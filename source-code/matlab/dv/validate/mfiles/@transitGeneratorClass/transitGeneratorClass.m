function [transitModelObject] = transitGeneratorClass(transitModelStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Constructor for transit generator class
% [transitModelObject] = transitGeneratorClass(transitModelStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% This method implements the constructor for the transitGeneratorClass.
% The output transitModelObject can then be used to generate a transit
% light curve model via the following methods:
%
%  [transitModelLightCurve, cadenceTimes]  = ...
%       generate_planet_model_light_curve(transitModelObject);
%
%
% Fields in the object can be returned by:  get(transitModelObject,'*')
%
%--------------------------------------------------------------------------
%
% INPUTS:
%
% transitModelStruct with the following fields:
%
%   (1) cadenceTimes        [array] barycentric-corrected cadence times (MJD)
%
%   (2) log10SurfaceGravity [struct] struct with the following fields:
%                       
%                          value: [scalar] value of log of stellar surface gravity (cm/sec^2)
%                    uncertainty: [scalar] uncertainty of parameter value (cm/sec^2)
%                     provenance: [string] parameter provenance    
%
%   (3) effectiveTemp       [struct] struct with the following fields:
%
%                          value: [scalar] value of stellar effective temperature (Kelvin)
%                    uncertainty: [scalar] uncertainty of parameter value (Kelvin)
%                     provenance: [string] parameter provenance    
%
%   (4) log10Metallicity    [struct] struct with the following fields (available for kepler limb darkening model only):
%                                    
%                          value: [scalar] value of log Fe/H metallicity, solar (FEH) 
%                    uncertainty: [scalar] uncertainty of parameter value (FEH) 
%                     provenance: [string] parameter provenance    
%
%   (5) radius              [struct] struct with the following fields:
%
%                          value: [scalar] value of stellar radius (solar-radii)
%                    uncertainty: [scalar] uncertainty of parameter value (solar radius)
%                     provenance: [string] parameter provenance    
%
%   (6) debugFlag           [logical] flag used for testing (default=false)
%
%   (7) modelNamesStruct    [struct] struct with the following fields:
%
%               transitModelName: [string] name of transit model
%         limbDarkeningModelName: [string] name of limb darkening model
%
%   (8) transitBufferCadences [scalar] number of cadences to buffer each transit
%
%   (9) transitSamplesPerCadence [scalar] number of samples per cadence
%                                   to compute the light curve (available 
%                                   for geometric model only)
%
%   (10a) configMaps           [struct] struct with spacecraft configuration maps
%                                               OR
%   (10b) timeParametersStruct [struct] struct with the following fields:
%
%                exposureTimeSec [scalar] exposure duration in seconds
%                readoutTimeSec  [scalar] readout time in seconds
%         numExposuresPerCadence [scalar] number of exposures per cadence
%
%   (11) smallBodyCutoff      [scalar] default small body cutoff value
%
%   (12) defaultAlbedo        [scalar] default albedo value
%
%   (13) defaultEffectiveTemp [scalar] default solar effective temperature (Kelvin) 
%
%   (14) planetModel          [struct] struct with one of the following set of fields:
%
%       legalFieldsFormat1 - 'physical' parameters
%
%           transitEpochBkjd       [scalar] barycentric-corrected time to first mid-transit (BKJD)
%           eccentricity           [scalar] planet orbital eccentricity (dimensionless)
%           longitudeOfPeriDegrees [scalar] planet longitude of periastron (degrees)
%           planetRadiusEarthRadii [scalar] planet radius (Earth radii)
%           semimajorAxisAu        [scalar] planet semimajor axis (AU)
%           minImpactParameter     [scalar] minimum impact parameter (dimensionless)
%           starRadiusSolarRadii   [scalar] stellar radius (solar radii)
%
%       legalFieldsFormat2 - 'tps-constructor' observable parameters
%
%           transitEpochBkjd       [scalar] barycentric-corrected time to first mid-transit (BKJD)
%           eccentricity           [scalar] planet orbital eccentricity (dimensionless)
%           longitudeOfPeriDegrees [scalar] planet longitude of periastron (degrees)
%           minImpactParameter     [scalar] minimum impact parameter (dimensionless)
%           starRadiusSolarRadii   [scalar] stellar radius (Solar-radii)
%           transitDepthPpm        [scalar] depth of transit signal (Parts per million)
%           orbitalPeriodDays      [scalar] period between detected transits (days)
%
%       legalFieldsFormat3 - 'geometric-observable' parameters
%
%           transitEpochBkjd       [scalar] barycentric-corrected time to first mid-transit (BKJD)
%           eccentricity           [scalar] planet orbital eccentricity (dimensionless)
%           longitudeOfPeriDegrees [scalar] planet longitude of periastron (degrees)
%           minImpactParameter     [scalar] minimum impact parameter (dimensionless)
%           orbitalPeriodDays      [scalar] period between detected transits (days)
%           ratioPlanetRadiusToStarRadius  [scalar] planet radius normalized by star radius
%           ratioSemiMajorAxisToStarRadius [scalar] semimajor axis normalized by star radius
%           starRadiusSolarRadii   [scalar] stellar radius (Solar-radii)
%           
%
%
% OUTPUTS:
%
% The transitModelObject with fields ordered as follows:
%
%   (1) cadenceTimes                [array]
%   (2) log10SurfaceGravity         [struct]
%   (3) effectiveTemp               [struct]
%   (4) radius                      [struct]
%   (5) samllBodyCutoff             [scalar]
%   (6) defaultAlbedo               [scalar]
%   (7) limbDarkeningCoefficients   [array]
%   (8) debugFlag                   [logical]
%   (9) planetModel [struct] with the following fields:
%
%           transitEpochBkjd
%           eccentricity
%           longitudeOfPeriDegrees
%           planetRadiusEarthRadii
%           semimajorAxisAu
%           minImpactParameter
%           starRadiusSolarRadii
%           transitDurationHours
%           transitIngressTimeHours        [scalar] transit ingress time (hours)
%           transitDepthPpm
%           orbitalPeriodDays
%           ratioPlanetRadiusToStarRadius  [scalar] planet radius normalized by star radius
%           ratioSemiMajorAxisToStarRadius [scalar] semimajor axis normalized by star radius
%           inclinationDegrees             [scalar] inclination angle of the orbit (degrees) 
%           equilibriumTempKelvin          [scalar] equilibrium temperature (Kelvin)
%           effectiveStellarFlux           [scalar] effective stellar flux (dimensionless)
%
%   (10) modelNamesStruct
%
%   (11) timeParametersStruct   [struct] with the following fields
%           transitBufferCadences       [scalar]
%           exposureTimeSec             [scalar]
%           readoutTimeSec              [scalar]
%           numExposuresPerCadence      [scalar]
%           transitSamplesPerCadence    [scalar]
%
%   (12) transitModelLightCurve [array] pre-allocated to zeros (one value per
%                              timestamp) which will be filled by the transit
%                              light curve relative to unobscured (=0) flux
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Version date:  2013-December-11.
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

% Modification History:
%
%    2013-December-11, JL:
%        defaultEffectiveTemp is added in transitModelStruct 
%    2012-August-23, JL:
%        stellar parameter structs and defaultAlbedo are added in transitModelStruct
%    2011-Jan-4, EQ:
%        adding stellar metallicity input for new limb darkening model
%    2010-Oct-12, EQ:
%        adding new legal planet model format and related functions for
%        v7.0 reparameterization
%    2010-May-05, PT:
%        convert from transitEpochMjd to transitEpochBkjd.
%    2009-August-05, PT:
%        handle invalid values, in particular in the KIC parameters (these are
%        not actually validated by the constructor).
%    2009-July-29, PT:
%        add support for config map passed directly to constructor and
%        subsequent extraction of time parameters.
%    2009-July-27, EQ:
%        add struct to inputs for config map parameters, add struct
%        to include both transit model name and limb darkening model name.
%        limb darkening coeffs will now be extracted within this
%        class rather than input
%    2009-July-27, PT:
%        change parameters used by TPS instantiation.
%    2009-July-22, PT:
%        change to use minImpactParameter instead of inclinationDegrees as a
%        physical parameter.
%    2009-July-17, EQ:
%        add support for output gaussian light curve model; including
%        debugFlag (default=false) for testing purposes; updated headers/comments
%    2009-June-12, PT:
%        use the 'tps-constructor' list of parameters instead of the 'observable'
%        for constructing from a format-2 planet model
%    2009-June-10, EQ:
%        replacing the ingress time for the star radius in the observables
%        input planet model
%    2009-June-02, PT:
%        clarify conditions under which a planetModel struct is known to be
%        in the model fit format and needs to be converted.
%    2009-May-26, PT:
%        add support for instantiating from a model fit parameters struct.  Move
%        some fields out of planetModel.  Get field names from a private method
%        rather than hard-coding.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


%--------------------------------------------------------------------------
% validate the inputs
%--------------------------------------------------------------------------
transitModelStruct = validate_transit_generator_inputs(transitModelStruct);


%--------------------------------------------------------------------------
% extract parameters from the inputs struct
%--------------------------------------------------------------------------
% force cadenceTimes to be a column vector
cadenceTimes           = transitModelStruct.cadenceTimes(:);
log10SurfaceGravity    = transitModelStruct.log10SurfaceGravity;
effectiveTemp          = transitModelStruct.effectiveTemp;
log10Metallicity       = transitModelStruct.log10Metallicity;
radius                 = transitModelStruct.radius;
debugFlag              = transitModelStruct.debugFlag;
modelNamesStruct       = transitModelStruct.modelNamesStruct;
planetModel            = transitModelStruct.planetModel;
transitBufferCadences  = transitModelStruct.transitBufferCadences;

% extract transitSamplesPerCadence if available
if isfield(transitModelStruct, 'transitSamplesPerCadence')
    transitSamplesPerCadence = transitModelStruct.transitSamplesPerCadence;
else
    transitSamplesPerCadence = [];
end

% extract smallBodyCutoff if available, default is 1e6 which will force the
% code to use the small body approximation
if isfield(transitModelStruct, 'smallBodyCutoff')   
    smallBodyCutoff = transitModelStruct.smallBodyCutoff;
else
    smallBodyCutoff = 1e6;
end

% extract defaultAlbedo and defaultEffectiveTemp if available
if isfield(transitModelStruct, 'defaultAlbedo')
    defaultAlbedo = transitModelStruct.defaultAlbedo;
else
    defaultAlbedo = 0.3;
end
if isfield(transitModelStruct, 'defaultEffectiveTemp')
    defaultEffectiveTemp = transitModelStruct.defaultEffectiveTemp;
else
    defaultEffectiveTemp = 5780;
end

numTimestamps = length(cadenceTimes);

% extract model names
transitModelName       = modelNamesStruct.transitModelName;
limbDarkeningModelName = modelNamesStruct.limbDarkeningModelName;


%--------------------------------------------------------------------------
% construct the relevant time parameters struct from the spacecraft config
% map using the mean timestamp, if the caller has not supplied the relevant
% parameters explicitly
%--------------------------------------------------------------------------

if isfield( transitModelStruct, 'timeParametersStruct' ) && ...
        isfield(transitModelStruct.timeParametersStruct, 'exposureTimeSec') && ...
        isfield(transitModelStruct.timeParametersStruct, 'readoutTimeSec') && ...
        isfield(transitModelStruct.timeParametersStruct, 'numExposuresPerCadence')
    
    timeParametersStruct = transitModelStruct.timeParametersStruct ;
    
else

    configMaps      = transitModelStruct.configMaps;
    configMapObject = configMapClass(configMaps);

    meanMjd = mean(cadenceTimes) + kjd_offset_from_mjd;

    exposureTimeSec = get_exposure_time(configMapObject, meanMjd);
    readoutTimeSec  = get_readout_time(configMapObject, meanMjd);
    numExposuresPerCadence = get_number_of_exposures_per_long_cadence_period(configMapObject, meanMjd);

    timeParametersStruct.exposureTimeSec = exposureTimeSec;
    timeParametersStruct.readoutTimeSec = readoutTimeSec;
    timeParametersStruct.numExposuresPerCadence = numExposuresPerCadence;
    
end
    
timeParametersStruct.transitSamplesPerCadence = transitSamplesPerCadence;
timeParametersStruct.transitBufferCadences = transitBufferCadences;


%--------------------------------------------------------------------------
% construct a new struct with which to instantiate the class
%--------------------------------------------------------------------------
transitModelStructNew.cadenceTimes              = cadenceTimes;
transitModelStructNew.log10SurfaceGravity       = log10SurfaceGravity;
transitModelStructNew.effectiveTemp             = effectiveTemp;
transitModelStructNew.radius                    = radius;
transitModelStructNew.defaultAlbedo             = defaultAlbedo;
transitModelStructNew.defaultEffectiveTemp      = defaultEffectiveTemp;
transitModelStructNew.limbDarkeningCoefficients = [];
transitModelStructNew.debugFlag                 = debugFlag;
transitModelStructNew.planetModel               = [];
transitModelStructNew.modelNamesStruct          = modelNamesStruct;
transitModelStructNew.timeParametersStruct      = timeParametersStruct;
transitModelStructNew.transitModelLightCurve    = zeros(numTimestamps, 1);
transitModelStructNew.smallBodyCutoff           = smallBodyCutoff;

%--------------------------------------------------------------------------
% instantiate class for gaussian model and return
%--------------------------------------------------------------------------
if strcmpi(transitModelName, 'gaussian')
    
    % include additional planet model fields
    planetModel.planetRadiusEarthRadii  = [];
    planetModel.semiMajorAxisAu         = [];
    planetModel.ratioPlanetRadiusToStarRadius  = [];
    planetModel.ratioSemiMajorAxisToStarRadius = [];
    
    transitModelStructNew.planetModel = planetModel;
    transitModelStructNew.limbDarkeningCoefficients = [0 0 0 0] ;
    
    % instantiate the transitGeneratorClass object and return
    transitModelObject = class(transitModelStructNew, 'transitGeneratorClass');
    return;
end


%--------------------------------------------------------------------------
% retrieve limb darkening coefficients
%--------------------------------------------------------------------------    
limbDarkeningModelStruct = struct(  'modelNameString',      limbDarkeningModelName,     ...
                                    'log10SurfaceGravity',  log10SurfaceGravity.value,  ...
                                    'effectiveTemp',        effectiveTemp.value,        ...
                                    'log10Metallicity',     log10Metallicity.value  );

limbDarkeningModelObject  = limbDarkeningClass(limbDarkeningModelStruct);
limbDarkeningModelObject  = get_limb_darkening_coefficients(limbDarkeningModelObject);
limbDarkeningCoefficients = get(limbDarkeningModelObject, 'limbDarkeningCoefficients');


%--------------------------------------------------------------------------
% determine whether the transitModelStruct is correctly formatted and which
% of the valid structs it represents.  Detect and handle the case in which
% the planetModel matches the format of a planet model fit struct
%--------------------------------------------------------------------------
if (isstruct(planetModel) && isvector(planetModel) && length(planetModel)>1 )
    
    if strcmpi(transitModelName, 'mandel-agol_geometric_transit_model')
        formatParameters = get_planet_model_legal_fields('geometric') ;
    else
        formatParameters = get_planet_model_legal_fields('physical') ;
    end
    planetModel = translate_fit_struct_to_format( planetModel, formatParameters);
end

legalFieldsFormat1 = get_planet_model_legal_fields('physical');
legalFieldsFormat2 = get_planet_model_legal_fields('tps-constructor');
legalFieldsFormat3 = get_planet_model_legal_fields('geometric');
legalFieldsFormat4 = get_planet_model_legal_fields('trapezoidal');

isFormat1 = all( isfield(planetModel, legalFieldsFormat1) ) && ...
    length(fieldnames(planetModel)) == length(legalFieldsFormat1) ;

isFormat2 = all( isfield(planetModel, legalFieldsFormat2) ) && ...
    length(fieldnames(planetModel)) == length(legalFieldsFormat2) ;

isFormat3 = all( isfield(planetModel, legalFieldsFormat3) ) && ...
    length(fieldnames(planetModel)) == length(legalFieldsFormat3) ;

isFormat4 = all( isfield(planetModel, legalFieldsFormat4) ) && ...
    length(fieldnames(planetModel)) == length(legalFieldsFormat4) ;

%--------------------------------------------------------------------------
% construct a new planet model struct with the following fields:
%
%           transitEpochBkjd
%           eccentricity
%           longitudeOfPeriDegrees
%           planetRadiusEarthRadii
%           semimajorAxisAu
%           minImpactParameter
%           starRadiusSolarRadii
%           transitDurationHours
%           transitIngressTimeHours
%           transitDepthPpm
%           orbitalPeriodDays
%           ratioPlanetRadiusToStarRadius
%           ratioSemiMajorAxisToStarRadius
%           inclinationDegrees
%           equilibriumTempKelvin
%
%--------------------------------------------------------------------------
if strcmpi(transitModelName, 'mandel-agol_geometric_transit_model')
    
    planetModelFields = get_planet_model_legal_fields('all');
else
    planetModelFields = get_planet_model_legal_fields('physical-observable');
end

for iField = 1:length(planetModelFields)
    newPlanetModel.(planetModelFields{iField}) = [];
end

if (~(isFormat1 || isFormat2 || isFormat3 || isFormat4))
    error('dv:transitGeneratorClass:invalidStructFormat', ...
        'transitGeneratorClass: instantiating struct has invalid format');
elseif (isFormat1)
    
    % check for a negative impact parameter and set it positive
    originalFields = legalFieldsFormat1;
    planetModel.minImpactParameter = abs(planetModel.minImpactParameter);
    
elseif (isFormat2)
    
    originalFields = legalFieldsFormat2;
    
elseif (isFormat3)
    
    originalFields = legalFieldsFormat3;
    
elseif (isFormat4)
    
    originalFields = legalFieldsFormat4;
    
end

check_planet_model_value_bounds(planetModel);

for iField = 1:length(originalFields)
    newPlanetModel.(originalFields{iField}) = planetModel.(originalFields{iField}) ;
end


%--------------------------------------------------------------------------
% set new planet model and ld coefficients prior to instantiating class
%--------------------------------------------------------------------------
transitModelStructNew.planetModel               = newPlanetModel;
transitModelStructNew.limbDarkeningCoefficients = limbDarkeningCoefficients;


%--------------------------------------------------------------------------
% instantiate the object
%--------------------------------------------------------------------------
transitModelObject = class(transitModelStructNew, 'transitGeneratorClass');


if (isFormat1) % 'physical'
    
    % compute observable parameters and include in transit model object
    transitModelObject = compute_transit_observable_parameters(transitModelObject);
    
elseif (isFormat2) % 'tps-constructor'
    
    % compute physical parameters and include in transit model object
    transitModelObject = ...
        compute_transit_parameters_from_tps_instantiation(transitModelObject);
    
elseif (isFormat3) % 'geometric-observable'
    
    % compute geometric observable parameters and include in transit model object
    transitModelObject = compute_transit_geometric_observable_parameters(transitModelObject);
    
elseif (isFormat4)
    
    transitModelObject = compute_trapezoidal_fit_derived_parameters(transitModelObject);
    
end


return;



%==========================================================================
% subfunction which performs translation of model fit parameters to format 1
% planet model parameters

function planetModel = translate_fit_struct_to_format(planetModelOriginal, formatParameters)

% get the names of the parameters in the planet model as a cell array
planetModelParameters = {planetModelOriginal.name};

% find the intersection, and in the process get indices into the parameters
[parameters, oldPointer, newPointer] = ...
    intersect(planetModelParameters, formatParameters);  %#ok<NASGU>

% construct the new planet model
for iField = 1:length(parameters)
    planetModel.(parameters{iField}) = planetModelOriginal(oldPointer(iField)).value ;
end

% sort according to the order of the physical parameters
planetModel = orderfields(planetModel, formatParameters) ;


return;

