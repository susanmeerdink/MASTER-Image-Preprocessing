PRO master_create_apply_glt_batch
  ;this program creates geographic lookup tables for MASTER imagery from the HyspIRI airborne
  ;campaign. It will go through the test folder and create a glt for each file put in the folder
  ;Susan Meerdink 8/4/15
  ;----------------------------------------------------------
  ; Open/Start ENVI
  compile_opt strictarr
  ENVI, /RESTORE_base_save_files
  envi_batch_init

  ;Select input files
  fileDir = FILEPATH('', ROOT_DIR = 'R:\MASTER_Imagery\Santa Barbara 20140604\') ;Change this to your directory!

  ;Makes directory names for each FL would need to change 'SN' if another Flight box and 11 to the number of flight boxes in your series
  fl_list = make_array(1,11,/string)
  for i = 1,11,1 do begin ;Right now goes from FL02_FL03
    if (i LT 10) then begin ;Add zero in front of number
      stri = string(0) + string(i)
    endif else begin ;Unless it's 10 or Greater (don't add zero in front)
      stri = string(i)
    endelse
    fl_list[0,(i-1)] = STRCOMPRESS('FL'+stri,/REMOVE_all) ;Create the list of folders
  endfor

  ;Loop through flightline folders (FL01, FL02, FL03,....)
  foreach element,fl_list do begin
    print, 'Starting with ' + element
    fpath = fileDir + element + '\' ;Set filepath and change directory
    cd, fpath
    
    ;Search for files 
    locationFile = File_Search(fpath + '*location.dat');Currently will only find .dat products
    emissivityFile = File_Search(fpath + '*-emissivity_tes.dat');Currently will only find .dat products
    tempFile = File_Search(fpath +'*-surface_temp.dat');Currently will only find .dat products
    
;;;;;;;;;;;;GENERATE GLT;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;Open Location File
    envi_open_file, locationFile, r_fid = locFID
    if locFID LT 0 then begin ;if the location file doesn't exist go on to the next folder
      continue
    endif
    PRINT, 'Creating GLT for: ' + locationFile

    ;Variables for GLT
    envi_file_query, locFID, SNAME = sname, DIMS = dims   ;dims defines the spatial subset (of a file or array) to use for processing
    i_proj = envi_proj_create(/geographic) ;Use this keyword to specify the input projection for the x and y map location images.
    o_proj = envi_proj_create(/utm, zone = 11, south = north) ;Use this keyword to specify the output projection for the GLT file. /utm,zone=11,datum='North America 1983'
    WHILE (((N = STRPOS(sname, '.dat'))) NE -1) DO STRPUT, sname, '_glt.dat', N
    out_loc_name = fileDir + element + '\' + sname;Use this keyword to specify a string with the output filename for the resulting data.
    pixel_size = 36 ;Set this keyword to a scalar value that represents both the x and y pixel size of the output GLT image.

    ;Create GLT
    envi_glt_doit, $
      DIMS = dims, $
      I_PROJ = i_proj, $ ;specify the input projection for the x and y map location images
      O_PROJ = o_proj,$ ;specify the output projection for the GLT file.
      OUT_NAME = out_loc_name, $ ;specify a string with the output filename for the resulting data.
      X_FID = locFID, $ ;input file FID
      X_POS = 1, $ ; longitude or band 2
      Y_FID = locFID, $ ;input file FID
      Y_POS = 0, $ ;latitude or band 1
      PIXEL_SIZE = pixel_size, $ ;Set this keyword to a scalar value that represents both the x and y pixel size of the output GLT image. 
      R_FID = out_loc_fid ;Return file FID
    ;,/SUPER, $
    
    PRINT, 'Completed GLT for: ' + locationFile
;;;;;;;;;;;APPLY GLT TO EMISSIVITY;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;open emissivity file
    envi_open_file, emissivityFile, r_fid = emissFID
    PRINT, 'Applying GLT to: ' + emissivityFile
    
    ;Get file information about image to be georefenced
    ENVI_file_query, emissFID,$ ;Get information about file
      DIMS = dimRaster,$ ;The dimensions of the image
      NB = nbRaster,$ ;Number of bands in image
      BNAMES = bnames,$ ;Band names of image
      NS = nsRaster, $ ;Number of Samples
      NL = nlRaster,$ ;Number of lines
      WL = wl,$ ;WAvelengths of image
      File_Type = ft, $ ;File Type
      DATA_TYPE = data_type, $ ;File data types
      OFFSET = offset, $ ;Use this keyword to specify the offset (in bytes) to the start of the data in the file.
      INTERLEAVE = interleave, $ ;specify the interleave output: 0: BSQ,1: BIL,2: BIP
      FNAME = file_name, $ ;contains the full name of the file (including path)
      BBL = bbl,$;Bad Band List
      SNAME = sname ;just file name (no path)

    ;variables for applying GLT
    WHILE (((N = STRPOS(sname, '.dat'))) NE -1) DO STRPUT, sname, '_GeoRef.dat', N
    out_georef_name = fileDir + element + '\' + sname;Use this keyword to specify a string with the output filename for the resulting data.
    
    ;Georeference from GLT
    ENVI_DOIT,'ENVI_GEOREF_FROM_GLT_DOIT', $
      FID = emissFID,$ ;file ID
      BACKGROUND = 0, $ ;specify the value for all background pixels
      GLT_FID = out_loc_fid,$ ;specify the file ID of the input GLT file
      OUT_NAME = out_georef_name,$ ;keyword to specify a string with the output filename for the resulting data
      POS = INDGEN(nbRaster) ;specify an array of band positions (INDGEN function returns an array with the specified dimensions)
    
    PRINT, 'Completed Georeferencing for: ' + emissivityFile

;;;;;;;;;;;;;;;APPLY GLT TO TEMP;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;open temperature file
    envi_open_file, tempFile, r_fid = tempFID
    PRINT, 'Applying GLT to: ' + tempFile
    
    ;Get file information about image to be georefenced
    ENVI_file_query, tempFID,$ ;Get information about file
      DIMS = dimRaster,$ ;The dimensions of the image
      NB = nbRaster,$ ;Number of bands in image
      BNAMES = bnames,$ ;Band names of image
      NS = nsRaster, $ ;Number of Samples
      NL = nlRaster,$ ;Number of lines
      WL = wl,$ ;WAvelengths of image
      File_Type = ft, $ ;File Type
      DATA_TYPE = data_type, $ ;File data types
      OFFSET = offset, $ ;Use this keyword to specify the offset (in bytes) to the start of the data in the file.
      INTERLEAVE = interleave, $ ;specify the interleave output: 0: BSQ,1: BIL,2: BIP
      FNAME = file_name, $ ;contains the full name of the file (including path)
      BBL = bbl, $ ;Bad Band List
      SNAME = sname ;Short name for file (no path)
    
    ;variables for applying GLT
    WHILE (((N = STRPOS(sname, '.dat'))) NE -1) DO STRPUT, sname, '_GeoRef.dat', N
    out_temp_name = fileDir + element + '\' + sname;Use this keyword to specify a string with the output filename for the resulting data.
    if nbRaster EQ 1 then begin
      pos = 0
    endif else begin
      pos = INDGEN((nbRaster))
    endelse
    
    ;Georeference from GLT
    ENVI_DOIT,'ENVI_GEOREF_FROM_GLT_DOIT', $
      FID = tempFID,$ ;file ID
      GLT_FID = out_loc_fid,$ ;specify the file ID of the input GLT file
      OUT_NAME = out_temp_name,$ ;keyword to specify a string with the output filename for the resulting data
      POS = pos ;specify an array of band positions
    
    PRINT, 'Completed Georeferencing for: ' + tempFile

    ;Close files before moving on to next flightline
    close, /ALL

  endforeach ;Loops through flightlines 


END ; END OF FILE