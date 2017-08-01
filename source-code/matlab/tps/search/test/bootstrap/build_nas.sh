#!/bin/bash
# 
# Copyright 2017 United States Government as represented by the
# Administrator of the National Aeronautics and Space Administration.
# All Rights Reserved.
# 
# NASA acknowledges the SETI Institute's primary role in authoring and
# producing the Kepler Data Processing Pipeline under Cooperative
# Agreement Nos. NNA04CC63A, NNX07AD96A, NNX07AD98A, NNX11AI13A,
# NNX11AI14A, NNX13AD01A & NNX13AD16A.
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

# set the paths we will need

TPS_ROOT=$SOC_CODE_ROOT/matlab/tps/search
NAS_BS_ROOT=$TPS_ROOT/test/bootstrap
MEX_ROOT=$TPS_ROOT/mex

# make a new path for the executable, if needed, and set $TPS_EXE_ROOT/latest
# to point at it

YEARSTR=$(date +%Y)
DOYSTR=$(date +%j)
YEARDOY="$YEARSTR$DOYSTR"
TPS_DEST=$TPS_EXE_ROOT/$YEARDOY
if [ ! -d $TPS_DEST ]; then
    mkdir $TPS_DEST
    rm $TPS_EXE_ROOT/latest
    ln -s -f $TPS_DEST $TPS_EXE_ROOT/latest
fi

# construct the mexfiles and put them into the MEX_ROOT directory

MEX_COMMAND="$MEX -f $MEX_ROOT/mexopts.sh -I$MEX_ROOT -outdir $MEX_ROOT"
$MEX_COMMAND $MEX_ROOT/fold_phases.c
$MEX_COMMAND $MEX_ROOT/fold_periods.c
$MEX_COMMAND $MEX_ROOT/find_ses_in_mes.c
$MEX_COMMAND $MEX_ROOT/median_filter.c

# build the function which returns the datestring

echo "function dateString = get_build_date_string" > $NAS_BS_ROOT/get_build_date_string.m
echo -n "dateString = '" >> $NAS_BS_ROOT/get_build_date_string.m
echo -n $(date) >> $NAS_BS_ROOT/get_build_date_string.m
echo "';" >> $NAS_BS_ROOT/get_build_date_string.m
echo "return" >> $NAS_BS_ROOT/get_build_date_string.m

# construct the executable and its shell script and put them into the 
# OUTPUT_DIR directory

$MCC -N -d $TPS_DEST -v -R -singleCompThread -m $NAS_BS_ROOT/run_bootstrap_monte_carlo_on_nas.m $NAS_BS_ROOT/get_build_date_string.m -p $MATLAB/toolbox/signal -p $MATLAB/toolbox/stats
# start constructing a new shell script, named run_tps_on_nas.sh

echo '#!/bin/bash' > $TPS_DEST/run_bootstrap_monte_carlo_on_nas.sh
echo "echo Datestamp of Build:" >> $TPS_DEST/run_bootstrap_monte_carlo_on_nas.sh
echo -n "echo " >> $TPS_DEST/run_bootstrap_monte_carlo_on_nas.sh
date >> $TPS_DEST/run_bootstrap_monte_carlo_on_nas.sh

# put the existing shell script into the new one and delete the original
cat $TPS_DEST/run_run_bootstrap_monte_carlo_on_nas.sh >> $TPS_DEST/run_bootstrap_monte_carlo_on_nas.sh
rm $TPS_DEST/run_run_bootstrap_monte_carlo_on_nas.sh
chmod u+x $TPS_DEST/run_bootstrap_monte_carlo_on_nas.sh


# build the executable version of the within-task aggregator

$MCC -N -d $NAS_BS_ROOT -v -R -singleCompThread -m $NAS_BS_ROOT/aggregate_bootstrap_files_on_nas.m -p $MATLAB/toolbox/signal -p $MATLAB/toolbox/stats
