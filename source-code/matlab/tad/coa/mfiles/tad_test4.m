% close all;
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
clear;
% clear classes;

% module = 3;
% output = 3;

% Q4 test where there is a big difference in zodi across FOV
% quarter = 4;
% % max zodi, mag 19.744
% module = 20;
% output = 3;

% min zodi, mag 20.1307
% module = 6;
% output = 3;

% Q6 test where there is a small difference in zodi across FOV
% tests effect of crowding
% quarter = 6;
% % max zodi, mag 20.3052
% module = 10;
% output = 1;

% min zodi, mag 20.3411
% module = 16;
% output = 1;

% test of 13.2 to hold constant PRF and crowding
% max zodi, mag 19.9243
quarter = 15;
% module = 16;
% output = 3;
module = 2;
output = 1;

% min zodi, mag 20.339
% quarter = 7;quit
% module = 13;
% output = 1;


season = mod(quarter+2,4) + 1;
load /path/to/steve_utilities/dateStruct;
qDateStruct = dateStruct(quarter+2);

startMjd = qDateStruct.startMjd + 1;
endMjd = qDateStruct.endMjd - 1;
startTime = mjd_to_utc(startMjd);
duration = endMjd - startMjd; % day

load /path/to/false_positives/hires_catalog/latestCleanKic.mat;

raDec2PixModel = retrieve_ra_dec_2_pix_model();
raDec2PixObject = raDec2PixClass(raDec2PixModel, 'zero-based');
% get the corners of the channel
cr = 500;
cc = 500;
[cRa cDec] = pix_2_ra_dec(raDec2PixObject, ...
	repmat(module, size(cr)), repmat(output, size(cr)), cr, cc, startMjd);

rad = sqrt(2)*600*4/3600; % to corner of a 600 pixel box in degrees
onChannel = find(abs(kic.ra-cRa/15) < rad/15/cos(cDec/180*pi) & abs(kic.dec-cDec) < rad);

ra = kic.ra(onChannel);
dec = kic.dec(onChannel);
kicId = kic.kepid(onChannel);
keplerMagnitude = kic.kepmag(onChannel);

nanMag = isnan(keplerMagnitude);
ra(nanMag) = [];
dec(nanMag) = [];
kicId(nanMag) = [];
keplerMagnitude(nanMag) = [];

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
% targetIndex = find(([kicEntryDataStruct.magnitude] < 13) & ...
%     ([kicEntryDataStruct.magnitude] >= 12.8));
targetIndex = find([kicEntryDataStruct.magnitude] < 14);
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
coaConfigurationStruct.motionPolynomialsEnabled = false;
coaConfigurationStruct.backgroundPolynomialsEnabled = false;

coaParameterStruct.spacecraftConfigurationStruct.millisecondsPerReadout = 518.9500;
coaParameterStruct.spacecraftConfigurationStruct.millisecondsPerFgsFrame = 103.79;
coaParameterStruct.spacecraftConfigurationStruct.fgsFramesPerIntegration = 59;
coaParameterStruct.spacecraftConfigurationStruct.integrationsPerShortCadence = 9;
coaParameterStruct.spacecraftConfigurationStruct.shortCadencesPerLongCadence = 30;

coaParameterStruct.kicEntryDataStruct = kicEntryDataStruct;
coaParameterStruct.targetKeplerIDList = targetKeplerIDList;
prfModel = retrieve_prf_model(module, output);
coaParameterStruct.prfBlob = struct_to_blob(prfModel.blob);
coaParameterStruct.coaConfigurationStruct = coaConfigurationStruct;
coaParameterStruct.raDec2PixModel = retrieve_ra_dec_2_pix_model(); 
coaParameterStruct.readNoiseModel = retrieve_read_noise_model(startMjd, endMjd); 
coaParameterStruct.gainModel = retrieve_gain_model(startMjd, endMjd); 
coaParameterStruct.twoDBlackModel = retrieve_two_d_black_model(module, output); 
coaParameterStruct.linearityModel = retrieve_linearity_model(startMjd, endMjd, module, output); 
coaParameterStruct.undershootModel = retrieve_undershoot_model(); 
coaParameterStruct.flatFieldModel = retrieve_flat_field_model(module, output); 
coaParameterStruct.fcConstants = convert_fc_constants_java_2_struct(); 
coaParameterStruct.saturationModel = retrieve_saturation_model(season, module, output);
% coaParameterStruct.saturationModel = [];
coaParameterStruct.motionBlobs = []; 
coaParameterStruct.backgroundBlobs = []; 
coaParameterStruct.startTime = startTime;
coaParameterStruct.duration = duration;
coaParameterStruct.module = module;
coaParameterStruct.output = output;
% coaParameterStruct.k2StartMjd = datestr2mjd('1 Aug 2008');

%%
% close all
% clear classes
% load tadTestInputs2
% clear amtParameterStruct maskTableParameterStruct amaParameterStruct amtResultStruct coaResultStruct
%%
coaParameterStruct.debugFlag = 0;
coaParameterStruct.coaConfigurationStruct.saturationSpillBufferSize = 0.75;
% coaParameterStruct.raDec2PixModel.spiceFileDir = '/path/to/spice';
coaResultStruct = coa_matlab_controller(coaParameterStruct);


