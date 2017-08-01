#!/usr/bin/perl -w
#Calculates the minimum and maximum times from the KTC.
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

sub min {
    my $a = shift;
    my $b = shift;
    if ($a < $b) {
	return $a;
    }
    return $b;
}

sub max {
    my $a = shift;
    my $b = shift;
    if ($a > $b) {
	return $a;
    }
    return $b;
}

my $minActualStart = 99999999;
my $maxActualStart = -1;
my $minActualEnd = 99999999;
my $maxActualEnd = -1;
my $minPlannedStart = 9999999;
my $maxPlannedStart = -1;
my $minPlannedEnd = 999999999;
my $maxPlannedEnd = -1;

open(F, "< $ARGV[0]") || die "Can't open \"$ARGV[0]\"\n";

while (my $in = <F>) {
    chomp $in;
    next if ($in =~ /^#/);
    
    my @F = split(/\|/, $in);
    my $keplerId =    $F[0];
    my $cadenceType = $F[1];
    my $categories =  $F[2];
    my $plannedStart = $F[3];
    my $plannedEnd =   $F[4];
    my $actualStart =  $F[5];
    my $actualEnd =    $F[6];
    next if ($cadenceType eq "SC");
    
    if (defined $actualStart) {
	$minActualStart = min($minActualStart, $actualStart);
	$maxActualStart = max($maxActualStart, $actualStart);
    }
    if (defined $actualEnd) {
	$minActualEnd = min($minActualEnd, $actualEnd);
	$maxActualEnd = max($maxActualEnd, $actualEnd);
    }
    $minPlannedStart = min($minPlannedStart, $plannedStart);
    $maxPlannedStart = max($maxPlannedStart, $plannedStart);
    $minPlannedEnd = min($minPlannedEnd, $plannedEnd);
    $maxPlannedEnd = max($maxPlannedEnd, $plannedEnd);
}


if ($minActualStart > $maxActualStart) {
    print "Bad actual times\n";
}

print "minActualStart $minActualStart\n";
print "maxActualStart $maxActualStart\n";
print "minActualEnd $minActualEnd\n";
print "maxActualEnd $maxActualEnd\n";
print "minPlannedStart $minPlannedStart\n";
print "maxPlannedStart $maxPlannedStart\n";
print "minPlannedEnd $minPlannedEnd\n";
print "maxPlannedEnd $maxPlannedEnd\n";

close(F);
#END.
