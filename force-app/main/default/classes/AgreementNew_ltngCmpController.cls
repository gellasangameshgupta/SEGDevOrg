/*******************************************************************************************************
* 
* @ Name		:  AgreementNew_ltngCmpController
* @ Purpose		:  Server side controller for AgreementNew_ltngCmp
* @ Author		:  Absyz
* @ Test Class  :  AgreementNew_ltngCmpController_Test
*
*   Date            |  Developer Name               |  Version      |  Changes
* ======================================================================================================
*   03-03-2022      |  anoop.ravindran@absyz.com    |  1.0          |  Initial Version
*******************************************************************************************************/

public with sharing class AgreementNew_ltngCmpController {
    //Fetch fields to display from FieldSet
    @AuraEnabled
    public static List<Field> fetchFieldSet(String fieldsetName){
        Schema.FieldSet fieldset = Schema.getGlobalDescribe().get('Apttus__APTS_Agreement__c').getDescribe().fieldsets.getMap().get(fieldsetName);
        List<Field> fieldList = new List<Field>();
        for(Schema.FieldSetMember member:fieldset.getFields()){
            Field field = new Field(member.getLabel(), member.getFieldPath(), member.getFieldPath() == 'Apttus__Status_Category__c', member.getDbRequired() || member.getRequired());
            system.debug(field);
            fieldList.add(field);
        }
        System.debug('fieldList--'+fieldList);
        return fieldList;
    }

    //Delete record on cancel
    @AuraEnabled
    public static void deleteRecord(String recordId){
        if(!String.isBlank(recordId)){
            delete new Apttus__APTS_Agreement__c(Id = recordId);
        }
    }
    public class Field{
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String name;
        @AuraEnabled
        public Boolean readOnly;
        @AuraEnabled
        public Boolean required;

        public field(){
            this.label = '';
            this.name = '';
            this.readOnly = false;
            this.required = false;
        }

        public field(String label, String name, Boolean readOnly, Boolean required){
            this.label = label;
            this.name = name;
            this.readOnly = readOnly;
            this.required = required;
        }
    }
}