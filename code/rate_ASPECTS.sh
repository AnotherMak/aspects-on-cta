#!/bin/bash

# Import variables
source ./paths.sh

# Loop over input files
for input_file in  $(cat $input_list); do


    echo "Calculation ASPECTS for $input_file"
    csv_file=$output_dir/${input_file%.nii.gz}/${input_file%.nii.gz}_measurements.csv
      if [ ! -f "$csv_file" ]; then
        echo "Error: CSV file '$csv_file' not found."
        exit 1
    fi

    readarray -t values_array < $output_dir/${input_file%.nii.gz}/${input_file%.nii.gz}_measurements.csv

    declare -A assoc
    for element in "${values_array[@]}"; do
        IFS=',' read -r name value <<< "$element"
        assoc["$name"]="$value"
    done

    # Ask the user to input the side
    read -p "Enter the side of occlusion for $input_file (left or right): " side

    # Check if the side is either left or right
    if [[ "$side" == "left" ]]; then
         side="L"
         contralateral="R"
    elif [[ "$side" == "right" ]]; then
         side="R"
         contralateral="L"
    # Else throw error and exit
    else
         echo "Invalid input. Please enter either 'left' or 'right'."
         exit 1
    fi
    
    # Calculate ratios
    regions=("C" "IC" "InCa" "LN" "M1" "M2" "M3" "M4" "M5" "M6")

    declare -A aarray_ratios

    for region in ${regions[@]}; do
        region_ratio=$(echo "${assoc["$region"_"$side"]} / ${assoc["$region"_"$contralateral"]}" | bc -l)
        aarray_ratios["$region"]=$region_ratio
    done

    # Compare ratios to threshold and rate region
    # Load thresholds from .csv
    readarray -t array_cutpoints < cutpoints.csv

    # Turn into an assiotative array
    declare -A aarray_cutpoints
    for element in "${array_cutpoints[@]}"; do
        IFS=',' read -r name value <<< "$element"
        aarray_cutpoints["$name"]="$value"
    done
  
    # Compare ratios to threshold and rate region
    ASPECTS=10
    declare -A aarray_infarction

    for region in ${regions[@]}; do
        if (( $(echo "${aarray_ratios["$region"]} < ${aarray_cutpoints["$region"]}" |bc -l) )); then
             aarray_infarction["$region"]="1"
             let "ASPECTS-=1"
        else
             aarray_infarction["$region"]="0"
        fi
    done
    
    # Create strings for the header and content of the results .csv file
    header=File
    results=$input_file
    for region in ${regions[@]}; do
        header+=","$region
        results+=","${aarray_infarction["$region"]}
    done
    header+=",rHU-ASPECTS"
    results+=","$ASPECTS

    # Print the header and results to the results .csv file
    echo $header > $output_dir/${input_file%.nii.gz}/${input_file%.nii.gz}_results.csv
    echo $results >> $output_dir/${input_file%.nii.gz}/${input_file%.nii.gz}_results.csv
done
