# Automated Segmentation of Axial CT for Delineation of PM, IMAT, and SAT

## There are 3 primary steps that are needed

### Step 1
Automatically convert DICOM images to axial PNG with pixel scaling of 0 to 255
- Conversion by individual folder
- Conversion by entire directory, recursively

### Step 2
Automatically select the axial PNG corresponding to the frame above the aortic arch
- Selection by individual folder
- Selection by entire directory, recursively

### Step 3
Create ROI for PM, IMAT, and SAT
- Weights are needed to train Mask R-CNN to select the appropriate pixels

### This Repository is Private

# Current Data:

## Ground Truth Example 1
![alt text](https://github.com/qahathaway/Automated_Segmentation_PTM-IMAT-SAT/blob/main/Ground_Truth_1.png)

## Ground Truth Example 2
![alt text](https://github.com/qahathaway/Automated_Segmentation_PTM-IMAT-SAT/blob/main/Ground_Truth_2.png)

## Computer Vision 1
![alt text](https://github.com/qahathaway/Automated_Segmentation_PTM-IMAT-SAT/blob/main/Random_1.png)

## Computer Vision 2
![alt text](https://github.com/qahathaway/Automated_Segmentation_PTM-IMAT-SAT/blob/main/Random_2.png)

## Computer Vision 3
![alt text](https://github.com/qahathaway/Automated_Segmentation_PTM-IMAT-SAT/blob/main/Random_3.png)
