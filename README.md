# MASTER-Image-Preprocessing
Project related to various MASTER pre processing functions

For MASTER imagery to be ready for image-to-image registration the following steps must be followed:

1. create and apply glt
	BATCH: Batch_Create_Apply_GLT > master_create_apply_glt_batch.pro
	SINGLE: Single_Create_Apply_GLT > master_apply_glt_single.pro & master_create_glt_single.pro
2. layer or stack emissivity and temperature files into one file
	BATCH: Batch_Layer_Stack > layer_stack_master.pro
	SINGLE: Single_Layer_Stack > single_layer_stack_master.pro
3. Move the new files to a flightline specific folder (currently in R:\Image-To-Image Registration\)
	Miscellaneous > moving_Emis&Temp_files.py
4. Rename files so that they start with the flightline number and add extra zero for base file.
	Miscellaneous > rename_files.py
5. Crop base file to area of interest in ENVI (by hand no code)
6. Run resizing code that adds borders. 
	Batch_Resize_Plus_Borders > resize_plus_borders_master.pro
