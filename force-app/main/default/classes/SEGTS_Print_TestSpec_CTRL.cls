/**********************************************************
Class Name      :SEGTS_Print_TestSpec_CTRL
Test Class      :SEGTS_Print_TestSpec_Test
Purpose         :Print Test Spec record Details
Created By      :RBEI
Created Date    :Dec 2018
***********************************************************/
public class SEGTS_Print_TestSpec_CTRL {
    public Test_Specification__c testSpec {get;set;}
    public Test_Specification__c newTstSpec{get;set;}
    public List<Test_Specification__c> sectionList{get;set;}
    Public Id pid{get;set;}
    public String GeneratedBy{get;set;}
    public User u{get;set;}
    public String ApprovedBy{get;set;}
    public String InvalidatedBy{get;set;}
    public String StatusWithVersion{get;set;}
    public List<WrapperSection> lstWrapperSection{get;set;} 
    public List<WrapperBlock> lstAllWrapperBlock{get;set;} 
    
    public SEGTS_Print_TestSpec_CTRL(ApexPages.StandardController std){
        pid=Apexpages.currentPage().getParameters().get('ID');
        testSpec = new Test_Specification__c();
        newTstSpec=new Test_Specification__c();
        lstWrapperSection=new List<WrapperSection>();
        lstAllWrapperBlock=new List<WrapperBlock>();
        u=[Select Name from User where id=:UserInfo.getUserId()];
        GeneratedBy=u.Name;
        sectionList=[Select id,Name,Order_No__c,(Select id,Name,Order_No__c from Test_Specifications__r order by Order_No__c asc) from Test_Specification__c where Parent_Test_Specification__c=:pid order by Order_No__c asc];
        System.debug('sectionList ----'+sectionList );
        set<Id> blockId=new Set<Id>();
        for(Test_Specification__c sec:sectionList)
        {
            WrapperSection ws=new WrapperSection();
            ws.l1Id=sec.id;
            ws.secname=sec.Name;
            ws.secorderno=Integer.valueOf(sec.Order_No__c);
            List<WrapperBlock> blockwrap=new List<WrapperBlock>();
            for(Test_Specification__c blk:sec.Test_Specifications__r)
            {
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
        for(WrapperBlock t:lstAllWrapperBlock)
        {
            List<Test_Specification__c> resultList=new List<Test_Specification__c>();
            for(Test_Specification__c re:results)
            {
                if(t.l2Id==re.Parent_Test_Specification__c)
                {
                    resultList.add(re);
                    t.resultListInner=resultList;
                }
             }
        }                      
        testSpec = [Select id,Name,Test_Spec_Type__c,Test_Specification__c,Designation__c,Condition__c,Additional_Features__c,Status__c,Stand__c,Starter_Type__c,Version_No__c,
                    FLC__c,NB__c,Information__c,Change__c,Change_Nr__c,Char_Curve_1__c,Char_Curve_2__c,
                    Temp_1_C__c,Temp_2_C__c,Solenoid__c,Relation_amount__c,SAP_Doc__c,Remarks__c,CreatedById,LastModifiedById,
                    Invalidated_By__c,i__c,Starter__c,Generated_By__c,OwnerId,FLS_PDF__c,NB_PDF__c,Invalidate_On__c,
                    Approved_by__c,Approved_On__c,Generated_By_PDF__c,Generated_On_PDF__c from Test_Specification__c Where ID =: pid];
         System.debug('NL---'+testSpec.NB_PDF__c+''+'FLS---'+testSpec.FLS_PDF__c); 
         StatusWithVersion  = testSpec.Status__c+' '+ 'Version';
         if(testSpec.Approved_by__c!=null)
         {
             User approved=[Select Name from User where id=:testSpec.Approved_by__c];
             ApprovedBy=approved.Name;
         }
         if(testSpec.Invalidated_By__c!=null)
         {    
             User invalidate=[Select Name from User where id=:testSpec.Invalidated_By__c];
             InvalidatedBy=invalidate.Name; 
         }              
        System.debug('TEst:::'+testSpec.Status__c);
        
    }
    public class WrapperSection
     {
         public Id l1Id{get;set;}
         public String secname{get;set;}
         public Integer secorderno{get;set;}
         public List<WrapperBlock> blockList{get;set;}
         public WrapperSection()
         {
         }
     }
     public class WrapperBlock
     {
         public Id l2Id{get;set;}
         public String blkname{get;set;}
         public Integer blkorderno{get;set;}
         public List<Test_Specification__c> resultListInner{get;set;}
         public WrapperBlock()
         {
         }
     }
     public Date Today
     { get
         { 
             return Date.today(); 
         }
     }    
}