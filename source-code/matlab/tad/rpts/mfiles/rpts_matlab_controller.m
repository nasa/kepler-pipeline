function [rptsResultsStruct] = rpts_matlab_controller(rptsInputStruct)
% function [rptsResultsStruct] = rpts_matlab_controller(rptsInputStruct)
%
% This function forms the MATLAB side of the science interface of the reference
% pixel target selection, and receives inputs via the structure rptsInputStruct.
% This function first calls the constructor for the rptsClass, which validates the
% fields of the input structure, and converts the required row/column inputs from
% (java) 0-base to (matlab) 1-base.  The function get_reference_pixel_target_definitions
% is called, which creates all of the reference pixel target and mask definitions,
% and converts the relevant rows/columns back to java 0-base prior to output.
%
% INPUT:  A data structure 'rptsInputStruct' with the following fields:
%
% top level
%  rptsInputStruct: a struct array which contains the following fields:
%
%          moduleOutputImage: [struct array]    image on the module output CCD produced by COA
%           stellarApertures: [struct array]    optimal apertures for selected stellar targets
%      dynamicRangeApertures: [struct array]    optimal apertures for dynamic range targets
%              existingMasks: [struct array]    input table of mask definitions
% rptsModuleParametersStruct: [struct]          module parameters
%                  debugFlag: [logical]         flag for debug mode
%
%  * see rptsClass.m for the fields and definitions in the above input structure
%
%  OUTPUT: rptsResultsStruct of class rptsClass containing the following fields as data members.
%
% top level
%  rptsResultsStruct is a struct array with the following fields:
%                  stellarTargetDefinitions: [struct array]
%             dynamicRangeTargetDefinitions: [struct array]
%                backgroundTargetDefinition: [struct array]
%                    blackTargetDefinitions: [struct array]
%                    smearTargetDefinitions: [struct array]
%                  backgroundMaskDefinition: [struct array]  custom mask
%                       blackMaskDefinition: [struct array]  custom mask
%                       smearMaskDefinition: [struct array]  custom mask
%
%  * see rptsClass.m for the fields and definitions in the above output structure
%--------------------------------------------------------------------------
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

if ~isfield(rptsInputStruct, 'debugFlag')
    % add debugFlag (=0) to inputs if unavailable
    rptsInputStruct.debugFlag = false;
end

debugFlag = rptsInputStruct.debugFlag;


% check for the presence of expected fields in the input structure, check
% whether each parameter is within the appropriate range, and create rptsClass
tic
rptsObject = rptsClass(rptsInputStruct);

display_rpts_status('RPTS:rpts_matlab_controller: Inputs validated and RPTS object created', 1);

%--------------------------------------------------------------------------
% get all reference pixel target definitions and mask definitions
tic
rptsResultsStruct = get_reference_pixel_target_definitions(rptsObject);

display('RPTS:rpts_matlab_controller: All target and mask definitions created');

if debugFlag >= 2
    save standardRptsResults.mat rptsResultsStruct
end

return;
