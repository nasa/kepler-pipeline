#!/usr/bin/env python
# 
# Copyright 2017 United States Government as represented by the
# Administrator of the National Aeronautics and Space Administration.
# All Rights Reserved.
# 
# This file is available under the terms of the NASA Open Source Agreement
# (NOSA). You should have received a copy of this agreement with the
# Kepler source code; see the file NASA-OPEN-SOURCE-AGREEMENT.doc.
# 
# No Warranty: THE SUBJECT SOFTWARE IS PROVIDED "AS IS" WITHOUT ANY
# WARRANTY OF ANY KIND, EITHER EXPRESSED, IMPLIED, OR STATUTORY,
# INCLUDING, BUT NOT LIMITED TO, ANY WARRANTY THAT THE SUBJECT SOFTWARE
# WILL CONFORM TO SPECIFICATIONS, ANY IMPLIED WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR FREEDOM FROM
# INFRINGEMENT, ANY WARRANTY THAT THE SUBJECT SOFTWARE WILL BE ERROR
# FREE, OR ANY WARRANTY THAT DOCUMENTATION, IF PROVIDED, WILL CONFORM
# TO THE SUBJECT SOFTWARE. THIS AGREEMENT DOES NOT, IN ANY MANNER,
# CONSTITUTE AN ENDORSEMENT BY GOVERNMENT AGENCY OR ANY PRIOR RECIPIENT
# OF ANY RESULTS, RESULTING DESIGNS, HARDWARE, SOFTWARE PRODUCTS OR ANY
# OTHER APPLICATIONS RESULTING FROM USE OF THE SUBJECT SOFTWARE.
# FURTHER, GOVERNMENT AGENCY DISCLAIMS ALL WARRANTIES AND LIABILITIES
# REGARDING THIRD-PARTY SOFTWARE, IF PRESENT IN THE ORIGINAL SOFTWARE,
# AND DISTRIBUTES IT "AS IS."
#
# Waiver and Indemnity: RECIPIENT AGREES TO WAIVE ANY AND ALL CLAIMS
# AGAINST THE UNITED STATES GOVERNMENT, ITS CONTRACTORS AND
# SUBCONTRACTORS, AS WELL AS ANY PRIOR RECIPIENT. IF RECIPIENT'S USE OF
# THE SUBJECT SOFTWARE RESULTS IN ANY LIABILITIES, DEMANDS, DAMAGES,
# EXPENSES OR LOSSES ARISING FROM SUCH USE, INCLUDING ANY DAMAGES FROM
# PRODUCTS BASED ON, OR RESULTING FROM, RECIPIENT'S USE OF THE SUBJECT
# SOFTWARE, RECIPIENT SHALL INDEMNIFY AND HOLD HARMLESS THE UNITED
# STATES GOVERNMENT, ITS CONTRACTORS AND SUBCONTRACTORS, AS WELL AS ANY
# PRIOR RECIPIENT, TO THE EXTENT PERMITTED BY LAW. RECIPIENT'S SOLE
# REMEDY FOR ANY SUCH MATTER SHALL BE THE IMMEDIATE, UNILATERAL
# TERMINATION OF THIS AGREEMENT.
#

import pyfits,getopt,sys

## I/O control

def usage():

    print 'The delivery contains this readme file, a python script and four data files.'
    print 'Each data file contains the WCS information for a specific spacecraft roll'
    print 'orientation. The data files must be kept in the same folder as the python'
    print 'script and the python script must be executed from the file directory/folder'
    print 'containing the script. The FFI FITS file need not reside within the same folder.'
    print ''
    print 'README                               This file'
    print 'UpdateWCSinFFI.py                    The python script'
    print 'UpdateWCSinFFI_data_season0.txt      The WCS data for quarters 2,6,10...'
    print 'UpdateWCSinFFI_data_season1.txt      The WCS data for quarters 3,7,11...'
    print 'UpdateWCSinFFI_data_season2.txt      The WCS data for quarters 4,8,12...'
    print 'UpdateWCSinFFI_data_season3.txt      The WCS data for quarters 0,1,5,9...'
    print ''
    print 'Before running the python script it must be made executable. From the shell'
    print 'type: chmod 755 UpdateWCSinFFI.py.'
    print ''
    print 'After the calibration of each FFI, perform the following shell command from'
    print 'the folder containing the python script and WCS data, e.g.:'
    print 'UpdateWCSinFFI.py --ffifile=kplr2010174164113_ffi-cal.fits'
    print ''
    print '--ffifile is the name and path of the FFI file'
    print ''
    print 'This procedure will overwrite the FFI file. It is advisable to make a copy'
    print 'of the FFI file before execution.'
    print ''
    print 'The procedure will overwrite or create new WCS keywords for each channel'
    print 'image within the FFI FITS file.'
    print ''
    print 'If the file is named kplr2009170043915_ffi-cal.fits or'
    print 'kplr2009170043915_ffi-uncert.fits this file is the Q2 M1 FFI.'
    print 'There is a problem calibrating the WCS for this file.'
    print 'The solution is to manually force an offset between the pointing '
    print 'values in the WCS file and that applied to the FFI header.'

    sys.exit()
    return

try:
    opts, args = getopt.getopt(sys.argv[1:],"h:f",
                               ["help","ffifile="])
except getopt.GetoptError:
    usage()
for o, a in opts:
    if o in ("-h", "--help"):
        usage()
    if o in ("-f", "--ffifile"):
        try:
            ffifile = str(a)
        except:
            msg = 'ERROR: FFIFILE -- ' + ffifile + ' is not a string'
            sys.exit(msg)

## is the FFI from Q2 M1, if so then we need a different calibration
if ffifile.endswith('kplr2009170043915_ffi-uncert.fits') or ffifile.endswith('kplr2009170043915_ffi-cal.fits'):
    isQ2M1 = True
else:
    isQ2M1 = False

## open the FFI FITS file

try:
    struct = pyfits.open(ffifile,mode='update')
except:
    msg = 'ERROR: cannot open ' + ffifile + ' as a FITS file'
    sys.exit(msg)

## find and read the QUARTER keyword

try:
    quarter = int(struct[0].header['QUARTER'])
except:
    txt = 'ERROR: cannot find or read the QUARTER keyword in ' + ffifile + '[0]'
    sys.exit(txt)

## decide which keyword defintion file is applicable

if quarter < 0:
    msg  = 'ERROR -- quarter is negative.'
    sys.exit(msg)
if quarter == 0:
    season = str(3)
else:
    season = str((int(quarter) - 2) % 4)
infile = 'UpdateWCSinFFI_data_season' + season + '.txt'

## open the ASCII file containing WCS data

try:
    content = open(infile,'r')
except:
    msg = 'ERROR: cannot open ' + infile + ' as an ASCII file'
    sys.exit(msg)

## Write the WCS information into the FITS headers

if isQ2M1:
    for line in content:
        line = line.strip()
        line=line.split(',')
        if len(line) == 1:
            hdu = int(line[0])
            del struct[hdu].header['CTYPE1']
            del struct[hdu].header['CTYPE2']
            del struct[hdu].header['CRVAL1']
            del struct[hdu].header['CRVAL2']
            del struct[hdu].header['CRPIX1']
            del struct[hdu].header['CRPIX2']
            del struct[hdu].header['CD1_1']
            del struct[hdu].header['CD1_2']
            del struct[hdu].header['CD2_1']
            del struct[hdu].header['CD2_2']
            del struct[hdu].header['A_ORDER']
            del struct[hdu].header['B_ORDER']
            del struct[hdu].header['A_2_0']
            del struct[hdu].header['A_0_2']
            del struct[hdu].header['A_1_1']
            del struct[hdu].header['B_2_0']
            del struct[hdu].header['B_0_2']
            del struct[hdu].header['B_1_1']
            del struct[hdu].header['AP_ORDER']
            del struct[hdu].header['BP_ORDER']
            del struct[hdu].header['AP_1_0']
            del struct[hdu].header['AP_0_1']
            del struct[hdu].header['AP_2_0']
            del struct[hdu].header['AP_0_2']
            del struct[hdu].header['AP_1_1']
            del struct[hdu].header['BP_1_0']
            del struct[hdu].header['BP_0_1']
            del struct[hdu].header['BP_2_0']
            del struct[hdu].header['BP_0_2']
            del struct[hdu].header['BP_1_1']
            del struct[hdu].header['A_DMAX']
            del struct[hdu].header['B_DMAX']
            del struct[hdu].header['CHECKSUM']
        if len(line) == 3:
        

            try:
                if str(line[0]).lower() == 'crval1':
                    #offset the crval1 position by 1.383 seconds of arc
                    # the multiplication by 15 is to convert from RA to arcsec
                    struct[hdu].header.update(line[0],float(line[1]) +((1.383*15) / 3600.),line[2])
                elif str(line[0]).lower() == 'crval2':
                    #offset the crval2 position by 7.8 seconds of arc
                    struct[hdu].header.update(line[0],float(line[1]) + (7.8/3600.),line[2])
    
                else:
                    struct[hdu].header.update(line[0],float(line[1]),line[2])
            except:
                struct[hdu].header.update(line[0],line[1],line[2])
#if the file is not from Q2M1
else:
    for line in content:
        line = line.strip()
        line=line.split(',')
        if len(line) == 1:
            hdu = int(line[0])
        if len(line) == 3:
        

            try:
                struct[hdu].header.update(line[0],float(line[1]),line[2])
            except:
                struct[hdu].header.update(line[0],line[1],line[2])    
        
content.close()
struct.close()
