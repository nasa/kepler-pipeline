%% pdc_convert_80_data_to_81
%
% function [pdcInputStruct] = pdc_convert_80_data_to_81(pdcInputStruct)
%
% Update 8.0-era PDC input structures to 8.1. This is useful when testing
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

function [pdcInputStruct] = pdc_convert_80_data_to_81(pdcInputStruct)

% First call all previous conversion files
% Theses should iteratively call each other on down
[pdcInputStruct] = pdc_convert_70_data_to_80(pdcInputStruct);

% Don't be vocal about when to set a field
verbosity = false;

% New fields for pdcModuleParameters
pdcInputStruct.pdcModuleParameters = ...
    assert_field(pdcInputStruct.pdcModuleParameters, 'variabilityEpRecoveryMaskEnabled', true, verbosity);
pdcInputStruct.pdcModuleParameters = ...
    assert_field(pdcInputStruct.pdcModuleParameters, 'variabilityEpRecoveryMaskWindow', 150, verbosity);
pdcInputStruct.pdcModuleParameters = ...
    assert_field(pdcInputStruct.pdcModuleParameters, 'variabilityDetrendPolyOrder', 3, verbosity);


% New fields for mapConfigurationStruct
pdcInputStruct.mapConfigurationStruct = ...
    assert_field(pdcInputStruct.mapConfigurationStruct, 'minFractionOfTargetsForSvd', 0.1, verbosity);
pdcInputStruct.mapConfigurationStruct = ...
    assert_field(pdcInputStruct.mapConfigurationStruct, 'entropyCleaningEnabled', true, verbosity);
pdcInputStruct.mapConfigurationStruct = ...
    assert_field(pdcInputStruct.mapConfigurationStruct, 'entropyCleaningCutoff', -0.7, verbosity);
pdcInputStruct.mapConfigurationStruct = ...
    assert_field(pdcInputStruct.mapConfigurationStruct, 'entropyMadFactor', 10.0, verbosity);
pdcInputStruct.mapConfigurationStruct = ...
    assert_field(pdcInputStruct.mapConfigurationStruct, 'entropyMaxIterations', 30, verbosity);

% New fields for spsdDetectionConfigurationStruct
pdcInputStruct.spsdDetectionConfigurationStruct = ...
    assert_field(pdcInputStruct.spsdDetectionConfigurationStruct, 'excludeWindowHalfWidth', 4, verbosity);


return
