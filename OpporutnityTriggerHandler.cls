public class OpporutnityTriggerHandler {
    
    public static void onInsertAccountRecords(List<Opportunity> newOpportunityList){
        List<Id> accountIdList = new List<Id>();
        for(Opportunity opportunityRecord : newOpportunityList){ 
            accountIdList.add(opportunityRecord.AccountId);		
        }
        accountUpdates(accountIdList);
    }

    public static void onUpdateAccountRecords(Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap){
        List<Id> accountIdList = new List<Id>();
        for(Opportunity newOpportunityRecord : newMap.values()){
        	Opportunity oldOpportunityRecord = oldMap.get(newOpportunityRecord.Id);
            if(oldOpportunityRecord.Name != newOpportunityRecord.Name){
           		accountIdList.add(newOpportunityRecord.AccountId);
            }
        }
        accountUpdates(accountIdList);
    }
    
    private static void accountUpdates(List<Id> accountList){
        Map<Id, List<String>> accountMap = new Map<Id, List<String>>();
        List<Account> updateAccountList = new List<Account>();
        for(Opportunity opportunity : [SELECT Name, AccountId FROM Opportunity WHERE AccountId IN: accountList]){
            if(!accountMap.containsKey(opportunity.AccountId)){
                accountMap.put(opportunity.AccountId, new List<String>{opportunity.Id, opportunity.Name});   
            } else{
            	String oppData = '|'+opportunity.Id+opportunity.Name;
            	accountMap.get(opportunity.AccountId).add(oppData);    
            }
        }
        if(!accountMap.isEmpty()){
            for(Account account : [SELECT Id, Description FROM Account WHERE Id IN: accountMap.keySet()]){
                if(accountMap.containsKey(account.Id)){
                    String descpString = (String.join(accountMap.get(account.Id),',')).replaceAll(',' ,'').deleteWhitespace(); 
                    account.Description = descpString;
                    updateAccountList.add(account);
                }
            }
        }
        if(!updateAccountList.isEmpty()){
            update updateAccountList;
        }
    }
}