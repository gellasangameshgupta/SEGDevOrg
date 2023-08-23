/************************************************************************************************
    Class Name      :SEGTS_Release_Redirect_CTRL
    Test Class      :SEGTS_Release_Redirect_Test
    Purpose         :This class is used for create Approved record of existing test Specification
    Created By      :RBEI
    Created Date    :Dec 2018
*************************************************************************************************/
public class SEGTS_Release_Redirect_CTRL {
    public ID pid{get;set;} 
        public Test_Specification__c testSpec {get;set;}
        public Test_Specification__c newTstSpec{get;set;}
        public Boolean refreshPage {get; set;}
        public SEGTS_Release_Redirect_CTRL(ApexPages.StandardController d){
        pid= ApexPages.currentPage().getParameters().get('ID');
        testSpec = new Test_Specification__c();
        refreshPage =false;
        newTstSpec=new Test_Specification__c();
        testSpec = [Select id,Name,Test_Spec_Type__c,Test_Specification__c,Designation__c,Condition__c,Additional_Features__c,Status__c,Stand__c,Starter_Type__c,Version_No__c,
                                     FLC__c,NB__c,Information__c,Change__c,Change_Nr__c,Char_Curve_1__c,Char_Curve_2__c,
                                     Temp_1_C__c,Temp_2_C__c,Solenoid__c,Remarks__c,Relation_amount__c,SAP_Doc__c,CreatedById,LastModifiedById,
                                     Invalidated_By__c,i__c,Generated_By__c,Starter__c,OwnerId from Test_Specification__c Where ID =: pid];
                System.debug('TEst:::'+testSpec.Status__c);
        }
       public PageReference OK(){
       testSpec.Status__c ='Approved';
       testSpec.Approved_by__c=UserInfo.getUserId();
       testSpec.Approved_On__c=System.Today();
       refreshPage =true;
       update testSpec;
       List<Test_Specification__c> testspecList=new List<Test_Specification__c>();    
       List<Test_Specification__c> tlist=[Select id from Test_Specification__c where Name=:testSpec.Name and id!=:testSpec.id and Status__c=:'Approved'];
           if(!tlist.isempty()){for(Test_Specification__c test:tlist){
                   Test_Specification__c ts=new Test_Specification__c();
                   ts.id=test.id;
                   ts.Status__c='Invalid';
               		ts.Invalidated_By__c =UserInfo.getUSerId();
               		ts.Invalidate_On__c=System.Today();
                   testspecList.add(ts);
               }
               update testspecList;
           }
      PageReference pg = new PageReference('/'+pid);
       pg.SetRedirect(true);
       return pg;
       //return null;
      }
}