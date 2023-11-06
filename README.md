# Automated Segmentation of Axial CT for Delineation of Pectoralis Muscle

## Background
Using computed tomography (CT), pectoralis muscle density and intramuscular fat deposition have been correlated with adverse health outcomes. It is unclear if pectoralis muscle measurements can be prospectively associated with incident heart failure, pneumonia, and other chronic medical conditions and if the use of automated detection tools can bypass the need for cumbersome, manual measurements.

## Methods
3083 participants in the MESArthritis ancillary study were examined. Participants with absent baseline data (n=852), presence of heart failure at baseline (n=305), low-quality CT (n=26), or artifact (n=26) did not meet criteria, with 1874 participants included in the final analysis. Mediastinal windowing was applied and hamming distances, utilizing vantage point trees, selected the axial frame directly above the aorta. Manual measurements were performed on 600 participants using LabelMe. Patients were split into training (60%) and testing (40%) sets to develop our deep-learning model. The semantic segmentation platform was created with Pixellib and Mask R-CNN. Five pectoralis muscle composition indices were assessed: pectoralis muscle (PM), subcutaneous adipose tissue (SAT), intermuscular adipose tissue (IMAT), perimuscular adipose tissue (PAT), and extramyocellular lipids (EML).

## Results
Comparison of manual measurements (n=600) to the deep-learning generated traces revealed a Dice score of (0.90 [0.90-0.91]) and (0.90 [0.89-0.90]) for the training and testing sets, respectively, and intersection over union score of (0.82 [0.82-0.83]) and (0.81 [0.81-0.82]) for the training and testing sets, respectively, when assessing all segments.

## Semantic Segmentation - Inference
![alt text](https://github.com/qahathaway/Automated_Segmentation_PTM-IMAT-SAT/blob/main/Output.jpg)

## PM, SAT, IMAT, PAT, and EML
![alt text](https://github.com/qahathaway/Automated_Segmentation_PTM-IMAT-SAT/blob/main/Features.jpg)

### Code is made freely available for academic research and teaching. The code within this repository cannot be freely used for commercial applications.
