({
	helperInit : function(component, event, helper) {
        component.set("v.Spinner",true);
        var action = component.get('c.fetchSlotDetails');           
        action.setParams({
            'searchDate': component.get("v.selectedDate")
        });   
        action.setCallback(this, function(response) {
            var state = response.getState();
          //  alert(JSON.stringify(response.getReturnValue()));
            if (state === "SUCCESS") {           
                if(response.getReturnValue()!=null && response.getReturnValue().length>0)
                {
                    if(response.getReturnValue().length===1 && response.getReturnValue()[0].ErrorMessage!=null)
                    {
                        component.set("v.showTimeSlots",false);    
                    	helper.ToastMethod("Error!",response.getReturnValue()[0].ErrorMessage,"error")
                    }
                    else
                    {
                        component.set('v.slotData',response.getReturnValue());
                        component.set("v.showTimeSlots",true);
                    }    
                }
                else
                {
                    component.set("v.showTimeSlots",false);    
                    helper.ToastMethod("Error!",$A.get("$Label.c.CanteenBookingError9"),"error")
                }
                     
                //  component.set("v.selectedDate", today);
            }
            else
            {
                component.set("v.showTimeSlots",false);  
                helper.ToastMethod("Error!",$A.get("$Label.c.CanteenBookingError1"),"error")
            }
            component.set("v.Spinner",false);
        });
         $A.enqueueAction(action);
	},
    helperSearchDateChanged : function(component, event, helper,searchDate) {
        component.set("v.Spinner",true);
		var action = component.get('c.fetchSlotDetails');      
        if(searchDate!='Invalid Date')
        {
            action.setParams({
                'searchDate': component.get("v.selectedDate")
            });   
            action.setCallback(this, function(response) {
                var state = response.getState();
          //      alert(JSON.stringify(response.getReturnValue()));
                if (state === "SUCCESS") {                    
                    if(response.getReturnValue()!=null && response.getReturnValue().length>0)
                    {
                        if(response.getReturnValue().length===1 && response.getReturnValue()[0].ErrorMessage!=null)
                        {
                            component.set("v.showTimeSlots",false);    
                            helper.ToastMethod("Error!",response.getReturnValue()[0].ErrorMessage,"error")
                        }
                        else
                        {
                            component.set('v.slotData',response.getReturnValue());
                            component.set("v.showTimeSlots",true);
                        }    
                    }
                    else
                    {
                        component.set("v.showTimeSlots",false);    
                        helper.ToastMethod("Error!",$A.get("$Label.c.CanteenBookingError9"),"error")
                    }
                }
                else
                {
                    component.set("v.showTimeSlots",false);  
                    helper.ToastMethod("Error!",$A.get("$Label.c.CanteenBookingError1"),"error")
                }
                component.set("v.Spinner",false);
            });
            $A.enqueueAction(action);
        }
        
	},
    helperAddBooking : function(component, event, helper, row) {
        component.set("v.Spinner",true);
		var action = component.get('c.addBooking');           
        action.setParams({
            'searchDate': component.get("v.selectedDate"),
            'slot': row.slot
          });   
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {  
                if(response.getReturnValue() === "SUCCESS")
                {
                    helper.ToastMethod("Success!",$A.get("$Label.c.CanteenBookingSuccess1"),"success");
                    helper.helperInit(component, event, helper);
                }
                else
                    helper.ToastMethod("Error!",response.getReturnValue(),"error")
                
            }
            else
            {
                helper.ToastMethod("Error!",$A.get("$Label.c.CanteenBookingError1"),"error")
            }
            component.set("v.Spinner",false);
        });
         $A.enqueueAction(action);
	},
    helperAddGuestBookingModal : function(component, event, helper, row) {
        var guestBooking=component.get("v.guestBooking");
        guestBooking.CanteenBooking_Date__c=component.get("v.selectedDate");
        guestBooking.CanteenBookingTimeSlot__c=row.slot;
        guestBooking.availableSlot=row.availableSlot;
        component.set("v.showAddGuestBooking",true);
	},
    helperAddGuestBooking : function(component, event, helper) {   
        component.set("v.Spinner",true);
		var action = component.get('c.addGuestBooking');           
        action.setParams({
            'searchDate': component.get("v.selectedDate"),
            'slot': component.get("v.guestBooking.CanteenBookingTimeSlot__c"),
            'noOfSlots': component.get("v.guestBooking.CanteenBookingNoOfSlots__c")
          });   
        action.setCallback(this, function(response) {
            component.set("v.showAddGuestBooking",false);
            var state = response.getState();
            if (state === "SUCCESS") {  
                if(response.getReturnValue() === "SUCCESS")
                {
                    helper.ToastMethod("Success!",$A.get("$Label.c.CanteenBookingSuccess1"),"success");
                    helper.helperInit(component, event, helper);
                }
                else
                    helper.ToastMethod("Error!",response.getReturnValue(),"error")
                
            }
            else
            {
                helper.ToastMethod("Error!",$A.get("$Label.c.CanteenBookingError1"),"error")
            }
            component.set("v.Spinner",false);
        });
         $A.enqueueAction(action);
         
	},
    helperRemoveBooking : function(component, event, helper, row) {
        component.set("v.Spinner",true);
		var action = component.get('c.removeBooking');           
        action.setParams({
            'searchDate': component.get("v.selectedDate"),
            'slot': row.slot
          });   
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                helper.ToastMethod("Success!",$A.get("$Label.c.CanteenBookingSuccess2"),"success");
                helper.helperInit(component, event, helper);                                                              
            }
            else
            {
                helper.ToastMethod("Error!",$A.get("$Label.c.CanteenBookingError1"),"error")
            }
 			component.set("v.Spinner",false);
        });
         $A.enqueueAction(action);
	},
    helperBookingDetails : function(component, event, helper, row) {
        component.set("v.Spinner",true);
		var action = component.get('c.fetchBookingDetails');           
        action.setParams({
            'searchDate': component.get("v.selectedDate"),
            'slot': row.slot
          });   
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                //alert(JSON.stringify(response.getReturnValue()));
                if(response.getReturnValue().length>0)
                {
                    component.set("v.showBookings",true);
                    component.set("v.bookingList",response.getReturnValue());
                }
                else
                    helper.ToastMethod("Sorry!",$A.get("$Label.c.CanteenBookingError3"),"error")
            }
            else
            {
                helper.ToastMethod("Error!",$A.get("$Label.c.CanteenBookingError1"),"error")
            }
 			component.set("v.Spinner",false);
        });
         $A.enqueueAction(action);
	},
    helperRemoveGuestBooking : function(component, event, helper, row) {
        component.set("v.Spinner",true);
		var action = component.get('c.removeGuestBooking');           
        action.setParams({
            'searchDate': component.get("v.selectedDate"),
            'slot': row.slot
          });   
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                helper.ToastMethod("Success!",$A.get("$Label.c.CanteenBookingSuccess2"),"success");
                helper.helperInit(component, event, helper);                                                              
            }
            else
            {
                helper.ToastMethod("Error!",$A.get("$Label.c.CanteenBookingError1"),"error")
            }
 			component.set("v.Spinner",false);
        });
         $A.enqueueAction(action);
	},
    ToastMethod : function(title,message,type) {
		 var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": title,
                        "message": message,
                        "type":type
                    });
                    toastEvent.fire();
	}
})