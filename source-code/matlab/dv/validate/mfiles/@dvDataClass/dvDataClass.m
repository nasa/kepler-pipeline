function [dvDataObject] = dvDataClass(dvDataStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Constructor [dvDataObject] = dvDataClass(dvDataStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% dvDataClass.m - Class Constructor
%
% This method orders the fields in the input data structure and then
% implements the constructor for the dvDataClass. It is assumed that the
% inputs have been validated before this constructor is invoked.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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

% If no input, generate an error.
if nargin == 0
    error('DV:dvDataClass:EmptyInputStruct', ...
        'The constructor must be called with an input structure');
end
    
% Order the fields to avoid getting error messages like:
%   Error using ==> class 
%   Field names and parent classes for class dvDataClass cannot be
%   changed without clear classes
dvDataStruct = orderfields(dvDataStruct);

dvDataStruct.fcConstants = ...
    orderfields(dvDataStruct.fcConstants);

% These are ordered in update_dv_inputs.
% dvDataStruct.configMaps = ...
%     orderfields(dvDataStruct.configMaps);
% nMaps = length(dvDataStruct.configMaps);
% for i = 1 : nMaps
%     dvDataStruct.configMaps(i).entries = ...
%         orderfields(dvDataStruct.configMaps(i).entries);
% end

% Don't order the fields in the raDec2PixModel, it creates problems down
% the line when raDec2Pix objects are instantiated.
% dvDataStruct.raDec2PixModel = ...
%     orderfields(dvDataStruct.raDec2PixModel);
% dvDataStruct.raDec2PixModel.geometryModel = ...
%     orderfields(dvDataStruct.raDec2PixModel.geometryModel);
% dvDataStruct.raDec2PixModel.pointingModel = ...
%     orderfields(dvDataStruct.raDec2PixModel.pointingModel);
% dvDataStruct.raDec2PixModel.rollTimeModel = ...
%     orderfields(dvDataStruct.raDec2PixModel.rollTimeModel);

if ~isempty(dvDataStruct.prfModels)
    dvDataStruct.prfModels = orderfields(dvDataStruct.prfModels);
    for i = 1 : length(dvDataStruct.prfModels)
        dvDataStruct.prfModels(i).fcModelMetadata = ...
            orderfields(dvDataStruct.prfModels(i).fcModelMetadata);
    end
end

dvDataStruct.dvCadenceTimes = ...
    orderfields(dvDataStruct.dvCadenceTimes);
dvDataStruct.dvCadenceTimes.dataAnomalyFlags = ...
    orderfields(dvDataStruct.dvCadenceTimes.dataAnomalyFlags);

dvDataStruct.barycentricCadenceTimes = ...
    orderfields(dvDataStruct.barycentricCadenceTimes);

dvDataStruct.dvConfigurationStruct = ...
    orderfields(dvDataStruct.dvConfigurationStruct);

dvDataStruct.fluxTypeConfigurationStruct = ...
    orderfields(dvDataStruct.fluxTypeConfigurationStruct);

dvDataStruct.planetFitConfigurationStruct = ...
    orderfields(dvDataStruct.planetFitConfigurationStruct);

dvDataStruct.trapezoidalFitConfigurationStruct = ...
    orderfields(dvDataStruct.trapezoidalFitConfigurationStruct);

dvDataStruct.centroidTestConfigurationStruct = ...
    orderfields(dvDataStruct.centroidTestConfigurationStruct);

dvDataStruct.pixelCorrelationConfigurationStruct = ...
    orderfields(dvDataStruct.pixelCorrelationConfigurationStruct);

dvDataStruct.differenceImageConfigurationStruct = ...
    orderfields(dvDataStruct.differenceImageConfigurationStruct);

dvDataStruct.bootstrapConfigurationStruct = ...
    orderfields(dvDataStruct.bootstrapConfigurationStruct);

dvDataStruct.ancillaryEngineeringConfigurationStruct = ...
    orderfields(dvDataStruct.ancillaryEngineeringConfigurationStruct);

dvDataStruct.ancillaryPipelineConfigurationStruct = ...
    orderfields(dvDataStruct.ancillaryPipelineConfigurationStruct);

dvDataStruct.ancillaryDesignMatrixConfigurationStruct = ...
    orderfields(dvDataStruct.ancillaryDesignMatrixConfigurationStruct);

dvDataStruct.gapFillConfigurationStruct = ...
    orderfields(dvDataStruct.gapFillConfigurationStruct);

dvDataStruct.pdcConfigurationStruct = ...
    orderfields(dvDataStruct.pdcConfigurationStruct);

dvDataStruct.saturationSegmentConfigurationStruct = ...
    orderfields(dvDataStruct.saturationSegmentConfigurationStruct);

dvDataStruct.tpsHarmonicsIdentificationConfigurationStruct = ...
    orderfields(dvDataStruct.tpsHarmonicsIdentificationConfigurationStruct);

dvDataStruct.pdcHarmonicsIdentificationConfigurationStruct = ...
    orderfields(dvDataStruct.pdcHarmonicsIdentificationConfigurationStruct);

dvDataStruct.tpsConfigurationStruct = ...
    orderfields(dvDataStruct.tpsConfigurationStruct);

if ~isempty(dvDataStruct.kics)
    dvDataStruct.kics = orderfields(dvDataStruct.kics);
    for i = 1 : length(dvDataStruct.kics)
        dvDataStruct.kics(i).keplerMag = ...
            orderfields(dvDataStruct.kics(i).keplerMag);
        dvDataStruct.kics(i).ra = ...
            orderfields(dvDataStruct.kics(i).ra);
        dvDataStruct.kics(i).dec = ...
            orderfields(dvDataStruct.kics(i).dec);
        dvDataStruct.kics(i).radius = ...
            orderfields(dvDataStruct.kics(i).radius);
        dvDataStruct.kics(i).effectiveTemp = ...
            orderfields(dvDataStruct.kics(i).effectiveTemp);
        dvDataStruct.kics(i).log10SurfaceGravity = ...
            orderfields(dvDataStruct.kics(i).log10SurfaceGravity);
        dvDataStruct.kics(i).log10Metallicity = ...
            orderfields(dvDataStruct.kics(i).log10Metallicity);
        dvDataStruct.kics(i).raProperMotion = ...
            orderfields(dvDataStruct.kics(i).raProperMotion);
        dvDataStruct.kics(i).decProperMotion = ...
            orderfields(dvDataStruct.kics(i).decProperMotion);
        dvDataStruct.kics(i).totalProperMotion = ...
            orderfields(dvDataStruct.kics(i).totalProperMotion);
        dvDataStruct.kics(i).parallax = ...
            orderfields(dvDataStruct.kics(i).parallax);
        dvDataStruct.kics(i).uMag = ...
            orderfields(dvDataStruct.kics(i).uMag);
        dvDataStruct.kics(i).gMag = ...
            orderfields(dvDataStruct.kics(i).gMag);
        dvDataStruct.kics(i).rMag = ...
            orderfields(dvDataStruct.kics(i).rMag);
        dvDataStruct.kics(i).iMag = ...
            orderfields(dvDataStruct.kics(i).iMag);
        dvDataStruct.kics(i).zMag = ...
            orderfields(dvDataStruct.kics(i).zMag);
        dvDataStruct.kics(i).gredMag = ...
            orderfields(dvDataStruct.kics(i).gredMag);
        dvDataStruct.kics(i).d51Mag = ...
            orderfields(dvDataStruct.kics(i).d51Mag);
        dvDataStruct.kics(i).twoMassId = ...
            orderfields(dvDataStruct.kics(i).twoMassId);
        dvDataStruct.kics(i).twoMassJMag = ...
            orderfields(dvDataStruct.kics(i).twoMassJMag);
        dvDataStruct.kics(i).twoMassHMag = ...
            orderfields(dvDataStruct.kics(i).twoMassHMag);
        dvDataStruct.kics(i).twoMassKMag = ...
            orderfields(dvDataStruct.kics(i).twoMassKMag);
        dvDataStruct.kics(i).scpId = ...
            orderfields(dvDataStruct.kics(i).scpId);
        dvDataStruct.kics(i).internalScpId = ...
            orderfields(dvDataStruct.kics(i).internalScpId);
        dvDataStruct.kics(i).catalogId = ...
            orderfields(dvDataStruct.kics(i).catalogId);
        dvDataStruct.kics(i).alternateId = ...
            orderfields(dvDataStruct.kics(i).alternateId);
        dvDataStruct.kics(i).alternateSource = ...
            orderfields(dvDataStruct.kics(i).alternateSource);
        dvDataStruct.kics(i).galaxyIndicator = ...
            orderfields(dvDataStruct.kics(i).galaxyIndicator);
        dvDataStruct.kics(i).blendIndicator = ...
            orderfields(dvDataStruct.kics(i).blendIndicator);
        dvDataStruct.kics(i).variableIndicator = ...
            orderfields(dvDataStruct.kics(i).variableIndicator);
        dvDataStruct.kics(i).ebMinusVRedding = ...
            orderfields(dvDataStruct.kics(i).ebMinusVRedding);
        dvDataStruct.kics(i).avExtinction = ...
            orderfields(dvDataStruct.kics(i).avExtinction);
        dvDataStruct.kics(i).photometryQuality = ...
            orderfields(dvDataStruct.kics(i).photometryQuality);
        dvDataStruct.kics(i).astrophysicsQuality = ...
            orderfields(dvDataStruct.kics(i).astrophysicsQuality);
        dvDataStruct.kics(i).galacticLatitude = ...
            orderfields(dvDataStruct.kics(i).galacticLatitude);
        dvDataStruct.kics(i).galacticLongitude = ...
            orderfields(dvDataStruct.kics(i).galacticLongitude);
        dvDataStruct.kics(i).grColor = ...
            orderfields(dvDataStruct.kics(i).grColor);
        dvDataStruct.kics(i).jkColor = ...
            orderfields(dvDataStruct.kics(i).jkColor);
        dvDataStruct.kics(i).gkColor = ...
            orderfields(dvDataStruct.kics(i).gkColor);
    end
end

if isfield(dvDataStruct, 'randStreamStruct')
    dvDataStruct.randStreamStruct = ...
        orderfields(dvDataStruct.randStreamStruct);
end

dvDataStruct.targetTableDataStruct = ...
    orderfields(dvDataStruct.targetTableDataStruct);
nTables = length(dvDataStruct.targetTableDataStruct);
for i = 1 : nTables
    if ~isempty(dvDataStruct.targetTableDataStruct(i).ancillaryPipelineDataStruct)
        dvDataStruct.targetTableDataStruct(i).ancillaryPipelineDataStruct = ...
            orderfields(dvDataStruct.targetTableDataStruct(i).ancillaryPipelineDataStruct);
    end
    if isfield(dvDataStruct.targetTableDataStruct(i), 'backgroundBlobs') && ...
            ~isempty(dvDataStruct.targetTableDataStruct(i).backgroundBlobs)
        dvDataStruct.targetTableDataStruct(i).backgroundBlobs = ...
            orderfields(dvDataStruct.targetTableDataStruct(i).backgroundBlobs);
    end
    if isfield(dvDataStruct.targetTableDataStruct(i), 'motionBlobs') && ...
            ~isempty(dvDataStruct.targetTableDataStruct(i).motionBlobs)
        dvDataStruct.targetTableDataStruct(i).motionBlobs = ...
            orderfields(dvDataStruct.targetTableDataStruct(i).motionBlobs);
    end
    if ~isempty(dvDataStruct.targetTableDataStruct(i).motionPolyStruct)
        dvDataStruct.targetTableDataStruct(i).motionPolyStruct = ...
            orderfields(dvDataStruct.targetTableDataStruct(i).motionPolyStruct);
    end
    nStructures = length(dvDataStruct.targetTableDataStruct(i).motionPolyStruct);
    for j = 1 : nStructures
        dvDataStruct.targetTableDataStruct(i).motionPolyStruct(j).rowPoly = ...
            orderfields(dvDataStruct.targetTableDataStruct(i).motionPolyStruct(j).rowPoly);
        dvDataStruct.targetTableDataStruct(i).motionPolyStruct(j).colPoly = ...
            orderfields(dvDataStruct.targetTableDataStruct(i).motionPolyStruct(j).colPoly);
    end
end
    
dvDataStruct.targetStruct = ...
    orderfields(dvDataStruct.targetStruct);
nTargets = length(dvDataStruct.targetStruct);
for i = 1 : nTargets
    if ~isempty(dvDataStruct.targetStruct(i).transits)
        dvDataStruct.targetStruct(i).transits = ...
            orderfields(dvDataStruct.targetStruct(i).transits);
    end
    dvDataStruct.targetStruct(i).raHours = ...
        orderfields(dvDataStruct.targetStruct(i).raHours);
    dvDataStruct.targetStruct(i).decDegrees = ...
        orderfields(dvDataStruct.targetStruct(i).decDegrees);
    dvDataStruct.targetStruct(i).keplerMag = ...
        orderfields(dvDataStruct.targetStruct(i).keplerMag);
    dvDataStruct.targetStruct(i).radius = ...
        orderfields(dvDataStruct.targetStruct(i).radius);
    dvDataStruct.targetStruct(i).effectiveTemp = ...
        orderfields(dvDataStruct.targetStruct(i).effectiveTemp);
    dvDataStruct.targetStruct(i).log10SurfaceGravity = ...
        orderfields(dvDataStruct.targetStruct(i).log10SurfaceGravity);
    dvDataStruct.targetStruct(i).log10Metallicity = ...
        orderfields(dvDataStruct.targetStruct(i).log10Metallicity);
    dvDataStruct.targetStruct(i).rawFluxTimeSeries = ...
        orderfields(dvDataStruct.targetStruct(i).rawFluxTimeSeries);
    dvDataStruct.targetStruct(i).correctedFluxTimeSeries = ...
        orderfields(dvDataStruct.targetStruct(i).correctedFluxTimeSeries);
    dvDataStruct.targetStruct(i).outliers = ...
        orderfields(dvDataStruct.targetStruct(i).outliers);
    dvDataStruct.targetStruct(i).centroids = ...
        orderfields(dvDataStruct.targetStruct(i).centroids);
    dvDataStruct.targetStruct(i).centroids.prfCentroids = ...
        orderfields(dvDataStruct.targetStruct(i).centroids.prfCentroids);
    dvDataStruct.targetStruct(i).centroids.fluxWeightedCentroids = ...
        orderfields(dvDataStruct.targetStruct(i).centroids.fluxWeightedCentroids);
    dvDataStruct.targetStruct(i).centroids.prfCentroids.rowTimeSeries = ...
        orderfields(dvDataStruct.targetStruct(i).centroids.prfCentroids.rowTimeSeries);
    dvDataStruct.targetStruct(i).centroids.prfCentroids.columnTimeSeries = ...
        orderfields(dvDataStruct.targetStruct(i).centroids.prfCentroids.columnTimeSeries);
    dvDataStruct.targetStruct(i).centroids.fluxWeightedCentroids.rowTimeSeries = ...
        orderfields(dvDataStruct.targetStruct(i).centroids.fluxWeightedCentroids.rowTimeSeries);
    dvDataStruct.targetStruct(i).centroids.fluxWeightedCentroids.columnTimeSeries = ...
        orderfields(dvDataStruct.targetStruct(i).centroids.fluxWeightedCentroids.columnTimeSeries);
    dvDataStruct.targetStruct(i).thresholdCrossingEvent = ...
        orderfields(dvDataStruct.targetStruct(i).thresholdCrossingEvent);
    nTces = length(dvDataStruct.targetStruct(i).thresholdCrossingEvent);
    for j = 1 : nTces
        dvDataStruct.targetStruct(i).thresholdCrossingEvent(j).weakSecondaryStruct = ...
            orderfields(dvDataStruct.targetStruct(i).thresholdCrossingEvent(j).weakSecondaryStruct);
        dvDataStruct.targetStruct(i).thresholdCrossingEvent(j).weakSecondaryStruct.depthPpm = ...
            orderfields(dvDataStruct.targetStruct(i).thresholdCrossingEvent(j).weakSecondaryStruct.depthPpm);
    end
    if ~isempty(dvDataStruct.targetStruct(i).targetDataStruct)
        dvDataStruct.targetStruct(i).targetDataStruct = ...
            orderfields(dvDataStruct.targetStruct(i).targetDataStruct);
    end
    if ~isempty(dvDataStruct.targetStruct(i).rollingBandContaminationStruct)
        dvDataStruct.targetStruct(i).rollingBandContaminationStruct = ...
            orderfields(dvDataStruct.targetStruct(i).rollingBandContaminationStruct);
    end
    nPulses = length(dvDataStruct.targetStruct(i).rollingBandContaminationStruct);
    for j = 1 : nPulses
        dvDataStruct.targetStruct(i).rollingBandContaminationStruct(j).severityFlags = ...
            orderfields(dvDataStruct.targetStruct(i).rollingBandContaminationStruct(j).severityFlags);
    end
end

% Now create the dvDataClass object.
dvDataObject = class(dvDataStruct, 'dvDataClass');

% Return.
return
