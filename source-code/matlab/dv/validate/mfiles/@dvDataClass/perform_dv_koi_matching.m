function [dvResultsStruct] = ...
perform_dv_koi_matching(dvDataObject, dvResultsStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [dvResultsStruct] = ...
% perform_dv_koi_matching(dvDataObject, dvResultsStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Match the DV fit results against the known KOI's at the planet level.
% Identify which KOI's are associated with which planet candidates and
% report correlation value for matches. If multiple DV results appear to
% match a single KOI then reject the matches. If multiple KOI's appear to
% match a single DV result then reject the matches.
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

% Get the relevant input fields.
dvConfigurationStruct = dvDataObject.dvConfigurationStruct;
koiMatchingThreshold = dvConfigurationStruct.koiMatchingThreshold;

% Loop over the targets and perform the KOI matching.
nTargets = length(dvDataObject.targetStruct);

for iTarget = 1 : nTargets
    
    % There is no matching to do if there are no KOIs associated with the
    % given target.
    transits = dvDataObject.targetStruct(iTarget).transits;
    
    if isempty(transits);
        continue
    end % if
    
    % Set up the KOI ephemeris vectors. Convert transit duration units from
    % hours to days for ephemeris matcher. Squeeze out any KOIs that are
    % not fully defined. These cannot be matched.
    koiPeriods = [transits.period]';
    koiEpochs = [transits.epoch]';
    koiDurations = [transits.duration]' * get_unit_conversion('hour2day');
    
    invalid = isnan(koiPeriods) | isnan(koiEpochs) | isnan(koiDurations);
    
    if all(invalid)
        continue
    end % if
    
    koiPeriods(invalid) = [];
    koiEpochs(invalid) = [];
    koiDurations(invalid) = [];
    transits(invalid) = [];

    % Compute the correlations between each DV fit result and all of the
    % KOIs associated with the given target. Loop over the DV fit results.
    % If the fit was not performed or was not successful, the TPS period,
    % epoch and duration are still available for matching.
    nPlanets = length(dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct);
    startKjd = dvDataObject.barycentricCadenceTimes(iTarget).startTimestamps(1);
    endKjd = dvDataObject.barycentricCadenceTimes(iTarget).endTimestamps(end);
    
    dvPeriods = zeros([nPlanets, 1]);
    dvEpochs = zeros([nPlanets, 1]);
    dvDurations = zeros([nPlanets, 1]);
    
    for iPlanet = 1 : nPlanets
        
        % Get the DV fit results for the given planet candidate. Note that
        % units for transit duration in ephemeris matcher are days, whereas
        % units for duration in DV are hours.
        planetResultsStruct = ...
            dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet);
        modelParameters = planetResultsStruct.allTransitsFit.modelParameters;
        
        [periodStruct] = retrieve_model_parameter(modelParameters, ...
            'orbitalPeriodDays');
        dvPeriods(iPlanet) = periodStruct.value;
        
        [epochStruct] = retrieve_model_parameter(modelParameters, ...
            'transitEpochBkjd');
        dvEpochs(iPlanet) = epochStruct.value;
    
        [durationStruct] = retrieve_model_parameter(modelParameters, ...
            'transitDurationHours');
        dvDurations(iPlanet) = ...
            durationStruct.value * get_unit_conversion('hour2day');
        
    end % for iPlanet
    
    % Correlate the fit results for all DV planet candidates against all of
    % the valid KOIs associated with the given target.
    [correlations] = correlate_ephemerides( ...
        koiPeriods, koiEpochs, koiDurations, ...
        dvPeriods, dvEpochs, dvDurations, ...
        startKjd, endKjd);
        
    % Identify the correlations above threshold and remove cases of
    % multiples for a given KOI or planet candidate.
    isMatch = correlations >= koiMatchingThreshold;
    sum1 = sum(isMatch, 1);
    sum2 = sum(isMatch, 2);
    
    isMatch( : , sum1 > 1) = false;
    isMatch(sum2 > 1, : ) = false;
    
    % Update the DV results structure.
    targetResultsStruct = dvResultsStruct.targetResultsStruct(iTarget);
    
    for iPlanet = 1 : nPlanets
        ixKoi = find(isMatch( : , iPlanet));
        if ~isempty(ixKoi)
            koiId = transits(ixKoi).koiId;
            targetResultsStruct.planetResultsStruct(iPlanet).koiId = ...
                koiId;
            targetResultsStruct.planetResultsStruct(iPlanet).keplerName = ...
                rmblank(transits(ixKoi).keplerName);
            targetResultsStruct.planetResultsStruct(iPlanet).koiCorrelation = ...
                correlations(ixKoi, iPlanet);
            targetResultsStruct.unmatchedKoiIds = ...
                rmstring(targetResultsStruct.unmatchedKoiIds, koiId);
        end % if
    end % for iPlanet
    
    if any(any(isMatch))
        targetResultsStruct.matchedKoiIds = {transits(any(isMatch, 2)).koiId};
    end % if
    
    if isempty(targetResultsStruct.unmatchedKoiIds)
        targetResultsStruct.unmatchedKoiIds = [];
    end % if
    
    dvResultsStruct.targetResultsStruct(iTarget) = targetResultsStruct;
    
    % Save variables relevant to KOI matching for given target.
    rootDir = targetResultsStruct.dvFiguresRootDirectory;
    save(fullfile(rootDir, 'koi-match.mat'), ...
        'koiPeriods', 'koiEpochs', 'koiDurations', ...
        'dvPeriods', 'dvEpochs', 'dvDurations', ...
        'startKjd', 'endKjd', 'transits', ...
        'correlations', 'isMatch', 'koiMatchingThreshold');
    
end % for iTarget

% Return.
return


function [string] = rmblank(string)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [string] = rmblank(string)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Remove all blanks from string.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% Remove blanks.
string(string == ' ') = [];

% Return.
return


function [array] = rmstring(array, string)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [array] = rmstring(array, string)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Remove string from cell array of strings.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% Remove string.
array(strcmp(array, string)) = [];

% Return.
return