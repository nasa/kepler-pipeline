function [monteCarloResults, masterPulse, polyCoeffs] = ...
    run_master_pulse_generation_monte_carlo( dvDataStruct, ...
    stellarParameters, nIterations, modelDuration, debugLevel  )
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [monteCarloResults, masterPulse, polyCoeffs] = run_master_pulse_generation_monte_carlo( ...
%    dvDataStruct, stellarParameters, nIterations, debugLevel  )
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Description: This function generates a master trial pulse by monte carlo.
%  It uses the dvDataStruct to generate a transit model by randomly and
%  uniformly sampling impact parameter, and logarithmically sampling the
%  depth.  It pulls sets of stellar parameters for limb darkening randomly
%  from stellarParameters.
% 
%
% Inputs: dvDataStruct - a generic dvDataStruct
%         stellarParameters - a struct with effectiveTemp,
%             log10SurfaceGravity, and log10Metallicity fields.  Note that
%             there is a file in the test data repo for this purpose that
%             contains stellar parameters for all the targets used in 8.3 V&V.
%             It is called stellar-parameters-for-master-pulse-mc.mat .
%             Note that this file also contains a dvDataStruct.
%         nIterations - the number of samples for the monte carlo
%         debugLevel - if >= 0 then progress info will be printed
%
% Outputs: monteCarloResults - an array with a pulse for each iteration on
%              each row
%          masterPulse - the master pulse vector obtained by averaging all
%              iterations together.
%          polyCoeffs - polynomial coefficients for the best fit polynomial
%
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

polyCoeffs = [];

% logarithmically sample depths, note that sqrt(depth) = r_p/r_* and the 
%small body cutoff is 0.01 for r_p/r_*
%allowedDepthsSigma = logspace(-3,2,5000) ;
allowedDepthsSigma = logspace(-4.3,-1.5,3000) ; 
% uniformly sample impact parameter
impactParameters = 0:0.01:1;

nStellarParams = length(stellarParameters.keplerId) ;

% just use one target
dvDataStruct.targetStruct = dvDataStruct.targetStruct(1) ;
[dvDataStruct] = update_dv_inputs(dvDataStruct);
[dvDataStruct] = validate_dv_inputs(dvDataStruct);
[dvDataStruct] = compute_barycentric_corrected_timestamps(dvDataStruct, []);
dvDataStructOrig = dvDataStruct ;
nCadences = length(dvDataStruct.targetStruct.rawFluxTimeSeries.values);

% set up a thresholdCrossingEvent - one transit in the middle
thresholdCrossingEvent.epochMjd = dvDataStruct.dvCadenceTimes.midTimestamps(nCadences/2) ;
thresholdCrossingEvent.maxMultipleEventSigma = 1e12; % set these large to ensure range is used for depth
thresholdCrossingEvent.maxSingleEventSigma = 1e12;
thresholdCrossingEvent.orbitalPeriod = 3000; % one transit

progressReports = 1:ceil(nIterations/100):nIterations ;

targetFluxTimeSeries = dvDataStruct.targetStruct.correctedFluxTimeSeries;
targetFluxTimeSeries.gapIndicators = false(size(targetFluxTimeSeries.gapIndicators)) ;
targetFluxTimeSeries.values = zeros(nCadences,1) ;

for i=1:nIterations
    
    % spit out progress info
    if ( ismember( i, progressReports ) && debugLevel >= 0 )
        disp( [ 'starting loop iteration number ', num2str(i), ...
            ' out of ', num2str(nIterations),' total loop iterations' ] ) ;
        pause(1) ;
    end
     
    % prepare flux for transit model generation - this just sets the
    % transit depth
    
    % sample the depth and inject into flux so code picks it up
    iDepth = randi([1 length(allowedDepthsSigma)],1,1) ;
    iDepth = allowedDepthsSigma(iDepth);
    %iDepth = allowedDepthsSigma;
    targetFluxTimeSeries.values(1500) = -iDepth ;
    
    % set the duration
    thresholdCrossingEvent.trialTransitPulseDuration = modelDuration;
    
    % grab a random set of stellar parameters for limb darkening
    iStellarParams = randi([1 nStellarParams],1,1);
    dvDataStruct = dvDataStructOrig ;
    dvDataStruct.targetStruct.log10SurfaceGravity.value = stellarParameters.log10SurfaceGravity(iStellarParams) ;
    dvDataStruct.targetStruct.effectiveTemp.value = stellarParameters.effectiveTemp(iStellarParams) ;
    dvDataStruct.targetStruct.log10Metallicity.value = stellarParameters.log10Metallicity(iStellarParams) ;
    
    % make the object
    dvDataObject = dvDataClass(dvDataStruct);
    
    % get a uniform, random impact parameter
    iImpactParam = randi([1 length(impactParameters)],1,1) ;
    impactParameterSeed = impactParameters(iImpactParam) ;

    % generate the transitModel struct
    transitModel = convert_tps_parameters_to_transit_model(dvDataObject, 1, ...
        thresholdCrossingEvent, targetFluxTimeSeries, impactParameterSeed);
    
    % generate the transitObject
    transitObject = transitGeneratorCollectionClass( transitModel, 0 ) ;
    
    % generate the astrophysical model
    transitModelValues = generate_planet_model_light_curve( transitObject );
    
    % trim
    transitModelValues = transitModelValues(transitModelValues ~= 0) ;
    
    if isequal(i,1)
        monteCarloResults = zeros(nIterations, length(transitModelValues) + 2 );
    end
    
    % normalize the models and store with zero padding
    monteCarloResults(i,2:end-1) = transitModelValues ./ abs(min(transitModelValues)) ;

end

% generate the masterPulse

masterPulse = mean(monteCarloResults,1);
masterPulse = masterPulse(:);

% generate the best fit polynomial

x = ( 1:length(masterPulse) )' ;
polyCoeffs = polyfit(x, masterPulse, min(length(x) - 3, 25) ) ;

if (debugLevel >= 0)
    figure;
    plot(x,masterPulse,'-o')
    hold on
    f = polyval(polyCoeffs, x) ;
    plot(x,f,'rx')
end

% now mirror and average the fit together to generate a symmetric pulse


return