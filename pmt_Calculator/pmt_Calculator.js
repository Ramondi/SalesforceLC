import { LightningElement, track } from "lwc";

export default class pmt_Calculator extends LightningElement {
  @track monthly;
  interest;
  periods;
  periodsperyear;
  @track netloan;

  onInputChangeHandler(event) {
    const name = event.target.name;
    if (name === "interest") {
      this.interest = event.target.value;
    } else if (name === "periods") {
      this.periods = event.target.value;
    } else if (name === "netloan") {
      this.netloan = event.target.value;
    } else if (name === "monthly") {
      this.monthly = event.target.value;
    } else if (name === "periodsperyear") {
      this.periodsperyear = event.target.value;
    }
  }

  onButtonCLick(event) {
    var operation = event.target.label;
    if (
      !isNaN(this.interest) &&
      !isNaN(this.periods) &&
      (!isNaN(this.netloan) || !isNaN(this.monthly))
    ) {
      const interest1 = parseFloat(this.interest) / 100;
      const periods1 = parseInt(this.periods, 10);
      const netloan1 = parseFloat(this.netloan);
      const monthly1 = parseInt(this.monthly);
      const periodsperyear1 = parseInt(this.periodsperyear);

      var tempResult = 0.0;
      if (operation === "Get Monthly Payment") {
        tempResult = `${
          (netloan1 * interest1) / (1 - Math.pow(1 + interest1, -periods1))
        }`;
        if (
          tempResult !== null &&
          tempResult !== "" &&
          tempResult !== undefined &&
          !isNaN(tempResult)
        ) {
          this.monthly = Math.round(tempResult * 100) / 100;
        }
      } else if (operation === "Get Net Loan") {
        // = 450 *( ( 1-POW( 1 + 0,045 ; -720 ) ) / 0,045)
        tempResult = `${
          monthly1 * ((1 - Math.pow(1 + interest1, -periods1)) / interest1)
        }`;

        if (
          tempResult !== null &&
          tempResult !== "" &&
          tempResult !== undefined &&
          !isNaN(tempResult)
        ) {
          this.netloan = Math.round(tempResult * 100) / 100;
        }
      }
    }
  }
}