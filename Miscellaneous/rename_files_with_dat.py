##Renaming Files
#This script runs through a directory and renames files to end in .dat.
#Susan Meerdink
#5//16
#--------------------------------------------------------------

import os # os is a library that gives us the ability to make OS changes
import glob
 
directory = 'H:\\users\\meerdink\\Image_To_Image_Registration\\' #Set directory
fl_list = ['1','2','3','4','5','6','7','8','9','10','11'] #Set the flightlines you want to rename

for folder in fl_list: #Loop through folders
    os.chdir(directory + 'SB_FL' + folder + '\\MASTER\\') #Change directory to the current folder
    files_list = glob.glob('*') #Get list of all files in directory
    print('Renaming files in folder: ' + 'FL' + folder)

    for one in files_list: #Loop through files
        if '.hdr' not in one: #If it is a header file DON'T Change name
            if '.dat' not in one: #If it hasn't already been renamed
                new = one + '.dat' #New File name
                os.rename(one, new) #Rename the file
            
    
print('Done Renaming Files')
