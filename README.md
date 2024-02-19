# periprem_reporting
PERIPrem Data Processing and Reporting


### PERIPrem Optimisation Tool

#### Data Entry Column Definitions

--- 

##### **Column A:** Gestational age at birth (select range below)

**Data Validation:** `=$AL$23:$AL$27`

 - <26+6
 - 27 - 27+6
 - 28 - 29+6
 - 30 - 31+6
 - 32 - 33+6

**Conditional Formatting:** White if cell contains a value

--- 

##### **Column B:** Birth weight (g) (select range below)

**Data Validation:** `=$AL$32:$AL$34`

 - <800g
 - <1500g
 - \>1500g

**Conditional Formatting:** White if cell contains a value

---

##### **Column C:** Singleton or multiple?

**Data Validation:** `=$AL$29:$AL$30`

 - Single
 - Multiple

**Conditional Formatting:** White if cell contains a value

---

##### **Column D:** Did the baby need invasive ventilation?

**Data Validation:** `=$AL$71:$AL$72`

 - Yes
 - No
 
**Conditional Formatting:** White if cell contains a value

---

##### **Column E:** Was the baby’s mother in active labour at any point prior to delivery?

**Data Validation:** `=$AL$71:$AL$72`

 - Yes
 - No
 
**Conditional Formatting:** White if cell contains a value

---

##### **Column F:** Place of Birth - Was this baby born in an appropriate unit for gestation and birth weight?

**Data Validation:** `=$AL$71:$AL$72`

 - Yes
 - No
 
**Conditional Formatting:** 

 - Grey if 
   - `=AND(A10="27 - 27+6",C10="Single", B10="<1500g")`
   - `=AND(A10="27 - 27+6",C10="Single", B10=">1500g")`
   - `=AND(A10="28 - 29+6",C10="Single", B10="<1500g")`
   - `=AND(A10="28 - 29+6",C10="Single", B10=">1500g")`
   - `=AND(A10="30 - 31+6",C10="Single", B10="<1500g")`
   - `=AND(A10="30 - 31+6",C10="Single", B10=">1500g")`
   - `=AND(A10="32 - 33+6",C10="Single", B10="<1500g")`
   - `=AND(A10="32 - 33+6",C10="Single", B10=">1500g")`
   - `=AND(A10="28 - 29+6",C10="Multiple", B10="<1500g")`
   - `=AND(A10="28 - 29+6",C10="Multiple", B10=">1500g")`
   - `=AND(A10="30 - 31+6", C10="Multiple", B10=">1500g")`
   - `=AND(A10="30 - 31+6",C10="Multiple", B10="<1500g")`
   - `=AND(A10="32 - 33+6",C10="Multiple", B10="<1500g")`
   - `=AND(A10="32 - 33+6",C10="Multiple", B10=">1500g")`
 - White if cell contains a value

---

##### **Column G:** Did the baby's mother receive antenatal steroids?

**Data Validation:** `=$AL$71:$AL$72`

 - Yes
 - No

**Conditional Formatting:** 

 - Grey if 
   - `=AND(A10="27 - 27+6",C10="Single", B10="<1500g")`
   - `=AND(A10="27 - 27+6",C10="Single", B10=">1500g")`
   - `=AND(A10="28 - 29+6",C10="Single", B10="<1500g")`
   - `=AND(A10="28 - 29+6",C10="Single", B10=">1500g")`
   - `=AND(A10="30 - 31+6",C10="Single", B10="<1500g")`
   - `=AND(A10="30 - 31+6",C10="Single", B10=">1500g")`
   - `=AND(A10="32 - 33+6",C10="Single", B10="<1500g")`
   - `=AND(A10="32 - 33+6",C10="Single", B10=">1500g")`
   - `=AND(A10="28 - 29+6",C10="Multiple", B10="<1500g")`
   - `=AND(A10="28 - 29+6",C10="Multiple", B10=">1500g")`
   - `=AND(A10="30 - 31+6",C10="Multiple", B10="<1500g")`
   - `=AND(A10="30 - 31+6",C10="Multiple", B10=">1500g")`
   - `=AND(A10="32 - 33+6",C10="Multiple", B10="<1500g")`
   - `=AND(A10="32 - 33+6",C10="Multiple", B10=">1500g")`
 - White if cell contains a value

---

##### **Column H:** How many doses of antenatal steroids did the baby's mother receive?

**Data Validation:** `=$AL$51:$AL$53`

 - 0
 - 1
 - 2

**Conditional Formatting:** 

 - Grey if 
   - `=$G10="No"`
   - `=AND(A10="27 - 27+6",C10="Single", B10="<1500g")`
   - `=AND(A10="27 - 27+6",C10="Single", B10=">1500g")`
   - `=AND(A10="28 - 29+6",C10="Single", B10="<1500g")`
   - `=AND(A10="28 - 29+6",C10="Single", B10=">1500g")`
   - `=AND(A10="30 - 31+6",C10="Single", B10="<1500g")`
   - `=AND(A10="30 - 31+6",C10="Single", B10=">1500g")`
   - `=AND(A10="32 - 33+6",C10="Single", B10="<1500g")`
   - `=AND(A10="32 - 33+6",C10="Single", B10=">1500g")`
   - `=AND(A10="28 - 29+6",C10="Multiple", B10="<1500g")`
   - `=AND(A10="28 - 29+6",C10="Multiple", B10=">1500g")`
   - `=AND(A10="30 - 31+6",C10="Multiple", B10="<1500g")`
   - `=AND(A10="30 - 31+6",C10="Multiple", B10=">1500g")`
   - `=AND(A10="32 - 33+6",C10="Multiple", B10="<1500g")`
   - `=AND(A10="32 - 33+6",C10="Multiple", B10=">1500g")`
 - White if cell contains a value

---

##### **Column I:** Could the course of antenatal steroids have been optimally administered (2 doses 12-24hrs apart, >24h and <7d)?	

**Data Validation:** `=$AL$71:$AL$72`

 - Yes
 - No

**Conditional Formatting:** 

 - Grey if 
   - `=$G10="No"`
   - `=AND(A10="27 - 27+6",C10="Single", B10="<1500g")`
   - `=AND(A10="27 - 27+6",C10="Single", B10=">1500g")`
   - `=AND(A10="28 - 29+6",C10="Single", B10="<1500g")`
   - `=AND(A10="28 - 29+6",C10="Single", B10=">1500g")`
   - `=AND(A10="30 - 31+6",C10="Single", B10="<1500g")`
   - `=AND(A10="30 - 31+6",C10="Single", B10=">1500g")`
   - `=AND(A10="32 - 33+6",C10="Single", B10="<1500g")`
   - `=AND(A10="32 - 33+6",C10="Single", B10=">1500g")`
   - `=AND(A10="28 - 29+6",C10="Multiple", B10="<1500g")`
   - `=AND(A10="28 - 29+6",C10="Multiple", B10=">1500g")`
   - `=AND(A10="30 - 31+6",C10="Multiple", B10="<1500g")`
   - `=AND(A10="30 - 31+6",C10="Multiple", B10=">1500g")`
   - `=AND(A10="32 - 33+6",C10="Multiple", B10="<1500g")`
   - `=AND(A10="32 - 33+6",C10="Multiple", B10=">1500g")`
 - White if cell contains a value

---

##### **Column J:** Was the course of antenatal steroids optimally administered (2 doses 12-24hrs apart, >24h and <7d)?

**Data Validation:** `=$AL$71:$AL$72`

 - Yes
 - No

**Conditional Formatting:** 

 - Grey if 
   - `=$G10="No"`
   - `=$I10="No"`
   - `=AND(A10="27 - 27+6",C10="Single", B10="<1500g")`
   - `=AND(A10="27 - 27+6",C10="Single", B10=">1500g")`
   - `=AND(A10="28 - 29+6",C10="Single", B10="<1500g")`
   - `=AND(A10="28 - 29+6",C10="Single", B10=">1500g")`
   - `=AND(A10="30 - 31+6",C10="Single", B10="<1500g")`
   - `=AND(A10="30 - 31+6",C10="Single", B10=">1500g")`
   - `=AND(A10="32 - 33+6",C10="Single", B10="<1500g")`
   - `=AND(A10="32 - 33+6",C10="Single", B10=">1500g")`
   - `=AND(A10="28 - 29+6",C10="Multiple", B10="<1500g")`
   - `=AND(A10="28 - 29+6",C10="Multiple", B10=">1500g")`
   - `=AND(A10="30 - 31+6",C10="Multiple", B10="<1500g")`
   - `=AND(A10="30 - 31+6",C10="Multiple", B10=">1500g")`
   - `=AND(A10="32 - 33+6",C10="Multiple", B10="<1500g")`
   - `=AND(A10="32 - 33+6",C10="Multiple", B10=">1500g")`
 - White if cell contains a value

---

##### **Column K:** Did the baby's mother receive antenatal magnesium sulphate?

**Data Validation:** `=$AL$71:$AL$72`

 - Yes
 - No

**Conditional Formatting:** 

 - Grey if 
   - `=$A10="30 - 31+6"`
   - `=$A10="32 - 33+6"`
 - White if cell contains a value

---

##### **Column L:** Could the course of antenatal magnesium sulphate have been optimally administered (>4 hours <24 hours of birth)?

**Data Validation:** `=$AL$71:$AL$72`

 - Yes
 - No

**Conditional Formatting:** 

 - Grey if 
   - `=$K10="No"`
   - `=$A10="30 - 31+6"`
   - `=$A10="32 - 33+6"`
 - White if cell contains a value

---

##### **Column M:** Was the course of antenatal magnesium sulphate optimally administered (>4 hours <24 hours of birth)?

**Data Validation:** `=$AL$71:$AL$72`

 - Yes
 - No

**Conditional Formatting:** 

 - Grey if 
   - `=$K10="No"`
   - `=$L10="No"`
   - `=$A10="30 - 31+6"`
   - `=$A10="32 - 33+6"`
 - White if cell contains a value

---

##### **Column N:** Did the baby’s mother receive intrapartum antibiotics?

**Data Validation:** `=$AL$71:$AL$72`

 - Yes
 - No

**Conditional Formatting:** 

 - Grey if 
   - `=$E10="No"`
 - White if cell contains a value

---

##### **Column O:** Could the course of intrapartum antibiotics have been optimally administered (>4 hours of birth)?

**Data Validation:** `=$AL$71:$AL$72`

 - Yes
 - No

**Conditional Formatting:** 

 - Grey if 
   - `=$E10="No"`
   - `=$N10="No"`
 - White if cell contains a value

---

##### **Column P:** Was the course of intrapartum antibiotics optimally administered (>4 hours of birth)?

**Data Validation:** `=$AL$71:$AL$72`

 - Yes
 - No

**Conditional Formatting:** 

 - Grey if 
   - `=$E10="No"`
   - `=$N10="No"`
   - `=$O10="No"`
 - White if cell contains a value

---

##### **Column Q:** Did the baby's mother receive information on the benefits of Early Maternal Breast Milk (EMBM) and support with hand / mechanical expressing within 2 hours of the babies birth?

**Data Validation:** `=$AL$71:$AL$72`

 - Yes
 - No

**Conditional Formatting:** 

 - White if cell contains a value

---

##### **Column R:** Did the baby have their cord clamped at or after one minute from birth?

**Data Validation:** `=$AL$71:$AL$72`

 - Yes
 - No

**Conditional Formatting:** 

 - White if cell contains a value

---

##### **Column S:** Did the baby have a normothermic temperature (36.5-37.5C) measured within one hour of birth?

**Data Validation:** `=$AL$71:$AL$72`

 - Yes
 - No

**Conditional Formatting:** 

 - White if cell contains a value

---

##### **Column T:** Percentage of babies born <34 weeks who receive volume-targeted ventilation in combination with synchronised ventilation as the primary mode of respiratory, if invasive ventilation is required

**Data Validation:** `=$AL$71:$AL$72`

 - Yes
 - No

**Conditional Formatting:** 

 - Grey if 
   - `=$D10="No"`
 - White if cell contains a value
 - White if cell contains 1 (NB: I believe this is an error as data validation suggests it can only be yes|no)

---

##### **Column U:** Did the baby receive caffeine within first 24 hours of life?

**Data Validation:** `=$AL$71:$AL$72`

 - Yes
 - No

**Conditional Formatting:** 

 - Grey if 
   - `=A10="30 - 31+6"`
   - `=A10="32 - 33+6"`
 - White if cell contains a value

---

##### **Column V:** Did the baby receive Early Maternal Breast Milk (EMBM) within 6 hours of birth (including buccal colostrum or maternal breast milk as mouth care)?

**Data Validation:** `=$AL$71:$AL$72`

 - Yes
 - No

**Conditional Formatting:** 

 - White if cell contains a value

---

##### **Column W:** Did the baby receive a multi-strain probiotic within first 24 hours of life?

**Data Validation:** `=$AL$71:$AL$72`

 - Yes
 - No

**Conditional Formatting:** 

 - Grey if 
   - `=AND(A10="32 - 33+6",B10=">1500g")"`
 - White if cell contains a value

---

##### **Column X:** Did the baby receive prophylactic hydrocortisone within first 24 hours of life?

**Data Validation:** `=$AL$71:$AL$72`

 - Yes
 - No


**Conditional Formatting:** 

 - Grey if 
   - `=A10="28 - 29+6"`
   - `=A10="30 - 31+6"`
   - `=A10="32 - 33+6"`
 - White if cell contains a value

---

##### **Column Y:**  BLANK

--- 

#### Data Processing Column Definitions

---

##### **Column Z:** Number of PERIPrem Bundle interventions Mum/Baby dyad received:	

**Data Calculation:** `=SUM(AR10:AV10)`

**Conditional Formatting:** 

 - White text on white background if cell is zero

---

##### **Column AA:** COUNT BLANK	

**Data Calculation:** `=SUM(AX10:BB10)`

---

##### **Column AB:** Optimal number of PERIPrem Bundle interventions for  gestational age:	

**Data Calculation:** `=11-AA10`

**Conditional Formatting:** 

 - White text on white background if cell is zero

---

##### **Column AC:** % of PERIPrem Bundle interventions optimised for Mum/Baby dyad:	

**Data Calculation:** `=Z10/AB10`

**Conditional Formatting:** 

 - White text on white background if cell is "#DIV/O1!" NB: This should be #DIV/0! but works as underlying format is white text on white
 - Black text on white background if cell is between 0 and 1 (inclusive)

---

##### **Column AD:** Number of antenatal PERIPrem Bundle interventions that were optimally administered

**Data Calculation:** `=BL10`

**Conditional Formatting:** 

 - Grey text on grey background if cell is zero

---

##### **Column AE:** Number of antenatal PERIPrem Bundle interventions that could have been optimally administered

**Data Calculation:** `=BK10`

**Conditional Formatting:** 

 - Grey text on grey background if cell is zero

---

##### **Column AF:** % of antenatal PERIPrem Bundle interventions that were optimally administered where it was possible

**Data Calculation:** `=BM10`

**Conditional Formatting:** 

 - Grey text on grey background if cell is zero

---

##### **Column AG:** FREE TEXT BOX:  Reasons why interventions weren't given [Optional]


**Data Calculation:** NONE

**Conditional Formatting:** 

 - Black text on white if cell is between 0 and 1 (inclusive) NB: Probably an error as this is a free text field rather than a percentage calculation 
 - White text on white background if cell is "#DIV/O1!" NB: This should be #DIV/0! but works as underlying format is white text on white again probably an error as this is a free text field rather than a percentage calculation 

---

#### Data Entry Column Definitions (Continued)

--- 

##### **Column AH:** BLANK

--- 

##### **Column AI:** If the baby was born on same site as designated NICU for the gestational age and birth weight, was it transferred in utero from another unit?

**Data Validation:** `=$AL$71:$AL$72`

 - Yes
 - No
 
**Conditional Formatting:** White if cell contains a value

 - Grey if 
   - `=F10="No"`
 - White if cell contains a value

--- 

##### **Column AJ:** If yes, which unit?

**Data Validation:** `=$AM$10:$AM$21`

 - Gloucestershire Royal Hospitals Foundation Trust
 - Great Western Hospitals NHS Foundation Trust
 - North Bristol NHS Trust
 - North Devon Healthcare NHS Trust
 - Royal Cornwall Hospitals NHS Trust
 - Royal Devon and Exeter NHS Foundation Trust
 - Royal United Hospitals Bath NHS Foundation Trust
 - Somerset NHS Foundation Trust
 - Torbay and South Devon NHS Foundation Trust
 - University Hospitals Bristol and Weston NHS Foundation Trust
 - University Hospitals Plymouth NHS Trust
 - Yeovil District Hospital NHS Foundation Trust

**Conditional Formatting:** White if cell contains a value

 - Grey if 
   - `=F10="No"`
 - White if cell contains a value

--- 

##### **Column AH:** FREE TEXT BOX: Interventions given prior to transfer [Optional]

**Data Validation:** NONE

**Conditional Formatting:** White if cell contains a value

 - Grey if 
   - `=F10="No"`
 - White if cell contains a value


