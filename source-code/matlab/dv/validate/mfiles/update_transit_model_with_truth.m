function dvResultsStruct = update_transit_model_with_truth(dvResultsStruct,dvTargetList,dvBackgroundBinaryList,raDec2PixModel)
%
% function dvResultsStruct = update_transit_model_with_truth(dvResultsStruct,dvTargetList,dvBackgroundBinaryList,raDec2PixModel)
%
% load planetResultsStruct with each ground truth planet and background
% binary signature
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


%% Seed transit fit parameter struct

% As of 6/10/09 the following strings are expected for modelParameters.name
% meanFluxMegaElectrons
% transitEpochMjd
% semiMajorAxisAu
% inclinationDegrees
% planetRadiusEarthRadii
% starRadiusSolarRadii
% ingressTimeHours
% transitDurationHours
% transitPeriodDays
% transitDepthPpMillion

% As of 8/14/09 the following strings are expected for modelParameters.name
% 'eccentricity'
% 'transitEpochMjd'
% 'semiMajorAxisAu'
% 'minImpactParameter'
% 'planetRadiusEarthRadii'
% 'starRadiusSolarRadii'
% 'transitIngressTimeHours'
% 'transitDurationHours'
% 'orbitalPeriodDays'
% 'transitDepthPpm'
% 'longitudeOfPeriDegrees'
%


% As of 5/25/10 the following strings are expected for modelParameters.name
% 'eccentricity'
% 'transitEpochBkjd'
% 'semiMajorAxisAu'
% 'minImpactParameter'
% 'planetRadiusEarthRadii'
% 'starRadiusSolarRadii'
% 'transitIngressTimeHours'
% 'transitDurationHours'
% 'orbitalPeriodDays'
% 'transitDepthPpm'
% 'longitudeOfPeriDegrees'
%


% select transit model name
transitModelName = 'groundTruth';
% transitModelName = 'gaussian';
% transitModelName = 'mandel-agol_transit_model';

% paramList = {'eccentricity'
%              'transitEpochBkjd'
%              'semiMajorAxisAu'
%              'minImpactParameter'
%              'planetRadiusEarthRadii'
%              'starRadiusSolarRadii'
%              'transitIngressTimeHours'
%              'transitDurationHours'
%              'orbitalPeriodDays'
%              'transitDepthPpm'
%              'longitudeOfPeriDegrees'};

paramList = get_planet_model_legal_fields('all');

% initialize array of model parameters
modelParameters = repmat(struct('name','',...
                                'value',0,...
                                'uncertainty',-1,...
                                'fitted',false),...
                                length(paramList),1);

% load parameter names                                        
for jParam=1:length(paramList)
    modelParameters(jParam).name = paramList{jParam};    
end

epochUncertainty = 0.01;        % days
relativeUncertainty = 0.01;     % use for other parameters

% find indices
iEpoch      = find(strcmpi('transitEpochBkjd',paramList),1);
iDuration   = find(strcmpi('transitDurationHours',paramList),1);
iPeriod     = find(strcmpi('orbitalPeriodDays',paramList),1);
iDepth      = find(strcmpi('transitDepthPpm',paramList),1);

% construct list of Kepler Ids which have background bianaries
backgroundBinaryKeplerIdList = [dvBackgroundBinaryList.targetKeplerId]';
iTargetList = find(ismember([dvTargetList.keplerId],[dvResultsStruct.targetResultsStruct.keplerId]));

raDec2PixObject = raDec2PixClass(raDec2PixModel,'one-based');

for iTarget = 1:length(iTargetList)
    
    % find unit of work endpoints
    tBegin = dvResultsStruct.targetResultsStruct(1).barycentricCorrectedTimestamps(1);
    tEnd   = dvResultsStruct.targetResultsStruct(1).barycentricCorrectedTimestamps(end);
    
    % use first planet all transits fit as template
    fitResults = dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(1).allTransitsFit;
    
    % update planet results fields which do not depend on the ground truth 
    fitResults.transitModelName = transitModelName;
    fitResults.limbDarkeningModelName = 'claret_nonlinear_limb_darkening_model';
    fitResults.fullConvergence = true;
    fitResults.modelChiSquare  = 1;
    fitResults.modelDegreesOfFreedom = 100;
    fitResults.robustWeights = [];
    fitResults.modelParameters = modelParameters;
    fitResults.modelParameterCovariance = zeros(length(paramList));
    
    % wrtie back into dvResultsStruct
    dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(1).allTransitsFit = fitResults;
    
    % parse planetResultsStruct
    planetResults = dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(1);
    
    % update fit results for all fit types and store    
    planetResults.allTransitsFit = fitResults;
    planetResults.oddTransitsFit = fitResults;
    planetResults.evenTransitsFit = fitResults;    
    
    
    iPlanet = 1;
    for iLightCurve = 1:length(dvTargetList(iTargetList(iTarget)).lightCurveList)
        
        % first light curve may be SOHO Stellar Variablity Data
        if(~strcmpi(dvTargetList(iTargetList(iTarget)).lightCurveList(iLightCurve).description, 'SOHO-based stellar variability'))

            dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet) = planetResults;
            dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).allTransitsFit.planetNumber = iPlanet;
            dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).planetNumber = iPlanet;

            % set orbital period (days)
            orbitalPeriod = dvTargetList(iTargetList(iTarget)).lightCurveList(iLightCurve).lightCurveData.orbitalPeriodMks./(3600*24);
            dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).allTransitsFit.modelParameters(iPeriod).value = orbitalPeriod;
            dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).allTransitsFit.modelParameters(iPeriod).uncertainty = orbitalPeriod * relativeUncertainty;

            % -- set first transit center time (days mjd)
            % get Kepler time of first transit and convert to Kjd
            t0 = dvTargetList(iTargetList(iTarget)).lightCurveList(iLightCurve).lightCurveData.transitTimesMks(1)./(3600*24);
                        
            % location of target star
            targetRa = dvTargetList(iTargetList(iTarget)).ra;
            targetDec = dvTargetList(iTargetList(iTarget)).dec;

            % convert t0 from Kepler time to bkjd and store as transit barycentric epoch
            epoch = kepler_time_to_barycentric( raDec2PixObject, targetRa, targetDec, t0 ) - kjd_offset_from_mjd;
            dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).allTransitsFit.modelParameters(iEpoch).value = epoch;                
            dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).allTransitsFit.modelParameters(iEpoch).uncertainty = epochUncertainty;
            
            %--------------------------------------------------------------------------
            % The transitDuration can be estimated from the star and planet radii, the
            %  semimajor axis, the surface gravity, and the orbital inclination.
            %
            % period = (2 * pi * a^(3/2)) / sqrt(G*M)
            %
            % where G*M = g * R_star^2
            %
            % transitDuration = distance the planet travels across star disk / orbital velocity            
            %
            %
            %  (1)    (distance/2)^2  +  (a*cos(i))^2  =  (r_star + r_planet)^2
            %
            %  (2)    velocity  =  sqrt((G*M)/a)  =  sqrt((g * r_star^2)/a)
            %
            %
            %  dividing sqrt(1) by (2):
            %
            %  transitDuration = 2 * sqrt( a/(g*r_star^2) *((r_star + r_planet)^2 - (a*cos(i))^2  ))
            %
            %
            %--------------------------------------------------------------------------
            
            
            % read ground truth paramters
            period =            dvTargetList(iTargetList(iTarget)).lightCurveList(iLightCurve).lightCurveData.orbitalPeriodMks;
            r_star =            dvTargetList(iTargetList(iTarget)).lightCurveList(iLightCurve).lightCurveData.primaryRadiusMks;
            r_planet =          dvTargetList(iTargetList(iTarget)).lightCurveList(iLightCurve).lightCurveData.secondaryRadiusMks;
            bImpact =           dvTargetList(iTargetList(iTarget)).lightCurveList(iLightCurve).lightCurveData.minimumImpactParameter;
            logGravity =        dvTargetList(iTargetList(iTarget)).logSurfaceGravity;
           
            % calculate semi-major axis (m)
            a = ( period * sqrt(logGravity * r_star^2) / 2 * pi ) ^ (2/3);

            % calculate transit duration (hours) and save
            duration = (1/3600) * ( 2 * sqrt( a/(logGravity*r_star^2) *((r_star + r_planet)^2 - (bImpact)^2  )) );
            dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).allTransitsFit.modelParameters(iDuration).value = duration;
            dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).allTransitsFit.modelParameters(iDuration).uncertainty = relativeUncertainty * duration;

            % calculate transit depth (ppm) and save
            transitDepth = 1e6 * ( max(dvTargetList(iTargetList(iTarget)).lightCurveList(iLightCurve).lightCurve) -...
                                    min(dvTargetList(iTargetList(iTarget)).lightCurveList(iLightCurve).lightCurve) );
            dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).allTransitsFit.modelParameters(iDepth).value = transitDepth;
            dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).allTransitsFit.modelParameters(iDepth).uncertainty = relativeUncertainty * transitDepth;
                 
            
            iPlanet = iPlanet + 1;
            
        end
        
        
        
    end
    
    % if there is a background binary on this target add it to the planet list
    [bbTF, bbIdx] = ismember(dvResultsStruct.targetResultsStruct(iTarget).keplerId, backgroundBinaryKeplerIdList);
    
    if(bbTF)        
        % initialize model parameters struct
        dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet) = planetResults;
        
        dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).allTransitsFit.planetNumber = iPlanet;
        dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).planetNumber = iPlanet;
        
        % read ground truth paramters
        t0           = dvBackgroundBinaryList(bbIdx).object.transitingStarObject.transitingOrbitObject.centralTransitTimes(1);
        period       = dvBackgroundBinaryList(bbIdx).object.transitingStarObject.transitingOrbitObject.orbitalPeriodMks;
        t0_primary   = t0/(3600*24);
        t0_secondary = (t0 + period/2)/(3600*24);
        
        r_primary   = dvBackgroundBinaryList(bbIdx).object.transitingStarObject.transitingOrbitObject.primaryRadiusMks;
        r_secondary = dvBackgroundBinaryList(bbIdx).object.transitingStarObject.transitingOrbitObject.secondaryRadiusMks;
        bImpact     = dvBackgroundBinaryList(bbIdx).object.transitingStarObject.transitingOrbitObject.minimumImpactParameter;
        G           = dvBackgroundBinaryList(bbIdx).object.transitingStarObject.transitingOrbitObject.gravitationalConstant;
        M_primary   = dvBackgroundBinaryList(bbIdx).object.transitingStarObject.transitingOrbitObject.primaryMassMks;
        M_secondary = dvBackgroundBinaryList(bbIdx).object.transitingStarObject.transitingOrbitObject.secondaryMassMks;
        
        
        % calculate semi-major axis (meters)
        a = ( period * sqrt( G * M_primary ) / 2 * pi ) ^ (2/3);
        
        
        % ADD ECLIPSE OF PRIMARY BACKGROUND BINARY OBJECT BY SECONDARY AS PLANET
        % calculate transit duration (hours) and save
        duration = (1/3600) * ( 2 * sqrt( a/( G * M_primary ) *((r_primary + r_secondary)^2 - (bImpact)^2  )) );
        dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).allTransitsFit.modelParameters(iDuration).value = duration;
        dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).allTransitsFit.modelParameters(iDuration).uncertainty = relativeUncertainty * duration;
        
        % set orbital period (days)
        orbitalPeriod = dvBackgroundBinaryList(bbIdx).object.transitingStarObject.transitingOrbitObject.orbitalPeriod;
        dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).allTransitsFit.modelParameters(iPeriod).value = orbitalPeriod;
        dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).allTransitsFit.modelParameters(iPeriod).uncertainty = orbitalPeriod * relativeUncertainty;
        
        % location of primary background object
        targetRa = dvBackgroundBinaryList(bbIdx).initialData.data.primaryPropertiesStruct.ra;
        targetDec = dvBackgroundBinaryList(bbIdx).initialData.data.primaryPropertiesStruct.dec;

        % convert t0_primary from Kepler time to bjd to bkjd and store
        epoch = kepler_time_to_barycentric( raDec2PixObject, targetRa, targetDec, t0_primary ) - kjd_offset_from_mjd;
        dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).allTransitsFit.modelParameters(iEpoch).value = epoch;            
        dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).allTransitsFit.modelParameters(iEpoch).uncertainty = epochUncertainty;

        % calculate transit depth (ppm)
        transitDepth = 1e6 * ( max(dvBackgroundBinaryList(bbIdx).object.transitingStarObject.transitingOrbitObject.lightCurve) - ...
                                min( dvBackgroundBinaryList(bbIdx).object.transitingStarObject.transitingOrbitObject.lightCurve ) );        
        dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).allTransitsFit.modelParameters(iDepth).value = transitDepth;
        dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).allTransitsFit.modelParameters(iDepth).uncertainty = relativeUncertainty * transitDepth;
        
        if( ~strcmpi(transitModelName, 'groundTruth') )

            % ADD ECLIPSE OF SECONDARY BACKGROUND BINARY OBJECT BY PRIMARY AS
            % PLANET IF NOT ACCESSING THE GROUND TRUTH TO GET MODEL LIGHT CURVE
            iPlanet = iPlanet + 1;
            % initialize model parameters struct
            dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet) = ...
                dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(1);

            dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).allTransitsFit.planetNumber = iPlanet;
            dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).planetNumber = iPlanet;

            % calculate transit duration (hours) and save
            duration = (1/3600) * ( 2 * sqrt( a/( G * M_secondary ) *((r_primary + r_secondary)^2 - (bImpact)^2  )) );
            dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).allTransitsFit.modelParameters(iDuration).value = duration;
            dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).allTransitsFit.modelParameters(iDuration).uncertainty = relativeUncertainty * duration;

            % set orbital period (days)
            orbitalPeriod = dvBackgroundBinaryList(bbIdx).object.transitingStarObject.transitingOrbitObject.orbitalPeriod;
            dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).allTransitsFit.modelParameters(iPeriod).value = orbitalPeriod;                
            dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).allTransitsFit.modelParameters(iPeriod).uncertainty = relativeUncertainty * orbitalPeriod;

            % location of primary background object
            targetRa = dvBackgroundBinaryList(bbIdx).initialData.data.primaryPropertiesStruct.ra;
            targetDec = dvBackgroundBinaryList(bbIdx).initialData.data.primaryPropertiesStruct.dec;

            % convert t0_secondary from kjd to bkjd time and store
            epoch = kepler_time_to_barycentric( raDec2PixObject, targetRa, targetDec, t0_secondary ) - kjd_offset_from_mjd;
            dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).allTransitsFit.modelParameters(iEpoch).value = epoch;                
            dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).allTransitsFit.modelParameters(iEpoch).uncertainty = epochUncertainty;

            % calculate transit depth (ppm)
            % assume same impact parameter as seconday on primary - This mean a circular orbit
            if( r_secondary <= ( 1 - bImpact ) * r_primary )
                secondaryTransitDepth = transitDepth + ( ( 1 - (1-bImpact)^2 ) * r_primary^2  ) / (r_primary^2 + r_secondary^2);
            else
                secondaryTransitDepth = transitDepth - ( ( 1 - (1-bImpact)^2 ) * r_secondary^2  ) / (r_primary^2 + r_secondary^2);
            end

            dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).allTransitsFit.modelParameters(iDepth).value = secondaryTransitDepth;
            dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).allTransitsFit.modelParameters(iDepth).uncertainty = relativeUncertainty * secondaryTransitDepth;
            
        end        
    end 
    
    % update fitted epoch to be within unit of work if it is not already
    for iPlanet = 1:length(dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct)
        
        epochDays  = dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).allTransitsFit.modelParameters(iEpoch).value;
        periodDays = dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).allTransitsFit.modelParameters(iPeriod).value;
        
        if( epochDays < tBegin || epochDays > tEnd )
            newEpoch = tBegin + mod(epochDays - tBegin, periodDays);
            dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).allTransitsFit.modelParameters(iEpoch).value = newEpoch;
        end
        
    end
    
end




