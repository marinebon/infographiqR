// !preview r2d3 data=read.csv("svg/svg_elements.csv", strip.white=T), svg = "svg/overview.svg"

//var d3 = d3v5;

// define div for tooltip
var tooltip_div = d3.select("body").append("div")
  .attr("class", "tooltip")
  .style("opacity", 0);

/*
d3.xml(options.svg_url_pfx + options.svg)
  .then(data => {
    div.node().append(data.documentElement);
  });
*/

//d3.svg(options.svg_url_pfx + options.svg).then((f) => {
  // https://gist.github.com/mbostock/1014829#gistcomment-2692594
  
//  var f_child = div.node().appendChild(f.documentElement);
d3.xml(options.svg_url_pfx + options.svg).then((f) => {
  // https://gist.github.com/mbostock/1014829#gistcomment-2692594
  
  var f_child = div.node().appendChild(f.documentElement);
  var h = d3.select(f_child);
  //var h = div.select("svg");
  
  //var svg_el = document.getElementById('scene').appendChild(xml.documentElement);
  //  d3.select(svg_el).attr('width', '100%');
  //  d3.select(svg_el).attr('height', '100%');
  
  // resize
  h.attr('width', width)
    .attr('height', height);
     
    // default questions to hide
  div.select("#questions")
    .attr("display", "none");
  
  if (options.debug){ 
    console.log('test before data.forEach');
  }
  
  // assign links
  data.forEach(function(d) {
    if (options.debug){ 
      console.log('forEach d.id: ' + d.id);
    }
    
    // reset fill in group id and children
    h.selectAll('#' + d.id)
      .style('fill', options.color_default)
      .selectAll('g')
        .style('fill', null)
        .selectAll('path')
          .style('fill', null); 
    h.selectAll('#' + d.id + ' > path')
      .style('fill', null);
    
    function handleClick(){
      if (d.notmodal > ''){
        window.location = d.link;
      } else {
        
        if (options.debug){ 
          console.log('  link:' + d.link);
        }
        
        $('#'+ options.modal_id).find('iframe')
          .prop('src', function(){ return d.link });
        
        $('#'+ options.modal_id + '-title').html( d.title );
        
        $('#'+ options.modal_id).on('show.bs.modal', function () {
          $('.modal-content').css('height',$( window ).height()*0.9);
          $('.modal-body').css('height','calc(100% - 65px - 55.33px)');
        });
        
        $('#'+ options.modal_id).modal();
      }
    }
    
    function handleMouseOver(){
      if (options.debug){ 
          console.log('  mouseover():' + d.id);
      }
       
      d3.select(this)
        //d3.select('#' + d.id)
        .style("fill", options.color_hover)
        .style("stroke", options.color_hover)
        .style("stroke-width", 1);
      
      tooltip_div.transition()
        .duration(200)
        .style("opacity", 0.9);
      tooltip_div.html(d.title + "<br/>") //  + d.status_text)
        .style("left", (d3.event.pageX) + "px")
        .style("top", (d3.event.pageY - 28) + "px");
    }
    
    function handleMouseOut(){
      if (options.debug){ 
          console.log('  mouseout():' + d.id);
        }
        
        d3.select(this)
          //d3.select('#' + d.id)
          .style("fill", options.color_default)
          .style("stroke-width", 0);
        
        tooltip_div.transition()
          .duration(500);
        tooltip_div.style("opacity", 0);
    }
    
    function handleListMouseOver(){
      if (options.debug){ 
          console.log('  mouseover():' + d.id);
      }
       
      d3.select('#' + d.id)
        .style("fill", options.color_hover)
        .style("stroke", options.color_hover)
        .style("stroke-width", 1);
      
      tooltip_div.transition()
        .duration(200)
        .style("opacity", 0.9);
      tooltip_div.html(d.title + "<br/>") //  + d.status_text)
        .style("left", (d3.event.pageX) + "px")
        .style("top", (d3.event.pageY - 28) + "px");
    }
    
    // handle events
    //#seabirds
    //document.querySelector("#htmlwidget-a327e317cc18a3234bdd").shadowRoot.querySelector("#seabirds")
    h.select('#' + d.id)
      .on("click", handleClick)
      .on('mouseover', handleMouseOver)
      .on('mouseout', handleMouseOut);
      
    // append to list infographic elements
    list_text = d.label ? d.label : d.id;  // fall back on id if label not set
    d3.select("#svg_id_list")
      .append("li").append("a")
        .text(list_text)
        .on("mouseover", handleListMouseOver)
        .on("mouseout", handleMouseOut)
        .on("click", handleClick);
  
  
  }); // end: data.forEach()
});

// move modal outside problematic children in layout 
// so modal not obscured by <div class="modal-backdrop fade in"></div>
// solution: https://github.com/twbs/bootstrap/issues/23916#issuecomment-476794355
$('#'+ options.modal_id).appendTo('body');

// show/hide questions
d3.select("#ckbox_questions").on("change", function() {
  display = this.checked ? "inline" : "none";
  
  div.select("#questions")
    .attr("display", display);
    
});

/*
d3.selectAll("[name=ckbox_questions]").on("change", function() {
  var selected = this.value;
  //opacity = this.checked ? 1 : 0;

  svg.selectAll(".dot")
    .filter(function(d) {return selected == d.holWkend;})
    .style("opacity", opacity);
}); 
*/

// handle event functions
/*
function handleMouseOver(d, i) {
  d3.select(this)
    .style("fill", options.color_hover)
    .style("stroke", options.color_hover)
    .style("stroke-width", 1);
    
  tooltip_div.transition()
    .duration(200)
    .style("opacity", 0.9);
  tooltip_div.html(d.title + "<br/>") //  + d.status_text)
    .style("left", (d3.event.pageX) + "px")
    .style("top", (d3.event.pageY - 28) + "px");
  //highlight();
}
function handleMouseOut(d, i) {
  d3.select(this)
    .style("fill", options.color_default)
    .style("stroke-width", 0);
    
  tooltip_div.transition()
    .duration(500);
  tooltip_div.style("opacity", 0);
  unhighlight();
}
*/

/*
function highlight(){
  d3.selectAll(g_children_selector).style("stroke", "white");
  d3.selectAll(g_children_selector).style("stroke-width", 1);
}
function unhighlight(){
  d3.selectAll(g_children_selector).style("stroke-width", 0);
}
*/
     




