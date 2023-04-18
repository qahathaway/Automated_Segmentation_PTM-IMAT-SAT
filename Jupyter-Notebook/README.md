# Semantic Segmentation Pipeline

## DICOM to PNG Conversion
A deep learning algorithm was developed in combination with a quantitative analysis framework to extract pectoralis muscle area
measurements from the non-contrast chest CT examinations. First, DICOM images from each participant were recursively selected using the glob2 (v0.7) package for Python (v3.7).

## Windowing
These DICOM images were windowed (width: 350, length: 50) and converted to a 255-pixed gray-scale PNG, maintaining the original
resolution (OpenCV v4.7.0.68).

## Frame Selection
Our algorithm next selects the image frame corresponding to the section directly above the aortic arch. The frame was isolated by recursively removing the first 60% of images (i.e., to remove abdominal and lower chest sections) and cropping the image to retain only the mediastinum. From the cropped image, pixel intensity was stratified to retain pixels with a value greater than 80 but less than 140; this provided pixel intensities in the mediastinum that included primarily vascular structures. A histogram was created containing the PNG sections, allowing for retrieval of the PNG with the lowest pixel intensities, correlating with the section directly above the aortic arch.

### Pixel Intensity Frame Selection
![alt text](https://github.com/qahathaway/Automated_Segmentation_PTM-IMAT-SAT/blob/main/Jupyter-Notebook/Frame_Selection.jpg)

## Manual Labelling
Two trained observers labelled 600 of these selected images manually (LabelMe v5.1.0), performing traces for the right pectoralis
muscle group, left pectoralis muscle group, and the subcutaneous adipose tissue directly anterior to these muscles. Using the Pixellib
package, we trained a region-based convolutional neural network (R-CNN) on 360 of these images and validated on the remaining
240. Our algorithm was configured using ResNet50 with pretrained weights.

## Semamtic Segmentation and Adipose Thresholding
We employed a framework developed for the MESArthritis ancillary study for quantitative analysis of pectoralis muscle in the chest CT, based off of prior work by Mühlberg et al. Briefly, we first isolated the intermuscular adipose tissue (IMAT) using subcutaneous adipose tissue (SAT) attenuation values using individualized thresholds. This entails the trimming of values that frequent less than 30% of those of the mode from both ends of a histogram of SAT attenuation values. Next, a threshold is selected at 2 standard deviations above the mean of the remaining values. Values in the pectoralis muscle tissue (PMT) below this threshold are considered IMAT. Values existing between 1 and 2 standard deviations above the mean are considered extramyocellular far (EML; adipose tissue between muscle fibers); the remaining are considered perimuscular adipose tissue (PAT; adipose tissue in fascial plane between the pectoralis major and minor). All area measurements (cm2) were indexed to the participant’s height (in m2).

### Adipose Tissue Thresholding
![alt text](https://github.com/qahathaway/Automated_Segmentation_PTM-IMAT-SAT/blob/main/Jupyter-Notebook/IMAT_PAT_EML.jpg)
