%% dv_convert_70_data_to_80
%
% function dvDataStruct = dv_convert_70_data_to_80(dvDataStruct)
%
% Update 7.0-era DV input structures to 8.0. This is useful when testing
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

function dvDataStruct = dv_convert_70_data_to_80(dvDataStruct)

% Add empty PRF model file names array if necessary.
if ~isfield(dvDataStruct, 'prfModelFileNames')
    dvDataStruct.prfModelFileNames = {};
end % if
if ~isfield(dvDataStruct, 'prfModels')
    dvDataStruct.prfModels = {};
end % if

% Add empty ancillary engineering data file name if necessary.
if ~isfield(dvDataStruct, 'ancillaryEngineeringDataFileName')
    dvDataStruct.ancillaryEngineeringDataFileName = '';
end % if

% Remove attitude solution structure if it exists.
if isfield(dvDataStruct, 'attitudeSolutionStruct')
    dvDataStruct = rmfield(dvDataStruct, 'attitudeSolutionStruct');
end % if

% Update planet fit parameters for 8.0.
if ~isfield(dvDataStruct.planetFitConfigurationStruct, 'smallBodyCutoff')
    dvDataStruct.planetFitConfigurationStruct.smallBodyCutoff = 1.0e6;
end % if

% Update PDC parameters for 8.0.
if ~isfield(dvDataStruct.pdcConfigurationStruct, 'mapEnabled')
    dvDataStruct.pdcConfigurationStruct.mapEnabled = false;
end % if

if ~isfield(dvDataStruct.pdcConfigurationStruct, 'excludeTargetLabels')
    dvDataStruct.pdcConfigurationStruct.excludeTargetLabels = [];
end % if

if ~isfield(dvDataStruct.pdcConfigurationStruct, 'harmonicsRemovalEnabled')
    dvDataStruct.pdcConfigurationStruct.harmonicsRemovalEnabled = false;
end % if

if ~isfield(dvDataStruct.pdcConfigurationStruct, 'preMapIterations')
    dvDataStruct.pdcConfigurationStruct.preMapIterations = 2;
end % if

if isfield(dvDataStruct.pdcConfigurationStruct, 'histogramLength')
    dvDataStruct.pdcConfigurationStruct = ...
        rmfield(dvDataStruct.pdcConfigurationStruct, 'histogramLength');
end % if

if isfield(dvDataStruct.pdcConfigurationStruct, 'histogramCountFraction')
    dvDataStruct.pdcConfigurationStruct = ...
        rmfield(dvDataStruct.pdcConfigurationStruct, 'histogramCountFraction');
end % if

if isfield(dvDataStruct.pdcConfigurationStruct, 'outlierScanWindowSize')
    dvDataStruct.pdcConfigurationStruct = ...
        rmfield(dvDataStruct.pdcConfigurationStruct, 'outlierScanWindowSize');
end % if

% Update TPS parameters for 8.0.
if ~isfield(dvDataStruct.tpsConfigurationStruct, 'robustStatisticThreshold')
    dvDataStruct.tpsConfigurationStruct.robustStatisticThreshold = 7.1;
end % if

if ~isfield(dvDataStruct.tpsConfigurationStruct, 'robustStatisticWindowLengthMultiplier')
    dvDataStruct.tpsConfigurationStruct.robustStatisticWindowLengthMultiplier = 3.0;
end % if

if ~isfield(dvDataStruct.tpsConfigurationStruct, 'robustWeightGappingThreshold')
    dvDataStruct.tpsConfigurationStruct.robustWeightGappingThreshold = 0.5;
end % if

if ~isfield(dvDataStruct.tpsConfigurationStruct, 'robustStatisticConvergenceTolerance')
    dvDataStruct.tpsConfigurationStruct.robustStatisticConvergenceTolerance = 0.01;
end % if

% Update gap fill parameters for 8.0.
if isfield(dvDataStruct.gapFillConfigurationStruct, 'removeShortPeriodEclipsingBinaries')
    dvDataStruct.gapFillConfigurationStruct.removeEclipsingBinariesOnList = ...
        dvDataStruct.gapFillConfigurationStruct.removeShortPeriodEclipsingBinaries;
    dvDataStruct.gapFillConfigurationStruct = ...
        rmfield(dvDataStruct.gapFillConfigurationStruct, 'removeShortPeriodEclipsingBinaries'); 
end % if

if ~isfield(dvDataStruct.gapFillConfigurationStruct, 'removeEclipsingBinariesOnList')
    dvDataStruct.gapFillConfigurationStruct.removeEclipsingBinariesOnList = false;
end % if

return
