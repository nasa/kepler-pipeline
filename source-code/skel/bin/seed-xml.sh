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

bin=`dirname $0`
soc_data_root=${SOC_DATA_ROOT:-/path/to/rec}

set -o nounset
set -o errexit

echo "Loading seed data from xml files..."

$bin/runjava seed-security
$bin/runjava pl-import $soc_data_root/flight/so/pipeline_parameters/soc/parameter-library.xml \
	$soc_data_root/dev/pipeline_parameters/pl/default.xml \
	$soc_data_root/dev/pipeline_parameters/pl/lc.xml \
	$soc_data_root/dev/pipeline_parameters/pl/sc.xml \
	$soc_data_root/dev/pipeline_parameters/pl/rp.xml \
	$soc_data_root/dev/pipeline_parameters/pl/ffi.xml \
	$soc_data_root/dev/pipeline_parameters/pl/q0.xml \
	$soc_data_root/dev/pipeline_parameters/pl/q1.xml \
	$soc_data_root/dev/pipeline_parameters/pl/q2.xml \
	$soc_data_root/dev/pipeline_parameters/pl/q3.xml \
	$soc_data_root/dev/pipeline_parameters/pl/q4.xml \
	$soc_data_root/dev/pipeline_parameters/pl/q5.xml \
	$soc_data_root/dev/pipeline_parameters/pl/q6.xml \
	$soc_data_root/dev/pipeline_parameters/pl/q7.xml \
	$soc_data_root/dev/pipeline_parameters/pl/overrides-for-smoke-test.xml
	
$bin/runjava pc-import $soc_data_root/dev/pipeline_parameters/pc/default.xml 

# Params & config for the debug pipeline

$bin/runjava pl-import $soc_data_root/dev/pipeline_parameters/pl/debug.xml 
$bin/runjava pc-import $soc_data_root/dev/pipeline_parameters/pc/debug.xml 

