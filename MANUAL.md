# REQUIREMENTS

1. Bash: The pipeline requires Bash version 4.0 or higher to function correctly.
2. FSL (FMRIB Software Library): The pipeline relies on FSL for certain functionalities. Ensure that FSL is installed and properly configured on your system. You can download FSL from the official FSL website: https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FSL

 # Setting up the paths.sh
Edit the paths.sh and set the corrects paths for your list of input files, the main output directy in which temporary files and the results will be stored as well as the correct path for the directoy containing the ASPECTS masks.
The list of input files should consist of one NIfTI file name per row (name of your CTA source images) and the files should be stored in the same same directory as the scripts.

# Running the pipeline
To run all steps of the pipleline, just execute run_pipeline.sh. All steps of the pipeline can also be called individually, but might not function correctly due to missing files from the steps before.

# Steps of the pipeline

## 1. CTA_coregistration.sh
This script measures whether the input CTA source images has an extension on the z-axis of greater than 180mm and if so, truncate it to 180mm from the highest point on the z-axis.
The brain is extracted in several steps and coregisterd to the MNI-152 1mm brain.
The resulting matrix file will then be applied to the original, non-brain extracted CTA file.

An additional quality control of the resulting coregistrion is highly recommended!

## 2. mask_coregistration.sh
Using the reverse matrix of the CTAs coregistraion, all 10 masks are coregisterd to the CTAs native space, binarized and stored in a folder named after the input file.

## 3. intensity_measurement.sh
The mean attenuation in Houndsfield Units (HU) is measured for each region on both hemisspheres and stored in the subfolder of each case. 
Only voxels with intensities between 1 und 250 are included in the measurement.

## 4. rate_aspects.sh
The user is prompted to enter the side of infarction (left/right) for each subject.
The relative Houndsfield Unit (rHU) is calculated by dividing the mean Houndsfield Unit of the infarcted side by the non-infarcted side.
The rHU is compared to the region-specific threshold stored in cutpoints.csv.
If it is lower than the threshold, then the region is regarded as infarcted and the total ASPECTS of the case is decreased by 1.
The results are saved in a .csv file in the subfolder of the file in question.
