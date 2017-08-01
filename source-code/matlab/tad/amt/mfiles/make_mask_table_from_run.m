% script to process monster tad run result to make mask table
% load ama-inputs-0.mat
% load maskDefinitions_mag9_1halo_test3.mat
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

% % call amt to perform optimization
% maskTableParametersStruct.nStellarMasks = 732;
% maskTableParametersStruct.nAssignedCustomMasks = 20;
% maskTableParametersStruct.nLargeMasks = 20;

amtParameterStruct.maskDefinitions = [];
amtParameterStruct.apertureStructs = inputsStruct.apertureStructs;
% amtParameterStruct.apertureStructs = rmfield(amtParameterStruct.apertureStructs, ...
%     {'signalToNoiseRatio', 'crowdingMetric', 'fluxFractionInAperture', 'distanceFromEdge'});
% for i=1:length(amtParameterStruct.apertureStructs)
% 	amtParameterStruct.apertureStructs(i).custom = 0;
% 	amtParameterStruct.apertureStructs(i).labels = [];
% end
amtParameterStruct.fcConstants = inputsStruct.fcConstants;
amtParameterStruct.amaConfigurationStruct.defaultStellarLabels = {'TAD_ONE_HALO', 'TAD_ADD_UNDERSHOOT_COLUMN'};
amtParameterStruct.amaConfigurationStruct.defaultCustomLabels = {'TAD_NO_HALO', 'TAD_NO_UNDERSHOOT_COLUMN'};
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
amtParameterStruct.debugFlag = 1;

amtParameterStruct.maskTableParametersStruct = maskTableParametersStruct;

amtResultStruct = amt_matlab_controller(amtParameterStruct);

save amtResultStruct.mat amtResultStruct
