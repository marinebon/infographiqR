// !preview r2d3 data=read.csv("svg/svg_elements.csv", strip.white=T), svg = "svg/overview.svg"

// define div for tooltip
var tooltip_div = d3.select("body").append("div")
  .attr("class", "tooltip")
  .style("opacity", 0);

d3.svg(options.svg).then((f) => {
  // https://gist.github.com/mbostock/1014829#gistcomment-2692594
  
  var f_child = svg.node().appendChild(f.documentElement);
  var h = d3.select(f_child);
  
  // resize
  h.attr('width', '100%')
   .attr('height', '100%');
   
  // default questions to hide
  svg.select("#questions")
    .attr("display", "none");

  if (options.debug){ 
    console.log('test before data.forEach');
  }
  
  // assign links
  data.forEach(function(d) {
    if (options.debug){ 
      console.log('test in data.forEach');
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
    
    // handle events
    h.selectAll('#' + d.id)
      .on("click", function() {
        //debugger;
        
        if (d.link_nonmodal > ''){
          window.location = d.link_nonmodal;
        } else {
          
          if (options.debug){ 
            console.log('  link_modal:' + d.id);
          }
          
          $('#'+ options.modal_id).find('iframe')
            .prop('src', function(){ return d.link_modal });
          
          $('#'+ options.modal_id + '-title').html( d.title );
          
          $('#'+ options.modal_id).on('show.bs.modal', function () {
            $('.modal-content').css('height',$( window ).height()*0.9);
            $('.modal-body').css('height','calc(100% - 65px - 55.33px)');
          });
          
          $('#'+ options.modal_id).modal();
        }
      })
     //.on('mouseover', handleMouseOver)
     //.on('mouseout', handleMouseOut);
     .on('mouseover', function() {
       if (options.debug){ 
        console.log('  mouseover():' + d.id);
       }
       
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
     })
     .on('mouseout', function() {
       if (options.debug){ 
        console.log('  mouseout():' + d.id);
       }
       
       d3.select(this)
        .style("fill", options.color_default)
        .style("stroke-width", 0);
        
       tooltip_div.transition()
        .duration(500);
       tooltip_div.style("opacity", 0);
       //unhighlight();
     });

  }); // end: data.forEach()
});


// show/hide questions
d3.select("#ckbox_questions").on("change", function() {
  display = this.checked ? "inline" : "none";
  
  svg.select("#questions")
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
     




