/*******************************************************************************************************
* 
* @ Name        :   AQT_CreateOrderSummaryBatch
* @ Purpose     :   Batch class to create order summary record from order 
* @ Author      :   Khushmeet Kaur
*
*   Date        |  Developer Name              |  Version      |  Changes
* ======================================================================================================
*   01-08-2022  |  Khushmeet.kaur@absyz.com    |  1.0          |  Initial Version
*
*******************************************************************************************************/
public class AQT_CreateOrderSummaryBatch implements Database.Batchable<sObject>,Schedulable{
    
    public AQT_CreateOrderSummaryBatch() {
        
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Id FROM Order WHERE Id NOT IN (SELECT OriginalOrderId FROM OrderSummary) AND CreatedDate = TODAY';
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC, List<Order>scope){
        
        For(Order objOrder : scope){
            ConnectApi.OrderSummaryInputRepresentation objOrderSummary = new ConnectApi.OrderSummaryInputRepresentation();
            objOrderSummary.OrderId = objOrder.Id;
            objOrderSummary.Status = 'Created';
           
            ConnectApi.OrderSummaryOutputRepresentation objOrderSummaryId = ConnectApi.OrderSummaryCreation.createOrderSummary(objOrderSummary);
        }
    }
    
    public void finish(Database.BatchableContext BC){
        
    }
    
    public void execute(SchedulableContext SC) {
        database.executebatch(new AQT_CreateOrderSummaryBatch());
    }
    
}