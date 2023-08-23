/**********************************************************
    Class Name      :CreateNewVersion_CTRL
    Purpose         :Creates a Invalid record of existing test Specification
    Created By      :RBEI
    Created Date    :Dec 2018
***********************************************************/
public class UpdateStatusValue {
    @Auraenabled
    public static String testSpec(Id tid)
    {
        String x;
		Test_Specification__c t=[SELECT Id, Status__c,SEGTS_permissionsetChecking__c,Name FROM Test_Specification__c Where Id=:tid];
		x=t.SEGTS_permissionsetChecking__c;
        return x;
    }
     @AuraEnabled
    public static void updateStatusVal(Id TestSpecID){
        Test_Specification__c obj = new Test_Specification__c();
        obj = [SELECT Id, Status__c,SEGTS_permissionsetChecking__c,Name FROM Test_Specification__c Where Id=:TestSpecID];
        
        if((obj.Status__c=='Draft' || obj.Status__c=='Approved') && obj.SEGTS_permissionsetChecking__c!='NO EDIT'){
            obj.Status__c='Invalid';
            obj.Invalidated_By__c=userInfo.getUserId();
            obj.Invalidate_On__c=System.Today();
            update obj;
        }
    }
}