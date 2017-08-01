function [dvDataStruct] = update_dv_inputs(dvDataStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [dvDataStruct] = update_dv_inputs(dvDataStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Append names of conditioned ancillary data file and post-fit workspace
% file to the DV input data structure.
%
% Convert input blobs to structs for each target table. Attach these to
% the DV input data struct and remove the original blobs.
%
% Fill in the missing LC target table ID's and quarters in the 
% dvCadenceTimes structure.
%
% Set explicit gaps for PRF-based centroids for the targets where the
% PRF-based centroid time series values, uncertainties and gap indicators
% are empty.
%
% Convert PRF models to structures and append to the DV input data
% structure.
%
% Generate randStreams for DV and append to DV data structure.
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

% Hard code DV file names.
CONDITIONED_ANCILLARY_DATA_FILE = 'dv_cads.mat';
INTERMEDIATE_DATA_FILE = 'dv_post_fit_workspace.mat';
RANDOM_DATA_FILE = 'dv_rand.mat';

% Define constants for gapped values in dvCadenceTimes structure.
MISSING_TARGET_TABLE_ID = 0;
MISSING_QUARTER = -1;

% Add DV file names to DV data structure.
dvDataStruct.conditionedAncillaryDataFile = CONDITIONED_ANCILLARY_DATA_FILE;
dvDataStruct.intermediateDataFile = INTERMEDIATE_DATA_FILE;
dvDataStruct.randomDataFile = RANDOM_DATA_FILE;

% Bring older data sets up to current version if not running on a release
% branch.
import gov.nasa.kepler.common.KeplerSocBranch;

if ~KeplerSocBranch.isRelease()
    [dvDataStruct] = dv_convert_62_data_to_70(dvDataStruct);
    [dvDataStruct] = dv_convert_70_data_to_80(dvDataStruct);
    [dvDataStruct] = dv_convert_80_data_to_81(dvDataStruct);
    [dvDataStruct] = dv_convert_81_data_to_82(dvDataStruct);
    [dvDataStruct] = dv_convert_82_data_to_83(dvDataStruct);
    [dvDataStruct] = dv_convert_83_data_to_90(dvDataStruct);
    [dvDataStruct] = dv_convert_90_data_to_91(dvDataStruct);
    [dvDataStruct] = dv_convert_91_data_to_92(dvDataStruct);
    [dvDataStruct] = dv_convert_92_data_to_93(dvDataStruct);
end % if
    
% Change settings (if necessary) when externalTcesEnabled = true. The weak
% secondary test and statistical bootstrap cannot be run if TPS is not
% being called for the multiple planet search.
if dvDataStruct.dvConfigurationStruct.externalTcesEnabled
    dvDataStruct.dvConfigurationStruct.multiplePlanetSearchEnabled = true;
    dvDataStruct.dvConfigurationStruct.weakSecondaryTestEnabled = false;
    dvDataStruct.dvConfigurationStruct.bootstrapEnabled = false;
end % if

% Get fields from input structure.
cadenceTimes = dvDataStruct.dvCadenceTimes;
cadenceGapIndicators = cadenceTimes.gapIndicators;
targetTableDataStruct = dvDataStruct.targetTableDataStruct;
targetStruct = dvDataStruct.targetStruct;

% Clean the working directory; remove existing state files.
stateFileNames = {CONDITIONED_ANCILLARY_DATA_FILE};

for iFile = 1 : length(stateFileNames)
    fileName = stateFileNames{iFile};
    if exist(fileName, 'file') == 2
        delete(fileName);
        display(['update_dv_inputs: stale state file ', fileName, ' removed.']);
    end % if
end % for iFile

% Loop through the target table structures and convert the background and
% motion blob series to standard background and motion polynomial struct
% arrays. Append the converted polynomials to the target table data
% structure.
[targetTableDataStruct] = ...
    convert_blobs_for_all_dv_target_tables(targetTableDataStruct);
    
% Fill in the missing lcTargetTableIds and quarters in the dvCadenceTimes
% structure. Save the original vectors for calls to TPS.
lcTargetTableIds = cadenceTimes.lcTargetTableIds;
quarters = cadenceTimes.quarters;

dvDataStruct.dvCadenceTimes.originalLcTargetTableIds = lcTargetTableIds;
dvDataStruct.dvCadenceTimes.originalQuarters = quarters;

[dvDataStruct.dvCadenceTimes.lcTargetTableIds] = ...
    fill_missing_cadence_times_values(lcTargetTableIds, MISSING_TARGET_TABLE_ID);
[dvDataStruct.dvCadenceTimes.quarters] = ...
    fill_missing_cadence_times_values(quarters, MISSING_QUARTER);

% Set gaps for PRF-based centroids where they are empty.
centroidValues = zeros(size(cadenceGapIndicators));
centroidUncertainties = zeros(size(cadenceGapIndicators));
centroidGapIndicators = true(size(cadenceGapIndicators));

centroidTimeSeries = struct( ...
    'values', centroidValues, ...
    'uncertainties', centroidUncertainties, ...
    'gapIndicators', centroidGapIndicators);

nTargets = length(targetStruct);

for iTarget = 1 : nTargets
    
    if isempty(targetStruct(iTarget).centroids.prfCentroids.rowTimeSeries.gapIndicators)
        targetStruct(iTarget).centroids.prfCentroids.rowTimeSeries = ...
            centroidTimeSeries;
    end
    
    if isempty(targetStruct(iTarget).centroids.prfCentroids.columnTimeSeries.gapIndicators)
        targetStruct(iTarget).centroids.prfCentroids.columnTimeSeries = ...
            centroidTimeSeries;
    end
    
end % for iTarget

% Ensure that the maximum single event statistic for seeding the DV fitter
% is equal to the maximum of the single event statistics combined to yield
% the maximum multiple event statistic for each TCE. Do not do this if
% external TCEs are enabled; in this case the desired maximum single event
% statistic is provided explicitly.
if ~dvDataStruct.dvConfigurationStruct.externalTcesEnabled
    for iTarget = 1 : nTargets
        nTces = length(targetStruct(iTarget).thresholdCrossingEvent);
        for iTce = 1 : nTces
            targetStruct(iTarget).thresholdCrossingEvent(iTce).maxSingleEventSigma = ...
                targetStruct(iTarget).thresholdCrossingEvent(iTce).maxSesInMes;
        end % for iTce
    end % for iTarget
end % if

% Merge the outlier indices with the filled indices for each target. This
% is to address a bug first introduced in PDC 8.0.
for iTarget = 1 : nTargets
    targetStruct(iTarget).correctedFluxTimeSeries.filledIndices = union( ...
        targetStruct(iTarget).correctedFluxTimeSeries.filledIndices, ...
        targetStruct(iTarget).outliers.indices);
end % for iTarget

% Convert each of the PRF files to PRF models and append to the DV data
% structure.
prfModelFileNames = dvDataStruct.prfModelFileNames;
[prfModelFileNames, prfModels] = convert_dv_prf_files(prfModelFileNames);

dvDataStruct.prfModelFileNames = prfModelFileNames;
dvDataStruct.prfModels = prfModels;

% Remove KOI matching information if matching is not enabled.
if ~dvDataStruct.dvConfigurationStruct.koiMatchingEnabled
    dvDataStruct.transitParameterModelDescription = '';
    dvDataStruct.transitNameModelDescription = '';
    for iTarget = 1 : nTargets
        targetStruct(iTarget).transits = [];
    end % for iTarget
end % if

% Order the KOIs by koiId. Note that the koiIds are strings.
for iTarget = 1 : nTargets
    if ~isempty(targetStruct(iTarget).transits)
        [~, ix] = sort({targetStruct(iTarget).transits.koiId});
        targetStruct(iTarget).transits = ...
            targetStruct(iTarget).transits(ix);
    end % if
end % for iTarget

% Update the DV input structure.
dvDataStruct.targetTableDataStruct = targetTableDataStruct;
dvDataStruct.targetStruct = targetStruct;

% Order the KICs by keplerId and remove any duplicates.
if ~isempty(dvDataStruct.kics)
    keplerIds = [dvDataStruct.kics.keplerId];
    [b, m] = unique(keplerIds, 'first');                                                                %#ok<ASGLU>
    dvDataStruct.kics = dvDataStruct.kics(m);
end % if

% Generate the randStreams for DV (including streams for call to TPS
% quarter-stitcher).
[dvDataStruct] = generate_dv_randstreams(dvDataStruct);

% Order the fields in the config maps which are used before the DV data
% object is instantiated.
dvDataStruct.configMaps = ...
    orderfields(dvDataStruct.configMaps);
nMaps = length(dvDataStruct.configMaps);
for iMap = 1 : nMaps
    dvDataStruct.configMaps(iMap).entries = ...
        orderfields(dvDataStruct.configMaps(iMap).entries);
end % for iMap

% Check for valid simulated transits parameters file.
tipFilename = dvDataStruct.transitInjectionParametersFileName;
simulatedTransitsEnabled = dvDataStruct.dvConfigurationStruct.simulatedTransitsEnabled;
if simulatedTransitsEnabled && ~isvalid_transit_injection_parameters_file( tipFilename );
    error(['Transit injection parameters file *',tipFilename,'* invalid.']);
end


% Return.
return


function [y] = fill_missing_cadence_times_values(x, g)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [y] = fill_missing_cadence_times_values(x, g)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% The lcTargetTableIds and quarters fields as populated on the Java side of
% the DV module interface do not associate each and every cadence with a
% given target table and quarter. That problem is rectified here by
% assuming that each target table and quarter extend to the beginning of
% the following target table and quarter. Gapped values of lcTargetTableIds
% and quarters values are indicated so that they can be ignored. It is not
% assumed that lcTargetTableIds (and quarters) must be monotonically
% increasing, just that they cannot be re-used.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% Find the unique values.
[b, m] = unique(x, 'first');

% Get the number of cadences.
n = length(x);

% Squeeze out the gapped value and associated "start" index. Sort by
% start index.
m(b == g) = [];
b(b == g) = [];

[m, ix] = sort(m);
b = b(ix);

% Make sure that the first valid lcTargetTableId and quarter begin on the
% first cadence.
m(1) = 1;

% Extend the duration of the lcTargetTableIds and quarters from the
% beginning of each instance to the beginning of the following instance.
l = length(b);
y = x;

for i = 1 : l-1
    y(m(i) : m(i+1) - 1) = b(i);
end % for i

y(m(l) : n) = b(l);

% Return.
return
