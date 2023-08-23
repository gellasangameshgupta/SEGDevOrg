/*
* @ Name        : CanteenSlotBookingController
* @ Purpose     : Controller class for CanteenSlotBookingComponent. 
* @ Author      : Renjumol PS
* @ Test Class  : CanteenSlotBookingControllerTest
*
* Date          | Developer Name                      | Version   | Changes
* ======================================================================================================
* 08-06-2020    | external.debasmita.rawooth@absyz.com       | 1.0       | Initial Version

*******************************************************************************************************/

public without sharing class CanteenSlotBookingController {
    
    @auraEnabled
    Public static List<SlotWrapper> fetchSlotDetails(date searchDate){
        Date appStartDate=[select id,BookingStartDate__c from CanteenBooking__mdt where DeveloperName=:Label.CanteenBookingAppStartDate limit 1].BookingStartDate__c;
	//	Date appStartDate = Date.parse(Label.CanteenBookingAppStartDate);
        System.debug('appStartDate>'+appStartDate);
        Datetime dt = (DateTime)searchDate;
        String dayOfWeek = dt.format('EEEE');
        List<String> allowedWeedkdays = Label.CanteenBookingWeekDays.split(',');
        System.debug('week day>'+dayOfWeek);
        List<SlotWrapper> slotWrapperList=new List<SlotWrapper>();
        if(allowedWeedkdays.contains(dayOfWeek) && searchDate>=appStartDate)
        {
            id loggedInUserId=UserInfo.getUserId();
            System.debug('UserInfo.getUserId()>'+UserInfo.getUserId());
            List<id> groupUserIds=GetGroupAdminUserList();
            System.debug('searchDate>'+searchDate);
            Date search_date = searchDate;
            Date currentDate=Date.today();
            try{
                CanteenBooking__mdt bookingSlot=[select id,BookingStartTime__c,NoOfSlots__c,SlotCapacity__c,SlotDuration__c from CanteenBooking__mdt where BookingStartDate__c<=:search_date and BookingEndDate__c>=:search_date limit 1];
                Id recordTypeId = [SELECT Id,Name,SobjectType FROM RecordType where Name =:Label.CanteenBookingRecordType limit 1].id;
                list<Static_Content__c> allBookings=[select CanteenBooking_Date__c,CanteenBookingTime__c,CanteenBookingTimeSlot__c,CanteenBookingUser__c,CanteenBookingNoOfSlots__c,CanteenBookingforGuest__c from Static_Content__c where CanteenBooking_Date__c=:search_date and recordTypeId=:recordTypeId ];
                system.debug('booking list> inside try>'+allBookings);
                if(bookingSlot!=null)
                {
                     system.debug('bookingSlot> inside if>'+bookingSlot);
                    boolean isBooked=false;
                    for(integer i=0;i<bookingSlot.NoOfSlots__c;i++)
                    {
                        system.debug('bookingSlot> inside for>');
                        SlotWrapper slotwrap=new SlotWrapper();
                        slotwrap.RemoveMeDisabled=true;
                        slotwrap.AddGuestDisabled=false;
                        slotwrap.RemoveGuestDisabled=true;
                        slotwrap.noOfslots=' ';
                     //   slotwrap.ShowBookingsDisabled=true;
                        slotwrap.Id=''+(i+1);
                        String timeString = bookingSlot.BookingStartTime__c.format('h:mm a');
                        System.debug('timeString>'+timeString);
                        bookingSlot.BookingStartTime__c=bookingSlot.BookingStartTime__c.addMinutes(Integer.valueOf(bookingSlot.SlotDuration__c));
                        Integer bookedCount=0;
                        if(allBookings.size()>0)
                        {
                            for(Static_Content__c booking:allBookings)
                            {
                                if(booking.CanteenBookingTimeSlot__c==timeString)
                                {
                                    if(booking.CanteenBookingNoOfSlots__c!=null && booking.CanteenBookingNoOfSlots__c>0)
                                        bookedCount=bookedCount+Integer.valueOf(booking.CanteenBookingNoOfSlots__c);
                                    else
                                    	bookedCount=bookedCount+1;
                                    if(booking.CanteenBookingUser__c==loggedInUserId && booking.CanteenBookingforGuest__c==false)
                                    {
                                        slotwrap.RemoveMeDisabled=false;
                                        isBooked=true;
                                    }
                                    else if(booking.CanteenBookingUser__c==loggedInUserId && booking.CanteenBookingforGuest__c==true)
                                    {
                                        slotwrap.RemoveGuestDisabled=false;
                                        slotwrap.noOfslots=Label.CanteenBookingGuests+' '+booking.CanteenBookingNoOfSlots__c;
                                    }
                                    
                                }
                            }
                        }
                        Integer available=Integer.valueOf(bookingSlot.SlotCapacity__c)-bookedCount;
                        //slotwrap.availableSlot=''+available;
                        slotwrap.slot=timeString;
                        if(available>0)
                        {
                            slotwrap.AddMeDisabled=false;
                            slotwrap.AddGuestDisabled=false;
                            slotwrap.availableSlot=''+available;
                        }
                        else
                        {
                            slotwrap.availableSlot='0';
                            slotwrap.AddMeDisabled=true;
                            slotwrap.AddGuestDisabled=true;
                        }
                        if(slotwrap.RemoveMeDisabled==false)
                            slotwrap.AddMeDisabled=true;
                        if(slotwrap.RemoveGuestDisabled==false)
                            slotwrap.AddGuestDisabled=true;
                        
                        if(search_date<currentDate)
                        {
                            slotwrap.AddMeDisabled=true;
                            slotwrap.RemoveMeDisabled=true;
                            slotwrap.RemoveGuestDisabled=true;
                            slotwrap.AddGuestDisabled=true;
                        }
                        
                        
                        slotWrapperList.add(slotwrap);
                    }
                    for(slotWrapper record:slotWrapperList)
                    {
                        if(isBooked==true)
                            record.AddMeDisabled=true;
                    }
                }        
            }
            catch(Exception e)
            {
                System.debug(e.getMessage());
            }
            return slotWrapperList;
        }
        else 
        {
            SlotWrapper slotwrap=new SlotWrapper();
            slotwrap.ErrorMessage=Label.CanteenBookingError1;
            if(!allowedWeedkdays.contains(dayOfWeek))
                slotwrap.ErrorMessage=Label.CanteenBookingError2;
            if(searchDate<appStartDate)
                slotwrap.ErrorMessage=Label.CanteenBookingError8;
            slotWrapperList.add(slotwrap);
            return slotWrapperList;
        }
    }
    
    @auraEnabled
    Public static string addBooking(date searchDate, String slot){
        String message='SUCCESS';
        id loggedInUserId=UserInfo.getUserId();
        Static_Content__c booking=new Static_Content__c();
        booking.CanteenBooking_Date__c=searchDate;
        booking.CanteenBookingTimeSlot__c=slot; 
        booking.CanteenBookingUser__c=loggedInUserId;
        try{
            booking.CanteenBookingTime__c=convertTime(slot,searchDate);
            System.debug('searchDate>'+searchDate+'>slot>'+slot+'loggedInUserId>'+loggedInUserId);
            Id recordTypeId = [SELECT Id,Name,SobjectType FROM RecordType where Name =:Label.CanteenBookingRecordType limit 1].id;
            booking.RecordTypeId=recordTypeId;
            insert(booking);
           
        }Catch(Exception e)
        {
            System.debug('addBooking>'+e.getMessage());
            message=Label.CanteenBookingError1;
        }
        return message;
    }
    @auraEnabled
    Public static string addGuestBooking(date searchDate, String slot, Integer noOfSlots){
        String message='SUCCESS';
        id loggedInUserId=UserInfo.getUserId();
        Static_Content__c booking=new Static_Content__c();
        booking.CanteenBooking_Date__c=searchDate;
        booking.CanteenBookingTimeSlot__c=slot;
        booking.CanteenBookingNoOfSlots__c=noOfSlots;
        booking.CanteenBookingUser__c=loggedInUserId;
        booking.CanteenBookingforGuest__c=true;
        
        try{
            booking.CanteenBookingTime__c=convertTime(slot,searchDate);
            System.debug('searchDate>'+searchDate+'>time>'+booking.CanteenBookingTime__c+' loggedInUserId>'+loggedInUserId);
            Id recordTypeId = [SELECT Id,Name,SobjectType FROM RecordType where Name =:Label.CanteenBookingRecordType limit 1].id;
            booking.RecordTypeId=recordTypeId;
            System.debug('guest>'+booking);
            insert(booking);
        }Catch(Exception e)
        {
            System.debug('addBooking>'+e.getMessage());
            message=Label.CanteenBookingError1;
        }
        return message;
    }
    
    @auraEnabled
    Public static void removeBooking(date searchDate, String slot){
        id loggedInUserId=UserInfo.getUserId();
        Date bookingDate=searchDate;
        System.debug('searchDate>'+searchDate+'>slot>'+slot+'loggedInUserId>'+loggedInUserId);
        try{
            Id recordTypeId = [SELECT Id,Name,SobjectType FROM RecordType where Name =:Label.CanteenBookingRecordType limit 1].id;
            Static_Content__c bookingDelete=[select id from Static_Content__c where CanteenBooking_Date__c=:bookingDate and CanteenBookingTimeSlot__c=:slot and CanteenBookingforGuest__c=false and CanteenBookingUser__c=:loggedInUserId and recordTypeId=:recordTypeId limit 1];
            delete(bookingDelete);
        }Catch(Exception e)
        {
            System.debug('addBooking>'+e.getMessage());
        }
        
    }
    @auraEnabled
    Public static void removeGuestBooking(date searchDate, String slot){
        id loggedInUserId=UserInfo.getUserId();
        Date bookingDate=searchDate;
        System.debug('searchDate>'+searchDate+'>slot>'+slot+'loggedInUserId>'+loggedInUserId);
        try{
            Id recordTypeId = [SELECT Id,Name,SobjectType FROM RecordType where Name =:Label.CanteenBookingRecordType limit 1].id;
            Static_Content__c bookingDelete=[select id from Static_Content__c where CanteenBooking_Date__c=:bookingDate and CanteenBookingTimeSlot__c=:slot and CanteenBookingUser__c=:loggedInUserId and CanteenBookingforGuest__c=true and recordTypeId=:recordTypeId limit 1];
            delete(bookingDelete);
        }Catch(Exception e)
        {
            System.debug('addBooking>'+e.getMessage());
        }
        
    }
    @auraEnabled
    Public static List<Static_Content__c> fetchBookingDetails(date searchDate, String slot){
        Date bookingDate=searchDate;
        List<Static_Content__c> bookingDetails=new List<Static_Content__c>();
        System.debug('searchDate>'+searchDate+'>slot>'+slot);
        try{
            Id recordTypeId = [SELECT Id,Name,SobjectType FROM RecordType where Name =:Label.CanteenBookingRecordType limit 1].id;
            bookingDetails=[select id,CanteenBookingUser__c,CanteenBookingUser__r.Name,CanteenBookingforGuest__c,CanteenBookingNoOfSlots__c from Static_Content__c where CanteenBooking_Date__c=:bookingDate and CanteenBookingTimeSlot__c=:slot and recordTypeId=:recordTypeId];
            
        }Catch(Exception e)
        {
            System.debug('addBooking>'+e.getMessage());
        }
        return bookingDetails;
    }
    
    @auraEnabled
    Public static Boolean showBookingDetailsButton(){
        Boolean showButton=false;
        try{
            List<id> groupUserIds=GetGroupAdminUserList();
            id loggedInUserId=UserInfo.getUserId();
            if(groupUserIds.contains(loggedInUserId))
                showButton=true;              
        }Catch(Exception e)
        {
            System.debug('addBooking>'+e.getMessage());
        }
        return showButton;
    }
    
    public static Time convertTime(String slot,Date searchDate)
    {
        Time timeslot;
        String[] timeParts = slot.split(' ');
        Integer hour = (timeParts[0].split(':')[0]!='12'? (Integer.valueOf(timeParts[0].split(':')[0]) + (timeParts[1] == 'PM' ? 12 : 0)) : 
                        (timeParts[1] == 'AM' ? 0 : 12));
        Integer minute = Integer.valueOf(timeParts[0].split(':')[1]);
        Integer second = 0;
        System.debug('hour>>'+hour+' min>>'+minute+' sec>>'+second);
        Datetime parsedDate = Datetime.newInstance(searchDate.year(), searchDate.month(), searchDate.day(), hour, minute, second);  
        timeslot=parsedDate.time();
        return timeslot;
    }
    
    public static List<Id> GetGroupAdminUserList()
    {
        List<Id> usersIdsInGroup= new List<Id>();
        Id groupId = [select id,name from Group where name=:Label.CanteenBookingViewUsers limit 1].id;
        List<GroupMember> groupMembers=[Select Id, group.type, UserOrGroupId From GroupMember where group.id=:groupId];
        for(GroupMember gm : groupMembers)
        {
            usersIdsInGroup.add(gm.UserOrGroupId);
        }
        for(User user:[select id,name from user where profile.name=:Label.CLIFv20008 and IsActive=true])
        {
            usersIdsInGroup.add(user.id);
        }
        for(user user:[select id,name from user where id in:usersIdsInGroup])
        {
            System.debug('user name>'+user.name+ ':: userId>'+user.id);
        }
        System.debug('current user name>'+[select id,name from user where id=:UserInfo.getUserId()].name+':: id>'+UserInfo.getUserId()); 
        return usersIdsInGroup;
    }
    
    public class SlotWrapper {
        
        @AuraEnabled
        public Boolean RemoveMeDisabled;
        @AuraEnabled
        public Boolean AddMeDisabled;
        @AuraEnabled
        public Boolean RemoveGuestDisabled;
        @AuraEnabled
        public Boolean AddGuestDisabled;
        @AuraEnabled
        public Boolean ShowBookingsDisabled;
        @AuraEnabled
        public String slot;
        @AuraEnabled
        public String noOfslots;
        @AuraEnabled
        public String availableSlot; 
        @AuraEnabled
        public String Id;
        @AuraEnabled
        public String ErrorMessage;
        
        
    }
    
    
}