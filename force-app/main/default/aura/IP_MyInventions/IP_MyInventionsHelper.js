({
	displayobject: function (component, event, listdata) {
       // alert('inside helper');
        var disp = [];
        if(listdata!=undefined && listdata.length>0){
            debugger;
            
            var activities = listdata;
            var pageno = component.get("v.pageNumber");
            var pagesizeval = component.get("v.pageSize");
            var initialval = pageno*pagesizeval;
            var finalval = initialval+pagesizeval;
            if(finalval>=activities.length){
                component.set("v.isLastPage",true);
                finalval = activities.length;
            }else{
                component.set("v.isLastPage",false);
            }
            for(var i=initialval; i<finalval; i++){
                disp.push(activities[i]);
            }
            component.set("v.maxsize", finalval);
            component.set("v.FilteredData", disp);
        }else{
            component.set("v.FilteredData", disp);
        }
    },
    sortData: function (component, fieldName, sortDirection) {
        var data = component.get("v.FilteredData");
        var res;
        var reverse = sortDirection !== 'asc';
        data.sort(this.sortBy(fieldName, reverse))
        component.set("v.FilteredData", data);
    },
    sortBy: function (field, reverse, primer) {
        var key = primer ?
            function(x) {return primer(x[field])} :
        function(x) {return x[field]};
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
            return a = key(a), b = key(b), reverse * ((a > b) - (b > a));
        }
    },
})