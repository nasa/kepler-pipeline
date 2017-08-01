
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

load ETEM2_coaParameterStruct.mat

coaResultStruct = coa_matlab_controller(coaParameterStruct);

apertures = coaResultStruct.optimalApertures;
apertures = rmfield(apertures, 'SNR');
apertures = rmfield(apertures, 'crowdingMetric');

amtParameterStruct.maskDefinitions = [];
% amtParameterStruct.optimalApertureStructs = [];
amtParameterStruct.optimalApertureStructs = apertures;
amtParameterStruct.amtConfigurationStruct.maxMasks = single(1024);
amtParameterStruct.amtConfigurationStruct.maxPixelsInMask = single(85);
amtParameterStruct.amtConfigurationStruct.maxMaskRows = single(11);
amtParameterStruct.amtConfigurationStruct.maxMaskCols = single(11);
amtParameterStruct.amtConfigurationStruct.centerRow = single(6);
amtParameterStruct.amtConfigurationStruct.centerCol = single(6);
amtParameterStruct.amtConfigurationStruct.minEccentricity = single(0.4);
amtParameterStruct.amtConfigurationStruct.maxEccentricity = single(0.9);
amtParameterStruct.amtConfigurationStruct.stepEccentricity = single(0.1);
amtParameterStruct.amtConfigurationStruct.stepInclination = single(pi/6);
amtParameterStruct.amtConfigurationStruct.useHaloApertures = single(1);
amtParameterStruct.debugFlag = 1;

amtResultStruct = amt_matlab_controller(amtParameterStruct);

amaParameterStruct.maskDefinitions = amtResultStruct.maskDefinitions;
amaParameterStruct.apertureStructs = apertures;
amaParameterStruct.useHaloApertures = 1;
amaParameterStruct.debugFlag = 1;

amaResultStruct = ama_matlab_controller(amaParameterStruct);

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

save ETEM2_tad_inputs.mat coaResultStruct amaResultStruct bpaResultStruct amtResultStruct