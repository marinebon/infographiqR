// define div for tooltip
var div = d3.select("body").append("div")
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
      console.log(data.columns);

      // filter by svg
      data = data.filter(function(row) {
        return row['svg'] == svg;
      })

      // iterate over rows of svg paths
      data.forEach(function(d) {
        console.log(d);

        // color
        d3.selectAll(d.status_path)
          .style("fill", d.status_color);

        // link
        d3.selectAll(d.link_path)
          //.attr("xlink:href", d.link)
          .attr("xlink:href", './modals/' + d.svg_id + '.html')
          .attr("xlink:data-title", d.link_title)
          .attr("xlink:data-remote", "false")
          .attr("xlink:data-toggle", "modal")
          .attr("xlink:data-target", "#myModal")
          .on("mouseover", function(x) {
            div.transition()
              .duration(200)
              .style("opacity", .9);
            div.html(d.link_title + "<br/>"  + d.status_text)
              .style("left", (d3.event.pageX) + "px")
              .style("top", (d3.event.pageY - 28) + "px");
            })
          .on("mouseout", function(d) {
            div.transition()
            .duration(500)
            div.style("opacity", 0);
          });
      }); // end: data.forEach()
    }); // end: d3.csv()
});

