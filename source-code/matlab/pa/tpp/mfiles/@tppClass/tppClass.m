function tppObject = tppClass(tppInputStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function tppObject = tppClass(tppInputStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% tppInputStruct is a structure with the following fields:
%   .targetStarStruct(): 1D array of structures describing targets that contain
%       at least the following fields:
%       .pixelTimeSeriesStruct() # of pixels x 1 array of structures
%           descrbing pixels that contain the following fields:
%           .timeSeries() # of cadences x 1 array containing pixel brightness
%               time series in electrons.
%           .uncertainties() # of cadences x 1 array containing pixel
%               uncertainty time series.
%           .gapList() # of gaps x 1 array containing the index of gaps in
%               .timeSeries
%           .row row of this pixel
%           .column column of this pixel
%           .isInOptimalAperture flag that when true indicates this pixel is in
%               the target's optimal aperture
%       .referenceRow row relative to which the pixels in the target are
%           located, typically the row of the target centroid
%       .referenceColumn column relative to which the pixels in the target are
%           located, typically the column of the target centroid
%       .gapList() # of gaps x 1 array containing the index of target-level gaps in
%           .targetStarStruct
%   .ancillaryDataStruct(): # of ancillary data fields x 1 array of structures
%       describing ancillary data with at least the following fields:
%       .values() # of cadences x 1 array containing ancillary data
%       .uncertainties() # of cadences x 1 array containing ancillary data
%       	uncertainty time series.
%       .dataGapIndicators() # of cadences x 1 array containing 1 where
%           there are gaps, 0 where there is valid data
%       .timestamps() # of cadences x 1 array giving the time in seconds at
%           which the time series was collected
%       .mnemonic character array containing tne name of this ancillary data
%   .motionPolyStruct(): possibly empty # of cadences array of structures,
%       one for each cadence, containing at least the following fields:
%       .rowCoeff, .columnCoeff: structures describing the row and column
%           motion across the module output as returned by
%           weighted_polyfit2d()
%   .motionGaps(): list of indices into .motionPolyStruct for which the
%       structure may be invalid.  May be empty
%   .backgroundCoeffStruct() 1 x # of cadences array of polynomial
%       coefficient structs as returned by robust_polyfit2d()
%   .backgroundGaps(): list of indices into .backgroundCoeffStruct for which the
%       structure may be invalid.  May be empty
%   .cosmicRayConfigurationStruct: structure containing various
%       configuration values as returned by build_cr_configuration_struct()
%   .backgroundConfigurationStruct: structure containing various
%       configuration values as returned by build_background_configuration_struct()
%   .tppConfigurationStruct structure containing various parameters
%       controlling current tpp run with fields:
%       .startCadence, .endCadence start and end cadence of the current run
%           in absolute cadence coordinates
%       .cadenceType type of cadence: 0 for short cadence, 1 for long
%           cadence
%       .ccdModule the CCD module of the current tpp run
%       .ccdOutput the CCD output channel of the current tpp run
%       .cleanCosmicRays flag to indicate that cosmic rays should be
%           cleaned: 0 => do not perform cosmic ray cleaning, 1 => perform
%           cosmic ray cleaning
%
% output: updates the following fields to each element of targetStarStruct
%   with background-removed data:
%       .pixelTimeSeriesStruct() # of pixels x 1 array of structures
%           descrbing pixels that contain the following fields:
%           .timeSeries() # of cadences x 1 array containing pixel brightness
%               time series.
%           .uncertainties() # of cadences x 1 array containing uncertainty
%               in pixel brightness.
%   The following fields of targetStarStruct are filled in during the
%       operation of TPP:
%       adds to each element of pixelTimeSeriesStruct:
%       .crCleanedSeries() same as field .timeSeries with cosmic rays removed
%           from non-gap entries.
%       .cosmicRayIndices() # of cosmic ray events x 1 array of indices in
%           .crCleanedSeries of cosmic ray events
%       .cosmicRayDeltas() array of same size as .cosmicRayIndices containing
%           the change in values in .crCleanedSeries from .timeSeries so
%           .timeSeries(.cosmicRayIndices) =
%           .crCleanedSeries(.cosmicRayIndices) + .cosmicRayDeltas
% MORE FILLED IN HERE BY OTHER DEVELOPERS AS THEIR COMPONENTS ARE COMPLETED
%
%   The following fields are added to each entry of targetStarStruct
%       .rawFluxTimeSeries # of cadences x 1 arrays containing
%           the raw flux time series for each target
%       .rawFluxUncertainties # of cadences x 1 arrays containing
%           the uncertainties in the raw flux time series for each target
%       .rowCentroid(), .colCentroid() # of cadences x 1 arrays containing
%           row and column centroids of the target
%
%
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

if nargin == 0
    % if no inputs generate an error
    error('PA:tppClass:EmptyInputStruct',...
        'The constructor must be called with an input structure.');
end
% This is an auto-generated script. Modify if needed.
%------------------------------------------------------------
fieldsAndBounds(1,:)  = { 'backgroundCoeffStruct'; []; []; []};
fieldsAndBounds(2,:)  = { 'backgroundStruct'; []; []; []};
fieldsAndBounds(3,:)  = { 'targetStarStruct'; []; []; []};
fieldsAndBounds(4,:)  = { 'smearStruct'; []; []; []};
fieldsAndBounds(5,:)  = { 'backgroundConfigurationStruct'; []; []; []};
fieldsAndBounds(6,:)  = { 'cosmicRayConfigurationStruct'; []; []; []};
fieldsAndBounds(7,:)  = { 'motionPolyStruct'; []; []; []};
fieldsAndBounds(8,:)  = { 'debugFlag'; []; []; []};
fieldsAndBounds(9,:)  = { 'tppConfigurationStruct'; []; []; []};
fieldsAndBounds(10,:)  = { 'gapFillParametersStruct'; []; []; []};
fieldsAndBounds(11,:)  = { 'ancillaryDataStruct'; []; []; []};
fieldsAndBounds(12,:)  = { 'motionGaps'; []; []; []};
fieldsAndBounds(13,:)  = { 'backgroundGaps'; []; []; []};
fieldsAndBounds(14,:)  = { 'startCadenceTimes'; []; []; []};
fieldsAndBounds(15,:)  = { 'endCadenceTimes'; []; []; []};

validate_structure(tppInputStruct, fieldsAndBounds,'tppInputStruct');
clear fieldsAndBounds;

%------------------------------------------------------------
fieldsAndBounds(1,:)  = { 'offsetx'; ' >= -1e12 '; ' <= 1e12 '; []};
fieldsAndBounds(2,:)  = { 'scalex'; ' >= -1e12 '; ' <= 1e12 '; []};
fieldsAndBounds(3,:)  = { 'originx'; ' >= -1e12 '; ' <= 1e12 '; []};
fieldsAndBounds(4,:)  = { 'offsety'; ' >= -1e12 '; ' <= 1e12 '; []};
fieldsAndBounds(5,:)  = { 'scaley'; ' >= -1e12 '; ' <= 1e12 '; []};
fieldsAndBounds(6,:)  = { 'originy'; ' >= -1e12 '; ' <= 1e12 '; []};
fieldsAndBounds(7,:)  = { 'xindex'; ' >= -1 '; ' <= 4 '; []};
fieldsAndBounds(8,:)  = { 'yindex'; ' >= -1 '; ' <= 4 '; []};
fieldsAndBounds(9,:)  = { 'type'; []; []; {'standard', 'not_scaled', 'legendre'}};
fieldsAndBounds(10,:)  = { 'order'; '> 0'; '<= 1e4'; []};
%fieldsAndBounds(11,:)  = { 'message'; []; []; []};
fieldsAndBounds(11,:)  = { 'coeffs'; ' > -1e3'; ' <= 1e9' ; []}; 
fieldsAndBounds(12,:)  = { 'covariance'; '>= -1e3'; '<= 1e9'; []};

nStructures = length(tppInputStruct.backgroundCoeffStruct);

for j = 1:nStructures
    validate_structure(tppInputStruct.backgroundCoeffStruct(j), fieldsAndBounds,'tppInputStruct.backgroundCoeffStruct');
end
clear fieldsAndBounds;

%------------------------------------------------------------
fieldsAndBounds(1,:)  = { 'pixelIndex'; []; []; []};
fieldsAndBounds(2,:)  = { 'row'; '>= 0'; '<= 1200'; []};
fieldsAndBounds(3,:)  = { 'column'; '>= 0'; '<= 1200'; []};
fieldsAndBounds(4,:)  = { 'timeSeries'; '> -1e3'; ' <= 1e9'; []};
fieldsAndBounds(5,:)  = { 'uncertainties'; '> -1e3'; ' <= 1e9'; []};
fieldsAndBounds(6,:)  = { 'gapList'; '>= 0'; '<= 1e6'; []};
fieldsAndBounds(7,:)  = { 'crCleanedSeries'; '> -1e3'; ' <= 1e9'; []};
fieldsAndBounds(8,:)  = { 'cosmicRayIndices'; '>= 0'; '<= 1e6'; []};
fieldsAndBounds(9,:)  = { 'cosmicRayDeltas'; '> -1e3'; ' <= 1e9'; []};

nStructures = length(tppInputStruct.backgroundStruct);

for j = 1:nStructures
    validate_structure(tppInputStruct.backgroundStruct(j), fieldsAndBounds,'tppInputStruct.backgroundStruct');
end

clear fieldsAndBounds;
%------------------------------------------------------------
fieldsAndBounds(1,:)  = { 'referenceRow'; '>= 0'; '<= 1200'; []};
fieldsAndBounds(2,:)  = { 'referenceColumn'; '>= 0'; '<= 1200'; []};
fieldsAndBounds(3,:)  = { 'pixelTimeSeriesStruct'; []; []; []};
fieldsAndBounds(4,:)  = { 'gapList'; '>= 0'; '<= 1e6'; []}; % short cadence data for a quarter can be 60*24*93 long

nStructures = length(tppInputStruct.targetStarStruct);

for j = 1:nStructures
    validate_structure(tppInputStruct.targetStarStruct(j), fieldsAndBounds,'tppInputStruct.targetStarStruct');
end

clear fieldsAndBounds;
%------------------------------------------------------------
fieldsAndBounds(1,:)  = { 'row'; '>= 0'; '<= 1200'; []};
fieldsAndBounds(2,:)  = { 'column'; '>= 0'; '<= 1200'; []};
fieldsAndBounds(3,:)  = { 'isInOptimalAperture'; []; [] ; [0 1]};
fieldsAndBounds(4,:)  = { 'timeSeries'; '> -1e3'; ' <= 1e9'; []};
fieldsAndBounds(5,:)  = { 'uncertainties'; '> -1e3'; ' <= 1e9'; []};
fieldsAndBounds(6,:)  = { 'gapList'; '>= 0'; '<= 1e6'; []};

kStructs = length(tppInputStruct.targetStarStruct);
for i = 1:kStructs

	 nStructures = length(tppInputStruct.targetStarStruct(i).pixelTimeSeriesStruct);

	for j = 1:nStructures
		validate_structure(tppInputStruct.targetStarStruct(i).pixelTimeSeriesStruct(j), fieldsAndBounds,'tppInputStruct.targetStarStruct(i).pixelTimeSeriesStruct');
	end
end

clear fieldsAndBounds;

%------------------------------------------------------------
fieldsAndBounds(1,:)  = { 'rowCoeff'; []; []; []};
fieldsAndBounds(2,:)  = { 'columnCoeff'; []; []; []};

nStructures = length(tppInputStruct.motionPolyStruct);

for j = 1:nStructures
    validate_structure(tppInputStruct.motionPolyStruct(j), fieldsAndBounds,'tppInputStruct.motionPolyStruct');
end

clear fieldsAndBounds;
%------------------------------------------------------------
fieldsAndBounds(1,:)  = { 'offsetx'; ' >= -1e12 '; ' <= 1e12 '; []};
fieldsAndBounds(2,:)  = { 'scalex'; ' >= -1e12 '; ' <= 1e12 '; []};
fieldsAndBounds(3,:)  = { 'originx'; ' >= -1e12 '; ' <= 1e12 '; []};
fieldsAndBounds(4,:)  = { 'offsety'; ' >= -1e12 '; ' <= 1e12 '; []};
fieldsAndBounds(5,:)  = { 'scaley'; ' >= -1e12 '; ' <= 1e12 '; []};
fieldsAndBounds(6,:)  = { 'originy'; ' >= -1e12 '; ' <= 1e12 '; []};
fieldsAndBounds(7,:)  = { 'xindex'; ' >= -1 '; ' <= 4 '; []};
fieldsAndBounds(8,:)  = { 'yindex'; ' >= -1 '; ' <= 4 '; []};
fieldsAndBounds(9,:)  = { 'type'; []; []; {'standard'; 'not_scaled'; 'legendre'}};
fieldsAndBounds(10,:)  = { 'order'; '> 0'; '<= 1e4'; []};
%fieldsAndBounds(11,:)  = { 'message'; []; []; []};
fieldsAndBounds(11,:)  = { 'coeffs'; ' > -1e3'; ' <= 1e9' ; []}; 
fieldsAndBounds(12,:)  = { 'covariance'; '>= -1e3'; '<= 1e9'; []};

kStructs = length(tppInputStruct.motionPolyStruct);
for i = 1:kStructs
	validate_structure(tppInputStruct.motionPolyStruct(i).rowCoeff, fieldsAndBounds,'tppInputStruct.motionPolyStruct(i).rowCoeff');

end
clear fieldsAndBounds;

%------------------------------------------------------------
fieldsAndBounds(1,:)  = { 'offsetx'; ' >= -1e12 '; ' <= 1e12 '; []};
fieldsAndBounds(2,:)  = { 'scalex'; ' >= -1e12 '; ' <= 1e12 '; []};
fieldsAndBounds(3,:)  = { 'originx'; ' >= -1e12 '; ' <= 1e12 '; []};
fieldsAndBounds(4,:)  = { 'offsety'; ' >= -1e12 '; ' <= 1e12 '; []};
fieldsAndBounds(5,:)  = { 'scaley'; ' >= -1e12 '; ' <= 1e12 '; []};
fieldsAndBounds(6,:)  = { 'originy'; ' >= -1e12 '; ' <= 1e12 '; []};
fieldsAndBounds(7,:)  = { 'xindex'; ' >= -1 '; ' <= 4 '; []};
fieldsAndBounds(8,:)  = { 'yindex'; ' >= -1 '; ' <= 4 '; []};
fieldsAndBounds(9,:)  = { 'type'; []; []; {'standard'; 'not_scaled'; 'legendre'}};
fieldsAndBounds(10,:)  = { 'order'; '> 0'; '<= 1e4'; []};
%fieldsAndBounds(11,:)  = { 'message'; []; []; []};
fieldsAndBounds(11,:)  = { 'coeffs'; ' > -1e3'; ' <= 1e9' ; []}; 
fieldsAndBounds(12,:)  = { 'covariance'; '>= -1e3'; '<= 1e9'; []};

kStructs = length(tppInputStruct.motionPolyStruct);
for i = 1:kStructs
	validate_structure(tppInputStruct.motionPolyStruct(i).columnCoeff, fieldsAndBounds,'tppInputStruct.motionPolyStruct(i).columnCoeff');

end

clear fieldsAndBounds;
%------------------------------------------------------------
fieldsAndBounds(1,:)  = { 'startCadence'; []; []; []};
fieldsAndBounds(2,:)  = { 'endCadence'; []; []; []};
fieldsAndBounds(3,:)  = { 'cadenceType'; []; []; []};
fieldsAndBounds(4,:)  = { 'ccdModule'; []; []; []};
fieldsAndBounds(5,:)  = { 'ccdOutput'; []; []; []};
fieldsAndBounds(6,:)  = { 'cleanCosmicRays'; []; []; []};

validate_structure(tppInputStruct.tppConfigurationStruct, fieldsAndBounds,'tppInputStruct.tppConfigurationStruct');
clear fieldsAndBounds;

%------------------------------------------------------------

fieldsAndBounds(1,:)  = { 'madXFactor'; []; []; []};
fieldsAndBounds(2,:)  = { 'maxGiantTransitDurationInHours'; []; []; []};
fieldsAndBounds(3,:)  = { 'maxDetrendPolyOrder'; []; []; []};
fieldsAndBounds(4,:)  = { 'maxArOrderLimit'; []; []; []};
fieldsAndBounds(5,:)  = { 'maxCorrelationWindowXFactor'; []; []; []};
fieldsAndBounds(6,:)  = { 'gapFillModeIsAddBackPredictionError'; []; []; []};
fieldsAndBounds(7,:)  = { 'cadenceDurationInMinutes'; []; []; []};
fieldsAndBounds(8,:)  = { 'gapFluxCompletenessFraction'; []; []; []};

validate_structure(tppInputStruct.gapFillParametersStruct, fieldsAndBounds,'tppInputStruct.gapFillParametersStruct');

clear fieldsAndBounds;


%------------------------------------------------------------
fieldsAndBounds(1,:)  = { 'mnemonic'; []; []; []};
fieldsAndBounds(2,:)  = { 'timestamps'; []; []; []};
fieldsAndBounds(3,:)  = { 'values'; []; []; []};
fieldsAndBounds(4,:)  = { 'uncertainties'; []; []; []};
fieldsAndBounds(5,:)  = { 'isAncillaryEngineeringData'; []; []; [true, false]};
fieldsAndBounds(6,:)  = { 'maxAcceptableGapInHours'; '> 0' ; ' <= 48'; []};
fieldsAndBounds(7,:)  = { 'modelOrderInDesignMatrix'; '> 0'; '<= 10'; []};

nStructures = length(tppInputStruct.ancillaryDataStruct);

for j = 1:nStructures
    validate_structure(tppInputStruct.ancillaryDataStruct(j), fieldsAndBounds,'tppInputStruct.ancillaryDataStruct');
end

clear fieldsAndBounds;
%------------------------------------------------------------
% create fields filled in later
nTargets = length(tppInputStruct.targetStarStruct);

for target=1:nTargets
    nPixels = length(tppInputStruct.targetStarStruct(target).pixelTimeSeriesStruct);
    for pixel = 1:nPixels
        tppInputStruct.targetStarStruct(target).pixelTimeSeriesStruct(pixel).crCleanedSeries = ...
            zeros(size(tppInputStruct.targetStarStruct(1).pixelTimeSeriesStruct(1).timeSeries));
        tppInputStruct.targetStarStruct(target).pixelTimeSeriesStruct(pixel).cosmicRayIndices = [];
        tppInputStruct.targetStarStruct(target).pixelTimeSeriesStruct(pixel).cosmicRayDeltas = [];
    end
    tppInputStruct.targetStarStruct(target).rawFluxTimeSeries = [];
    tppInputStruct.targetStarStruct(target).rawFluxUncertainties = [];
    tppInputStruct.targetStarStruct(target).rowCentroid = [];
    tppInputStruct.targetStarStruct(target).colCentroid = [];
end

% make the tppClass object
tppObject = class(tppInputStruct, 'tppClass');
