@isTest
public class IP_InventionImageUploadCtrlTest {
    @isTest
    public static  void createRecord(){
        case cs=new case();
        cs.Subject='test subject';
        cs.IP_Product_Type__c='PC Starter';
        cs.IP_Invention_Created_as_Part_of_Work__c='Yes';
        cs.IP_Who_Initiated_the_Subject__c='Test';
        cs.IP_Reason_for_Working_on_That_Subject__c='Test';
        cs.IP_Is_there_Contribution_of_the_Company__c  ='Yes';
        cs.IP_Special_Points_to_be_Considered__c='Yes';
        cs.IP_Explanation_of_Special_Points__c='Test';
        cs.IP_Inventors__c='raviteja.vaddi@gmail.com(100%)';
        cs.IP_Fill_Form_or_Upload_IDF__c='I have summarized my invention in a document and would like to upload it below';
        cs.IP_Prior_Art__c='';
        cs.IP_Problem_Solved__c='';
        cs.IP_Invention_Description__c='';
        cs.IP_Use_of_Invention_by_Us__c='';
        cs.Status=  'Approved for Filing';
        cs.IP_Status__c = 'Approved for Filing';
        cs.IP_Product_Subcategories__c='Armature';
        cs.IP_Invention_Part_of_Entrusted_Research__c='Yes';
        
        User cd = [SELECT Id, name FROM User WHERE IP_InsightIP_Role__c = 'IP Manager' limit 1];
        cs.IP_Manager__c = cd.Id;
        User vd = [SELECT Id, name FROM User WHERE IP_InsightIP_Role__c = 'PRC Member' limit 1];
        cs.IP_PRC_Member__c = vd.Id;
        
        test.startTest();
        insert cs;
        
        Apexpages.StandardController sc = new Apexpages.StandardController(cs);
        IP_InventionImageUploadCtrl txt= new IP_InventionImageUploadCtrl(sc);
        String getString= IP_InventionImageUploadCtrl.getContents(cs.Id);
        IP_InventionImageUploadCtrl.imageURL=getString;
        List<Id>returnId = txt.photos;
        Integer returnInteger= txt.totalPhotos;
        test.stopTest();
    }
}