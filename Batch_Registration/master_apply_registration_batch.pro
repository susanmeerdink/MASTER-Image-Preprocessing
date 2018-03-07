PRO master_apply_registration_batch
;This code does image to image registration using GCPs collected
;
;Susan Meerdink
;2/21/17

;-------------------------------------------------------------------------------------
;;; SETTING UP ENVI/IDL ENVIRONMENT ;;;
COMPILE_OPT STRICTARR
envi, /restore_base_save_files
ENVI_BATCH_INIT ;Doesn't require having ENVI open - use with stand alone IDL 64 bit
;;; DONE SETTING UP ENVI/IDL ENVIRONMENT ;;;

;;; INPUTS ;;;
main_path = 'D:\Imagery\MASTER\' ; Set directory that holds all flightlines
;fl_list = ['FL02','FL03','FL04','FL05','FL06','FL07','FL08','FL09','FL10','FL11'] ;Create the list of folders
fl_list = ['FL02'] ;Create the list of folders
basemap = 'D:\Basemap\SBbox_36m_flightline_1_to_11_PA' ;Set to basemap for GCPs

;;; OPEN BASEFILE
ENVI_open_file, basemap, R_FID = fidBase ;Open the file

;;; PROCESSING ;;;
FOREACH single_flightline, fl_list DO BEGIN ;;; LOOP THROUGH FLIGHTLINES ;;;
  print, 'Starting with ' + single_flightline ;Print which flightline is being processed
  flightline_path = main_path + single_flightline + '\4 - Rotated 35 Degree Files\' ; Set path for flightline that is being processed
  cd, flightline_path ;Change Directory to flightline that is being processed
  
  ;; SETTING UP GCP File ;;
  gcpFile = file_search(main_path + single_flightline + '\*.pts') ;Get the GCPs for this flightline
  RESTORE,'C:\Users\Susan\Documents\GitHub\MASTER-Image-Preprocessing\Batch_Registration\gcpTemplate.sav' ;load in saved template
  gcp = read_ascii(gcpFile,TEMPLATE = gcpTemplate) ; opens prompt to load in ascii file. Skip to line 6, separate via white space, and have four separate fields
  numPts = size(gcp.XMap,/N_ELEMENTS); Get the number of points/rows
  gcpFormat = dblarr(4,numPts )
  gcpFormat[0,*] = gcp.XMap
  gcpFormat[1,*] = gcp.YMap
  gcpFormat[2,*] = gcp.XImage
  gcpFormat[3,*] = gcp.YImage
  
  ;;; LOOPING THROUH OTHER IMAGES ;;;
  image_list = file_search('*140416*') ;Get list of all images in flightline that have been rotated
  FOREACH single_image, image_list DO BEGIN ; Loop through all images for a single flightline
    IF strmatch(single_image,'*.hdr') EQ 0 THEN BEGIN ;If the file being processed isn't a header,text, or GCP file proceed
      ;;; BASIC FILE INFO ;;;
      print, 'Processing: ' + single_image
      ENVI_open_file, single_image, R_FID = fidIn ;Open the file
      ENVI_file_query, fidIn,$ ;Get information about file
        DIMS = raster_dims,$ ;The dimensions of the image
        NB = raster_bands,$ ;Number of bands in image
        BNAMES = raster_band_names,$ ;Band names of image
        NS = raster_samples, $ ;Number of Samples
        NL = raster_lines,$ ;Number of lines
        WL = raster_wl,$ ;WAvelengths of image
        DATA_TYPE = raster_data_type, $ ;File data types
        SNAME = raster_file_name, $ ;contains the full name of the file (including path)
        BBL = raster_bbl ;Bad Band List
      
      ;;; REGISTRATION ;;;
      I = strpos(raster_file_name,'rot35')
      strput,raster_file_name,'Regis',I
      outputName = flightline_path + raster_file_name;Set output name for registration image
      ENVI_DOIT,'ENVI_REGISTER_DOIT', $
        B_FID = fidBase, $ ;keyword to specify the file ID for the base file
        PTS = gcpFormat, $ ; keyword to specify an array of double-precision values representing the x and y positions of the base and warp tie points
        W_FID = fidIn, $ ;keyword to specify the file ID for the warp file
        W_POS = INDGEN(raster_bands), $ ;keyword to specify an array of band positions for the warp image indicating the band numbers on which to perform the operation
        W_DIMS = raster_dims, $ ;specify the spatial dimensions of the warp image (W_FID) on which to perform the operation
        OUT_NAME = outputName, $ ;keyword to specify a string with the output filename for the resulting data
        R_FID = fidOut ;returned FID
      
      ;;; CLEANING UP ;;;
      close, fidOut
      close, fidIn
      print, 'Finished: ' + single_image
              
     ENDIF ;End of if statement to select image files (not header, text, or GCP files)
  ENDFOREACH ;End of loop through images in a flightline
ENDFOREACH ;End of loop through flightline
  close, fidBase
END ;END of file
