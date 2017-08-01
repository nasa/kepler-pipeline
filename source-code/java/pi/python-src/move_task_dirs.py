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
from __future__ import print_function

'''
Created on Nov 28, 2011

@author: tklaus
'''

import Properties
import os
import sys
import jaydebeapi #@UnresolvedImport
import jpype #@UnresolvedImport
import threading
import Queue
import subprocess
import traceback

queue = Queue.Queue()
print_lock = threading.Lock()

def mtprint(*args, **kwargs):
    with print_lock:
        print (*args, **kwargs)
        
def move_task_files(clusterName, instanceId, moduleName, destinationDir, numClientThreads=40):
    
    global _moduleName
    global _destinationDir
    
    _moduleName = moduleName
    _destinationDir = destinationDir
    
    tasks = get_pipeline_metadata(clusterName, instanceId)
    
    # enqueue tasks
    for task in tasks:
        queue.put(task)
    
    # start worker threads
    if len(tasks) < numClientThreads:
        numClientThreads = len(tasks)
        
    mtprint('Starting', numClientThreads, 'threads')
    
    for i in range(1, numClientThreads):
        t = threading.Thread(target=process_task)
        t.setDaemon(True)
        t.start()
        
    queue.join()
    
def process_task():
    while not queue.empty():
        try:
            task = queue.get()
            do_move(task)
            queue.task_done() #so that Queue.join() will work
        except Exception as e:
            mtprint('Failed to copy task: ', task, e)
            traceback.print_exc(file=sys.stdout)

    mtprint("queue empty, thread exiting")
    
def do_move(task):
    taskId = str(int(task[0]))
    instanceId = str(int(task[1]))
    state = int(task[2])
    workerHost = str(task[3])

    taskDirName = '{0}-matlab-{1}-{2}'.format(moduleName, instanceId, taskId)
    dest = os.path.join(_destinationDir, taskDirName)

    if state in (4,5) and not os.path.exists(dest): # (4,5) = (COMPLETED, PARTIAL) 
        moveCmd = ['ssh', 'socops@' + workerHost, 'python', '/path/to/dist/bin/move_task_dir.py', instanceId, taskId, _destinationDir] 
        mtprint ('Running: ', moveCmd)
        rc = subprocess.call(moveCmd)
        if rc:
            mtprint ('ERROR: failed to run move_task_dir on worker, rc = ', rc)
 
def get_pipeline_metadata(clusterName, instanceId):
    p = Properties.Properties()
    p.load(open(os.path.expanduser('~/.soc/' + clusterName + '.properties')))
    
    dbDriverClass = p.getProperty('hibernate.connection.driver_class')
    dbUrl = p.getProperty('hibernate.connection.url')
    dbUser = p.getProperty('hibernate.connection.username')
    dbPassword = p.getProperty('hibernate.connection.password')
    
    mtprint (dbDriverClass, dbUrl, dbUser)

    # start JVM
    jar = os.path.expanduser('/path/to/java/jars/runtime/oracle/ojdbc6.jar')
    jpype.startJVM('/usr/java/latest/jre/lib/amd64/server/libjvm.so', '-Djava.class.path=%s' % jar)
    
    conn = jaydebeapi.connect(dbDriverClass, dbUrl, dbUser, dbPassword)
    curs = conn.cursor()
    curs.execute('SELECT ID,PI_PIPELINE_INSTANCE_ID,STATE,WORKER_HOST from PI_PIPELINE_TASK WHERE PI_PIPELINE_INSTANCE_ID=' + instanceId)
    results = curs.fetchall()
    
    return results
    
if __name__ == '__main__':
    if len(sys.argv) < 5:
        mtprint ('USAGE: move_task_files.py CLUSTER_NAME INSTANCE_ID MODULE_NAME DESTINATION_DIR [NUM_CLIENT_THREADS]')
        sys.exit(-1)

    clusterName = sys.argv[1]
    instanceId = sys.argv[2]
    moduleName = sys.argv[3]
    destinationDir = sys.argv[4]

    if len(sys.argv) == 6:
        move_task_files(clusterName, instanceId, moduleName, destinationDir, sys.argv[5])
    else:
        move_task_files(clusterName, instanceId, moduleName, destinationDir)


