PRO create_glt_single
  ;Start Application
  COMPILE_OPT STRICTARR
  envi, /restore_base_save_files
  ENVI_BATCH_INIT
  
  filename = 'R:\users\susan.meerdink\IDL_Code\Testing_Data\MASTERL2_1393800_03_20130411_1851_1910_V01-location';pull out current file
  outname= filename+'_glt' ; Set output name for file
  ENVI_OPEN_FILE, filename, r_fid=fid1 ;open file
  
  ; query file information to set dimensions for function
  ENVI_FILE_QUERY, fid1, ns=ns, nl=nl,fname=fname,nb=nb, dims=INdims
    proj = ENVI_PROJ_CREATE(/GEOGRAPHIC) ;geographic lat/lon
    PRINT,proj
  PRINT, 'Creating GLT for ' + filename
  ENVI_DOIT, 'ENVI_GLT_DOIT',DIMS=dims,I_PROJ=proj,O_PROJ=proj,OUT_NAME=outname,PIXEL_SIZE=0.000333,X_FID= xy, X_POS = 1, Y_FID=xy, Y_POS=0,R_FID=rfid; Create GLT
  
  envi_file_mng, id=fid1, /remove, /no_warning

END
