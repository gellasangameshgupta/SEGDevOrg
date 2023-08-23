@isTest(SeeAllData=true)
public class CanteenSlotBookingControllerTest {
    
    public static testmethod void fetchSlotDetailsTest() {
        test.startTest();
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
        test.stopTest();
        
    }

}