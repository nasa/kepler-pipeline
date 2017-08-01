function [rptsInputStruct, rptsObject] = generate_rpts_test_data
% [rptsInputStruct, rptsObject] = generate_rpts_test_data
%
% function to generate test data for reference pixel target selection.  
% Outputs are the rpts input structure and rpts object.  Apertures and image
% are generated (by S. Bryson) from ETEM data and results from TAD coa and amt 
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

% (1) load results from ETEM run
% load /path/to/matlab/tad/rpts/sample_data/run370/FFI_4_2_2_run370.mat;   

% (2) load result structs directly from TAD coa and ama output 
% (standardCoaResultStruct, standardAmaResultStruct)
load /path/to/matlab/tad/rpts/sample_data/sample_data.mat  

% (3) load struct from rpts inputs-*.bin
% load /path/to/matlab/tad/rpts/sample_data/rpts_inputs.mat  

% pre-allocate rpts inputs structure
rptsInputStruct = struct('moduleOutputImage', [], 'stellarApertures', [], 'dynamicRangeApertures', [], ...
    'existingMasks', [], 'rptsModuleParametersStruct', [], 'debugFlag', []);

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% generate test data for moduleOutputImage
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% (1) for ETEM data:
% ccdImage = ccdm;

% (2) for coa/ama output:
ccdImage = struct_to_array2D(standardCoaResultStruct.completeOutputImage);
[s1, s2] = size(ccdImage);   

% pre-allocate image struct array
rptsInputStruct.moduleOutputImage = repmat(struct('array', zeros(s2, 1)), 1, s1);

for row = 1:s1
    rptsInputStruct.moduleOutputImage(row).array = ccdImage(row, :)'; 
end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% generate test data for stellarApertures and for dynamicRangeApertures structs
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
optimalApertures = standardCoaResultStruct.optimalApertures;
% remove fields that are not relevant to rpts
optimalApertures = rmfield(optimalApertures, 'signalToNoiseRatio');
optimalApertures = rmfield(optimalApertures, 'crowdingMetric');

% select subset to populate stellarApertures structure
rptsInputStruct.stellarApertures = optimalApertures(1:25);
rptsInputStruct.stellarApertures(1).referenceColumn = 900;  % these are off bounds - temp fix
rptsInputStruct.stellarApertures(6).referenceRow = 27;      % these are off bounds - temp fix
rptsInputStruct.stellarApertures(20).referenceRow = 88;     % these are off bounds - temp fix

% select subset to populate dynamicRangeApertures
rptsInputStruct.dynamicRangeApertures = optimalApertures(26:30);
clear optimalApertures;

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% generate test data for existingMasks
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%maskDefinitions = cat(2, standardAmtResultStruct.maskDefinitions);
maskDefinitions = standardAmtResultStruct.maskDefinitions;
rptsInputStruct.existingMasks = maskDefinitions;
clear maskDefinitions;

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% generate test data for rptsModuleParametersStruct
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
rptsInputStruct.rptsModuleParametersStruct.nHaloRings = 2;
rptsInputStruct.rptsModuleParametersStruct.radiusForBackgroundPixelSelection = 45;
rptsInputStruct.rptsModuleParametersStruct.nBackgroundPixelsPerStellarTarget = 14;
% valid rows for smearRows  with (0, 0) at ULHS are: [0:25, 1050:1069], or in matlab-base [1:26, 1051:1070]
% or with (0, 0) at LLHS: [0:19, 1044:1069], or in matlab-base [1:20, 1045:1070]
% valid columns for blackColumns are:  [0:11, 1112:1131], or in matlab-base [1:12, 1113:1132]
rptsInputStruct.rptsModuleParametersStruct.smearRows  = [5:10, 1055:1065]';
rptsInputStruct.rptsModuleParametersStruct.blackColumns = (1:10)';
rptsInputStruct.rptsModuleParametersStruct.backgroundModeThresh = 2;
rptsInputStruct.rptsModuleParametersStruct.smearNoiseRatioThresh = 5.0000e-04;
rptsInputStruct.rptsModuleParametersStruct.exposuresPerCadence = 289;
rptsInputStruct.rptsModuleParametersStruct.readNoiseSquared = 180625;

% set debug flag
rptsInputStruct.debugFlag = 0;

%--------------------------------------------------------------------------
% create the rpts object
tic
rptsObject = rptsClass(rptsInputStruct);
toc

save /path/to/matlab/tad/rpts/inputs.mat rptsInputStruct rptsObject;
save /path/to/matlab/tad/rpts/sample_data/inputs.mat rptsInputStruct rptsObject

return
