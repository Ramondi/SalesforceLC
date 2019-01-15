public class VA_dependentPicklist_UpdateCtrl  {
	@AuraEnabled 
    public static Map<String, List<String>> getDependentMap(sObject objDetail, string contrfieldApiName,string depfieldApiName,string rtDeveloperName) {
        String controllingField = contrfieldApiName.toLowerCase();
        String dependentField = depfieldApiName.toLowerCase();
        String rtName = rtDeveloperName.toLowerCase();
        Map<String,List<String>> objResults = new Map<String,List<String>>();
        
        Schema.sObjectType objType = objDetail.getSObjectType();
        if (objType==null){
            return objResults;
        }
		
        
        Map<String, Schema.SObjectField> objFieldMap = objType.getDescribe().fields.getMap();
        
        if (!objFieldMap.containsKey(controllingField) || !objFieldMap.containsKey(dependentField)){
            return objResults;     
        }
        
        Schema.SObjectField theField = objFieldMap.get(dependentField);
        Schema.SObjectField ctrlField2 = objFieldMap.get(controllingField);
		List<PicklistValue> ctrlField = getPicklistValueBasedonRecordType(objType.getDescribe().getName(), contrfieldApiName, rtName) ;
        List<PicklistValue> contrEntries = ctrlField;
		List<Schema.PicklistEntry> contrEntries2 = ctrlField2.getDescribe().getPicklistValues();
        List<PicklistEntryWrapper> depEntries = wrapPicklistEntries(theField.getDescribe().getPicklistValues());
        List<String> controllingValues = new List<String>();
		List<String> controllingValues2 = new List<String>();
        
        for (PicklistValue ple : ctrlField) {
            String label = ple.label;
            controllingValues.add(label);
        }
		for (Schema.PicklistEntry ple: contrEntries2) {
            String label = ple.getLabel();
            objResults.put(label, new List<String>());
            controllingValues2.add(label);
        }
		System.debug(controllingValues2);
        
        for (PicklistEntryWrapper plew : depEntries) {
            String label = plew.label;
            String validForBits = base64ToBits(plew.validFor);
            for (Integer i = 0; i < validForBits.length(); i++) {
                String bit = validForBits.mid(i, 1);
                if (bit == '1') {
                    objResults.get(controllingValues2.get(i)).add(label);
                }
            }
        }
		Map<String,List<String>> objResults2 = new Map<String,List<String>>();
		for(String element:controllingValues) {
			objResults2.put(element,objResults.get(element));
		}

        return objResults2;
    }
    
    public static String decimalToBinary(Integer val) {
        String bits = '';
        while (val > 0) {
            Integer remainder = Math.mod(val, 2);
            val = Integer.valueOf(Math.floor(val / 2));
            bits = String.valueOf(remainder) + bits;
        }
        return bits;
    }
    
    public static String base64ToBits(String validFor) {
        if (String.isEmpty(validFor)) return '';
        
        String validForBits = '';
        
        for (Integer i = 0; i < validFor.length(); i++) {
            String thisChar = validFor.mid(i, 1);
            Integer val = base64Chars.indexOf(thisChar);
            String bits = decimalToBinary(val).leftPad(6, '0');
            validForBits += bits;
        }
        
        return validForBits;
    }
    
    private static final String base64Chars = '' +
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ' +
        'abcdefghijklmnopqrstuvwxyz' +
        '0123456789+/';
    
    
    private static List<PicklistEntryWrapper> wrapPicklistEntries(List<Schema.PicklistEntry> PLEs) {
        return (List<PicklistEntryWrapper>)
            JSON.deserialize(JSON.serialize(PLEs), List<PicklistEntryWrapper>.class);
    }
    
    public class PicklistEntryWrapper{
        public String active {get;set;}
        public String defaultValue {get;set;}
        public String label {get;set;}
        public String value {get;set;}
        public String validFor {get;set;}
        public PicklistEntryWrapper(){            
        }
        
    }

	public static list<PicklistValue> getPicklistValueBasedonRecordType(String objectAPIName, String fieldAPIName, String recordTypeDeveloperName){
       
       list<PicklistValue> picklistValues = new list<PicklistValue>();
       
       //get record type Id
       list<RecordType> recordTypes = [Select Id, Name From RecordType  Where SobjectType = :objectAPIName and DeveloperName = :recordTypeDeveloperName limit 1];
       Id recordTypeId = (!recordTypes.isEmpty()) ? recordTypes.get(0).Id : null;
       
       if(recordTypeId != null){
           
           String method = 'GET';
		   String y = Url.getSalesforceBaseUrl().toExternalForm().replace('Url:[delegate=','').replace(']','');
		   String endpoint = String.format('/services/data/v41.0/ui-api/object-info/{0}/picklist-values/{1}/{2}', new String[]{ objectAPIName, recordTypeId, fieldAPIName });
           HttpRequest request = new HttpRequest();
           request.setEndpoint('callout:UI_API_Named_Credentials'+endPoint);
           request.setMethod(method);
           
           HTTPResponse response = (new Http()).send(request);
		   
           if(response.getStatusCode() == 200){
               
               Map<String,Object> root = (Map<String,Object>) JSON.deserializeUntyped(response.getBody());
               if(root.containsKey('values')){ 
                   List<Object> picklistVals = (List<Object>)root.get('values');
                   for(Object picklistVal : picklistVals){
                       Map<String,Object> picklistValMap = (Map<String,Object>) picklistVal;
                       picklistValue pickVal = new picklistValue();
                       pickVal.value = (String) picklistValMap.get('value');
                       pickVal.label = (String) picklistValMap.get('label');
                       picklistValues.add(pickVal);
                   }
               }
               
           }
           
       }
       
      return picklistValues;
   }
   
   public class PicklistValue{
       public String value {get;set;}
       public String label {get;set;}
   }
}
