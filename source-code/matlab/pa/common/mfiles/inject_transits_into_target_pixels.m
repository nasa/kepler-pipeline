function [ outputStruct ] = inject_transits_into_target_pixels( inputStruct, dvStyleInputs )
% function [ outputStruct ] = inject_transits_into_target_pixels( inputStruct, dvStyleInputs )
% 
% This function uses information produced in the Transit Injection Parameters (TIP) module to inject a transit model into target pixels 
% using a target magnitude estimated from the median background corrected target flux and the pixel response function (PRF) at the location 
% of the target plus an offset which may be zero. If the offset is non-zero the median out of transit flux for the target does not remain 
% unchanged, there will be a small added flux. To compensate for this additional flux the medianPhotocurrentAdded is saved for each planet 
% and will be removed after PA has performed the Aperture Photometry step (SAP nominally). 
%
% INPUTS:
% inputStruct contains the following fields:
%       transitModelStruct      == model used by transitGeneratorClass - from simulatedTransitsBlob + timestamps and configMap
%       transitSeparation       == simulated tranits period
%       transitWidthToModel     == buffer around transit centers to model
%       transitDepthToModel     == fractional depth of transit to model
%       offsetArcSec            == magnitude of offset from target where prf for transit is centered (arcsec)
%       offsetPhase             == phase of offset in ra/dec space [ -pi, pi ]
%       offsetEnabled           == boolean to enabled offset transiting object
%       targetDataStruct        == target data
%       cadenceTimes            == cadence times struct
%       motionPolyStruct        == motion polnomials from PA interpolated so that every cadence is filled
%       CADENCE_DURATION_SEC    == cadence length in seconds (from configMap)
%       MAG12_E_PER_S           == e/s for magnitude 12 target from fc constants
%       prfObject               == prf model instantiated as an object
% dvStyleInputs (optional)      ==  boolean; default = false
%                                   allows use of targetDataStruct as presented in DV (w/ .value, .uncertainty, .provinance subfields)
% 
% OUTPUTS:
% outputStruct cointains the following fields:
%       pixelValues                 == updated pixel values
%       pixelGaps                   == updated pixel gaps
%       testDepth                   == estimate of transit depth from model light curve (nPlanets x 1)
%       prfFailed                   == logical array (nCadences x 1)
%       cadenceModified             == logical array (nCadences x 1)
%       fractionSignalSubtracted    == fraction of signal subtracted from pixels in optimal aperture (nCadences x 1)
%       appliedRa                   == ra of transiting object (deg)
%       appliedDec                  == dec of transiting object (deg)
%       magnitudeOffset             == magnitude offset of transiting object from target magnitude, NaN if offsetEnabled = false (nPlanets x 1)
%       medianPhotocurrentAdded     == This will be subtracted later in PA from the raw flux after aperture photometry is performed (nPlanets x 1)
%                                      If offsetEnabled(iPlanet) = false, medianPhotocurrentAdded(iPlanet) = 0.
%       relativeTargetMagEstimate   == target magnitude relative to mag = 12 estimated from median flux after SAP
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



% check null case
if isempty(inputStruct)
    outputStruct = [];
    return;
end

% set targetDataStruct input style
if nargin == 1
    dvStyleInputs = false;
end


% read needed inputs
transitModelStruct      = inputStruct.transitModelStruct;
transitSeparation       = inputStruct.transitSeparation;
transitWidthToModel     = inputStruct.transitWidthToModel;
transitDepthToModel     = inputStruct.transitDepthToModel;
offsetArcSec            = inputStruct.offsetArcSec;
offsetPhase             = inputStruct.offsetPhase;
offsetEnabled           = inputStruct.offsetEnabled;
offsetTransitDepth      = inputStruct.offsetTransitDepth;
targetDataStruct        = inputStruct.targetDataStruct;
cadenceTimes            = inputStruct.cadenceTimes;
motionPolyStruct        = inputStruct.motionPolyStruct;

CADENCE_DURATION_SEC    = inputStruct.CADENCE_DURATION_SEC;
MAG12_E_PER_S           = inputStruct.MAG12_E_PER_S;
prfObject               = inputStruct.prfObject;

% count number of planets to simulate
nPlanets = length(transitModelStruct);

% check for correct length of parameter arrays
if length(transitSeparation) ~= nPlanets ||...
        length(transitSeparation) ~= nPlanets ||...
        length(transitWidthToModel) ~= nPlanets ||...
        length(transitDepthToModel) ~= nPlanets ||...
        length(offsetArcSec) ~= nPlanets ||...
        length(offsetPhase) ~= nPlanets ||...
        length(offsetEnabled) ~= nPlanets ||...
        length(offsetTransitDepth) ~= nPlanets
    
    error('Number of parameters in transitInjectionInputs not equal to number of transit models input.');
end

% count cadences and get gap indicators
midTimestamps           = cadenceTimes.midTimestamps;
cadenceGapIndicators    = cadenceTimes.gapIndicators;
nCadences               = length(midTimestamps);

% retrieve units conversions
DAYS_PER_HOUR = get_unit_conversion('hour2day');
DEGREES_PER_RADIAN = get_unit_conversion('rad2deg');
HOURS_PER_SECOND = get_unit_conversion('sec2hour');
DEGREES_PER_HOUR = 2 * pi * DAYS_PER_HOUR * DEGREES_PER_RADIAN;
DEGREES_PER_ARCSEC = HOURS_PER_SECOND;

% initialize outputs
fractionSignalSubtracted    = zeros(nCadences,1);
cadenceModified             = false(nCadences,1);
prfFailed                   = false(nCadences,1);
fluxAddedToOptimalAperture  = zeros(nCadences,1);

% get target pixel coordinates
sceneRows = [targetDataStruct.pixelDataStruct.ccdRow];
sceneCols = [targetDataStruct.pixelDataStruct.ccdColumn];

% get the target pixel data
pixelValues         = [targetDataStruct.pixelDataStruct.values];
pixelGaps           = [targetDataStruct.pixelDataStruct.gapIndicators];
inOptimalAperture   = [targetDataStruct.pixelDataStruct.inOptimalAperture];
% pixelValues(pixelGaps) = nan;                                                     % don't assign nans to gapped pixels per KSOC-3102

% extract arrays of row and column polynomials
rowPoly = [motionPolyStruct.rowPoly];
colPoly = [motionPolyStruct.colPoly];

% estimate target photocurrent (e-/cadence) in optimal aperture
originalFluxTimeSeries = injected_transits_sap(inputStruct);
originalFlux = originalFluxTimeSeries.values;
originalGaps = originalFluxTimeSeries.gapIndicators;
originalFlux(originalGaps) = nan;
photocurrent = nanmedian(originalFlux);

% estimate target mag relative to mag12 from photocurrent
relativeFlux = photocurrent / (CADENCE_DURATION_SEC * MAG12_E_PER_S);
relativeTargetMag = b2mag(relativeFlux);

% pre-initialize storage arrays
testDepth = zeros(nPlanets,1);
magnitudeOffset = zeros(nPlanets,1);

% get target ra/dec per kic and add offset
if dvStyleInputs
    targetDec = targetDataStruct.decDegrees.value;
    targetRa = targetDataStruct.raHours.value;
else
    targetDec = targetDataStruct.decDegrees;
    targetRa = targetDataStruct.raHours;    
end
offsetRaArcSec  = offsetArcSec .* cos(offsetPhase) ./ cos(deg2rad( targetDec ));
offsetDecArcSec = offsetArcSec .* sin(offsetPhase);
thisRa = targetRa * DEGREES_PER_HOUR + offsetRaArcSec .* DEGREES_PER_ARCSEC;
thisDec = targetDec + offsetDecArcSec .* DEGREES_PER_ARCSEC;

% initialize outputStruct
outputStruct.keplerId                   = targetDataStruct.keplerId;
outputStruct.pixelValues                = pixelValues;
outputStruct.pixelGaps                  = pixelGaps;
outputStruct.testDepth                  = testDepth;
outputStruct.prfFailed                  = prfFailed;
outputStruct.cadenceModified            = cadenceModified;
outputStruct.appliedRa                  = thisRa;
outputStruct.appliedDec                 = thisDec;
outputStruct.fractionSignalSubtracted   = fractionSignalSubtracted;
outputStruct.magnitudeOffset            = magnitudeOffset;
outputStruct.medianPhotocurrentAdded    = 0;                                        % this is the offset = 0 case
outputStruct.fluxAddedToOptimalAperture = fluxAddedToOptimalAperture;               % this is a nCadences x 1 vector of zeros at this point
outputStruct.originalFluxTimeSeries     = originalFluxTimeSeries;
outputStruct.relativeTargetMagEstimate  = relativeTargetMag;


% if the photocurrent is NaN the relativeTargetMag will be NaN so just return
if isnan(relativeTargetMag)
    disp(['Estimated magnitude for keplerId ',num2str(targetDataStruct.keplerId),' = NaN.',...
            ' Cannot inject transits for this target.']);
    return;
end

% loop over transitModelStructs (could be different planets if the text file was set up that way)
for iPlanet = 1:nPlanets
    
    % save current state of pixels and flags
    savedPixelValues                = pixelValues;
    savedPixelgaps                  = pixelGaps;
    savedPrfFailed                  = prfFailed;
    savedCadenceModified            = cadenceModified;
    savedFluxAddedToOptimalAperture = fluxAddedToOptimalAperture;
            
    % get modeled light curve w/transits separated by transitSeparation but with transit shape defined by transitModelStruct
    modelLightCurve = assemble_simulated_light_curve( transitModelStruct(iPlanet), transitSeparation(iPlanet), transitWidthToModel(iPlanet) );
    
    % save estimate of actual depth generated
    testDepth(iPlanet) = max(modelLightCurve) - min(modelLightCurve);
    
    % if offset enabled, adjust photocurrent to be that of the offset object consistent with modeled transit depth for entire aperture
    % calculate magnitudeOffset to add to target magnitude - b2mag gives magnitude relative to mag12
    if offsetEnabled(iPlanet)
        photocurrent = photocurrent * transitDepthToModel(iPlanet)/(offsetTransitDepth(iPlanet)-transitDepthToModel(iPlanet));        
        relativeFlux = photocurrent / ( CADENCE_DURATION_SEC * MAG12_E_PER_S );
        magnitudeOffset(iPlanet) = b2mag(relativeFlux) - relativeTargetMag;
    else
        magnitudeOffset(iPlanet) = NaN;
    end
    
    % specify the model vector for all cadences, not just the ungapped ones (which is what barycentricCadenceTimes is)
    modelToAdd = zeros(nCadences,1);
    if offsetEnabled(iPlanet)
        % modeled photocurrent which when added to target flux creates transiting object at offset location
        modelToAdd(~cadenceGapIndicators) = (1 + (modelLightCurve(~cadenceGapIndicators)./transitDepthToModel(iPlanet)).*offsetTransitDepth(iPlanet)) .* photocurrent;
    else
        % modeled photocurrent which when added to target flux creates transits at target location
        modelToAdd(~cadenceGapIndicators) = modelLightCurve(~cadenceGapIndicators) .* photocurrent;
    end
        
    % check for non-nan ra and dec from kic
    if isnan(thisRa(iPlanet)) || isnan(thisDec(iPlanet))
        % calculate center of optimal aperture in row/col
        rowOaCentroid = mean(sceneRows(inOptimalAperture));
        columnOaCentroid = mean(sceneCols(inOptimalAperture));
        disp(['Ra and/or Dec == NaN for target ',num2str(targetDataStruct.keplerId),'.',...
            ' Simulated transit will be applied at centroid of optimal aperture.']);
    end
        
    % loop over cadences since we need to evaluate the motion polys cadence by cadence anyway
    for j = 1:nCadences
        if ~cadenceGapIndicators(j)
            
            if modelToAdd(j) ~= 0
                
                % calculate row/col to center the prf
                if isnan(thisRa(iPlanet)) || isnan(thisDec(iPlanet))
                    % default is the center of the optimal aperture
                    fittedRow = rowOaCentroid;
                    fittedCol = columnOaCentroid;
                else
                    % estimate prf center from the motion poly
                    fittedRow = weighted_polyval2d(thisRa(iPlanet),thisDec(iPlanet),rowPoly(j));
                    fittedCol = weighted_polyval2d(thisRa(iPlanet),thisDec(iPlanet),colPoly(j));
                end
                
                % get prf over all target pixels (scene)
                prforiginalFlux = evaluate(prfObject, fittedRow, fittedCol, sceneRows, sceneCols);
                
                if ~isempty(prforiginalFlux)
                    % modify target pixel with the prf weighted transit model
                    % set candenceModified flag
                    cadenceModified(j) = true;
                    modifiedPrforiginalFlux = prforiginalFlux' .* modelToAdd(j);
                    pixelValues(j,:) = pixelValues(j,:) + modifiedPrforiginalFlux;
                    
                    % track flux added to OA
                    fluxAddedToOptimalAperture(j) = fluxAddedToOptimalAperture(j) + sum(modifiedPrforiginalFlux(inOptimalAperture));                    
                    
                else
                    % set prfFailed flag and gap all pixels for this cadence
                    prfFailed(j) = true;
                    pixelGaps(j,:) = true(size(pixelGaps(j,:)));
                end
            end
        end
    end
    
    % if prf failed on all intransit cadences restore pixel values and gaps to what they were before this planet processed
    % restore cadence modified and prf failed flags and fraction subtracted array
    if ~all(modelToAdd==0) && isequal((prfFailed & modelToAdd ~= 0), modelToAdd ~= 0)
        pixelValues                = savedPixelValues;
        pixelGaps                  = savedPixelgaps;
        prfFailed                  = savedPrfFailed;
        cadenceModified            = savedCadenceModified;
        fluxAddedToOptimalAperture = savedFluxAddedToOptimalAperture;
        disp(['Prf failed for all transit cadences for keplerId ',num2str(targetDataStruct.keplerId),...
            ' No transits injected for planet ',num2str(iPlanet),'.']);
    end
end


% update median photocurrent added for later SAP calculation
if any(offsetEnabled)
    medianPhotocurrentAdded = median(fluxAddedToOptimalAperture(~cadenceGapIndicators));
else
    medianPhotocurrentAdded = 0;
end    

% calculate fractional signal subtracted per assuming target flux will have median flux added removed
fractionSignalSubtracted = (fluxAddedToOptimalAperture - medianPhotocurrentAdded) ./ originalFlux;

% update outputStruct
outputStruct.pixelValues                = pixelValues;
outputStruct.pixelGaps                  = pixelGaps;
outputStruct.testDepth                  = testDepth;
outputStruct.prfFailed                  = prfFailed;
outputStruct.cadenceModified            = cadenceModified;
outputStruct.fractionSignalSubtracted   = fractionSignalSubtracted;
outputStruct.magnitudeOffset            = magnitudeOffset;
outputStruct.medianPhotocurrentAdded    = medianPhotocurrentAdded;
outputStruct.fluxAddedToOptimalAperture = fluxAddedToOptimalAperture;

return;



function [fluxTimeSeries, backgroundFluxTimeSeries] = injected_transits_sap(inputStruct)

% calculate flux for this target just as it is done in the pa method perform_simple_aperture_photometry but without building or modifying the
% paDataClass object

% unpackage some stuff
targetDataStruct        = inputStruct.targetDataStruct;
backgroundPolyStruct    = inputStruct.backgroundPolyStruct;
cadenceTimes            = inputStruct.cadenceTimes;
timestamps              = cadenceTimes.midTimestamps;
cadenceGapIndicators    = cadenceTimes.gapIndicators;
nCadences               = length(timestamps);

    
% Get pixel values, uncertainties, gaps, rows and columns
pixelDataStruct = targetDataStruct.pixelDataStruct;
pixelValues = [pixelDataStruct.values];
pixelUncertainties = [pixelDataStruct.uncertainties];
gapArray = [pixelDataStruct.gapIndicators];
rows = [pixelDataStruct.ccdRow];
cols = [pixelDataStruct.ccdColumn];

% Check if there are any pixels in optimal aperture.
inOptimalAperture = [pixelDataStruct.inOptimalAperture]';   
    
if any(inOptimalAperture)

    pixelValues = pixelValues( : , inOptimalAperture);
    pixelUncertainties = pixelUncertainties( : , inOptimalAperture);
    gapArray = gapArray( : , inOptimalAperture);
    rows = rows(inOptimalAperture);
    cols = cols(inOptimalAperture);

    % Set a gap in the flux time series if any pixel in the optimal
    % aperture for the given target is missing. Set all gapped values
    % and uncertainties to 0.
    gapIndicators = any(gapArray, 2)  | cadenceGapIndicators;
    pixelValues(gapIndicators, : ) = 0;
    pixelUncertainties(gapIndicators, : ) = 0;

    % Initialize background flux time series. Use same gaps as flux time
    % series
    backgroundFluxTimeSeries.values = zeros(nCadences,1);
    backgroundFluxTimeSeries.uncertainties = zeros(nCadences,1);
    backgroundFluxTimeSeries.gapIndicators = gapIndicators;

    % Perfrom SAP on fitted background values. Include standard
    % propagation of errors. This operation must be done cadence by
    % cadence since multiple cadence use cases are not supported by
    % weighted_polyval2d. Note: Since fill_background_polynomial_struct
    % has been run prior to this point there is a background polynomial
    % avaliable for all cadences. 
    for iCadence = 1:nCadences
        backgroundPoly = backgroundPolyStruct(iCadence).backgroundPoly;
        Cv = backgroundPoly.covariance;
        [backgroundValues, ~, Aback] = weighted_polyval2d(rows, cols, backgroundPoly);
        backgroundFluxTimeSeries.values(iCadence) = sum(backgroundValues);
        backgroundFluxTimeSeries.uncertainties(iCadence) = sqrt(sum(sum(Aback * Cv * Aback')));
    end

    % Perform SAP on target pixels. Include basic propagation of
    % uncertainties assuming for now that all pixels are uncorrelated
    % for any given cadence. Remove background flux from target flux.
    fluxTimeSeries.values = sum(pixelValues, 2) - backgroundFluxTimeSeries.values;
    fluxTimeSeries.uncertainties = sqrt( sum(pixelUncertainties .^ 2, 2) + backgroundFluxTimeSeries.uncertainties.^2 );
    fluxTimeSeries.gapIndicators = gapIndicators;

else % there are no pixels in aperture

    backgroundFluxTimeSeries.values = zeros([nCadences, 1]);
    backgroundFluxTimeSeries.uncertainties = zeros([nCadences, 1]);
    backgroundFluxTimeSeries.gapIndicators = true([nCadences, 1]);         

    fluxTimeSeries.values = zeros([nCadences, 1]);
    fluxTimeSeries.uncertainties = zeros([nCadences, 1]);
    fluxTimeSeries.gapIndicators = true([nCadences, 1]);

end % if / else

% Return.
return