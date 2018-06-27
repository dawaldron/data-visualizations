# medicaid recipients

This is a quick project analyzing employment status and disabilities among Medicaid clients. Write-up posted here: https://www.waldrn.com/2018-winter-storms/.

**usa_00099.csv** This file was extracted from IPUMS-USA. Variables used are AGE, EMPSTAT, INCSUPP, DIFFREM, DIFFPHYS, DIFFMOB, DIFFCARE, DIFFSENS, DIFFEYE, DIFFHEAR. Cases where HINSCAID == 2 (Has insurance through Medicaid). 

**medicaid.R** Reads the data and calculates the output files for d3 visualizations.

**index.html** and **medicaid.js** draw the charts. See link above for live demo.