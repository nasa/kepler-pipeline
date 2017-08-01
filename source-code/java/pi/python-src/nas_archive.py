#!/usr/bin/python
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

'''
Created on Aug 9, 2012

@author: tklaus
'''

import os
import sys
import glob
import getopt
import tarfile
import subprocess
import hashlib

USAGE = 'nas_archive -c|--copy -v|--verify -s|--sourcedirectory <DIR_NAME> -t|--tardirectory -p <FILE_PATTERN>-r|--remotedirectory <REMOTE_HOST>:<DIR_NAME> -z|--compress -u|--nasusername -a|--supcommand'
EXAMPLE_USAGE_COPY = 'EXAMPLE (copy to NAS): nas_archive -c -s /my/task_files -t /my/tmpdir -p pa-matlab-* -r host:/path/to/myarchivedir -z -u mynasusername'
EXAMPLE_USAGE_VERIFY = 'EXAMPLE (verify at NAS): nas_archive -v -s /path/to/myarchivedir -p pa-matlab-*'

copyFlag = False
verifyFlag = False
sourceDirectory = ''
tarDirectory = ''
remoteDirectory = ''
compressFlag = False
filePattern = '*'
nasUsername = ''
supCommand = '/path/to/dist/bin/sup'

def do_copy():
    if compressFlag:
        tarFileExtension = '.tar.gz'
        tarFileMode = 'w:gz'      
    else:
        tarFileExtension = '.tar'
        tarFileMode = 'w:'

    taskDirs = glob.glob(os.path.join(sourceDirectory, filePattern))
    
    if not taskDirs:
        print("No files matching pattern '{}' found in directory {}".format(filePattern, sourceDirectory))
        sys.exit(2)
    
    for taskDir in taskDirs:
        tarPath = os.path.join(tarDirectory, os.path.basename(taskDir) + tarFileExtension)
        
        print('Creating tar file {}'.format(tarPath))
        
        with tarfile.open(tarPath, tarFileMode) as tar:
            tar.add(taskDir, arcname=os.path.basename(taskDir))

        print("Creating hash file")
                    
        hashPath = "{0}.hash".format(tarPath)
        print('hash: {}'.format(calculate_hash(tarPath)))
        
        create_hashfile(tarPath, hashPath)
        
        print("Transferring files to NAS")
        
        command = [supCommand, '-v', '-n', '-b', '-u', nasUsername, '-oCiphers=arcfour128', 
                      '-oMACs=umac-64@openssh.com', 'scp', '-r', tarPath, remoteDirectory]
        print(" running: {}".format(command))
        rc = subprocess.check_call(command)
        if rc:
            print("Failed to run sup: {}".format(command))
            sys.exit(2)
        
        command = [supCommand, '-v', '-n', '-b', '-u', nasUsername, '-oCiphers=arcfour128', 
                      '-oMACs=umac-64@openssh.com', 'scp', '-r', hashPath, remoteDirectory]
        print(" running: {}".format(command))
        rc = subprocess.check_call(command)
        if rc:
            print("Failed to run sup: {}".format(command))
            sys.exit(2)
            
def do_verify():
    tarFiles = glob.glob(os.path.join(sourceDirectory, filePattern))
    
    if not tarFiles:
        print("No files matching pattern '{}' found in directory {}".format(filePattern, sourceDirectory))
        sys.exit(2)
    
    for tarPath in tarFiles:
        if tarPath.endswith('.hash'):
            continue # ignore the hash files
        
        hashFile = tarPath + '.hash'
        
        #print('tarPath = {}'.format(tarPath))
        #print('hashFile = {}'.format(hashFile))
        
        if not os.path.exists(hashFile):
            print('Verify FAILED: path={}, NO HASHFILE FOUND'.format(tarPath))
        else:
            verify_hashfile(tarPath, hashFile)


def create_hashfile(path, hashFile):
    with open(hashFile, 'w') as f:
        f.write(calculate_hash(path))

def verify_hashfile(path, hashFile):
    with open(hashFile, 'r') as f:
        expectedHashvalue = f.read()
        #print('expectedHashvalue = {}'.format(expectedHashvalue))
        
    actualHashvalue = calculate_hash(path)
    
    if expectedHashvalue != actualHashvalue:
        print('Verify FAILED: path={}, expectedHash={}, actualHash={}'.format(path, expectedHashvalue, actualHashvalue))
    else:
        print('Verify PASSED: path={}, expectedHash={}, actualHash={}'.format(path, expectedHashvalue, actualHashvalue))
        
def calculate_hash(path):
    hasher = hashlib.sha256()
    with open(path, 'rb') as f:
        buf = f.read(65536)
        while len(buf) > 0:
            hasher.update(buf)
            buf = f.read(65536)
    hashvalue = hasher.hexdigest()
    return hashvalue

def print_usage_and_exit(errorMsg=''):
    if errorMsg:
        print("ERROR: {}".format(errorMsg))
    print(USAGE)
    print(EXAMPLE_USAGE_COPY)
    print(EXAMPLE_USAGE_VERIFY)
    print("Argument descriptions:")
    print(" copy: Use when running on source host. Does tar, md5sum, and sup copy")
    print(" verify: Use when running on NAS host. Does md5sum and compares to md5sum copied over")
    print(" sourcedirectory: Directory where task dirs exist (soc) or copied tar files (verify)")
    print(" tardirectory: Temporary directory where tar files will be created. Defaults to sourcedirectory"
          " if not specified. Only used with -c")
    print(" remotedirectory: Destination host and directory on remote (NAS) host where files will be copied to. "
          "Only used with -c")
    print(" compress: Determines whether the tar file will be compressed (.tar.gz)")
    sys.exit(2)

def validate_dir(directory):
    if not os.path.exists(directory):
        print_usage_and_exit('directory {} does not exist'.format(directory))
    if not os.path.isdir(directory):
        print_usage_and_exit('path {} exists, but is not a directory')
        
if __name__ == "__main__":
    try:
        opts, args = getopt.getopt(sys.argv[1:], "cvs:t:p:r:zu:a:", ["copy", "verify", "sourcedirectory=", 
            "tardirectory=", "pattern=", "remotedirectory=", "compress", "nasusername", "supcommand"])
        
    except getopt.GetoptError:
        print_usage_and_exit()
        
    if args:
        print_usage_and_exit("Unrecognized arguments: {}".format(args))
        
    for opt, arg in opts:
        if opt in ("-c", "--copy"):
            copyFlag = True
        elif opt in ("-v", "--verify"):
            verifyFlag = True
        elif opt in ("-s", "--sourcedirectory"):
            sourceDirectory = arg
            validate_dir(sourceDirectory)
        elif opt in ("-t", "--tardirectory"):
            tarDirectory = arg
            validate_dir(sourceDirectory)
        elif opt in ("-p", "--pattern"):
            filePattern = arg
        elif opt in ("-r", "--remotedirectory"):
            remoteDirectory = arg
        elif opt in ("-z", "--compress"):
            compressFlag = True
        elif opt in ("-u", "--nasusername"):
            nasUsername = arg
        elif opt in ("-a", "--supcommand"):
            supCommand = arg
            
    if not sourceDirectory:
        print_usage_and_exit("sourcedirectory (-s) must be specified")
        
    if copyFlag and verifyFlag:
        print_usage_and_exit("Can't specify both -c *and* -v (pick one)")
        
    if not copyFlag and not verifyFlag:
        print_usage_and_exit("One of -c or -v must be specified")
        
    if copyFlag and not remoteDirectory:
        print_usage_and_exit("-r must be specified when -c is specified (where do you want the files copied to on the remote host?")
    
    if copyFlag and not ':' in remoteDirectory:
        print_usage_and_exit("Remote directory must contain remote hostname (e.g., 'host:/my/dir')")
    
    if copyFlag and not nasUsername:
        print_usage_and_exit("-u must be specified when -c is specified")
    
    if verifyFlag and compressFlag:
        print_usage_and_exit("-z cannot be specified with -v")        
        
    if not tarDirectory:
        tarDirectory = sourceDirectory
        
    print('copyFlag = {}'.format(copyFlag))
    print('verifyFlag = {}'.format(verifyFlag))
    print('sourceDirectory = {}'.format(sourceDirectory))
    print('tarDirectory = {}'.format(tarDirectory))
    print('filePattern = {}'.format(filePattern))
    print('remoteDirectory = {}'.format(remoteDirectory))
    print('compressFlag = {}'.format(compressFlag))
    print('nasUsername = {}'.format(nasUsername))
    print('supCommand = {}'.format(supCommand))

    if copyFlag:
        do_copy()
    elif verifyFlag:
        do_verify()
        
