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
Created on Aug 14, 2012

@author: tklaus
'''

import os
import sys
import glob

def do_analysis(directory):
    taskName = os.path.basename(directory)
    perTaskPath = os.path.join(os.path.dirname(directory), 'memdrone-maxrss_pertask.txt')
    
    memdroneFiles = glob.glob(os.path.join(directory, 'memdrone*'))

    print 'memdroneFiles:', memdroneFiles

    maxOverallRss = 0.0
    
    for memdroneLog in memdroneFiles:
        maxRss = parse_memdrone_log(memdroneLog)
        if maxRss > maxOverallRss:
            maxOverallRss = maxRss
    
    print 'maxOverallRss=', maxOverallRss

    update_datafile(perTaskPath, taskName, maxOverallRss)

def parse_memdrone_log(memdroneLog):
    print 'parsing:', memdroneLog
    
    maxRss = 0.0
        
    logfile = open(memdroneLog, 'r').readlines()
    
    for line in logfile:
        elements = line.split()
        
        if len(elements) != 11:
            #print('unable to parse:', line)
            continue
        
        rss = float(elements[10])
        
        if rss > maxRss:
            maxRss = rss
    
    print 'maxRss = ', maxRss
    
    return maxRss

def update_datafile(path, label, value):
    f = open(path, 'a')
    
    f.write(label)
    f.write(' ')
    f.write(str(value))
    f.write('\n')
    f.close()
    
if __name__ == '__main__':
    if len(sys.argv) != 2:
        print 'USAGE: memdrone_analysis.py DIRECTORY'
        sys.exit(-1)

    directory = sys.argv[1]
    
    do_analysis(directory)
