({
  render: function(component, helper) {
    // By default, after the component finished loading data/handling events,
    // it will call this render function this.superRender() will call the
    // render function in the parent component.
    var ret = this.superRender();

    // Calls the helper function to append the SVG icon
    //helper.renderIcon(component);
    return ret;
  },
  afterRender: function(component, helper) {
      var svg1 = component.get("v.svgFlag");
      if(svg1 === 'info'){
        var svg = component.find("svg_content1");
        var svgDiv = svg.getElement();
        var val = svgDiv.innerText;
        if (typeof val !== 'undefined') {
            val = val.replace("<![CDATA[", "").replace("]]>", "");
            svgDiv.innerHTML = val;
        }
      }
      
      if(svg1 === 'faq'){
        var svg = component.find("svg_content2");
        var svgDiv = svg.getElement();
        var val = svgDiv.innerText;
        if (typeof val !== 'undefined') {
            val = val.replace("<![CDATA[", "").replace("]]>", "");
            svgDiv.innerHTML = val;
        }
      }
      
      if(svg1 === 'req'){
        var svg = component.find("svg_content3");
        var svgDiv = svg.getElement();
        var val = svgDiv.innerText;
        if (typeof val !== 'undefined') {
            val = val.replace("<![CDATA[", "").replace("]]>", "");
            svgDiv.innerHTML = val;
        }
      }
      
      if(svg1 === 'app'){
        var svg = component.find("svg_content4");
        var svgDiv = svg.getElement();
        var val = svgDiv.innerText;
        if (typeof val !== 'undefined') {
            val = val.replace("<![CDATA[", "").replace("]]>", "");
            svgDiv.innerHTML = val;
        }
      }
      
  }
})