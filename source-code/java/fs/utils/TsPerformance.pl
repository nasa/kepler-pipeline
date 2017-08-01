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

#This runs the time series performance test through different permutations.
#This should be executed on the machine the file store server will be
#running.

use English;
use integer;

$FILESTORE_CONFIG_g = "../etc/kepler.properties";
$N_HOSTS = 4;

my @NSeriesPoints = ([1, 1440], [10000, 1440], [32000, 1440], [1, 10000], [8000, 10000]);

#Until I fix runStuff() this must be a multiple of N_HOSTS
my @ServerMaxClient = qw(4);
my @TotalClients = qw(8 32 64);

open(LOG, "> TsPerformance.log") || die "Can't open log file.";

foreach my $nseriesPoints (@NSeriesPoints) {
    foreach my $totalClients (@TotalClients) {
	foreach my $serverMaxClients (@ServerMaxClient) {
	    my $nseries = $nseriesPoints->[0];
	    my $npoints = $nseriesPoints->[1];
	    next if ($serverMaxClients >$totalClients);
	    cleanFileStore($nseries * $totalClients);
	    setFileStoreMaxClients($serverMaxClients);
	    startFileStore();
	    runStuff($nseries, $npoints, $totalClients, $serverMaxClients);
	}
    }
}

close(LOG);

#END.

sub runStuff {
    my $nseries = shift;
    my $npoints = shift;
    my $totalClients = shift;
    my $serverMaxClients = shift;

    if (($totalClients % $N_HOSTS) != 0) {
	die "Total clients must be a multiple of N_HOSTS.\n";
    }

    my $clientsPerHost = $totalClients / $N_HOSTS;
    my $cmd = "/opt/c3-4/cexec -f ../etc/c3.conf 'cd /path/to/dist/bin; ./runjava fsclient-tsload -id `hostname` -nt $clientsPerHost -ns $nseries -nd $npoints'";

    my $startMessage = "Starting test run with nseres:$nseries npoints:$npoints totalClients:$totalClients serverMaxClients:$serverMaxClients\n";
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

sub startFileStore {
    my $startMessage = `./fs start`;
    if ($CHILD_ERROR) {
	die "Failed to start file store server.\n" . $startMessage;
    }
    #TODO:  Really we should check the log and wait for the listening
    #message
    sleep 10;
}

sub setFileStoreMaxClients {
    my $maxClients = shift;

    my $removeOutput = 
	`grep -v fs.server.max-concurrent-read-write $FILESTORE_CONFIG_g`;

    if ($CHILD_ERROR) {
	die "Failed to remove concurrent read-write setting.\n". $removeOutput;
    }

    my $reconfigured = $removeOutput . "\nfs.server.max-concurrent-read-write=$maxClients\n";
   
    open(F, "> $FILESTORE_CONFIG_g") || die "Failed to open \"$FILESTORE_CONFIG_g\" for writing.\n";

    print F $reconfigured;
    close(F);

}

sub cleanFileStore {
    my $nTotalSeries = shift;

    my $fsStopOutput = `./fs stop`;
    if ($CHILD_ERROR && $fsStopOutput !~ /not running/i) {
	die "Failed to stop file store server.\n" .$fsStopOutput;
    }

    my $fsConfigOutput = `grep fs.data.dir $FILESTORE_CONFIG_g`;
    if ($CHILD_ERROR) {
	die "Can't find fs.data.dir \n" . $fsConfigOutput ;
    }

    $fsConfigOutput =~ /^fs.data.dir=(\S+)/mg;
    if ($1 eq "") {
	die "$FILESTORE_CONFIG_g does not contain fs.data.dir\n" . $fsConfigOutput;
    }

    if ( -e "/usr/local/bin/init-filestore.pl"   && $nTotalSeries > 80000) {
	 
	my $initFilestoreOut = `sudo /usr/local/bin/init-filestore.pl`;
	if ($CHILD_ERROR) {
	    die "Failed to clean file store.\n" . $initFilestoreOut;
	}
    } else {
	my $dataDir = $1;

	if ($dataDir eq "." || $dataDir eq "/") {
	    die "Cowardly refusing to remove data in \"$dataDir\".";
	}

	my $rmOut = `rm -fr $dataDir`;
	if ($CHILD_ERROR) {
	    die "Failed to delete \"$dataDir\"\n" . $rmOut;
	}
    }

}
