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

# Convert a long cadence data file (and a PMRF file) to an FFI:
#
TMP_LC_FITS=".tmp-lc2ffi-lc.fits"
TMP_IMG_FITS=".tmp-lc2ffi-img.fits"
NUM_HDUS=84

# Parse args, using defaults when needed:
#
if [ $# -lt 2 ]; then
    echo "Usage: lc2ffi.sh lc_file pmrf_file ffi_file [row_name col_name value ]"
    exit 1;
fi
lc_file="lc.fits";       [ $# -ge 1 ] && lc_file=$1
pmrf_file="pmrf.fits";   [ $# -ge 2 ] && pmrf_file=$2
ffi_file="new-ffi.fits"; [ $# -ge 3 ] && ffi_file=$3
row_name="row";          [ $# -ge 4 ] && row_name=$4
col_name="column";       [ $# -ge 5 ] && col_name=$5
value="orig_value";      [ $# -ge 6 ] && value=$6

if [ ! -w . ]; then
    echo "Local dir is not writable.  Run from another location.";
    exit 1;
fi

if [ ! `which faddcol` ]; then
    echo "FTOOLS environment not detected";
    exit 1;
fi

/bin/cp $lc_file $TMP_LC_FITS

# Paste the PMRF file row/col information onto each HDU of the 
#   tmp-lc file:
#
for ((ii=1; ii <= NUM_HDUS; ++ii)); do
    faddcol $TMP_LC_FITS+$ii $pmrf_file+$ii $row_name,$col_name
done

# Copy the long-cadence file to the new FFI file, and
#   clear the new FFI's HDUs, then, create images from 
#   long-cadence files, and copy those images to the 
#   last HDU of the output new FFI.
#
/bin/cp $lc_file $ffi_file

for ((ii=1; ii <= NUM_HDUS; ++ii)); do
    echo -e -n "\rcreating file step $ii/$NUM_HDUS"
    fdelhdu $ffi_file+1 N Y
done

# Strip the success echo from flst2im output:
#
for ((ii=1; ii <= NUM_HDUS; ++ii)); do
    echo -e -n "\rpopulating data step $ii/$NUM_HDUS"
    flst2im $TMP_LC_FITS+$ii $TMP_IMG_FITS \
        rows=- xcol=$col_name ycol=$row_name value=$value \
        xrange=1,1132 yrange=1,1070 clobber=yes | \
        egrep -v '^( || ... Successfully completed FLST2IM )$'
    fappend $TMP_IMG_FITS+0 $ffi_file
done
echo -e -n "\r\n"

# Clean up
#
/bin/rm -f $TMP_LC_FITS $TMP_IMG_FITS

exit 0

