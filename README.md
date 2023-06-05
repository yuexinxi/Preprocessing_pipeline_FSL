# Preprocessing_pipeline_FSL
## bto_dualecho_fieldmap.sh
- This script takes the following arguments: 1st echo magnitude image, 2nd echo magnitude image, 1st echo phase image, 2nd echo phase image and delta TE (optional) to generate the fieldmap and json file in BIDS specification.
- Dependencies: [Synthstrip](https://surfer.nmr.mgh.harvard.edu/docs/synthstrip/), [FSL](https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FslInstallation), [jq](https://jqlang.github.io/jq/)
- Example:
```
bto_dualecho_fieldmap.sh --mag1=sub-01_ses-01_acq-GRE_run-1_echo-1_part-mag_T2starw.nii.gz --mag2=sub-01_ses-01_acq-GRE_run-1_echo-2_part-mag_T2starw.nii.gz --phs1=sub-01_ses-01_acq-GRE_run-1_echo-1_part-phase_T2starw.nii.gz --phs2=sub-01_ses-01_acq-GRE_run-1_echo-2_part-phase_T2starw.nii.gz --dte=2.46
```

## phasediff_fieldmap.sh
- This script takes the following arguments: 1st echo magnitude image, 2nd echo magnitude image, phasediff image and delta TE (optional) to generate the fieldmap and json file in BIDS specification.
- Dependencies: [Synthstrip](https://surfer.nmr.mgh.harvard.edu/docs/synthstrip/), [FSL](https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FslInstallation), [jq](https://jqlang.github.io/jq/)
- Example: 
```
phasediff_fieldmap.sh --mag1=sub-01_ses-01_acq-GRE_run-1_echo-1_magnitude1.nii.gz --mag2=sub-01_ses-01_acq-GRE_run-1_echo-2_magnitude2.nii.gz --phs=sub-01_ses-01_acq-GRE_run-1_echo-1_phasediff.nii.gz --dte=2.46
```

## run_fsl_flirt.py
- This script takes the following arguments: functional image, reference anatomical image, white matter sementation and fieldmap (optional) to perform registration of functional image to anatomical image based on boundary based registration. This is the same method as what fMRIPrep uses (by 23.0.2).
- Dependencies: [nipype](https://nipype.readthedocs.io/en/latest/users/install.html)
- Example:
```
python run_fsl_flirt.py sub-01_ses-01_task-rest_run-01_bold.nii.gz sub-01_acq-MPRAGE_run-01_T1w.nii.gz sub-01_acq-MPRAGE_run-03_label-WM_probseg.nii.gz nofieldmap
```

## run_fsl_topup.py
- This script takes the following arguments: two functional images of opposite phase encoding direction (with their metadata json files. Make sure the "AcquisitionMatrixPE" and "EffectiveEchoSpacing" fields are available) and the unwarp direction to perform distortion correction of functional image with topup method. The results will either be in the current directory or in a new directory ./output/contrasts/ depending on the method chosen.
- Dependencies: [nipype](https://nipype.readthedocs.io/en/latest/users/install.html) or [FSL](https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FslInstallation)
- Example:
```
python run_fsl_topup.py sub-01_ses-01_task-rest_dir-AP_bold.nii.gz sub-01_ses-01_task-rest_dir-PA_bold.nii.gz y-
```
