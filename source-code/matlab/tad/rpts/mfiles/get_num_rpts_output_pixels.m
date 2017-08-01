function rptsPixelCountStruct = get_num_rpts_output_pixels(inputsStruct, outputsStruct)
% function rptsPixelCountStruct = get_num_rpts_output_pixels(inputsStruct, outputsStruct)
%
% function to get the total number of pixels in RPTS-generated target
% definitions (stellar, dynamic range, background, and collateral
% (black/smear).  The total number of pixels for each pixel type are
% also output.
%
%
%
% INPUTS: RPTS input and output structs
%
% example inputs/outputs:
%
% inputsStruct =
%                         module: 22
%                         output: 3
%              moduleOutputImage: [1x1070 struct]
%               stellarApertures: [1x5 struct]
%          dynamicRangeApertures: [1x1 struct]
%                  existingMasks: [1x772 struct]
%                 readNoiseModel: [1x1 struct]
%                    fcConstants: [1x1 struct]
%     rptsModuleParametersStruct: [1x1 struct]
%             scConfigParameters: [1x1 struct]
%                      debugFlag: 0
%
% outputsStruct =
%          stellarTargetDefinitions: [1x5 struct]
%     dynamicRangeTargetDefinitions: [1x1 struct]
%        backgroundTargetDefinition: [1x1 struct]
%            blackTargetDefinitions: [1x5 struct]
%            smearTargetDefinitions: [1x10 struct]
%          backgroundMaskDefinition: [1x1 struct]
%               blackMaskDefinition: [1x1 struct]
%               smearMaskDefinition: [1x1 struct]
%
%
% OUTPUTS:
%
% rptsPixelCountStruct = 
%                           ccdModule: 2
%                           ccdOutput: 1
%                             channel: 1
%                   numStellarTargets: 3
%              numDynamicRangeTargets: 0
%                      numBkgdTargets: 1
%               numMaskedSmearTargets: 5
%              numVirtualSmearTargets: 5
%                     numBlackTargets: 5
%               numStellarPixelsTotal: 312
%               numStellarPixelsArray: [3x1 double]
%         numExcessStellarPixelsTotal: 100
%         numExcessStellarPixelsArray: [3x1 double]
%          numDynamicRangePixelsTotal: 0
%          numDynamicRangePixelsArray: 0
%        numExcessDynRangePixelsTotal: 0
%        numExcessDynRangePixelsArray: 0
%                numMaskedSmearPixels: 230
%               numVirtualSmearPixels: 230
%                      numBlackPixels: 275
%                     numTotalTargets: 19
%          numTotalPhotometricTargets: 3
%           numTotalCollateralTargets: 16
%                      numTotalPixels: 1062
%           numTotalPhotometricPixels: 312
%            numTotalCollateralPixels: 750
%           numPhotometricPixelsArray: [3x1 double]
%     numExcessPhotometricPixelsTotal: 100
%     numExcessPhotometricPixelsArray: [3x1 double]
%
%
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


ccdModule = inputsStruct.module;
ccdOutput = inputsStruct.output;

channel = convert_from_module_output(ccdModule, ccdOutput);

rptsPixelCountStruct.ccdModule = ccdModule;
rptsPixelCountStruct.ccdOutput = ccdOutput;
rptsPixelCountStruct.channel   = channel;

% load the existing masks table from the inputs struct
existingMasksTable = inputsStruct.existingMasks;

% masked and virtual smear target definitions are grouped together, find
% the number of each type from inputs:
smearRows           = inputsStruct.rptsModuleParametersStruct.smearRows;

maskedSmearRows     = smearRows(smearRows < 20);        % 0base:    0:19
virtualSmearRows    = smearRows(smearRows > 1043);      % 0base:    1044:1069

%--------------------------------------------------------------------------
% get the number of targets for each pixel type
%--------------------------------------------------------------------------
numStellarTargets       = length(outputsStruct.stellarTargetDefinitions);
numDynamicRangeTargets  = length(outputsStruct.dynamicRangeTargetDefinitions);
numBkgdTargets          = length(outputsStruct.backgroundTargetDefinition);

numMaskedSmearTargets   = length(maskedSmearRows);
numVirtualSmearTargets  = length(virtualSmearRows);
numMaskedAndVirtualSmearTargets  = length(outputsStruct.smearTargetDefinitions);

numBlackTargets         = length(outputsStruct.blackTargetDefinitions);


% add to output struct
rptsPixelCountStruct.numStellarTargets          = numStellarTargets;
rptsPixelCountStruct.numDynamicRangeTargets     = numDynamicRangeTargets;
rptsPixelCountStruct.numBkgdTargets             = numBkgdTargets;

rptsPixelCountStruct.numMaskedSmearTargets      = numMaskedSmearTargets;
rptsPixelCountStruct.numVirtualSmearTargets     = numVirtualSmearTargets;
%rptsPixelCountStruct.numMaskedAndVirtualSmearTargets = numMaskedAndVirtualSmearTargets;
rptsPixelCountStruct.numBlackTargets            = numBlackTargets;


%--------------------------------------------------------------------------
% count the number of total pixels for stellar targets
%--------------------------------------------------------------------------
if any(numStellarTargets)

    % loop through stellar targets and count pixels
    for i = 1:numStellarTargets

        maskIndex = outputsStruct.stellarTargetDefinitions(i).maskIndex + 1;

        numStellarPixelsInTarget(i) = length(existingMasksTable(maskIndex).offsets);                %#ok<AGROW>
        numExcessStellarPixelInTargets(i)  = outputsStruct.stellarTargetDefinitions(i).excessPixels;       %#ok<AGROW>
    end

    numStellarPixelsTotal    = sum(numStellarPixelsInTarget);
    numStellarPixelsArray    = (numStellarPixelsInTarget)';
    
    numExcessStellarPixelsTotal     = sum(numExcessStellarPixelInTargets);
    numExcessStellarPixelsArray     = (numExcessStellarPixelInTargets)';
    
    %add to output struct
    rptsPixelCountStruct.numStellarPixelsTotal = numStellarPixelsTotal;
    rptsPixelCountStruct.numStellarPixelsArray = numStellarPixelsArray;
    rptsPixelCountStruct.numExcessStellarPixelsTotal  = numExcessStellarPixelsTotal;
    rptsPixelCountStruct.numExcessStellarPixelsArray  = numExcessStellarPixelsArray;
    
else
    numStellarPixelsTotal = 0;   %set here for concatenation at end of function
    numStellarPixelsArray = 0;
    numExcessStellarPixelsTotal  = 0;
    numExcessStellarPixelsArray  = 0;
    
    %add to output struct
    rptsPixelCountStruct.numStellarPixelsTotal = numStellarPixelsTotal;
    rptsPixelCountStruct.numStellarPixelsArray = numStellarPixelsArray;
    rptsPixelCountStruct.numExcessStellarPixelsTotal  = numExcessStellarPixelsTotal;
    rptsPixelCountStruct.numExcessStellarPixelsArray  = numExcessStellarPixelsArray;
end


%--------------------------------------------------------------------------
% count the number of total pixels for dynamic range targets
%--------------------------------------------------------------------------
if any(numDynamicRangeTargets)

    % loop through dynamic range targets and count pixels
    for i = 1:numDynamicRangeTargets

        maskIndex = outputsStruct.dynamicRangeTargetDefinitions(i).maskIndex + 1;

        numDynamicRangePixelsInTarget(i) = length(existingMasksTable(maskIndex).offsets);                 %#ok<AGROW>
        numExcessDynRangePixelInTargets(i)       = outputsStruct.dynamicRangeTargetDefinitions(i).excessPixels;   %#ok<AGROW>
    end


    numDynamicRangePixelsTotal    = sum(numDynamicRangePixelsInTarget);
    numDynamicRangePixelsArray    = (numDynamicRangePixelsInTarget)';
    
    numExcessDynRangePixelsTotal     = sum(numExcessDynRangePixelInTargets);
    numExcessDynRangePixelsArray     = (numExcessDynRangePixelInTargets)';
    
    %add to output struct
    rptsPixelCountStruct.numDynamicRangePixelsTotal = numDynamicRangePixelsTotal;
    rptsPixelCountStruct.numDynamicRangePixelsArray = numDynamicRangePixelsArray;
    rptsPixelCountStruct.numExcessDynRangePixelsTotal  = numExcessDynRangePixelsTotal;
    rptsPixelCountStruct.numExcessDynRangePixelsArray  = numExcessDynRangePixelsArray;
    
else
    numDynamicRangePixelsTotal = 0;   %set here for concatenation at end of function
    numDynamicRangePixelsArray = 0;
    numExcessDynRangePixelsTotal       = 0;
    numExcessDynRangePixelsArray       = 0;
    
    %add to output struct
    rptsPixelCountStruct.numDynamicRangePixelsTotal = numDynamicRangePixelsTotal;
    rptsPixelCountStruct.numDynamicRangePixelsArray = numDynamicRangePixelsArray;
    rptsPixelCountStruct.numExcessDynRangePixelsTotal  = numExcessDynRangePixelsTotal;
    rptsPixelCountStruct.numExcessDynRangePixelsArray  = numExcessDynRangePixelsArray;
end


%--------------------------------------------------------------------------
% count the number of pixels for the targets with supermasks
%--------------------------------------------------------------------------
numBkgdPixels = numBkgdTargets * length(outputsStruct.backgroundMaskDefinition.offsets); % numBkgdTargets=1
rptsPixelCountStruct.numBkgdTargets = numBkgdTargets;

numMaskedSmearPixels    = numMaskedSmearTargets * length([outputsStruct.smearMaskDefinition.offsets]);
rptsPixelCountStruct.numMaskedSmearPixels = numMaskedSmearPixels;

numVirtualSmearPixels   = numVirtualSmearTargets * length([outputsStruct.smearMaskDefinition.offsets]);
rptsPixelCountStruct.numVirtualSmearPixels = numVirtualSmearPixels;

numMaskedAndSmearPixels  = numMaskedAndVirtualSmearTargets * length([outputsStruct.smearMaskDefinition.offsets]);
%rptsPixelCountStruct.numMaskedAndSmearPixels = numMaskedAndSmearPixels;

numBlackPixels = numBlackTargets * length([outputsStruct.blackMaskDefinition.offsets]);
rptsPixelCountStruct.numBlackPixels = numBlackPixels;


% TARGET COUNT
%--------------------------------------------------------------------------
% count the number of total targets
%--------------------------------------------------------------------------
numTotalTargets = sum([numStellarTargets ...
    numDynamicRangeTargets ...
    numBkgdTargets ...
    numVirtualSmearTargets ...
    numMaskedSmearTargets ...
    numBlackTargets]);

rptsPixelCountStruct.numTotalTargets = numTotalTargets;


%--------------------------------------------------------------------------
% count the number of total photometric targets
%--------------------------------------------------------------------------
numTotalPhotometricTargets = sum([numStellarTargets ...
    numDynamicRangeTargets]);

rptsPixelCountStruct.numTotalPhotometricTargets = numTotalPhotometricTargets;


%--------------------------------------------------------------------------
% record the number of total collateral targets (should = 4)
%--------------------------------------------------------------------------
numTotalCollateralTargets = sum([numBkgdTargets ...
    numVirtualSmearTargets ...
    numMaskedSmearTargets ...
    numBlackTargets]);

rptsPixelCountStruct.numTotalCollateralTargets = numTotalCollateralTargets;


% PIXEL COUNT
%--------------------------------------------------------------------------
% count the number of total (photometric+collateral) pixels
%--------------------------------------------------------------------------
numTotalPixels = sum([numStellarPixelsTotal ...
    numDynamicRangePixelsTotal ...
    numBkgdPixels ...
    numMaskedAndSmearPixels ...
    numBlackPixels]);

rptsPixelCountStruct.numTotalPixels = numTotalPixels;


%--------------------------------------------------------------------------
% count the number of total photometric pixels
%--------------------------------------------------------------------------
numTotalPhotometricPixels = sum([numStellarPixelsTotal ...
    numDynamicRangePixelsTotal]);

rptsPixelCountStruct.numTotalPhotometricPixels = numTotalPhotometricPixels;


%--------------------------------------------------------------------------
% count the number of total collateral pixels
%--------------------------------------------------------------------------
numTotalCollateralPixels = sum([numBkgdPixels ...
    numMaskedAndSmearPixels numBlackPixels]);

rptsPixelCountStruct.numTotalCollateralPixels = numTotalCollateralPixels;


%--------------------------------------------------------------------------
% record the number of photometric pixels for each target (1D array)
%--------------------------------------------------------------------------
numPhotometricPixelsArray = numStellarPixelsArray + numDynamicRangePixelsArray;

rptsPixelCountStruct.numPhotometricPixelsArray = numPhotometricPixelsArray;


%--------------------------------------------------------------------------
% count the number of excess photometric pixels
%--------------------------------------------------------------------------
numExcessPhotometricPixelsTotal = sum([numExcessStellarPixelsTotal  numExcessDynRangePixelsTotal]);

rptsPixelCountStruct.numExcessPhotometricPixelsTotal = numExcessPhotometricPixelsTotal;


%--------------------------------------------------------------------------
% record the number of excess photometric pixels for each target (1D array)
%--------------------------------------------------------------------------
numExcessPhotometricPixelsArray = numExcessStellarPixelsArray + numExcessDynRangePixelsArray;
    
rptsPixelCountStruct.numExcessPhotometricPixelsArray = numExcessPhotometricPixelsArray;


return;

