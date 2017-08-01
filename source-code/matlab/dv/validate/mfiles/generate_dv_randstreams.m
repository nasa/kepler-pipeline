function [dvDataStruct] = generate_dv_randstreams(dvDataStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [dvDataStruct] = generate_dv_randstreams(dvDataStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Generate target-specific and method-specific randstreams for DV
% (including call to TPS quarter-stitcher). Target and CSCI-specific
% randstreams are a design goal for the SOC pipeline. We are also
% implementing method-specific randstreams in DV because debugging of
% post-fit functionality in DV is generally performed by loading the DV
% data object from the post-fit workspace and invoking the desired method.
% This may shortcut other methods which would have been executed in the
% pipeline. The method-specific randstreams ensure that the same random
% number sequences are generated per target in the pipeline and in local
% method-specific debugging.
%
% Append the randstreams to the DV data object. Ensure that an additional
% randstream is also generated that can apply to all targets.
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

% Set the method-specific seed offsets. Offsets are in units of 1e10
% because seeds are generated from 10*keplerId+csciIndex+seedOffset and
% keplerIds are 9-digit numbers.
PRE_FITTER_OFFSET =                 0e10;
FITTER_OFFSET =                     1e10;
DIFFERENCE_IMAGE_OFFSET =           2e10;
CENTROID_TEST_OFFSET =              3e10;
PIXEL_CORRELATION_TEST_OFFSET =     4e10;
BINARY_DISCRIMINATION_TEST_OFFSET = 5e10;
BOOTSTRAP_OFFSET =                  6e10;
GHOST_DIAGNOSTIC_OFFSET =           7e10;

% Generate a randstream struct and append it to the DV data structure. Let
% keplerId = 0 apply to all targets.
keplerIds = [dvDataStruct.targetStruct.keplerId]';
keplerIds = [keplerIds; 0];

[paramStruct] = socRandStreamManagerClass.get_default_param_struct();

[tpsRandStreams] = ...
    socRandStreamManagerClass('TPS', keplerIds, paramStruct);

paramStruct.seedOffset = PRE_FITTER_OFFSET;
[preFitterRandStreams] = ...
    socRandStreamManagerClass('DV', keplerIds, paramStruct);

paramStruct.seedOffset = FITTER_OFFSET;
[fitterRandStreams] = ...
    socRandStreamManagerClass('DV', keplerIds, paramStruct);

paramStruct.seedOffset = DIFFERENCE_IMAGE_OFFSET;
[differenceImageRandStreams] = ...
    socRandStreamManagerClass('DV', keplerIds, paramStruct);

paramStruct.seedOffset = CENTROID_TEST_OFFSET;
[centroidTestRandStreams] = ...
    socRandStreamManagerClass('DV', keplerIds, paramStruct);

paramStruct.seedOffset = PIXEL_CORRELATION_TEST_OFFSET;
[pixelCorrelationTestRandStreams] = ...
    socRandStreamManagerClass('DV', keplerIds, paramStruct);

paramStruct.seedOffset = BINARY_DISCRIMINATION_TEST_OFFSET;
[binaryDiscriminationTestRandStreams] = ...
    socRandStreamManagerClass('DV', keplerIds, paramStruct);

paramStruct.seedOffset = BOOTSTRAP_OFFSET;
[bootstrapRandStreams] = ...
    socRandStreamManagerClass('DV', keplerIds, paramStruct);

paramStruct.seedOffset = GHOST_DIAGNOSTIC_OFFSET;
[ghostDiagnosticRandStreams] = ...
    socRandStreamManagerClass('DV', keplerIds, paramStruct);

% Initialize the randStreamStruct.
randStreamStruct = struct( ...
    'tpsRandStreams', tpsRandStreams, ...
    'preFitterRandStreams', preFitterRandStreams, ...
    'fitterRandStreams', fitterRandStreams, ...
    'differenceImageRandStreams', differenceImageRandStreams, ...
    'centroidTestRandStreams', centroidTestRandStreams, ...
    'pixelCorrelationTestRandStreams', pixelCorrelationTestRandStreams, ...
    'binaryDiscriminationTestRandStreams', binaryDiscriminationTestRandStreams, ...
    'bootstrapRandStreams', bootstrapRandStreams, ...
    'ghostDiagnosticRandStreams', ghostDiagnosticRandStreams);

% Append the randStreamStruct to the dvDataStruct.
dvDataStruct.randStreamStruct = randStreamStruct;

% Return.
return
