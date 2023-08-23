/**************************************************************************************************************************
    Class Name      :SEGTS_ctrl_TestDeatilsViewLc 
    Test Class      :SEGTS_ctrl_TestDeatilsViewLc_Test
    Purpose         :Showing TestDetails data in Test Details tab with conditionally rendering "Create" and "Edit" button
    Created By      :RBEI
    Created Date    :Feb 2019
**************************************************************************************************************************/
public class SEGTS_ctrl_TestDeatilsViewLc {
    @AuraEnabled
    public static String gettestSpec(Id pageId)
    {
        	Test_Specification__c t=new Test_Specification__c();
            String x;
        	if(pageId!=null)
            {
                t=[Select SEGTS_permissionsetChecking__c from Test_Specification__c where id=:pageId];
                x=t.SEGTS_permissionsetChecking__c;
                
            }
        System.debug('x---'+x);
        return x;
    }
   /* @AuraEnabled 
    public static List<PermissionSetAssignment> fetchUser(){
     // query current user information 
     System.debug('USer---'+userInfo.getUserId()); 
      List<PermissionSetAssignment> pa = [select PermissionSetId from PermissionSetAssignment Where AssigneeId =: userInfo.getUserId()]; 
        System.debug('permission---'+pa);          
        return pa;
    }*/
    @AuraEnabled
    public static List<WrapperSection> getData(Id pageId)
    {
        List<Test_Specification__c> sectionList;
        List<WrapperSection> lstWrapperSection=new List<WrapperSection>();
        List<WrapperBlock> lstAllWrapperBlock=new List<WrapperBlock>();
    	sectionList=[Select id,Name,Order_No__c,(Select id,Name,Order_No__c from Test_Specifications__r order by Order_No__c asc) from Test_Specification__c where Parent_Test_Specification__c=:pageId order by Order_No__c asc];
        set<Id> blockId=new Set<Id>();
        System.debug('sectionList::::'+sectionList[0].Test_Specifications__r);
        for(Test_Specification__c sec:sectionList){
            WrapperSection ws=new WrapperSection();
            ws.l1Id=sec.id;
            ws.secname=sec.Name;
            ws.secorderno=Integer.valueOf(sec.Order_No__c);
            List<WrapperBlock> blockwrap=new List<WrapperBlock>();
            for(Test_Specification__c blk:sec.Test_Specifications__r){
                WrapperBlock wb=new WrapperBlock();
                wb.l2Id=blk.id;
                wb.blkname=blk.Name;
                wb.blkorderno=Integer.valueOf(blk.Order_No__c);
                blockwrap.add(wb);
                blockId.add(blk.id);
                lstAllWrapperBlock.add(wb);
            }
            ws.blockList=blockwrap;
            lstWrapperSection.add(ws);
        }  
        List<Test_Specification__c> results=[Select id,Name,Order_No__c,Designation__c,Size__c,Condition__c,
                                             Value_Toleran__c,Unit__c,Interface__c,Remark__c,Parent_Test_Specification__c   from Test_Specification__c where Parent_Test_Specification__c in:blockId order by Order_No__c asc];
        for(WrapperBlock t:lstAllWrapperBlock){
            List<Test_Specification__c> resultList=new List<Test_Specification__c>();
            for(Test_Specification__c re:results){
                if(t.l2Id==re.Parent_Test_Specification__c){
                    resultList.add(re);
                    t.resultListInner=resultList;
                }
             }
        }
         return lstWrapperSection;
    }
   


	 public class WrapperSection
     {
         @AuraEnabled public Id l1Id{get;set;}
         @AuraEnabled public String secname{get;set;}
         @AuraEnabled public Integer secorderno{get;set;}
         @AuraEnabled public List<WrapperBlock> blockList{get;set;}
         public WrapperSection()
         {
         }
     }
	  public class WrapperBlock
     {
         @AuraEnabled public Id l2Id{get;set;}
         @AuraEnabled public String blkname{get;set;}
         @AuraEnabled public Integer blkorderno{get;set;}
         @AuraEnabled public List<Test_Specification__c> resultListInner{get;set;}
         public WrapperBlock()
         {
         }
     }
}