---
editor_options: 
  markdown: 
    wrap: 72
---

# Processing of PERIPrem data

## Inputs

### Create folder on sharepoint

The data files from the trusts in the Health Innovation South West
(HISW) and Health Innovation West of England (HIWoE) footprints should
be set through in one batch prior to the data validation date, however
this is rarely the case, so some curation will be required.

Once these files have been received they should be stored on the
sharepoint for HISW in the following location

`14 Evaluation & Learning/External Commissions/00. Archive/PERIPrem/Optimisation Tool/Trust/YYYY/MM. MMM YY/Input`

where YYYY is the year and MM. MMM YY is the month number, month
abbreviated name and two digit year

e.g.

`14 Evaluation & Learning/External Commissions/00. Archive/PERIPrem/Optimisation Tool/Trust/2024/03. MAR 24/Input`

### Move data from email into input folder

The files received via email should be moved to the newly created input
folder. There shouldn't be multiple updates during the processing period
be there alway are so be prepared to overwrite and re-run the processing
as and when files are drip fed in.

The files should be renamed to the following format

`MMM YYYY - TTT[T].xlsx`

where MMM is the abbreviated month name e.g. AUG and YYYY is the four
digit year and TTT[T] is the abbreviated Trust name as follows

-   GLO - Gloucestershire Hospitals NHS FT
-   GWH - Great Western Hospitals NHS FT
-   MUS - Somerset NHS FT (Musgrove Park)
-   NBT - North Bristol NHS Trust
-   RCHT - Royal Cornwall Hospitals NHS Trust
-   RDUE - Royal Devon University Healthcare NHS FT (Exeter)
-   RDUN - Royal Devon University Healthcare NHS FT (North Devon)
-   RUH - Royal United Hospitals Bath NHS FT
-   TOR - Torbay and South Devon Hospital NHS FT
-   UHBW - University Hospitals Bristol and Weston NHS FT
-   UHP - University Hospitals Plymouth NHS Trust
-   YEO - Somerset NHS FT (Yeovil)

### Move previous output file into input folder

The previous month's final output file should be saved in the sharepoint
folder for the previous month in the output folder and should be called

`OUTPUT_PERIPrem_data.csv`

Copy this into the input folder of the current month

### Move previous checksum file into input folder and update

Copy the previous months checksum file into the current months output
folder on sharepoint, the file should be called

`PERIPrem CheckSum.xlsx`

Update the checksum file according to the files Missing, Received or
Updated

## Validate data

### Move input data to local directory

The files are all set up correctly on sharepoint so now download to the
local input folder in `.\periprem\_reporting\input\`

### Clear output directory

Ensure the output directory is empty

### Run validation

Before running the `validate_and_import_periprem_data.R` script check
the file locations are correct

```         
fil_historic <- './input/OUTPUT_PERIPrem_data.csv'
dir_input <- './input/'
dir_output <- './output'
```

If they are then run the `validate_and_import_periprem_data.R` script

This process will be repeated as and when additional data is received

### Report validation

Send an email to the HIWoE and HISW contacts with the `_ERR.csv` files
and the `process.log` file from the output directory and a copy of the
checksum table from the `PERIPrem CheckSum.xlsx` in the `.\input`
directory

## Final Processing

### Move data from email into input folder

The updated files received via email should be moved to the input folder.
These updates should be for those trusts that had submission errors identified
in the previous validation set but invariably there will be new files and as
such please refer to the first section.

### Move previous checksum file into input folder and update

Update the checksum file according to the files Missing, Received or
Updated. Once the files have been updated on the sharepoint input folder 
download a copy to your local folder for processing.

### Run validation

As before

### Run validation

As before

### Report validation

As before

## Report creation

### Run the PDF report creation script

Check the `[Inputs]` section of the `create_periprem_pdf_outputs.ini` file and 
ensure the *data* section points to the newly created PERIPrem_data.csv in the
output folder and that *month* section refers to the correct month.

Run the `create_periprem_pdf_outputs.R` script which will create all the PDF 
files


------------------------------------------------------------------------

# END OF CURRENT INSTRUCTION SET

## Process data

Once the validated

The data files from the trusts in the Health Innovation South West
(HISW) and Health Innovation West of England (HIWoE) footprints should
be set through in one batch prior to the data validation date, however
this is rarely the case, so some curation will be required.

Once these files have been received they should be stored on the
sharepoint for HISW in the following location

**14 Evaluation & Learning/External Commissions/00.
Archive/PERIPrem/Optimisation Tool/Trust/`YYYY`/`MM. MMM YY`/Input**

where YYYY is the year and MM. MMM YY is the month number, month
abbreviated name and two digit year

e.g.

14 Evaluation & Learning/External Commissions/00.
Archive/PERIPrem/Optimisation Tool/Trust/2024/03. MAR 24/Input

In addition to the optimisation tools there should be two additional
files in the folder.

**PERIPrem CheckSum.xlsx**

which is a tally of which files have been received from each trust

| Trust | Mar-24   |
|:------|:---------|
| GLO   | Received |
| GWH   | Received |
| MUS   | Received |
| NBT   | Missing  |
| RCHT  | Received |
| RDUE  | Received |
| RDUN  | Missing  |
| RUH   | Received |
| TOR   | Updated  |
| UHBW  | Received |
| UHP   | Updated  |
| YEO   | Received |

and **HISTORIC\_`MMM_YYYY`.CSV**

where MMM is the abbreviated month name and YYYY is the year, for
example HISTORIC_FEB_2024.CSV, this files contains all the historic data
as at the time of the previous month's processing of the PERIPrem data.

## Initial set up

All the files in the relevant sharepoint directory for the month being
processed should be downloaded and moved into the PERIPrem reporting
input directory. The optimisation tools should go into a subdirectory,
normally named **original** and the other two files go into the main
**input** directory

e.g.

-   C:/RWorkspace/periprem_reporting/input for the checksum and historic
    data and
-   C:/RWorkspace/periprem_reporting/input/original for the optimisation
    tools

## Validation

Open RStudio and open the **periprem_reporting** project, and open the
**validate_and_import_periprem_data.R** script

Ensure the lines 18 to 21 all point to the correct directory and file
locations and the month is the correct month

e.g. when processing March 2024 data the lines should be as follows

-   `fil_historic <- './input/HISTORIC_FEB_2024.CSV'`
-   `dt_month <- as.Date('2024-03-01')`
-   `dir_input <- './input/original'`
-   `dir_output <- './output'`

## Post Validation

Dependent on how many error are present in the file a number of files
will be created in the **output** directory

-   HISTORIC_MMM_YYYY.csv which contains all the historic data up to and
    including the current month (where MMM is the abbreviated month name
    and YYYY the year)
-   process.log which contains the number of valid and invalid lines in
    each of the trust optimisation tool files
-   TRUST_MMM_YYYY_ERR.csv which is a file created for each trust whose
    optimisation tool has errors, that details the line of the error and
    the validation rule(s) which the entry failed

The HISTORIC_MMM_YYYY.csv should be uploaded to the sharepoint directory
for the next month and the process log and error logs should be emailed
to the PERIPrem project managers at HISW and HIWoE

## Validation Updates

During the week after validation the trusts have the opportunity to
correct their submissions, if no corrections are forthcoming the invalid
entries will not form part of the final reporting

## Report Creation

Open the **`create_periperm_pdf_outputs.ini`** file and check that lines
2 to 8 point to the correct files and directories and the month is
correct. Below is an example of the ini file entries for March 2024 (NB:
the format of the month should be in the YYYY-MM-DD format)

-   [Inputs]
-   locations=C:/rworkspace/periprem_reporting/files/trusts.csv
-   data=c:/rworkspace/periprem_reporting/output/HISTORIC_MAR_2024.csv
-   month=2024-03-01
-   infographic=c:/rworkspace/periprem_reporting/files/PERIPrem.pdf
-   [Outputs]
-   dir=./output

This will create a number of PDF files
