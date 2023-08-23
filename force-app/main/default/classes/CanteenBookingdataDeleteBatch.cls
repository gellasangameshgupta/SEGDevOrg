global class CanteenBookingdataDeleteBatch implements Database.Batchable<sObject>, Schedulable {
   
    global RecordType canteenRecordTypeId = [Select id from RecordType where sObjectType = 'Static_Content__c' and DeveloperName ='Canteen_Booking' Limit 1]; 
    global Database.QueryLocator start(Database.BatchableContext BC) {
        system.debug('canteenRecordTypeId '+canteenRecordTypeId.Id);
        String query = 'SELECT Id, Name, RecordTypeId, RecordType.name, createddate FROM Static_Content__c where RecordTypeId = \''+canteenRecordTypeId.Id +
            '\' and CreatedDate < Last_N_Days:28 ';
        system.debug('query '+query);
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Static_Content__c> BookingList) {
       system.debug('BookingList '+BookingList);
        try {
        	delete  BookingList;       
        } catch(Exception e) {
            System.debug(e);
        }
    } 
    global void finish(Database.BatchableContext BC) {
  }
    global void execute(SchedulableContext SC) {
        database.executebatch(new CanteenBookingdataDeleteBatch());
    }
}