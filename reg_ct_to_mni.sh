#!/bin/bash

if [[ "$1" == "-h" || $# -eq 0 ]]; then
    echo "Usage:"
    echo "$(basename $0) path_to_data path_to_masks"
    echo "-------------------------------------------------------------------------"
    echo "This script takes the path to the CT data folder and path to masks folder"
    echo "registers CT images and their masks to MNI space using skull"
    echo "and computes a frequency map of the masks"
    echo "Assumption: The name of image and its corresponding mask are the same."
    echo "-------------------------------------------------------------------------"
    echo "Script created by : Yuexin Xi (10-2023), yuexinxi0220@outlook.com"
    echo "Dependencies      : FMRIB Software Library"
    echo "Learn more        : https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/"
    echo "-------------------------------------------------------------------------"
    exit 1
fi


image_dir=$1
mask_dir=$2

list_image=`ls $image_dir`

# check mask existence
for filename in $list_image; do
    if ! [ -e ${mask_dir}/${filename} ]; then
        echo "The mask of ${filename} does not exist."
        exit 1
        fi
    done

# remove suffix + assume masks have the same name as images
list_image=$($FSLDIR/bin/remove_ext $list_image)
list_image=($list_image)
echo "Processing the following images:"
echo ${list_image[@]}
#n=${#list_image[@]}

# create new array for processed masks
list_mask=()

for filename in ${list_image[@]}
do
    # reorient CT to standard space
    fslreorient2std \
        ${image_dir}/${filename} \
        ${image_dir}/${filename}_reorient

    # reorient mask to standard space
    fslreorient2std \
        ${mask_dir}/${filename} \
        ${mask_dir}/${filename}_mask_reorient

    # register the reoriented images to MNI skull
    flirt \
        -in ${image_dir}/${filename}_reorient \
        -ref $FSLDIR/data/standard/MNI152_T1_2mm_skull.nii.gz \
        -dof 7 \
        -out ${image_dir}/${filename}_reg_to_mni \
        -omat ${image_dir}/${filename}_reg_to_mni

    # register the reoriented mask to MNI with transformation matrix obtained above
    flirt \
        -in ${mask_dir}/${filename}_mask_reorient \
        -ref $FSLDIR/data/standard/MNI152_T1_2mm_skull.nii.gz \
        -init ${image_dir}/${filename}_reg_to_mni \
        -dof 7 \
        -out ${mask_dir}/${filename}_mask_reg_to_mni \
        -omat ${mask_dir}/${filename}_mask_reg_to_mni \
        -applyxfm

    # re-threshold the mask with threshold = 0.5
    fslmaths \
        ${mask_dir}/${filename}_mask_reg_to_mni \
        -thr 0.5 \
        -bin ${mask_dir}/${filename}_mask_reg_to_mni

    list_mask+=("${mask_dir}/${filename}_mask_reg_to_mni")
done

# merge all registered masks into one 4D array
fslmerge \
    -t \
    frequency_map_mni.nii.gz \
    ${list_mask[@]}

# calculate frequency
fslmaths \
    frequency_map_mni.nii.gz \
    -Tmean \
    frequency_map_mni.nii.gz

: '
# register the reoriented images to MNI skull
# flirt \
#    -in 004_reorient.nii.gz \
#    -ref $FSLDIR/data/standard/MNI152_T1_2mm.nii.gz \
#    -dof 7 \
#    -out reg_004_reorient_to_mni \
#    -omat reg_004_reorient_to_mni \
#    -searchrx -10 10 \
#    -searchry -10 10 \ 
#    -searchrz -10 10
'
