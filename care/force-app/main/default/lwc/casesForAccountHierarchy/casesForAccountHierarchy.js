import { LightningElement, api, wire } from 'lwc';
import getCasesRelatedToAccountHierarchy from '@salesforce/apex/CasesForAccountHierarchyController.getCasesRelatedToAccountHierarchy';

export default class CasesForAccountHierarchy extends LightningElement {
    @api recordId;
    @api columns = [];
    @api tableData = [];
    @api titleText;
    @api fieldSetName;
    @api ObjectComponentIsOn;
    @api SetColumnAsHyperlink;
    @api SetColumnAsHyperlinkField;
    @api CaseFilterField;
    @api CaseFilterValue;


    connectedCallback(){
        getCasesRelatedToAccountHierarchy({ recordId : this.recordId,
                                            fieldSetAPIName : this.fieldSetName,
                                            objectComponentIsOn : this.ObjectComponentIsOn,
                                            caseFilterField : this.CaseFilterField,
                                            caseFilterValue : this.CaseFilterValue  })
        .then(data=> {
            console.log('cases');
            console.log(data);

            let objStr = JSON.parse(data);   
            let listOfFields= JSON.parse(Object.values(objStr)[1]);
            let listOfRecords = JSON.parse(Object.values(objStr)[0]);
            let items = [];

            listOfFields.map(element=>{
                if(this.SetColumnAsHyperlink == 'Yes' && 
                   element.fieldPath == this.SetColumnAsHyperlinkField){                               
                    
                    items = [...items ,
                                    {
                                        label: element.label, 
                                        fieldName: 'URLField',
                                        fixedWidth: 150,
                                        type: 'url', 
                                        typeAttributes: { 
                                            label: {
                                                fieldName: element.fieldPath
                                            },
                                            target: '_blank'
                                        },
                                        sortable: true 
                                    }
                    ];
                } else {
                    items = [...items ,{label: element.label, 
                        fieldName: element.fieldPath}];
                }   
            });

            this.columns = items; 
            this.tableData = listOfRecords;

            if(this.SetColumnAsHyperlink != null && this.SetColumnAsHyperlink == 'Yes'){
                this.createHyperLinkOnColumn();
            }
            this.error = undefined;
        })
        .catch(error =>{
            this.error = error;
            console.log('error',error);
            this.tableData = undefined;
        });
    }

    createHyperLinkOnColumn(){
        let URLField;
        this.tableData = this.tableData.map(item=>{
            URLField = '/lightning/r/' + this.SFDCobjectApiName + '/' + item.Id + '/view';
            return {...item,URLField};                     
        });
        this.tableData = this.tableData.filter(item => item.fieldPath  != this.SetColumnAsHyperlinkField);
    }
}