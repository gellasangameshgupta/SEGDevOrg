/**********************************************************
    Class Name      :SEGTS_Print_TestSpec_Back_CTRL
	Test Class		:SEGTS_Print_TestSpec_Back_Test
    Purpose         :Print Test Spec record Details
    Created By      :RBEI
    Created Date    :Dec 2018
***********************************************************/
public class SEGTS_Print_TestSpec_Back_CTRL {
    public Id cid {get;set;}
    public Test_Specification__c testSpec {get;set;}
    public Test_Specification__c newTstSpec{get;set;}
    public SEGTS_Print_TestSpec_Back_CTRL(ApexPages.StandardController stdd){
        cid= Apexpages.currentPage().getParameters().get('ID');
        testSpec = new Test_Specification__c();
        newTstSpec=new Test_Specification__c();
        testSpec = [Select id,Name,Test_Spec_Type__c,Test_Specification__c,Designation__c,Condition__c,Additional_Features__c,Status__c,Stand__c,Starter_Type__c,Version_No__c,
                                     FLC__c,NB__c,Information__c,Change__c,Change_Nr__c, Char_Curve_1__c,Char_Curve_2__c,
                                     Temp_1_C__c,Temp_2_C__c,Solenoid__c,Remarks__c,Relation_amount__c,SAP_Doc__c,CreatedById,LastModifiedById,
                                     Invalidated_By__c,i__c,Starter__c,Generated_By__c,OwnerId from Test_Specification__c Where ID =: cid];
                System.debug('TEst:::'+testSpec.Status__c);
        }
    /* Cancel is used for redirect to record detail page */
    public PageReference Back(){
        PageReference pg = new PageReference('/'+cid);
        pg.setRedirect(true);
        return pg;
    }
}