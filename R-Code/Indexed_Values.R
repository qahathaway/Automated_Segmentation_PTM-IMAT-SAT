library(haven)
library(survival)
library(dplyr)
library(mice)
library(naniar)
library(miceafter)
library(gtsummary)
library(ggplot2)
library(ggfortify)
library(survminer)

AIMUSCLE = read.csv('path/to/file.csv')

#Getting rid of the MESA at the from of every study ID and relabelling it idno for mergin ease
AIMUSCLE$idno = substr(AIMUSCLE$Study_ID, 5, 11)
AIMUSCLE$idno = as.numeric(AIMUSCLE$idno)

##Importing Other Datasets
FINALTAGGED = read_sav('path/to/file.sav')

IncidentHF = read_sav('path/to/file.sav')

#Exclude people with prior events

MRIDATA = subset(FINALTAGGED, !(is.na(olvedm5t))) # Excluding those without MRI data
IncidentHF = subset(IncidentHF, exall == 0 & expvd == 0) #Excluding those who have had baseline event

#merge the datasets

step1 = merge(AIMUSCLE, MRIDATA, by = "idno")
step3 = merge(step1, IncidentHF, by = 'idno')

##Calculation
step3$RightEngelkeIMF = step3$Extramyocellular.Lipid...Right + step3$Perimuscular.Adipose.Tissue..Right
step3$LeftEngelkeIMF = step3$Extramyocellular.Lipid...Left + step3$Perimuscular.Adipose.Tissue..Left

step3$EngelkeRightPectoralisMuscleArea = step3$Pectoralis.Muscle..Right
step3$EngelkeLeftPectoralisMuscleArea = step3$Pectoralis.Muscle..Left

step3$pectoralistotal = step3$EngelkeRightPectoralisMuscleArea + step3$EngelkeLeftPectoralisMuscleArea
step3$Interfattotal = step3$RightEngelkeIMF + step3$LeftEngelkeIMF
step3$emltotal = step3$Extramyocellular.Lipid...Right + step3$Extramyocellular.Lipid...Left
step3$patotal = step3$Perimuscular.Adipose.Tissue..Right + step3$Perimuscular.Adipose.Tissue..Left
step3$Subtotal = step3$Subcutaneous.Adipose.Tissue

step3$pmi5c = ((step3$EngelkeRightPectoralisMuscleArea + step3$EngelkeLeftPectoralisMuscleArea) / ((step3$htcm5/100)^2))

step3$iai5c1 = ((step3$RightEngelkeIMF + step3$LeftEngelkeIMF) / ((step3$htcm5/100)^2))

step3$sai5c = ((step3$Subcutaneous.Adipose.Tissue) / ((step3$htcm5/100)^2))

step3$iai5c2 = ((step3$RightEngelkeIMF + step3$LeftEngelkeIMF) / (step3$EngelkeRightPectoralisMuscleArea + step3$EngelkeLeftPectoralisMuscleArea)) * 100

step3$EML5c1 = ((step3$Extramyocellular.Lipid...Right + step3$Extramyocellular.Lipid...Left) / ((step3$htcm5/100)^2))
step3$PAT5c1 = ((step3$Perimuscular.Adipose.Tissue..Right + step3$Perimuscular.Adipose.Tissue..Left) / ((step3$htcm5/100)^2))

#Contract the dataset for the data that I want


DATA = step3[c("idno", "age5c", 'gender1', 'pkyrs5c', 'htn5c', 'agatpm5c', 'olvedm5t', 'htcm5', 'wtlb5', 'pamvcm5c',
               'chftt', 'e15ctdyc', 'chf','iai5c1', 'EML5c1', 'PAT5c1', 'pmi5c', 'sai5c', 'race1c', 'creatin5t', 'hba1c5',
               'htnmed5c', 'lipid5c', 'diabins5', 'chlcat5c', 'income5', 'curalc5', 'bmi5c', 'olvef5t')]

##Subsetting those individuals who had event AFTER their 5th exam CT

DATA = subset(DATA, chftt >= e15ctdyc)

#Calculating amount of missing data in the final data set

sum(is.na(DATA))/(nrow(DATA)*ncol(DATA)) #Calculated NA in the data set

mcar_test(DATA[2:ncol(DATA)]) # Running Pattern of Missing Data analysis NOT SIGNIFICANT

#Factorize things that need to be factorized


DATA$gender1 = as.factor(DATA$gender1) #Factorized Sex
DATA$htn5c = as.factor(DATA$htn5c) #Factorized Hypertension
DATA$htnmed5c = as.factor(DATA$htnmed5c)  
DATA$lipid5c = as.factor(DATA$lipid5c) 
DATA$diabins5 = as.factor(DATA$diabins5)

DATA = DATA %>% mutate(chlcat5c = case_when(
  chlcat5c == 1 ~ 1,
  chlcat5c == 2 ~ 2,
  chlcat5c == 3 ~ 2,
))


DATA$chlcat5c = as.factor(DATA$chlcat5c) 

DATA = DATA %>% mutate(income5 = case_when(
  income5 == 1 ~ 1,
  income5 == 2 ~ 2,
  income5 == 3 ~ 2,
  income5 == 4 ~ 2,
  income5 == 5 ~ 2,
  income5 == 6 ~ 3,
  income5 == 7 ~ 3,
  income5 == 8 ~ 3,
  income5 == 9 ~ 3,
  income5 == 10 ~ 3,
  income5 == 11 ~ 4,
  income5 == 12 ~ 4,
  income5 == 13 ~ 4,
  income5 == 14 ~ 4,
  income5 == 15 ~ 4,
))


DATA$income5 = as.factor(DATA$income5) 
DATA$curalc5 = as.factor(DATA$curalc5) 

##Changing race to White/Black/Other because it was previously coded as White/Chinese/Black/Hispanic which was not 
##appropriate
DATA = DATA %>% mutate(race1c = case_when(
  race1c == 1 ~ 1,
  race1c == 3 ~ 2,
  race1c == 2 ~ 3,
  race1c == 4 ~ 3
))


DATA$race1c = as.factor(DATA$race1c)

DATA = DATA[complete.cases(DATA), ]

##Summary Table
Summary = DATA %>% select(age5c, gender1, olvef5t, pkyrs5c, htn5c, bmi5c, agatpm5c, iai5c1, EML5c1, PAT5c1, pmi5c, sai5c, race1c, pamvcm5c, hba1c5, creatin5t,htnmed5c, lipid5c, diabins5,chlcat5c, income5 , curalc5) %>% 
  tbl_summary(
    digits = all_continuous() ~ 4,
    label = list(
      age5c ~ 'Age',
      gender1 ~ 'Sex',
      race1c ~ 'Race/Ethnicity',
      bmi5c ~ 'Body Mass Index',
      income5 ~ 'Total Gross Family Income',
      pkyrs5c ~ 'Smoking Status',
      curalc5 ~ 'Presently Drink Alcohol',
      htn5c ~ 'Hypertension (JNC IV Criteria)',
      hba1c5 ~ 'Hemoglobin A1C (%)',
      chlcat5c ~ 'Total Cholesterol (NCEP Categories)',
      creatin5t ~ 'Serum Creatinine (mg/dL)',
      htnmed5c ~ 'Hypertension Medicaiton Use',
      diabins5 ~ 'Insulin/Hypoglycemic Medication Use',
      lipid5c ~ 'Lipid-lowering Medication Use',
      pamvcm5c ~ 'Moderate to Vigorous Activity (MET-min/week)',
      agatpm5c ~ 'Phantom-adjusted Total Agatston Calcium Score',
      olvef5t ~ 'Left Ventricular Ejection Fraction (%)',
      iai5c1 ~ 'Intermuscular Adipose Tissue Area (cm squared)',
      EML5c1 ~ 'Extramyocellular Adipose Tissue Area (cm squared)',
      PAT5c1 ~ 'Perimuscular Adipose Tissue Area (cm squared)',
      pmi5c ~ 'Pectoralis Muscle Index Area (cm squared)',
      sai5c ~ 'Subcutaneous Adipose Tissue Index Area (cm squared)',
      missing = 'no'
    ))

gt::gtsave(as_gt(Summary), file = 'path/to/file.rtf')


#Calculating Derivative MRI VARIABLES
for (x in 1:nrow(DATA)) {
  if (DATA$gender1[x] == 1) {
    DATA$LVMASSPRED[x] = 100*DATA$olvedm5t[x]/(8.25*((DATA$htcm5[x]/100)^0.54)*((DATA$wtlb5[x]*0.45359237)^0.61))
  }
  else if (DATA$gender1[x] == 0) {
    DATA$LVMASSPRED[x] = 100*DATA$olvedm5t[x]/(6.82*((DATA$htcm5[x]/100)^0.54)*((DATA$wtlb5[x]*0.45359237)^0.61))
  }
}

for (x in 1:nrow(DATA)) {
  if (DATA$LVMASSPRED[x] <= 136 & !is.na(DATA$LVMASSPRED[x])) {
    DATA$LVH[x] = 0
  }
  else {
    DATA$LVH[x] = 1
  }
}

#Calculating left ventricular hypertrophy (using > 136% as cutoff according to Dr. Bluemke) and left ventricular mass percentage of predicted.

DATA$LVH= as.factor(DATA$LVH)

#Calculating the log(calciums core + 1) as done in Dr. Bleumke's paper to account for normality
DATA$CACSCORE = log(DATA$agatpm5c+1)

#Calculating Follow Up time
DATA$followuptime = DATA$chftt - DATA$e15ctdyc

summary(DATA$followuptime)

#Models for IncidentHF Crude

CModelMuscleIndexLVH = coxph(Surv(followuptime, chf)~ pmi5c, data = DATA)
CModelFatIndex1LVH  = coxph(Surv(followuptime, chf)~ iai5c1, data = DATA)
CModelEMLLVH  = coxph(Surv(followuptime, chf)~ EML5c1, data = DATA)
CModelPATLVH  = coxph(Surv(followuptime, chf)~ PAT5c1, data = DATA)
CModelSFATLVH  = coxph(Surv(followuptime, chf)~ sai5c, data = DATA)


summary(CModelMuscleIndexLVH)
summary(CModelFatIndex1LVH)
summary(CModelEMLLVH)
summary(CModelPATLVH)
summary(CModelSFATLVH)


cox.zph(CModelMuscleIndexLVH)
cox.zph(CModelFatIndex1LVH)
cox.zph(CModelEMLLVH)
cox.zph(CModelPATLVH)
cox.zph(CModelSFATLVH)


concordance(CModelMuscleIndexLVH, timewt = 'n')
concordance(CModelFatIndex1LVH, timewt = 'n')
concordance(CModelEMLLVH, timewt = 'n')
concordance(CModelPATLVH, timewt = 'n')
concordance(CModelSFATLVH, timewt = 'n')

royston(CModelMuscleIndexLVH)
royston(CModelFatIndex1LVH)
royston(CModelEMLLVH)
royston(CModelPATLVH)
royston(CModelSFATLVH)


#Models for IncidentHF Basic Demo

BCModelMuscleIndexLVH = coxph(Surv(followuptime, chf)~ age5c   + gender1 + race1c + income5+pmi5c, data = DATA)
BCModelFatIndex1LVH  = coxph(Surv(followuptime, chf)~ age5c   + gender1 + race1c + income5+iai5c1, data = DATA)
BCModelEMLLVH  = coxph(Surv(followuptime, chf)~ age5c   + gender1 + race1c + income5+EML5c1, data = DATA)
BCModelPATLVH  = coxph(Surv(followuptime, chf)~ age5c   + gender1 + race1c + income5+PAT5c1, data = DATA)
BCModelSFATLVH  = coxph(Surv(followuptime, chf)~ age5c   + gender1 + race1c + income5+sai5c, data = DATA)


summary(BCModelMuscleIndexLVH)
summary(BCModelFatIndex1LVH)
summary(BCModelEMLLVH)
summary(BCModelPATLVH)
summary(BCModelSFATLVH)


cox.zph(BCModelMuscleIndexLVH)
cox.zph(BCModelFatIndex1LVH)
cox.zph(BCModelEMLLVH)
cox.zph(BCModelPATLVH)
cox.zph(BCModelSFATLVH)


concordance(BCModelMuscleIndexLVH, timewt = 'n')
concordance(BCModelFatIndex1LVH, timewt = 'n')
concordance(BCModelEMLLVH, timewt = 'n')
concordance(BCModelPATLVH, timewt = 'n')
concordance(BCModelSFATLVH, timewt = 'n')

royston(BCModelMuscleIndexLVH)
royston(BCModelFatIndex1LVH)
royston(BCModelEMLLVH)
royston(BCModelPATLVH)
royston(BCModelSFATLVH)

#Model for IncidentHF Only Clinical
PModelMuscleIndexLVH = coxph(Surv(followuptime, chf)~ age5c   + gender1 + bmi5c + race1c + pkyrs5c +curalc5  + htn5c  + hba1c5 + creatin5t + pamvcm5c +htnmed5c + lipid5c + diabins5 + chlcat5c+ income5+  pmi5c, data = DATA)
PModelFatIndex1LVH  = coxph(Surv(followuptime, chf)~ age5c   + gender1 + bmi5c+ race1c+ pkyrs5c+curalc5+ htn5c  + hba1c5 + creatin5t +pamvcm5c +htnmed5c + lipid5c + diabins5 + chlcat5c + income5+  iai5c1, data = DATA)
PModelEMLLVH  = coxph(Surv(followuptime, chf)~ age5c   + gender1 + bmi5c+ race1c+ pkyrs5c  +curalc5+ htn5c  + hba1c5 + creatin5t +pamvcm5c +htnmed5c + lipid5c + diabins5 + chlcat5c+ income5+   EML5c1, data = DATA)
PModelPATLVH  = coxph(Surv(followuptime, chf)~ age5c   + gender1 + bmi5c+ race1c+ pkyrs5c +curalc5 + htn5c   + hba1c5 + creatin5t+pamvcm5c +htnmed5c + lipid5c + diabins5 + chlcat5c+ income5+   PAT5c1, data = DATA)
PModelSFATLVH  = coxph(Surv(followuptime, chf)~ age5c   + gender1 + bmi5c+ race1c+ pkyrs5c +curalc5 + htn5c  + hba1c5 + creatin5t +pamvcm5c+htnmed5c + lipid5c + diabins5 + chlcat5c + income5+   sai5c, data = DATA)


summary(PModelMuscleIndexLVH)
summary(PModelFatIndex1LVH)
summary(PModelEMLLVH)
summary(PModelPATLVH)
summary(PModelSFATLVH)


cox.zph(PModelMuscleIndexLVH)
cox.zph(PModelFatIndex1LVH)
cox.zph(PModelEMLLVH)
cox.zph(PModelPATLVH)
cox.zph(PModelSFATLVH)

concordance(PModelMuscleIndexLVH,timewt = 'n')
concordance(PModelFatIndex1LVH, timewt = 'n')
concordance(PModelEMLLVH, timewt = 'n')
concordance(PModelPATLVH, timewt = 'n')
concordance(PModelSFATLVH, timewt = 'n')

royston(PModelMuscleIndexLVH)
royston(PModelFatIndex1LVH)
royston(PModelEMLLVH)
royston(PModelPATLVH)
royston(PModelSFATLVH)
#Models for IncidentHF Adjusted for Clinical and CACscore

ModelCACMuscleIndexLVH = coxph(Surv(followuptime, chf)~ age5c  + race1c + gender1+ bmi5c + pkyrs5c  +curalc5 + htn5c  + hba1c5 + creatin5t+ CACSCORE +pamvcm5c +htnmed5c + lipid5c + diabins5 + chlcat5c+ income5+   pmi5c, data = DATA)
ModelCACFatIndex1LVH  = coxph(Surv(followuptime, chf)~ age5c  + race1c + gender1+ bmi5c + pkyrs5c+curalc5+ htn5c  + hba1c5 + creatin5t+ CACSCORE +pamvcm5c +htnmed5c + lipid5c + diabins5 + chlcat5c+ income5+   iai5c1, data = DATA)
ModelCACEMLLVH  = coxph(Surv(followuptime, chf)~ age5c   + race1c+ gender1+ bmi5c+ pkyrs5c +curalc5 + htn5c  + hba1c5 + creatin5t+ CACSCORE +pamvcm5c +htnmed5c + lipid5c + diabins5 + chlcat5c+ income5+   EML5c1, data = DATA)
ModelCACPATLVH  = coxph(Surv(followuptime, chf)~ age5c   + race1c+ gender1 + bmi5c+ pkyrs5c +curalc5 + htn5c  + hba1c5 + creatin5t+ CACSCORE +pamvcm5c +htnmed5c + lipid5c + diabins5 + chlcat5c+ income5+   PAT5c1, data = DATA)
ModelCACSFATLVH  = coxph(Surv(followuptime, chf)~ age5c  + race1c + gender1+ bmi5c + pkyrs5c +curalc5 + htn5c + hba1c5 + creatin5t + CACSCORE +pamvcm5c +htnmed5c + lipid5c + diabins5 + chlcat5c+ income5+   sai5c, data = DATA)

summary(ModelCACMuscleIndexLVH)
summary(ModelCACFatIndex1LVH)
summary(ModelCACEMLLVH)
summary(ModelCACPATLVH)
summary(ModelCACSFATLVH)


cox.zph(ModelCACMuscleIndexLVH)
cox.zph(ModelCACFatIndex1LVH)
cox.zph(ModelCACEMLLVH)
cox.zph(ModelCACPATLVH)
cox.zph(ModelCACSFATLVH)

concordance(ModelCACMuscleIndexLVH, timewt = 'n')
concordance(ModelCACFatIndex1LVH, timewt = 'n')
concordance(ModelCACEMLLVH, timewt = 'n')
concordance(ModelCACPATLVH, timewt = 'n')
concordance(ModelCACSFATLVH, timewt = 'n')

royston(ModelCACMuscleIndexLVH)
royston(ModelCACFatIndex1LVH)
royston(ModelCACEMLLVH)
royston(ModelCACPATLVH)
royston(ModelCACSFATLVH)


#Models for IncidentHF Fully Adjusted

ModelMuscleIndexLVH = coxph(Surv(followuptime, chf)~ age5c  + race1c + gender1 + pkyrs5c  +curalc5 + htn5c + CACSCORE + pamvcm5c+ + hba1c5 +  creatin5t +htnmed5c + lipid5c + diabins5 + chlcat5c+olvef5t+  LVMASSPRED +pmi5c, data = DATA)
ModelFatIndex1LVH  = coxph(Surv(followuptime, chf)~ age5c   + race1c+ gender1 + pkyrs5c  +curalc5 + htn5c + CACSCORE +pamvcm5c + hba1c5 + creatin5t+htnmed5c + lipid5c + diabins5 + chlcat5c+olvef5t+   LVMASSPRED +iai5c1, data = DATA)
ModelEMLLVH  = coxph(Surv(followuptime, chf)~ age5c  + race1c + gender1 + pkyrs5c   +curalc5+ htn5c + CACSCORE +pamvcm5c + hba1c5 + creatin5t+htnmed5c + lipid5c + diabins5 + chlcat5c+olvef5t+   LVMASSPRED+ EML5c1, data = DATA)
ModelPATLVH  = coxph(Surv(followuptime, chf)~ age5c   + race1c+ gender1 + pkyrs5c   +curalc5+ htn5c + CACSCORE +pamvcm5c + hba1c5 + creatin5t+htnmed5c + lipid5c + diabins5 + chlcat5c+olvef5t+   LVMASSPRED+ PAT5c1, data = DATA)
ModelSFATLVH  = coxph(Surv(followuptime, chf)~ age5c  + race1c + gender1 + pkyrs5c  +curalc5 + htn5c + CACSCORE +pamvcm5c+ hba1c5 + creatin5t +htnmed5c + lipid5c + diabins5 + chlcat5c+olvef5t+   LVMASSPRED+ sai5c, data = DATA)

summary(ModelMuscleIndexLVH)
summary(ModelFatIndex1LVH)
summary(ModelEMLLVH)
summary(ModelPATLVH)
summary(ModelSFATLVH)


cox.zph(ModelMuscleIndexLVH)
cox.zph(ModelFatIndex1LVH)
cox.zph(ModelEMLLVH)
cox.zph(ModelPATLVH)
cox.zph(ModelSFATLVH)

concordance(ModelMuscleIndexLVH, timewt = 'n')
concordance(ModelFatIndex1LVH, timewt = 'n')
concordance(ModelEMLLVH, timewt = 'n')
concordance(ModelPATLVH, timewt = 'n')
concordance(ModelSFATLVH, timewt = 'n')

royston(ModelMuscleIndexLVH)
royston(ModelFatIndex1LVH)
royston(ModelEMLLVH)
royston(ModelPATLVH)
royston(ModelSFATLVH)


##Loglikelihood Calculations between models with and without indices

NULLMODEL = coxph(Surv(followuptime, chf)~ age5c  + race1c + gender1 + pkyrs5c  +curalc5 + htn5c + CACSCORE +pamvcm5c+ hba1c5 + creatin5t +htnmed5c + lipid5c + diabins5 + chlcat5c+olvef5t+   LVMASSPRED, data = DATA)
concordance(NULLMODEL)


anova(ModelMuscleIndexLVH, NULLMODEL)
anova(ModelFatIndex1LVH, NULLMODEL)
anova(ModelEMLLVH, NULLMODEL)
anova(ModelPATLVH, NULLMODEL)
anova(ModelSFATLVH, NULLMODEL)

##Comparing C-statistics
compareC(DATA$followuptime, DATA$chf, predict(ModelMuscleIndexLVH, type = 'risk'), predict(NULLMODEL, type = 'risk') )
compareC(DATA$followuptime, DATA$hf, predict(ModelFatIndex1LVH, type = 'risk'), predict(NULLMODEL, type = 'risk') )
compareC(DATA$followuptime, DATA$chf, predict(ModelEMLLVH, type = 'risk'), predict(NULLMODEL, type = 'risk') )
compareC(DATA$followuptime, DATA$chf, predict(ModelPATLVH, type = 'risk'), predict(NULLMODEL, type = 'risk') )
compareC(DATA$followuptime, DATA$chf, predict(ModelSFATLVH, type = 'risk'), predict(NULLMODEL, type = 'risk') )

##Generating Number of Events Per Year
DATAEVENTS = DATA[, c('chf', 'followuptime')]
summary(DATAEVENTS$followuptime)
DATAEVENTS$followuptimechar = as.factor(cut(DATAEVENTS$followuptime, breaks = c(0,365,730,1095,1460,1826,2191,2566,2921))) 
table(DATAEVENTS$followuptimechar, as.factor(DATAEVENTS$chf))

##Generate means of indices by incident heart failure occurence
DATAEVENT = subset(DATA, chf == 1)
DATANOEVENT = subset(DATA, chf == 0)

summary(DATAEVENT$pmi5c)
summary(DATAEVENT$iai5c1)
summary(DATAEVENT$EML5c1)
summary(DATAEVENT$PAT5c1)
summary(DATAEVENT$sai5c)

summary(DATANOEVENT$pmi5c)
summary(DATANOEVENT$iai5c1)
summary(DATANOEVENT$EML5c1)
summary(DATANOEVENT$PAT5c1)
summary(DATANOEVENT$sai5c)

##Generate Kaplan-Meier Curves
DATA = DATA %>% mutate(CATpmi5c = case_when (pmi5c >= median(pmi5c) ~ 1, pmi5c < median(pmi5c) ~ 0))
DATA = DATA %>% mutate(CATiai5c1 = case_when (iai5c1 >= median(iai5c1) ~ 1, iai5c1 < median(iai5c1) ~ 0))
DATA = DATA %>% mutate(CATEML5c1 = case_when (EML5c1 >= median(EML5c1) ~ 1, EML5c1 < median(EML5c1) ~ 0))
DATA = DATA %>% mutate(CATPAT5c1 = case_when (PAT5c1 >= median(PAT5c1) ~ 1, PAT5c1 < median(PAT5c1) ~ 0))
DATA = DATA %>% mutate(CATsai5c = case_when (sai5c >= median(sai5c) ~ 1, sai5c < median(sai5c) ~ 0))

summary(DATA$iai5c1)
summary(DATA$EML5c1)
summary(DATA$PAT5c1)
summary(DATA$pmi5c)
summary(DATA$sai5c)


DATA$CATpmi5c = as.factor(DATA$CATpmi5c)
DATA$CATiai5c1 = as.factor(DATA$CATiai5c1)
DATA$CATEML5c1 = as.factor(DATA$CATEML5c1)
DATA$CATPAT5c1 = as.factor(DATA$CATPAT5c1)
DATA$CATsai5c = as.factor(DATA$CATsai5c)

KMModelMuscleIndexLVH = survfit(Surv(followuptime, chf)~ CATpmi5c, data = DATA, type = 'kaplan-meier')
KMModelFatIndex1LVH  = survfit(Surv(followuptime, chf)~ CATiai5c1, data = DATA, type = 'kaplan-meier')
KMModelEMLLVH  = survfit(Surv(followuptime, chf)~ CATEML5c1, data = DATA, type = 'kaplan-meier')
KMModelPATLVH  = survfit(Surv(followuptime, chf)~ CATPAT5c1, data = DATA, type = 'kaplan-meier')
KMModelSFATLVH  = survfit(Surv(followuptime, chf)~ CATsai5c, data = DATA, type = 'kaplan-meier')



ggsurvplot(
  KMModelMuscleIndexLVH,
  data = DATA,
  size = 1,                 # change line size
  palette =
    c("#9e7606", "#000000"),# custom color palettes
  conf.int = F,          # Add confidence interval
  pval = TRUE,              # Add p-value
  ylim = c(0.95,1),
  risk.table = TRUE,        # Add risk table
  risk.table.col = "strata",# Risk table color by groups
  legend.labs =
    c("Low", "High"),    # Change legend labels
  risk.table.height = 0.25, # Useful to change when you have multiple groups
  xlab = "Time (in days)",
  ggtheme = theme_bw(base_size=24)# Change ggplot2 theme
)


ggsurvplot(
  KMModelFatIndex1LVH,
  data = DATA,
  size = 1,                 # change line size
  palette =
    c("#9e7606", "#000000"),# custom color palettes
  conf.int = F,          # Add confidence interval
  pval = TRUE,              # Add p-value
  ylim = c(0.95,1),
  risk.table = TRUE,        # Add risk table
  risk.table.col = "strata",# Risk table color by groups
  legend.labs =
    c("Low", "High"),    # Change legend labels
  risk.table.height = 0.25, # Useful to change when you have multiple groups
  xlab = "Time (in days)",
  ggtheme = theme_bw(base_size=24)
# Change ggplot2 theme
)


ggsurvplot(
  KMModelEMLLVH,
  data = DATA,
  size = 1,                 # change line size
  palette =
    c("#9e7606", "#000000"),# custom color palettes
  conf.int = F,          # Add confidence interval
  pval = TRUE,              # Add p-value
  ylim = c(0.95,1),
  risk.table = TRUE,        # Add risk table
  risk.table.col = "strata",# Risk table color by groups
  legend.labs =
    c("Low", "High"),    # Change legend labels
  risk.table.height = 0.25, # Useful to change when you have multiple groups
  xlab = "Time (in days)",
  ggtheme = theme_bw(base_size=24)
     # Change ggplot2 theme
)

ggsurvplot(
  KMModelPATLVH,
  data = DATA,
  size = 1,                 # change line size
  palette =
    c("#9e7606", "#000000"),# custom color palettes
  conf.int = F,          # Add confidence interval
  pval = TRUE,              # Add p-value
  ylim = c(0.95,1),
  risk.table = TRUE,        # Add risk table
  risk.table.col = "strata",# Risk table color by groups
  legend.labs =
    c("Low", "High"),    # Change legend labels
  risk.table.height = 0.25, # Useful to change when you have multiple groups
  xlab = "Time (in days)",
  ggtheme = theme_bw(base_size=24)
     # Change ggplot2 theme
)

ggsurvplot(
  KMModelSFATLVH,
  data = DATA,
  size = 1,                 # change line size
  palette =
    c("#9e7606", "#000000"),# custom color palettes
  conf.int = F,          # Add confidence interval
  pval = TRUE,              # Add p-value
  ylim = c(0.95,1),
  risk.table = TRUE,        # Add risk table
  risk.table.col = "strata",# Risk table color by groups
  legend.labs =
    c("Low", "High"),    # Change legend labels
  risk.table.height = 0.25, # Useful to change when you have multiple groups
  xlab = "Time (in days)",
  ggtheme = theme_bw(base_size=24)
     # Change ggplot2 theme
)
