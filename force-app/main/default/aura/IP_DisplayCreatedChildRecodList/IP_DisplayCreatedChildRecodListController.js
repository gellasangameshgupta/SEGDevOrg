({
    redirectToDetail : function(component, event, helper) {        
        var alertId =  event.getSource().get("v.class");
        var _url=window.location.href;
        if(_url!=''){
            _url= _url.substring(0,_url.indexOf("/apex"));//alert(alertId);
        }
        window.open(_url+"/"+alertId);                
        return true;
    }
})