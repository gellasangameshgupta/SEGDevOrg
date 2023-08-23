/************************************************************************************************
    Class Name      :SEGTS_ListView_MetaData_CTRL
    Test Class      :SEGTS_ListView_Metadata_Test
    Purpose         :Fetch the data of the List view with search filter criteria
    Created By      :RBEI
    Created Date    :Dec 2018
*************************************************************************************************/
public class SEGTS_ListView_MetaData_CTRL {
    public List<String> filters{get;set;}
    public Listview l{get;set;}
    public User u{get;set;}
    public SEGTS_ListView_MetaData_CTRL(ApexPages.StandardSetController std) {
        filters=new List<String>();
        u=[Select Name from User where id=:userInfo.getUserId()];
        l=[SELECT Id,Name FROM ListView WHERE SobjectType = 'Test_Specification__c' and Name = 'Search Test Specification'];
        //String qry = 'select name,Test_Spec_Type__c,NB_PDF__c,FLS_PDF__c,Version_No__c,Solenoid__c,Starter_Type__c,i__c,NB__c,FLC__c,Additional_Features__c,Information__c,SAP_Doc__c,Stand__c,Condition__c,Designation__c,createddate from Test_Specification__c where Parent_Test_Specification__c=null';
       // List<Test_Specification__c> listSpec=database.getQueryLocator(qry);
        setCon.setFilterId(l.id); 
        //setCon = new ApexPages.StandardSetController(Database.getQueryLocator(qry)); 
        System.debug('setcon---'+setcon);
        //System.debug('List----'+listTestSpec.size());
        //setCon.setFilterId(l.id); 
        HttpRequest req = new HttpRequest();
        String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
        String endPoinURL = baseUrl+'/services/data/v32.0/sobjects/Test_Specification__c/listviews/'+l.id+'/describe';
        req.setEndpoint(endPoinURL);
        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
        Http http = new Http();
        if(!test.isRunningTest()){HTTPResponse response = http.send(req);
            Map<String, Object> tokenResponse = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            String query = (String)tokenResponse.get('query');
            String filter1=query.substringafter('WHERE').substringbefore('ORDER');
            for(String s:filter1.split('AND')){
                filters.add(s.remove('__c').replaceAll('_',' '));    
            }
        }
    }
     public  ApexPages.StandardSetController setCon
     {
         get {
                 
                 //String qry = 'select name,Test_Spec_Type__c,NB_PDF__c,FLS_PDF__c,Version_No__c,Solenoid__c,Starter_Type__c,i__c,NB__c,FLC__c,Additional_Features__c,Information__c,SAP_Doc__c,Stand__c,Condition__c,Designation__c,createddate from Test_Specification__c where Parent_Test_Specification__c=null';
                 setCon = new ApexPages.StandardSetController(Database.getQueryLocator([select name,Test_Spec_Type__c,NB_PDF__c,FLS_PDF__c,Version_No__c,Solenoid__c,Starter_Type__c,i__c,NB__c,FLC__c,Additional_Features__c,Information__c,SAP_Doc__c,Stand__c,Condition__c,Designation__c,createddate from Test_Specification__c where Parent_Test_Specification__c=:null order by createddate desc])); 
                 setCon.setPageSize(1000);
             return setCon;
           }
           set;
      }           
                
     @TestVisible public List<Test_Specification__c> getlistTestSpec(){ return (List<Test_Specification__c>)setCon.getRecords(); 
         
    }
    /*@TestVisible public List<Test_Specification__c> listTestSpec{ get{return (List<Test_Specification__c>)setCon.getRecords();} 
         
    }*/
    @TestVisible public Date Today{ get{ return Date.today(); 
        }
    } 
}