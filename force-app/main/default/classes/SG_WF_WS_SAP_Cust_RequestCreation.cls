/**
*
*
* @ Purpose : This Apex Class Handles the SAP Call to APM Interface #3 from SAP and creates a Request 
*
* @ Author: Peter Bosch
*
*
*       Date                |   Developer Name                  |   Version         |   Changes
* ===========================================================================================================
*   (1.0) ??.??.????        |   Michal Swist    |   1.0         |   Initial Version |
*   (1.1) 18.12.2017        |   Peter.Bosch@t-systems.com       |   1.1             |   Added Logic for WF 6 
*   12/04/2019              |   vivek.Kothalanka@absyz.comm     |   2.1             |   Added logic for Deactivate workflow
*/


global class SG_WF_WS_SAP_Cust_RequestCreation{ 
    
    /* Class for response object */
    global class ResponseObject{
        
        /* variables for response */
        WebService String result;
        WebService String objectId;
        WebService String errorDescription;
        
        /* constructor */
        public ResponseObject(String result, String objectId, String errorDescription){
            this.result = result;
            this.objectId = objectId;
            this.errorDescription = errorDescription;
        }      
        
    }
    
    /* Class to store field values */
    global class RequestWrapper{
        
        /* variables for inserting to the record */
        WebService String Accounting_clerk_information;
        WebService String Approver_Proxy_name;
        WebService String Approver_name;
        WebService String Company_Code;
        WebService String Cost_Center;
        WebService String Document_Item;
        WebService String Fiscal_Year;
        WebService String GL;
        WebService String II_is_blocked_due_to_other_reasons;
        WebService String Internal_Order;
        WebService String Invoice_Item_Currency;
        WebService String Invoice_Number;
        WebService String Invoice_date_document_date;
        WebService String Invoice_item_amount;
        WebService String Invoice_quantity;
        WebService String Invoice_type_Document_type;
        WebService String Invoice_unit_of_measure;
        WebService String Invoicing_Party_vendor_name;
        WebService String Invoicing_Party_vendor_number;
        WebService String Item_Text;
        WebService String Material_Number;
        WebService String PV_between_PO_item_and_Invoice_item;
        WebService String Plant_SAP;
        WebService String Posting_date;
        WebService String Profit_Center;
        WebService String Purchase_order_item_s;
        WebService String Purchase_order_number; 
        WebService String Purchasing_organization; 
        WebService String QV_between_PO_item_and_Invoice_item;
        WebService String Salesforce_ID;
        WebService String Unit_Of_Measure;
        WebService String WBS_Element;
        WebService String Workflow_number;
        WebService String order_net_price;
        WebService String order_quantity;
    }
    
    WebService static SG_WF_WS_SAP_Cust_RequestCreation.ResponseObject createApmRequest(RequestWrapper rw){
        
        /* Response to send */
        SG_WF_WS_SAP_Cust_RequestCreation.ResponseObject response;
        
        /*Start of Iteartion 3 changes */
        /* To check if re is not null */
        if(rw != NULL) {
            
            LIST<IFv2_Workflows__mdt> workflowList = new LIST<IFv2_Workflows__mdt>();   // List to store queried workflow metadata based on workflow number 
            
            /* Query for workflows metadata based on workflow number */
            if(rw.Workflow_number != null) {
                workflowList = [SELECT Name__c,ThirdPartyFormat__c,Status__c,DeactivateInInsightflow1__c
                                FROM IFv2_Workflows__mdt 
                                WHERE ThirdPartyFormat__c != NULL AND ThirdPartyFormat__c = : rw.Workflow_number];
            }
            
            System.debug('workflow list not empty>>'+workflowList);
            Boolean DeactivateWorkflow = true;  // Boolean variable to check if workflow is deactivated and to works also if mdt record id deleted 
            // if(!Test.isRunningTest()){
            /* Checking if workflowList is not empty */
            if(!workflowList.isEmpty()) {
                
                /* Checking if deactivate insightflow check box is checked is checked or not */
                if(workflowList[0].DeactivateInInsightflow1__c && workflowList[0].Status__c == 'Active') {
                    
                    DeactivateWorkflow = false;
                    IFv2_ICORequestCreation.RequestWrapper IFv2_Rw = new IFv2_ICORequestCreation.RequestWrapper(rw);    // Creating an instance of ICORequstCreation Class
                    
                    /* Getting the response from ICORequestCreation class */
                    response = (SG_WF_WS_SAP_Cust_RequestCreation.ResponseObject)JSON.deserialize(JSON.serialize(IFv2_ICORequestCreation.createApmRequest(IFv2_Rw)), SG_WF_WS_SAP_Cust_RequestCreation.ResponseObject.class);
                } 
            }
            //  }
            /* This part of logic will execute if worklfow is not deactivated in 1.0 */
            /*commented for cleaning up of Insightflow 1.0 components
if(DeactivateWorkflow) {
if(String.isBlank(rw.Salesforce_ID) || String.isBlank(rw.Approver_name) || String.isBlank(rw.Workflow_number)){
response = response = new SG_WF_WS_SAP_Cust_RequestCreation.ResponseObject('ERROR', '', 'Salesforce ID, Approver Name and Workflow number are required, please check if are filled properly');
} else {    
WF_Request__c apmRequest = new WF_Request__c();
String errorDesc = '';

List<Workflow__c> apmWFList= new List<Workflow__c>([SELECT Id, Name, Application_Key__c 
FROM Workflow__c 
WHERE Name IN ('AP Monitor Workflow-1', 'AP Monitor Workflow-2', 'AP Monitor Workflow-3', 'AP Monitor Workflow-4', 'AP Monitor Workflow-5', 'AP Monitor Workflow-6', 'AP Monitor Workflow-8')]);

Map<String, Workflow__c> appKeyToWfMap = new Map<String, Workflow__c>();

for(Workflow__c wf : apmWFList){
appKeyToWfMap.put(wf.Application_Key__c, wf);
}

List<RecordType> rtList = new List<RecordType>([
SELECT Id, DeveloperName
FROM RecordType 
wHERE DeveloperName in 
('X34_AP_Monitor_workflow_1','X35_AP_Monitor_workflow_2', 'X36_AP_Monitor_workflow_3', 'X37_AP_Monitor_workflow_4', 'X38_AP_Monitor_workflow_5','X39_AP_Monitor_workflow_6', 'X40_AP_Monitor_workflow_7', 'X41_AP_Monitor_workflow_8')]);

Map<String, RecordType> mapWorkflowNumberToRecordType = new Map<String, RecordType>();

for(RecordType rt : rtList){
String devName = rt.DeveloperName;
mapWorkflowNumberToRecordType.put('0'+devName.substring(devName.length()-1, devName.length()), rt);
}

List<User> retrievedUsers = [SELECT Id, NT_User__c FROM User WHERE NT_User__c =: rw.Approver_name OR NT_User__c =: rw.Approver_Proxy_name];

Map<String, User> sapUserToSFDCUserMap = new Map<String, User>();
for(User u : retrievedUsers){
sapUserToSFDCUserMap.put(u.NT_User__c , u);
}

try{
apmRequest.Accounting_clerk_information__c = (rw.Accounting_clerk_information != null || !String.isBlank(rw.Accounting_clerk_information)) ? rw.Accounting_clerk_information : '';
apmRequest.Approver_Proxy_name__c = (rw.Approver_Proxy_name != null || !String.isBlank(rw.Approver_Proxy_name)) ? rw.Approver_Proxy_name : '';
apmRequest.Approver_name__c = (rw.Approver_name != null || !String.isBlank(rw.Approver_name)) ? rw.Approver_name : '';
apmRequest.Company_Code__c = (rw.Company_Code != null || !String.isBlank(rw.Company_Code)) ? rw.Company_Code : '';
apmRequest.Cost_Center__c = (rw.Cost_Center != null || !String.isBlank(rw.Cost_Center)) ? rw.Cost_Center : '';
apmRequest.Document_Item__c = (rw.Document_Item != null || !String.isBlank(rw.Document_Item)) ? rw.Document_Item : '';
apmRequest.Fiscal_Year__c = (rw.Fiscal_Year != null || !String.isBlank(rw.Fiscal_Year)) ? rw.Fiscal_Year : '';
apmRequest.GL__c = (rw.GL != null || !String.isBlank(rw.GL)) ? rw.GL : '';
apmRequest.II_is_blocked_due_to_other_reasons__c = (rw.II_is_blocked_due_to_other_reasons != null || !String.isBlank(rw.II_is_blocked_due_to_other_reasons)) ? rw.II_is_blocked_due_to_other_reasons : '';
apmRequest.Internal_Order__c = (rw.Internal_Order != null || !String.isBlank(rw.Internal_Order)) ? rw.Internal_Order : '';
apmRequest.Invoice_Item_Currency__c = (rw.Invoice_Item_Currency != null || !String.isBlank(rw.Invoice_Item_Currency)) ? rw.Invoice_Item_Currency : '';
apmRequest.Invoice_Number__c = (rw.Invoice_Number != null || !String.isBlank(rw.Invoice_Number)) ? rw.Invoice_Number : '';
apmRequest.Invoice_date_document_date__c = (rw.Invoice_date_document_date != null || !String.isBlank(rw.Invoice_date_document_date)) ? rw.Invoice_date_document_date : '';
apmRequest.Invoice_item_amount__c = (rw.Invoice_item_amount != null || !String.isBlank(rw.Invoice_item_amount)) ? rw.Invoice_item_amount : '';
apmRequest.Invoice_quantity__c = (rw.Invoice_quantity != null || !String.isBlank(rw.Invoice_quantity)) ? rw.Invoice_quantity : '';
apmRequest.Invoice_type_Document_type__c = (rw.Invoice_type_Document_type != null || !String.isBlank(rw.Invoice_type_Document_type)) ? rw.Invoice_type_Document_type : '';
apmRequest.Invoice_unit_of_measure__c = (rw.Invoice_unit_of_measure != null || !String.isBlank(rw.Invoice_unit_of_measure)) ? rw.Invoice_unit_of_measure : '';
apmRequest.Invoicing_Party_vendor_name__c = (rw.Invoicing_Party_vendor_name != null || !String.isBlank(rw.Invoicing_Party_vendor_name)) ? rw.Invoicing_Party_vendor_name : '';
apmRequest.Invoicing_Party_vendor_number__c = (rw.Invoicing_Party_vendor_number != null || !String.isBlank(rw.Invoicing_Party_vendor_number)) ? rw.Invoicing_Party_vendor_number : '';
apmRequest.Item_Text__c = (rw.Item_Text != null || !String.isBlank(rw.Item_Text)) ? rw.Item_Text : '';
apmRequest.Material_Number__c = (rw.Material_Number != null || !String.isBlank(rw.Material_Number)) ? rw.Material_Number : '';
apmRequest.PV_between_PO_item_and_Invoice_item__c = (rw.PV_between_PO_item_and_Invoice_item != null || !String.isBlank(rw.PV_between_PO_item_and_Invoice_item)) ? rw.PV_between_PO_item_and_Invoice_item : '';
apmRequest.Plant_SAP__c = (rw.Plant_SAP != null || !String.isBlank(rw.Plant_SAP)) ? rw.Plant_SAP : '';
apmRequest.Posting_date__c = (rw.Posting_date != null || !String.isBlank(rw.Posting_date)) ? rw.Posting_date : '';
apmRequest.Profit_Center__c = (rw.Profit_Center != null || !String.isBlank(rw.Profit_Center)) ? rw.Profit_Center : '';
apmRequest.Purchase_order_item_s__c = (rw.Purchase_order_item_s != null || !String.isBlank(rw.Purchase_order_item_s)) ? rw.Purchase_order_item_s : '';
apmRequest.Purchase_order_number__c = (rw.Purchase_order_number != null || !String.isBlank(rw.Purchase_order_number)) ? rw.Purchase_order_number : '';
apmRequest.Purchasing_organization__c = (rw.Purchasing_organization != null || !String.isBlank(rw.Purchasing_organization)) ? rw.Purchasing_organization : '';
apmRequest.QV_between_PO_item_and_Invoice_item__c = (rw.QV_between_PO_item_and_Invoice_item != null || !String.isBlank(rw.QV_between_PO_item_and_Invoice_item)) ? rw.QV_between_PO_item_and_Invoice_item : '';
apmRequest.Salesforce_ID__c = (rw.Salesforce_ID != null || !String.isBlank(rw.Salesforce_ID)) ? rw.Salesforce_ID : '';
apmRequest.Unit_Of_Measure__c = (rw.Unit_Of_Measure != null || !String.isBlank(rw.Unit_Of_Measure)) ? rw.Unit_Of_Measure : '';
apmRequest.WBS_Element__c = (rw.WBS_Element != null || !String.isBlank(rw.WBS_Element)) ? rw.WBS_Element : '';
apmRequest.Workflow_number__c = (rw.Workflow_number != null || !String.isBlank(rw.Workflow_number)) ? rw.Workflow_number : '';
apmRequest.order_net_price__c = (rw.order_net_price != null || !String.isBlank(rw.order_net_price)) ? rw.order_net_price : '';
apmRequest.order_quantity__c = (rw.order_quantity != null || !String.isBlank(rw.order_quantity)) ? rw.order_quantity: '';
//Fields that have been moved from trigger:
String testVariable = rw.Workflow_number;
System.debug(testVariable);
apmRequest.RecordTypeId = mapWorkflowNumberToRecordType.get(rw.Workflow_number).Id;
apmRequest.WF_Workflow_Name__c = appKeyToWfMap.get('APM'+rw.Workflow_number.substring(1, rw.Workflow_number.length())).Id;
apmRequest.WF29_Approver__c = sapUserToSFDCUserMap.get(rw.Approver_name).Id;
if(!String.isBlank(rw.Approver_Proxy_name) && rw.Approver_Proxy_name != null){
apmRequest.Approver_2__c = sapUserToSFDCUserMap.get(rw.Approver_Proxy_name).Id;
} 
//WF6 changes - Accounting Clerk comes with the Proxy field
if(!String.isBlank(rw.Approver_Proxy_name) && rw.Approver_Proxy_name != null){
apmRequest.OwnerId = sapUserToSFDCUserMap.get(rw.Approver_Proxy_name).Id;
apmRequest.Status__c = 'Draft';
apmRequest.WF29_Approver__c = null;
apmRequest.Approver_2__c = sapUserToSFDCUserMap.get(rw.Approver_name).Id;
}
insert apmRequest;
} catch (Exception e){
errorDesc = e.getMessage() + '\n' + e.getStackTraceString();        
}

if(String.isBlank(errorDesc)){
response = new SG_WF_WS_SAP_Cust_RequestCreation.ResponseObject('SUCCESS', apmRequest.Id, '');
} else {
response = new SG_WF_WS_SAP_Cust_RequestCreation.ResponseObject('ERROR', '', errorDesc);
}
}
} */
        }
        return response;
    }
}