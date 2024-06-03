### Processing of PERIPrem data

## Collection of data

The data files from the trusts in the Health Innovation South West (HISW) and 
Health Innovation West of England (HIWoE) footprints should be set through in 
one batch prior to the data validation date, however this is rarely the case, 
so some curation will be required. 

Once these files have been received they should be stored on the sharepoint for
HISW in the following location 

**14 Evaluation & Learning/External Commissions/00. Archive/PERIPrem/Optimisation Tool/Trust/`YYYY`/`MM. MMM YY`/Input**

where YYYY is the year and MM. MMM YY is the month number, month abbreviated name and two digit year

e.g.

14 Evaluation & Learning/External Commissions/00. Archive/PERIPrem/Optimisation Tool/Trust/2024/03. MAR 24/Input

In addition to the optimisation tools there should be two additional files in the folder. 

**PERIPrem CheckSum.xlsx**

which is a tally of which files have been received from each trust

|Trust|Mar-24|
|:----|:-----|
|GLO|Received|
|GWH|Received|
|MUS|Received|
|NBT|Missing|
|RCHT|Received|
|RDUE|Received|
|RDUN|Missing|
|RUH|Received|
|TOR|Updated|
|UHBW|Received|
|UHP|Updated|
|YEO|Received|

and **HISTORIC_`MMM_YYYY`.CSV**

where MMM is the abbreviated month name and YYYY is the year, for example HISTORIC_FEB_2024.CSV, this files 
contains all the historic data as at the time of the previous month's processing of the PERIPrem data.

## Initial set up

All the files in the relevant sharepoint directory for the month being processed should be downloaded 
and moved into the PERIPrem reporting input directory. The optimisation tools should go into a subdirectory, 
normally named **original** and the other two files go into the main **input** directory

e.g. 

+ C:/RWorkspace/periprem_reporting/input for the checksum and historic data and
+ C:/RWorkspace/periprem_reporting/input/original for the optimisation tools

## Validation

Open RStudio and open the **periprem_reporting** project, and open the **validate_and_import_periprem_data.R** script

Ensure the lines 18 to 21 all point to the correct directory and file locations and the month is the correct month

e.g. when processing March 2024 data the lines should be as follows

+ `fil_historic <- './input/HISTORIC_FEB_2024.CSV'`
+ `dt_month <- as.Date('2024-03-01')`
+ `dir_input <- './input/original'`
+ `dir_output <- './output'`

## Post Validation

Dependent on how many error are present in the file a number of files will be created in the **output** directory

+ HISTORIC_MMM_YYYY.csv which contains all the historic data up to and including the current month (where MMM is the abbreviated month name and YYYY the year)
+ process.log which contains the number of valid and invalid lines in each of the trust optimisation tool files
+ TRUST_MMM_YYYY_ERR.csv which is a file created for each trust whose optimisation tool has errors, that details the line of the error and the validation rule(s) which the entry failed

The HISTORIC_MMM_YYYY.csv should be uploaded to the sharepoint directory for the next month and the process log and error logs should be emailed to the PERIPrem project managers at HISW and HIWoE

## Validation Updates

During the week after validation the trusts have the opportunity to correct their submissions, if no corrections are forthcoming the 
invalid entries will not form part of the final reporting

## Report Creation

Open the **`create_periperm_pdf_outputs.ini`** file and check that lines 2 to 8 point to the correct files and directories and the
month is correct. Below is an example of the ini file entries for March 2024 (NB: the format of the month should be in the YYYY-MM-DD format)

+ [Inputs]
+ locations=C:/rworkspace/periprem_reporting/files/trusts.csv
+ data=c:/rworkspace/periprem_reporting/output/HISTORIC_MAR_2024.csv
+ month=2024-03-01
+ infographic=c:/rworkspace/periprem_reporting/files/PERIPrem.pdf
+ [Outputs]
+ dir=./output

This will create a number of PDF files