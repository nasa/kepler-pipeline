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
close all;
clear;
clear classes;

module = 3;
output = 3;
startTime = '1-May-2009';
duration = 1; % day
startMjd = datestr2mjd(startTime);
endMjd = startMjd + duration;

kicData = retrieve_kics(module, output, datestr2mjd(startTime));
nKicEntries = length(kicData);
for i=1:nKicEntries
    if ~isempty(kicData(i).getKeplerMag())
		ra(i) = double(kicData(i).getRa());
		dec(i) = double(kicData(i).getDec());
		kicId(i) = double(kicData(i).getKeplerId());
		keplerMagnitude(i) = double(kicData(i).getKeplerMag());
	end
end

nStars = length(kicId);
range = 1:nStars;
% nStars = 5000;
% range = fix(length(kicId)*rand(nStars,1))+1;
%%
kicEntryDataStruct = struct('KICID', num2cell(kicId(range)), ...
    'RA', num2cell(ra(range)), 'dec', num2cell(dec(range)),...
    'magnitude', num2cell(single(keplerMagnitude(range))), ...
    'effectiveTemp', num2cell(single(5000*ones(size(kicId(range))))));

% pick the brightest 2000 stars as targets
targetIndex = find(([kicEntryDataStruct.magnitude] < 15) & ...
    ([kicEntryDataStruct.magnitude] >= 4));
targetKeplerIDList = [kicEntryDataStruct(targetIndex).KICID]';

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
coaConfigurationStruct.saturationSpillBufferSize = .5;

% load the desired prf and turn it into a blob
% p = load('/path/to/matlab/tad/coa/PRFpolys_z1f1_4.mat');
% prfPolyStruct = p(1,1).polys;
% coaParameterStruct.prfBlob = struct_to_blob(prfPolyStruct);

% fid = fopen('/path/to/matlab/tad/coa/prfBlob_z1f1_4.dat');
% fid = fopen('/path/to/ETEM_PSFs/all_blobs/prf101-2008032321.dat');
% filename = sprintf('/path/to/prfBlobs/kplr2008102115-%02d%d_prf.bin', module, output);
% filename = sprintf('/path/to/prf/v6/kplr2008081921-%02d%d_prf.bin', module, output);
filename = sprintf('/path/to/prf/v7/kplr2008102115-%02d%d_prf.bin', module, output);
fid = fopen(filename);

prfBlob = fread(fid, 'uint8');
% prf = blob_to_struct(prfBlob);
% for i=1:5
%     prfCollection(i).polyStruct = prf;
% end
% prfBlob = struct_to_blob(prfCollection);

coaParameterStruct.spacecraftConfigurationStruct.millisecondsPerReadout = 518.9500;
coaParameterStruct.spacecraftConfigurationStruct.millisecondsPerFgsFrame = 103.79;
coaParameterStruct.spacecraftConfigurationStruct.fgsFramesPerIntegration = 59;
coaParameterStruct.spacecraftConfigurationStruct.integrationsPerShortCadence = 9;
coaParameterStruct.spacecraftConfigurationStruct.shortCadencesPerLongCadence = 30;

coaParameterStruct.kicEntryDataStruct = kicEntryDataStruct;
coaParameterStruct.targetKeplerIDList = targetKeplerIDList;
coaParameterStruct.prfBlob = prfBlob;
coaParameterStruct.coaConfigurationStruct = coaConfigurationStruct;
coaParameterStruct.raDec2PixModel = retrieve_ra_dec_2_pix_model(); 
coaParameterStruct.readNoiseModel = retrieve_read_noise_model(startMjd, endMjd); 
coaParameterStruct.gainModel = retrieve_gain_model(startMjd, endMjd); 
coaParameterStruct.twoDBlackModel = retrieve_two_d_black_model(module, output); 
coaParameterStruct.linearityModel = retrieve_linearity_model(startMjd, endMjd, module, output); 
coaParameterStruct.undershootModel = retrieve_undershoot_model(); 
coaParameterStruct.flatFieldModel = retrieve_flat_field_model(module, output); 
coaParameterStruct.fcConstants = convert_fc_constants_java_2_struct(); 
coaParameterStruct.startTime = startTime;
coaParameterStruct.duration = duration;
coaParameterStruct.module = module;
coaParameterStruct.output = output;

fclose(fid);

%%
% close all
% clear classes
% load tadTestInputs2
% clear amtParameterStruct maskTableParameterStruct amaParameterStruct amtResultStruct coaResultStruct
%%
coaParameterStruct.debugFlag = 1;
coaParameterStruct.coaConfigurationStruct.saturationSpillBufferSize = 0.75;

% coaParameterStruct.raDec2PixModel.spiceFileDir = '/path/to/spice';
coaResultStruct = coa_matlab_controller(coaParameterStruct);

%% set up ama
load maskDefinitions_mag9_1halo.mat
% maskTableParametersStruct = maskTableParameterStruct;
amaParameterStruct.maskDefinitions = maskDefinitions;
amaParameterStruct.maskTableParametersStruct = maskTableParametersStruct;

amaParameterStruct.apertureStructs = coaResultStruct.optimalApertures;
amaParameterStruct.apertureStructs = rmfield(amaParameterStruct.apertureStructs, ...
    {'signalToNoiseRatio', 'crowdingMetric', 'fluxFractionInAperture', 'distanceFromEdge'});
for i=1:length(amaParameterStruct.apertureStructs)
	amaParameterStruct.apertureStructs(i).custom = 0;
	amaParameterStruct.apertureStructs(i).labels = [];
end

amaParameterStruct.fcConstants = coaParameterStruct.fcConstants; 
amaParameterStruct.amaConfigurationStruct.defaultStellarLabels ...
	= {'TAD_ONE_HALO', 'TAD_ADD_UNDERSHOOT_COLUMN'};
amaParameterStruct.amaConfigurationStruct.defaultCustomLabels ...
	= {'TAD_NO_HALO', 'TAD_NO_UNDERSHOOT_COLUMN'};
amaParameterStruct.debugFlag = 1;

%% create custom targets
custom_tdefs
customKeplerIdStart = 1e9;
nAps = length(amaParameterStruct.apertureStructs);
customTargetNum = 1;
amaParameterStruct.apertureStructs(nAps+customTargetNum).keplerId ...
	= customKeplerIdStart + customTargetNum;
amaParameterStruct.apertureStructs(nAps+customTargetNum).referenceRow ...
	= 535;
amaParameterStruct.apertureStructs(nAps+customTargetNum).referenceColumn ...
	= 566;
amaParameterStruct.apertureStructs(nAps+customTargetNum).badPixelCount ...
	= 0;
amaParameterStruct.apertureStructs(nAps+customTargetNum).offsets ...
	= arpTargetDefinition.offsets;
amaParameterStruct.apertureStructs(nAps+customTargetNum).custom = 1;
amaParameterStruct.apertureStructs(nAps+customTargetNum).labels ...
	= {'TAD_DEDICATED_MASK', 'TAD_NO_HALO', 'TAD_NO_UNDERSHOOT_COLUMN'};
	
customTargetNum = customTargetNum + 1;
amaParameterStruct.apertureStructs(nAps+customTargetNum).keplerId ...
	= customKeplerIdStart + customTargetNum;
amaParameterStruct.apertureStructs(nAps+customTargetNum).referenceRow ...
	= 200;
amaParameterStruct.apertureStructs(nAps+customTargetNum).referenceColumn ...
	= 300;
amaParameterStruct.apertureStructs(nAps+customTargetNum).badPixelCount ...
	= 0;
amaParameterStruct.apertureStructs(nAps+customTargetNum).offsets ...
	= customTargetDefinition1.offsets;
amaParameterStruct.apertureStructs(nAps+customTargetNum).custom = 1;
amaParameterStruct.apertureStructs(nAps+customTargetNum).labels ...
	= {'TAD_DEDICATED_MASK', 'TAD_NO_HALO', 'TAD_NO_UNDERSHOOT_COLUMN'};
	
customTargetNum = customTargetNum + 1;
amaParameterStruct.apertureStructs(nAps+customTargetNum).keplerId ...
	= customKeplerIdStart + customTargetNum;
amaParameterStruct.apertureStructs(nAps+customTargetNum).referenceRow ...
	= 260;
amaParameterStruct.apertureStructs(nAps+customTargetNum).referenceColumn ...
	= 700;
amaParameterStruct.apertureStructs(nAps+customTargetNum).badPixelCount ...
	= 0;
amaParameterStruct.apertureStructs(nAps+customTargetNum).offsets ...
	= customTargetDefinition1.offsets;
amaParameterStruct.apertureStructs(nAps+customTargetNum).custom = 1;
amaParameterStruct.apertureStructs(nAps+customTargetNum).labels ...
	= {'TAD_DEDICATED_MASK', 'TAD_NO_HALO', 'TAD_NO_UNDERSHOOT_COLUMN'};
	
customTargetNum = customTargetNum + 1;
amaParameterStruct.apertureStructs(nAps+customTargetNum).keplerId ...
	= customKeplerIdStart + customTargetNum;
amaParameterStruct.apertureStructs(nAps+customTargetNum).referenceRow ...
	= 900;
amaParameterStruct.apertureStructs(nAps+customTargetNum).referenceColumn ...
	= 700;
amaParameterStruct.apertureStructs(nAps+customTargetNum).badPixelCount ...
	= 0;
amaParameterStruct.apertureStructs(nAps+customTargetNum).offsets ...
	= customTargetDefinition1.offsets;
amaParameterStruct.apertureStructs(nAps+customTargetNum).custom = 1;
amaParameterStruct.apertureStructs(nAps+customTargetNum).labels ...
	= {'TAD_NO_HALO', 'TAD_NO_UNDERSHOOT_COLUMN'};
	
customTargetNum = customTargetNum + 1;
amaParameterStruct.apertureStructs(nAps+customTargetNum).keplerId ...
	= customKeplerIdStart + customTargetNum;
amaParameterStruct.apertureStructs(nAps+customTargetNum).referenceRow ...
	= 600;
amaParameterStruct.apertureStructs(nAps+customTargetNum).referenceColumn ...
	= 600;
amaParameterStruct.apertureStructs(nAps+customTargetNum).badPixelCount ...
	= 0;
amaParameterStruct.apertureStructs(nAps+customTargetNum).offsets ...
	= customTargetDefinition2.offsets;
amaParameterStruct.apertureStructs(nAps+customTargetNum).custom = 1;
amaParameterStruct.apertureStructs(nAps+customTargetNum).labels ...
	= {'TAD_DEDICATED_MASK', 'TAD_NO_HALO', 'TAD_NO_UNDERSHOOT_COLUMN'};
	
customTargetNum = customTargetNum + 1;
amaParameterStruct.apertureStructs(nAps+customTargetNum).keplerId ...
	= customKeplerIdStart + customTargetNum;
amaParameterStruct.apertureStructs(nAps+customTargetNum).referenceRow ...
	= 700;
amaParameterStruct.apertureStructs(nAps+customTargetNum).referenceColumn ...
	= 900;
amaParameterStruct.apertureStructs(nAps+customTargetNum).badPixelCount ...
	= 0;
amaParameterStruct.apertureStructs(nAps+customTargetNum).offsets ...
	= customTargetDefinition2.offsets;
amaParameterStruct.apertureStructs(nAps+customTargetNum).custom = 1;
amaParameterStruct.apertureStructs(nAps+customTargetNum).labels ...
	= {'TAD_DEDICATED_MASK', 'TAD_NO_HALO', 'TAD_NO_UNDERSHOOT_COLUMN'};

customTargetNum = customTargetNum + 1;
amaParameterStruct.apertureStructs(nAps+customTargetNum).keplerId ...
	= customKeplerIdStart + customTargetNum;
amaParameterStruct.apertureStructs(nAps+customTargetNum).referenceRow ...
	= 300;
amaParameterStruct.apertureStructs(nAps+customTargetNum).referenceColumn ...
	= 300;
amaParameterStruct.apertureStructs(nAps+customTargetNum).badPixelCount ...
	= 0;
amaParameterStruct.apertureStructs(nAps+customTargetNum).offsets ...
	= customTargetDefinition2.offsets;
amaParameterStruct.apertureStructs(nAps+customTargetNum).custom = 1;
amaParameterStruct.apertureStructs(nAps+customTargetNum).labels ...
	= {'TAD_NO_HALO', 'TAD_NO_UNDERSHOOT_COLUMN'};

%% test ama

amaResultStruct = ama_matlab_controller(amaParameterStruct);
show_ama(amaResultStruct.targetDefinitions, amaResultStruct.maskDefinitions, ...
    struct_to_array2D(coaResultStruct.completeOutputImage), amaParameterStruct.apertureStructs, 100);

amaParameterStruct
amaResultStruct

targetDefIds = [amaResultStruct.targetDefinitions.keplerId];
duplicateIndices = find(diff(targetDefIds) == 0);
dupTargetDefIds = targetDefIds(duplicateIndices);
[tf, dupApertureIndices] = ismember(dupTargetDefIds, [amaParameterStruct.apertureStructs.keplerId]);


