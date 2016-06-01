##Moving Files
#This script runs through a directory and moves specific files
#into a new directory.
#Susan Meerdink
#5/24/16
#--------------------------------------------------------------

import os # os is a library that gives us the ability to make OS changes
from shutil import copyfile
import glob 
 
org_dir = 'R:\\MASTER_Imagery\\' #Set original directory (where the files are coming from)
out_dir = 'R:\\Image-To-Image Registration\\' #Set directory where files will out put
flightline_name = 'Sierra Nevada' #What flightline would you like to transfer over?
file_search = '*emissivity&temp*' #What files are you looking to move?

os.chdir(org_dir) #Change directory to the current folder

#ALL flightdates
date_list = glob.glob(flightline_name + '*') #get list of flightbox dates

#Alter for Select flightdates
#date_list = [(flightline_name + ' 20130606')]

for date in date_list: #Loop through folders
    dirHome = org_dir + date + '\\'
    fl_list = glob.glob(dirHome + 'FL*') #Get list of all files in directory

    for folder in fl_list: #Loop through flightline folders (FL01, FL02,...)
        file_list = glob.glob(folder +'\\'+ file_search) # find files of interest

        index = folder.find('FL') 
        folderName = folder[index:index+4]

        if flightline_name is 'Santa Barbara':
            flName = 'SB_'
        else:
            flName = 'SN_'

        newDir = out_dir + flName + folderName + '\\MASTER\\' #Location of new file
    
        if not os.path.exists(newDir): #If this directory doesn't exist
            os.makedirs(newDir)#Create temperature directory

        for oneFile in file_list:#Loop through files
            indexName = oneFile.find('MASTERL2')
            fileName = oneFile[indexName:len(oneFile)] #Get the file name
            finalDir = newDir + fileName #Set final destination with file name
            copyfile(oneFile,finalDir) # copy the file to it's new location
            print('Moved file: ' + fileName)
          
print('Done Moving Files')
