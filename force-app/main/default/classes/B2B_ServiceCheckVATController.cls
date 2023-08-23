/*******************************************************************************************************
* 
* @ Name            :   B2B_ServiceCheckVATController
* @ Purpose         :   To call invocable method from flow B2B_Registration
* @ Methods         :   1) checkVATValidity - Returns response from external application to validate VAT Number
*                       	params - List<VATRequest>
* @ Author          :   Aseem Doddamani
* @ Usage           :   1) To accept parameters from flow,
*                       returns a Boolean value to validate the input VAT Number on the flow screen
* @ Test Class Name :   B2B_ServiceCheckVATControllerTest
*
*   Date            |  Developer Name                 |  Version      |  Changes
* ======================================================================================================
*   22-10-2021      |  aseem.doddamani@absyz.com      |  1.0          |  Initial Version
*
*******************************************************************************************************/
public class B2B_ServiceCheckVATController {
    
    @InvocableMethod
    public static List<VATResult> checkVATValidity (List<VATRequest> list_requestVATParams) {
        List<VATResult> list_VatResults = new List<VATResult>();
        VATResult objVatResults = new VATResult();
        
        if (!list_requestVATParams.isEmpty()) {
            try {
                List<IFv2_Country__mdt> list_Countries = [SELECT 
                                                          Id,
                                                          MasterLabel,
                                                          CountryCode__c
                                                          FROM 
                                                          IFv2_Country__mdt 
                                                          WHERE MasterLabel = :list_requestVATParams[0].strCountryCode
                                                          AND Status__c = 'Active'
                                                          AND CountryCode__c != null
                                                          LIMIT 1
                                                         ];
                
                B2B_ServiceCheckVatTypes.checkVatResponse_element objCheckVatResponse = 
                    new B2B_ServiceCheckVatTypes.checkVatResponse_element();
                B2B_ServiceCheckVat.checkVatPort objMethod = new B2B_ServiceCheckVat.checkVatPort();
                
                if (!list_Countries.isEmpty()) {
                    objCheckVatResponse = objMethod.checkVat(
                        String.valueOf(list_Countries[0].CountryCode__c),
                        list_requestVATParams[0].strVATNumber
                    );
                }
                
                if (objCheckVatResponse.valid) {
                    objVatResults.blnIsValid = true;
                } else {
                    objVatResults.blnIsValid = false;
                }
                
                list_VatResults.add(objVatResults);
            } catch(Exception ex) {
                IFv2_ExceptionUtilitiesController.exceptionHandler(ex);
            }
        }
        
        return list_VatResults;
    }
    
    public class VATRequest {
        @InvocableVariable public String strCountryCode;
        @InvocableVariable public String strVATNumber;
    }
    
    public class VATResult {
        @InvocableVariable public Boolean blnIsValid;
    }
}