#!/bin/sh 
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

function cleanup {
    case "${database_dialect}" in
org.hibernate.dialect.HSQL*)
    $bin/hsqldb stop
    ;;
    esac
}

trap cleanup EXIT

bin=`dirname $0`
soc_data_root=${SOC_DATA_ROOT:-/path/to/rec}
soc_dev_root=/path/to/dev
data=/path/to/data
local_data=/path/to/local/data
database_dialect=`awk -F '=' '$1 == "hibernate.dialect" {printf "%s", $2}' < $bin/../etc/kepler.properties`

set -o nounset
set -o errexit

echo "Archiving task and log files..."

$bin/archive.sh --dev-pipeline

echo "Deleting old ETEM, HSQLDB & filestore files..."

# The following command may fail with multiple messages of the form:
# rm: cannot remove `<directory pathname>': Directory not empty
# This is caused by undeletable files named ".fuse_hiddenxxxxxxxxxxxxxxxx*",
# where 'x' stands for a hexadecimal digit.
# See "http://serverfault.com/questions/478558/how-to-delete-fuse-hidden-files"
# If this happens, you can use the "lsof" shell command to list open files.
# This will show the process ID of the process that is keeping the file open.
# When that process is killed, the .fuse_hidden* files will become deletable.

rm -rf $soc_dev_root/*

case "${database_dialect}" in
org.hibernate.dialect.Oracle*)

    ROWS="`runjava ddlinit rows | tail -1 | sed -e 's/\([0-9]+\)[ \n]*/\1/'`"
    declare -i ROWS
    if [ ${ROWS:-1} -gt 0 ]
    then
        echo "Aborting, database contains data!" >&2
        exit 1
    fi

    if [ -d "${data}/hibernate/schema/${USER}" ]
    then
        data_root_dir="${data}/hibernate/schema/${USER}"
    elif [ -d "${local_data}/hibernate/schema/${USER}" ]
    then
        data_root_dir="${local_data}/hibernate/schema/${USER}"
    else
        unset data_root_dir
    fi

    TABLES="`runjava ddlinit table-count | tail -1 | sed -e 's/\([0-9]+\)[ \n]*/\1/'`"

    if [ "${data_root_dir+set}" = "set" \
         -a -f "${data_root_dir}/ddl.oracle-drop.sql" \
         -a ${TABLES:-1} -gt 0 ]
    then

        echo "Cleaning Oracle database..."

        $bin/runjava execsql -continueOnError "${data_root_dir}/ddl.oracle-drop.sql"
    fi

    echo "Creating Oracle schema..."

    $bin/runjava execsql $bin/../etc/schema/ddl.oracle-create.sql
    ;;

org.hibernate.dialect.HSQL*)

    $bin/hsqldb start
    sleep 1

    echo "Creating hsqldb schema..."

    $bin/runjava execsql $bin/../etc/schema/ddl.hsqldb-create.sql
    ;;
*)
    echo "${database_dialect}: unknown database dialect" >&2
    exit 1
    ;;
esac

echo "Loading DEV seed data..."

$bin/seed-xml.sh
$bin/runjava pl-import $soc_data_root/dev/pipeline_parameters/pl/overrides-for-dev-pipeline.xml 

echo "Creating DR directories..."

mkdir -p $soc_dev_root/dr/working/incoming
mkdir -p $soc_dev_root/dr/working/processing

echo "Done!"

