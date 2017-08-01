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

my $delay = $ARGV[0];

if ($delay == 0) {
	die "Poll interval must be greater than zero\n";
}

do {
	my $ps = `ps -ef | grep Wrapper | grep -v grep`;
	my @Processes = split(/\n/, $ps);
	for my $proc (@Processes) {
		my @ProcInfo = split(/\s+/, $proc);
		my $watchPid = $ProcInfo[1];
		printMemInfo($watchPid);	
	}
	sleep($delay);
} while (1);


#END.

sub printMemInfo {
	my $watchPid = shift;

	if (!open(F, "< /proc/$watchPid/statm")) {
		print timeStamp() . " Failed to open statm file for pid $watchPid\n";
		return;
	}
		
	my $line = <F>;
	chomp $line;
	#all units are in pages
	my ($current, $resident, $shared, $code, $dataStack, $library, $dirty)  =
	split(/\s+/, $line);

	for $pageSize ($current, $resident, $code, $dataStack, $library, $dirty) {
		$pageSize = pagesToGiBytes($pageSize);
	}

	print timeStamp() .
	      " Pid $watchPid, Total Size : " . $current .
		"GiB Resident : " . $resident . "GiB\n";
	

}

sub timeStamp {
	my $date = `date`;
	chomp $date;
	return $date;
}

sub pagesToGiBytes {
	my $pageCount = shift;
	my $PAGE_SIZE = 1024 * 4;
	my $GiBytes = 1024*1024*1024;

	return $pageCount*$PAGE_SIZE/$GiBytes;
}
