/**
 * Created by Craig.Bradshaw on 15/03/2019.
 */

global class AccountKeyInfoWrapper implements Comparable{

    @AuraEnabled
    public String headline {get;set;}

    @AuraEnabled
    public String[] dataItems {get;set;}

    @AuraEnabled
    public Integer priority {get;set;}

    public AccountKeyInfoWrapper(){
        
    }

    public AccountKeyInfoWrapper(String headline,String[] data, Integer priority){
        this.headline = headline;
        this.dataItems = data;
        this.priority = priority;
    }

    global Integer compareTo(Object compareTo) {
        AccountKeyInfoWrapper compareWrapper = (AccountKeyInfoWrapper)compareTo;
        Integer returnValue = 0;

        if(this.priority > compareWrapper.priority){
            returnValue =  1;
        }else if (this.priority < compareWrapper.priority){
            returnValue = -1;
        }
        return returnValue;
    }

}