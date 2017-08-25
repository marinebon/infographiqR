var debug_mode = false;

// define div for tooltip
var tooltip_div = d3.select("body").append("div")
  .attr("class", "tooltip")
  .style("opacity", 0);

d3.xml(svg_path)
  .mimeType("image/svg+xml")
  .get(function(error, xml) {
    if (error) throw error;
    //document.body.appendChild(xml.documentElement);
    //d3.select("#scene").append(xml.documentElement)
    document.getElementById('scene').appendChild(xml.documentElement);

    // read csv
    d3.csv(svg_elements_csv, function(error, data) {

      if (error) throw error;

      if (debug_mode){
        console.log('all svg element csv data..');
        console.log(data);
      }
      //debugger;

      // filter by svg
      data = data.filter(function(row) {
        return row.svg == svg;
      });

      if (debug_mode){
        console.log('selected svg element csv data...');
        console.log(data);
      }

      // iterate over rows of svg paths
      data.forEach(function(d) {
        var d_path = 'g#' + d.svg_id + ' path';
        var d_link = './modals/' + d.svg_id + '.html';

        if (debug_mode){
          console.log('forEach d...' + d);
          console.log(d);
        }

        // color
        d3.selectAll(d_path)
          .style("fill", d.status_color);

        function highlight(){
          d3.selectAll(d_path).style("stroke", "white");
          d3.selectAll(d_path).style("stroke-width", 1);
        }
        function unhighlight(){
          d3.selectAll(d_path).style("stroke-width", 0);
        }

        // create list of species in the infographic
        d3.select("#svg_id_list").append("li").append("a")
          .text(d.label)
          .attr("xlink:href", d_link)
          .attr("xlink:data-title", d.label)
          .attr("xlink:data-remote", "false")
          .attr("xlink:data-toggle", "modal")
          .attr("xlink:data-target", "#myModal")
          .on("mouseover", highlight)
          .on("mouseout", unhighlight);

        // link svgs to modals
        d3.selectAll(d_path)
          .attr("xlink:href", d_link)
          .attr("xlink:data-title", d.label)
          .attr("xlink:data-remote", "false")
          .attr("xlink:data-toggle", "modal")
          .attr("xlink:data-target", "#myModal")
          .on("mouseover", function(x) {
            tooltip_div.transition()
              .duration(200)
              .style("opacity", 0.9);
            tooltip_div.html(d.label + "<br/>"  + d.status_text)
              .style("left", (d3.event.pageX) + "px")
              .style("top", (d3.event.pageY - 28) + "px");
            highlight();
          })
          .on("mouseout", function(d) {
            tooltip_div.transition()
            .duration(500);
            tooltip_div.style("opacity", 0);
            unhighlight();
          })
        ;
      }); // end: data.forEach()
    }); // end: d3.csv()
});
