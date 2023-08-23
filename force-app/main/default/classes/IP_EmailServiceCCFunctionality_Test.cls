/*******************************************************************************************************
* 
* @ Name    :   IP_EmailServiceCCFunctionality_Test
* @ Purpose :   Test Class for IP_EmailServiceCCFunctionality
* @ Author  :   madhuravani.b@absyz.com
*
*   Date            |  Developer Name               |  Version      |  Changes
* ===================================================================================================================
*   06-04-2021      |  madhuravani.b@absyz.com      |  1.0          |  Initial Version
*********************************************************************************************************************/
@isTest
public class IP_EmailServiceCCFunctionality_Test {
    static testMethod void sendEmail() {
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        
        IP_EmailServiceCCFunctionality objEmail = new IP_EmailServiceCCFunctionality();
        
        //Creating Case
        case cs=new case();
        cs.Subject='P00-001';
        cs.IP_Product_Type__c='PC Starter';
        cs.IP_Invention_Created_as_Part_of_Work__c='Yes';
        cs.IP_Who_Initiated_the_Subject__c='Test';
        cs.IP_Reason_for_Working_on_That_Subject__c='Test';
        cs.IP_Is_there_Contribution_of_the_Company__c  ='Yes';
        cs.IP_Special_Points_to_be_Considered__c='Yes';
        cs.IP_Explanation_of_Special_Points__c='Test';
        cs.IP_Inventors__c='raviteja.vaddi@gmail.com(50%)';
        cs.IP_Fill_Form_or_Upload_IDF__c='I have summarized my invention in a document and would like to upload it below';
        cs.IP_Prior_Art__c='';
        cs.IP_Problem_Solved__c='';
        cs.IP_Invention_Description__c='';
        cs.IP_Use_of_Invention_by_Us__c='';
        cs.Status=  'Draft';
        cs.IP_Product_Subcategories__c='Armature';
        cs.IP_Invention_Part_of_Entrusted_Research__c='Yes';
        cs.IP_Right_ID__c = 'P00-001';
        insert cs;
        
        //Creating ContentVersion
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Penguins',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion;    
        
        //Creating ContentDocument
       /* List<ContentDocument> documents = [
            SELECT Id, Title, LatestPublishedVersionId 
            FROM ContentDocument
        ];*/
        
        ContentVersion fetchFirstVersion = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: contentVersion.Id];
        ContentDocumentLink firstDocLink = new ContentDocumentLink();
        firstDocLink.ContentDocumentId = fetchFirstVersion.ContentDocumentId;
        firstDocLink.LinkedEntityId = cs.Id;
        firstDocLink.ShareType = 'V';
        insert firstDocLink;
        
        List<String> lst_toAddresses = new List<String>{'toaddress@email.com'};
        email.subject = 'Invention //P00-001';
        email.toAddresses = lst_toAddresses;
        email.fromAddress = 'fromaddress@email.com';
        email.plainTextBody = 'email body';
        Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
        attachment.body = blob.valueOf('my attachment text');
        attachment.fileName = 'textfileone.txt';
        attachment.mimeTypeSubType = 'text/plain';
        email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment };
            
        // add an Text atatchment
        Messaging.InboundEmail.TextAttachment attachmenttext = new Messaging.InboundEmail.TextAttachment();
        attachmenttext.body = 'my attachment text';
        attachmenttext.fileName = 'textfiletwo3.txt';
        attachmenttext.mimeTypeSubType = 'texttwo/plain';
        email.textAttachments =   new Messaging.inboundEmail.TextAttachment[] { attachmenttext };
            
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        objEmail.handleInboundEmail(email, env);
    }
}