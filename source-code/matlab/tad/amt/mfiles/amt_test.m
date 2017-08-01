% this script tests aperture mask table creation with the default set of
% configuration parameters.  
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

% close all;
% clear;
% clear classes;
% 
% coaResultStruct = read_CoaOutputs('/path/to/java/tad/coa/outputs-7-success.bin');
%load coaResultStruct_m18o1.mat
%apertures = coaResultStruct.optimalApertures;
%apertures = rmfield(apertures, 'signalToNoiseRatio');
%apertures = rmfield(apertures, 'crowdingMetric');

% build_ama_inputs_from_coa_outputs;
load ../../coa/mfiles/coaResultStruct_m22o2.mat
load ../../coa/mfiles/coaParameterStruct_m22o2.mat

amaParameterStruct.maskDefinitions = [];
amaParameterStruct.apertureStructs = coaResultStruct.optimalApertures;
amaParameterStruct.apertureStructs = rmfield(amaParameterStruct.apertureStructs, ...
    {'signalToNoiseRatio', 'crowdingMetric', 'fluxFractionInAperture', 'distanceFromEdge'});

amaParameterStruct.fcConstants = coaParameterStruct.fcConstants; 
% amaParameterStruct.fcConstants = convert_fc_constants_java_2_struct(); 

amaParameterStruct.debugFlag = 1;
amtParameterStruct.maskDefinitions = [];
amtParameterStruct.apertureStructs = amaParameterStruct.apertureStructs;
amtParameterStruct.fcConstants = amaParameterStruct.fcConstants;
amtParameterStruct.amaConfigurationStruct = amaParameterStruct.amaConfigurationStruct;
%amtParameterStruct.apertureStructs = apertures;
amtParameterStruct.amtConfigurationStruct.maxMasks = single(970);
amtParameterStruct.amtConfigurationStruct.maxPixelsInMask = single(85);
amtParameterStruct.amtConfigurationStruct.maxMaskRows = single(11);
amtParameterStruct.amtConfigurationStruct.maxMaskCols = single(11);
amtParameterStruct.amtConfigurationStruct.centerRow = single(6);
amtParameterStruct.amtConfigurationStruct.centerCol = single(6);
amtParameterStruct.amtConfigurationStruct.minEccentricity = single(0.4);
amtParameterStruct.amtConfigurationStruct.maxEccentricity = single(0.9);
amtParameterStruct.amtConfigurationStruct.stepEccentricity = single(0.1);
amtParameterStruct.amtConfigurationStruct.stepInclination = single(pi/6);
amtParameterStruct.amtConfigurationStruct.maxPixelsInSmallMask = single(75); % include buffer to allow large masks
amtParameterStruct.amtConfigurationStruct.nNestedBoxes = single(5); % include buffer to allow large masks
amtParameterStruct.amtConfigurationStruct.maxMaskHeight = single(100); % include buffer to allow large masks
amtParameterStruct.amtConfigurationStruct.maxMaskWidth = single(22); % include buffer to allow large masks
amtParameterStruct.debugFlag = 1;

amtResultStruct = amt_matlab_controller(amtParameterStruct);

amaParameterStruct.maskDefinitions = amtResultStruct.maskDefinitions;
amaResultStruct = ama_matlab_controller(amaParameterStruct);
show_ama(amaResultStruct.targetDefinitions, amaParameterStruct.maskDefinitions, ...
    struct_to_array2D(coaResultStruct.completeOutputImage), amaParameterStruct.apertureStructs);

amaParameterStruct
amaResultStruct

targetDefIds = [amaResultStruct.targetDefinitions.keplerId];
duplicateIndices = find(diff(targetDefIds) == 0);
dupTargetDefIds = targetDefIds(duplicateIndices);
[tf, dupApertureIndices] = ismember(dupTargetDefIds, [amaParameterStruct.apertureStructs.keplerId]);

