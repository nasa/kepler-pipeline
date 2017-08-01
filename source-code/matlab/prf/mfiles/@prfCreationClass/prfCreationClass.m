function prfCreationObject = prfCreationClass(prfCreationData)

% prf_input_validation.m
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

% This is an auto-generated script. Modify if needed.
%------------------------------------------------------------
fieldsAndBounds = cell(17,4);
fieldsAndBounds(1,:)  = { 'ccdModule'; '>=2'; '<=24'; []};
fieldsAndBounds(2,:)  = { 'ccdOutput'; '>=1'; '<=4'; []};
fieldsAndBounds(3,:)  = { 'startCadence'; '>=0'; []; []};
fieldsAndBounds(4,:)  = { 'endCadence'; '>=0'; []; []};
fieldsAndBounds(5,:)  = { 'fcConstants'; []; []; []};
fieldsAndBounds(6,:)  = { 'calUncertaintyBlobsStruct'; []; []; []};
fieldsAndBounds(7,:)  = { 'configMaps'; []; []; []};
fieldsAndBounds(8,:)  = { 'prfConfigurationStruct'; []; []; []};
fieldsAndBounds(9,:)  = { 'pouConfigurationStruct'; []; []; []};
fieldsAndBounds(10,:)  = { 'motionConfigurationStruct'; []; []; []};
fieldsAndBounds(11,:)  = { 'raDec2PixModel'; []; []; []};
fieldsAndBounds(12,:)  = { 'spacecraftAttitudeStruct'; []; []; []};
fieldsAndBounds(13,:)  = { 'cadenceTimes'; []; []; []};
fieldsAndBounds(14,:)  = { 'backgroundBlobsStruct'; []; []; []};
fieldsAndBounds(15,:)  = { 'fpgGeometryBlobsStruct'; []; []; []};
fieldsAndBounds(16,:)  = { 'targetStarsStruct'; []; []; []};
fieldsAndBounds(17,:)  = { 'previousCentroids'; []; []; []};

validate_structure(prfCreationData, fieldsAndBounds,'prfCreationData');

clear fieldsAndBounds;
%------------------------------------------------------------
fieldsAndBounds = cell(5,4);
fieldsAndBounds(1,:)  = { 'blobIndices'; []; []; []};
fieldsAndBounds(2,:)  = { 'gapIndicators'; []; []; []};
fieldsAndBounds(3,:)  = { 'blobFilenames'; []; []; []};
fieldsAndBounds(4,:)  = { 'startCadence'; []; []; []};
fieldsAndBounds(5,:)  = { 'endCadence'; []; []; []};

validate_structure(prfCreationData.calUncertaintyBlobsStruct, fieldsAndBounds,'prfCreationData.calUncertaintyBlobsStruct');

clear fieldsAndBounds;
%------------------------------------------------------------
fieldsAndBounds = cell(3,4);
fieldsAndBounds(1,:)  = { 'id'; []; []; []};
fieldsAndBounds(2,:)  = { 'time'; []; []; []};
fieldsAndBounds(3,:)  = { 'entries'; []; []; []};

validate_structure(prfCreationData.configMaps, fieldsAndBounds,'prfCreationData.configMaps');

clear fieldsAndBounds;
%------------------------------------------------------------
fieldsAndBounds = cell(2,4);
fieldsAndBounds(1,:)  = { 'mnemonic'; []; []; []};
fieldsAndBounds(2,:)  = { 'value'; []; []; []};

nStructures = length(prfCreationData.configMaps.entries);

for j = 1:nStructures
	validate_structure(prfCreationData.configMaps.entries(j), fieldsAndBounds,'prfCreationData.configMaps.entries');
end

clear fieldsAndBounds;
%------------------------------------------------------------
fieldsAndBounds = cell(37,4);
fieldsAndBounds(1,:)  = { 'numPrfsPerChannel'; '>=1'; '<=5'; []};
fieldsAndBounds(2,:)  = { 'prfOverlap'; '>=0'; []; []};
fieldsAndBounds(3,:)  = { 'subPixelRowResolution'; '>=2'; '<=10'; []};
fieldsAndBounds(4,:)  = { 'subPixelColumnResolution'; '>=2'; '<=10'; []};
fieldsAndBounds(5,:)  = { 'pixelArrayRowSize'; '>=2'; '<=15'; []};
fieldsAndBounds(6,:)  = { 'pixelArrayColumnSize'; '>=2'; '<=15'; []};
fieldsAndBounds(7,:)  = { 'maximumPolyOrder'; '>=0'; '<=20'; []};
fieldsAndBounds(8,:)  = { 'minimumMagnitudePrf1'; '>=1'; '<=20'; []};
fieldsAndBounds(9,:)  = { 'minimumMagnitudePrf2'; '>=1'; '<=20'; []};
fieldsAndBounds(10,:)  = { 'minimumMagnitudePrf3'; '>=1'; '<=20'; []};
fieldsAndBounds(11,:)  = { 'minimumMagnitudePrf4'; '>=1'; '<=20'; []};
fieldsAndBounds(12,:)  = { 'minimumMagnitudePrf5'; '>=1'; '<=20'; []};
fieldsAndBounds(13,:)  = { 'maximumMagnitudePrf1'; '>=1'; '<=20'; []};
fieldsAndBounds(14,:)  = { 'maximumMagnitudePrf2'; '>=1'; '<=20'; []};
fieldsAndBounds(15,:)  = { 'maximumMagnitudePrf3'; '>=1'; '<=20'; []};
fieldsAndBounds(16,:)  = { 'maximumMagnitudePrf4'; '>=1'; '<=20'; []};
fieldsAndBounds(17,:)  = { 'maximumMagnitudePrf5'; '>=1'; '<=20'; []};
fieldsAndBounds(18,:)  = { 'crowdingThresholdPrf1'; '>=0'; '<=1'; []};
fieldsAndBounds(19,:)  = { 'crowdingThresholdPrf2'; '>=0'; '<=1'; []};
fieldsAndBounds(20,:)  = { 'crowdingThresholdPrf3'; '>=0'; '<=1'; []};
fieldsAndBounds(21,:)  = { 'crowdingThresholdPrf4'; '>=0'; '<=1'; []};
fieldsAndBounds(22,:)  = { 'crowdingThresholdPrf5'; '>=0'; '<=1'; []};
fieldsAndBounds(23,:)  = { 'contourCutoffPrf1'; '>=0'; '<=1'; []};
fieldsAndBounds(24,:)  = { 'contourCutoffPrf2'; '>=0'; '<=1'; []};
fieldsAndBounds(25,:)  = { 'contourCutoffPrf3'; '>=0'; '<=1'; []};
fieldsAndBounds(26,:)  = { 'contourCutoffPrf4'; '>=0'; '<=1'; []};
fieldsAndBounds(27,:)  = { 'contourCutoffPrf5'; '>=0'; '<=1'; []};
fieldsAndBounds(28,:)  = { 'prfPolynomialType'; []; []; []};
fieldsAndBounds(29,:)  = { 'debugLevel'; []; []; []};
fieldsAndBounds(30,:)  = { 'rowLimit'; '>=1'; '<=1070'; []};
fieldsAndBounds(31,:)  = { 'columnLimit'; '>=1'; '<=1132'; []};
fieldsAndBounds(32,:)  = { 'regionMinSize'; '>0'; '<=1132'; []};
fieldsAndBounds(33,:)  = { 'regionStepSize'; '>1e-8'; '<1e3'; []};
fieldsAndBounds(34,:)  = { 'minStars'; '>=1'; '<=1e5'; []};
fieldsAndBounds(35,:)  = { 'baseAttitudeIndex'; '>0'; '<1e6'; []};
fieldsAndBounds(36,:)  = { 'centroidChangeThreshold'; '>=0'; '<=1e6'; []};
fieldsAndBounds(37,:)  = { 'reportEnable'; []; []; []};

validate_structure(prfCreationData.prfConfigurationStruct, fieldsAndBounds,'prfCreationData.prfConfigurationStruct');

clear fieldsAndBounds;
%------------------------------------------------------------
fieldsAndBounds = cell(8,4);
fieldsAndBounds(1,:)  = { 'pouEnabled'; []; []; []};
fieldsAndBounds(2,:)  = { 'compressionEnabled'; []; []; []};
fieldsAndBounds(3,:)  = { 'numErrorPropVars'; []; []; []};
fieldsAndBounds(4,:)  = { 'maxSvdOrder'; []; []; []};
fieldsAndBounds(5,:)  = { 'pixelChunkSize'; []; []; []};
fieldsAndBounds(6,:)  = { 'cadenceChunkSize'; []; []; []};
fieldsAndBounds(7,:)  = { 'interpDecimation'; []; []; []};
fieldsAndBounds(8,:)  = { 'interpMethod'; []; []; []};

validate_structure(prfCreationData.pouConfigurationStruct, fieldsAndBounds,'prfCreationData.pouConfigurationStruct');

clear fieldsAndBounds;
%------------------------------------------------------------
fieldsAndBounds = cell(5,4);
fieldsAndBounds(1,:)  = { 'aicOrderSelectionEnabled'; []; []; []};
fieldsAndBounds(2,:)  = { 'fitMaxOrder'; []; []; []};
fieldsAndBounds(3,:)  = { 'rowFitOrder'; []; []; []};
fieldsAndBounds(4,:)  = { 'columnFitOrder'; []; []; []};
fieldsAndBounds(5,:)  = { 'fitMinPoints'; []; []; []};

validate_structure(prfCreationData.motionConfigurationStruct, fieldsAndBounds,'prfCreationData.motionConfigurationStruct');

clear fieldsAndBounds;
%------------------------------------------------------------
fieldsAndBounds = cell(19,4);
fieldsAndBounds(1,:)  = { 'spiceFileDir'; []; []; []};
fieldsAndBounds(2,:)  = { 'spiceSpacecraftEphemerisFilename'; []; []; []};
fieldsAndBounds(3,:)  = { 'planetaryEphemerisFilename'; []; []; []};
fieldsAndBounds(4,:)  = { 'leapSecondFilename'; []; []; []};
fieldsAndBounds(5,:)  = { 'mjdStart'; []; []; []};
fieldsAndBounds(6,:)  = { 'mjdEnd'; []; []; []};
fieldsAndBounds(7,:)  = { 'pointingModel'; []; []; []};
fieldsAndBounds(8,:)  = { 'geometryModel'; []; []; []};
fieldsAndBounds(9,:)  = { 'rollTimeModel'; []; []; []};
fieldsAndBounds(10,:)  = { 'HALF_OFFSET_MODULE_ANGLE_DEGREES'; []; []; []};
fieldsAndBounds(11,:)  = { 'OUTPUTS_PER_ROW'; []; []; []};
fieldsAndBounds(12,:)  = { 'OUTPUTS_PER_COLUMN'; []; []; []};
fieldsAndBounds(13,:)  = { 'nRowsImaging'; []; []; []};
fieldsAndBounds(14,:)  = { 'nColsImaging'; []; []; []};
fieldsAndBounds(15,:)  = { 'nMaskedSmear'; []; []; []};
fieldsAndBounds(16,:)  = { 'nLeadingBlack'; []; []; []};
fieldsAndBounds(17,:)  = { 'NOMINAL_CLOCKING_ANGLE'; []; []; []};
fieldsAndBounds(18,:)  = { 'nModules'; []; []; []};
fieldsAndBounds(19,:)  = { 'mjdOffset'; []; []; []};

validate_structure(prfCreationData.raDec2PixModel, fieldsAndBounds,'prfCreationData.raDec2PixModel');

clear fieldsAndBounds;
%------------------------------------------------------------
fieldsAndBounds = cell(3,4);
fieldsAndBounds(1,:)  = { 'ra'; []; []; []};
fieldsAndBounds(2,:)  = { 'dec'; []; []; []};
fieldsAndBounds(3,:)  = { 'roll'; []; []; []};

validate_structure(prfCreationData.spacecraftAttitudeStruct, fieldsAndBounds,'prfCreationData.spacecraftAttitudeStruct');

clear fieldsAndBounds;
%------------------------------------------------------------
fieldsAndBounds = cell(3,4);
fieldsAndBounds(1,:)  = { 'values'; '>=0'; '<=370'; []};
fieldsAndBounds(2,:)  = { 'uncertainties'; []; []; []};
fieldsAndBounds(3,:)  = { 'gapIndices'; []; []; []};

validate_structure(prfCreationData.spacecraftAttitudeStruct.ra, fieldsAndBounds,'prfCreationData.spacecraftAttitudeStruct.ra');

clear fieldsAndBounds;
%------------------------------------------------------------
fieldsAndBounds = cell(3,4);
fieldsAndBounds(1,:)  = { 'values'; '>=0'; '<=70'; []};
fieldsAndBounds(2,:)  = { 'uncertainties'; []; []; []};
fieldsAndBounds(3,:)  = { 'gapIndices'; []; []; []};

validate_structure(prfCreationData.spacecraftAttitudeStruct.dec, fieldsAndBounds,'prfCreationData.spacecraftAttitudeStruct.dec');

clear fieldsAndBounds;
%------------------------------------------------------------
fieldsAndBounds = cell(3,4);
fieldsAndBounds(1,:)  = { 'values'; '>=-360'; '<=360'; []};
fieldsAndBounds(2,:)  = { 'uncertainties'; []; []; []};
fieldsAndBounds(3,:)  = { 'gapIndices'; []; []; []};

validate_structure(prfCreationData.spacecraftAttitudeStruct.roll, fieldsAndBounds,'prfCreationData.spacecraftAttitudeStruct.roll');

clear fieldsAndBounds;
%------------------------------------------------------------
fieldsAndBounds = cell(6,4);
fieldsAndBounds(1,:)  = { 'startTimestamps'; []; []; []};
fieldsAndBounds(2,:)  = { 'midTimestamps'; []; []; []};
fieldsAndBounds(3,:)  = { 'endTimestamps'; []; []; []};
fieldsAndBounds(4,:)  = { 'gapIndicators'; []; []; []};
fieldsAndBounds(5,:)  = { 'requantEnabled'; []; []; []};
fieldsAndBounds(6,:)  = { 'cadenceNumbers'; []; []; []};

validate_structure(prfCreationData.cadenceTimes, fieldsAndBounds,'prfCreationData.cadenceTimes');

clear fieldsAndBounds;
%------------------------------------------------------------
fieldsAndBounds = cell(5,4);
fieldsAndBounds(1,:)  = { 'blobIndices'; []; []; []};
fieldsAndBounds(2,:)  = { 'gapIndicators'; []; []; []};
fieldsAndBounds(3,:)  = { 'blobFilenames'; []; []; []};
fieldsAndBounds(4,:)  = { 'startCadence'; []; []; []};
fieldsAndBounds(5,:)  = { 'endCadence'; []; []; []};

validate_structure(prfCreationData.backgroundBlobsStruct, fieldsAndBounds,'prfCreationData.backgroundBlobsStruct');

clear fieldsAndBounds;
%------------------------------------------------------------
fieldsAndBounds = cell(5,4);
fieldsAndBounds(1,:)  = { 'blobIndices'; []; []; []};
fieldsAndBounds(2,:)  = { 'gapIndicators'; []; []; []};
fieldsAndBounds(3,:)  = { 'blobFilenames'; []; []; []};
fieldsAndBounds(4,:)  = { 'startCadence'; []; []; []};
fieldsAndBounds(5,:)  = { 'endCadence'; []; []; []};

validate_structure(prfCreationData.fpgGeometryBlobsStruct, fieldsAndBounds,'prfCreationData.fpgGeometryBlobsStruct');

clear fieldsAndBounds;
%------------------------------------------------------------
fieldsAndBounds = cell(10,4);
fieldsAndBounds(1,:)  = { 'keplerId'; []; []; []};
fieldsAndBounds(2,:)  = { 'keplerMag'; '>=0'; '<=25'; []};
fieldsAndBounds(3,:)  = { 'tadCrowdingMetric'; '>=0'; '<=1'; []};
fieldsAndBounds(4,:)  = { 'fluxFractionInAperture'; '>=0'; '<=1'; []};
fieldsAndBounds(5,:)  = { 'ra'; '>=15'; '<=24'; []};
fieldsAndBounds(6,:)  = { 'dec'; '>=30'; '<=70'; []};
fieldsAndBounds(7,:)  = { 'referenceRow'; '>=1'; '<=1070'; []};
fieldsAndBounds(8,:)  = { 'referenceColumn'; '>=1'; '<=1132'; []};
fieldsAndBounds(9,:)  = { 'gapIndices'; []; []; []};
fieldsAndBounds(10,:)  = { 'pixelTimeSeriesStruct'; []; []; []};

nStructures = length(prfCreationData.targetStarsStruct);

for j = 1:nStructures
	validate_structure(prfCreationData.targetStarsStruct(j), fieldsAndBounds,'prfCreationData.targetStarsStruct');
end

clear fieldsAndBounds;
%------------------------------------------------------------
fieldsAndBounds = cell(6,4);
fieldsAndBounds(1,:)  = { 'row'; '>=1'; '<=1070'; []};
fieldsAndBounds(2,:)  = { 'column'; '>=1'; '<=1132'; []};
fieldsAndBounds(3,:)  = { 'values'; '>=-1e9'; '<=1e9'; []};
fieldsAndBounds(4,:)  = { 'uncertainties'; []; []; []};
fieldsAndBounds(5,:)  = { 'gapIndices'; []; []; []};
fieldsAndBounds(6,:)  = { 'isInOptimalAperture'; '>=0'; '<=1'; []};

kStructs = length(prfCreationData.targetStarsStruct);
warningInsteadOfErrorFlag = true;
for i = 1:kStructs
	nStructures = length(prfCreationData.targetStarsStruct(i).pixelTimeSeriesStruct);

	for j = 1:nStructures
		validate_structure(prfCreationData.targetStarsStruct(i).pixelTimeSeriesStruct(j), ...
		fieldsAndBounds,'prfCreationData.targetStarsStruct(i).pixelTimeSeriesStruct', ...
		warningInsteadOfErrorFlag);
	end

end

clear fieldsAndBounds;
%------------------------------------------------------------
fieldsAndBounds = cell(6,4);
fieldsAndBounds(1,:)  = { 'keplerId'; []; []; []};
fieldsAndBounds(2,:)  = { 'rows'; '>=0'; '<=1070'; []};
fieldsAndBounds(3,:)  = { 'rowUncertainties'; []; []; []};
fieldsAndBounds(4,:)  = { 'columns'; '>=0'; '<=1132'; []};
fieldsAndBounds(5,:)  = { 'columnUncertainties'; []; []; []};
fieldsAndBounds(6,:)  = { 'gapIndices'; []; []; []};

nStructures = length(prfCreationData.previousCentroids);

for j = 1:nStructures
	validate_structure(prfCreationData.previousCentroids(j), fieldsAndBounds,'prfCreationData.previousCentroids');
end

clear fieldsAndBounds;
%------------------------------------------------------------

if (~isempty(prfCreationData.fpgGeometryBlobsStruct))
    geometryModelBlobSeries = blobSeriesClass(prfCreationData.fpgGeometryBlobsStruct);
    geometryModel = get_struct_for_cadence(geometryModelBlobSeries, 1);
    prfCreationData.raDec2PixModel.geometryModel = geometryModel.struct;
end

for t=1:length(prfCreationData.targetStarsStruct)
	prfCreationData.targetStarsStruct(t).prfFlux = [];
end

prfCreationData.raDec2PixObject = raDec2PixClass(prfCreationData.raDec2PixModel, 'one-based');
prfCreationData.prfRow = 512;
prfCreationData.prfColumn = 550;

prfCreationObject = class(prfCreationData, 'prfCreationClass');
