function [dvResultsStruct, converged, secondaryConverged, alertMessageStruct] = perform_whitening_and_model_fitting( ...
    dvDataObject, dvResultsStruct, thresholdCrossingEvent, iTarget, iPlanet, oddEvenFlag, fitTimeoutDatenum, refTime, ...
    impactParameterSeed, reducedParameterFitsEnabled)
%
% perform_whitening_and_model_fitting -- whiten the flux time series and fit a transiting planet model to it
%
% Version date:  2015-April-09.
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
%    2016-July-25, JL:
%        Seed reduced parameter fits with TCE parameters
%    2015-April-09, JL:
%        Add input argument 'whitenedModelGapIndicators' in the method
%        fill_planet_results_struct
%    2014-November-26, JL:
%       Seed all-odd-even transits fit in the order of reducedParameterFit - trapezoidalFit - TCE
%    2014-October-23, JL:
%       Seed all-odd-even transits fit in the order of trapezoidalFit - reducedParameterFit - TCE
%    2014-September-16, JL:
%       Initial release.
%
%=========================================================================================

% extract some data which is buried deep in various structures for convenience

targetResultsStruct                      = dvResultsStruct.targetResultsStruct(iTarget);
targetFluxTimeSeries                     = targetResultsStruct.residualFluxTimeSeries;

trialTransitPulseDuration                = thresholdCrossingEvent.trialTransitPulseDuration ;

ancillaryDesignMatrixConfigurationStruct = dvDataObject.ancillaryDesignMatrixConfigurationStruct;
pdcConfigurationStruct                   = dvDataObject.pdcConfigurationStruct;
saturationSegmentConfigurationStruct     = dvDataObject.saturationSegmentConfigurationStruct;
gapFillConfigurationStruct               = dvDataObject.gapFillConfigurationStruct;
tpsConfigurationStruct                   = dvDataObject.tpsConfigurationStruct;

keplerId                                 = dvDataObject.targetStruct(iTarget).keplerId ;
outlierIndices                           = dvDataObject.targetStruct(iTarget).outliers.indices;
discontinuityIndices                     = dvDataObject.targetStruct(iTarget).discontinuityIndices;

transitDurationMultiplier                = dvDataObject.planetFitConfigurationStruct.transitDurationMultiplier;
deemphasisWeightsEnabled                 = dvDataObject.planetFitConfigurationStruct.deemphasisWeightsEnabled;

fitterTransitRemovalBufferTransits       = dvDataObject.planetFitConfigurationStruct.fitterTransitRemovalBufferTransits ;

bufKeplerIds                             = [dvDataObject.barycentricCadenceTimes.keplerId];
barycentricCadenceTimes                  = dvDataObject.barycentricCadenceTimes(keplerId==bufKeplerIds);

robustFitEnabled                         = dvDataObject.planetFitConfigurationStruct.robustFitEnabled ;
if reducedParameterFitsEnabled
    robustFitEnabled = false;
end
if robustFitEnabled
    iterLimit = 2;
else
    iterLimit = 1;
end

% load the conditioned ancillary data file

load(dvDataObject.conditionedAncillaryDataFile, 'conditionedAncillaryDataArray');

% get the cadence labels for the whitening filter model

  cadenceQuarterLabels = get_intra_quarter_cadence_labels( dvDataObject.dvCadenceTimes.quarters, ...
      dvDataObject.targetStruct.rawFluxTimeSeries.gapIndicators );

% Seed the fitter with TCE data or fit parameters from trapezoidal fit/reduced parameter fit 

transitModel = convert_tps_parameters_to_transit_model(dvDataObject, iTarget, thresholdCrossingEvent, targetFluxTimeSeries, impactParameterSeed);

seededWithPriorFitFlag = false;

trapezoidalModelFittingEnabled = dvDataObject.planetFitConfigurationStruct.trapezoidalModelFitEnabled;

if oddEvenFlag == 0
      
      reducedParameterFits = dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).reducedParameterFits;
      if isempty(reducedParameterFits)
          validChiSquareArray = [];
      else
          modelChiSquareArray       = [reducedParameterFits.modelChiSquare];
          validChiSquareArray       = modelChiSquareArray(modelChiSquareArray>0);
      end
     
      if ~reducedParameterFitsEnabled && ~isempty(validChiSquareArray)
      
          transitModel.planetModel = seed_planet_model_with_reduced_parameter_fits(dvDataObject, dvResultsStruct, iTarget, iPlanet, transitModel.planetModel);
          
%     elseif trapezoidalModelFittingEnabled && dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).trapezoidalFit.fullConvergence
      
%         transitModel.planetModel = seed_planet_model_with_trapezoidal_fit(dvDataObject, dvResultsStruct, iTarget, iPlanet, transitModel.planetModel, reducedParameterFitsEnabled, impactParameterSeed);
      
      else
      
          if reducedParameterFitsEnabled
          
              disp(' ');
              disp(['  Seed planet model with TCE parameters with fixed impact parameter ' num2str(transitModel.planetModel.minImpactParameter)]);
              disp(' ');

          else
    
              disp(' ');
              disp('  Seed planet model with TCE parameters');
              disp(' ');
          
          end
      
      end
  
end

if strcmp(dvDataObject.dvConfigurationStruct.transitModelName, 'mandel-agol_geometric_transit_model')
    fitType = 12;         % DV fitter in the   whitened domain
else
    fitType = 1 ;
end

if ( oddEvenFlag > 0 )
    [transitModel, fitType] = compute_odd_even_transit_model( transitModel, targetResultsStruct.planetResultsStruct(iPlanet), trapezoidalModelFittingEnabled, ...
                                                              dvDataObject.planetFitConfigurationStruct.reducedParameterFitsEnabled );
end

transitObject = transitGeneratorCollectionClass( transitModel, oddEvenFlag ) ;

% Update the limb darkening coefficient values in the DV results structure

if oddEvenFlag == 0
    
    limbDarkeningCoefficients = get(transitObject, 'limbDarkeningCoefficients');
    limbDarkeningStruct       = dvResultsStruct.targetResultsStruct(iTarget).limbDarkeningStruct;
    
    for iTable = 1 : length(limbDarkeningStruct)
        
        if limbDarkeningStruct(iTable).coefficient1==0 && limbDarkeningStruct(iTable).coefficient2==0 && limbDarkeningStruct(iTable).coefficient3==0 && limbDarkeningStruct(iTable).coefficient4==0
            
            limbDarkeningStruct(iTable).coefficient1 = limbDarkeningCoefficients(1);
            limbDarkeningStruct(iTable).coefficient2 = limbDarkeningCoefficients(2);
            limbDarkeningStruct(iTable).coefficient3 = limbDarkeningCoefficients(3);
            limbDarkeningStruct(iTable).coefficient4 = limbDarkeningCoefficients(4);
            
        end
        
    end
    
    dvResultsStruct.targetResultsStruct(iTarget).limbDarkeningStruct = limbDarkeningStruct;
    
end

% Remove the trend from the target flux time series.

originalTargetFluxTimeSeries = targetFluxTimeSeries;
if dvDataObject.planetFitConfigurationStruct.cotrendingEnabled
    targetFluxTimeSeries = remove_timeseries_trend( conditionedAncillaryDataArray, targetFluxTimeSeries, ancillaryDesignMatrixConfigurationStruct, ...
                                                    pdcConfigurationStruct, saturationSegmentConfigurationStruct, gapFillConfigurationStruct );
end

%     Gap the in-transit cadences

fitterTransitRemovalMethod = 1;
residualFluxTimeSeries = remove_transit_signature_from_flux_time_series(targetFluxTimeSeries, transitObject, fitterTransitRemovalMethod, fitterTransitRemovalBufferTransits);

%     Generate the whitening filter

whiteningFilterModel   = generate_whitening_filter_model(residualFluxTimeSeries.values, residualFluxTimeSeries.gapIndicators, trialTransitPulseDuration, gapFillConfigurationStruct, tpsConfigurationStruct, cadenceQuarterLabels);
whiteningFilterObject  = whiteningFilterClass( whiteningFilterModel );

whitenedFluxTimeSeries = generate_whitened_flux_time_series_struct( whiteningFilterObject, targetFluxTimeSeries);

%     Compute the deemphasis weights

if deemphasisWeightsEnabled
    deemphasisWeights = compute_deemphasis_weights(dvDataObject, whitenedFluxTimeSeries, outlierIndices, discontinuityIndices);
else
    deemphasisWeights = ones(length(whitenedFluxTimeSeries.values), 1);
end

doRobustFit             = false ;
cadencesUsed            = [];

% Construct the struct for instantiation for the transitFitClass object

transitFitResultStruct  = [];
transitFitStruct.targetFluxTimeSeries       = targetFluxTimeSeries;
transitFitStruct.barycentricCadenceTimes    = barycentricCadenceTimes;

transitFitStruct.whitenedFluxTimeSeries     = whitenedFluxTimeSeries;
transitFitStruct.whiteningFilterModel       = whiteningFilterModel;
transitFitStruct.transitGeneratorObject     = transitObject;
transitFitStruct.deemphasisWeights          = deemphasisWeights;
transitFitStruct.debugLevel                 = dvDataObject.dvConfigurationStruct.debugLevel;
transitFitStruct.configurationStruct        = dvDataObject.planetFitConfigurationStruct;

if exist( 'fitTimeoutDatenum', 'var' ) && ~isempty( fitTimeoutDatenum )
    transitFitStruct.configurationStruct.fitTimeoutDatenum       = fitTimeoutDatenum;
else
    transitFitStruct.configurationStruct.fitTimeoutDatenum       = inf;
end
transitFitStruct.configurationStruct.robustFitEnabled            = doRobustFit;
transitFitStruct.configurationStruct.reducedParameterFitsEnabled = reducedParameterFitsEnabled;

% Set lower/upper bounds of fitted parameters by hard-coding in v7.0.
% They will be included in module parameters in the future versions.

if ~isfield(transitFitStruct.configurationStruct, 'transitEpochBkjdLowerBound')
    transitFitStruct.configurationStruct.transitEpochBkjdLowerBound = -inf;
end
if ~isfield(transitFitStruct.configurationStruct, 'transitEpochBkjdUpperBound')
    transitFitStruct.configurationStruct.transitEpochBkjdUpperBound =  inf;
end
if ~isfield(transitFitStruct.configurationStruct, 'ratioPlanetRadiusToStarRadiusLowerBound')
    %transitFitStruct.configurationStruct.ratioPlanetRadiusToStarRadiusLowerBound = 1e-6;
    transitFitStruct.configurationStruct.ratioPlanetRadiusToStarRadiusLowerBound = -inf;
end
if ~isfield(transitFitStruct.configurationStruct, 'ratioPlanetRadiusToStarRadiusUpperBound')
    transitFitStruct.configurationStruct.ratioPlanetRadiusToStarRadiusUpperBound =  inf;
end
if ~isfield(transitFitStruct.configurationStruct, 'ratioSemiMajorAxisToStarRadiusLowerBound')
    transitFitStruct.configurationStruct.ratioSemiMajorAxisToStarRadiusLowerBound = 1.0;
    %transitFitStruct.configurationStruct.ratioSemiMajorAxisToStarRadiusLowerBound = -inf;
end
if ~isfield(transitFitStruct.configurationStruct, 'ratioSemiMajorAxisToStarRadiusUpperBound')
    transitFitStruct.configurationStruct.ratioSemiMajorAxisToStarRadiusUpperBound =  inf;
end
if ~isfield(transitFitStruct.configurationStruct, 'minImpactParameterLowerBound')
    transitFitStruct.configurationStruct.minImpactParameterLowerBound = -inf;
end
if ~isfield(transitFitStruct.configurationStruct, 'minImpactParameterUpperBound')
    transitFitStruct.configurationStruct.minImpactParameterUpperBound =  inf;
end
if ~isfield(transitFitStruct.configurationStruct, 'orbitalPeriodDaysLowerBound')
    %transitFitStruct.configurationStruct.orbitalPeriodDaysLowerBound  =  0;
    transitFitStruct.configurationStruct.orbitalPeriodDaysLowerBound  =  -inf;
end
if ~isfield(transitFitStruct.configurationStruct, 'orbitalPeriodDaysUpperBound')
    transitFitStruct.configurationStruct.orbitalPeriodDaysUpperBound  =   inf;
end
if ~isfield(transitFitStruct.configurationStruct, 'transitDurationHoursLowerBound')
    transitFitStruct.configurationStruct.transitDurationHoursLowerBound  = 0.5;
end
if ~isfield(transitFitStruct.configurationStruct, 'transitDurationHoursUpperBound')
    transitFitStruct.configurationStruct.transitDurationHoursUpperBound  =  inf;
end

transitFitStruct.configurationStruct.impactParameterRangeZeroToOne = true;

% Save transitEpochBkjd and orbitalPeriodDays from TCE to check fit results later. Ajdust transitEpochBkjd if necessary

transitEpochBkjdTce  = thresholdCrossingEvent.epochMjd - kjd_offset_from_mjd;
orbitalPeriodDaysTce = thresholdCrossingEvent.orbitalPeriod;

epochOffsetPeriods = 0;
while ( transitEpochBkjdTce + epochOffsetPeriods*orbitalPeriodDaysTce ) < barycentricCadenceTimes.startTimestamps(1)
    epochOffsetPeriods = epochOffsetPeriods + 1;
end

transitFitStruct.configurationStruct.transitEpochBkjdTce    = transitEpochBkjdTce + epochOffsetPeriods*orbitalPeriodDaysTce;
transitFitStruct.configurationStruct.orbitalPeriodDaysTce   = orbitalPeriodDaysTce;

transitFitStruct.configurationStruct.cadencesUsedFixedFlag  = false;
transitFitStruct.configurationStruct.cadencesUsed           = cadencesUsed;


% begin the iterative process

converged                     = false;
secondaryConverged            = false;
alertMessageStruct.identifier = '';
alertMessageStruct.message    = '';

nIter = 0;
transitFitObjectLastIter = [];
whitenedModel = zeros(size(targetFluxTimeSeries.values));
whitenedModelGapIndicators = (cadenceQuarterLabels == -1);
loopStartTimestamp = clock;

defaultPeriod = transitModel.planetModel.orbitalPeriodDays;


while nIter < iterLimit
    
    nIter = nIter + 1 ;
    
    iterationStartTimestamp = clock ;
    disp( ['      Starting fitting iteration ', num2str(nIter)] ) ;
    
    %     test the transit object to see if its light curve is identically zero, if so return with an alert message
    
    transitModelValues = generate_planet_model_light_curve( transitObject );
    
    if all( transitModelValues( isfinite(transitModelValues) & isreal(transitModelValues) ) == 0 )
        
        if secondaryConverged
            
            dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet) = ...
                fill_planet_results_struct( transitFitObjectLastIter, dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet), ...
                whitenedModel, whitenedModelGapIndicators, converged, seededWithPriorFitFlag );
            
        end
        
        alertMessageStruct.identifier = 'dv:performWhiteningAndModelFitting:lightCurveAllZeroes';
        alertMessageStruct.message    = 'perform_whitening_and_model_fitting: last-iter transit model light curve is identically zero';
        
        return
        
    end
    
    transitFitStruct.transitGeneratorObject               = transitObject;
    transitFitStruct.configurationStruct.robustFitEnabled = doRobustFit;
   
    transitFitObject = transitFitClass( transitFitStruct, fitType );
    
    %     perform the fit
    try
        
        if doRobustFit
            disp('      Robust fitting:') ;
        end
        
        transitFitObject = fit_transit( transitFitObject );
        
    catch
        
        lastError = lasterror;
        
        if oddEvenFlag==0
            eval(['save fitResult_target_' num2str(iTarget) '_planet_' num2str(iPlanet) '_all.mat     transitFitResultStruct']);
        elseif oddEvenFlag==1
            eval(['save fitResult_target_' num2str(iTarget) '_planet_' num2str(iPlanet) '_oddEven.mat transitFitResultStruct']);
        end
        
        if secondaryConverged
            
            dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet) = ...
                fill_planet_results_struct( transitFitObjectLastIter, dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet), ...
                whitenedModel, whitenedModelGapIndicators, converged, seededWithPriorFitFlag );
            
        end
        
        alertMessageStruct.identifier = lastError.identifier;
        alertMessageStruct.message    = lastError.message;
        
        return
        
    end
    
    converged                = true;
    secondaryConverged       = true;
    doRobustFit              = robustFitEnabled ;
    transitFitObjectLastIter = transitFitObject;
    
    % generate and save figures
    
    targetTableDataStruct    = dvDataObject.targetTableDataStruct;
    cadenceNumbers           = dvDataObject.dvCadenceTimes.cadenceNumbers;
    generate_transit_fit_plots( transitFitObject, originalTargetFluxTimeSeries, targetTableDataStruct, cadenceNumbers, dvResultsStruct.targetResultsStruct(iTarget).dvFiguresRootDirectory, ...
                                keplerId, iPlanet, defaultPeriod, impactParameterSeed, reducedParameterFitsEnabled, transitDurationMultiplier, true);
    
    fitConfigurationStruct   = get(transitFitObject, 'configurationStruct');
    chiSquare                = get(transitFitObject, 'chisq');
    allTransitSnr            = get(transitFitObject, 'allTransitSnr');
    oddTransitSnr            = get(transitFitObject, 'oddTransitSnr');
    evenTransitSnr           = get(transitFitObject, 'evenTransitSnr');
    parameterValues          = get(transitFitObject, 'finalParValues');
    fitType                  = get(transitFitObject, 'fitType');
    transitObject            = get_fitted_transit_object( transitFitObject ) ;

    whitenedModel            = model_function(transitFitObject, parameterValues, true, true);
    cadencesUsed             = fitConfigurationStruct.cadencesUsed;
    
    transitFitResultStruct(nIter).iTarget                       = iTarget;
    transitFitResultStruct(nIter).iPlanet                       = iPlanet;
    transitFitResultStruct(nIter).oddEvenFlag                   = oddEvenFlag;
    transitFitResultStruct(nIter).fitType                       = fitType;
    transitFitResultStruct(nIter).whitenedFluxTimeSeriesValues  = whitenedFluxTimeSeries.values;
    transitFitResultStruct(nIter).whitenedModelTimeSeriesValues = whitenedModel;
    transitFitResultStruct(nIter).cadenceUsed                   = cadencesUsed;
    transitFitResultStruct(nIter).converged                     = converged;
    transitFitResultStruct(nIter).secondaryConverged            = secondaryConverged;
    transitFitResultStruct(nIter).doRobustFit                   = doRobustFit;
    transitFitResultStruct(nIter).chiSquare                     = chiSquare;
    if oddEvenFlag==0
        transitFitResultStruct(nIter).modelFitSnr               = allTransitSnr;
    elseif oddEvenFlag==1
        transitFitResultStruct(nIter).modelFitSnr               = [oddTransitSnr evenTransitSnr];
    end
    transitFitResultStruct(nIter).parameterValues                = parameterValues;
    
    disp(['      refTime ' num2str(etime(clock, refTime), '%6.2f') ' seconds : convergenceFlag = ' num2str(converged) ', secondaryConvergenceFlag = ' num2str(secondaryConverged)]);
    if oddEvenFlag==0
        
        if ~reducedParameterFitsEnabled && length(parameterValues)==5
            disp(['         chiSquare = ' num2str(chiSquare)]);
            disp(['         parameterValues:   transitEpochBkjd_all  = '               num2str(parameterValues(1)) ...
                ', orbitalPeriodDays_all  = '              num2str(parameterValues(5)) ...
                ', ratioPlanetRadiusToStarRadius_all  = '  num2str(parameterValues(2)) ...
                ', ratioSemiMajorAxisToStarRadius_all  = ' num2str(parameterValues(3)) ...
                ', minImpactParameter_all  = '             num2str(parameterValues(4))]);
        elseif reducedParameterFitsEnabled && length(parameterValues)==4
            disp(['         chiSquare = ' num2str(chiSquare)]);
            disp(['         parameterValues:   transitEpochBkjd_all  = '               num2str(parameterValues(1)) ...
                ', orbitalPeriodDays_all  = '              num2str(parameterValues(4)) ...
                ', ratioPlanetRadiusToStarRadius_all  = '  num2str(parameterValues(2)) ...
                ', ratioSemiMajorAxisToStarRadius_all  = ' num2str(parameterValues(3))]);
        end
        
    elseif oddEvenFlag==1 && length(parameterValues)==10
        
        disp(['         chiSquare = ' num2str(chiSquare)]);
        disp(['         parameterValues:   transitEpochBkjd_odd  = '               num2str(parameterValues(1)) ...
            ', orbitalPeriodDays_odd  = '              num2str(parameterValues(5)) ...
            ', ratioPlanetRadiusToStarRadius_odd  = '  num2str(parameterValues(2)) ...
            ', ratioSemiMajorAxisToStarRadius_odd  = ' num2str(parameterValues(3)) ...
            ', minImpactParameter_odd  = '             num2str(parameterValues(4))]);
        disp(['                            transitEpochBkjd_even = '               num2str(parameterValues(6)) ...
            ', orbitalPeriodDays_even = '              num2str(parameterValues(10)) ...
            ', ratioPlanetRadiusToStarRadius_even = '  num2str(parameterValues(7)) ...
            ', ratioSemiMajorAxisToStarRadius_even = ' num2str(parameterValues(8)) ...
            ', minImpactParameter_even = '             num2str(parameterValues(9))]);
        
    end
    disp(['      Iteration ',num2str(nIter),' completed, elapsed time ', num2str( etime( clock, iterationStartTimestamp ) ), ' seconds']);
    
end % while not converged loop

disp( ['      Converged on iteration ',num2str(nIter),' after ', num2str( etime( clock, loopStartTimestamp ) ),' seconds from beginning of iterative whitening and model fitting loop'] );

transitFitResultStruct(end).whitenedFluxTimeSeriesValues  = whitenedFluxTimeSeries.values;
transitFitResultStruct(end).whitenedModelTimeSeriesValues = whitenedModel;
transitFitResultStruct(end).cadenceUsed                   = cadencesUsed;

if oddEvenFlag==0
    if ~reducedParameterFitsEnabled
        eval(['save fitResult_target_' num2str(iTarget) '_planet_' num2str(iPlanet) '_all.mat     transitFitResultStruct']);
    else
        eval(['save fitResult_target_' num2str(iTarget) '_planet_' num2str(iPlanet) '_fit_with_fixed_impact_parameter_' num2str(impactParameterSeed, '%1.2f') '.mat transitFitResultStruct']);
    end
elseif oddEvenFlag==1
    eval(['save fitResult_target_' num2str(iTarget) '_planet_' num2str(iPlanet) '_oddEven.mat transitFitResultStruct']);
end

% fill the result struct information related to the planet fit

dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet) = ...
    fill_planet_results_struct( transitFitObject, dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet), whitenedModel, whitenedModelGapIndicators, converged, seededWithPriorFitFlag );

return
