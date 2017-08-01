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
Created on Jan 27, 2012

@author: tklaus
'''

import os
import sys

def find_incomplete_subtasks(instanceDir, moduleName):
    outputFilename = moduleName + '-outputs-0.mat'
    taskDirs = os.listdir(instanceDir)
    
    totalSubtaskCount = 0
    totalMissingCount = 0
    
    for taskDir in taskDirs:
        if '-matlab-' in taskDir:
            print 'Processing: ' + taskDir
            taskMissingCount = 0;
            taskPath = os.path.join(instanceDir,taskDir)
            subTaskDirs = os.listdir(taskPath) 
            for subTaskDir in subTaskDirs:
                if 'st-' in subTaskDir:
                    totalSubtaskCount += 1
                    subTaskPath = os.path.join(taskPath,subTaskDir)
                    subTaskFiles = os.listdir(subTaskPath)
                    if not outputFilename in subTaskFiles:
                        taskMissingCount += 1
                        totalMissingCount += 1
                        
            if taskMissingCount > 0:
                print taskDir, 'has ', taskMissingCount, ' missing outputs'
                
    print instanceDir, 'has a total of ', totalMissingCount, ' missing outputs out of a total of ', totalSubtaskCount
            
if __name__ == '__main__':
    if len(sys.argv) != 3:
        print 'USAGE: find_incomplete_subtasks.py INSTANCE_DIR MODULE_NAME'
        sys.exit(-1)

    instanceDir = sys.argv[1]
    moduleName = sys.argv[2]
    
    find_incomplete_subtasks(instanceDir, moduleName)
