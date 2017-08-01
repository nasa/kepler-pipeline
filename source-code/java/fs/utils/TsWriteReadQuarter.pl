#!/usr/bin/perl -w
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

#Reads and writes a quarter of data.  This uses C3 and should be run on the
#cluster master machine.

use English;
use integer;
use strict;

#$DIST_PATH_g="/path/to/dist";
$main::DIST_PATH_g="/path/to/dist";

my $N_HOSTS = 1;
my $N_POINTS = 1440;
my $TOTAL_CLIENTS = 1;
my $CADENCE_PER_MONTH = 24*2*30;
my $MONTH_GAP = 2*24;
my $PGAP = "1/60";
my $NSERIES = 1;



open(LOG, "> TsReadWrite.log") || die "Can't open log file.";
my $startCadence = 0;
for (my $month=0; $month < 3; $month++, $startCadence += $CADENCE_PER_MONTH + $MONTH_GAP) {
    runStuff($NSERIES, $N_POINTS, $TOTAL_CLIENTS, $PGAP, $startCadence);
}
close(LOG);

#END.

sub runStuff {
    my $nseries = shift;
    my $npoints = shift;
    my $totalClients = shift;
    my $PGap = shift;
    my $startCadence = shift;

    if (($totalClients % $N_HOSTS) != 0) {
	die "Total clients must be a multiple of N_HOSTS.\n";
    }

    my $clientsPerHost = $totalClients / $N_HOSTS;
    my $cmd = "/opt/c3-4/cexec -f ../etc/c3.conf 'cd $main::DIST_PATH_g/bin; ./runjava fsclient-tsload -id `hostname` -nt $clientsPerHost -ns $nseries -nd $npoints -pgap $PGap -sc $startCadence '";
#   

    my $startMessage = "Starting test run with nseries:$nseries npoints:$npoints totalClients:$totalClients startCadence:$startCadence\n";
    print $startMessage;
    print LOG $startMessage;

    my $writeOnly = `$cmd -w`;
    print LOG $writeOnly;
    if ($CHILD_ERROR) {
	die "$writeOnly\n";
    }

    my $readOnly = `$cmd -r`;
    print LOG $readOnly;
    if ($CHILD_ERROR) {
	die "$readOnly\n";
    }
    
}


