/*
 *@Class Name: APTS_UpdateNonStandardFlowController
 *@Author : Apttus 
 *@Usage: This class is used to update the flag Non-Standard flow to True and assign the Agreement record to Legal Queue.
 */
public with sharing class APTS_UpdateNonStandardFlowController {
    
  private Apttus__APTS_Agreement__c agreement;
  
  public APTS_UpdateNonStandardFlowController(ApexPages.StandardController stdController) {     
    this.agreement = (Apttus__APTS_Agreement__c)stdController.getRecord();    
  }

/* 
 *@Function Name: updateFlow
 *@Author : Apttus 
 *@Usage: This function is used to to update the flag Non-Standard flow to True and assign the Agreement record to Legal Queue
*/
  public PageReference updateNonStandardFlow(){    
    
    Group groupDetail = [SELECT Id, Name, DeveloperName, Email, Type FROM Group where Type='Queue' And Name ='Legal Queue' limit 1];
    agreement.OwnerId = groupDetail.Id;  
    agreement.Apttus__Non_Standard_Legal_Language__c = true;
    agreement.Apttus__Status_Category__c =  'In Authoring';   
    agreement.Apttus__Status__c = 'Author Contract';

    try {
        update agreement; 
    } catch (Exception e) {
        System.debug(LoggingLevel.ERROR, '[APTS_UpdateNonStandardFlowController] Exception: ' + e.getMessage());
        System.debug(LoggingLevel.ERROR, '[APTS_UpdateNonStandardFlowController] Exception: ' + e.getStackTraceString());          
    }   
    PageReference result = new ApexPages.StandardController(agreement).view();
    
    return result;    
  }


}