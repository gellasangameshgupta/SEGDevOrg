/**
* @description Used to fetch Account related data from Jagger
* @createdDate Jan 28, 2022
*/
public with sharing class CLM_AccountUpsertQueue implements Queueable, Database.AllowsCallouts {
    private final Integer offset;
    private List<Account> accounts;

    /**
    * @description Fetch specific number of Accounts from Jagger API based on the offset value
    * @createdDate Jan 28, 2022
    * @param offset
    */
    public CLM_AccountUpsertQueue(Integer offset){
        this.offset = offset;
    }

    /**
    * @description Fetch specific number of Accounts from Jagger API based on the offset value
    * @createdDate Jan 28, 2022
    */
    public void execute(QueueableContext context) {
        CLM_AccountCalloutUtility obj = new CLM_AccountCalloutUtility();
        obj.getCompanies(offset);
    }
}