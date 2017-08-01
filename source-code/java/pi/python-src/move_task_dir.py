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
Created on Jan 26, 2012

@author: tklaus
'''

import shutil
import os
import sys
import subprocess

SEARCH_DIRS = ['/path/to/dist/tmp', '/path/to/archive']

def move_task_dir(instanceId, taskId, destDir):
    taskDirPath = find_task_dir(SEARCH_DIRS, instanceId, taskId) 
    if taskDirPath is not None:
        do_move(taskDirPath, destDir)
    else:
        print 'No task dir found on worker for instance=', instanceId, ', task=', taskId
        
def find_task_dir(rootDirs, instanceId, taskId):
    taskDirSuffix = instanceId + '-' + taskId

    for rootDir in rootDirs:
        for root, dirs, names in os.walk(rootDir):
            for dir in dirs:
                if dir.endswith(taskDirSuffix):
                    return os.path.join(root, dir)
    return None

def do_move(taskDirPath, destRootDir):
    
    try:
        print 'Copying: ' + taskDirPath + ' to ' + destRootDir
            
        destDir = os.path.join(destRootDir, os.path.basename(taskDirPath))
        shutil.copytree(taskDirPath, destDir, ignore=shutil.ignore_patterns('*.bin'))

        # if successful (no Error thrown by copytree)
        print 'Copy successful, deleting source file:', taskDirPath
        shutil.rmtree(taskDirPath)

        #copyCmd = ['cp', '-R', taskDirPath, destDir] 
        #print 'Running: ', copyCmd
        #rc = subprocess.call(copyCmd)
        #if rc:
        #    print 'FAILED to copy/remove task files for ', taskDirPath, ' rc=', rc
        
    except shutil.Error as e:
        print 'FAILED to copy/remove task files for ', taskDirPath, ' caught e: ', e
        
if __name__ == '__main__':
    if len(sys.argv) != 4:
        print 'USAGE: move_task_file.py INSTANCE_ID TASK_ID DESTINATION_DIRECTORY'
        sys.exit(-1)

    instanceId = sys.argv[1]
    taskId = sys.argv[2]
    destDir = sys.argv[3]
    
    move_task_dir(instanceId, taskId, destDir)
