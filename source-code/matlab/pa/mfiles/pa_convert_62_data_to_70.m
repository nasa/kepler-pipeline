%% pa_convert_62_data_to_70
%
% function [paDataStruct] = pa_convert_62_data_to_70(paDataStruct)
%
% Update 6.2-era PA input structures to 7.0. This is useful when testing
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

function [paDataStruct] = pa_convert_62_data_to_70(paDataStruct)

if ~isfield(paDataStruct.gapFillConfigurationStruct, 'giantTransitPolyFitChunkLengthInHours')
    paDataStruct.gapFillConfigurationStruct.giantTransitPolyFitChunkLengthInHours = 72;
end % if

if ~isfield(paDataStruct.gapFillConfigurationStruct, 'removeShortPeriodEclipsingBinaries')
    paDataStruct.gapFillConfigurationStruct.removeShortPeriodEclipsingBinaries = false;
end % if


if ~isfield(paDataStruct.motionConfigurationStruct, 'aicDecimationFactor')
    paDataStruct.motionConfigurationStruct.aicDecimationFactor = 8;
end % if

if ~isfield(paDataStruct.motionConfigurationStruct, 'centroidBiasFitOrder')
    paDataStruct.motionConfigurationStruct.centroidBiasFitOrder = 2;
end % if

if ~isfield(paDataStruct.motionConfigurationStruct, 'centroidBiasRemovalIterations')
    paDataStruct.motionConfigurationStruct.centroidBiasRemovalIterations = 2;
end % if

if ~isfield(paDataStruct.motionConfigurationStruct, 'maxGappingIterations')
    paDataStruct.motionConfigurationStruct.maxGappingIterations = 20;
end % if

if ~isfield(paDataStruct.motionConfigurationStruct, 'robustWeightGappingThreshold')
    paDataStruct.motionConfigurationStruct.robustWeightGappingThreshold = 0.5000;
end % if


fcModelMetadata = struct( ...
    'svnInfo', '', ...
    'ingestTime', '', ...
    'modelDescription', '', ...
    'databaseUrl', '', ...
    'databaseUsername', '');

if ~isfield(paDataStruct.raDec2PixModel.geometryModel, 'fcModelMetadata')
    paDataStruct.raDec2PixModel.geometryModel.fcModelMetadata = ...
        fcModelMetadata;
end % if

if ~isfield(paDataStruct.raDec2PixModel.pointingModel, 'fcModelMetadata')
    paDataStruct.raDec2PixModel.pointingModel.fcModelMetadata = ...
        fcModelMetadata;
end % if

if ~isfield(paDataStruct.raDec2PixModel.rollTimeModel, 'fcModelMetadata')
    paDataStruct.raDec2PixModel.rollTimeModel.fcModelMetadata = ...
        fcModelMetadata;
end % if

return
