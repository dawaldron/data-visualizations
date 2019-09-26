# ActBlue data for 2020 Democratic Primary

read_actblue_data.R parses the .fec file submitted by ActBlue to the FEC with donations through July 2019. This file can be downloaded in this zip archive: https://cg-519a459a-0ea3-42c2-b7bc-fa1143481f74.s3-us-gov-west-1.amazonaws.com/bulk-downloads/electronic/20190801.zip. The ActBlue data is contained in a 5.9GB file named "1344765.fec".

tabulate_actblue_data.R creates the summaries of unique donor counts used for the charts at https://waldrn.com/candidate-support-by-occupation-in-the-2020-democratic-primary/

Counts of unique donors are based on unique combinations of first name, last name, and ZIP code. Donors who donated to multiple 2020 candidates have their support split equally among each candidate they donated to.

Job titles entered by donors are coded according to the 2010 Standard Occupational Classification system. Because job titles are often insufficient for occupational coding, some job titles are not coded and are discarded from this analysis. The main sources used for occupational coding are the BLS Direct Match Title File (DMTF) and O\*NET's Sample of Reported Job Titles data. The crosswalk that was developed and used to code the occupations is included (titleocc_xw_final.csv).

In order to increase the number of job titles that could be coded, a number of aggregations were applied to the 2010 SOC system. One example is college professors. In the SOC system, postsecondary teachers have codes that are specific to their subject areas. Because donors usually just write "college professor" without specifying a subject area or department, they are instead coded as "college professors", and all postsecondary teacher SOC codes are rolled up into this aggregated occupation. The file that defines these aggregations is included here (soc_aggregations.csv).