% analyze_ghost_diagnostic_data.m
% This script retrieves the ghost diagnostic statistics produced by a given
% DV run, and produces a statistical analysis sufficient for validation and testing
%===============================================
% 
% Copyright 2017 United States Government as represented by the
% Administrator of the National Aeronautics and Space Administration.
% All Rights Reserved.
% 
% NASA acknowledges the SETI Institute's primary role in authoring and
% producing the Kepler Data Processing Pipeline under Cooperative
% Agreement Nos. NNA04CC63A, NNX07AD96A, NNX07AD98A, NNX11AI13A,
% NNX11AI14A, NNX13AD01A & NNX13AD16A.
% 
% This file is available under the terms of the NASA Open Source Agreement
% (NOSA). You should have received a copy of this agreement with the
% Kepler source code; see the file NASA-OPEN-SOURCE-AGREEMENT.doc.
% 
% No Warranty: THE SUBJECT SOFTWARE IS PROVIDED "AS IS" WITHOUT ANY
% WARRANTY OF ANY KIND, EITHER EXPRESSED, IMPLIED, OR STATUTORY,
% INCLUDING, BUT NOT LIMITED TO, ANY WARRANTY THAT THE SUBJECT SOFTWARE
% WILL CONFORM TO SPECIFICATIONS, ANY IMPLIED WARRANTIES OF
% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR FREEDOM FROM
% INFRINGEMENT, ANY WARRANTY THAT THE SUBJECT SOFTWARE WILL BE ERROR
% FREE, OR ANY WARRANTY THAT DOCUMENTATION, IF PROVIDED, WILL CONFORM
% TO THE SUBJECT SOFTWARE. THIS AGREEMENT DOES NOT, IN ANY MANNER,
% CONSTITUTE AN ENDORSEMENT BY GOVERNMENT AGENCY OR ANY PRIOR RECIPIENT
% OF ANY RESULTS, RESULTING DESIGNS, HARDWARE, SOFTWARE PRODUCTS OR ANY
% OTHER APPLICATIONS RESULTING FROM USE OF THE SUBJECT SOFTWARE.
% FURTHER, GOVERNMENT AGENCY DISCLAIMS ALL WARRANTIES AND LIABILITIES
% REGARDING THIRD-PARTY SOFTWARE, IF PRESENT IN THE ORIGINAL SOFTWARE,
% AND DISTRIBUTES IT "AS IS."
% 
% Waiver and Indemnity: RECIPIENT AGREES TO WAIVE ANY AND ALL CLAIMS
% AGAINST THE UNITED STATES GOVERNMENT, ITS CONTRACTORS AND
% SUBCONTRACTORS, AS WELL AS ANY PRIOR RECIPIENT. IF RECIPIENT'S USE OF
% THE SUBJECT SOFTWARE RESULTS IN ANY LIABILITIES, DEMANDS, DAMAGES,
% EXPENSES OR LOSSES ARISING FROM SUCH USE, INCLUDING ANY DAMAGES FROM
% PRODUCTS BASED ON, OR RESULTING FROM, RECIPIENT'S USE OF THE SUBJECT
% SOFTWARE, RECIPIENT SHALL INDEMNIFY AND HOLD HARMLESS THE UNITED
% STATES GOVERNMENT, ITS CONTRACTORS AND SUBCONTRACTORS, AS WELL AS ANY
% PRIOR RECIPIENT, TO THE EXTENT PERMITTED BY LAW. RECIPIENT'S SOLE
% REMEDY FOR ANY SUCH MATTER SHALL BE THE IMMEDIATE, UNILATERAL
% TERMINATION OF THIS AGREEMENT.
%
clear all
close all

% Script dir
scriptDir = '/codesaver/work/test_ghost_diagnostic/scripts/';

% Input runId
runId = input('KSOP number, e.g. 2102, 2222, 2486, 2488, 2537 -- ','s');

% Identify the location of the original taskfiles directory corresponding to the KSOP number, of the run to analyze.
% The taskfiles directory is where the dvOuputMatrix.mat is found
% Specify the name of the corresponding local working directory 
switch runId
    case '2102'
        taskFilesDir = '/path/to/ksop-2102/dv/';
        localDir = '/codesaver/work/test_ghost_diagnostic/ksop-2102-dv-Q1-Q17-code-stabilization/';
    case '2222'
        taskFilesDir = '/path/to/ksop-2222-post-9.3-DV-full-Q1-Q17/';
        localDir = '/codesaver/work/test_ghost_diagnostic/ksop-2222-post9.3-full-run-Q1-Q17/';
    case '2486'
        taskFilesDir = '/path/to/ksop-2486-DV-mini-Overpopulation-Q1-Q17/';
        localDir = '/codesaver/work/test_ghost_diagnostic/ksop-2486-9.3-DV-mini-run-Overpopulation-Q1-Q17/';
    case '2488' % Results posted to KSOC-4959
        taskFilesDir = '/path/to/soc-9.3-reprocessing/mq-q1-q17/pipeline_results/dv-v2/';
        localDir = '/codesaver/work/test_ghost_diagnostic/ksop-2488-9.3-DV-reprocessing-V2/';
    case '2537' % Results posted to KDAWG-217
        taskFilesDir = '/path/to/mq-q1-q17/pipeline_results/dv-v4/';
        localDir = '/codesaver/work/test_ghost_diagnostic/ksop-2537-9.3-DV-reprocessing-V4/';
        
end

% Data directory
dataDir = '/codesaver/work/test_ghost_diagnostic/data/';

% Load a local copy of the DV output matrix; if it has not been saved locally,
% get it from the taskfiles directory and make a local copy.
if(exist([localDir,'dvOutputMatrix.mat'],'file'))
    load([localDir,'dvOutputMatrix.mat'])
elseif(exist(taskFilesDir,'dir'))
    load([taskFilesDir,'dvOutputMatrix.mat']);
    save([localDir,'dvOutputMatrix.mat'],'dvOutputMatrix','dvOutputMatrixColumns')
else 
    fprintf('Error -- Cannot find dvOutputMatrix.mat\n')
end

% Extract ghost diagnostic results: !!!!! check that the columns are still correct
% column 258: 'ghostDiagnosticResults.coreApertureCorrelationStatistic_value'
% column 259: 'ghostDiagnosticResults.coreApertureCorrelationStatistic_significance'
% column 260: 'ghostDiagnosticResults.haloApertureCorrelationStatistic_value'
% column 261: 'ghostDiagnosticResults.haloApertureCorrelationStatistic_significance'
coreStatisticValue = dvOutputMatrix(:,258);
coreStatisticSignificance = dvOutputMatrix(:,259);
haloStatisticValue = dvOutputMatrix(:,260);
haloStatisticSignificance = dvOutputMatrix(:,261);
cv = dvOutputMatrix(:,258);
cs = dvOutputMatrix(:,259);
hv = dvOutputMatrix(:,260);
hs = dvOutputMatrix(:,261);


%==========================================================================
% Check for TCEs whose core and halo values and statistics did not change
% from the initialized values. This means no ghost statistics were computed
noGhostDiagnosticsIdx = cv==0&hv==0&cs==-1&hs==-1;
fprintf('Of %d TCEs there were %d for which ghost diagnostics were not computed\n',length(cv),sum(noGhostDiagnosticsIdx))

% Extract known KoiId: !!!!! check that the columns are still correct
% column 189 targetKoiId -- set to -1 if no KOI is associated with this
% target (?)
% column 190 planetKoiId -- set to -1 if no KOI is associated with this TCE
% column 191 planetKoiCorrelation
targetKoiId = dvOutputMatrix(:,189);
planetKoiId = dvOutputMatrix(:,190);
% fix the planetKoiId that have entries beyond the 2nd decimal place (??)
% Indicator for KOIs

%==========================================================================
% 1. Look at ratio of halo value to core value for *all* TCEs for which
% ghost diagnostics were computed
n1 = length(cv);
idx = ~noGhostDiagnosticsIdx';
n2 = sum(idx);
rr = nanmedian( abs( hv(idx)./cv(idx) ) );
fprintf('There were %d TCEs,of which %d, or %7.1f percent had ghost diagnostics computed\n',n1,n2,n2/n1*100)
fprintf('Median absolute value of ratio of halo value to core value for these TCEs is %7.2f\n',rr)

% Histogram of Median absolute value of ratio of halo value to core value
figure
hold on
grid on
box on
hist(log10( abs( hv(idx)./cv(idx) ) ) , -15:0.5:5)
title(['abs ( (halo statistic)/(core statistic) ) for ',num2str(n2),' of ',num2str(n1),' TCEs with ghost diagnostic'])
xlabel('log10 ratio')
ylabel('Counts')
axis([-5,5,0,12000])
legend(['Median ratio = ',num2str(rr,'%7.1f')],'Location','NorthEast')
set(gca,'FontSize',12)
set(findall(gcf,'type','text'),'FontSize',12)
plotName = [localDir,'halo_to_core_ratio_for_all_TCes.png'];
print('-dpng','-r100',plotName)


%==========================================================================
% TCEs that have KOI numbers in dvOutputMatrix
koiIndicator = planetKoiId>0;
yy = planetKoiId(koiIndicator);
zz = zeros(length(yy),1);
for ind = 1:length(yy)
    zz(ind,1) = str2double(sprintf('%6.2f',yy(ind,1)));
end
planetKoiId(koiIndicator) = zz;

% KOIs for which ghost diagnostics were not computed
fprintf('Of the %d TCEs matched to known KOIs, there were %d for which ghost diagnostics were not computed\n',sum(koiIndicator),sum(koiIndicator&noGhostDiagnosticsIdx))

% Ephemeris correlation function !!!!! check that it's the correct column
planetKoiCorrelation = dvOutputMatrix(:,191);

% Set koi target and planet indicators
% koiPlanetIndicator = planetKoiId~=-1;
% koiTargetIndicator = targetKoiId~=-1;
% knownKoiPcIndicator = koiPlanetIndicator&koiTargetIndicator;

%=========================================================================

% Print a table with columns for keplerId, koiId, for each KOI from
% cumulative table, using perl
cd(dataDir)
% perl command format:
% !cat nexsci_cumulative_table05june2015.csv | perl -F/,/ -ane '$label="";$confirmedFlag = "";if ($F[4] =~ /(CANDIDATE)/) { $label = 1; } elsif (($F[4] =~ /FALSE/) && (($F[96] =~ 0) || ($F[99] =~ 1)) ) { $label = 2; } if($F[5] =~ /(CONFIRMED)/) {$confirmedFlag = 1;} else {$confirmedFlag = 0;} print "$F[1],$F[2],$F[9],$F[6],$F[15],$label,$F[96],$F[97],$F[98],$F[99],$confirmedFlag\n" if ($label ne "");  ' > test.csv
% !cat nexsci_cumulative_table05june2015.csv | perl -F/,/ -ane '$label="";if ($F[7] =~ /(CANDIDATE)/) { $label = 1; } elsif ($F[7] =~ /FALSE/) { $label = 2; } print "$F[1],$F[2],$F[7],$F[11]\n" if ($label ne "");  ' > ephemeris_match_list.csv
% !!!!! Note 2/19/2016 -- downloaded the nexsci cumulative KOI table
% q1_q17_dr24_koi.csv from
% http://exoplanetarchive.ipac.caltech.edu/cgi-bin/TblView/nph-tblView?app=ExoTbls&config=cumulative,
% !!!!! Column definitions changed from last version of cumulative table
% Disposition is now Column 5 (was column 7)
% Ephemeris match flag is now Column 9 (was column 11)
% I edited the perl command below to account for the changes.
!cat q1_q17_dr24_koi.csv | perl -F/,/ -ane '$label="";if ($F[5] =~ /(CANDIDATE)/) { $label = 1; } elsif ($F[5] =~ /FALSE/) { $label = 2; } print "$F[1],$F[2],$F[5],$F[9]\n" if ($label ne "");  ' > ephemeris_match_list.csv
ephemeris_match_filename = strcat('ephemeris_match_list_',runId,'.csv');
movefile('ephemeris_match_list.csv',ephemeris_match_filename);
cd(scriptDir)
[A] = importdata([dataDir,ephemeris_match_filename]);
ephemerisMatchIndicator= logical(A.data);
nexsciKeplerIdList = str2double(A.textdata(:,1));
nexsciKoiList = A.textdata(:,2);
nexsciArchiveDisposition = A.textdata(:,3);

% Read the nexsci cumulative table file (downloaded on 17nov2014)
% and make indicator for which TCEs are known planet candidates
% [num,text,raw] = xlsread([dataDir,'cumulative_no_headers.xls']);

% Columns
% 1 (num) index number (1 to 7305)
% 2 (num) keplerId
% 3 (text) Koi number
% 4 (text) disposition using Kepler data <== classes 'CANDIDATE', 'FALSE POSITIVE'
% 5 (text) exoplanet archive disposition  <== classes 'CONFIRMED', 'CANDIDATE', 'FALSE POSITIVE'
% nexsciKoiList = text(:,3);
% nexsciKeplerIdLlist = num(:,2);
% nexsciArchiveDisposition = text(:,4);
nexsciKoiPcId = nan(length(nexsciKoiList),1);
nexsciKoiFpId = nan(length(nexsciKoiList),1);
nexsciKoiNdId = nan(length(nexsciKoiList),1);
nexsciPcDispositionIndicator = false(length(nexsciKoiList),1);
nexsciFpDispositionIndicator = false(length(nexsciKoiList),1);
nexsciNdDispositionIndicator = false(length(nexsciKoiList),1);
for iCell = 1:length(nexsciKoiList);
    % nexsci archive disposition
    tmp1 = nexsciArchiveDisposition{iCell};
    % Indicator for planet candidates in nexsci list (length 7305)
    nexsciPcDispositionIndicator(iCell) = strcmp(tmp1,'CANDIDATE');
    nexsciFpDispositionIndicator(iCell) = strcmp(tmp1,'FALSE POSITIVE');
    nexsciNdDispositionIndicator(iCell) = strcmp(tmp1,'NOT DISPOSITIONED');
    % List of numerical Koi Id for planet candidates
    numericalKoiId = nexsciKoiList{iCell};
    if(nexsciPcDispositionIndicator(iCell))
        nexsciKoiPcId(iCell) =  str2double(numericalKoiId(2:end));
    elseif(nexsciFpDispositionIndicator(iCell))
        nexsciKoiFpId(iCell) =  str2double(numericalKoiId(2:end));
    else 
        fprintf('KOI index %d is Neither PC nor FP, nexsciArchiveDisposition = %s \n',iCell,nexsciArchiveDisposition{iCell})
        nexsciKoiNdId(iCell) =  str2double(numericalKoiId(2:end));
    end
end

% Map planetKoiId (from dvOutputMatrix) to nexsciKoiId (cumulative nexsci table) entries that are PC and FP
% iPc and iFp are indicators in dvOutputMatrix list
[~, ~, iPc] = intersect(nexsciKoiPcId,planetKoiId);
[~, ~, iFp] = intersect(nexsciKoiFpId,planetKoiId);
[~, ii, iNd] = intersect(nexsciKoiNdId,planetKoiId);
% KOIs with nexsci ephemeris flag
[~, ~, iEm] = intersect(nexsciKoiFpId(ephemerisMatchIndicator),planetKoiId);

% statistics
fprintf('Matching statistics %d PCs, %d FPs, %d Not dispositioned, %d nexsci ephem flag\n',length(iPc),length(iFp),length(iNd),length(iEm))
% Set indicators for tce Kois that are matched to the nexsciKoiId table
% entries that are PC and FP
tceNexsciKoiPcMatchIndicator = false(1,length(planetKoiId));
tceNexsciKoiPcMatchIndicator(iPc) = true;
tceNexsciKoiFpMatchIndicator = false(1,length(planetKoiId));
tceNexsciKoiFpMatchIndicator(iFp) = true;
tceNexsciKoiNdMatchIndicator = false(1,length(planetKoiId));
tceNexsciKoiNdMatchIndicator(iNd) = true;
tceNexsciKoiEphemMatchIndicator = false(1,length(planetKoiId));
tceNexsciKoiEphemMatchIndicator(iEm) = true;

% Statistics of TCES that were known KOIs that were in the NExScI
% cumulative table
fprintf('Of the %d TCEs that were identified by DV as matching known KOIs, %d were found in the NExScI cumulative table, complsed of %d PC, %d FP\n',sum(koiIndicator),length(iFp)+length(iPc),length(iPc),length(iFp))


%==========================================================================
% 2. Look at ratio of halo value to core value for TCEs that are PC KOIs
n1 = sum(tceNexsciKoiPcMatchIndicator);
idx = tceNexsciKoiPcMatchIndicator & ~noGhostDiagnosticsIdx';
n2 = sum(idx);
rr = nanmedian( abs( hv(idx)./cv(idx) ) );
fprintf('%d TCEs were matched to PC KOIs in NExScI table, of which %d, or %7.1f percent had ghost diagnostics computed\n',n1,n2,n2/n1*100)
fprintf('Median absolute value of ratio of halo value to core value for these TCEs is %7.2f\n',rr)

% Histogram of Median absolute value of ratio of halo value to core value
figure
hold on
grid on
box on
hist(log10( abs( hv(idx)./cv(idx) ) ) , -5:0.5:3)
title(['abs ( (halo statistic)/(core statistic) ) for ',num2str(n2),' TCEs that are known PCs'])
xlabel('log10 ratio')
ylabel('Counts')
legend(['Median ratio = ',num2str(rr,'%7.1f')],'Location','NorthWest')
set(gca,'FontSize',12)
set(findall(gcf,'type','text'),'FontSize',12)
plotName = [localDir,'halo_to_core_ratio_for_known_PCs.png'];
print('-dpng','-r100',plotName)


%==========================================================================
% 3. Look at ratio of halo value to core value forTCEs that are FP KOIs that are ephemeris
% matched to contaminators
n1 = sum(tceNexsciKoiEphemMatchIndicator);
idx = tceNexsciKoiEphemMatchIndicator & ~noGhostDiagnosticsIdx';
n2 = sum(idx);
rr = nanmedian( abs(hv(idx)./cv(idx)) );
fprintf('%d TCEs were matched to FP KOIs flagged in NExScI table as contaminated, of which %d or %7.1f percent had ghost diagnostics computed\n',n1,n2,n2/n1*100)
fprintf('Median absolute value of ratio of halo value to core value for these TCEs is %7.2f\n',rr)

% Histogram of Median absolute value of ratio of halo value to core value
figure
hold on
grid on
box on
hist(log10(abs(hv(idx)./cv(idx))),-3:0.5:3)
title(['abs ( (halo statistic)/(core statistic) ) for ',num2str(n2),' known contaminated TCEs'])
xlabel('log10 ratio')
ylabel('Counts')
legend(['Median ratio = ',num2str(rr,'%7.1f')],'Location','NorthWest')
set(gca,'FontSize',12)
set(findall(gcf,'type','text'),'FontSize',12)
plotName = [localDir,'halo_to_core_ratio_for_contaminated_TCEs.png'];
print('-dpng','-r100',plotName)

%==========================================================================
% 4. Look at ratio of halo value to core value for FP that are *not* ephemeris
% matched to contaminators
n1 = sum(  tceNexsciKoiFpMatchIndicator & ~tceNexsciKoiEphemMatchIndicator );
idx = tceNexsciKoiFpMatchIndicator & ~tceNexsciKoiEphemMatchIndicator & ~noGhostDiagnosticsIdx';
n2 = sum(idx);
rr = nanmedian( abs(hv(idx)./cv(idx)) );
fprintf('%d TCEs were matched to FP KOIs not flagged in NExScI table as contaminated, of which %d had ghost diagnostics computed\n',n1,n2)
fprintf('Median absolute value of ratio of halo value to core value for these TCEs is %7.2f\n',rr)

% Histogram of Median absolute value of ratio of halo value to core value
figure
hold on
grid on
box on
hist(log10(abs(hv(idx)./cv(idx))),-3:0.5:3)
title(['abs ( (halo statistic)/(core statistic) ) for ',num2str(n2),' known FP, uncontaminated TCEs'])
xlabel('log10 ratio')
ylabel('Counts')
legend(['Median ratio = ',num2str(rr,'%7.1f')],'Location','Best')
set(gca,'FontSize',12)
set(findall(gcf,'type','text'),'FontSize',12)
plotName = [localDir,'halo_to_core_ratio_for_FP_uncontaminated_TCEs.png'];
print('-dpng','-r100',plotName)


%==========================================================================
skipThis = true;
if(~skipThis)
    % Cross-compare with Jeff Coughlin's list of period-epoch
    % collisions
    
    % Note from Jeff Coughlin: "... here is a file of all FP KoiId contaminated via
    % Direct PRF by a parent over 40" away - most of these should be due to
    % reflection off the field flatter lenses, though some may just have
    % a very, very bright parent. I put the KOI of the child (FP KOI),
    % the KIC of the child, the Name of the parent, the KIC of the parent,
    % and then the distance between them in arcseconds.
    % The further away ones may be the most promising candidates."
    
    % Import list of keplerIds of contaminated KoiId from Jeff Coughlin's list
    % Received 14 April 2014. Lists all KoiId with direct PRF contamination and
    % distance to contaminating star > 40"
    [list, delimiter, nheaderlines] = importdata([dataDir,'FFLReflCands.txt']);
    nList = size(list.textdata,1)-1;
    
    % list.textdata has columns #1, #2, and #3:
    %       planetKoiId,
    %       targetKoiId,
    %       and parent(contaminator) name
    % list.data has columns #4 and #5:
    %       parent(contaminator) targetKoi, and
    %       distance (arcsec)
    contaminatedTargetKoiId = zeros(nList,1);
    contaminatedPlanetKoiId = zeros(nList,1);
    contaminatorName = cell(nList,1);
    contaminatorKoiId = zeros(nList,1);
    contaminatorDistance = zeros(nList,1);
    for iRow = 1:nList
        % there are 245 keplerIds in the list, but only 240 are unique
        contaminatedPlanetKoiId(iRow,1)  = str2double(list.textdata{iRow+1,1});
        contaminatedTargetKoiId(iRow,1) = str2double(list.textdata{iRow+1,2});
        contaminatorName{iRow,1} = list.textdata{iRow+1,3};
        contaminatorKoiId(iRow,1) = list.data(iRow,1);
        contaminatorDistance(iRow,1) = list.data(iRow,2);
    end
    
    
    % Intersection of contaminatedPlanetKoiId and tces that are FP planetKoiId
    % 111 direct PRF-contaminated KOIs are identified among the TCEs that are
    % dispostioned as FPs
    [~, iaa, ibb] = intersect(planetKoiId(iFp),contaminatedPlanetKoiId);
    
    % No direct PRF-contaminated KOIs are identified among the TCEs that are
    % dispositioned as PCs
    [~, icc, idd] = intersect(planetKoiId(iPc),contaminatedPlanetKoiId);
    
    % No direct PRF-contaminated KOIs are identified among the TCEs that are
    % dispositioned as Nd
    [C, iee, iff] = intersect(planetKoiId(iNd),contaminatedPlanetKoiId);
    
    % test, should be zero
    sum(planetKoiId(iFp(iaa)) - contaminatedPlanetKoiId(ibb)~=0)
    
    % Of the 111 identified direct PRF-contaminated KOIs that are dispositioned
    % as FPs:
    
    % How many have CORE statistic >= HALO statistic? Answer: 7 of them.
    sum(cv(iFp(iaa)) >= hv(iFp(iaa)))
    % Of the 7, 4 have both statistics with > 0.9 significance
    sum(cv(iFp(iaa)) >= hv(iFp(iaa)) & cs(iFp(iaa))> 0.9& hs(iFp(iaa))> 0.9)
    
    % How many have CORE statistic < HALO statistic? Answer: 104 of them.
    sum(cv(iFp(iaa)) < hv(iFp(iaa)))
    sum(cv(iFp(iaa)) < hv(iFp(iaa)) & cs(iFp(iaa))> 0.6 & hs(iFp(iaa))> 0.6)
        
    %======================================================================
    % TCE-to-nexsci-matched FPs Histograms
    figure
    hold on
    subplot(2,2,1)
    hist(cv(tceNexsciKoiFpMatchIndicator))
    title('Core Stat Value: NExScI FPs')
    
    subplot(2,2,2)
    hist(cs(tceNexsciKoiFpMatchIndicator))
    title('Core Stat Significance: NExScI FPs')
    
    subplot(2,2,3)
    hist(hv(tceNexsciKoiFpMatchIndicator))
    title('Halo Stat Value: NExScI FPs')
    
    subplot(2,2,4)
    hist(hs(tceNexsciKoiFpMatchIndicator))
    title('Halo Stat Significance: NExScI FPs')
    
    set(gca,'FontSize',12)
    set(findall(gcf,'type','text'),'FontSize',12)
    
    plotName = [localDir,'nexsciFpGhostbusterStats.png'];
    print('-dpng','-r100',plotName)
    
    % TCE-to-nexsci-matched FPs Statistics
    hvKnownFp = hv(tceNexsciKoiFpMatchIndicator);
    cvKnownFp = cv(tceNexsciKoiFpMatchIndicator);
    hsKnownFp = hs(tceNexsciKoiFpMatchIndicator);
    csKnownFp = cs(tceNexsciKoiFpMatchIndicator);
    fprintf('Median halo statistic value for FPs %6.2f\n',median(hvKnownFp));
    fprintf('Median core statistic value for FPs %6.2f\n',median(cvKnownFp));
    % fprintf('Median core statistic significance for FPs %6.2f\n',median(csKnownFp));
    % fprintf('Median halo statistic significance for FPs %6.2f\n',median(hsKnownFp));
    fprintf('Median difference between core statistic and halo statistic values for FPs %6.2f\n',median(cvKnownFp - hvKnownFp));
    
    inds1FP = find(cvKnownFp < hvKnownFp);
    fprintf('%d FPs with core statistic < halo statistic\n',length(inds1FP))
    inds2FP = find(cvKnownFp >= hvKnownFp);
    fprintf('%d FPs with core statistic >= halo statistic\n',length(inds2FP))
    
    % CORE and halo significance for inds1FP
    cs1FP = csKnownFp(inds1FP);
    hs1FP = hsKnownFp(inds1FP);
    
    % CORE and halo significance for inds1PC
    cs2FP = csKnownFp(inds2FP);
    hs2FP = hsKnownFp(inds2FP);
    
    %==========================================================================
    % Look at core vs halo statistic for the KOIs that are identified as ephemeris
    % matches to period-epoch collisions
    fprintf('Of %d FPs that were ephemeris-matched to contaminators, %d have core statistic value > halo statistic value\n',sum(tceNexsciKoiEphemMatchIndicator),sum(cv(tceNexsciKoiEphemMatchIndicator)-hv(tceNexsciKoiEphemMatchIndicator) > 0))
    fprintf('Of %d FPs that were ephemeris-matched to contaminators, %d have core statistic value > halo statistic value\n',sum(tceNexsciKoiEphemMatchIndicator), sum( cv(tceNexsciKoiEphemMatchIndicator)./hv(tceNexsciKoiEphemMatchIndicator)  > 1 ) )
    fprintf('Median halo statistic value for FPs that are ephemeris-matched to contaminators %6.2f\n',median(hv(tceNexsciKoiEphemMatchIndicator)))
    fprintf('Median core statistic value for FPs that are ephemeris-matched to contaminators %6.2f\n',median(cv(tceNexsciKoiEphemMatchIndicator)))
    fprintf('Median core statistic value - halo statistic value for FPs that are ephemeris-matched to contaminators %6.2f\n',median(cv(tceNexsciKoiEphemMatchIndicator)-hv(tceNexsciKoiEphemMatchIndicator)))
    
    % We are most interested in ratios, not differences in the statistics, so
    % skip stuff that deals with differences
    
    %==========================================================================
    % TCE-to-nexsci-matched PCs Histograms
    figure
    hold on
    
    subplot(2,2,1)
    hist(cv(tceNexsciKoiPcMatchIndicator))
    title('Core Stat Value: NExScI PCs')
    
    subplot(2,2,2)
    hist(cs(tceNexsciKoiPcMatchIndicator))
    title('Core Stat Significance: NExScI PCs')
    
    subplot(2,2,3)
    hist(hv(tceNexsciKoiPcMatchIndicator))
    title('Halo Stat Value: NExScI PCs')
    
    subplot(2,2,4)
    hist(hs(tceNexsciKoiPcMatchIndicator))
    title('Halo Stat Significance: NExScI PCs')
    
    set(gca,'FontSize',12)
    set(findall(gcf,'type','text'),'FontSize',12)
    
    plotName = [localDir,'nexsciPcGhostbusterStats.png'];
    print('-dpng','-r100',plotName)
    
    %==========================================================================
    % TCE-to-nexsci-matched PCs Statistics
    
    
    hvKnownPc = hv(tceNexsciKoiPcMatchIndicator);
    cvKnownPc = cv(tceNexsciKoiPcMatchIndicator);
    hsKnownPc = hs(tceNexsciKoiPcMatchIndicator);
    csKnownPc = cs(tceNexsciKoiPcMatchIndicator);
    fprintf('Median halo statistic value for PCs %6.2f\n',median(hvKnownPc));
    fprintf('Median core statistic value for PCs %6.2f\n',median(cvKnownPc));
    % fprintf('Median core statistic significance for PCs %6.2f\n',median(csKnownPc));
    % fprintf('Median halo statistic significance for PCs %6.2f\n',median(hsKnownPc));
    fprintf('Median difference between core statistic and halo statistic values for PCs %6.2f\n',median(cvKnownPc - hvKnownPc));
    
    % CORE < HALO
    inds1PC = find(cvKnownPc < hvKnownPc);
    fprintf('There were %d PCs with core statistic < halo statistic\n',length(inds1PC))
    % CORE >= HALO
    inds2PC = find(cvKnownPc >= hvKnownPc);
    fprintf('There were %d PCs with core statistic >= halo statistic\n',length(inds2PC))
    
    % Look at the median ratio of core to halo statistics for the
    % PCs that had core value < halo value
    xx=cvKnownPc(cvKnownPc < hvKnownPc)./hvKnownPc(cvKnownPc < hvKnownPc) ;
    figure
    hist(xx)
    title('Distribution of ratio of core value to halo value for PCs with core < halo')
    median(xx)
    
    
    % Look at the median ratio of core to halo statistics for the
    % PCs that had core value > halo value
    yy=cvKnownPc(cvKnownPc > hvKnownPc)./hvKnownPc(cvKnownPc > hvKnownPc) ;
    figure
    hist(yy)
    title('Distribution of core value to halo value for PCs with core > halo')
    median(yy)
    
    % Look at the median ratio of core to halo statistics for the
    % PCs that had core value > halo value
    yy=cvKnownPc(cvKnownPc > hvKnownPc)./hvKnownPc(cvKnownPc > hvKnownPc) ;
    figure
    hist(yy)
    title('Distribution of core value to halo value for PCs with core > halo')
    median(yy)
    
    % CORE and halo significance for inds1PC
    cs1PC = csKnownPc(inds1PC);
    hs1PC = hsKnownPc(inds1PC);
    
    % CORE and halo significance for inds1PC
    cs2PC = csKnownPc(inds2PC);
    hs2PC = hsKnownPc(inds2PC);
    
end



