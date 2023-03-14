public class AccountController {
   
    @AuraEnabled (Cacheable=true)
    public Static Map<String, Double> getOppSumMapByStage(String accId, Date fromDate, Date toDate){
        List<Opportunity> oppList = [SELECT Amount, isClosed, isWon, AccountId FROM Opportunity WHERE AccountId = :accId AND CloseDate >= :fromDate AND 
                                           CloseDate <= :toDate];
    System.debug('oppList: '+ oppList);
    System.debug('getCategorizedMap: ' + getCategorizedMap (oppList));
    return getCategorizedMap (oppList);
    }
    //push class to github
    @AuraEnabled (Cacheable=true)
    public Static Map<String, Double> getOppSumWithChildAccounts(String accId, Integer hierarchyLevel, Date fromDate, Date toDate){
        String query = 'SELECT Amount, isClosed, isWon, AccountId FROM Opportunity WHERE (AccountId = :accId';
        String dateRangeQuery = ') AND CloseDate >= :fromDate AND CloseDate <= :toDate';
        String criteria = getHierarchyWhereClause (hierarchyLevel);
        System.debug('Additional criteria : ' + criteria);
        query = query + criteria + dateRangeQuery;
        System.debug('query : ' + query );
        List<Opportunity> oppList = Database.query(query);
        //List<Opportunity> oppList = [SELECT Amount, isClosed, isWon, AccountId FROM Opportunity WHERE AccountId = :accId];
    System.debug(oppList);
    System.debug(getCategorizedMap (oppList));
    return getCategorizedMap (oppList);
    }
    
    // Helper Methods
    private static String getHierarchyWhereClause (Integer hierarchyLevel){
        String initialPart = ' OR Account';
        String lastPart = '.ParentId =:accId';
        String criteria = '';
        for (Integer i=1; i<=hierarchyLevel; i++){
            if (i==1){
                criteria = initialPart + lastPart;
            } else if (i>1){
                criteria = criteria + ' ' + initialPart + getParentStatement(i) + lastPart;
            }
        }
        return criteria;
    }
    
    private static String getParentStatement (Integer hierarchyLevel){
        String parentStatement = '';
         for (Integer i=2; i<=hierarchyLevel; i++){
		 	parentStatement = parentStatement + '.Parent' ;
    	}
        return parentStatement;
    }
    
    private static Map<String, Double> getCategorizedMap (List<Opportunity> oppList){
        Map<String, Double> sumMapByStage = new Map<String, Double>();
        Double cwAmount = 0;
        Double clAmount = 0;
        Double openAmount = 0;
        for (Opportunity opp:oppList){
            if (opp.isClosed){
                if (opp.isWon) { // closedWon
                    cwAmount = cwAmount + opp.Amount;
                    sumMapByStage.put('Closed Won', cwAmount);
                } else { // closedLost
                    clAmount = clAmount + opp.Amount;
                    sumMapByStage.put('Closed Lost', clAmount);
                }
            } // Closed = Closed Won or Closed Lost
            else { // Open
                openAmount = openAmount + opp.Amount;
                sumMapByStage.put('Open', openAmount);
            }
   		}
        return sumMapByStage;
    }
}