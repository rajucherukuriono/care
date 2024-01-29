import { LightningElement, api } from 'lwc';

export default class PhoneDetails extends LightningElement {
    @api displayPhoneProperty;
    @api displayLiveAgent;
    @api holidayMonth1;
    @api holidayDate1;
    @api holidayMonth2;
    @api holidayDate2;
    @api holidayMonth3;
    @api holidayDate3;
    @api holidayMonth4;
    @api holidayDate4;
    @api memberVisibility;
    @api visitorVisibility;
    
    monthNames = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];

    // Call Center Hours in Waltham time
    //      Mon - Fri: 8am - 6pm

    // Waltham time changes throughout the year
    // From November 3 - March 9: UTC-5
    // From March 10 - November 2: UTC-4 (known as Daylight Savings time)
    
    // Call Center Hours in UTC
    // From November 3 - March 9 (UTC -5)
    //      Mon - Fri: 1pm - 11pm UTC
    // From March 10 - Nov 2 (UTC -4) (Daylight Savings)
    //      Mon - Fri: 12pm - 10pm UTC

    getTargetOpenHourMonToThu(daylightSavingsOffset){
        return 13 - daylightSavingsOffset; // 1pm UTC normally; 12pm UTC in Daylight Savings
    }

    getTargetCloseHourMonToThu(daylightSavingsOffset){
        return 23 - daylightSavingsOffset; // 11pm UTC normally; 10pm UTC in Daylight Savings
    }

    getTargetOpenHourFri(daylightSavingsOffset){
        return 13 - daylightSavingsOffset; // 1pm UTC normally; 12pm UTC in Daylight Savings
    }

    getTargetCloseHourFri(daylightSavingsOffset){
        return 23 - daylightSavingsOffset; // 11pm UTC normally; 10pm UTC in Daylight Savings
    }

    getOffset(){
        // If waltham is in Daylight Savings time, we will substract 1 to UTC time (because we're moving from -500 to -400)
        if (this.isWalthamInDaylightSavings() === true) return 1;
        return 0;
    }

    isWalthamInDaylightSavings(){
        var now = new Date();
        var currentMonth = now.getUTCMonth();
        var currentDate = now.getUTCDate();
        if (currentMonth === 0 || currentMonth === 1 || currentMonth === 12){ // Jan, Feb or Dec
            return false;
        } else if (currentMonth === 10 && currentDate > 2){ // Later than Nov 2
            return false;
        } else if (currentMonth === 2 && currentDate < 10){// Earlier than March 10
            return false;
        } 
        return true;
      }

    get displayPhone(){
        
        console.log(this.memberVisibility==='No' || this.memberVisibility===undefined);
        console.log(this.visitorVisibility==='No' || this.visitorVisibility===undefined);
        console.log(window.localStorage.getItem('MemberId'));
        console.log(window.localStorage.getItem('ExternalMemberId')===undefined);
        console.log(window.localStorage.getItem('ExternalMemberId')!==null);
        console.log(window.localStorage.getItem('ExternalMemberId'));
        console.log(this.visitorVisibility);
        console.log(this.memberVisibility);

        if (this.displayPhoneProperty === false) return false; // Phone is being overriden at config level

        const now = new Date();
        if (this.isItAHoliday(now) === true) return false; // because its a holiday

        if(window.localStorage.getItem('ExternalMemberId')!==null && (this.memberVisibility==='No' || this.memberVisibility===undefined))
        {
            console.log('Inside Member Criteria, dont display Phone :)');
        return false;
        }
        else if(window.localStorage.getItem('ExternalMemberId')===null && (this.visitorVisibility==='No' || this.visitorVisibility===undefined))
        {
            console.log('Inside Visitor Criteria, dont display Phone :)');
        return false;
        }
        console.log("Member/Visitor has Phone Access :)");

        const currentDay = now.getUTCDay();
        const currentHour = now.getUTCHours();
        const walthamOffset = this.getOffset();
        if (currentDay > 0 && currentDay < 5){ // Mon to Thu
            if (currentHour >= this.getTargetOpenHourMonToThu(walthamOffset) && currentHour < this.getTargetCloseHourMonToThu(walthamOffset)){ 
                return true;
            } 
        }
        if (currentDay === 5){ // Friday
            if (currentHour >= this.getTargetOpenHourFri(walthamOffset) && currentHour < this.getTargetCloseHourFri(walthamOffset)){
                return true;
            }
        }

       

        return false;
    }

    isItAHoliday(now){
        const currentMonth = now.getUTCMonth();
        const currentMonthName = this.monthNames[currentMonth];
        const currentDate = now.getUTCDate();

        const holidayMonth1 =  this.holidayMonth1;
        const holidayDate1 = Number.parseInt(this.holidayDate1,10);
        if (currentMonthName === holidayMonth1 && currentDate === holidayDate1){
            return true; // because it's a holiday
        }

        const holidayMonth2 =  this.holidayMonth2;
        const holidayDate2 = Number.parseInt(this.holidayDate2,10);
        if (currentMonthName === holidayMonth2 && currentDate === holidayDate2){
            return true; // because it's a holiday
        }

        const holidayMonth3 =  this.holidayMonth3;
        const holidayDate3 = Number.parseInt(this.holidayDate3,10);
        if (currentMonthName === holidayMonth3 && currentDate === holidayDate3){
            return true; // because it's a holiday
        }

        const holidayMonth4 =  this.holidayMonth4;
        const holidayDate4 = Number.parseInt(this.holidayDate4,10);
        if (currentMonthName === holidayMonth4 && currentDate === holidayDate4){
            return true; // because it's a holiday
        }

        return false;
    }



    get displayRule(){
        var displayLiveAgent = this.displayLiveAgent;
        if (displayLiveAgent === true) return true;
        return false;
    }
}