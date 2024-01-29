import { LightningElement, api } from 'lwc';
import getReviewInformation from '@salesforce/apex/ReviewModerationController.getReviewInformation';
import getCaseInformation from '@salesforce/apex/ReviewModerationController.getCaseInformation';
import createCaseComment from '@salesforce/apex/ReviewModerationController.createCaseComment';
import rejectReview from '@salesforce/apex/ReviewModerationController.rejectReview';
import editReviewValues from '@salesforce/apex/ReviewModerationController.editReviewValues';

import { getRecord, notifyRecordUpdateAvailable } from 'lightning/uiRecordApi';
import closeCase from '@salesforce/apex/ReviewModerationController.closeCase';
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class ModerateReviews extends LightningElement {

    @api recordId;
    isLoading;
    modalSpinner;
    isModalOpen = false;
    reviewRating;
    updatedReviewRating;
    reviewRatingSelectedId;
    seekerMemberId;
    seekerMemberUUId;
    providerMemberId;
    providerMemberUUId;
    displaySeekerDetails;
    displayProviderDetails;

    reviewText;
    reviewTextModal;
    caseCommentText;
    contactReason;

    onRejectModal = false;
    reviewUUID;
    textField;
    hasReviewUUId;

    modalError = false;
    modalErrorMessage;
    publishSuccess = true;
    caseStatusClosed = false;

    _title = "Publish Changes";
    message = "";
    variant = "";

    isEdit = false;
    isRatingChanged = false;

    textFieldEdited = false;

    is5checked;
    is4checked;
    is3checked;
    is2checked;
    is1checked;

    hasErrors;
    errorMessages = [];

    reviewRatingName;
    reviewRatingParenthesis;
    updatedReviewRatingParenthesis;

    connectedCallback(){
        this.setReviewRatingName();
        this.isLoading = true;
        this.getCaseInfo();
        this.isLoading = false;
    }

    setReviewRatingName(){
        this.reviewRatingName = "ReviewRating" + Math.random();
    }

    async rating(event) {
        this.isRatingChanged = true;
        this.updatedReviewRating = event.target.value;
        this.updatedReviewRatingParenthesis = event.target.value;
        this.setRatingForEdit();
    }

    async openEditModal() {
        this.reviewTextModal = this.reviewText;
        this.onRejectModal = false;
        this.updatedReviewRating = this.reviewRating;
        this.setRatingForEdit();
        this.isModalOpen = true;
        this.contactReason = 'Review Edited';
    }

    handleReject(){
        this.isLoading = true;
        this.onRejectModal = true;
        this.reviewTextModal = this.reviewText;
        this.isModalOpen = true;
        this.updatedReviewRating = this.reviewRating;
        this.setRatingForEdit();
        this.contactReason = 'Review Rejected';
        this.isLoading = false;
    }

    async publish() {
        this.modalSpinner = true;

        if(this.sufficientLengthComment()){
            let result = await editReviewValues({ reviewUUId : this.reviewUUID,
                                                textFieldEdited : this.textFieldEdited,
                                                textEdited : this.reviewTextModal,
                                                isRatingUpdated : this.isRatingChanged,
                                                updatedRatingValue : this.updatedReviewRating })

            const parsedResults = JSON.parse(result);                       
            if(parsedResults.isSuccessful){
                this.message = 'The changes were published successfully.'
                this.variant = 'success';

                this.showNotification();
            
                await this.createCaseComment();
                await this.closeCase();
                await notifyRecordUpdateAvailable([{recordId: this.recordId}]);

                this.reviewText = this.reviewTextModal;
                
                this.reviewRating = this.updatedReviewRating;
                this.reviewRatingParenthesis = this.updatedReviewRatingParenthesis;

                this.setRating();
                this.isModalOpen = false;
                this.modalSpinner = false;
            
                
            } else {
                this.message = 'There was an issue publishing changes. Changes were NOT published.'
                this.variant = 'error'
                this.showNotification();
                this.isLoading = false;
                this.modalSpinner = false;
            }
        }
    }

    async handleReviewRejection(){
        this.modalSpinner = true;

        if(this.sufficientLengthComment()){
            let result = await rejectReview({ reviewUUId : this.reviewUUID});
            const parsedResults = JSON.parse(result);
                
            if(parsedResults.isSuccessful){
                await this.createCaseComment();
                await this.closeCase();
                await notifyRecordUpdateAvailable([{recordId: this.recordId}]);
                    
                this.closeModal();

                this.message = 'The review was successfuly rejected.'
                this.variant = 'success';
                this.showNotification();
            } else{
                this.message = 'There was an issue rejecting this review. Review NOT rejected.'
                this.variant = 'error';
                this.showNotification();
            }
            this.modalSpinner = false;
            }
        
    }

    sufficientLengthComment(){
        if(this.caseCommentText && this.caseCommentText.length >= 10){
            this.modalError = false;
            return true;
        } else {
            this.modalErrorMessage = 'Please enter a comment that is at least 10 characters';
            this.modalError = true;
            this.modalSpinner = false;
            return false;
        }
    }

    async getReviewInfo(){
        let result = await getReviewInformation({ reviewUUId : this.reviewUUID})
            let resultDeserialized = JSON.parse(result);
            console.log('resultDeserialized');
            console.log(resultDeserialized);
            if(resultDeserialized.isSuccessful){
                if(resultDeserialized.reviewData.description && resultDeserialized.reviewData.description.display_text){
                    this.reviewText = resultDeserialized.reviewData.description.display_text;
                } else if(resultDeserialized.reviewData.description && resultDeserialized.reviewData.description.original_text){
                    this.reviewText = resultDeserialized.reviewData.description.original_text;
                } else{
                    this.hasErrors = true;
                    this.errorMessages.push('No review text was return for this Review UUID');
                }
                
                if(resultDeserialized.reviewData.ratings){
                    this.reviewRatingParenthesis = resultDeserialized.reviewData.ratings[0].value;
                    this.updatedReviewRatingParenthesis = resultDeserialized.reviewData.ratings[0].value;
                    this.reviewRating = Math.ceil(resultDeserialized.reviewData.ratings[0].value);
                } else {
                    this.hasErrors = true;
                    this.errorMessages.push('No rating was return for this Review UUID');
                }
                this.setRating();
            } else {
                this.hasErrors = true;
                this.errorMessages.push('There was an issue getting review data');
                this.errorMessages.push(resultDeserialized.message);
            }
            
    }

    async getCaseInfo(){
        let result = await getCaseInformation({ recordId : this.recordId})
        this.reviewUUID = result.Review_UUID__c;

        if(result.Status == 'Closed'){
            this.caseStatusClosed = true;
            this.contactReason = result.Contact_Reason__c;
        }

        if(this.reviewUUID) {
            this.getReviewInfo();
            this.hasReviewUUId = true;
        }
    }

    handleReviewTextChange(event){
        this.reviewTextModal = event.target.value;
        this.textFieldEdited = true;
    }

    showNotification(){
        this.dispatchEvent(new ShowToastEvent({
            title: this._title,
            message: this.message,
            variant: this.variant
        }));
    }

    handleUpdatedValues(event){
        this.reviewText = event.detail.updatedText;
    }

    async handleApprove(){
        this.isLoading = true;
        this.contactReason = 'Review Approved';
        await this.closeCase();
        await notifyRecordUpdateAvailable([{recordId: this.recordId}]);
        this.isLoading = false;
    }

    

    async closeCase(){
        let result = await closeCase({ recordId : this.recordId,
                                       contactReason : this.contactReason})
        let resultDeserialized = JSON.parse(result);

        if(resultDeserialized.isSuccessful){
            this.caseStatusClosed = true;
        } else {
            this.hasErrors = true;
            this.errorMessages.push('Could not update case: ' + resultDeserialized.message);

            this.message = 'There was an issue closing the case: ' + resultDeserialized.message;
            this.variant = 'error';
            this.showNotification();
        }
    }

    closeModal() {
        this.isModalOpen = false;
    }

    async createCaseComment(){
        if(this.caseCommentText) {
            let result = await createCaseComment({ recordId : this.recordId,
                                                   caseComment : this.caseCommentText})
        }
    }

    handleCommentChange(event){
        this.caseCommentText = event.target.value;
    }

    setRating(){
        switch (parseInt(this.reviewRating)){
            case 5:
                this.template.querySelector('[data-id="star5ReadOnly"]').checked = true;
                break;
            case 4:
                this.template.querySelector('[data-id="star4ReadOnly"]').checked = true;
                break;
            case 3:
                this.template.querySelector('[data-id="star3ReadOnly"]').checked = true;
                break;
            case 2:
                this.template.querySelector('[data-id="star2ReadOnly"]').checked = true;
                break;
            case 1:
                this.template.querySelector('[data-id="star1ReadOnly"]').checked = true;
                break;
        }
    }

    /*
    * Not sure why but the setRating method would not work for the radio group in the modal.
    * Setting the value to a property worked though so going with that.
    */
    setRatingForEdit(){
        this.uncheckAll();
        switch (parseInt(this.updatedReviewRating)){
            case 5:
                this.is5checked = true;
                break;
            case 4:
                this.is4checked = true;
                break;
            case 3:
                this.is3checked = true;
                break;
            case 2:
                this.is2checked = true;
                break;
            case 1:
                this.is1checked = true;
                break;
        }
    }

    uncheckAll(){
        this.is5checked = false;
        this.is4checked = false;
        this.is3checked = false;
        this.is2checked = false;
        this.is1checked = false;
    }
}