#!/bin/bash

# Import variables
source ./paths.sh

# Define ASPECTS regions
region_names=("C_L" "C_R" "IC_L" "IC_R" "InCa_L" "InCa_R" "LN_L" "LN_R" "M1_L" "M1_R" "M2_L" "M2_R" "M3_L" "M3_R" "M4_L" "M4_R" "M5_L" "M5_R" "M6_L" "M6_R")

# Loop over input files
for input_file in  $(cat $input_list); do
    echo "Performing atlas coregistration on $input_file"
    regions_dir=$output_dir/"${input_file%.nii.gz}"
    mkdir -p $regions_dir

    # Loop through all regions
    for region in "${region_names[@]}"; do
	flirt -in $mask_dir/MNI152_"$region".nii.gz -ref $input_file -applyxfm -init ${input_file%.nii.gz}_reverse.mat -out $regions_dir/${input_file%.nii.gz}_$region.nii.gz

	# Binarize the resulting mask
	fslmaths $regions_dir/${input_file%.nii.gz}_$region.nii.gz -bin $regions_dir/${input_file%.nii.gz}_$region.nii.gz
    done
done
