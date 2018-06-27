waffle1();
waffle2();
bar();

function waffle1() {
  var color = d3.scaleOrdinal()
    .range(["indianred","#e19d9d","#aaaaaa"]);

  var margin = {top: 30, right: 10, bottom: 40, left: 10},
      width = +d3.select("#wafflecont-1").style("width").replace("px", "");

  if (width > 400) {
    var pad   =  1, // padding between blocks (in pixels)
        size  = 8,
        row   = 5, // number of rows in each set
        height = row * (size + pad)
        labelsize = "12px";
  } else {
    var pad   =  1, // padding between blocks (in pixels)
        size  = 6,
        row   = 7, // number of rows in each set
        height = row * (size + pad)
        labelsize = "10px";
  }

  d3.csv("e.csv", function(error, totals) {
    if (error) throw error;

    totals.sort(function(a,b) { return a.EMPSTAT - b.EMPSTAT; })

    color.domain(totals.map(function(d) { return d.Emp; }));

    var data = [];

    var start = 0;
    totals.forEach(function(d, i) {
      for (var r = start; r < start + Math.round(+d.number / 100000); r++) {
        var valueList = { };
        valueList.column = Math.floor(r / row) + 1;
        valueList.row = (r % row);
        valueList.set = i;
        data.push(valueList);
      }
      start = start + Math.round(+d.number / 100000);
    });

    var svg = d3.select("#waffle-1").append("svg")
      .attr("width", width + margin.left + margin.right)
      .attr("height", height + margin.top + margin.bottom);

    var g = svg.append("g")
      .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

    g.selectAll("rect")
      .data(data).enter()
      .append("rect")
      .attr("y", function(d) { return height - d.row * (size + pad); })
      .attr("x", function(d) { return d.column * (size + pad) - (size + pad);})
      .attr("width", size)
      .attr("height", size)
      .style("fill", function(d) { return color(d.set); });

    g.selectAll("text")
      .data(totals).enter()
      .append("text")
      .attr("x", function(d) { return ((d.cumul / 100000) * (pad + size) / row) + ((d.number / 100000) * (pad + size) / (row * 2)); })
      .attr("y", height + 24)
      .style("fill", function(d) { return color(d.Emp); })
      .style("text-anchor", "middle")
      .style("font-size", labelsize)
      .style("font-weight", 400)
      .text(function(d) { return d.Emp; })

    var legend = svg.append("g")
      .attr("id", "legend1")
      .attr("transform", "translate(5,5)");

    legend.append("rect")
      .attr("y", 10)
      .attr("x", 5)
      .attr("width", size)
      .attr("height", size)
      .style("fill", "#555555");

    legend.append("text")
      .attr("y", 18)
      .attr("x", 18)
      .style("font-size", "12px")
      .style("fill", "#555555")
      .text(" = 100,000 people");
  })
}

function waffle2() {
  var color = d3.scaleOrdinal()
    .range(["indianred","#e19d9d","#aaaaaa"]);

  var margin = {top: 30, right: 10, bottom: 50, left: 10},
      width = +d3.select("#wafflecont-2").style("width").replace("px", "");

  if (width > 400) {
    var pad   =  1, // padding between blocks (in pixels)
        size  = 8,
        row   = 5, // number of rows in each set
        height = row * (size + pad)
        labelsize = "12px";
  } else {
    var pad   =  1, // padding between blocks (in pixels)
        size  = 6,
        row   = 7, // number of rows in each set
        height = row * (size + pad)
        labelsize = "10px";
  }

  d3.csv("d.csv", function(error, totals) {
    if (error) throw error;

    totals.sort(function(a,b) { return b.Disabled - a.Disabled; })

    color.domain(totals.map(function(d) { return d.Disabled; }));

    var data = [];

    var start = 0;
    totals.forEach(function(d, i) {
      for (var r = start; r < start + Math.round(+d.number / 100000); r++) {
        var valueList = { };
        valueList.column = Math.floor(r / row) + 1;
        valueList.row = (r % row);
        valueList.set = i;
        data.push(valueList);
      }
      start = start + Math.round(+d.number / 100000);
    });

    var svg = d3.select("#waffle-2").append("svg")
      .attr("width", width + margin.left + margin.right)
      .attr("height", height + margin.top + margin.bottom);

    var g = svg.append("g")
      .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

    g.selectAll("rect")
      .data(data).enter()
      .append("rect")
      .attr("y", function(d) { return height - d.row * (size + pad); })
      .attr("x", function(d) { return d.column * (size + pad) - (size + pad);})
      .attr("width", size)
      .attr("height", size)
      .style("fill", function(d) { return color(d.set); });

    g.selectAll("text.lab1")
      .data(totals).enter()
      .append("text")
      .attr("class", "lab1")
      .attr("x", function(d) { return ((d.cumul / 100000) * (pad + size) / row) + ((d.number / 100000) * (pad + size) / (row * 2)); })
      .attr("y", height + 24)
      .style("fill", function(d) { return color(d.Disabled); })
      .style("text-anchor", "middle")
      .style("font-size", labelsize)
      .style("font-weight", 400)
      .text(function(d) { return d.Disabled1; })

    g.selectAll("text.lab2")
      .data(totals).enter()
      .append("text")
      .attr("class", "lab2")
      .attr("x", function(d) { return ((d.cumul / 100000) * (pad + size) / row) + ((d.number / 100000) * (pad + size) / (row * 2)); })
      .attr("y", height + 38)
      .style("fill", function(d) { return color(d.Disabled); })
      .style("text-anchor", "middle")
      .style("font-size", labelsize)
      .style("font-weight", 400)
      .text(function(d) { return d.Disabled2; })

    var legend = svg.append("g")
      .attr("id", "legend1")
      .attr("transform", "translate(5,5)");

    legend.append("rect")
      .attr("y", 10)
      .attr("x", 5)
      .attr("width", size)
      .attr("height", size)
      .style("fill", "#555555");

    legend.append("text")
      .attr("y", 18)
      .attr("x", 18)
      .style("font-size", "12px")
      .style("fill", "#555555")
      .text(" = 100,000 people");
  })
}

function bar() {
  var color = d3.scaleOrdinal()
    .range(["#005aff","#7facff","#bbbbbb"]);

  var margin = {top: 30, right: 10, bottom: 30, left: 100},
      width = +d3.select("#barcont").style("width").replace("px", ""),
      height = 250;

  var svg = d3.select("#bar")
    .append("svg")
    .attr("width", width)
    .attr("height", height),
    gwidth = +svg.attr("width") - margin.left - margin.right,
    gheight = +svg.attr("height") - margin.top - margin.bottom,
    g = svg.append("g").attr("transform", "translate(" + margin.left + "," + margin.top + ")");

  var x = d3.scaleLinear()
    .range([0, gwidth]);
  var y = d3.scaleBand()
    .range([0, gheight])
    .padding(0.2);

  d3.csv("t.csv", function(error, csv) {
    y.domain(csv.map(function(d) { return d.Disability }));
    x.domain([
      0,
      d3.max(csv, function(d) { return +d.SSI + +d['No SSI']; })
    ]);

    var bar = g.selectAll("rect")
      .data(csv)
      .enter();

    bar.append("rect")
      .attr("class", "nssi")
      .attr("y", function(d) { return y(d.Disability); })
      .attr("x", x(0))
      .attr("width", function(d) { return x(d['No SSI']); })
      .attr("height", y.bandwidth())
      .style("fill", "indianred");

    bar.append("rect")
      .attr("class", "ssi")
      .attr("y", function(d) { return y(d.Disability); })
      .attr("x", function(d) { return x(d['No SSI']) })
      .attr("width", function(d) { return x(d.SSI); })
      .attr("height", y.bandwidth())
      .style("fill", "#e19d9d");

    var box = bar.append("g")
      .attr("class", "box")
      .attr("transform", function(d) { return "translate(" + x(0) + "," + y(d.Disability) + ")"} )
      .on("mousemove", function(d) {
        d3.select(this).select("rect").style("opacity", .3);
        d3.select(this).selectAll("text").style("opacity", 1);
      })
      .on("mouseout", function(d) {
        d3.select(this).select("rect").style("opacity", 0);
        d3.select(this).selectAll("text").style("opacity", .6);
      });

    box.append("rect")
      .attr("y", 0)
      .attr("x", 0)
      .attr("width", gwidth)
      .attr("height", y.bandwidth())
      .style("opacity", 0)
      .style("fill", "#ffffff");

    box.append("text")
      .attr("y", 16)
      .attr("x", function(d) { return x(d['No SSI'] / 2); })
      .style("fill", "#ffffff")
      .style("font-size", "12px")
      .style("text-anchor", "middle")
      .style("opacity", .6)
      .text(function(d) { if (x(d['No SSI']) > 35) {
        return d3.format(".2s")(d['No SSI']);
      } else {
        return "";
      }});

    box.append("text")
      .attr("y", 16)
      .attr("x", function(d) { return x(+d["No SSI"] + (+d.SSI / 2)); })
      .style("fill", "#ffffff")
      .style("font-size", "12px")
      .style("text-anchor", "middle")
      .style("opacity", .6)
      .text(function(d) { if (x(d.SSI) > 35) {
        return d3.format(".2s")(+d.SSI);
      } else {
        return "";
      }});

    g.append("text")
      .attr("y", 0)
      .attr("x", x(+csv[0]["No SSI"] / 2))
      .style("fill", "indianred")
      .style("font-size", "12px")
      .style("text-anchor", "middle")
      .style("font-weight", 400)
      .text("Not on SSI");

    g.append("text")
      .attr("y", 0)
      .attr("x", x(+csv[0]["No SSI"] + (csv[0].SSI / 2)))
      .style("fill", "#e19d9d")
      .style("font-size", "12px")
      .style("text-anchor", "middle")
      .style("font-weight", 400)
      .text("On SSI");

    g.append("g")
      .attr("id", "barAxis")
      .attr("class", "axis")
      .call(d3.axisLeft(y));

    g.append("g")
      .attr("id", "barAxis")
      .attr("class", "axis")
      .call(d3.axisBottom(x)
        .tickFormat(d3.format(".1s"))
        .ticks(5))
      .attr("transform", "translate(0, " + gheight + ")");
  });
}