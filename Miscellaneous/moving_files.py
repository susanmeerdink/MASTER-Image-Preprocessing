##Moving Files
#This script runs through a directory and moves MASTER files into
#MASTER-Temp and MASTER-Emiss Folders.
#Susan Meerdink
#5/4/16
#--------------------------------------------------------------

import os # os is a library that gives us the ability to make OS changes
import glob
import errno 
 
directory = 'R:\\Image-To-Image Registration\\' #Set directory
fl_list = ['FL01','FL02','FL03','FL04','FL05','FL06','FL07','FL08','FL09','FL10','FL11'] #Set the flightlines you want to rename

for folder in fl_list: #Loop through folders
    dirHome = directory + 'SB_' + folder + '\\MASTER'
    os.chdir(dirHome) #Change directory to the current folder
    files_list = glob.glob('*') #Get list of all files in directory
    print('Moving files in folder: ' + folder)

    dirMT = directory + 'SB_' + folder + '\\MASTER-Temp\\' #New folder for temperature products
    dirME = directory + 'SB_' + folder + '\\MASTER-Emiss\\' #New folder for emissivity products
    
    if not os.path.exists(dirMT): #If this directory doesn't exist
        os.makedirs(dirMT)#Create temperature directory

    if not os.path.exists(dirME): #If this directory doesn't exist
        os.makedirs(dirME) #Create emissivity directory

    for one in files_list: #Loop through files
        if 'emissivity_tes' in one: #If file is an emissivity_tes file...
            new = dirME + one #set new location name
            os.rename(one, new) #move file
            
        if 'surface_temp' in one: #If file is an surface_temp file...
            new = dirMT + one #set new location name
            os.rename(one, new) #move file

    try: #Try to remove MASTER Directory
        os.rmdir(dirHome)
    except OSError as ex: #If you cannot remove it, throw error
        if ex.errno == 13:
            print "permission denied - cannot remove directory"
        if ex.errno == errno.ENOTEMPTY:
            print "directory not empty - cannot remove directory"
            
print('Done Moving Files')
