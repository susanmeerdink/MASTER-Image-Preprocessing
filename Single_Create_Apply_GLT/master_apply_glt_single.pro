PRO master_apply_glt_single
;Susan Meerdink
;Created 5/2/2016
;This file applies a GLT that has already been created to a single file.
;Set this code directly to the file that contains the GLT (geographic look up table) Information. 

;Start Application
COMPILE_OPT STRICTARR
envi, /restore_base_save_files
ENVI_BATCH_INIT

gltfilename = 'R:\users\susan.meerdink\IDL_Code\Testing_Data\MASTERL2_1393800_03_20130411_1851_1910_V01-location_GLT' ;Set to location file that contains GLT information
infilename = 'R:\users\susan.meerdink\IDL_Code\Testing_Data\MASTERL2_1393800_03_20130411_1851_1910_V01-surface_temp.dat' ;Set to the file you want to georeference

ENVI_OPEN_FILE, infilename, r_fid = fidIN ;open input file
ENVI_OPEN_FILE, gltfilename, r_fid = fidGLT ;open input file

ENVI_FILE_QUERY, fidIN, $; query file information to set dimensions for function
  nb = nbRaster, $ ;number of bands
  fname = fullname, $ ;full name of file (includes path)
  dims = INdims ;Dimensions of Input Image

;variables for applying GLT
WHILE (((N = STRPOS(fullname, '.dat'))) NE -1) DO STRPUT, fullname, '_GeoRef.dat', N

PRINT, 'Applying GLT for ' + filename

;Georeference from GLT
ENVI_DOIT,'ENVI_GEOREF_FROM_GLT_DOIT', $
  FID = fidIN,$ ;file ID
  BACKGROUND = 0, $ ;specify the value for all background pixels
  GLT_FID = fidGLT,$ ;specify the file ID of the input GLT file
  OUT_NAME = fullname,$ ;keyword to specify a string with the output filename for the resulting data
  POS = INDGEN(nbRaster) ;specify an array of band positions (INDGEN function returns an array with the specified dimensions)

envi_file_mng, id = fidIN, /remove, /no_warning ;Close input file
envi_file_mng, id = fidGLT, /remove, /no_warning ;Close GLT file 

PRINT, 'Done Applying GLT for ' + filename
END
