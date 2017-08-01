#!/usr/bin/perl -w
#This script configures the OS for the file store server.
#This must be run as root.
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

use strict;
use English;

if ($ENV{'USER'} ne "root") {
    die "This program must be run as root.\n";
}

my $doLimits = 0;
my $doMaxFiles = 0;
my $doIoSched = 0;
my $limitsFile = "/etc/security/limits.conf";

for (my $i=0; $i < @ARGV; $i++) {
    my $option = $ARGV[$i];
    if ($option eq "-a") {
	$doLimits = 1;
	$doMaxFiles = 1;
	$doIoSched = 1;
    } elsif ($option eq "-l") {
	$doLimits = 1;
    } elsif ($option eq "-m") {
	$doMaxFiles = 1;
    } elsif ($option eq "-i") {
	$doIoSched = 1;
    } elsif ($option eq "-f") {
	$limitsFile = $ARGV[++$i];
	if ($limitsFile eq "" || $limitsFile =~ /^-/) {
	    die "Bad limits file \"$limitsFile\".\n";
	}
    } else {
        die "Bad option \"$option\".\n";
    }
}

if (!($doLimits || $doMaxFiles || $doIoSched)) {
    die "Specify an option.\n";
}

#This configures resource limits
if ($doLimits) {
    configureLimits($limitsFile);
}


#Configure the system wide maximum number of open files.  This seems to
#increase performance even if this number is never reached.
if ($doMaxFiles) {
    configureMaxFiles();
}

#This configures the I/O scheduler based on multipathd output

if ($doIoSched) {
    $main::FILE_STORE_DATA_g = "fsdata";
    $main::NFS_DATA_g = "nfs";
    $main::FILE_STORE_LOG_g = "fslog";
    
    
    my $multipath = `/sbin/multipath -ll`;
    if ($CHILD_ERROR) {
	die "Failed to execute multipath.\n$multipath\n";
    }
    
    foreach my $line (split(/\n/, $multipath)) {
	if ($line !~ /($main::FILE_STORE_DATA_g|$main::FILE_STORE_LOG_g|$main::NFS_DATA_g)\d+.*\([0-9a-fA-F]+\)\s+(dm-\d+)+\s+3PARdata,VV$/) {
	    next;
	}
	
	my $multipathAliasPrefix = $1;
	my $deviceMapperDevice = $2;
	print "Found configurable device \"$multipathAliasPrefix $deviceMapperDevice\"\n";
	my @DiskDevices = findDiskDevicesForDeviceMapperDevice($deviceMapperDevice);
	if ($#DiskDevices == 0) {
	    die "Did not find any file store disk devices needing configuration.\n";
	}
	
	print "Found disk devices potentially needing I/O scheduler configuration " . join(",",@DiskDevices) . "\n";
	
	
	foreach my $diskDevice (@DiskDevices) {
	    configureDiskDevice($diskDevice, $multipathAliasPrefix);
	}
    }
    
}
exit 0;
#END.

sub configureDiskDevice {
    my $diskDevice = shift;
    my $multipathDevice = shift;

    my $schedulerParameter = "/sys/block/$diskDevice/queue/scheduler";
    if ($multipathDevice =~ /($main::FILE_STORE_DATA_g|$main::NFS_DATA_g)/) {
	print "Setting $schedulerParameter to \"deadline\".\n";
	open(F,"> $schedulerParameter") || die "Failed to open $schedulerParameter\n";
	print F "deadline";
	close(F);
    }

    if ($multipathDevice =~ /$main::FILE_STORE_LOG_g/) {
	print "Setting $schedulerParameter to \"anticipatory\".\n";
	open(F, "> $schedulerParameter") || die "Failed to open $schedulerParameter\n";
	print F "anticipatory";
	close(F);
    }
}

sub findDiskDevicesForDeviceMapperDevice {
    my $dmDevice = shift;

    if ($dmDevice !~ /dm-\d+/) {
	die "Invalid device name \"$dmDevice\".\n";
    }

    my $lsOutput = `ls -1 /sys/block/$dmDevice/slaves`;
    if ($CHILD_ERROR) {
	die "Failed to find slave devices for \"$dmDevice\".\n$lsOutput\n";
    }

    my @Rv;
    for my $line (split(/\n/, $lsOutput)) {
	$line =~ s/@//;
	push(@Rv, ($line));
    }

    return @Rv;
}

#arg0: limit file name
sub configureLimits {
    my $limitsFile = shift;
    my $NOFILE_SOFT_LIMIT = 10*1024;
    my $NOFILE_HARD_LIMIT = 256*1024;
    my $NPROC_SOFT_LIMIT = 2 * 1024;
    my $NPROC_HARD_LIMIT = 2 * 1024;
    my $LIMITS_FILE = "/etc/security/limits.conf";
    
    configureLimit("nofile", $NOFILE_SOFT_LIMIT, $NOFILE_HARD_LIMIT, $limitsFile);
    configureLimit("nproc", $NPROC_SOFT_LIMIT, $NPROC_HARD_LIMIT, $limitsFile);
}

#arg0: the name of the limit, e.g. "nproc"
#arg1: The soft limit value.
#arg2: The hard limit value.
#arg3: The name of the limits file.
sub configureLimit {
    my $limitName = shift;
    my $softLimit = shift;
    my $hardLimit = shift;
    my $limitsFile = shift;

    if (! -w $limitsFile) {
	die "Limits file \"$limitsFile\" is not writable.\n";
    }

    my $softOk = 0;
    my $grepSoft = `grep "* soft $limitName $softLimit" $limitsFile`;
    if ($CHILD_ERROR == 2) {
	die "Failed to grep $limitsFile\n". $grepSoft;
    } elsif ($CHILD_ERROR == 0) {
	$softOk = 1;
    }
    
    my $hardOk = 0;
    my $grepHard = `grep "* hard nofile $hardLimit" $limitsFile`;
    if ($CHILD_ERROR == 2) {
	die "Failed to grep $limitsFile\n" . $grepHard;
    } elsif ($CHILD_ERROR == 0) {
	$hardOk = 1;
    }
    
    if ($hardOk && $softOk) {
	print "Limit $limitName already configured.\n";
	return;
    }
    
    open(LIMITS_CONF, "< $limitsFile") || die "Can't open file \"$limitsFile\" for reading.\n";
    my @Lines = <LIMITS_CONF>;
    close(LIMITS_CONF);
    
    #Remove old lines and add new lines to tmp file.
    #There are usually some kind of security problems with using tmp files in
    #world writable directories so I'm going to avoid that here by making the
    #tmp file in /root.
    open(TMP_LIMITS, "> /root/limits.conf.tmp") || die "Failed to open file /root/limits.conf.tmp for writing.\n";
    for (my $i=0; $i < @Lines; $i++) {
	my $line = $Lines[$i];
	next if ($line =~ /^\s*\*\s+(soft|hard)\s+$limitName/);
	next if ($line =~ /configureOSForFileStoreServer.pl/ && $Lines[$i + 1] =~ /$limitName/);
	print TMP_LIMITS $line;
    }
    print TMP_LIMITS "# The following two lines are configured by configureOSForFileStoreServer.pl\n";
    print TMP_LIMITS "* soft $limitName  $softLimit\n";
    print TMP_LIMITS "* hard $limitName  $hardLimit\n";
    close(TMP_LIMITS);
    
    
    my $mvOutput = `mv /root/limits.conf.tmp $limitsFile`;
    if ($CHILD_ERROR) {
	die "Failed to move tmp limits file to actual limits file \"$limitsFile\".\n" . $mvOutput;
    }
    
    print "Configured $limitName in $limitsFile.\n";
}

sub configureMaxFiles() {
    my $FILE_MAX_PATH = "/proc/sys/fs/file-max";
    my $FILE_MAX = 3_000_000;
    open(FILE_MAX, "< $FILE_MAX_PATH") || die "Can't open $FILE_MAX_PATH.\n";
    my $currentFileMax = <FILE_MAX>;
    chomp $currentFileMax;
    close(FILE_MAX);
    
    if ($currentFileMax < $FILE_MAX) {
	my $echoOut = `echo $FILE_MAX > $FILE_MAX_PATH`;
	if ($CHILD_ERROR) {
	    die "Failed to set $FILE_MAX_PATH to $FILE_MAX\n";
	}
	print "Configured $FILE_MAX_PATH for $FILE_MAX open files.\n";
    } else {
	print "Current $FILE_MAX_PATH is $currentFileMax which is greater than the number of open files needed; $FILE_MAX.\n";
    }
}
