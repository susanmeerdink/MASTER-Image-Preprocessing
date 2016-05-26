PRO single_layer_stack_master
; This code stacks the MASTER emissivity and surface temperature file.
; It does not use the ENVI layer function because that function projects the new image and rotates it
; The files (to be resized) must be in 0 rotation (North to South). 
; This code also changes the image into Data Type 3 instead of the original Data Type 14 - which cannot be read in
; R or new ENVI. 
;Susan Meerdink
;5/26/2016
;--------------------------------------------------------------------------
;;; INPUTS ;;;
main_path = 'R:\MASTER_Imagery\' ; Set directory that holds all flightlines
flightbox_name = 'Santa Barbara 20131125' ;Name of flightbox to be processed 
;;; INPUTS DONE ;;

;;; SETTING UP ENVI/IDL ENVIRONMENT ;;;
COMPILE_OPT STRICTARR
envi, /restore_base_save_files
ENVI_BATCH_INIT ;Doesn't require having ENVI open - use with stand alone IDL 64 bit
;;; DONE SETTING UP ENVI/IDL ENVIRONMENT ;;;

;;; SETTING UP FLIGHTLINE FOLDERS ;;;
fl_date_list = ['FL04']
;;; DONE SETTING UP FLIGHTLINE FOLDERS ;;;

;;; PROCESSING ;;;
FOREACH single_flightline, fl_date_list DO BEGIN ;;; LOOP THROUGH FLIGHT DATES ;;;
  print, 'Starting ' + single_flightline ;Print which flightdate is being processed
  pathDir = main_path + flightbox_name + '\' + single_flightline + '\'

  emis_file_list = FILE_SEARCH(pathDir,'*emissivity_tes_Geo*')
  temp_file_list = FILE_SEARCH(pathDir,'*surface_temp_Geo*')
  
  ENVI_OPEN_FILE,emis_file_list[0],R_FID = fidEmis ;Open the emissivity file
  ENVI_OPEN_FILE, temp_file_list[0],R_FID = fidTemp ;Open the temperature file
  
  ENVI_FILE_QUERY, fidEmis, $ ;Get info about emissivity file
    NB = emis_bands, $ ; Number of bands
    NS = numSamples, $ ;Number of samples
    NL = numLines, $ ;Number of lines
    DATA_TYPE = emis_dt, $ ;Data Type
    WL = emis_WL, $ ;Wavelength values
    SNAME = emis_name_short ;short file name for emissivity file
    
  ENVI_FILE_QUERY, fidTemp, $ ; Get info about temperature file
    NB = temp_bands; Number of bands
    
  map_info = ENVI_GET_MAP_INFO(FID = fidEmis)
  
  outImage = MAKE_ARRAY([numSamples, (emis_bands + temp_bands), numLines], TYPE = 3, VALUE = 0) ;Create empty array for output image with Long integer (32 bits) data type
  countLine = 0 ;Counter for array assignment in loop
  
  ;;; GET DATA & ASSIGN TO RESIZED IMAGE ;;;
  FOR i = 0, (numLines-1) DO BEGIN ;Loop through lines of image
    emisData = ENVI_GET_SLICE(/BIL, FID = fidEmis, LINE = i, POS = INDGEN(emis_bands), XS = 0, XE = numSamples-1) ;Get Data from new image (returns in BIL format)
    tempData = ENVI_GET_SLICE(/BIL, FID = fidTemp, LINE = i, POS = INDGEN(temp_bands), XS = 0, XE = numSamples-1) ;Get Data from new image (returns in BIL format)
    ;              LINE = keyword to specify the line number to extract the slice from. LINE is a zero-based number.
    ;              POS = keyword to specify an array of band positions
    ;              XE = keyword to specify the x ending value. XE is a zero-based number.
    ;              XS = keyword to specify the x starting value. XS is a zero-based number.
    ;              /BIL = keyword that make data returned in BIL format - dimensions of a BIL slice are always [num_samples, num_bands]               
    outLine = [[emisData],[tempData]];Assign Data to new array
    outImage[0,0,countLine] = outLine ;Assign Array
    countLine = countLine + 1 ;Advance counter used in array assignment 
  ENDFOR
  ;;; DONE GETTING DATA & ASSIGNING TO RESIZED IMAGE ;;; 
  
  ;;; WRITE DATA TO ENVI FILE ;;;
  fileOutput = pathDir + STRMID(emis_name_short,0,(STRPOS(emis_name_short,'-')+1)) + 'emissivity&temp' ;Set file name for new image
  fileOutputTemp = pathDir + STRMID(emis_name_short,0,(STRPOS(emis_name_short,'-')+1)) + 'emissivity&tempBIL' ;Set file name for new BSQ image
  
  ENVI_WRITE_ENVI_FILE, outImage, $ ; Data to write to file
    OUT_NAME = fileOutputTemp, $ ;Output file name
    NB = (emis_bands + temp_bands), $; Number of Bands
    NL = numLines, $ ;Number of lines
    NS = numSamples, $ ;Number of Samples
    INTERLEAVE = 1 , $ ;Set this keyword to one of the following integer values to specify the interleave output: 0: BSQ 1: BIL 2: BIP
    R_FID = fidInter, $ ;Set keyword for new file's FID
    OFFSET = 0 ; Use this keyword to specify the offset (in bytes) to the start of the data in the file.
  ;;; DONE WRITING DATA TO ENVI FILE ;;;

  ;;; CONVERT TO BSQ ;;;
  ENVI_FILE_QUERY,fidInter, DIMS = new_dims, NS = new_samples, NL = new_lines, NB = new_bands
  ENVI_DOIT, 'CONVERT_DOIT', $
    DIMS = new_dims, $ ;five-element array of long integers that defines the spatial subset
    FID = fidInter, $ ;Set for new file's fid
    OUT_NAME = fileOutput, $ ; Set new files output name
    R_FID = fidFinal, $ ;Set BSQ file fid
    O_INTERLEAVE = 0, $ ;keyword that specifies the interleave output: 0: BSQ, 1: BIL, 2: BIP
    POS =  INDGEN(new_bands) ;specify an array of band positions
  ;;; DONE CONVERTING TO BSQ ;;;

  ;;; CREATING ENVI HEADER FILE ;;;
  raster_wl = [string(emis_WL),'surface_temp']
  ENVI_SETUP_HEAD, $
    fname = fileOutput + '.hdr', $ ;Header file name
    NS = new_samples,$ ;Number of samples
    NL = new_lines, $ ;Number of lines
    data_type = 3,$ ; Data type of file
    interleave =  0, $ ;specify the interleave output: 0: BSQ,1: BIL,2: BIP
    NB = new_bands,$ ;Number of Bands
    map_info = map_info, $ ;Map Info - set to the base image since raster has been resized.
    bnames = raster_wl, $ ;Bands Names
    /write
  ;;; DONE CREATING ENVI HEADER FILE ;;;

  ;;; CLOSING ;;;
  envi_file_mng, ID = fidEmis, /remove ;Close current Raster image
  envi_file_mng, ID = fidTemp, /remove ;Close current Raster image
  envi_file_mng, ID = fidInter, /remove ;Close current Raster image
  envi_file_mng, ID = fidFinal, /remove ;Close current Raster image
  FILE_DELETE, fileOutputTemp ;Delete the temporary BIL formatted image
  FILE_DELETE, fileOutputTemp + '.hdr' ;Delete the temporary BIL formatted image
  ;;; DONE CLOSING ;;;
  
  print,'Completed' + single_flightline
   
ENDFOREACH  ;;; LOOP THROUGH FLIGHT DATES ;;;

END