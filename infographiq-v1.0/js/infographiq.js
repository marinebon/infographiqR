// append div for tooltip
var tooltip_div = d3.select("body").append("div")
  .attr("class", "tooltip")
  .style("opacity", 0);

// append div for modal
function appendHtml(el, str) {
  var div = document.createElement('div');
  div.innerHTML = str;
  while (div.children.length > 0) {
    el.appendChild(div.children[0]);
  }
}

var modal_html = '<div aria-labelledby="modal-title" class="modal fade bs-example-modal-lg" id="modal" role="dialog" tabindex="-1"><div class="modal-dialog modal-lg" role="document"><div class="modal-content"><div class="modal-header"><button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button><h4 class="modal-title" id="modal-title">title</h4></div><div class="modal-body"><iframe data-src="" height="100%" width="100%" frameborder="0"></iframe></div><div class="modal-footer"><button class="btn btn-default btn-sm" data-dismiss="modal">Close</button></div></div></div></div>';

appendHtml(document.body, modal_html); // "body" has two more children - h1 and span.

function basename(path) {
     return path.replace(/.*\//, '');
}

// main function to link svg elements to modal popups with data in csv
function link_svg({svg, csv, svg_location, csv_location, debug = false, 
  hover_color = 'yellow', width = '100%', height = '100%', modal_id = 'modal', 
  modal_url_pfx, 
  text_list = "list", colored_sections = false, 
  section_colors = ['LightGreen', 'MediumOrchid', 'Orange'], text_toggle = false} = {}) {
  
  d3.xml(svg).then((f) => {
    
    var div = d3.select('#' + svg_location);
  
    var f_child = div.node().appendChild(f.documentElement);
    
    // get handle to svg
    var h = d3.select(f_child);
    
    // full size
    h.attr('width', width)
     .attr('height', height);
    
    if (debug){ 
      console.log('before data.forEach');
    }
  
    if (text_toggle === true){

      function toggleText(){
        display = d3.select("#" + csv_location + "Checkbox").property("checked") ? "inline" : "none";
        d3.select("#" + svg_location).select("#text").attr("display", display);
      }

      d3.select("#" + csv_location).append("span")
        .text("Text in image: ")
        .attr("font-weight", "bold")
        .attr("id", csv_location + "Wrapper");

      d3.select("#" + csv_location  + "Wrapper").append("label")
        .attr("id", csv_location + "Toggle")
        .attr("class", "switch");

      d3.select("#" + csv_location + "Toggle").append("input")
        .attr("id", csv_location + "Checkbox")
        .attr("type", "checkbox")
        .on("change", toggleText);

      d3.select("#" + csv_location + "Toggle").append("span")
        .attr("class", "slider");      

    }

    d3.csv(csv).then(function(data) {
  
      if (text_list === "accordion" | text_list === "sectioned_list"){
        data = data.sort(
          function(a,b) { return d3.ascending(a.section, b.section) ||  d3.ascending(a.title, b.title) });
        var section_list = [];
        data.forEach(function(d) {
          if (section_list.length == 0 | section_list[section_list.length - 1] != d.section){
            section_list.push(d.section);
          }
        })
      }
      else {
        data = data.sort(
          function(a,b) { return d3.ascending(a.title, b.title) });
      }

      section_color_index = 0;
       
      if (text_list === "accordion"){

        d3.select("#" + csv_location)
            .attr("class", "panel-group")
            .attr("role", "tablist")
            .attr("aria-multiselectable", "true");
        
        for (let i = 0; i < section_list.length; i++) {
          d3.select("#" + csv_location).append("div")
            .attr("id", csv_location + "Panel" + i)
            .attr("class", "panel panel-default");
          d3.select("#" + csv_location + "Panel" + i).append("div")
            .attr("id", csv_location + "PanelSub" + i)
            .attr("class", "panel-heading")
            .attr("role", "tab");
          if (colored_sections === true){
            d3.select("#" + csv_location + "PanelSub" + i).attr("style", "background-color: " + section_colors[section_color_index] +  ";");
            section_color_index++;
            if (section_colors.length == section_color_index){section_color_index = 0;}
          }
          d3.select("#" + csv_location + "PanelSub" + i).append("h4")
            .text(section_list[i])
            .attr("id", csv_location + "PanelTitle" + i)
            .attr("class", "panel-title")
            .attr("data-toggle", "collapse")
            .attr("data-target", "#" + csv_location + "collapse" + i)
            .attr("role", "button")
            .attr("aria-controls", csv_location + "collapse" + i);
          d3.select("#" + csv_location + "Panel" + i).append("div")
              .attr("id", csv_location + "collapse" + i) 
              .attr("role", "tabpanel")
              .attr("aria-labelledby", "heading" + i);
          if (i == 0) {
            d3.select("#" + csv_location + "PanelTitle" + i).attr("aria-expanded", "true");
            d3.select("#" + csv_location + "collapse" + i) .attr("class", "panel-collapse collapse in");
          }
          else {
            d3.select("#" + csv_location + "PanelTitle" + i).attr("aria-expanded", "false");
            d3.select("#" + csv_location + "collapse" + i) .attr("class", "panel-collapse collapse");
          }
    
          d3.select("#" + csv_location + "collapse" + i).append("div")
            .attr("class", "panel-body")
            .attr("id", csv_location + "body" + i);
    
          var section_content = d3.select('#' + csv_location + 'body' + i).append('ul');
    
          data.forEach(function(d) {
            if (d.section == section_list[i]){
              section_content = icon_append(d, h, modal_url_pfx, modal_id, svg_location, hover_color, section_content, debug);
            }
          })
        }
      } //end: "accordion" text_list option
      else if (text_list === "list" | text_list === "none"){

        var section_content = d3.select('#' + csv_location).append('ul');
  
        if (text_list === "list"){text_column = true;}
        else {text_column = false;}

        data.forEach(function(d) {
          section_content = icon_append(d, h, modal_url_pfx, modal_id, svg_location, hover_color, section_content, debug, text_column);
        })
      } //end: "list" text_list option
      else if (text_list === "sectioned_list"){
        for (let i = 0; i < section_list.length; i++) {
          d3.select("#" + csv_location).append("div")
            .attr("class", "section-title")
            .attr("id", csv_location + "Section" + i)
            .text(section_list[i]);
          if (colored_sections === true){
            d3.select("#" + csv_location + "Section" + i).attr("style", "background-color: " + section_colors[section_color_index] +  ";");
            section_color_index++;
            if (section_colors.length == section_color_index){section_color_index = 0;}
          }

          var section_content = d3.select("#" + csv_location).append('ul');

          data.forEach(function(d) {
            if (d.section == section_list[i]){
              section_content = icon_append(d, h, modal_url_pfx, modal_id, svg_location, hover_color, section_content, debug);
            }
          })
        }
      } //end: "sectioned_list" text_list option
    }) // end: d3.csv().then({
  
    .catch(function(error){
      // d3.csv() error   
    }); // end: d3.csv()
    
  // turn off questions by default
  d3.select("#text").attr("display", "none");



  }); // d3.xml(svg).then((f) => {

}

function icon_append(d, h, modal_url_pfx, modal_id, svg_location, hover_color, section_content, debug, text_column = true){
            if (debug){ 
              console.log('forEach d.icon: ' + d.icon);
            }
            d.link = modal_url_pfx + d.icon + '.html';
            d.title = d.title ? d.title : d.icon;  // fall back on id if title not set
  
            function handleClick(){
              if (d.not_modal == 'T'){
                window.location = d.link;
              } else {
                
                if (debug){ 
                  console.log('  link:' + d.link);
                }
                
                // https://www.drupal.org/node/756722#using-jquery
                (function ($) {
                  $('#'+ modal_id).find('iframe')
                    .prop('src', function(){ return d.link });
                  
                  $('#'+ modal_id + '-title').html( d.title );
                  
                  $('#'+ modal_id).on('show.bs.modal', function () {
                    $('.modal-content').css('height',$( window ).height()*0.9);
                    $('.modal-body').css('height','calc(100% - 65px - 55.33px)');
                  });
                  
                  $('#'+ modal_id).modal();
                }(jQuery));
              }
            }
  
            function handleMouseOver(){
              if (debug){ 
                  console.log('  mouseover():' + d.icon);
              }
               
              d3.selectAll("#" + svg_location).select('#' + d.icon)
                .style("stroke-width", 2)
                .style("stroke", hover_color);
              
              tooltip_div.transition()
                .duration(200)
                .style("opacity", 0.8);
              tooltip_div.html(d.title + "<br/>")
                .style("left", (d3.event.pageX) + "px")
                .style("top", (d3.event.pageY - 28) + "px");
            }
  
            function handleMouseOverSansTooltip(){
              if (debug){ 
                  console.log(' handleMouseOverSansTooltip():' + d.icon);
              }
               
              d3.selectAll("#" + svg_location).select('#' + d.icon)
                .style("stroke-width", 2)
                .style("stroke", hover_color);
            }
  
            function handleMouseOut(){
              if (debug){ 
                  console.log('  mouseout():' + d.icon);
                }
                
                d3.selectAll("#" + svg_location).select('#' + d.icon)
                  .style("stroke-width",0);
      
                tooltip_div.transition()
                  .duration(500);
                tooltip_div.style("opacity", 0);
            }
  
            h.select('#' + d.icon)
              .on("click", handleClick)
              .on('mouseover', handleMouseOver)
              .on('mouseout', handleMouseOut);
  
            // set outline of paths within group to null
            d3.selectAll("#" + svg_location).select('#' + d.icon).selectAll("path")
                .style("stroke-width", null)
                .style("stroke", null);
          
            if (text_column === true){
              // add to bulleted list of svg elements
              list_text = d.title ? d.title : d.icon;  // fall back on id if title not set
              section_content.append("li").append("a")
                .text(list_text)
                .on("click", handleClick)
                .on('mouseover', handleMouseOverSansTooltip)
                .on('mouseout', handleMouseOut);
            }
            return section_content;
}
