@isTest
public class Covid_Test_Booking_Controller_test {
    
    public static testmethod void fetchSlotDetailsTest() {
        test.startTest();
        
        CovidTestBooking__mdt bookingSlot=[select id,BookingStartDate__c,BookingStartTime__c,NoOfSlots__c,SlotCapacity__c,SlotDuration__c from CovidTestBooking__mdt limit 1];
        List<String> allowedWeedkdays = Label.Covid_Week_Days.split(',');
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
        boolean bookingbutton=Covid_Test_Booking_Controller.showBookingDetailsButton();
        Covid_Test_Booking_Controller.addBooking(searchDate,timeString);
        Covid_Test_Booking_Controller.addGuestBooking(searchDate,timeString,2);
        Covid_Test_Booking_Controller.fetchSlotDetails(searchDate);
        Covid_Test_Booking_Controller.fetchSlotDetails(searchDate-1); 
        Covid_Test_Booking_Controller.fetchBookingDetails(searchDate,timeString);
        Covid_Test_Booking_Controller.removeBooking(searchDate,timeString);
        Covid_Test_Booking_Controller.removeGuestBooking(searchDate,timeString);
        test.stopTest();
        
    }

}