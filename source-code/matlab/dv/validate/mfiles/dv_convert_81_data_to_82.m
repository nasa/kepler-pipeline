%% dv_convert_81_data_to_82
%
% function dvDataStruct = dv_convert_81_data_to_82(dvDataStruct)
%
% Update 8.1-era DV input structures to 8.2. This is useful when testing
% with existing data sets.
%%
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

function dvDataStruct = dv_convert_81_data_to_82(dvDataStruct)

% Add default prior instance ID for 8.2.
if ~isfield(dvDataStruct, 'priorInstanceId')
    dvDataStruct.priorInstanceId = '-';
end % if

% Add default prior fit results for 8.2.
if ~isfield(dvDataStruct.targetStruct(1), 'allTransitsFits')
    nTargets = length(dvDataStruct.targetStruct);
    for iTarget = 1 : nTargets
        dvDataStruct.targetStruct(iTarget).allTransitsFits = [];
    end % for iTarget
end % if

% Add difference image parameters.
if ~isfield(dvDataStruct.differenceImageConfigurationStruct, ...
        'singlePrfFitSnrThreshold')
    dvDataStruct.differenceImageConfigurationStruct.singlePrfFitSnrThreshold = 0.0;
end % if

if ~isfield(dvDataStruct.differenceImageConfigurationStruct, ...
        'maxSinglePrfFitFailures')
    dvDataStruct.differenceImageConfigurationStruct.maxSinglePrfFitFailures = 20;
end % if

% Parse data anomaly types.
if isfield(dvDataStruct.dvCadenceTimes, 'dataAnomalyTypes')
    if ~isfield(dvDataStruct.dvCadenceTimes, 'dataAnomalyFlags')
        [dvDataStruct.dvCadenceTimes.dataAnomalyFlags] = ...
            parse_data_anomaly_types(dvDataStruct.dvCadenceTimes.dataAnomalyTypes);
    end % if
    dvDataStruct.dvCadenceTimes = rmfield(dvDataStruct.dvCadenceTimes, 'dataAnomalyTypes');
end % if

% Add new gap fill parameter.
if ~isfield(dvDataStruct.gapFillConfigurationStruct, ...
        'arAutoCorrelationThreshold')
    dvDataStruct.gapFillConfigurationStruct.arAutoCorrelationThreshold = 0.05;
end % if

% Add new PDC parameters.
if ~isfield(dvDataStruct.pdcConfigurationStruct, ...
        'bandSplittingEnabled')
    dvDataStruct.pdcConfigurationStruct.bandSplittingEnabled = false;
end % if

if ~isfield(dvDataStruct.pdcConfigurationStruct, ...
        'stellarVariabilityRemoveEclipsingBinariesEnabled')
    dvDataStruct.pdcConfigurationStruct.stellarVariabilityRemoveEclipsingBinariesEnabled = false;
end % if

% Add empty CBV blob series.
if ~isfield(dvDataStruct.targetTableDataStruct(1), 'cbvBlobs')
    for iTable = 1 : length(dvDataStruct.targetTableDataStruct)
        dvDataStruct.targetTableDataStruct(iTable).cbvBlobs = struct( ...
            'blobIndices', [], ...
            'gapIndicators', [], ...
            'blobFilenames', [], ...
            'startCadence', -1, ...
            'endCadence', -1);
    end % for iTable
end % if

return
