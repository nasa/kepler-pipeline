function tpsMetricsStruct = collect_results_for_metrics_file( tpsInputStruct, tpsResults )
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function tpsMetricsStruct = collect_results_for_metrics_file( inputStruct, outputStruct )
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Description:
% This function defines and gathers all the information needed for the 
% the metrics struct. It can pull any info from both the inputStruct and the
% tps results struct.
%
% Inputs:
%   tpsInputStruct: a struct that contains the inputs to the tps run
%            
%   tpsResults:  the struct resulting from a TPS run
%
% Outputs:
%   tpsMetricsStruct: collected results
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


% initialize metrics struct and specify the data we want to collect in it

tpsMetricsStruct = struct('nPulseLengths',[],'keplerId',[],'tceMaxMes',[],'tceMinMes',[],'durationIndex',[],'duration',[], ...
    'cdppSlope',[],'minMinMes',[],'skyGroup',[], ...
    'nPulsesFlaggedAsPlanet',[],'depthStat',[],'edgeStat',[],'mesGrowthStat',[],'mesGrowthN',[]);  

% if both inputs are empty then just return the initialized struct

if ( isempty(tpsInputStruct) && isempty(tpsResults) )
    return;
end

% only write the struct for targets with TCE's; otherwise exit now

isPlanetACandidate = [tpsResults.isPlanetACandidate];
if ~any(isPlanetACandidate)
    return;
end

% number of targets

nTargets = length(tpsInputStruct.tpsTargets);

% length of isPlanetACandidate vector

nTargetsTimesNpulses = length(isPlanetACandidate);

% number of pulse durations

nPulseLengths = nTargetsTimesNpulses/nTargets;

% keplerIds
keplerIds =  int32([tpsInputStruct.tpsTargets.keplerId]);

% entries in tpsResults are vectors of length N*M (where N = nTargets and M = nPulseDurations) and structure
% [pulseDuration1(1,nTargets)],[pulseDuration2(1,nTargets)],...,[pulseDurationM(1,nTargets)]
% reshape tpsResults to a N*M array of structs, with nTargets rows and nPulseLengths columns (one column for each pulse
% duration)

tpsResultsNew = reshape(tpsResults,nTargets,nPulseLengths);

% indicate which targets have at least one planet candidate

isPlanetACandidate = reshape(isPlanetACandidate,nTargets,nPulseLengths);
nPulsesFlaggedAsPlanet = sum(isPlanetACandidate,2);
nGoodTargets = sum(nPulsesFlaggedAsPlanet>0);
targetNumbers = 1:nTargets;

% loop over targets which have at least one valid isPlanetACandidate flag

% initialize

tpsMetricsStruct = repmat(tpsMetricsStruct,1,nGoodTargets);

targetCount = 0;

for targetNumber = targetNumbers(nPulsesFlaggedAsPlanet>0)
    
    % increment target count
    
    targetCount = targetCount + 1;
        
    % write to tpsMetricsStruct
    
    tpsMetricsStruct(targetCount).nPulsesFlaggedAsPlanet = nPulsesFlaggedAsPlanet(targetNumber);
    tpsMetricsStruct(targetCount).keplerId = keplerIds(targetNumber);
    
    % nPulseLengths is needed for the aggregator
    tpsMetricsStruct(targetCount).nPulseLengths = nPulseLengths; 
    
    % extract needed information
    
    maxMes     = [tpsResultsNew(targetNumber,:).maxMultipleEventStatistic];
    minMes     = [tpsResultsNew(targetNumber,:).minMultipleEventStatistic];
    cdpps      = [tpsResultsNew(targetNumber,:).rmsCdpp];
    pulses     = [tpsResultsNew(targetNumber,:).trialTransitPulseInHours];
    
    % get the the MES for the best TCE, which is the maximum MES over all
    % the pulse durations for which isPlanetACandidate is set to one
    
    isPlanetACand = isPlanetACandidate(targetNumber,:);
    mesIndicator = maxMes == max( maxMes(isPlanetACand == 1) ) ; %%%%%jcat
    durationIndex = find(mesIndicator, 1, 'first') ;
    tpsMetricsStruct(targetCount).durationIndex = durationIndex;
    tpsMetricsStruct(targetCount).duration = pulses(durationIndex);
    
    % get the minimum and maximum MES at the pulse corresponding to the TCE
    
    tpsMetricsStruct(targetCount).tceMinMes = minMes(durationIndex);
    tpsMetricsStruct(targetCount).tceMaxMes = maxMes(durationIndex);
    
    % fit rmsCDPP values to pulse durations and get slope
    
    p = polyfit(log10(pulses),log10(cdpps),1);
    cdppSlope = p(1);
    tpsMetricsStruct(targetCount).cdppSlope = cdppSlope;
    
    % get the most negative minMES over all the trial pulses
    
    tpsMetricsStruct(targetCount).minMinMes = min( minMes );
    
    % get skygroup and modout info
    
    tpsMetricsStruct(targetCount).skyGroup = tpsInputStruct.skyGroup;
    % tpsMetricsStruct(targetCount).ccdModuleFirstQuarter = tpsInputStruct.tpsTargets(targetNumber).diagnostics.ccdModule(1);
    % tpsMetricsStruct(targetCount).ccdOutputFirstQuarter = tpsInputStruct.tpsTargets(targetNumber).diagnostics.ccdOutput(1);
    
    % get information about quarters
    
    % tpsMetricsStruct(targetCount).quartersPresent = ~[tpsInputStruct.tpsTargets.quarterGapIndicators] ;

    
    %==========================================================================
    % compute depth test statistics
    
    normalizationTS = tpsResultsNew(targetNumber,durationIndex).normalizationTimeSeries;
    superResIndices = tpsResultsNew(targetNumber,durationIndex).indexOfSesAdded;
    actualSES = tpsResultsNew(targetNumber,durationIndex).sesCombinedToYieldMes;% This is the actual SES used at superresolution
    normalIndices = int32( ceil( superResIndices / 3.0 ) ); % Convert Super-Resolution to Normal Resolution
    normalIndices = normalIndices( actualSES ~= 0 );
    actualSES = actualSES( actualSES ~= 0 );
    normalizationAtSES = normalizationTS(normalIndices);
    cdppAtSES = 1.0e6./normalizationAtSES;
    
    % do depth consistency test, and add depthStat to tpsMetricsStruct if it is
    % valid
    
    [depStat depStatValid] = do_depth_test(actualSES,cdppAtSES);
    if (depStatValid == 1)
        depthStat = depStat;
        tpsMetricsStruct(targetCount).depthStat = depthStat;
    else
        tpsMetricsStruct(targetCount).depthStat = -1;
    end
    
    % start doing TCEs near gaps and edge test, and add edgeStat to tpsMetricsStruct if it is
    % valid
    
    pulsecadencen = round(tpsMetricsStruct(targetCount).duration*2.0);
    ts = tpsInputStruct.cadenceTimes.midTimestamps;
    gaps = tpsInputStruct.cadenceTimes.gapIndicators;
    rawflx = tpsInputStruct.tpsTargets(targetNumber).fluxValue;
    
    % demphTS = getdemphasis(tpsInputStruct);
    % goodDataIdx = (gaps == 0 & ts > 1.0 & rawflx > 1.0 & demphTS > 0.1);
    goodDataIdx = (gaps == 0 & ts > 1.0 & rawflx > 1.0); % Can ignore demphTS as per Chris Burke
    badDataIdx  =~ goodDataIdx;
    [edStat edStatValid] = do_edge_test(pulsecadencen,normalIndices,badDataIdx);
    if (edStatValid == 1)
        edgeStat = edStat;
        tpsMetricsStruct(targetCount).edgeStat = edgeStat;
    else
        tpsMetricsStruct(targetCount).edgeStat = -1;
    end
    
    % compute MES growth slope, mesGrowthN and mesGrowthStat and add to 
    % tpsMetricsStruct if mesValid == 1
    
    [mesStat mesN mesValid] = do_mes_growth(actualSES,normalizationAtSES);
    if (mesValid == 1)
        mesGrowthStat = mesStat;
        mesGrowthN = mesN;
        tpsMetricsStruct(targetCount).mesGrowthStat = mesGrowthStat;
        tpsMetricsStruct(targetCount).mesGrowthN = mesGrowthN;
    else
        tpsMetricsStruct(targetCount).mesGrowthStat = -1;
        tpsMetricsStruct(targetCount).mesGrowthN = -1;
    end
    
end % loop over targets

return % end of main function

function [depStat depStatValid] = do_depth_test(actualSES,cdppAtSES)

depStat = 0;
depStatValid = 0;

% do depth consistency test

% estimate the transit depth for each event

transitDepths = actualSES.*cdppAtSES;

% get the largest depth - use prctile protect short period things

maxTransitDepth = prctile(transitDepths,95.0);

% with lots of chances for big tail outliers
% filter out transit depths greater than deepest

tmp = (transitDepths < maxTransitDepth); 
transitDepths = transitDepths(tmp);
transitCdpp = cdppAtSES(tmp);
if (length(transitCdpp) > 2)
    weightCdpp = 1.0./(transitCdpp.^2);
    
    % do weighted means and weighted variance
    
    meanDepth = weighted_mean(transitDepths,weightCdpp);
    meanDepthErr = sqrt(var(transitDepths,weightCdpp));
    depStat = abs(meanDepth-maxTransitDepth)/meanDepthErr;
    depStatValid = 1;
end

return

function [edStat edStatValid] = do_edge_test(pulsecadencen,normalIndices,badDataIdx)

nbad = 0;

% make a window 3 pulse durations below and above transit cadence
oidx = int32(-(pulsecadencen*3):1:(pulsecadencen*3));

for k = 1:length(normalIndices)
    idx = oidx+normalIndices(k);
    tmp = idx > 0 & idx <= length(badDataIdx);
    
    % make sure cadence window is within bounds
    
    idx = idx(tmp);
    if (sum(badDataIdx(idx)) > 0)
        nbad = nbad+1; 
    end
end
edStat = nbad/length(normalIndices);
edStatValid = 1;

return

function [mesStat mesN mesValid] = do_mes_growth(actualSES,normalizationAtSES)

mesStat = 0;
mesN = 0;
mesValid = 0;
corrSES = actualSES.*normalizationAtSES;
nevent = length(actualSES); 
mesn = zeros(size(1:nevent));

for kk = 1:nevent
    mesn(kk) = sum(corrSES(1:kk))/sqrt(sum(normalizationAtSES(1:kk).^2));
end

% impose a lower floor to MES in order to avoid negative mes and noise at low levels
idx = find(mesn>0.3); 
if (length(idx) > 1)
    medSES = median(abs(actualSES));
    mesrat = mesn(idx)./medSES;
    p = polyfit(log10(1:length(mesrat)),log10(mesrat),1);
    mesStat = p(1);
    mesN = length(mesrat);
    mesValid = 1;
    if (imag(mesStat) ~= 0) 
        % disp('Imaginary'); 
        % disp([actualSES normalizationAtSES]); 
        % pause; 
        mesValid = 0;
        mesStat = 0;
        mesN = 0;
    end
end

return

