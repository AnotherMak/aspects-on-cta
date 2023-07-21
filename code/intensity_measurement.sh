#!/bin/bash

# Import variables
source ./paths.sh

# Define ASPECTS regions
region_names=("C_L" "C_R" "IC_L" "IC_R" "InCa_L" "InCa_R" "LN_L" "LN_R" "M1_L" "M1_R" "M2_L" "M2_R" "M3_L" "M3_R" "M4_L" "M4_R" "M5_L" "M5_R" "M6_L" "M6_R")

# Loop over input files
for input_file in  $(cat $input_list); do

    echo "Measuring intensites on $input_file"
    # Create the csv-file to store the intensity measurement
    output_csv=$output_dir/${input_file%.nii.gz}/${input_file%.nii.gz}_measurements.csv
    echo Region,MeanIntensity > $output_csv

    # Loop through all regions
    for region in "${region_names[@]}"; do
	mean_intensity=$(fslstats $input_file -k $output_dir/${input_file%.nii.gz}/${input_file%.nii.gz}_$region.nii.gz -l 0 -u 251 -M)
        echo "$region,$mean_intensity" >> $output_csv
    done
done
