PRO master_create_glt_single
;Susan Meerdink
;Created 5/2/2016
;This file creates a GLT for a single flightline, but does not apply the GLT to any files.
;Set this code directly to the file that contains the GLT (geographic look up table) Information. 

;Start Application
COMPILE_OPT STRICTARR
envi, /restore_base_save_files
ENVI_BATCH_INIT

filename = 'R:\users\susan.meerdink\IDL_Code\Testing_Data\MASTERL2_1393800_03_20130411_1851_1910_V01-location' ;Set to location file that contains GLT information
outname = filename + '_glt' ; Set output name for file
ENVI_OPEN_FILE, filename, r_fid = fid1 ;open file

ENVI_FILE_QUERY, fid1, $; query file information to set dimensions for function
  dims = INdims ;Dimensions of Input Image

;Variables for GLT creation
i_proj = envi_proj_create(/geographic) ;Use this keyword to specify the input projection for the x and y map location images.
o_proj = envi_proj_create(/utm, zone = 11, south = north) ;Use this keyword to specify the output projection for the GLT file. 
pixel_size = 36 ;Set this keyword to a scalar value that represents both the x and y pixel size of the output GLT image.

PRINT, 'Creating GLT for ' + filename

ENVI_DOIT, 'ENVI_GLT_DOIT',$ ; Create GLT
  DIMS = INdims, $ ; five-element array of long integers that defines the spatial subset to use for processing
  I_PROJ = i_proj, $ ;keyword to specify the input projection for the x and y map location images. 
  O_PROJ = o_proj, $ ;specify the output projection for the GLT file.
  OUT_NAME = outname, $ ;keyword to specify a string with the output filename for the resulting data. (can set to in memory)
  PIXEL_SIZE = pixel_size, $ ;keyword to a scalar value that represents both the x and y pixel size of the output GLT image.
  X_FID = xy, $ ;keyword to specify the file ID for the x map projection values file.
  X_POS = 1, $ ; keyword to specify the band position of the x map projection values.
  Y_FID = xy, $ ;keyword to specify the file ID for the y map projection values file.
  Y_POS = 0, $ ; keyword to specify the band position of the y map projection values.
  R_FID = rfid ;named variable containing the file ID to access the processed data

envi_file_mng, id = fid1, /remove, /no_warning ;Close location file (input file)
envi_file_mng, id = rfid, /remove, /no_warning ;Close GLT file (output file)

PRINT, 'Done GLT for ' + filename
END
