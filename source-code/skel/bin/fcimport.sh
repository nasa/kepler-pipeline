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

# $1 CODEREV "i128"
# $2 DATAREV "r274"
# $3 USER "tklaus"
# $4 SVNURL "v4"

CODEREV = $1
DATAREV = $2
USER = $3
SVNURL = $4

./runjava import-rolltime rewriteHistory "$CODEREV $DATAREV $USER svn+ssh://host/path/to/roll-time/$SVNURL"
./runjava import-pointing rewriteHistory "$CODEREV $DATAREV $USER svn+ssh://host/path/to/pointing/$SVNURL"
./runjava import-geometry rewriteHistory "$CODEREV $DATAREV $USER svn+ssh://host/path/to/geometry/$SVNURL"
./runjava import-readnoise rewriteHistory "$CODEREV $DATAREV $USER svn+ssh://host/path/to/read-noise/$SVNURL"
./runjava import-read-noise rewriteHistory "$CODEREV $DATAREV $USER svn+ssh://host/path/to/read-noise/$SVNURL"
./runjava import-gain rewriteHistory "$CODEREV $DATAREV $USER svn+ssh://host/path/to/gain/$SVNURL"
./runjava import-linearity rewriteHistory "$CODEREV $DATAREV $USER svn+ssh://host/path/to/linearity/$SVNURL"
./runjava import-undershoot rewriteHistory "$CODEREV $DATAREV $USER svn+ssh://host/path/to/undershoot/$SVNURL"
./runjava import-invalid-pixels rewriteHistory "$CODEREV $DATAREV $USER svn+ssh://host/path/to/$SVNURL"
./runjava import-large-flat rewriteHistory "$CODEREV $DATAREV $USER svn+ssh://host/path/to/large-flat/$SVNURL"
./runjava import-largeflat rewriteHistory "$CODEREV $DATAREV $USER svn+ssh://host/path/to/large-flat/$SVNURL"
./runjava import-prf rewriteHistory "$CODEREV $DATAREV $USER svn+ssh://host/path/to/prf/$SVNURL"
./runjava import-prf rewriteHistory "$CODEREV $DATAREV $USER svn+ssh://host/path/to/prf/$SVNURL"
./runjava import-two-d-black rewriteHistory "$CODEREV $DATAREV $USER svn+ssh://host/path/to/two-d-black/$SVNURL"
./runjava import-2dblack rewriteHistory "$CODEREV $DATAREV $USER svn+ssh://host/path/to/two-d-black/$SVNURL"
./runjava import-smallflat rewriteHistory "$CODEREV $DATAREV $USER svn+ssh://host/path/to/small-flat/$SVNURL"
