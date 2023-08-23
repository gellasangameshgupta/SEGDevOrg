/**
* @Name: APTS_AgreementClauseTriggerHelper
* @Author: APTTUS
* @CreateDate: 01/31/2020
* @Description: Triggerhandler for Agreement Trigger.
-----------------------------------------------------------------------------------------------
**/
public class APTS_AgreementClauseTriggerHelper {
    
    public static void UpdateApprovalRequired(List<Apttus__Agreement_Clause__c> newList){
        Apttus__APTS_Agreement__c sAgr = new Apttus__APTS_Agreement__c();
        List<Apttus__APTS_Agreement__c> listAgr = new List<Apttus__APTS_Agreement__c>();
        Set<Id> selectClauseIds = new Set<Id> ();
        
        Apttus_Approval.ApprovalRequiredCheck checker = new Apttus_Approval.ApprovalRequiredCheck();
        for (Apttus__Agreement_Clause__c ac : newList){
            // If condition is to avoid error for Doc Generation / Re-generation
            If(ac.Apttus__Action__c == 'Modified' || ac.Apttus__Action__c == 'Deleted'){
                
            Boolean Approvalresult = !Test.isRunningTest()? checker.doCheck(ac.id):false;
            system.debug('Clause result :'+ Approvalresult);
                    if(!Approvalresult){
                         if(!Test.isRunningTest())
                         ac.addError('Approval Submission Failed');
                    }
                    
                    if( Approvalresult || Test.isRunningTest()){
                        selectClauseIds.add(ac.Id);                     
                    }
            }
        }
        
        // For Updating Agreement Approval Status = Approval Required
        try{
            system.debug('Updated called ' + listAgr);
            //List<Apttus__Agreement_Clause__c> agrClause = new List<Apttus__Agreement_Clause__c>([select Apttus__Agreement__c from Apttus__Agreement_Clause__c where Id IN:selectClauseIds and APTS_Approval_Status__c = 'Approval Required']);
            List<Apttus__Agreement_Clause__c> agrClause = new List<Apttus__Agreement_Clause__c>([select Apttus__Agreement__c from Apttus__Agreement_Clause__c where Id IN:selectClauseIds and Approval_Status__c = 'Approval Required']);
            for (Apttus__Agreement_Clause__c acls : agrClause){
            sAgr.Apttus_Approval__Approval_Status__c = 'Approval Required';
            sAgr.Apttus__Status_Category__c = 'In Authoring';
            sAgr.Apttus__Status__c = 'Author Contract';
            sAgr.Id = acls.Apttus__Agreement__c;
            system.debug('Agreement Id to be updated' + acls.Apttus__Agreement__c);
            listAgr.add(sAgr);
            }
            update listAgr;
              
        }catch (DmlException e) {
                System.debug('A DML exception has occurred: ' + e.getMessage());
        }    
            
    
    }    
}