function prfInputStruct = make_prf_inputs_from_pa(paOutputs, paInputs, fpgOutput, prfExampleInput)
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

startDateMjd = paInputs.cadenceTimes.startTimestamps(1);
endDateMjd = paInputs.cadenceTimes.endTimestamps(end);

prfInputStruct.ccdModule = paInputs.ccdModule;
prfInputStruct.ccdOutput = paInputs.ccdOutput;
prfInputStruct.startCadence = 0;
prfInputStruct.endCadence = length(paOutputs.targetStarResultsStruct(1).fluxTimeSeries(1).values) - 1;
prfInputStruct.fcConstants = convert_fc_constants_java_2_struct();
% prfInputStruct.calUncertaintyBlobsStruct = paOutputs.uncertaintyBlobFileName; % get from fpgOutputs
prfInputStruct.calUncertaintyBlobsStruct.blobIndices = []; % get from paOutputs
prfInputStruct.configMaps = retrieve_config_map(startDateMjd, endDateMjd);

prfInputStruct.prfConfigurationStruct.numPrfsPerChannel = 1;
prfInputStruct.prfConfigurationStruct.prfOverlap = 0.1;
prfInputStruct.prfConfigurationStruct.subPixelRowResolution = 6;
prfInputStruct.prfConfigurationStruct.subPixelColumnResolution = 6;
prfInputStruct.prfConfigurationStruct.pixelArrayRowSize = 11;
prfInputStruct.prfConfigurationStruct.pixelArrayColumnSize = 11;
prfInputStruct.prfConfigurationStruct.maximumPolyOrder = 8;
% prfInputStruct.prfConfigurationStruct.magnitudeRange = [12 13.5];
% prfInputStruct.prfConfigurationStruct.crowdingThreshold = 0.5;
% prfInputStruct.prfConfigurationStruct.contourCutoff = 1e-3;
prfInputStruct.prfConfigurationStruct.minimumMagnitudePrf1 = 12*ones(84,1);
prfInputStruct.prfConfigurationStruct.minimumMagnitudePrf2 = 12*ones(84,1);
prfInputStruct.prfConfigurationStruct.minimumMagnitudePrf3 = 12*ones(84,1);
prfInputStruct.prfConfigurationStruct.minimumMagnitudePrf4 = 12*ones(84,1);
prfInputStruct.prfConfigurationStruct.minimumMagnitudePrf5 = 12*ones(84,1);
prfInputStruct.prfConfigurationStruct.maximumMagnitudePrf1 = 13*ones(84,1);
prfInputStruct.prfConfigurationStruct.maximumMagnitudePrf2 = 13*ones(84,1);
prfInputStruct.prfConfigurationStruct.maximumMagnitudePrf3 = 13*ones(84,1);
prfInputStruct.prfConfigurationStruct.maximumMagnitudePrf4 = 13*ones(84,1);
prfInputStruct.prfConfigurationStruct.maximumMagnitudePrf5 = 13*ones(84,1);
prfInputStruct.prfConfigurationStruct.crowdingThresholdPrf1 = 0.5*ones(84,1);
prfInputStruct.prfConfigurationStruct.crowdingThresholdPrf2 = 0.5*ones(84,1);
prfInputStruct.prfConfigurationStruct.crowdingThresholdPrf3 = 0.5*ones(84,1);
prfInputStruct.prfConfigurationStruct.crowdingThresholdPrf4 = 0.5*ones(84,1);
prfInputStruct.prfConfigurationStruct.crowdingThresholdPrf5 = 0.5*ones(84,1);
prfInputStruct.prfConfigurationStruct.contourCutoffPrf1 = 1e-3*ones(84,1);
prfInputStruct.prfConfigurationStruct.contourCutoffPrf2 = 1e-3*ones(84,1);
prfInputStruct.prfConfigurationStruct.contourCutoffPrf3 = 1e-3*ones(84,1);
prfInputStruct.prfConfigurationStruct.contourCutoffPrf4 = 1e-3*ones(84,1);
prfInputStruct.prfConfigurationStruct.contourCutoffPrf5 = 1e-3*ones(84,1);
prfInputStruct.prfConfigurationStruct.prfPolynomialType = 'not_scaled'; % 'standard' or 'not-scaled'
prfInputStruct.prfConfigurationStruct.debugLevel = 1;
prfInputStruct.prfConfigurationStruct.rowLimit = ...
    prfInputStruct.fcConstants.nMaskedSmear ...
    + [1 prfInputStruct.fcConstants.nRowsImaging];
prfInputStruct.prfConfigurationStruct.columnLimit = ...
    prfInputStruct.fcConstants.nLeadingBlack ...
    + [1 prfInputStruct.fcConstants.nColsImaging];
prfInputStruct.prfConfigurationStruct.regionMinSize = 0.3;
prfInputStruct.prfConfigurationStruct.regionStepSize = 0.05;
prfInputStruct.prfConfigurationStruct.minStars = 10;
prfInputStruct.prfConfigurationStruct.baseAttitudeIndex = 0;
prfInputStruct.prfConfigurationStruct.centroidChangeThreshold = 0.01;
prfInputStruct.prfConfigurationStruct.reportEnable = 0;

prfInputStruct.pouConfigurationStruct.pouEnabled = false;
prfInputStruct.pouConfigurationStruct.compressionEnabled = true;
prfInputStruct.pouConfigurationStruct.numErrorPropVars = 30;
prfInputStruct.pouConfigurationStruct.maxSvdOrder = 10;
prfInputStruct.pouConfigurationStruct.pixelChunkSize = 2500;
prfInputStruct.pouConfigurationStruct.cadenceChunkSize = 240;
prfInputStruct.pouConfigurationStruct.interpDecimation = 24;
prfInputStruct.pouConfigurationStruct.interpMethod = 'linear';

prfInputStruct.motionConfigurationStruct.fitLowOrder = 3;
prfInputStruct.motionConfigurationStruct.aicOrderSelectionEnabled = true;
prfInputStruct.motionConfigurationStruct.fitMaxOrder = 8;
prfInputStruct.motionConfigurationStruct.rowFitOrder = 3;
prfInputStruct.motionConfigurationStruct.columnFitOrder = 3;
prfInputStruct.motionConfigurationStruct.fitMinPoints = 20;

backgroundConfigurationStruct = build_background_configuration_struct();
prfInputStruct.raDec2PixModel = retrieve_ra_dec_2_pix_model();

prfInputStruct.spacecraftAttitudeStruct = fpgOutput.spacecraftAttitudeStruct;
% set the index to the non-dithered cadence, determined by dither pattern

% set times for all cadences and set the gap indicators for the even-indexed ones
% (movement contaminated)
prfInputStruct.cadenceTimes = paInputs.cadenceTimes;

prfInputStruct.backgroundBlobsStruct.blobIndices = zeros(241,1);
prfInputStruct.backgroundBlobsStruct.gapIndicators = false(241,1);
prfInputStruct.backgroundBlobsStruct.blobFilenames = {paOutputs.backgroundBlobFileName};
prfInputStruct.backgroundBlobsStruct.startCadence = 1;
prfInputStruct.backgroundBlobsStruct.endCadence = 241;

prfInputStruct.fpgGeometryBlobsStruct.blobIndices = zeros(241,1);
prfInputStruct.fpgGeometryBlobsStruct.gapIndicators = false(241,1);
prfInputStruct.fpgGeometryBlobsStruct.blobFilenames = {fpgOutput.geometryBlobFileName};
prfInputStruct.fpgGeometryBlobsStruct.startCadence = 1;
prfInputStruct.fpgGeometryBlobsStruct.endCadence = 241;

nCadences = length(paInputs(1).targetStarDataStruct(1).pixelDataStruct(1).values);
gapList = 1:2:(nCadences-1) ; % gap every other cadence, first not gapped

inputTargetStruct = paInputs.targetStarDataStruct;
outputTargetStruct = paOutputs.targetStarResultsStruct;
nTargets = length(inputTargetStruct);
module = paInputs.ccdModule;
output = paInputs.ccdOutput;
tadStruct = retrieve_tad(module, output, 'prf-v3-lc');
optApData = tadStruct.targets;
if length(optApData) ~= length(inputTargetStruct)
    error('tad target data and input target data do not have the same length');
end
% make the targetStarStruct with the fields expected by the old PA
% background routines
for t=1:nTargets
    tadIndex = find([optApData.keplerId] == inputTargetStruct(t).keplerId);
    targetStarStruct(t).keplerId = inputTargetStruct(t).keplerId;
    targetStarStruct(t).keplerMag = inputTargetStruct(t).keplerMag;
    targetStarStruct(t).tadCrowdingMetric = optApData(tadIndex).crowdingMetric;
    targetStarStruct(t).fluxFractionInAperture = inputTargetStruct(t).fluxFractionInAperture;
    targetStarStruct(t).ra = inputTargetStruct(t).raHours;
    targetStarStruct(t).dec = inputTargetStruct(t).decDegrees;
    targetStarStruct(t).referenceRow = inputTargetStruct(t).referenceRow;
    targetStarStruct(t).referenceColumn = inputTargetStruct(t).referenceColumn;
    targetStarStruct(t).gapIndices = gapList;

    % build the pixel time series structure for each target, including dummy vaules for
    % cadences which are motion-contaminated
    pixData = inputTargetStruct(t).pixelDataStruct;
    nPixels = length(pixData);
    for p=1:nPixels
        targetStarStruct(t).pixelTimeSeriesStruct(p).row = pixData(p).ccdRow;
        targetStarStruct(t).pixelTimeSeriesStruct(p).column = pixData(p).ccdColumn;
        targetStarStruct(t).pixelTimeSeriesStruct(p).values = pixData(p).values;
        targetStarStruct(t).pixelTimeSeriesStruct(p).uncertainties = pixData(p).uncertainties;
        targetStarStruct(t).pixelTimeSeriesStruct(p).gapIndices = find(pixData(p).gapIndicators) - 1;
        targetStarStruct(t).pixelTimeSeriesStruct(p).isInOptimalAperture = pixData(p).isInOptimalAperture;
    end
    
    % fill in the input centroids
    previousCentroids(t).keplerId ...
        = targetStarStruct(t).keplerId;
    previousCentroids(t).rows ...
        = outputTargetStruct(t).centroidRowTimeSeries.values;
    previousCentroids(t).rowUncertainties ...
        = outputTargetStruct(t).centroidRowTimeSeries.uncertainties;
    previousCentroids(t).columns ...
        = outputTargetStruct(t).centroidColumnTimeSeries.values;
    previousCentroids(t).columnUncertainties ...
        = outputTargetStruct(t).centroidColumnTimeSeries.uncertainties;
    previousCentroids(t).gapIndices = gapList;
    previousCentroids(t).rows(gapList+1) = 0;
    previousCentroids(t).columns(gapList+1) = 0;
end

prfInputStruct.targetStarsStruct = targetStarStruct;
prfInputStruct.previousCentroids = previousCentroids;
