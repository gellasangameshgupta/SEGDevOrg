@isTest
public class CanteenBookingdataDeleteBatchTest {
    
    public static testmethod void fetchSlotDetailsTest() {
       // test.startTest();
        CanteenBooking__mdt bookingSlot=[select id,BookingStartDate__c,BookingStartTime__c,NoOfSlots__c,SlotCapacity__c,SlotDuration__c from CanteenBooking__mdt limit 1];
        List<String> allowedWeedkdays = Label.CanteenBookingWeekDays.split(',');
        Date searchDate;
        for(Integer i=0;i<7;i++)
        {
            Datetime dt = (DateTime)bookingSlot.BookingStartDate__c;
        	String dayOfWeek = dt.format('EEEE');
            if(allowedWeedkdays.contains(dayOfWeek))
            {
                searchDate=bookingSlot.BookingStartDate__c;
                break;
            }
            else 
                bookingSlot.BookingStartDate__c=bookingSlot.BookingStartDate__c+1;
        }
        String timeString = bookingSlot.BookingStartTime__c.format('h:mm a');
        boolean bookingbutton=CanteenSlotBookingController.showBookingDetailsButton();
        CanteenSlotBookingController.addBooking(searchDate,timeString);
        CanteenSlotBookingController.addGuestBooking(searchDate,timeString,2);
        CanteenSlotBookingController.fetchSlotDetails(searchDate);
        CanteenSlotBookingController.fetchSlotDetails(searchDate-1); 
        CanteenSlotBookingController.fetchBookingDetails(searchDate,timeString);
        CanteenSlotBookingController.removeBooking(searchDate,timeString);
        CanteenSlotBookingController.removeGuestBooking(searchDate,timeString);
        
        User user1,user2;
         Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
         User u = new user();
        u.alias = 'alias';
        u.LastName = 'lastName';
        u.Username = 'test@testingfsagdgdsbggfbsajkdf.com';
        u.Email = 'test@seg-automotive.com';
        u.TimeZoneSidKey = 'Europe/Berlin';
        u.LocaleSidKey = 'en_US';
        u.EmailEncodingKey = 'UTF-8';
        u.LanguageLocaleKey = 'en_US';
        u.ProfileId = profileId.Id;
        u.Department = '123';
        insert u;
        Static_Content__c obj = new Static_Content__c();
        RecordType canteenRecordTypeId = [Select id from RecordType where sObjectType = 'Static_Content__c' and DeveloperName ='Canteen_Booking' Limit 1]; 

        obj.RecordTypeId = canteenRecordTypeId.id;
        obj.CanteenBookingUser__c = u.id;
        obj.CanteenBooking_Date__c = system.today();
        obj.CanteenBookingTimeSlot__c = timeString;
        obj.CanteenBookingNoOfSlots__c = 1;
        insert obj;
        Datetime yesterday = Datetime.now().addDays(-30);
        Test.setCreatedDate(obj.Id, yesterday);  
        test.startTest();
        CanteenBookingdataDeleteBatch obj1 = new CanteenBookingdataDeleteBatch();
        DataBase.executeBatch(obj1); 
        test.stopTest();
        
        
        
        
    }


}