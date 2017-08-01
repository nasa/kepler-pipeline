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

export DEFAULT_ROOT='.'

USAGE='"
Usage: ${0##*/} [-d <dir>] <sed-cmd> ... | -s <from> <to>

Where
        -d <dir>    The root directory containing the *.m input
                    files (the default is \""${DEFAULT_ROOT}"\").
        <sed-cmd>   The sed(1) command(s) to be executed.
"'

# print help message
if [ $# -eq 0 ]
then
    eval echo "${USAGE}" ; exit 0
fi

# command line args
unset ROOT PATTERN REPLACE
while [ $# -gt 0 ]
do
    case "${1}" in
    -d) shift ; export ROOT="${1}" ; shift ;;
    -s) if [ $# -eq 3 ]
        then
            shift
            export PATTERN="${1}" ; shift
            export REPLACE="${1}" ; shift
        else
            echo "Missing required args to 's' option." >&2
            eval echo "${USAGE}" >&2 ; exit 1
        fi ;;
    *)  break ;;
    esac
done

if [ $# -eq 0 -a "${PATTERN+yes}" != "yes" ]
then
    echo "Missing required sed(1) commands." >&2
    eval echo "${USAGE}" >&2 ; exit 1
fi

# find and update matching files
case "${PATTERN+yes}" in
yes)
    find "${ROOT:-${DEFAULT_ROOT}}" -type f -name \*.m \
    | xargs egrep -l "${PATTERN}" \
    | xargs sed -i '' "s/${PATTERN}/${REPLACE}/g"
    ;;
*)
    find "${ROOT:-${DEFAULT_ROOT}}" -type f -name \*.m \
    | xargs sed ${1+"${@}"}
    ;;
esac
