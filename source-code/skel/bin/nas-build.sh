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

# This script is used to build the SOC code tree on Pleiades
#
# usage: nas-build.sh KEPLER_ROOT CONFIG_TEMPLATE_FILENAME
#    example usage: 
#    ex: nas-build.sh /path/to/TEST pleiades-LAB.template
#
#

if [ $# -ne 2 ]
then
  echo "Usage: `basename $0` KEPLER_ROOT CONFIG_TEMPLATE_FILENAME"
  exit -1
fi

KEPLER_ROOT=${1}
echo "KEPLER_ROOT =" $KEPLER_ROOT

CONFIG_TEMPLATE_FILENAME=${2}

CODE_DIR=$KEPLER_ROOT
LOG_FILE=$CODE_DIR/build.log

echo "CODE_DIR =" $CODE_DIR

if [ ! -h $CODE_DIR ]
then
  echo "CODE_DIR does not exist or is not a symlink"
  exit -1
fi

module ()
{
       eval `/usr/bin/modulecmd bash $*`
}

module add jvm/jdk1.7.0_141
module add matlab/2010b
module add gcc/4.4.5
module add svn/1.6.21
  
CODE_DIR=`readlink $CODE_DIR`
BRANCH=`basename $CODE_DIR`

STATUS="Build of $BRANCH started in $KEPLER_ROOT"

echo $STATUS ": LOG_FILE =" $LOG_FILE
echo $STATUS >> $LOG_FILE

date >> $LOG_FILE

export ANT_HOME=$KEPLER_ROOT/ant/latest

export PATH=$JAVA_HOME/bin:$PATH
export PATH=$ANT_HOME/bin:$PATH
export PATH=$KEPLER_ROOT/dist/bin:$PATH

export SOC_CODE_ROOT=$KEPLER_ROOT
export SOC_BUILD_NPROC=1

echo "KEPLER_ROOT=" $KEPLER_ROOT >> $LOG_FILE
echo "PATH=" $PATH >> $LOG_FILE
echo "SOC_CODE_ROOT=" $SOC_CODE_ROOT >> $LOG_FILE
echo "BRANCH=" $BRANCH >> $LOG_FILE

echo "PBS_NODEFILE contents: " >> $LOG_FILE
cat $PBS_NODEFILE >> $LOG_FILE

cd $SOC_CODE_ROOT

# Preserve logs (KSOC-4773)
ARCHIVE_DIR=$KEPLER_ROOT/archive/snapshot-$(date +%Y-%m-%d-%H-%M-%S)
mkdir -p $ARCHIVE_DIR
mv -v $SOC_CODE_ROOT/dist/logs/* $ARCHIVE_DIR

echo "*** Clean ***" >> $LOG_FILE
ant -Dpleiades=1  -Drelease.version=$BRANCH clean >> $LOG_FILE

echo "*** Dist ***" >> $LOG_FILE
ant -Dpleiades=1  -Drelease.version=$BRANCH dist >> $LOG_FILE

if [ $? -eq 0 ]
then
    echo "Build completed successfully, updating config" >> $LOG_FILE
    $KEPLER_ROOT/dist/bin/runjava config-merge $KEPLER_ROOT/skel/etc/kepler.properties $KEPLER_ROOT/skel/etc/$CONFIG_TEMPLATE_FILENAME $KEPLER_ROOT/dist/etc/kepler.properties >> $LOG_FILE 2>&1
    $KEPLER_ROOT/dist/bin/runjava soc-version >> $LOG_FILE
else
    echo "Build FAILED" >> $LOG_FILE
    exit -1
fi

echo "Build complete" >> $LOG_FILE
date >> $LOG_FILE

exit 0

