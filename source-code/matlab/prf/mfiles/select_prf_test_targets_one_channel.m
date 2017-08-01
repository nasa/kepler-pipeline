% script to select PRF test targets
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
smallCatalog = make_small_catalog(14,4);

% magnitudeRange = [12 15];
load /path/to/PRF/PRF_target_selection/selectedKeplerIds.mat
% targetIndices = find(smallCatalog.keplerMagnitude > magnitudeRange(1) ...
%     & smallCatalog.keplerMagnitude < magnitudeRange(2));
targetIndices = ismember(smallCatalog.keplerId, selectedKeplerIds);
targetList = smallCatalog.keplerId(targetIndices);

%%
% do a tad run to get the crowding metric

module = smallCatalog.module;
output = smallCatalog.output;
dateStr = smallCatalog.dateStr;
duration = 5; % days
startMjd = datestr2mjd(dateStr);
endMjd = startMjd + duration;
% set the main defaults
coaParameterStruct.kicEntryDataStruct = [];

% set the catalog
kics = retrieve_kics(module, output, startMjd);
goodEntryCount = 1;
for i=1:length(kics)
    if ~isempty(kics(i).getKeplerId()) && ~isempty(kics(i).getKeplerMag())
        coaParameterStruct.kicEntryDataStruct(goodEntryCount).KICID = double(kics(i).getKeplerId());
        coaParameterStruct.kicEntryDataStruct(goodEntryCount).RA = double(kics(i).getRa());
        coaParameterStruct.kicEntryDataStruct(goodEntryCount).dec = double(kics(i).getDec());
        coaParameterStruct.kicEntryDataStruct(goodEntryCount).magnitude = double(kics(i).getKeplerMag());
        coaParameterStruct.kicEntryDataStruct(goodEntryCount).effectiveTemp = double(kics(i).getEffectiveTemp());
        goodEntryCount = goodEntryCount + 1;
    end
end

% set the target list
coaParameterStruct.targetKeplerIDList = targetList;

% get the appropriate PRF blob
filename = sprintf('/path/to/prf/v7/kplr2008102115-%02d%d_prf.bin', module, output);
disp(filename);

bfid = fopen(filename, 'r');
coaParameterStruct.prfBlob = fread(bfid, inf, 'uint8');
fclose(bfid);

coaConfigurationStruct.dvaMeshEdgeBuffer = -1; % how close to the edge of a CCD we compute the dva
coaConfigurationStruct.dvaMeshOrder = 3; % order of the polynomial fit to dva mesh
coaConfigurationStruct.nDvaMeshRows = 5; % size of the mesh on which to compute DVA
coaConfigurationStruct.nDvaMeshCols = 5; % size of the mesh on which to compute DVA
coaConfigurationStruct.nOutputBufferPix = 2; % # of pixels to allow off visible ccd
coaConfigurationStruct.nStarImageRows = 21; % rows in each star image
coaConfigurationStruct.nStarImageCols = 21; % columns in each star image
coaConfigurationStruct.starChunkLength = 5000; % # of stars to process at a time
coaConfigurationStruct.raOffset = 0;
coaConfigurationStruct.decOffset = 0;
coaConfigurationStruct.phiOffset = 0;

coaParameterStruct.spacecraftConfigurationStruct.millisecondsPerReadout = 518.9500;
coaParameterStruct.spacecraftConfigurationStruct.millisecondsPerFgsFrame = 103.79;
coaParameterStruct.spacecraftConfigurationStruct.fgsFramesPerIntegration = 59;
coaParameterStruct.spacecraftConfigurationStruct.integrationsPerShortCadence = 9;
coaParameterStruct.spacecraftConfigurationStruct.shortCadencesPerLongCadence = 30;

coaParameterStruct.startTime = dateStr;
coaParameterStruct.duration = duration; 
coaParameterStruct.raDec2PixModel = retrieve_ra_dec_2_pix_model(); 
coaParameterStruct.coaConfigurationStruct = coaConfigurationStruct;
coaParameterStruct.readNoiseModel = retrieve_read_noise_model(startMjd, endMjd); 
coaParameterStruct.gainModel = retrieve_gain_model(startMjd, endMjd); 
coaParameterStruct.twoDBlackModel = retrieve_two_d_black_model(module, output); 
coaParameterStruct.linearityModel = retrieve_linearity_model(startMjd, endMjd, module, output); 
coaParameterStruct.undershootModel = retrieve_undershoot_model(); 
coaParameterStruct.flatFieldModel = retrieve_flat_field_model(module, output); 
coaParameterStruct.fcConstants = convert_fc_constants_java_2_struct(); 
coaParameterStruct.module = module; 
coaParameterStruct.output = output; 

coaParameterStruct.debugFlag = 1; 

coaResultStruct = coa_matlab_controller(coaParameterStruct);

%%
% now make the ama input structure

amaParameterStruct.maskDefinitions = [];
amaParameterStruct.apertureStructs = coaResultStruct.optimalApertures;
amaParameterStruct.apertureStructs = rmfield(amaParameterStruct.apertureStructs, ...
    {'SNR', 'crowdingMetric', 'fluxFractionInAperture'});
amaParameterStruct.fcConstants = convert_fc_constants_java_2_struct(); 

amaParameterStruct.amaConfigurationStruct.useHaloApertures = 2;

amaParameterStruct.debugFlag = 1;

% % run amt
% amtParameterStruct.maskDefinitions = [];
% amtParameterStruct.optimalApertureStructs = amaParameterStruct.apertureStructs;
% amtParameterStruct.fcConstants = amaParameterStruct.fcConstants;
% amtParameterStruct.amaConfigurationStruct = amaParameterStruct.amaConfigurationStruct;
% %amtParameterStruct.optimalApertureStructs = apertures;
% amtParameterStruct.amtConfigurationStruct.maxMasks = single(770);
% amtParameterStruct.amtConfigurationStruct.maxPixelsInMask = single(85);
% amtParameterStruct.amtConfigurationStruct.maxMaskRows = single(11);
% amtParameterStruct.amtConfigurationStruct.maxMaskCols = single(11);
% amtParameterStruct.amtConfigurationStruct.centerRow = single(6);
% amtParameterStruct.amtConfigurationStruct.centerCol = single(6);
% amtParameterStruct.amtConfigurationStruct.minEccentricity = single(0.4);
% amtParameterStruct.amtConfigurationStruct.maxEccentricity = single(0.9);
% amtParameterStruct.amtConfigurationStruct.stepEccentricity = single(0.1);
% amtParameterStruct.amtConfigurationStruct.stepInclination = single(pi/6);
% amtParameterStruct.debugFlag = 1;
% 
% amtResultStruct = amt_matlab_controller(amtParameterStruct);
% 
% % run ama with the new mask table
% amaParameterStruct.maskDefinitions = amtResultStruct.maskDefinitions;

% load a good mask table
load /path/to/PRF/PRF_target_selection/tadStruct_v10.mat
amaParameterStruct.maskDefinitions = tadStruct_v10.maskDefinitions;

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
tadInputStruct.refPixelTargetDefinitions(1) = tadInputStruct.targetDefinitions(1);
tadInputStruct.refPixelTargetDefinitions(2) = tadInputStruct.targetDefinitions(2);

save(['prf_tadInputStruct_m' num2str(module) 'o' num2str(output) '.mat'], 'tadInputStruct');
