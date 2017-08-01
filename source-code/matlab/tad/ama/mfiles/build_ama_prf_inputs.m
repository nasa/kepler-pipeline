% script to build PRF ama inputs and ETEM tad file
% 
% Copyright 2017 United States Government as represented by the
% Administrator of the National Aeronautics and Space Administration.
% All Rights Reserved.
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

load ../../coa/mfiles/prfCoaData_m14o1.mat
module = coaInputStruct.module;
output = coaInputStruct.output;

% identify targets with the required crowding metric
crowdingCutoff = 0.9;
optAps = coaResultStruct.optimalApertures;
crowdingMetric = [optAps.crowdingMetric];
notCrowded = find(crowdingMetric > crowdingCutoff);

coaResultStruct.optimalApertures = coaResultStruct.optimalApertures(notCrowded);

load amaStructs.mat
amaParameterStruct.maskDefinitions = amaIs.maskDefinitions;
% choose targets that are not crowded
amaParameterStruct.apertureStructs = coaResultStruct.optimalApertures;
amaParameterStruct.apertureStructs = rmfield(amaParameterStruct.apertureStructs, ...
    {'signalToNoiseRatio', 'crowdingMetric', 'fluxFractionInAperture'});

amaParameterStruct.moduleDescriptionStruct.nrowPix = coaInputStruct.fcConstants.nRowsImaging;
amaParameterStruct.moduleDescriptionStruct.nColPix = coaInputStruct.fcConstants.nColsImaging;
amaParameterStruct.moduleDescriptionStruct.leadingBlack = coaInputStruct.fcConstants.nLeadingBlack;
amaParameterStruct.moduleDescriptionStruct.trailingBlack = coaInputStruct.fcConstants.nTrailingBlack;
amaParameterStruct.moduleDescriptionStruct.virtualSmear = coaInputStruct.fcConstants.nVirtualSmear;
amaParameterStruct.moduleDescriptionStruct.maskedSmear = coaInputStruct.fcConstants.nMaskedSmear;

amaParameterStruct.debugFlag = 1;

amaResultStruct = ama_matlab_controller(amaParameterStruct);

% we also have to run bpa

bpaParameterStruct.moduleOutputImage = coaResultStruct.completeOutputImage; % the full image for this module output
bpaParameterStruct.bpaConfigurationStruct.lineStartRow = coaResultStruct.minRow; % will be set by other parts of TAD
bpaParameterStruct.bpaConfigurationStruct.lineEndRow = coaResultStruct.maxRow;
bpaParameterStruct.bpaConfigurationStruct.lineStartCol = coaResultStruct.minCol;
bpaParameterStruct.bpaConfigurationStruct.lineEndCol = coaResultStruct.maxCol;
bpaParameterStruct.bpaConfigurationStruct.nLinesRow = 31;
bpaParameterStruct.bpaConfigurationStruct.nLinesCol = 36; % nLinesRow*nLinesCol should match numBackgroundApertures
bpaParameterStruct.bpaConfigurationStruct.nEdge = 6; % # of point in edge region: 2*nEdge + ncenter = nlines
bpaParameterStruct.bpaConfigurationStruct.edgeFraction = 1/10; % fractional size of hi-res edge
bpaParameterStruct.bpaConfigurationStruct.histBinSize = 100; % 

bpaParameterStruct.debugFlag = 1;

bpaResultStruct = bpa_matlab_controller(bpaParameterStruct);

tadInputStruct.targetDefinitions = amaResultStruct.targetDefinitions;
tadInputStruct.maskDefinitions = amaParameterStruct.maskDefinitions;
tadInputStruct.backgroundTargetDefinitions = bpaResultStruct.targetDefinitions;
tadInputStruct.backgroundMaskDefinitions = bpaResultStruct.maskDefinitions;
tadInputStruct.coaResultStruct = coaResultStruct;

save(['prf_tadInputStruct_m' num2str(module) 'o' num2str(output) '.mat'], 'tadInputStruct');
