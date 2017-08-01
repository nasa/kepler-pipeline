function [paResultsStruct] = ...
compute_pa_encircled_energy_metrics(paDataObject, paResultsStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [paResultsStruct] = ...
% compute_pa_encircled_energy_metrics(paDataObject, paResultsStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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

% Set empty value.
emptyValue = 0;

paStateFileName = paDataObject.paFileStruct.paStateFileName;
paRootTaskDir   = paDataObject.paFileStruct.paRootTaskDir;

ccdModule = paDataObject.ccdModule;
ccdOutput = paDataObject.ccdOutput;

cadenceTimes = paDataObject.cadenceTimes;
timestamps = cadenceTimes.midTimestamps;
cadenceGapIndicators = cadenceTimes.gapIndicators;

nCadences = length(timestamps);
validTimestamps = timestamps(~cadenceGapIndicators);

processingK2Data = paDataObject.cadenceTimes.startTimestamps(1) > ...
    paDataObject.fcConstants.KEPLER_END_OF_MISSION_MJD;

% Load the PPA target star data and results structures from the PA state
% file. Remove the variable targets, out of family targets and custom
% targets before computing the encircled energy metrics.
load(fullfile(paRootTaskDir, paStateFileName), 'ppaTargetStarDataStruct', ...
    'ppaTargetStarResultsStruct', 'variableTargetKeplerIds', ...
    'outOfFamilyTargetKeplerIds');

keplerIds = [ppaTargetStarDataStruct.keplerId]';                                                    %#ok<NODEF>
customTargetIds = keplerIds(is_valid_id(keplerIds, 'custom'));
keplerIdsToExclude = union(union(variableTargetKeplerIds, ...
    outOfFamilyTargetKeplerIds), customTargetIds);
isTargetToExclude = ismember(keplerIds, keplerIdsToExclude);
ppaTargetStarDataStruct = ppaTargetStarDataStruct(~isTargetToExclude);
ppaTargetStarResultsStruct = ppaTargetStarResultsStruct(~isTargetToExclude);                        %#ok<NODEF>

% build up PPA input structs
dataStruct = struct('targetStarDataStruct',ppaTargetStarDataStruct,...
                    'paConfigurationStruct',paDataObject.paConfigurationStruct, ...
                    'encircledEnergyConfigurationStruct',paDataObject.encircledEnergyConfigurationStruct,...
                    'motionPolyStruct',paDataObject.motionPolyStruct);
resultsStruct = struct('targetStarResultsStruct',ppaTargetStarResultsStruct);

if(~isempty(dataStruct.targetStarDataStruct) && ~isempty(resultsStruct.targetStarResultsStruct)) && ~processingK2Data
    
    % repackage input data structs
    eeTempStruct = generate_eeTempStruct_from_paDataStruct(dataStruct, resultsStruct);

    % compute ee metric
    eeTempStruct = encircledEnergy(eeTempStruct);

    % add results to paResultsStruct
    paResultsStruct.encircledEnergyMetrics.values = eeTempStruct.encircledEnergyStruct.eeRadius;
    paResultsStruct.encircledEnergyMetrics.uncertainties = eeTempStruct.encircledEnergyStruct.CeeRadius;
    paResultsStruct.encircledEnergyMetrics.gapIndicators = ismember(1:nCadences,eeTempStruct.encircledEnergyStruct.eeDataGap)';
    
else
    % set all gaps in results struct
    paResultsStruct.encircledEnergyMetrics.values = emptyValue * ones([nCadences, 1]);
    paResultsStruct.encircledEnergyMetrics.uncertainties = emptyValue * ones([nCadences, 1]);
    paResultsStruct.encircledEnergyMetrics.gapIndicators = true([nCadences, 1]);
end

% Plot the encircled energy metric regardless of debug level.
close all;
isLandscapeOrientation = true;
includeTimeFlag = false;
printJpgFlag = false;

gapIndicators = paResultsStruct.encircledEnergyMetrics.gapIndicators;
startTime = fix(validTimestamps(1));
plot(timestamps(~gapIndicators) - startTime, ...
    paResultsStruct.encircledEnergyMetrics.values(~gapIndicators), '.-b');
title(['[PA] Encircled Energy Metric -- Module ', num2str(ccdModule), ...
    ' /  Output ', num2str(ccdOutput)]);
xlabel(['Elapsed Days from ', mjd_to_utc(startTime, 0)]);
ylabel('Encircled Energy Metric (pixels)');
plot_to_file('pa_encircled_energy', isLandscapeOrientation, includeTimeFlag, ...
    printJpgFlag);

return
