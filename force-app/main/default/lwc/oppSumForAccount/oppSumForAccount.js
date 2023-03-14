import { LightningElement, wire, api, track } from 'lwc';
import getOppSumMapByStage from "@salesforce/apex/AccountController.getOppSumMapByStage";
import getOppSumWithChildAccounts from "@salesforce/apex/AccountController.getOppSumWithChildAccounts";

export default class oppSumForAccount extends LightningElement {
    
    fromDate;
    toDate;
    hierarchyLevel;
    @api recordId;
    @track categorizedMap = [];
    @track categorizedMapWithChildAcc = [];

    @wire(getOppSumMapByStage, {accId:'$recordId', fromDate:'$fromDate', toDate:'$toDate'})
    oppAmountListByStages({error,data}){
        if(data){
            for(let key in data){
                this.categorizedMap.push({value:data[key], key:key});
            }
        }else if(error){
            window.console.log('An error has occured in getOppSumMapByStage: ');
            window.console.log(error);
        }
    }
    @wire(getOppSumWithChildAccounts,{accId:'$recordId', fromDate:"$fromDate", toDate:'$toDate', hierarchyLevel:'$hierarchyLevel'})
    oppAmountListByStagesWithChildAccs({error,data}){
        if(data){
            var tempMap =[]
            for(let key in data){
                tempMap.push({value:data[key], key:key});
            }
            this.categorizedMapWithChildAcc = tempMap;
            console.log('categorizedMapWithChildAcc' + this.categorizedMapWithChildAcc);
        }else if(error){
            window.console.log('An error has occured in getOppSumWithChildAccounts: ');
            window.console.log(error);
        }
    }
    
    
    handleToDateChange(event){
        window.clearTimeout(this.delayTimeout);
        const toDate = event.target.value;
        this.delayTimeout = setTimeout(() => {
            this.toDate = toDate
            console.log(this.toDate);
        }, 1000);
    }
    handleFromDateChange(event){
        window.clearTimeout(this.delayTimeout);
        const fromDate = event.target.value;
        this.delayTimeout = setTimeout(() => {
            this.fromDate = fromDate
            console.log(this.toDate);
        }, 1000);
    }
    handleHierarchyLevelChange(event){
        this.hierarchyLevel=event.detail.value;
    }

}