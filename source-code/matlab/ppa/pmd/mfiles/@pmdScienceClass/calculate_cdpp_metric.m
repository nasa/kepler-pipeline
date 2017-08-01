function cdppReport = calculate_cdpp_metric(pmdScienceObject)
%
% cdppReport = calculate_cdpp_metric(pmdScienceObject)
% 
% Calculate the measured and expected CDPP values and their ratio.
%
% INPUTS:
%   pmdScienceObject
%
% OUTPUTS:
%    A multilevel struct with the following structure, binned by Kepler magnitude:
%
%    cdppReport
%       .measured 
%           .mag9
%               .threeHour
%                   .values:        [float array]    (nCadences x 1)
%                   .uncertainties: [float array]    (nCadences x 1)
%                   .gapIndicators: [logical array]  (nCadences x 1)
%               .sixHour
%                   (same as threeHour)
%               .twelveHour
%                   (same as threeHour)
%           .mag10
%               (same as mag9)
%           .mag11
%               (same as mag9)
%           .mag12
%               (same as mag9)
%           .mag13
%               (same as mag9)
%           .mag14
%               (same as mag9)
%           .mag15
%               (same as mag9)
%       .expected 
%           (same as .measured)
%       .ratio    
%           (same as .measured)
%       .mmrMetrics
%           .countOfStarsInMagnitude  -- The count of dwarf stars in the following magnitude bins:
%               .mag9    
%               .mag10   
%               .mag11   
%               .mag12   
%               .mag13   
%               .mag14   
%               .mag15   
%           .medianCdpp -- The median CDPP for dwarf stars in the same magnitude bins as countOfStarsInMagnitude
%           .tenthPercentileCdpp -- The tenth-percentile CDPP for dwarf stars in the same magnitude bins as countOfStarsInMagnitude
%           .noiseModel -- The noise model CDPP for dwarf stars in the same magnitude bins as countOfStarsInMagnitude
%           .percentBelowNoise-- The percent of dwarf stars in the same magnitude bins as countOfStarsInMagnitude with median CDPP less than the noise model
%   
%
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
    cdppReport.measured = calculate_cdpp_measured(pmdScienceObject);
    cdppReport.expected = calculate_cdpp_expected(pmdScienceObject);
    cdppReport.ratio    = calculate_cdpp_ratio(cdppReport);
    cdppReport.mmrMetrics = calculate_cdpp_metric_additional(pmdScienceObject);
return

function outputCdppMeasured = calculate_cdpp_measured(pmdScienceObject)
    nTargets = length(pmdScienceObject.cdppTsData);
    nCadences = length(pmdScienceObject.cadenceTimes.midTimestamps);

    outputCdppMeasured = get_cdpp_struct(nCadences);
    cdppBinningStruct = get_binning_struct();                        
    
    % Check whether it is Kepler data or K2 data
    if isfield(pmdScienceObject.fcConstants, 'KEPLER_END_OF_MISSION_MJD')
        KEPLER_END_OF_MISSION_MJD = pmdScienceObject.fcConstants.KEPLER_END_OF_MISSION_MJD;
    else
        KEPLER_END_OF_MISSION_MJD = 56444;
    end
    isK2Uow = pmdScienceObject.cadenceTimes.startTimestamps(1) > KEPLER_END_OF_MISSION_MJD;
    
    % Bin up lists of mag/time-window binned cdpps that are NOT gapped:
    %
    for itarg = 1:nTargets
        targCdpp = pmdScienceObject.cdppTsData(itarg);
        
        % Convert the filledIndices to a filled indicator vector, and set
        % the gapping vector targFilledIndicator to that.
        % Note conversion from zero-based to one-based indices:
        %
        targFilledIndicator = false(size(targCdpp.fluxTimeSeries.gapIndicators));
        targFilledIndicator(targCdpp.fluxTimeSeries.filledIndices+1) = true;
        
        % Skip the target if it has gapIndicators.  If any element of
        % gapIndicators is true, the skip the target.  Otherwise, use the
        % filled indicator as gap information.
        %
        if sum(targCdpp.fluxTimeSeries.gapIndicators) ~= 0
            continue;
        end
        
        % Skip giant stars (stars with log(g) <= 4.0) when Kepler data is processed:
        %
        if ~isempty(targCdpp.log10SurfaceGravity) && ~isnan(targCdpp.log10SurfaceGravity)
            if targCdpp.log10SurfaceGravity <= 4.0 && ~isK2Uow
                continue;
            end
        end
         
        % Skip this target if it has a NaN keplerMag:
        %
        if isnan(targCdpp.keplerMag)
            continue;
        end
                
        % Get the target's magnitude in a 'mag%d' string to use as
        % an index into cdppBinningStruct:
        %
        roundMag = round(targCdpp.keplerMag);
        if roundMag < 9 || roundMag > 15
            continue;
        end
        magString = sprintf('mag%d', roundMag);
        
        cdppBinningStruct.(magString).threeHour.values( end+1,:) = targCdpp.cdpp3Hr;
        cdppBinningStruct.(magString).sixHour.values(   end+1,:) = targCdpp.cdpp6Hr;
        cdppBinningStruct.(magString).twelveHour.values(end+1,:) = targCdpp.cdpp12Hr;

        % Used for excluding long-gapped targets below:
        cdppBinningStruct.(magString).threeHour.uncertainties( end+1,:) = targCdpp.fluxTimeSeries.uncertainties;
        cdppBinningStruct.(magString).sixHour.uncertainties(   end+1,:) = targCdpp.fluxTimeSeries.uncertainties;
        cdppBinningStruct.(magString).twelveHour.uncertainties(end+1,:) = targCdpp.fluxTimeSeries.uncertainties;
        
        cdppBinningStruct.(magString).threeHour.gapIndicators( end+1,:) = targFilledIndicator;
        cdppBinningStruct.(magString).sixHour.gapIndicators(   end+1,:) = targFilledIndicator;
        cdppBinningStruct.(magString).twelveHour.gapIndicators(end+1,:) = targFilledIndicator;
    end


    % Generate the metrics:
    %
    mags = get_mag_cell_array();
    hours = get_hour_cell_array();

    for imag = 1:length(mags)
        for ihour = 1:length(hours)
            
            mag = mags{imag};
            hour = hours{ihour};

            if ~isempty(cdppBinningStruct.(mag).(hour).values)
                binValues = cdppBinningStruct.(mag).(hour).values;
                binGaps   = cdppBinningStruct.(mag).(hour).gapIndicators;
                binUncert = cdppBinningStruct.(mag).(hour).uncertainties;
                
                loopCdppValues  = -1 + zeros(size(binValues, 2), 1);
                loopCdppUncerts = -1 + zeros(size(binValues, 2), 1);
                loopCdppGaps    =       true(size(binValues, 2), 1);
                
                for icad = 1:size(binUncert,2)
                    cadValues = binValues(:, icad);
                    cadGaps   = binGaps(:, icad);
                    cadUncert = binUncert(:, icad);
                    
                    tmpValue = sqrt(trimmean((cadValues(cadUncert>0)).^2, 10, 1));
                    if isfinite(tmpValue)
                        loopCdppValues(icad) = tmpValue;
                        loopCdppUncerts(icad) = std(cadValues(cadUncert>0));
                        loopCdppGaps(icad) = all(cadGaps);
                    else
                        loopCdppValues(icad) = -1;
                        loopCdppUncerts(icad) = -1;
                        loopCdppGaps(icad) = true;
                    end
                end
                
                outputCdppMeasured.(mag).(hour).values        = loopCdppValues;
                outputCdppMeasured.(mag).(hour).uncertainties = loopCdppUncerts;
                outputCdppMeasured.(mag).(hour).gapIndicators = loopCdppGaps | pmdScienceObject.cadenceTimes.gapIndicators;
                
                % For gaps, set value and uncertainty to -1
                %
                cdppGaps = find(outputCdppMeasured.(mag).(hour).gapIndicators);
                outputCdppMeasured.(mag).(hour).values(cdppGaps) = -1;
                outputCdppMeasured.(mag).(hour).uncertainties(cdppGaps) = -1;
                
                % Replace NaNs in outputCdppMeasured values/uncertainties with -1s/-1s
                outputCdppMeasured.(mag).(hour).values( isnan(outputCdppMeasured.(mag).(hour).values) )                   = -1;
                outputCdppMeasured.(mag).(hour).uncertainties( isnan(outputCdppMeasured.(mag).(hour).uncertainties) )     = -1;
                
            end
        end
    end
return

function outputCdppExpected = calculate_cdpp_expected(pmdScienceObject)
    nTargets = length(pmdScienceObject.cdppTsData);
    nCadences = length(pmdScienceObject.cadenceTimes.midTimestamps);
    
    % Check whether it is Kepler data or K2 data
    if isfield(pmdScienceObject.fcConstants, 'KEPLER_END_OF_MISSION_MJD')
        KEPLER_END_OF_MISSION_MJD = pmdScienceObject.fcConstants.KEPLER_END_OF_MISSION_MJD;
    else
        KEPLER_END_OF_MISSION_MJD = 56444;
    end
    isK2Uow = pmdScienceObject.cadenceTimes.startTimestamps(1) > KEPLER_END_OF_MISSION_MJD;

    % Allocate collation arrays:
    %
    collationValues = get_expected_struct();
    collationUncert = get_expected_struct();
    collationGaps   = get_expected_struct();
    
    for itarg = 1:nTargets
        targCdpp = pmdScienceObject.cdppTsData(itarg);

        % Skip giant stars (stars with log(g) <= 4.0) when Kepler data is processed:
        %
        if ~isempty(targCdpp.log10SurfaceGravity) && ~isnan(targCdpp.log10SurfaceGravity)
            if targCdpp.log10SurfaceGravity <= 4.0 && ~isK2Uow
                continue;
            end
        end
         
        % Skip this target if it has a NaN keplerMag:
        %
        if isnan(targCdpp.keplerMag)
            continue;
        end
        
        magnitude = round(targCdpp.keplerMag);

        targValues = targCdpp.fluxTimeSeries.values(:);
        targUncert = targCdpp.fluxTimeSeries.uncertainties(:);

        % Skip the target if it has gapIndicators or is out of the mag range.
        %
        isGapIndicators = (sum(targCdpp.fluxTimeSeries.gapIndicators) ~= 0);
        isOutOfMagRange = (magnitude > 15 || magnitude < 9);
        if isGapIndicators || isOutOfMagRange
            continue;
        end

        % Use the filled indicator as gap information.
        % Convert the filledIndices to a filled indicator vector. Note
        % zero-based to one-based conversion:
        % 
        targFilledIndicator = false(size(targCdpp.fluxTimeSeries.gapIndicators));
        targFilledIndicator(targCdpp.fluxTimeSeries.filledIndices+1) = true;
        
        mag = sprintf('mag%d', magnitude);
        collationValues.(mag)(end+1,:) = targValues;
        collationUncert.(mag)(end+1,:) = targUncert;
        collationGaps.(mag)(  end+1,:) = targFilledIndicator;
    end

    % Generate RMS:
    %
    mags = get_mag_cell_array(); 
    collationRMSs = get_expected_struct();
    for imag = 1:length(mags)
        mag = mags{imag};
        [collationRMSs.(mag) gapsForMag] = gapped_rms(collationUncert.(mag),  collationGaps.(mag));
        newGaps.(mag) = gapsForMag;
    end

    windows = get_time_binning_windows(pmdScienceObject);

    % Calculate the expected values.  If the magRMSs entry is empty, skip
    % it, and use the default data set up in the initialization of outputCdppExpected.
    %
    outputCdppExpected = get_cdpp_struct(nCadences);
    for imag = 1:length(mags)
        hours = get_hour_cell_array();
        for ihour = 1:length(hours)
            
            mag = mags{imag};

            RMSs    = collationRMSs.(mag);
            values  = collationValues.(mag);
            uncerts = collationUncert.(mag);
            gaps    = collationGaps.(mag);

            if ~isempty(RMSs)
                hour = hours{ihour};
                window = windows{ihour};

                uncertaintyFraction = RMSs ./ smoothed_mean_null(values);
                loopCdppValues = 1e6 * sqrt(conv_null(window, uncertaintyFraction.^2)/window);
                loopCdppUncert = 1e6 * mean_null(uncerts ./ values);
                loopGaps = get_gaps_measured(gaps, nCadences);
                
                % Add in new gaps for long-gapped data (if there are none, this is a no-op):
                %
                for igap = 1:length(newGaps.(mag))
                    windowGapRange = (newGaps.(mag)(igap) - floor(window/2)):(newGaps.(mag)(igap) + floor(window/2));
                    windowGapRange = windowGapRange(windowGapRange > 0 & windowGapRange <= length(loopGaps));
                    loopGaps(windowGapRange) = true;
                end

                outputCdppExpected.(mag).(hour).values        = loopCdppValues;
                outputCdppExpected.(mag).(hour).uncertainties = loopCdppUncert;
                outputCdppExpected.(mag).(hour).gapIndicators = loopGaps | pmdScienceObject.cadenceTimes.gapIndicators;
                                
                % For gaps, set value and uncertainty to -1
                %
                cdppGaps = find(outputCdppExpected.(mag).(hour).gapIndicators);
                outputCdppExpected.(mag).(hour).values(cdppGaps) = -1;
                outputCdppExpected.(mag).(hour).uncertainties(cdppGaps) = -1;
                
                % Replace NaNs in outputCdppExpected values/uncertainties with -1s/-1s
                outputCdppExpected.(mag).(hour).values( isnan(outputCdppExpected.(mag).(hour).values) )                   = -1;
                outputCdppExpected.(mag).(hour).uncertainties( isnan(outputCdppExpected.(mag).(hour).uncertainties) )     = -1;
                
            end
        end
    end

return

function cdppRatio = calculate_cdpp_ratio(cdppReport)
    nCadences = length(cdppReport.expected.mag9.threeHour.values);
    cdppRatio = get_cdpp_struct(nCadences);

    mags = get_mag_cell_array();
    hours = get_hour_cell_array();

    for imag = 1:length(mags)
        for ihour = 1:length(hours)

            mag = mags{imag};
            hour = hours{ihour};

            cdppRatio.(mag).(hour).values        =      cdppReport.measured.(mag).(hour).values         ./ ...
                                                        cdppReport.expected.(mag).(hour).values;
            cdppRatio.(mag).(hour).uncertainties = sqrt((cdppReport.measured.(mag).(hour).uncertainties ./ cdppReport.measured.(mag).(hour).values).^2      + ...
                                                        (cdppReport.measured.(mag).(hour).uncertainties ./ cdppReport.expected.(mag).(hour).values).^2);
            cdppRatio.(mag).(hour).gapIndicators =      cdppReport.measured.(mag).(hour).gapIndicators  | ...
                                                        cdppReport.expected.(mag).(hour).gapIndicators;
            
            % Replace NaNs in cdppRatio values/uncertainties with 0s/-1s
            cdppRatio.(mag).(hour).values( isnan(cdppRatio.(mag).(hour).values) )                   = 0;
            cdppRatio.(mag).(hour).uncertainties( isnan(cdppRatio.(mag).(hour).uncertainties) )     = -1;
            
        end
    end

return

function cdppStruct = get_cdpp_struct(nCadences)
% cdppStruct = get_cdpp_struct(nCadences)
% 
% Return a struct for output that has been pre-filled with dummy data (-1s and falses).
%
    cdppStruct = struct( ...
        'mag9',  struct('threeHour',  struct('values', zeros(nCadences, 1) - 1, 'uncertainties', zeros(nCadences, 1) - 1, 'gapIndicators', true(nCadences, 1)), ...
                        'sixHour',    struct('values', zeros(nCadences, 1) - 1, 'uncertainties', zeros(nCadences, 1) - 1, 'gapIndicators', true(nCadences, 1)), ...
                        'twelveHour', struct('values', zeros(nCadences, 1) - 1, 'uncertainties', zeros(nCadences, 1) - 1, 'gapIndicators', true(nCadences, 1))), ...
        'mag10', struct('threeHour',  struct('values', zeros(nCadences, 1) - 1, 'uncertainties', zeros(nCadences, 1) - 1, 'gapIndicators', true(nCadences, 1)), ...
                        'sixHour',    struct('values', zeros(nCadences, 1) - 1, 'uncertainties', zeros(nCadences, 1) - 1, 'gapIndicators', true(nCadences, 1)), ...
                        'twelveHour', struct('values', zeros(nCadences, 1) - 1, 'uncertainties', zeros(nCadences, 1) - 1, 'gapIndicators', true(nCadences, 1))), ...
        'mag11', struct('threeHour',  struct('values', zeros(nCadences, 1) - 1, 'uncertainties', zeros(nCadences, 1) - 1, 'gapIndicators', true(nCadences, 1)), ...
                        'sixHour',    struct('values', zeros(nCadences, 1) - 1, 'uncertainties', zeros(nCadences, 1) - 1, 'gapIndicators', true(nCadences, 1)), ...
                        'twelveHour', struct('values', zeros(nCadences, 1) - 1, 'uncertainties', zeros(nCadences, 1) - 1, 'gapIndicators', true(nCadences, 1))), ...
        'mag12', struct('threeHour',  struct('values', zeros(nCadences, 1) - 1, 'uncertainties', zeros(nCadences, 1) - 1, 'gapIndicators', true(nCadences, 1)), ...
                        'sixHour',    struct('values', zeros(nCadences, 1) - 1, 'uncertainties', zeros(nCadences, 1) - 1, 'gapIndicators', true(nCadences, 1)), ...
                        'twelveHour', struct('values', zeros(nCadences, 1) - 1, 'uncertainties', zeros(nCadences, 1) - 1, 'gapIndicators', true(nCadences, 1))), ...
        'mag13', struct('threeHour',  struct('values', zeros(nCadences, 1) - 1, 'uncertainties', zeros(nCadences, 1) - 1, 'gapIndicators', true(nCadences, 1)), ...
                        'sixHour',    struct('values', zeros(nCadences, 1) - 1, 'uncertainties', zeros(nCadences, 1) - 1, 'gapIndicators', true(nCadences, 1)), ...
                        'twelveHour', struct('values', zeros(nCadences, 1) - 1, 'uncertainties', zeros(nCadences, 1) - 1, 'gapIndicators', true(nCadences, 1))), ...
        'mag14', struct('threeHour',  struct('values', zeros(nCadences, 1) - 1, 'uncertainties', zeros(nCadences, 1) - 1, 'gapIndicators', true(nCadences, 1)), ...
                        'sixHour',    struct('values', zeros(nCadences, 1) - 1, 'uncertainties', zeros(nCadences, 1) - 1, 'gapIndicators', true(nCadences, 1)), ...
                        'twelveHour', struct('values', zeros(nCadences, 1) - 1, 'uncertainties', zeros(nCadences, 1) - 1, 'gapIndicators', true(nCadences, 1))), ...
        'mag15', struct('threeHour',  struct('values', zeros(nCadences, 1) - 1, 'uncertainties', zeros(nCadences, 1) - 1, 'gapIndicators', true(nCadences, 1)), ...
                        'sixHour',    struct('values', zeros(nCadences, 1) - 1, 'uncertainties', zeros(nCadences, 1) - 1, 'gapIndicators', true(nCadences, 1)), ...
                        'twelveHour', struct('values', zeros(nCadences, 1) - 1, 'uncertainties', zeros(nCadences, 1) - 1, 'gapIndicators', true(nCadences, 1))));
return

function binningStruct = get_binning_struct()
    binningStruct = struct( ...
        'mag9',  struct('threeHour',  struct('values', [], 'uncertainties', [], 'gapIndicators', []), ...
                        'sixHour',    struct('values', [], 'uncertainties', [], 'gapIndicators', []), ...
                        'twelveHour', struct('values', [], 'uncertainties', [], 'gapIndicators', [])), ...
        'mag10', struct('threeHour',  struct('values', [], 'uncertainties', [], 'gapIndicators', []), ...
                        'sixHour',    struct('values', [], 'uncertainties', [], 'gapIndicators', []), ...
                        'twelveHour', struct('values', [], 'uncertainties', [], 'gapIndicators', [])), ...
        'mag11', struct('threeHour',  struct('values', [], 'uncertainties', [], 'gapIndicators', []), ...
                        'sixHour',    struct('values', [], 'uncertainties', [], 'gapIndicators', []), ...
                        'twelveHour', struct('values', [], 'uncertainties', [], 'gapIndicators', [])), ...
        'mag12', struct('threeHour',  struct('values', [], 'uncertainties', [], 'gapIndicators', []), ...
                        'sixHour',    struct('values', [], 'uncertainties', [], 'gapIndicators', []), ...
                        'twelveHour', struct('values', [], 'uncertainties', [], 'gapIndicators', [])), ...
        'mag13', struct('threeHour',  struct('values', [], 'uncertainties', [], 'gapIndicators', []), ...
                        'sixHour',    struct('values', [], 'uncertainties', [], 'gapIndicators', []), ...
                        'twelveHour', struct('values', [], 'uncertainties', [], 'gapIndicators', [])), ...
        'mag14', struct('threeHour',  struct('values', [], 'uncertainties', [], 'gapIndicators', []), ...
                        'sixHour',    struct('values', [], 'uncertainties', [], 'gapIndicators', []), ...
                        'twelveHour', struct('values', [], 'uncertainties', [], 'gapIndicators', [])), ...
        'mag15', struct('threeHour',  struct('values', [], 'uncertainties', [], 'gapIndicators', []), ...
                        'sixHour',    struct('values', [], 'uncertainties', [], 'gapIndicators', []), ...
                        'twelveHour', struct('values', [], 'uncertainties', [], 'gapIndicators', [])));
return

function expectedStruct = get_expected_struct()
    expectedStruct = struct( ...
        'mag9',  [], ...
        'mag10', [], ...
        'mag11', [], ...
        'mag12', [], ...
        'mag13', [], ...
        'mag14', [], ...
        'mag15', []);
return

function magCellArray = get_mag_cell_array()
    magCellArray = { 'mag9', 'mag10', 'mag11', 'mag12', 'mag13', 'mag14', 'mag15' };
return

 function hourCellArray = get_hour_cell_array()
     hourCellArray = { 'threeHour', 'sixHour', 'twelveHour' };
return

% For the _null functions, the 'min(size(data)) > 1' block is
% to prevent collapsing a singleton dimension, e.g., a 30x150 input 
% data should be collapsed down to a 1x150, but a 1x150 input dimension
% should NOT be collapsed down to 1x1!
%
function outputData = mean_null(data)
    outputData = [];    
    if ~isempty(data)
        if min(size(data)) > 1
            % Only (data) that is > 0 s/b included in the trimmean for each
            % cadence. Otherwise, set the outputData to zero for that cadence, &
            % set long gap cadence indicator to TRUE.
            nCadences = size(data,2);
            for icad = 1:nCadences
                cadData = data(:,icad);
                posCadData = cadData(cadData > 0);
                outputData(icad) = trimmean(posCadData, 10, 1);
            end
        else
            outputData = data;
        end
    end
    outputData = outputData(:);
return
 
% Get the smoothed average for the data set per cadence, using a window of 
% (one day - one long cadence) or the data size, whichever is smaller.  
% This 'whichever is smaller' condition is to handle datasets with
% a small number of cadences.
%
function outputData = smoothed_mean_null(data)
    outputData = [];    
    
    % If the duration of the data is < 47 cadences, make the window size
    % the data duration.
    windowSize = 47; % per Jon: one day minus one long cadence
    if size(data,2) < windowSize
        windowSize = size(data,2);
    end

    if ~isempty(data)

        if min(size(data)) <= 1
            outputData = data;
            outputData = outputData(:);
            return
        end
        
        meanedData = mean(data, 1);
        [paddedX meanedData paddedFit] = pad_linear_y(1:length(meanedData), meanedData, 1, length(meanedData), windowSize); %#ok<NASGU>

        outputData = filter(ones(windowSize,1)/windowSize, 1, meanedData);
        outputData = outputData(1+windowSize:end-windowSize);
    end
    outputData = outputData(:);
return

 function [padx pady fity] = pad_linear_y(x, y, minx, maxx, marg)
    p=polyfit(x, y, 1);
    z = polyval(p, x);

    stub_lx = (minx-marg):(minx-1);
    lr = minx:marg+minx-1;
    stub_ly = fliplr(y(lr)-z(lr)) + p(2) + p(1)*(x(lr)-marg);

    stub_rx = (maxx+1):(maxx+marg);
    rr =  maxx-marg+1:maxx;
    stub_ry = fliplr(y(rr)-z(rr)) + p(2) + p(1)*(x(rr)+marg);

    padx = [stub_lx x stub_rx];
    pady = [stub_ly y stub_ry];
    fity = polyval(p, padx);
return   

% Return the standard deviation of the data across the 1st dimension.
% Returns null for null inputs (the default std function errors if
% null inputs are given; this is to block that).
%
function outputData = std_null(data)
    outputData = [];    
    if ~isempty(data)
        if min(size(data)) > 1
            outputData = std(data, 1);
        else
            outputData = zeros(size(data));
        end
    end
    outputData = outputData(:);
return

% Perform a conv operation on 'data' over 'window'.
% handling are similar to the std_null notes.
%
function outputData = conv_null(window, data)
    workData = [data(1:window)-(data(window+1)-data(1));  data;  data(end-window+1:end)-(data(end-window)-data(end))];
    outputData = [];    
    if ~isempty(workData)
        outputData = conv(ones(1,window)/window, workData);
        deltaIndex = fix(window/2);
        outputData = outputData(deltaIndex+1:deltaIndex+length(workData));
    end
    outputData = outputData(1+window:end-window);
return

% For a set of input data, return a boolean vector (nCadences x 1) that indicates
% if ALL stars in the input data is gapped for that cadence.
%
function outputGaps = get_gaps_measured(data, nCadences)
    outputGaps = true(nCadences, 1);
    if ~isempty(data)
        if min(size(data)) > 1
            outputGaps = sum(data, 1) == size(data, 1);
        else
            outputGaps = data;
        end
    end
    outputGaps = outputGaps(:);
return


function [outputData longGappedCadences] = gapped_rms(data, gaps)
% outputData = gapped_rms(data, gaps)
%
% INPUTS: data(nstars x ncadences)
%         gaps(nstars x ncadences)
%
% OUTPUTS: outputData(ncadences x 1)
%
% Returns the RMS value of each cadence of input data
% for the elements of that cadence that are not gapped.
%
% If all data for a given cadence is gapped,
% compute the RMS of all targets for that cadence are greater than
% zero.  If none of the targets for that cadence are greater than
% zero, set the output value to zero and returns a gap indicator for that cadence.

    nCadences = size(data, 2);
    longGappedCadences = [];
    outputData = [];
    
    for icad = 1:nCadences
        cadData = data(:, icad);
        leZero = cadData <= 0;
        
        if all(leZero)
            longGappedCadences(end+1) = icad;
            rmsVal = 0;
        else
            squaredData = cadData(~leZero) .^ 2;
            meanedSquaredData = trimmean(squaredData, 10, 1);
            rmsVal = sqrt(meanedSquaredData);
        end
        
        outputData(icad) = rmsVal;
    end    
    
    outputData = outputData(:);
return

function output = rms_for_completely_gapped_data(data)
    output = [];
    if 0 == numel(data)
        return
    end
    
    output = zeros(1,size(data,2));
    for icadence = 1:size(data,2)
        cadData = data(:,icadence);
        cadDataGtZero = cadData(cadData > 0);
        output(icadence) = sqrt(sum(cadDataGtZero .^ 2) ./ length(cadDataGtZero));
    end
return

function windows = get_time_binning_windows(pmdScienceObject)
% Calculate the length in cadences of the time windows.  This calc 
% will not be affected by changing cadence times.  The results will be
% (6, 12, 24) for (3, 6, 12) hour time windows for half hour cadences.
% (six half-hour cadences for 3 hours, twelve half-hour cadences for 
% 6 hours, twenty-four half-hour cadences for 12 hours) 
%
    medDiffCadence = 24 * median(diff(pmdScienceObject.cadenceTimes.midTimestamps));
    windows = { round(3/medDiffCadence), round(6/medDiffCadence), round(12/medDiffCadence) };
return
