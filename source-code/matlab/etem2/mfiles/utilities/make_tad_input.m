function make_tad_input(outputFilename, catalogData, targetKeplerIDList, runParamsObject)
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

debugFlag = 0;

kicEntryDataStruct = struct('KICID', num2cell(catalogData.kicId), ...
    'RA', num2cell(catalogData.ra/15), 'dec', num2cell(catalogData.dec),...
    'magnitude', num2cell(catalogData.keplerMagnitude), ...
    'effectiveTemp', num2cell(single(5000*ones(size(catalogData.kicId)))));

wellCapacity = get(runParamsObject, 'wellCapacity');
numAtoDBits = get(runParamsObject, 'numAtoDBits');
exposuresPerCadence = get(runParamsObject, 'exposuresPerCadence');

pixelModelStruct.exposuresPerCadence = exposuresPerCadence;
pixelModelStruct.wellCapacity = get(runParamsObject, 'wellCapacity');
pixelModelStruct.saturationSpillUpFraction = get(runParamsObject, 'saturationSpillUpFraction');
pixelModelStruct.flux12 = get(runParamsObject, 'fluxOfMag12Star');
pixelModelStruct.cadenceTime = get(runParamsObject, 'cadenceDuration');
pixelModelStruct.integrationTime = get(runParamsObject, 'integrationTime');
pixelModelStruct.transferTime = get(runParamsObject, 'transferTime');
pixelModelStruct.parallelCTE = get(runParamsObject, 'parallelCTE');
pixelModelStruct.serialCTE = get(runParamsObject, 'serialCTE');

pixelModelStruct.readNoiseSquared ...
    = get(runParamsObject, 'readNoise')^2 * exposuresPerCadence; % e-^2/long cadence
pixelModelStruct.quantizationNoiseSquared ...
    = ( wellCapacity / (2^numAtoDBits-1))^2 / 12 * exposuresPerCadence; % e-^2/long cadence

coaConfigurationStruct.dvaMeshEdgeBuffer = -1; % how close to the edge of a CCD we compute the dva
coaConfigurationStruct.dvaMeshOrder = 3; % order of the polynomial fit to dva mesh
coaConfigurationStruct.nDvaMeshRows = 5; % size of the mesh on which to compute DVA
coaConfigurationStruct.nDvaMeshCols = 5; % size of the mesh on which to compute DVA
coaConfigurationStruct.nOutputBufferPix = 2; % # of pixels to allow off visible ccd
coaConfigurationStruct.nStarImageRows = 21; % rows in each star image
coaConfigurationStruct.nStarImageCols = 21; % columns in each star image
coaConfigurationStruct.starChunkLength = 5000; % # of stars to process at a time
coaConfigurationStruct.startTime = get(runParamsObject, 'runStartDate');
coaConfigurationStruct.duration = get(runParamsObject, 'runDurationDays');

coaParameterStruct.kicEntryDataStruct = kicEntryDataStruct;
coaParameterStruct.targetKeplerIDList = targetKeplerIDList;
coaParameterStruct.pixelModelStruct = pixelModelStruct;
coaParameterStruct.coaConfigurationStruct = coaConfigurationStruct;
coaParameterStruct.module = get(runParamsObject, 'moduleNumber');
coaParameterStruct.output = get(runParamsObject, 'outputNumber');
fid = fopen('/path/to/matlab/tad/coa/prfBlob_z1f1_4.dat');
coaParameterStruct.prfBlob = fread(fid, 'uint8');

coaParameterStruct.debugFlag = debugFlag;

coaResultStruct = coa_matlab_controller(coaParameterStruct);

apertures = coaResultStruct.optimalApertures;
apertures = rmfield(apertures, 'SNR');
apertures = rmfield(apertures, 'crowdingMetric');
apertures = rmfield(apertures, 'fluxFractionInAperture');

load('configuration_files/maskDefinitions.mat');

amaParameterStruct.maskDefinitions = maskDefinitions;
amaParameterStruct.apertureStructs = apertures;
amaParameterStruct.amaConfigurationStruct.useHaloApertures = 1;
amaParameterStruct.debugFlag = debugFlag;

amaResultStruct = ama_matlab_controller(amaParameterStruct);

bpaParameterStruct.moduleOutputImage = coaResultStruct.completeOutputImage; % the full image for this module output
bpaParameterStruct.bpaConfigurationStruct.lineStartRow = coaResultStruct.minRow; % will be set by other parts of TAD
bpaParameterStruct.bpaConfigurationStruct.lineEndRow = coaResultStruct.maxRow;
bpaParameterStruct.bpaConfigurationStruct.lineStartCol = coaResultStruct.minCol;
bpaParameterStruct.bpaConfigurationStruct.lineEndCol = coaResultStruct.maxCol;
bpaParameterStruct.bpaConfigurationStruct.nLinesRow = 25;
bpaParameterStruct.bpaConfigurationStruct.nLinesCol = 45; % nLinesRow*nLinesCol should match numBackgroundApertures
bpaParameterStruct.bpaConfigurationStruct.nEdge = 6; % # of point in edge region: 2*nEdge + ncenter = nlines
bpaParameterStruct.bpaConfigurationStruct.edgeFraction = 1/10; % fractional size of hi-res edge
bpaParameterStruct.bpaConfigurationStruct.histBinSize = 100; % 

bpaParameterStruct.debugFlag = debugFlag;

bpaResultStruct = bpa_matlab_controller(bpaParameterStruct);

save(outputFilename, 'coaResultStruct', 'amaResultStruct', 'bpaResultStruct');

