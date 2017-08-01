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

"""
Created on Nov 21, 2011

Various functions used to initialize SUP SSH keys for automating communications
with Pleiades.

@author: tklaus
"""

import pickle
import pexpect
import binascii
import os
import sys
import getpass
import subprocess
import glob
import tempfile

def nas_initkeys_cluster(hostFilename):
    
    hosts = [ h.rstrip() for h in open(hostFilename,'r').readlines() if not h.startswith('#')]
    
    print hosts
    
    if not len(hosts):
        print 'Host file contains no hosts!'
        return
    
    generateKeyHost = hosts[0]
    
    user = raw_input('Username: ');
    password = getpass.getpass('Password: ')
    passcode = getpass.getpass('Passcode (do NOT reuse codes): ')
        
    print 'Generating key on host: ', generateKeyHost
    
    rc = call_nas_initkeys_host(user, generateKeyHost, password, passcode)
    
    if rc == 0:
        print 'Propagating keys to other hosts'
        propagate_keys(generateKeyHost, hosts)
    else:
        print 'ERROR: Failed to generate keys on host:', generateKeyHost, " Aborting."
    return 0

def propagate_keys(generateKeyHost, hosts):
    # propagate new key to other hosts
    tempDir = tempfile.mkdtemp()
    cmd = ['scp', 'socops@' + generateKeyHost + ':~/.ssh/meshkey.*', tempDir]
    print 'Copying meshkey from: ', generateKeyHost, 'cmd=', cmd
    rc = subprocess.call(cmd)
    
    if rc:
        print 'ERROR: Failed to fetch meshkeys from ', generateKeyHost, 'returned ', rc
        return
    
    keys = glob.glob(os.path.join(tempDir,'meshkey.*'))
    
    for host in hosts[1:]:
        for key in keys:
            cmd = ['scp', key, 'socops@' + host + ':~/.ssh/']
            print 'Copying meshkey to host: ', host, 'cmd=', cmd
            rc = subprocess.call(cmd)
    
            if rc:
                print 'WARNING: Failed to propagate meshkeys to ', host, ', returned ', rc
    
def call_nas_initkeys_host(user, hostname, password, passcode):

    credsList = [user, password, passcode]
    credsPick = pickle.dumps(credsList,2)
    credsB64 = binascii.b2a_hex(credsPick)
    
    cmd = ['ssh','socops@' + hostname, '/path/to/dist/bin/nas_initkeys.py', '-h', credsB64]

    print 'Connecting to: ', hostname, 'cmd=', cmd
    
    rc = subprocess.call(cmd)
    
    if rc:
        print 'WARN: nas_initkeys.py on ', hostname, 'returned ', rc
        
    return rc
          
'''
Performs the following interaction using pexpect:
 $ ./sup -g                                             
 Generating key on sup.nas.nasa.gov (provide login information)
 Password: 
 Enter PASSCODE:
 Identity added: /path/to/.ssh/meshkey.1322517253 (/path/to/.ssh/meshkey.1322517253)
 Lifetime set to 604800 seconds
'''
def nas_initkeys_host(credsB64):
    
    # First delete old meshkeys, if any
    oldMeshKeys = glob.glob('~/.ssh/meshkey.*')
    for oldMeshKey in oldMeshKeys:
        if not os.path.isdir(oldMeshKey):
            os.remove(oldMeshKey)
        else:
            print 'WARNING: Filename matches meshkey format, but is a directory: ', oldMeshKey
        
    credsPick = binascii.a2b_hex(credsB64)
    credsList = pickle.loads(credsPick)

    user = credsList[0]
    password = credsList[1]
    passcode = credsList[2]

    prompts = ['Are you sure you want to continue connecting (yes/no)?',
               'Enter passphrase for /path/to/.ssh/id_rsa:',
               'Password:',
               'Enter PASSCODE:',
               'Unable to generate key',
               pexpect.EOF]

    responses = ['yes',
                 'passphrase',
                 password,
                 passcode,
                 None,
                 None]
    
    success = exec_expect('/path/to/dist/bin/sup -g -u ' + user, prompts, responses)
    
    if success:
        return 0
    else:
        return -1
        


def exec_expect(cmd, prompts, responses):

    print 'Running cmd: ', cmd

    child = pexpect.spawn(cmd)
    child.logfile_read = sys.stdout
    
    done = False
    success = True
    passwordSent = False
    passcodeSent = False
    
    while not done: 
        index = child.expect(prompts, 60)
        print 'index = ', index

        # Password
        if index == 2:
            if passwordSent:
                # password was already sent, they must not have liked it
                done = True
                success = False
            else:
                passwordSent = True
        # Passcode
        elif index == 3:
            if passcodeSent:
                # passcode was already sent, they must not have liked it
                done = True
                success = False
            else:
                passcodeSent = True
        
        # unable to generate key
        elif index == 4:
            done = True
            success = False
        
        # EOF
        elif index == 5:
            done = True
            success = passwordSent and passcodeSent

        if not done:        
            response = responses[index];
            child.sendline(response)
    
    return success            


if __name__ == '__main__':
    if len(sys.argv) < 3:
        print 'USAGE: nas_initkeys.py -c|-h HOSTFILE|CREDS'
        sys.exit(-1)

    cmd = sys.argv[1]
    arg = sys.argv[2]

    if cmd == '-c':
        sys.exit(nas_initkeys_cluster(arg))
    elif cmd == '-h':
        sys.exit(nas_initkeys_host(arg))
    else:
        print 'USAGE: nas_initkeys.py -c|-h HOSTFILE|CREDS'
        sys.exit(-1)


