/**************************************************************************************************************************
    Class Name      :SEGTS_EditTestDetailsCtrl 
    Test Class      :SEGTS_EditTestDetailsCtrl_Test
    Purpose         :This class controls the edition of existing Test Details on click of "Edit" Button
    Created By      :RBEI
    Created Date    :Feb 2019
**************************************************************************************************************************/
global class SEGTS_EditTestDetailsCtrl
{
    public List<Test_Specification__c> sectionList{get;set;}
    Public Id pid{get;set;}
    public String JSONData{get;set;}
    public Test_Specification__c testspec{get;set;}
    public List<WrapperSection> lstWrapperSection{get;set;} 
    public List<level2> lstAllWrapperBlock{get;set;}
    public List<SelectOption> designationOptionLst {get;set;}
    public List<SelectOption> sizeOptionLst {get;set;}
    public List<SelectOption> conditionOptionLst {get;set;}
    public List<SelectOption> unitOptionLst {get;set;}
    public List<SelectOption> interfaceOptionLst {get;set;} 
    public SEGTS_EditTestDetailsCtrl()
    {
        pid=apexpages.currentpage().getParameters().get('id');
        lstWrapperSection=new List<WrapperSection>();
        lstAllWrapperBlock=new List<level2>();
        testspec=new Test_Specification__c();
        //pid=Apexpages.currentpage().getparameters().get('id');
        sectionList=[Select id,Name,Order_No__c,(Select id,Name,Order_No__c from Test_Specifications__r order by Order_No__c asc) from Test_Specification__c where Parent_Test_Specification__c=:pid order by Order_No__c asc];
        set<Id> blockId=new Set<Id>();
        for(Test_Specification__c sec:sectionList)
        {
            WrapperSection ws=new WrapperSection();
            ws.l1Id=sec.id;
            ws.testSectionHeader=sec.Name;
            ws.sortOrder=Integer.valueOf(sec.Order_No__c);
            List<level2> blockwrap=new List<level2>();
            for(Test_Specification__c blk:sec.Test_Specifications__r)
                {
                    level2 wb=new level2();
                    wb.l2Id=blk.id;
                    wb.testBlockHeader=blk.Name;
                    wb.sortOrder=Integer.valueOf(blk.Order_No__c);
                    blockwrap.add(wb);
                    blockId.add(blk.id);
                    lstAllWrapperBlock.add(wb);
                }
                ws.level2=blockwrap;
                lstWrapperSection.add(ws);
                
        }  
        List<Test_Specification__c> results=[Select id,Name,Order_No__c,Designation__c,Size__c,Condition__c,
                                                 Value_Toleran__c,Unit__c,Interface__c,Remark__c,Parent_Test_Specification__c   from Test_Specification__c where Parent_Test_Specification__c in:blockId order by Order_No__c asc];
                                                 
                for(level2 t:lstAllWrapperBlock)
                {
                    List<level3> resultList=new List<level3>();
                    if(results!=null && results.size()>0)
                    {
                        for(Test_Specification__c re:results)
                        {
                            if(t.l2Id==re.Parent_Test_Specification__c)
                            {
                                level3 r=new level3();
                                if(re.Designation__c==null)
                                {
                                    r.designation='';
                                }
                                else
                                {
                                    r.designation=re.Designation__c;
                                }
                                if(re.Size__c==null)
                                {
                                    r.size='';
                                }
                                else
                                {    
                                    r.size=re.Size__c;
                                }
                                if(re.Condition__c==null)
                                {
                                    r.condition='';
                                }
                                else
                                {        
                                    r.condition=re.Condition__c;
                                }
                                if(re.Value_Toleran__c==null)
                                {
                                    r.volume='';
                                }
                                else
                                {            
                                    r.volume=re.Value_Toleran__c;
                                }
                                if(re.Unit__c==null)
                                {
                                    r.unit='';
                                }
                                else
                                {            
                                    r.unit=re.Unit__c;
                                }
                                if(re.Remark__c==null)
                                {
                                    r.remark='';
                                }
                                else
                                {            
                                    r.remark=re.Remark__c;
                                }
                                if(re.Interface__c==null)
                                {
                                    r.interfacec='';
                                }
                                else
                                {            
                                    r.interfacec=re.Interface__c;
                                }    
                                resultList.add(r);
                                t.level3=resultList;
                            }
                         }
                    }
                      
        } 
                         
                        
        
        JSONData=JSON.serialize(lstWrapperSection);
        JSONData='{"request":'+JSONData.replace('null','""')+'}';
        //JSONData='{"request":'+JSONData+'}';
        System.debug('JSON----'+JSONData);               
     }
     @RemoteAction
     global static string SaveTestDeatils(String request,String id) {
          JSONTestReqWrap  request1 = (JSONTestReqWrap)JSON.deserialize(request, JSONTestReqWrap.class);
          List<Test_Specification__c> delsecList=new List<Test_Specification__c>(); 
          List<Test_Specification__c> delblckList=new List<Test_Specification__c>();
          List<Test_Specification__c> delrowList=new List<Test_Specification__c>();
          set<Id> secId=new Set<Id>();
          set<Id> blckid=new Set<Id>();
          if(id!=null)
          {
            for(Test_Specification__c t:[Select id from Test_Specification__c where Parent_Test_Specification__c=:id]){
                secId.add(t.id);
                delsecList.add(t);
            }
         }
         delete delsecList;
         if(secId.size()!=null && secId.size()>0){
            for(Test_Specification__c t:[Select id from Test_Specification__c where Parent_Test_Specification__c in:secId]){
                delblckList.add(t);
                blckid.add(t.id);
            }
         }
         delete delblckList;
         if(blckid.size()!=null && blckid.size()>0){
            for(Test_Specification__c t:[Select id from Test_Specification__c where Parent_Test_Specification__c in:blckid]){
                delrowList.add(t);
            }
         }
          delete delrowList;
          Map<section,Test_Specification__c> sectionMap=new Map<section,Test_Specification__c>(); 
          List<Test_Specification__c> secList=new List<Test_Specification__c>();
          Integer secx=1;
          for(section sec:request1.request){   
                 Test_Specification__c secn=new Test_Specification__c();
                 secn.Parent_Test_Specification__c=id;
                 secn.Test_Section_Header__c=sec.testSectionHeader;
                 secn.name=sec.testSectionHeader;
                 secn.HierechyLevel__c='Level 1';
                 secn.Order_No__c=secx++;
                 secList.add(secn);
                 sectionMap.put(sec,secn);
                 System.debug('DatatoApex---'+sec);
             }
             insert secList;
             List<Test_Specification__c> blkList=new List<Test_Specification__c>();
             Integer blkx=1;
             Map<block,Test_Specification__c> blockMap=new Map<block,Test_Specification__c>(); 
              for(section  sec:sectionMap.keyset()){
                  if(sec.level2!=null)
                  {
                      for(block  blk:sec.level2){
                         if(blk.testBlockHeader!=null && blk.testBlockHeader!='')
                         {
                             Test_Specification__c blck=new Test_Specification__c();
                             Test_Specification__c se=sectionMap.get(sec);
                             blck.Parent_Test_Specification__c=se.id;
                             blck.HierechyLevel__c='Level 2';
                             blck.name=blk.testBlockHeader;
                             blck.Test_Block_Header__c=blk.testBlockHeader;
                             blck.Order_No__c=blkx++;
                             blkList.add(blck);
                             blockMap.put(blk,blck);
                          }
                     }         
                      blkx=1;
                  }       
             }
             insert blkList;
             List<Test_Specification__c> rsltList=new List<Test_Specification__c>();
             Integer rsltsx=1;        
             for(block blk:blockMap.keyset()){
                 if(blk.level3!=null)
                 {
                     for(result rslt:blk.level3){
                         if(!String.isempty(rslt.designation))
                         {
                             Test_Specification__c rlt=new Test_Specification__c();
                             Test_Specification__c se=blockMap.get(blk);
                             rlt.Parent_Test_Specification__c=se.id;
                             rlt.HierechyLevel__c='Level 3';
                             rlt.name=rslt.designation;
                             rlt.Designation__c=rslt.designation;
                             rlt.Order_No__c=rsltsx++;
                             rlt.Interface__c=rslt.interfacec;
                             rlt.Remark__c=rslt.remark;
                             rlt.Size__c=rslt.size;
                             rlt.Value_Toleran__c=rslt.volume;
                             rlt.Unit__c=rslt.unit;
                             rlt.Condition__c=rslt.condition;
                             rsltList.add(rlt);
                          }   
                      }    
                      rsltsx=1;
                  }      
              }
              insert rsltList;
              for(Test_Specification__c trslts:rsltList)
               {
                Test_Specification__c  prnt=new Test_Specification__c();
                prnt.id=id;
                if(trslts.Interface__c=='Auslaufzeit')
                {
                    
                        prnt.Auslaufzeit__c=trslts.Value_Toleran__c;
                        
                }
                if(trslts.Interface__c=='Belast')
                {
                    
                        prnt.Belast__c=trslts.Value_Toleran__c;
                        
                }
                if(trslts.Interface__c=='Beschl')
                {
                    
                        prnt.Beschl__c=trslts.Value_Toleran__c;
                        
                }
                if(trslts.Interface__c=='Dauer1')
                {
                    
                        prnt.Dauer1__c=trslts.Value_Toleran__c;
                        
                }
                if(trslts.Interface__c=='Dauer2')
                {
                    
                        prnt.Dauer2__c=trslts.Value_Toleran__c;
                        
                }
                if(trslts.Interface__c=='Dauer3')
                {
                   
                        prnt.Dauer3__c=trslts.Value_Toleran__c;
                        
                }
                if(trslts.Interface__c=='Drehzahl')
                {
                   
                        prnt.Drehzahl__c=trslts.Value_Toleran__c;
                        
                }
                if(trslts.Interface__c=='Feld12A')
                {
                    
                        prnt.Feld12A__c=trslts.Value_Toleran__c;
                        
                }
                if(trslts.Interface__c=='Feld12B')
                {
                   
                        prnt.Feld12B__c=trslts.Value_Toleran__c;
                        
                }
                if(trslts.Interface__c=='Feld12C')
                {
                    
                        prnt.Feld12C__c=trslts.Value_Toleran__c;
                        
                }
                if(trslts.Interface__c=='I1')
                {
                    
                        prnt.I1__c=trslts.Value_Toleran__c;
                        
                }
                if(trslts.Interface__c=='I1_min')
                {
                    
                        prnt.I1_min__c=trslts.Value_Toleran__c;
                        
                }
                if(trslts.Interface__c=='I2')
                {
                    
                        prnt.I2__c=trslts.Value_Toleran__c;
                        
                }
                if(trslts.Interface__c=='I2_min')
                {
                    
                        prnt.I2_min__c=trslts.Value_Toleran__c;
                        
                }
                if(trslts.Interface__c=='I3')
                {
                   
                        prnt.I3__c=trslts.Value_Toleran__c;
                        
                }
                if(trslts.Interface__c=='Kenntemp')
                {
                    
                        prnt.Kenntemp__c=trslts.Value_Toleran__c;
                        
                }
                if(trslts.Interface__c=='Leerlauf')
                {
                    
                        prnt.Leerlauf__c=trslts.Value_Toleran__c;
                        
                }
                if(trslts.Interface__c=='M1')
                {
                   
                        prnt.M1__c=trslts.Value_Toleran__c;
                        
                }
                if(trslts.Interface__c=='M2')
                {
                    
                        prnt.M2__c=trslts.Value_Toleran__c;
                        
                }
                if(trslts.Interface__c=='M3')
                {
                    
                        prnt.M3__c=trslts.Value_Toleran__c;
                        
                }
                if(trslts.Interface__c=='Memo16a')
                {
                    
                        prnt.Memo16a__c=trslts.Value_Toleran__c;
                        
                }
                if(trslts.Interface__c=='Memo16b')
                {
                    
                        prnt.Memo16b__c=trslts.Value_Toleran__c;
                        
                }
                if(trslts.Interface__c=='Memo16c')
                {
                   
                        prnt.Memo16c__c=trslts.Value_Toleran__c;
                        
                }
                if(trslts.Interface__c=='Memo17a')
                {
                    
                        prnt.Memo17a__c=trslts.Value_Toleran__c;
                        
                }
                if(trslts.Interface__c=='Memo17b')
                {
                    
                        prnt.Memo17b__c=trslts.Value_Toleran__c;
                        
                }
                if(trslts.Interface__c=='Memo17c')
                {
                    
                        prnt.Memo17c__c=trslts.Value_Toleran__c;
                        
                }
                if(trslts.Interface__c=='Memo17d')
                {
                   
                        prnt.Memo17d__c=trslts.Value_Toleran__c;
                        
                }
                if(trslts.Interface__c=='Messspannung')
                {
                    
                        prnt.Messspannung__c=trslts.Value_Toleran__c;
                        
                }
                if(trslts.Interface__c=='Messzeit10')
                {
                   
                        prnt.Messzeit10__c=trslts.Value_Toleran__c;
                        
                }
                if(trslts.Interface__c=='Messzeit11')
                {
                   
                        prnt.Messzeit11__c=trslts.Value_Toleran__c;
                        
                }
                if(trslts.Interface__c=='Messzeit13')
                {
                    
                        prnt.Messzeit13__c=trslts.Value_Toleran__c;
                        
                }
                if(trslts.Interface__c=='Messzeit5')
                {
                    
                        prnt.Messzeit5__c=trslts.Value_Toleran__c;
                        
                }
                if(trslts.Interface__c=='Messzeit6')
                {
                    
                        prnt.Messzeit6__c=trslts.Value_Toleran__c;
                        
                }
                if(trslts.Interface__c=='Messzeit7')
                {
                    
                        prnt.Messzeit7__c=trslts.Value_Toleran__c;
                        
                }
                if(trslts.Interface__c=='n1')
                {
                    
                        prnt.n1__c=trslts.Value_Toleran__c;
                        
                }
                if(trslts.Interface__c=='n1_max')
                {
                    
                        prnt.n1_max__c=trslts.Value_Toleran__c;
                       
                }
                if(trslts.Interface__c=='n2')
                {
                    
                        prnt.n2__c=trslts.Value_Toleran__c;
                        
                }
                if(trslts.Interface__c=='n2_max')
                {
                    
                        prnt.n2_max__c=trslts.Value_Toleran__c;
                        
                }
                if(trslts.Interface__c=='n3')
                {
                    
                        prnt.n3__c=trslts.Value_Toleran__c;
                        
                }
                if(trslts.Interface__c=='n3_max')
                {
                    
                        prnt.n3_max__c=trslts.Value_Toleran__c;
                        
                }
                if(trslts.Interface__c=='nl')
                {
                    
                        prnt.nl__c=trslts.Value_Toleran__c;
                        
                }
                if(trslts.Interface__c=='P14a')
                {
                    
                        prnt.P14a__c=trslts.Value_Toleran__c;
                        
                }
                if(trslts.Interface__c=='P14b')
                {
                    
                        prnt.P14b__c=trslts.Value_Toleran__c;
                        
                }
                if(trslts.Interface__c=='P15a')
                {
                    
                        prnt.P15a__c=trslts.Value_Toleran__c;
                        
                }
                if(trslts.Interface__c=='P15b')
                {
                   
                        prnt.P15b__c=trslts.Value_Toleran__c;
                        
                }
                if(trslts.Interface__c=='P16a')
                {
                    
                        prnt.P16a__c=trslts.Value_Toleran__c;
                        
                }
                if(trslts.Interface__c=='P16b')
                {
                    
                        prnt.P16b__c=trslts.Value_Toleran__c;
                        
                }
                if(trslts.Interface__c=='pruefnr')
                {
                   
                        prnt.pruefnr__c=trslts.Value_Toleran__c;
                        
                }
                if(trslts.Interface__c=='Strom')
                {
                    
                        prnt.Strom__c=trslts.Value_Toleran__c;
                        
                }
                if(trslts.Interface__c=='Textfeld16')
                {
                    
                        prnt.Textfeld16__c=trslts.Value_Toleran__c;
                        
                }
                if(trslts.Interface__c=='U1')
                {
                    
                        prnt.U1__c=trslts.Value_Toleran__c;
                        
                }
                if(trslts.Interface__c=='U10')
                {
                    
                        prnt.U10__c=trslts.Value_Toleran__c;
                       
                }
                if(trslts.Interface__c=='U11')
                {
                    
                        prnt.U11__c=trslts.Value_Toleran__c;
                        
                }
                if(trslts.Interface__c=='U2')
                {
                    
                        prnt.U2__c=trslts.Value_Toleran__c;
                        
                }
                if(trslts.Interface__c=='U3')
                {
                    
                        prnt.U3__c=trslts.Value_Toleran__c;
                        
                }
                if(trslts.Interface__c=='U5')
                {
                    
                        prnt.U5__c=trslts.Value_Toleran__c;
                        
                }
                if(trslts.Interface__c=='U5M')
                {
                    
                        prnt.U5M__c=trslts.Value_Toleran__c;
                       
                }
                if(trslts.Interface__c=='U6')
                {
                    
                        prnt.U6__c=trslts.Value_Toleran__c;
                        
                }
                if(trslts.Interface__c=='U6M')
                {
                    
                        prnt.U6M__c=trslts.Value_Toleran__c;
                        
                }
                if(trslts.Interface__c=='U7')
                {
                    
                        prnt.U7__c=trslts.Value_Toleran__c;
                        
                }
                if(trslts.Interface__c=='U7M')
                {
                       prnt.U7M__c=trslts.Value_Toleran__c;
                        
                }
                if(trslts.Interface__c=='Wert17a')
                {
                    
                        prnt.Wert17a__c=trslts.Value_Toleran__c;
                        
                }
                if(trslts.Interface__c=='Wert17b')
                {
                    
                        prnt.Wert17b__c=trslts.Value_Toleran__c;
                        
                }
                if(trslts.Interface__c=='I3_min')
                {
                    
                        prnt.I3_min__c=trslts.Value_Toleran__c;
                        
                }
                update prnt;
            }
              string res=id;
              return res;
         }     
      public List<SelectOption> getDesignationOptionList(){
        designationOptionLst = new List<SelectOption>();
        Schema.DescribeFieldResult rst5 = Test_Specification__c.Designation__c.getDescribe();
        List<Schema.PickListEntry> lst5 = rst5.getPickListValues();
        designationOptionLst .add(new SelectOption('',''));
        for(Schema.PickListEntry obj:lst5){
            designationOptionLst .add(new SelectOption(obj.getLabel(),obj.getValue()));
        }
        return designationOptionLst ;
    }
     public List<SelectOption> getSizeOptionList(){
        sizeOptionLst = new List<SelectOption>();
        Schema.DescribeFieldResult rst5 = Test_Specification__c.Size__c.getDescribe();
        List<Schema.PickListEntry> lst5 = rst5.getPickListValues();
        sizeOptionLst .add(new SelectOption('',''));
        for(Schema.PickListEntry obj:lst5){
            sizeOptionLst.add(new SelectOption(obj.getLabel(),obj.getValue()));
        }
        return sizeOptionLst;
    }
     public List<SelectOption> getConditionOptionList(){
        conditionOptionLst = new List<SelectOption>();
        Schema.DescribeFieldResult rst5 = Test_Specification__c.Condition__c.getDescribe();
        List<Schema.PickListEntry> lst5 = rst5.getPickListValues();
        conditionOptionLst .add(new SelectOption('',''));
        for(Schema.PickListEntry obj:lst5){
            conditionOptionLst .add(new SelectOption(obj.getLabel(),obj.getValue()));
        }
        return conditionOptionLst;
    }
    public List<SelectOption> getUnitOptionList(){
        unitOptionLst= new List<SelectOption>();
        Schema.DescribeFieldResult rst5 = Test_Specification__c.Unit__c.getDescribe();
        List<Schema.PickListEntry> lst5 = rst5.getPickListValues();
        unitOptionLst .add(new SelectOption('',''));
        for(Schema.PickListEntry obj:lst5){
            unitOptionLst.add(new SelectOption(obj.getLabel(),obj.getValue()));
        }
        return unitOptionLst;
    }
     public List<SelectOption> getInterfaceOptionList(){
        interfaceOptionLst = new List<SelectOption>();
        Schema.DescribeFieldResult rst5 = Test_Specification__c.Interface__c.getDescribe();
        List<Schema.PickListEntry> lst5 = rst5.getPickListValues();
        interfaceOptionLst .add(new SelectOption('',''));
        for(Schema.PickListEntry obj:lst5){
            interfaceOptionLst .add(new SelectOption(obj.getLabel(),obj.getValue()));
        }
        return interfaceOptionLst ;
    }
          public class WrapperSection
     {
         public Id l1Id{get;set;}
         public String testSectionHeader{get;set;}
         public Integer sortOrder{get;set;}
         public List<level2> level2{get;set;}
         public WrapperSection()
         {
         }
     }
     public class level2
     {
         public Id l2Id{get;set;}
         public String testBlockHeader{get;set;}
         public Integer sortOrder{get;set;}
         public List<level3> level3{get;set;}
         public level2()
         {
         }
     }
     public class level3
     {
         public String designation{get;set;}
         public String size{get;set;}
         public String condition{get;set;}
         public String volume{get;set;}
         public String unit{get;set;}
         public String remark{get;set;}
         public String interfacec{get;set;}
         public level3()
         {
         }
    } 
     global class JSONTestReqWrap {
        public List<section> request;       
    }
    global class section {
        public String testSectionHeader;
        public String sortOrder;
        public List<block> level2;
        
    }
    global class block {
        public String testBlockHeader;
        public String sortOrder;
        public List<result> level3;
    }
    global class result {
        public String designation;
        public String size;
        public String condition;
        public String volume;
        public String unit;
        public String remark;
        public String interfacec;
        public String sortOrder;
    }        
}