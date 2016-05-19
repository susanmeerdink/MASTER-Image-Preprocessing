PRO layer_stack_master
;
;Susan Meerdink
;5/11/2016
;--------------------------------------------------------------------------
;;; INPUTS ;;;
main_path = 'R:\MASTER_Imagery\' ; Set directory that holds all flightlines
flightbox_name = 'Santa Barbara' ;Name of flightbox to be processed (SB for Santa Barbara, SN for Sierra Nevada)
;;; INPUTS DONE ;;

;;; SETTING UP ENVI/IDL ENVIRONMENT ;;;
COMPILE_OPT STRICTARR
envi, /restore_base_save_files
ENVI_BATCH_INIT ;Doesn't require having ENVI open - use with stand alone IDL 64 bit
;;; DONE SETTING UP ENVI/IDL ENVIRONMENT ;;;

;;; SETTING UP FLIGHTLINE FOLDERS ;;;
fl_date_list = FILE_SEARCH(main_path,(flightbox_name + '*'))
;;; DONE SETTING UP FLIGHTLINE FOLDERS ;;;

;;; PROCESSING ;;;
FOREACH single_date, fl_date_list DO BEGIN ;;; LOOP THROUGH FLIGHT DATES ;;;
  print, 'Starting ' + single_date ;Print which flightdate is being processed
  fl_list = FILE_SEARCH(single_date,'FL??\') ;Get the flightlines for each date

  FOREACH single_flightline, fl_list DO BEGIN ;;;LOOP THROUGH FLIGHTLINES;;;
    print,'Starting ' + single_flightline ;Print which flightline is being processed
    emis_file_list = FILE_SEARCH(single_flightline,'*emissivity_tes_Geo*')
    temp_file_list = FILE_SEARCH(single_flightline,'*surface_temp_Geo*')
    
    ENVI_OPEN_FILE,emis_file_list[0],R_FID = emis_raster ;Open the emissivity file
    ENVI_OPEN_FILE, temp_file_list[0],R_FID = temp_raster ;Open the temperature file
    
    ENVI_FILE_QUERY, emis_raster, $ ;Get info about emissivity file
      NB = emis_bands, $ ; Number of bands
      NS = emis_ns, $ ;Number of samples
      NL = emis_nl, $ ;Number of lines
      DIMS = emis_dims, $ ;Dimensions of image
      DATA_TYPE = emis_dt, $ ;Data Type
      SNAME = emis_name_short ;short file name for emissivity file
      
    ENVI_FILE_QUERY, temp_raster, $ ; Get info about temperature file
      NB = temp_bands, $; Number of bands
      NL = temp_nl, $ ;number of lines
      NS = temp_ns ; Number of samples

    emis_proj = ENVI_GET_PROJECTION(FID = emis_raster, PIXEL_SIZE = emis_ps)
    
    outFileName = single_flightline + '\' + STRMID(emis_name_short,0,(STRPOS(emis_name_short,'-')+1)) + 'emissivity&temp'
    
    nb = emis_bands + temp_bands
    fidIn = lonarr(nb)
    posIn = lonarr(nb)
    dimsIn = lonarr(5,nb)
    for i = 0L, emis_bands - 1 do begin
      fidIn[i] = emis_raster
      posIn[i] = i
      dimsIn[0,i] = [-1,0,emis_ns-1,0,emis_nl-1]
    endfor
    ;
    for i = emis_bands, nb - 1 do begin
      fidIn[i] = temp_raster
      posIn[i] = i - emis_bands
      dimsIn[0,i] = [-1,0,temp_ns-1,0,temp_nl-1]
    endfor
    
    ENVI_DOIT, 'ENVI_LAYER_STACKING_DOIT', $ ; Use this procedure to build a new multi-band file from georeferenced images of various pixel sizes, extents, and projections.
      DIMS = dimsIn,$ ;keyword is a five-element array of long integers that defines the spatial subset
      FID = fidIn,$ ;keyword to specify the file IDs for the input files. 
      OUT_NAME = outFileName,$ ;keyword to specify a string with the output filename for the resulting data.
      OUT_DT  = emis_dt, $ ;Keyword to specify data type 14 = long 64 bit integer
      OUT_PROJ = emis_proj,$ ; keyword to specify the output projection for the layer-stacked file.
      OUT_PS = emis_ps,$ ;keyword to specify the output x and y pixel size. 
      POS = posIn,$ ;keyword to specify an array of band positions POS is an array of long integers with one entry for each input file, with values ranging from 0 to the number of bands minus 1.
      R_FID = outFID;routines that result in new images also have an R_FID, or “returned FID.” 
    
    if outFID EQ -1 then begin
      print, 'Error in processing ' + single_flightline
    endif

    envi_file_mng, ID = emis_raster, /remove ;Close current Raster image
    envi_file_mng, ID = temp_raster, /remove ;Close current Raster image
    envi_file_mng, ID = outFID, /remove ;Close current Raster image
  ENDFOREACH ;;;LOOP THROUGH FLIGHTLINES;;;
   
ENDFOREACH  ;;; LOOP THROUGH FLIGHT DATES ;;;

END