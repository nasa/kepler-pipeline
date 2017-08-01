#!/bin/bash
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

# This script is used to submit subtasks to the NASA Ames Supercomputer (NAS)
# This script is passed as an argument to the PBS 'qsub' command and executes
# on one of the supercomputer nodes allocated by the qsub command. 
# No login scripts (.bash_profile, .bashrc, etc.) are run prior to running
# the script, so the script must initialize all necessary environment variables.
#
# usage: nas-launcher.sh MAX_SUBTASK_NUMBER BINARY_NAME WORKING_DIR TIMEOUT_SECS CORES_PER_NODE KEPLER_DIST_DIR
#

if [ $# -ne 6 ]
then
  echo "Usage: `basename $0` MAX_SUBTASK_NUMBER BINARY_NAME WORKING_DIR TIMEOUT_SECS CORES_PER_NODE KEPLER_DIST_DIR"
  exit -1
fi

echo "nas-launcher: START"

MAX_SUBTASK_NUMBER=$1
BINARY_NAME=$2
WORKING_DIR=$3
TIMEOUT_SECS=$4
CORES_PER_NODE=$5
KEPLER_DIST_DIR=$6

KEPLER_BIN_DIR=$KEPLER_DIST_DIR/bin
LOG_PATH=$KEPLER_DIST_DIR/logs/tasks/qsub-`basename $WORKING_DIR`-`date "+%Y-%0m-%0dT%H:%M:%S"`.log

echo "nas-launcher: PBS_NODEFILE contents:"
cat $PBS_NODEFILE

# Extract tar
ARCHIVE=${WORKING_DIR}.tar
echo "nas-launcher: Extracting inputs .tar archive: " $ARCHIVE
cd `dirname $WORKING_DIR`
tar xvf $ARCHIVE

# Reset IN_PROGRESS flag
echo "nas-launcher: Creating .IN_PROGRESS flag"
touch $WORKING_DIR/.IN_PROGRESS

# create symlinks for shared files
echo "nas-launcher: Creating symlinks"
$KEPLER_BIN_DIR/nas-mklinks.sh $WORKING_DIR

echo "nas-launcher: Launching jobs"
seq 0 $MAX_SUBTASK_NUMBER | PATH=$PATH:$KEPLER_BIN_DIR parallel -j $CORES_PER_NODE -u --sshloginfile $PBS_NODEFILE $KEPLER_BIN_DIR/nas-job-launcher.sh {} $BINARY_NAME $WORKING_DIR $TIMEOUT_SECS $KEPLER_DIST_DIR > $LOG_PATH 2>&1
echo "nas-launcher: All jobs COMPLETE"

# remove symlinks for shared files
echo "nas-launcher: Removing symlinks"
$KEPLER_BIN_DIR/nas-rmlinks.sh $WORKING_DIR

#create archive
echo "nas-launcher: Creating outputs .tar archive: " $ARCHIVE
cd $WORKING_DIR/..
rm -f $ARCHIVE
tar cvf $ARCHIVE `basename $WORKING_DIR`

# Clear IN_PROGRESS flag
echo "nas-launcher: Clearing .IN_PROGRESS flag"
rm -rf $WORKING_DIR/.IN_PROGRESS

echo "nas-launcher: END"

