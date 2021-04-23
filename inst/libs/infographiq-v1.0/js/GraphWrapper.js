    function GraphWrapper({Google_Spreadsheet_Link, threshold_year = 2011, targetElement = 'chart_div', 
      YAxisTitle = "Y Axis Title", YAxisTitle2 = "Second Y Axis", twoYAxes = false, SST = false} = {}) {

      var query = new google.visualization.Query(Google_Spreadsheet_Link);
      query.send(handleQueryResponse);

      function handleQueryResponse(response) {

        var GoogleData = response.getDataTable();
        var maxValue = 0;
        var minValue = 10000;

        var original_col_number = GoogleData.getNumberOfColumns();
        for (let i = 1; i < original_col_number; i++){
          if (maxValue < GoogleData.getColumnRange(i).max){
            maxValue = GoogleData.getColumnRange(i).max;
          }
          if (minValue > GoogleData.getColumnRange(i).min){
            minValue = GoogleData.getColumnRange(i).min;
          }

        }
        maxValue = maxValue*1.1;
        minValue = minValue*0.9;

        minValue = 0;

        GoogleData.addColumn('number','Background');
        GoogleData.addColumn( {role: 'style', type: 'string'});
        GoogleData.addColumn( {role: 'annotation', type: 'string'});

        var beginning_row = 0;

        var annotation_text = "Trends since " + threshold_year;

        if (SST == false){
          year_format = "####";
          var beginning_year = GoogleData.getColumnRange(0).min; 
          if (beginning_year <= threshold_year) {
              beginning_row = GoogleData.getFilteredRows([{column: 0, minValue: threshold_year}])[0];
          }
          else {
            annotation_text = "Trends since " + beginning_year;
          }
        }
        else{
          year_format = null;
          var thisYear = 0;
          do {
            beginning_row = beginning_row + 1;
            thisYear = GoogleData.getValue(beginning_row, 0).getYear() + 1900;
          } while (thisYear < threshold_year);
        }

        var ending_row = GoogleData.getNumberOfRows();

        var columnNumber = GoogleData.getNumberOfColumns() - 1;

        for (let i = beginning_row; i < ending_row; i++) {
          GoogleData.setCell(i, columnNumber - 2, maxValue);  
          GoogleData.setCell(i, columnNumber - 1, 'stroke-width: 0;');
        }

        var annotation_row = Math.round((ending_row - beginning_row)/2) + beginning_row ;

        GoogleData.setCell(annotation_row, columnNumber, annotation_text);

        column_format =[];

        for (let i = 1; i < (columnNumber - 2); i++) {column_format.push({});}
        column_format.push({type: "area", color: 'CornflowerBlue', visibleInLegend: false});

        var options = {
          tooltip: {textStyle: {fontSize: 15}},
          annotations: {stem: {length: 0}, 
            textStyle: {
              bold: false,
              fontSize: 15,
              italic: false,
              color: 'black',
              opacity: 1.0
            }
          },
          legend: {position: 'bottom', textStyle: {fontSize: 15}} , 
          chartArea: {width: '80%', top: 10, height: '80%'},
          animation: {startup: true, duration:500}, // animate the graph
          height: 400, // make the graph 400 pixels high
          seriesType: 'line',//
          series: column_format,
          hAxis: { // options for the X Axis
              title: "Year", // Set the X Axis title
              format: year_format,
              textStyle: {fontSize: 15},
              gridlines: {color: 'transparent'}, // no X Axis gridlines
              titleTextStyle: {bold: true, italic: false, fontSize: 15}}, // Set how the X Axis title looks
          vAxis: {  // options for the Y Axis
              viewWindow: {max: maxValue, min: minValue}, 
              title: YAxisTitle,  // Set the Y Axis title
              textStyle: {fontSize: 15},
              titleTextStyle: {bold: true, italic: false, fontSize: 15}, // Set how the Y Axis title looks
              minorGridlines: {color: 'transparent'}} // No minor Y Axis gridlines
          };

        if (twoYAxes == true) {
          options.chartArea = {width: '70%', top: 10, height: '80%'};
          options.series = {
            0: {targetAxisIndex: 0},
            1: {targetAxisIndex: 1},
            2: {targetAxisIndex: 0, type: "area", color: 'CornflowerBlue', visibleInLegend: false}};
          options.vAxes = {
            textStyle: {fontSize: 15},
            0: {title: YAxisTitle, viewWindow: {max: maxValue, min: minValue}},
            1: {title: YAxisTitle2}};
          options.vAxis = {titleTextStyle: {bold: true, italic: false, fontSize: 15 },
            minorGridlines: {color: 'transparent'}};
        }
        // Create a line chart (note the use of LineChart in the command) and put that in the div element 'chart_div'
        var chart = new google.visualization.LineChart(document.getElementById(targetElement));

        // Create the graph using the options that we set above
        chart.draw(GoogleData, options);
      }
    }