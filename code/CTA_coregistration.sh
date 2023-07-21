#!/bin/bash

# Import variables
source ./paths.sh

# Loop over input files
for input_file in $(cat $input_list); do
    echo "Performing coregistration to MNI-152 on $input_file "

    # Measure the 3D dimensions of the input file
    dim3=$(fslhd $input_file | grep -w 'dim3' | awk '{print $2}')
    pixdim3=$(fslhd $input_file | grep -w 'pixdim3' | awk '{print $2}')

    length_dim3_mm=$(echo "$dim3 * $pixdim3" | bc)
    
    # Limit the input file to 180mm from the uppermost point
    if (( $(echo "$length_dim3_mm > 180" | bc -l) )); then
        echo "Input file's z-axis is bigger than 180mm, truncating to 180mm"
        cut_file="${input_file%.nii.gz}_cut.nii.gz"
        new_slicecount=$(echo "180 / $pixdim3" | bc)
        z_min=$(echo "$dim3 - $new_slicecount" | bc)
        fslroi $input_file $cut_file 0 -1 0 -1 $z_min -1
        input_file=$cut_file
    fi
    
    # Set filenames for following steps
    lthr_file=${input_file%.nii.gz}_lthr.nii.gz
    uthr_file=${input_file%.nii.gz}_uthr.nii.gz
    sm_file=${input_file%.nii.gz}_sm.nii.gz
    
    # Apply a lower threshold of 2
    fslmaths $input_file -thr 2 $lthr_file
    # Apply a upper thrseshold of 500
    fslmaths $lthr_file -uthr 500 $uthr_file; rm $lthr_file
    # Apply a Gaussian kernel to smooth
    fslmaths $uthr_file -kernel gauss 1 $sm_file; rm $uthr_file

    # Perform brain extraction
    bet $sm_file ${input_file%.nii.gz}_brain.nii.gz -f 0.001; rm $sm_file
    
    # Run the registration command
    output_file="${output_dir}/${input_file%.nii.gz}_registered.nii.gz"
    flirt -in ${input_file%.nii.gz}_brain.nii.gz -ref $FSLDIR/data/standard/MNI152_T1_1mm_brain.nii.gz -out $output_dir/${input_file%.nii.gz}_brain_coreg.nii.gz -omat $output_dir/"${input_file%.nii.gz}.mat"
    
    # Apply the transformation matrix to the input file
    flirt -in $input_file -ref $FSLDIR/data/standard/MNI152_T1_1mm.nii.gz -applyxfm -init $output_dir/"${input_file%.nii.gz}.mat" -out $output_dir/${input_file%.nii.gz}_coreg.nii.gz

    # Reverse the matrix file
    convert_xfm -omat $output_dir/"${input_file%.nii.gz}_reverse.mat" -inverse $output_dir/"${input_file%.nii.gz}.mat"
done
