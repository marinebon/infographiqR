// !preview r2d3 data=read.csv("svg/svg_elements.csv", strip.white=T), svg = "svg/overview.svg"

var d3 = d3v5;

// define div for tooltip
var tooltip_div = d3.select("body").append("div")
  .attr("class", "tooltip")
  .style("opacity", 0);

d3.svg(options.svg_url_pfx + options.svg).then((f) => {
  // https://gist.github.com/mbostock/1014829#gistcomment-2692594
  
  var f_child = svg.node().appendChild(f.documentElement);
  var h = d3.select(f_child);
  
  // resize
  //h.attr('width', '100%')
  // .attr('height', '100%');
  h.attr('width', width)
   .attr('height', height);
   
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
    
    var id_selector = '#' + d.id // + ' > path, #' + d.id;
    // d3.select("#seabirds, #seabirds > path").style("fill", "yellow")
    
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
      d3.selectAll(id_selector)
        .style("fill", options.color_visited);
    }
    
    function handleMouseOver(){
      if (options.debug){ 
        console.log('  mouseover():' + d.id);
      }
      
      //d3.select(this) 
      d3.selectAll(id_selector)
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
       
      //sd3.select(this)
      d3.selectAll(id_selector)
        .style("fill", options.color_default)
        .style("stroke-width", 0);
        
      tooltip_div.transition()
        .duration(500);
      tooltip_div.style("opacity", 0);
    }
    
    // handle events
    h.selectAll('#' + d.id)
      .on("click", handleClick)
      .on('mouseover', handleMouseOver)
      .on('mouseout', handleMouseOut);

    // create list of species in the infographic
    list_text = d.label ? d.label : d.id;  // fall back on id if label not set
    d3.select("#svg_id_list")
      .append("li").append("a")
        .text(list_text)
        .on("mouseover", handleMouseOver)
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
  
  svg.select("#questions")
    .attr("display", display);
    
});





