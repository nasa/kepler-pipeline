%% pdc_convert_83_data_to_90
%
% function [pdcInputStruct] = pdc_convert_83_data_to_90(pdcInputStruct)
%
% Update earlier PDC input structures to 9.0. It recursively calls earlier version 
% conversion functions. This is useful when testing with existing data sets.
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

function [pdcInputStruct] = pdc_convert_83_data_to_90(pdcInputStruct)

% First call all previous conversion files
% These should iteratively call each other on down
[pdcInputStruct] = pdc_convert_82_data_to_83(pdcInputStruct);

% Don't be vocal about when to set a field
verbosity = false;

% New fields for mapConfigurationStruct
pdcInputStruct.mapConfigurationStruct = ...
    assert_field(pdcInputStruct.mapConfigurationStruct, 'useBasisVectorsAndPriorsFromBlob', false, verbosity);
pdcInputStruct.mapConfigurationStruct = ...
    assert_field(pdcInputStruct.mapConfigurationStruct, 'useBasisVectorsAndPriorsFromPixels', false, verbosity);
pdcInputStruct.mapConfigurationStruct = ...
    assert_field(pdcInputStruct.mapConfigurationStruct, 'usePriorsFromPixels', false, verbosity);

% New fields for spsdDetectionConfigurationStruct
pdcInputStruct.spsdDetectionConfigurationStruct = ...
    assert_field(pdcInputStruct.spsdDetectionConfigurationStruct, 'harmonicsRemovalEnabled', false, verbosity);

% New fields for spsdRemovalConfigurationStruct (for Short Cadence Post Correction)
pdcInputStruct.spsdRemovalConfigurationStruct = ...
    assert_field(pdcInputStruct.spsdRemovalConfigurationStruct, 'shortCadencePostCorrectionEnabled', false, verbosity);
pdcInputStruct.spsdRemovalConfigurationStruct = ...
    assert_field(pdcInputStruct.spsdRemovalConfigurationStruct, 'shortCadencePostCorrectionLeftWindow', 5, verbosity);
pdcInputStruct.spsdRemovalConfigurationStruct = ...
    assert_field(pdcInputStruct.spsdRemovalConfigurationStruct, 'shortCadencePostCorrectionRightWindow', 30, verbosity);
pdcInputStruct.spsdRemovalConfigurationStruct = ...
    assert_field(pdcInputStruct.spsdRemovalConfigurationStruct, 'shortCadencePostCorrectionMethod', 'gapfill', verbosity);
