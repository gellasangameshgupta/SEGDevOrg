/**************************************************************************************************************************
    Class Name      :SEGTS_CreateTestDetailsCtrl 
    Test Class      :SEGTS_CreateTestDetailsCtrl_Test
    Purpose         :This class controls the creation of New Test Details on click of "Create" Button
    Created By      :RBEI
    Created Date    :Feb 2019
**************************************************************************************************************************/
global class SEGTS_CreateTestDetailsCtrl{
     
    public Test_Specification__c testspec{get;set;}
    public List<SelectOption> designationOptionLst {get;set;}
    public List<SelectOption> sizeOptionLst {get;set;}
    public List<SelectOption> conditionOptionLst {get;set;}
    public List<SelectOption> unitOptionLst {get;set;}
    public List<SelectOption> interfaceOptionLst {get;set;}
    public Id pid{get;set;}
    public SEGTS_CreateTestDetailsCtrl(){
         testspec=new Test_Specification__c();
         pid=apexpages.currentpage().getParameters().get('id');
         
        //System.debug('JSonData--'+JSonData());
    }
    
    @RemoteAction
    global static string SaveTestDeatils(String request,String id) {
         System.debug('vf data----'+request);
        JSONTestReqWrap  request1 = (JSONTestReqWrap)JSON.deserialize(request, JSONTestReqWrap.class);
         System.debug('json wrapper----'+request1);
         //System.debug('pid---'+pid);
         Map<Level1,Test_Specification__c> sectionMap=new Map<Level1,Test_Specification__c>(); 
         List<Test_Specification__c> secList=new List<Test_Specification__c>();
         Integer secx=1;
         for(Level1 sec:request1.request){   
             Test_Specification__c section=new Test_Specification__c();
             section.Parent_Test_Specification__c=id;
             section.Test_Section_Header__c=sec.testSectionHeader;
             section.name=sec.testSectionHeader;
             section.HierechyLevel__c='Level 1';
             section.Order_No__c=secx++;
             secList.add(section);
             sectionMap.put(sec,section);
             System.debug('DatatoApex---'+sec);
         }
         insert secList;
         List<Test_Specification__c> blkList=new List<Test_Specification__c>();
         Integer blkx=1;
         Map<Level2,Test_Specification__c> blockMap=new Map<Level2,Test_Specification__c>(); 
            for(Level1 sec:sectionMap.keyset()){
            if(sec.level2!=null){
              for(Level2 blk:sec.level2){
                  if(blk.testBlockHeader!=null && blk.testBlockHeader!=''){
                     Test_Specification__c block=new Test_Specification__c();
                     Test_Specification__c se=sectionMap.get(sec);
                     block.Parent_Test_Specification__c=se.id;
                     block.HierechyLevel__c='Level 2';
                     block.name=blk.testBlockHeader;
                     block.Test_Block_Header__c=blk.testBlockHeader;
                     block.Order_No__c=blkx++;
                     blkList.add(block);
                     blockMap.put(blk,block);
                 }    
              }    
              blkx=1;
            }     
         }
         insert blkList;
         List<Test_Specification__c> rsltList=new List<Test_Specification__c>();
         Integer rsltsx=1;        
         for(Level2 blk:blockMap.keyset()){
             if(blk.level3!=null){
                 for(Level3 rslt:blk.level3){
                     if(!String.isempty(rslt.designation)){
                         Test_Specification__c result=new Test_Specification__c();
                         Test_Specification__c se=blockMap.get(blk);
                         result.Parent_Test_Specification__c=se.id;
                         result.HierechyLevel__c='Level 3';
                         result.name=rslt.designation;
                         result.Designation__c=rslt.designation;
                         result.Order_No__c=rsltsx++;
                         result.Interface__c=rslt.interfacec;
                         result.Remark__c=rslt.remark;
                         result.Size__c=rslt.size;
                         result.Value_Toleran__c=rslt.volume;
                         result.Unit__c=rslt.unit;
                         result.Condition__c=rslt.condition;
                         rsltList.add(result);
                     }   
                  }    
                  rsltsx=1;
             }        
          }
          insert rsltList;
          for(Test_Specification__c trslts:rsltList){
              Test_Specification__c  prnt=new Test_Specification__c();
                prnt.id=id;
                if(trslts.Interface__c=='Auslaufzeit'){if(String.isEmpty(prnt.Auslaufzeit__c)){
                        prnt.Auslaufzeit__c=trslts.Value_Toleran__c;
                    }    
                }
                if(trslts.Interface__c=='Belast'){if(String.isEmpty(prnt.Belast__c)){
                        prnt.Belast__c=trslts.Value_Toleran__c;
                    }    
                }
                if(trslts.Interface__c=='Beschl'){if(String.isEmpty(prnt.Beschl__c)){
                        prnt.Beschl__c=trslts.Value_Toleran__c;
                    }    
                }
                if(trslts.Interface__c=='Dauer1'){if(String.isEmpty(prnt.Dauer1__c)){
                        prnt.Dauer1__c=trslts.Value_Toleran__c;
                    }    
                }
                if(trslts.Interface__c=='Dauer2'){if(String.isEmpty(prnt.Dauer2__c)){
                        prnt.Dauer2__c=trslts.Value_Toleran__c;
                    }    
                }
                if(trslts.Interface__c=='Dauer3'){if(String.isEmpty(prnt.Dauer3__c)){
                        prnt.Dauer3__c=trslts.Value_Toleran__c;
                    }    
                }
                if(trslts.Interface__c=='Drehzahl'){if(String.isEmpty(prnt.Drehzahl__c)){
                        prnt.Drehzahl__c=trslts.Value_Toleran__c;
                    }    
                }
                if(trslts.Interface__c=='Feld12A'){if(String.isEmpty(prnt.Feld12A__c)){
                        prnt.Feld12A__c=trslts.Value_Toleran__c;
                    }    
                }
               if(trslts.Interface__c=='Feld12B'){if(String.isEmpty(prnt.Feld12B__c)){
                        prnt.Feld12B__c=trslts.Value_Toleran__c;
                    }    
                }
                if(trslts.Interface__c=='Feld12C'){if(String.isEmpty(prnt.Feld12C__c)){
                        prnt.Feld12C__c=trslts.Value_Toleran__c;
                    }    
                }
                if(trslts.Interface__c=='I1'){if(String.isEmpty(prnt.I1__c)){
                        prnt.I1__c=trslts.Value_Toleran__c;
                    }    
                }
                if(trslts.Interface__c=='I1_min'){if(String.isEmpty(prnt.I1_min__c)){
                        prnt.I1_min__c=trslts.Value_Toleran__c;
                    }    
                }
                if(trslts.Interface__c=='I2'){if(String.isEmpty(prnt.I2__c)){
                        prnt.I2__c=trslts.Value_Toleran__c;
                    }    
                }
                if(trslts.Interface__c=='I2_min'){if(String.isEmpty(prnt.I2_min__c)){
                        prnt.I2_min__c=trslts.Value_Toleran__c;
                    }    
                }
                if(trslts.Interface__c=='I3'){if(String.isEmpty(prnt.I3__c)){
                        prnt.I3__c=trslts.Value_Toleran__c;
                    }    
                }
                if(trslts.Interface__c=='Kenntemp'){if(String.isEmpty(prnt.Kenntemp__c)){
                        prnt.Kenntemp__c=trslts.Value_Toleran__c;
                    }    
                }
                if(trslts.Interface__c=='Leerlauf'){if(String.isEmpty(prnt.Leerlauf__c)){
                        prnt.Leerlauf__c=trslts.Value_Toleran__c;
                    }    
                }
                if(trslts.Interface__c=='M1'){if(String.isEmpty(prnt.M1__c)){
                        prnt.M1__c=trslts.Value_Toleran__c;
                    }    
                }
                if(trslts.Interface__c=='M2'){if(String.isEmpty(prnt.M2__c)){
                        prnt.M2__c=trslts.Value_Toleran__c;
                    }    
                }
                if(trslts.Interface__c=='M3'){if(String.isEmpty(prnt.M3__c)){
                        prnt.M3__c=trslts.Value_Toleran__c;
                    }    
                }
                if(trslts.Interface__c=='Memo16a'){if(String.isEmpty(prnt.Memo16a__c)){
                        prnt.Memo16a__c=trslts.Value_Toleran__c;
                    }    
                }
                if(trslts.Interface__c=='Memo16b'){if(String.isEmpty(prnt.Memo16b__c)){
                        prnt.Memo16b__c=trslts.Value_Toleran__c;
                    }    
                }
                if(trslts.Interface__c=='Memo16c'){if(String.isEmpty(prnt.Memo16c__c)){
                        prnt.Memo16c__c=trslts.Value_Toleran__c;
                    }    
                }
                if(trslts.Interface__c=='Memo17a'){if(String.isEmpty(prnt.Memo17a__c)){
                        prnt.Memo17a__c=trslts.Value_Toleran__c;
                    }    
                }
                if(trslts.Interface__c=='Memo17b'){if(String.isEmpty(prnt.Memo17b__c)){
                        prnt.Memo17b__c=trslts.Value_Toleran__c;
                    }    
                }
                if(trslts.Interface__c=='Memo17c'){if(String.isEmpty(prnt.Memo17c__c)){
                        prnt.Memo17c__c=trslts.Value_Toleran__c;
                    }    
                }
                if(trslts.Interface__c=='Memo17d'){if(String.isEmpty(prnt.Memo17d__c)){
                        prnt.Memo17d__c=trslts.Value_Toleran__c;
                    }    
                }
                if(trslts.Interface__c=='Messspannung'){if(String.isEmpty(prnt.Messspannung__c)){
                        prnt.Messspannung__c=trslts.Value_Toleran__c;
                    }    
                }
                if(trslts.Interface__c=='Messzeit10'){if(String.isEmpty(prnt.Messzeit10__c)){
                        prnt.Messzeit10__c=trslts.Value_Toleran__c;
                    }    
                }
                if(trslts.Interface__c=='Messzeit11'){if(String.isEmpty(prnt.Messzeit11__c)){
                        prnt.Messzeit11__c=trslts.Value_Toleran__c;
                    }    
                }
                if(trslts.Interface__c=='Messzeit13'){if(String.isEmpty(prnt.Messzeit13__c)){
                        prnt.Messzeit13__c=trslts.Value_Toleran__c;
                    }    
                }
                if(trslts.Interface__c=='Messzeit5'){if(String.isEmpty(prnt.Messzeit5__c)){
                        prnt.Messzeit5__c=trslts.Value_Toleran__c;
                    }    
                }
                if(trslts.Interface__c=='Messzeit6'){if(String.isEmpty(prnt.Messzeit6__c)){
                        prnt.Messzeit6__c=trslts.Value_Toleran__c;
                    }    
                }
                if(trslts.Interface__c=='Messzeit7'){if(String.isEmpty(prnt.Messzeit7__c)){
                        prnt.Messzeit7__c=trslts.Value_Toleran__c;
                    }    
                }
                if(trslts.Interface__c=='n1'){if(String.isEmpty(prnt.n1__c)){
                        prnt.n1__c=trslts.Value_Toleran__c;
                    }    
                }
                if(trslts.Interface__c=='n1_max'){if(String.isEmpty(prnt.n1_max__c)){
                        prnt.n1_max__c=trslts.Value_Toleran__c;
                    }    
                }
                if(trslts.Interface__c=='n2'){if(String.isEmpty(prnt.n2__c)){
                        prnt.n2__c=trslts.Value_Toleran__c;
                    }    
                }
                if(trslts.Interface__c=='n2_max'){if(String.isEmpty(prnt.n2_max__c)){
                        prnt.n2_max__c=trslts.Value_Toleran__c;
                    }    
                }
                if(trslts.Interface__c=='n3'){if(String.isEmpty(prnt.n3__c)){
                        prnt.n3__c=trslts.Value_Toleran__c;
                    }    
                }
                if(trslts.Interface__c=='n3_max'){if(String.isEmpty(prnt.n3_max__c)){
                        prnt.n3_max__c=trslts.Value_Toleran__c;
                    }    
                }
                if(trslts.Interface__c=='nl'){if(String.isEmpty(prnt.nl__c)){
                        prnt.nl__c=trslts.Value_Toleran__c;
                    }    
                }
                if(trslts.Interface__c=='P14a'){if(String.isEmpty(prnt.P14a__c)){
                        prnt.P14a__c=trslts.Value_Toleran__c;
                    }    
                }
                if(trslts.Interface__c=='P14b'){if(String.isEmpty(prnt.P14b__c)){
                        prnt.P14b__c=trslts.Value_Toleran__c;
                    }    
                }
                if(trslts.Interface__c=='P15a'){if(String.isEmpty(prnt.P15a__c)){
                        prnt.P15a__c=trslts.Value_Toleran__c;
                    }    
                }
                if(trslts.Interface__c=='P15b'){if(String.isEmpty(prnt.P15b__c)){
                        prnt.P15b__c=trslts.Value_Toleran__c;
                    }    
                }
                if(trslts.Interface__c=='P16a'){if(String.isEmpty(prnt.P16a__c)){
                        prnt.P16a__c=trslts.Value_Toleran__c;
                    }    
                }
                if(trslts.Interface__c=='P16b'){if(String.isEmpty(prnt.P16b__c)){
                        prnt.P16b__c=trslts.Value_Toleran__c;
                    }    
                }
                if(trslts.Interface__c=='pruefnr'){if(String.isEmpty(prnt.pruefnr__c)){
                        prnt.pruefnr__c=trslts.Value_Toleran__c;
                    }    
                }
                if(trslts.Interface__c=='Strom'){if(String.isEmpty(prnt.Strom__c)){
                        prnt.Strom__c=trslts.Value_Toleran__c;
                    }    
                }
                if(trslts.Interface__c=='Textfeld16'){if(String.isEmpty(prnt.Textfeld16__c)){
                        prnt.Textfeld16__c=trslts.Value_Toleran__c;
                    }    
                }
                if(trslts.Interface__c=='U1'){if(String.isEmpty(prnt.U1__c)){
                        prnt.U1__c=trslts.Value_Toleran__c;
                    }    
                }
                if(trslts.Interface__c=='U10'){if(String.isEmpty(prnt.U10__c)){
                        prnt.U10__c=trslts.Value_Toleran__c;
                    }    
                }
                if(trslts.Interface__c=='U11'){if(String.isEmpty(prnt.U11__c)){
                        prnt.U11__c=trslts.Value_Toleran__c;
                    }    
                }
                if(trslts.Interface__c=='U2'){if(String.isEmpty(prnt.U2__c)){
                        prnt.U2__c=trslts.Value_Toleran__c;
                    }    
                }
                if(trslts.Interface__c=='U3'){if(String.isEmpty(prnt.U3__c)){prnt.U3__c=trslts.Value_Toleran__c;
                    }    
                }
                if(trslts.Interface__c=='U5'){if(String.isEmpty(prnt.U5__c)){prnt.U5__c=trslts.Value_Toleran__c;
                    }    
                }
                if(trslts.Interface__c=='U5M'){if(String.isEmpty(prnt.U5M__c)){prnt.U5M__c=trslts.Value_Toleran__c;
                    }    
                }
                if(trslts.Interface__c=='U6'){if(String.isEmpty(prnt.U6__c)){
                        prnt.U6__c=trslts.Value_Toleran__c;
                    }    
                }
                if(trslts.Interface__c=='U6M'){if(String.isEmpty(prnt.U6M__c)){prnt.U6M__c=trslts.Value_Toleran__c;
                    }    
                }
                if(trslts.Interface__c=='U7'){if(String.isEmpty(prnt.U7__c)){prnt.U7__c=trslts.Value_Toleran__c;
                    }    
                }
                if(trslts.Interface__c=='U7M'){if(String.isEmpty(prnt.U7M__c)){prnt.U7M__c=trslts.Value_Toleran__c;
                    }    
                }
                if(trslts.Interface__c=='Wert17a'){if(String.isEmpty(prnt.Wert17a__c)){prnt.Wert17a__c=trslts.Value_Toleran__c;
                    }    
                }
                if(trslts.Interface__c=='Wert17b'){ if(String.isEmpty(prnt.Wert17b__c)){prnt.Wert17b__c=trslts.Value_Toleran__c;
                    }    
                }
                if(trslts.Interface__c=='I3_min'){if(String.isEmpty(prnt.I3_min__c)){prnt.I3_min__c=trslts.Value_Toleran__c;
                    }    
                }
                update prnt;
          }
          String res=id;
          System.debug('res---'+res);
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
     
    global class JSONTestReqWrap {
        public List<Level1> request;       
    }
    global class Level1 {
        public String testSectionHeader;
        public String sortOrder;
        public List<Level2> level2;
        
    }
    global class Level2 {
        public String testBlockHeader;
        public String sortOrder;
        public List<Level3> level3;
    }
    global class Level3 {
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