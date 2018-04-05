drawLegend("#map1");
drawLegend("#map2");
drawLegend("#map3");
drawLegend("#map4");
drawLegend("#map5");
drawLegend("#map6");
drawLegend("#map7");

function drawLegend(divID) {
  var legend = d3.selectAll(divID)
    .append("div").attr("class", "legend");

  var margin = {
        top: 15,
        right: 100,
        bottom: 0,
        left: 100
      },
      width = +legend.style("width").replace("px","") - margin.left - margin.right,
      height = 20;

  var stops = [0,1,3,6,9,12,24]

  var colorScale = d3.scaleLinear()
    .range(['#FFFFFF','#ffffcc','#c7e9b4','#7fcdbb','#41b6c4','#2c7fb8','#253494'])
    .domain(stops);

  var x = d3.scaleLinear()
    .rangeRound([0, width])
    .domain([0,24]);

  var svg = legend.append("svg")
    .attr("width", width + margin.left + margin.right)
    .attr("height", height + margin.top + margin.bottom);

  var g = svg.append("g")
    .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

  var defs = svg.append("defs");

  var linearGradient = defs.append("linearGradient")
      .attr("id", "linear-gradient");

  linearGradient
      .attr("x1", "0%")
      .attr("y1", "0%")
      .attr("x2", "100%")
      .attr("y2", "0%");

  linearGradient.selectAll("stop")
    .data(stops)
    .enter().append("stop") 
      .attr("offset", function(d) { return (Math.round(100 * d / 24) + "%"); })   
      .attr("stop-color", function(d) { return colorScale(d); });

  g.append("rect")
    .attr("width", width)
    .attr("height", 6)
    .style("fill", "url(#linear-gradient)");

  g.append("g")
    .attr("class", "axis")
    .call(d3.axisBottom(x)
      .tickValues(stops))
      .select(".domain").remove();

  g.select("g.axis")
    .append("text")
    .attr("x", width / 2)
    .attr("y", -5)
    .style("text-anchor", "middle")
    .text("snow accumulation (inches)")
}