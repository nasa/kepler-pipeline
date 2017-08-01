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

# Convert an FFI to an long-cadence-like data file (the PRMF is included in
#   this output):
#
TMP_LC_FILE=".tmp-ffi2lc.fits"
NUM_HDUS=84

# Parse args, using defaults when needed:
#
if [ $# -lt 2 ]; then
    echo "Usage: ffi2lc ffi_file lc_file [row_name col_name value]"
    exit 1;
fi
ffi_file="ffi.fits";   [ $# -ge 1 ] && ffi_file=$1
lc_file="new-lc.fits"; [ $# -ge 2 ] && lc_file=$2
row_name="row";        [ $# -ge 3 ] && row_name=$3
col_name="column";     [ $# -ge 4 ] && col_name=$4
value="value";         [ $# -ge 5 ] && value=$5

if [ ! -w . ]; then
    echo "Local dir is not writable.  Run from another location.";
    exit 1;
fi

if [ ! `which faddcol` ]; then
    echo "FTOOLS environment not detected";
    exit 1;
fi

/bin/cp $ffi_file $lc_file

# Copy the FFI file to the new LC file, and
#   clear the new file's HDUs.
#
for ((ii=1; ii <= NUM_HDUS; ++ii)); do
    echo -e -n "\rcreating file step $ii/$NUM_HDUS"
    fdelhdu $lc_file+1 N Y
done

# Convert the ith image HDU to a list in a temp file,
#   and then append the list from that temp file to
#   the output.
#
for ((ii=1; ii <= NUM_HDUS; ++ii)); do
    echo -e -n "\rpopulating data step $ii/$NUM_HDUS"
    fim2lst $ffi_file+$ii $TMP_LC_FILE x=$col_name y=$row_name value=$value copyall=no clobber=yes
    fappend $TMP_LC_FILE+1 $lc_file
done
echo -e -n "\r\n"

# Clean up
#
/bin/rm -f $TMP_LC_FILE

exit 0

