({
    Change : function(component, event, helper) {
        var value1 = event.getSource().get("v.value");
      //  alert('value of row'+value1);
        
        if(value1==true){
            var evt = component.getEvent("sendToParent");
          //  alert('record...'+component.find("check").get("v.text"));
            evt.setParams({"checktrue" : component.find("check").get("v.text")});
            
            evt.fire();
          //  alert('fired event--'+JSON.sringify(evt));
            
        }
        
        if(value1==false){
            var evt1 = component.getEvent("sendToParent");
            evt1.setParams({"checkfalse" : component.find("check").get("v.text")});
         
            evt1.fire();
        }
    }
})