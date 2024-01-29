//Next three need to be kept until deploy complete, then they can be removed
import HC_Topic_Account_Management from '@salesforce/label/c.HC_Topic_Account_Management';
import HC_Topic_Using_Your_Account from '@salesforce/label/c.HC_Topic_Using_Your_Account';
import HC_Topic_Subscription_Billing from '@salesforce/label/c.HC_Topic_Subscription_Billing';

import HC_Topic_Trust_Safety from '@salesforce/label/c.HC_Topic_Trust_Safety';
import HC_Topic_Account_and_Profile from '@salesforce/label/c.HC_Topic_Account_and_Profile';
import HC_Topic_Finding_a_Caregiver from '@salesforce/label/c.HC_Topic_Finding_a_Caregiver';
import HC_Topic_Running_My_Business from '@salesforce/label/c.HC_Topic_Running_My_Business';
import HC_Topic_Bookings_and_Full_Time_Jobs from '@salesforce/label/c.HC_Topic_Bookings_and_Full_Time_Jobs';
import HC_Topic_Payments from '@salesforce/label/c.HC_Topic_Payments';
import HC_Topic_My_Profile_and_Services from '@salesforce/label/c.HC_Topic_My_Profile_and_Services';
import HC_Topic_Getting_Started from '@salesforce/label/c.HC_Topic_Getting_Started';


const getTopicName = (topicName) => {
    // Given an english topic name, returns a localized topic name from custom labels
    if (topicName === undefined) return '';

    topicName = topicName.toLowerCase();
    if(topicName === 'account and profile'){
        return HC_Topic_Account_and_Profile;
    } else if (topicName === 'finding a caregiver'){
        return HC_Topic_Finding_a_Caregiver;
    } else if (topicName === 'running my business'){
        return HC_Topic_Running_My_Business;
    } else if (topicName === 'bookings and full-time jobs'){
        return HC_Topic_Bookings_and_Full_Time_Jobs;
    } else if (topicName === 'payments'){
        return HC_Topic_Payments;
    } else if (topicName === 'my profile and services'){
        return HC_Topic_My_Profile_and_Services;
    } else if (topicName === 'getting started'){
        return HC_Topic_Getting_Started;
    } else if (topicName === 'trust & safety'){
        return HC_Topic_Trust_Safety;
    } else if (topicName === 'subscription & billing'){ //subscription-billing can be removed after deploy complete
        return HC_Topic_Subscription_Billing;
    } else if (topicName === 'using your account'){  //using-your-account can be removed after deploy complete
        return HC_Topic_Using_Your_Account;
    } else if (topicName === 'account management'){  //account-management can be removed after deploy complete
        return HC_Topic_Account_Management;
    } 
    return '';
};

export { getTopicName };