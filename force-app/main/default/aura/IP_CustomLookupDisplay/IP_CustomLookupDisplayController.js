({
    selectRecord : function(component, event, helper){      
        // get the selected record from list  
        var getSelectRecord;
        if(component.get("v.oRecord"))
        {
            getSelectRecord = component.get("v.oRecord");
            var compEvent = component.getEvent("oSelectedRecordEvent");
            // set the Selected sObject Record to the event attribute.  
            compEvent.setParams({"recordByEvent" : getSelectRecord });  
            // fire the event  
            compEvent.fire();
        }else if(component.get("v.childRecord"))
        {
            getSelectRecord = component.get("v.childRecord");
            var compEvent = component.getEvent("oSelectedRecordEvent");
            // set the Selected sObject Record to the event attribute.  
            compEvent.setParams({"recordByEvent" : getSelectRecord });  
            // fire the event  
            compEvent.fire();
        }else if(component.get("v.userRecord"))
        {
            getSelectRecord = component.get("v.userRecord");
            console.log('Select Record', JSON.stringify(getSelectRecord));
            // call the event   
            var compEvent = component.getEvent("oSelectedRecordEvent1");
            // set the Selected sObject Record to the event attribute.  
            compEvent.setParams({"recordByEvent" : getSelectRecord });  
            // fire the event  
            compEvent.fire();
            
        }
    },
})