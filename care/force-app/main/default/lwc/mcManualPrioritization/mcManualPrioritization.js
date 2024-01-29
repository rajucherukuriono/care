/*
API : 52
Source : lwcFactory.com
*/
import {LightningElement, api, wire, track} from 'lwc';
//Import apex method 
import fetchCases from '@salesforce/apex/mcCaseManualPrioritization.appCustomWrapListMthd';
import updateCases from '@salesforce/apex/mcCaseManualPrioritization.updateCases';
import updatePriority from '@salesforce/apex/mcCaseManualPrioritization.updatePriority';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getPicklistValuesfromMap from '@salesforce/apex/mcCaseManualPrioritization.getPicklistValuesfromMap';
import getFieldLableAndFieldAPI from '@salesforce/apex/mcCaseManualPrioritization.getFieldLableAndFieldAPI';
export default class DatatableWithPagination extends LightningElement {   
    
    
    // JS Properties for datatable
    @track pageSizeOptions = [10, 25, 50, 75, 100]; //Page size options
    @track records = []; //All records available in the data table
    columns = []; //columns information available in the data table
    @track columnsSet =[];
    @track totalRecords = 0; //Total no.of records
    @track pageSize; //No.of records to be displayed per page
    @track totalPages; //Total no.of pages
    @track pageNumber = 1; //Page number    
    @track recordsToDisplay = []; //Records to be displayed on the page
    checkFieldSet= false;

    @track wiredRecords;
    @track error;
    @track draftValues = [];
    @track mapData= [];

    @track toastMessageError;
    @track toastMessageSuccess;
    @track toastError = false;
    @track toastSuccess = false;
    @track selectList = [];
    @track searchString;
    @track initialRecords;
    @track casesSpinner = true;
    @track showError;

    get bDisableFirst() {
        return this.pageNumber == 1;
    }
    get bDisableLast() {
        return this.pageNumber == this.totalPages;
    }


    renderedCallback() {
        this.handleCallfromService();
        this.loadColumns();
    }

    
    // connectedCallback method called when the element is inserted into a document
    connectedCallback(){
        this.loadPicklists();
        this.fetchAllCases();  
    }

    loadColumns(){
        getFieldLableAndFieldAPI()
        .then((data) =>{            
            let fieldSet = JSON.parse(data);
            for (let index = 0; index < fieldSet.length; index++) {
                if(Object.keys(fieldSet[index])[0] =='Case Number'){
                    this.columns.push({
                        label: 'Case Number',
                        fieldName: 'CaseLink',
                        type: 'url',
                        typeAttributes: {label: { fieldName: 'CaseNumber' }, 
                        target: '_blank'},
                        sortable: true
                    });
                }
                else if(Object.keys(fieldSet[index])[0] =='Priority'){
                    this.columns.push({
                        label: 'Priority',
                        fieldName: 'Priority',
                        editable: true,
                        sortable: true
                    });                    
                } 
                else if(Object.keys(fieldSet[index])[0] =='Last Modified Date'){
                    this.columns.push({
                        label: 'Last Modified Date',
                        fieldName: 'LastModifiedDate',
                        type: 'date', 
                        typeAttributes: {
                            day: 'numeric',
                            month: 'short',
                            year: 'numeric',
                            hour: '2-digit',
                            minute: '2-digit',
                            second: '2-digit',                            
                            hour12: true
                        },
                        sortable: true
                    });                    
                }                
                else{
                    this.columns.push({label : Object.keys(fieldSet[index])[0], fieldName : Object.values(fieldSet[index])[0]});
                }
            }
            this.checkFieldSet = true;
        })
        .catch((error) => {
            console.log(error);
            //this.showError(error);
        });
    }    

    loadPicklists(){
        getPicklistValuesfromMap()
        .then((data) => {            
            if (data != null) {
                var conts = data;
                for(var key in conts){
                    this.mapData.push({value:conts[key], key:key});              
                }            
            }                
        })
        .catch((error) => {
            console.log('error while fetching metadata--> ' + JSON.stringify(error));
        });

    }

    
    fetchAllCases(){
        var mapCon = this.mapData;  
        var tMap = [];      
        for(var key in mapCon){
            tMap.push({key: mapCon[key].key, value: this.template.querySelector("[data-id='"+mapCon[key].key+"']").value});
            //console.log('Key:  '+mapCon[key].key );
            //console.log('Value: '+ this.template.querySelector("[data-id='"+mapCon[key].key+"']").value);
        }
        this.fetchCasesOnLoad(tMap);
    }


     // fetch cases records from apex method 
     async fetchCasesOnLoad(data) {
        fetchCases({ mapFieldValues: data })
        .then((result) => {
            if (result != null) {
                this.records = [];
                this.initialRecords = [];
                //console.log('triggerred'+result.length);
                let tempRecs = [];
                result.forEach( ( record ) => {
                    let tempRec = Object.assign( {}, record );  
                    tempRec.CaseLink = '/' + tempRec.Id;
                    tempRecs.push( tempRec );
                    
                });
                this.records = tempRecs;
                this.initialRecords = tempRecs;
                //this.records = result;
                this.totalRecords = result.length; // update total records count                 
                this.pageSize = this.pageSizeOptions[0]; //set pageSize with default value as first option
                this.paginationHelper(); // call helper menthod to update pagination logic 
                this.casesSpinner = false;
            }
        })
        .catch((error) => {
            console.log('error while fetch Cases--> ' + JSON.stringify(error));
        });
    }

    async handleCallfromService() {
        this.template.querySelectorAll("[data-id='itemLabel']").forEach(element => {
            let labelVal = element.innerHTML.replace('__c', '');
            labelVal = labelVal.replace('_', ' ');
            labelVal = labelVal.replace('_', ' ');
            element.innerHTML = labelVal; 
        });
    }

    
    
   
    @track TypeSelect = [];
    handleChange(event) {
        for(var key in this.mapData){
            this.TypeSelect = this.template.querySelectorAll("[data-id='"+key+"']");
        }
        const selectInputs = this.template.querySelectorAll("[class='slds-select selectPicklist']");
        selectInputs.forEach( input => {
          //  this.TypeSelect.push(input.target);
        });        
    }

    async handleSave( event ) {
        const updatedFields = event.detail.draftValues;
        console.log('******');
        console.log(updatedFields);
        await updateCases( { data: updatedFields } )
        .then( result => {
            if (result != null) {                       
                this.toastSuccess = true;
                this.toastMessageSuccess = result;
                this.fetchCasesOnLoad(this.selectList);
             }    
        }).catch( error => {
            console.log( 'Error is ' + JSON.stringify( error ) );
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error updating or refreshing records',
                    message: error.body.message,
                    variant: 'error'
                })
            );

        });

    }


    getSelectedRec() {
        var selectedRecords =  this.template.querySelector("lightning-datatable").getSelectedRows();
        if(selectedRecords.length > 0){
            console.log('selectedRecords are ', selectedRecords);
            
            let ids = '';
            var setIds = [];
            selectedRecords.forEach(currentItem => {
                ids = ids + ',' + currentItem.Id;
                setIds.push(currentItem.Id);
            });
            this.selectedIds = ids.replace(/^,/, '');
            this.lstSelectedRecords = selectedRecords;
            let casePrior= this.template.querySelector("[data-id='updatePriority']").value;
            if(casePrior !=null ){
                updatePriority({ caseIds: setIds ,  priority : casePrior})
                .then((result) => {
                    if (result != null) {                       
                       this.toastSuccess = true;
                       this.toastMessageSuccess = result;
                       this.fetchCasesOnLoad(this.selectList);
                    }
                })
                .catch((error) => {
                    this.toastError = true;
                    this.toastMessageError = 'error while fetch Cases--> ' + JSON.stringify(error);
                    console.log('error while fetch Cases--> ' + JSON.stringify(error));
                });
            }
        }   
    }

    

    handleRecordsPerPage(event) {
        this.pageSize = event.target.value;
        this.paginationHelper();
    }

    previousPage() {
        this.pageNumber = this.pageNumber - 1;
        this.paginationHelper();
    }

    nextPage() {
        this.pageNumber = this.pageNumber + 1;
        this.paginationHelper();
    }

    firstPage() {
        this.pageNumber = 1;
        this.paginationHelper();
    }

    lastPage() {
        this.pageNumber = this.totalPages;
        this.paginationHelper();
    }


    // JS function to handel pagination logic 
    paginationHelper() {
        this.recordsToDisplay = [];
        // calculate total pages
        this.totalPages = Math.ceil(this.totalRecords / this.pageSize);
        // set page number 
        if (this.pageNumber <= 1) {
            this.pageNumber = 1;
        } else if (this.pageNumber >= this.totalPages) {
            this.pageNumber = this.totalPages;
        }

        // set records to display on current page 
        for (let i = (this.pageNumber - 1) * this.pageSize; i < this.pageNumber * this.pageSize; i++) {
            if (i === this.totalRecords) {
                break;
            }
            this.recordsToDisplay.push(this.records[i]);
        }
    }

    handleSearchonBlur(event) {
        this.casesSpinner = true;
        const searchKey = event.target.value.toLowerCase();
        console.log('search is::'+searchKey);
        if (searchKey!='' && searchKey!=null) {
            this.recordsToDisplay = this.initialRecords;
 
            if (this.recordsToDisplay) {
                let searchRecords = [];
 
                for (let record of this.recordsToDisplay) {
                    let valuesArray = Object.values(record);
 
                    for (let val of valuesArray) {
                        //console.log('val is ' + val);
                        let strVal = String(val);
 
                        if (strVal) { 
                            if (strVal.toLowerCase().includes(searchKey)) {
                                searchRecords.push(record);
                                break;
                            }
                        }
                    }
                }
                //console.log('Matched Cases are ' + JSON.stringify(searchRecords));
                this.recordsToDisplay = searchRecords;

                this.totalRecords = searchRecords.length; // update total records count                 
                this.pageSize = this.pageSizeOptions[0]; //set pageSize with default value as first option
                this.casesSpinner = false;
            }
        } else {
            this.fetchAllCases();  
        }
    }

    
}