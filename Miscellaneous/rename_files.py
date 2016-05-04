##Renaming Files
#This script runs through a directory and renames MASTER files.
#Susan Meerdink
#5/4/16
#--------------------------------------------------------------

import os # os is a library that gives us the ability to make OS changes
import glob
 
directory = 'R:\\Image-To-Image Registration\\' #Set directory
fl_list = ['FL01','FL02','FL03','FL04','FL05','FL06','FL07','FL08','FL09','FL10','FL11'] #Set the flightlines you want to rename

for folder in fl_list: #Loop through folders
    os.chdir(directory + 'SB_' + folder + '\\MASTER\\') #Change directory to the current folder
    files_list = glob.glob('*') #Get list of all files in directory
    print('Renaming files in folder: ' + folder)

    for one in files_list: #Loop through files
        if 'FL' not in one: #If it hasn't already been renamed
            new = folder + '_' + one #New Folder name
            os.rename(one, new) #Rename the file
            
    
print('Done Renaming Files')
