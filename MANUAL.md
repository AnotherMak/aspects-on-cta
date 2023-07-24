# REQUIREMENTS

1. Bash: The pipeline requires Bash version 4.0 or higher to function correctly.
2. FSL (FMRIB Software Library): The pipeline relies on FSL for certain functionalities. Ensure that FSL is installed and properly configured on your system. You can download FSL from the official FSL website: https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FSL

 # Setting up the paths.sh
Edit the paths.sh and set the corrects paths for the following:
- input_list: Path to a text file  (or similar), containing the names of your input NIfTI files with one filename per row. Currently, files have to be stored in the /code subdirectory.
- output_dir: Path to a directory, into which temporary files and the subfolders for each file will be created
- mask_dir: Path to the directoy, in which the ASPECTS masks contained in this repository are saved.

# Running the pipeline
To execute all steps of the pipleline consecutivly, execute run_pipeline.sh. All steps of the pipeline can also be called individually, but might not function correctly due to missing files if steps before are skipped.

# Steps of the pipeline

## 1. CTA_coregistration.sh
This script performs the following tasks:
- Measures if the input CTA source images have an extension on the z-axis greater than 180mm and truncates it to 180mm from the highest point on the z-axis if necessary.
- Extracts the brain in several steps and coregisteres it to MNI-152 brain space.
- Applies the resulting matrix file to the original, non-brain-extracted CTA file.

Note : It is highly recommended to perform additional quality control on the resulting coregistration (for example via visual inspection)

## 2. mask_coregistration.sh
This script performs the following tasks:
- Using the reverse matrix of the CTAs coregistration, coregisters the ASPECTS masks to the CTAs native space.
- Binarizes all masks
- Stores the coregistered masks in a folder in the output_dir, named after the input file.

## 3. intensity_measurement.sh
This script performs the following tasks:
- Measures the mean attenuation in Hounsfield Units (HU) for each region on both hemisspheres, including only voxels with intensities between 1 und 250 and storing the resulting means in a .csv file in the file's subfolder.

## 4. rate_aspects.sh
In this step, the following actions are performed:
- The user is prompted to enter the side of infarction (left/right) for each subject.
- The relative Houndsfield Unit (rHU) is calculated by dividing the mean Houndsfield Unit of the infarcted side by the non-infarcted side.
- The rHU is compared to the region-specific threshold stored in cutpoints.csv.
- If it is lower than the threshold, then the region is considered as infarcted and the total ASPECTS of the case is decreased by 1.
- The results are saved in a .csv file in the file's subfolder
