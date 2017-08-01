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

# Display usage information and exit.
usage() {
    cat <<EOF
Usage: `basename $0` [options]
--aft		archive files in $SOC_CODE_ROOT/dist/{logs,tmp} (default)
--dev-pipeline	archive files in /path/to/dev/{logs,task-data}
--help		display this message
EOF
    exit 1;
}

# Parse command line.
mode=aft
while [ $# != 0 ]; do
    case "$1" in
	--a*)	mode=aft;;
	--d*)   mode=dev-pipeline;;
	*)     usage;;
    esac
    shift
done

# Default aft mode.
if [ $mode = dev-pipeline ]; then
    dir=/path/to/dev
    logDir=$dir/logs
    taskDir=$dir/task-data
else
    dir=$SOC_CODE_ROOT/dist
    logDir=$dir/logs
    taskDir=$dir/tmp
fi

archiveDir=/path/to/archive/snapshot-$(date +%Y-%m-%d-%H-%M-%S)

if [ `find $logDir $taskDir -type f ! -empty | wc -l` = 0 ]; then
    echo "Nothing in logs and tmp in $dir to archive"
    exit
fi

set -x

if [ `find $logDir -type f ! -empty | wc -l` -gt 0 ]; then
    mkdir -p $archiveDir/logs
    mv $logDir/* $archiveDir/logs
fi
if [ `find $taskDir -type f ! -empty | wc -l` -gt 0 ]; then
    mkdir -p $archiveDir/task-data
    mv $taskDir/* $archiveDir/task-data
fi
