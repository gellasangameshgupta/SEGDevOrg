/*******************************************************************************************************
* 
* @ Name    :   IP_EmailServiceCCFunctionality
* @ Purpose :   Controller for Email Services for CC functionality
* @ Author  :   madhuravani.b@absyz.com
* @ Test Class Name : IP_EmailServiceCCFunctionality_Test
*
*   Date            |  Developer Name               |  Version      |  Changes
* ===================================================================================================================
*   06-04-2021      |  madhuravani.b@absyz.com      |  1.0          |  Initial Version
*********************************************************************************************************************/
global class IP_EmailServiceCCFunctionality implements Messaging.InboundEmailHandler {
    
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email,Messaging.InboundEnvelope envelope) {
        
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        system.debug('Subject::'+email.subject);
        if(email.subject.contains('//')){
            String[] InventionNumber = email.subject.split('//'); 
            system.debug('Subject Split::'+InventionNumber);
            system.debug('Subject::'+InventionNumber[0]);
            system.debug('Record Name::'+InventionNumber[1]);
            String recordName = InventionNumber[1];
            
            Case objInvention = new Case();
            Case emailMsg = new Case();
            //Check if the email is for IDF
            if(InventionNumber[1].contains('IDF')){
                objInvention =  [Select id from Case where IP_IDFNumber__c =: recordName];
                system.debug('Inside IDF Check::'+objInvention);
            }
            //Check if the email is for IP Right
            else if(InventionNumber[1].contains('P') && InventionNumber[1].contains('-')){
                objInvention =  [Select id from Case where IP_Right_ID__c =: recordName];
                system.debug('Inside IP Right Check::'+objInvention);
            }
            //Check if the email is for Patent Family
            else if(InventionNumber[1].contains('P') && !InventionNumber[1].contains('-')){
                objInvention =  [Select id from Case where IP_Patent_Family_ID__c =: recordName];
                system.debug('Inside Patent Family Check::'+objInvention);
            }
            system.debug('Record::'+objInvention);
            if(objInvention != null)
            {
                emailMsg.Subject = email.subject;
                emailMsg.IP_To__c = string.join(email.toAddresses,',');
                emailMsg.IP_From__c = email.fromAddress;
                if(email.ccAddresses != null)
                	emailMsg.IP_CC__c = string.join(email.ccAddresses,',');
                emailMsg.IP_Message_Body__c = email.htmlBody;
                emailMsg.IP_Parent_Record_Name__c = objInvention.Id;
                emailMsg.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Email Messages').getRecordTypeId();
                
                try {
                    insert emailMsg ;
                } catch(Exception e) {
                    IFv2_ExceptionUtilitiesController.exceptionHandler(e);
                }
                
                string strBody = 'To Address :'+email.toAddresses;
                strBody += '\n From Address : ' + email.fromAddress;
                strBody += '\n CC Address : '+ email.ccAddresses;
                strBody += '\n Subject : ' +email.subject;
                strBody += '\n Mail Body : '+ email.htmlBody;
                
                ContentVersion cv = new ContentVersion();
                cv.Title = InventionNumber[0];
                cv.PathOnClient = InventionNumber[0]+'.html';
                cv.VersionData = Blob.valueOf(strBody); //EncodingUtil.base64decode(strBody);
                cv.IsMajorVersion = true;
                cv.IP_FileFromEmail__c = true;
                cv.IP_IsEmailUpload__c = true;
                try {
                    Insert cv;
                } catch(Exception e) {
                    IFv2_ExceptionUtilitiesController.exceptionHandler(e);
                }
                
                //Get Content Documents
                Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
                
                //Create ContentDocumentLink 
                ContentDocumentLink cdl = New ContentDocumentLink();
                cdl.LinkedEntityId = emailMsg.Id;
                cdl.ContentDocumentId = conDocId;
                cdl.shareType = 'V';
                try {
                    Insert cdl;
                } catch(Exception e) {
                    IFv2_ExceptionUtilitiesController.exceptionHandler(e);
                }
            }
            List<ContentVersion>cvList = new List<ContentVersion>();
            List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
            List<Id> contentVerInsertList = new List<Id>();
            if(email.textAttachments != null){
                for (Messaging.Inboundemail.TextAttachment tAttachment : email.textAttachments){
                    ContentVersion cv = new ContentVersion();
                    cv.Title = tAttachment.fileName;
                    cv.PathOnClient = tAttachment.fileName;
                    cv.VersionData = Blob.valueOf(tAttachment.body);
                    cv.IsMajorVersion = true;
                    cv.IP_FileFromEmail__c = true;
                    cv.IP_IsEmailUpload__c = true;
                    cvList.add(cv);
                }
            }
            
            if(email.binaryAttachments != null){
                for (Messaging.Inboundemail.BinaryAttachment bAttachment : email.binaryAttachments){
                    ContentVersion cv = new ContentVersion();
                    String fileName = bAttachment.fileName;
                    List<String> fileNameLst = fileName.split('\\.');  /*used escape parameter for '.' delimiter */
                    cv.Title = fileNameLst[0];//bAttachment.fileName;
                    cv.PathOnClient = bAttachment.fileName;
                    cv.VersionData = bAttachment.body;
                    cv.IsMajorVersion = true;
                    cv.IP_FileFromEmail__c = true;
                    cv.IP_IsEmailUpload__c = true;
                    cvList.add(cv);
                }
            }
            
            if(cvList.size() > 0){
                try {
                    insert cvList;
                } catch(Exception e) {
                    IFv2_ExceptionUtilitiesController.exceptionHandler(e);
                }
                for(ContentVersion cv : cvList){
                    contentVerInsertList.add(cv.Id);
                }
            }
            
            if(contentVerInsertList.size() > 0){
                List<ContentVersion> cvQueryList = [select id, ContentDocumentId from ContentVersion WHERE Id in :contentVerInsertList];
                for (ContentVersion cv : cvQueryList) {
                    ContentDocumentLink cl = new ContentDocumentLink();
                    cl.ContentDocumentId = cv.ContentDocumentId;
                    cl.LinkedEntityId = emailMsg.Id; //Shared with record ID
                    cl.ShareType = 'V';
                    cl.Visibility = 'AllUsers';
                    cdlList.add(cl);
                }
                if(cdlList.size() > 0){
                    try {
                        insert cdlList;
                    } catch(Exception e) {
                        IFv2_ExceptionUtilitiesController.exceptionHandler(e);
                    }
                }
            }
        }
        return result;
    }
}