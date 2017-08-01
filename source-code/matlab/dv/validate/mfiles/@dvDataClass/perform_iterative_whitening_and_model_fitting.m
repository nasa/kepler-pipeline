function [dvResultsStruct, converged, secondaryConverged, alertMessageStruct] = perform_iterative_whitening_and_model_fitting( ...
                             dvDataObject, dvResultsStruct, thresholdCrossingEvent, iTarget, iPlanet, oddEvenFlag, fitTimeoutDatenum, refTime, ...
                             impactParameterSeed, reducedParameterFitsEnabled)
%
% perform_iterative_whitening_and_model_fitting -- whiten the flux time series for a star
% and fit a transiting planet model to it
%
% dvResultsStruct = perform_iterative_whitening_and_model_fitting( dvDataObject,
%    dvResultsStruct, thresholdCrossingEvent, iTarget, iPlanet, oddEvenFlag,
%    fitTimeoutDatenum ) performs whitening and transit model fitting on target iTarget
%    for planet iPlanet.  This is mainly just an execution sketch to contextualize all the
%    bits and pieces and may be replaced in its entirety soon, if we are lucky.
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
%    2015-February-17, SS:
%       Add cadenceQuarterLabel vector to the whiteningFilterClass
%    2014-November-26, JL:
%       Seed all-odd-even transits fit in the order of reducedParameterFit - trapezoidalFit - TCE
%    2014-October-23, JL:
%       Seed all-odd-even transits fit in the order of trapezoidalFit - reducedParameterFit - TCE
%    2014-April-10, JL:
%       If reduced parameter fit is enabled, seed odd-even transit fitter with parameters from
%       the reduced parameter fit with minimum chi-square metric
%    2013-August-08, JL:
%       Retrieve deemphasisWeightsEnabled from dvDataObject
%    2013-April-30, JL:
%       Adjust transitEpochBkjd so that it is always larger than the start of unit of work
%    2013-April-04, JL:
%       Add deemphasisWeights in transitFitStruct
%    2013-March-13, JL:
%       Add TCE values of 'transitEpochBkjd' and 'orbitalPeriodDays' in transitFitStruct.configurationStruct 
%    2013-February-20, JL:
%       Fill planet result structure when light curve are all zeroes and 'secondaryConverged' is true
%    2013-January-24, JL:
%       Clean the variable 'whitenerScaleFactor' and related whitenedFluxTimeSeries.uncertainties
%    2012-December-13, JL:
%       Add module parameter 'iterationToFreezeCadencesForFit'
%    2012-December-06, JL:
%       Set ratioSemiMajorAxisToStarRadiusLowerBound to 1
%    2012-November-27, JL:
%       Added 'defaultPeriod' argument to generate_transit_fit_plots
%    2012-October-29, JL:
%       Generate fitter diagnostic plots in each iteration of whitening and
%       model fitting
%    2012-October-03, JL:
%       Added module parameter 'cotrendingEnabled'
%       Added 'whitenedModel' argument to fill_planet_results_struct
%    2012-September-21, JT:
%       Added transitDurationMultiplier argument to generate_transit_fit_plots
%    2012-August-23, JL:
%       Move calculation of equilibrium temprature to transitGeneratorClass
%    2012-July-05, JL:
%       Implement the reduced parameter fit algorithm
%    2012-May-16, JL:
%       Add computation of equilibrium temperature.
%    2012-April-16, JL:
%       Always save transitFitResultStruct.whitenedModelTimeSeriesValues at the final iteration
%    2012-March-27, JL:
%       Always save transitFitResultStruct.whitenedFluxTimeSeriesValues at the final iteration
%    2012-March-15, JL:
%       Add the function to seed planet model with parameters of prior fits.
%    2012-February-08, JL:
%       Continue multiple planet search when allTransitsFit fails
%    2011-November-09, JL:
%       Add and save metrics 'relativeVariationWhitenedFlux' and 'relativeVariationWhitenedFluxUsed'.
%    2011-November-02, JL:
%       Change 'saveTimeSeriesFlag' to 'saveTimeSeriesEnabled'.
%    2011-October-31, JL:
%       Add module parameters 'tightParameterConvergenceTolerance', 'looseParameterConvergenceTolerance',
%       'tightSecondaryParameterConvergenceTolerance', 'looseSecondaryParameterConvergenceTolerance',
%       'chiSquareConvergenceTolerance' and 'saveTimeSeriesFlag' in
%       dvDataObject.planetFitConfigurationStruct.
%    2011-October-03, JL:
%        generate an error when all 'finite and real' values of the light curve are zeros 
%    2011-August-19, JL:
%        add the flag 'impactParameterRangeZeroToOne' in transitFitStruct.configurationStruct
%        to indicate whether the fitted parameter 'minImpactParameter' will vary in the range
%        of [0, 1] or [0, 1+ratioPlanetRadiusToStarRadius]
%    2011-July-27, JL:
%        add timing messages
%    2011-June-28, JL:
%        set lower/upper bounds of fitted parameters to -inf and inf
%        add the field 'barycentricCadenceTimes' in transitFitStruct
%    2011-June-06, JL:
%        add the field 'cadenceDurationDays' in transitFitStruct.configurationStruct 
%        for modelFitSnr calculation
%    2011-March-31, JL:
%        In case of fullConvergence/secondaryConvergence, fill in the planet results struct
%        (including bounds check) first, then generate the transit fit plots
%        Set lower bound of orbitalPeriodDays to 0
%    2011-March-04, JL:
%        set lower bound of ratioPlanetRadiusToStarRadius to 1e-6
%    2011-February-18, JL:
%        add lower bound of derived parameter 'transitDurationHours'
%    2011-February-14, JL:
%        add lower/upper bounds to fitted parameters
%    2011-January-31, JL:
%        implement secondary convergence criterion
%    2011-January-21, JL:
%        Data is always fitted in whitened domain in DV. fitType is initially set to 12.
%    2010-Nov-05, JL:
%        Add fitter with geometric transit model.
%    2010-May-14, PT:
%        add originalTargetFluxTimeSeries to preserve PDC time series (since this method
%        does an additional detrending).  Use the original PDC flux in plots.
%    2010-May-07, PT:
%        change in signature of plot-generation method of transitFitClass.
%    2010-April-27, PT:
%        support for transitGeneratorCollectionClass and simultaneous fitting of odd and
%        even transits.
%    2010-January-06, PT:
%        support for parameter which dictates timeout of fitting.  End fitting if the
%        transitObject from the last iteration produces a light curve which is identically
%        zero.
%    2009-December-09, PT:
%        preserve gap indices passed into DV when constructing the whitened flux time
%        series.
%    2009-September-21, PT:
%        eliminate unused targetStruct member from transitFitClass.
%    2009-September-17, PT:
%        remove spaghetti plate convergence logic at end of loop, replace with a function
%        which does all the work.  Pass the transitObject directly to the fitter object,
%        instead of a model for creating the transitObject.
%    2009-September-14, PT:
%        use module parameters to control transit signature removal options.
%    2009-September-10, PT:
%        allow the # of iterations to expand if we switch to a different fit type or to
%        robust fitting.  Do not allow robust fitting to change fit types.
%    2009-September-09, PT:
%        add targetFluxTimeSeries to args for convert_tps_parameters_to_transit_model.
%    2009-September-04, PT:
%        get filled indices from the whitening filter object and put them to use.
%    2009-September-02, PT:
%        improvements to odd-even fitting and subtraction of model flux from the flux time
%        series.  Force odd-even fits to use the same fitType as the all-transits fit,
%        regardless of whether that fit would produce the best chisq.  Add handling for
%        exhausting the number of iterations.
%    2009-August-28, PT:
%        do fitting with the orbital period as a parameter first, then switch to fitting 
%        with an impact parameter afterwards if possible.
%    2009-August-20, PT:
%        perform a final set of iterations with robust fitting if the robust fit parameter
%        is set.
%    2009-August-17, PT:
%        support for fitting with the impact parameter or the orbital period as fit
%        parameters.
%    2009-August-03, PT:
%        support for planetModel fields eccentricity and longitudeOfPeri.
%    2009-May-15, PT:
%        change to use of residualFluxTimeSeries which has the median value normalized
%        out, and use of cached barycentric-corrected MJD timestamps.  Support of
%        debugLevel values and timing information.
%    2009-May-12, PT:
%        support for odd-only and even-only transit fitting
%    2009-May-11, PT:
%        correct expression which subtracts transit signatures from flux time series.
%
%=========================================================================================

% extract some data which is buried deep in various structures for convenience

  targetResultsStruct = dvResultsStruct.targetResultsStruct(iTarget) ;
  targetFluxTimeSeries = targetResultsStruct.residualFluxTimeSeries ;
  
  ancillaryDesignMatrixConfigurationStruct = ...
      dvDataObject.ancillaryDesignMatrixConfigurationStruct;
  pdcConfigurationStruct = dvDataObject.pdcConfigurationStruct ;
  saturationSegmentConfigurationStruct = ...
      dvDataObject.saturationSegmentConfigurationStruct;
  gapFillConfigurationStruct = dvDataObject.gapFillConfigurationStruct ;
  tpsConfigurationStruct = dvDataObject.tpsConfigurationStruct;
  
  trialTransitPulseDuration = thresholdCrossingEvent.trialTransitPulseDuration ;
  
  conditionedAncillaryDataFile = dvDataObject.conditionedAncillaryDataFile;
  
  keplerId = dvDataObject.targetStruct(iTarget).keplerId ;
  kicStarRadius = dvDataObject.targetStruct(iTarget).radius.value ;
  iterLimit = dvDataObject.planetFitConfigurationStruct.whitenerFitterMaxIterations ;
  robustFitEnabled = dvDataObject.planetFitConfigurationStruct.robustFitEnabled ;
  if reducedParameterFitsEnabled
      robustFitEnabled = false;
  end

  outlierIndices       = dvDataObject.targetStruct(iTarget).outliers.indices;
  discontinuityIndices = dvDataObject.targetStruct(iTarget).discontinuityIndices;
  
  tightParameterConvergenceTolerance          = dvDataObject.planetFitConfigurationStruct.tightParameterConvergenceTolerance;
  looseParameterConvergenceTolerance          = dvDataObject.planetFitConfigurationStruct.looseParameterConvergenceTolerance;
  tightSecondaryParameterConvergenceTolerance = dvDataObject.planetFitConfigurationStruct.tightSecondaryParameterConvergenceTolerance;
  looseSecondaryParameterConvergenceTolerance = dvDataObject.planetFitConfigurationStruct.looseSecondaryParameterConvergenceTolerance;
  chiSquareConvergenceTolerance               = dvDataObject.planetFitConfigurationStruct.chiSquareConvergenceTolerance;
  saveTimeSeriesEnabled                       = dvDataObject.planetFitConfigurationStruct.saveTimeSeriesEnabled;
  transitDurationMultiplier                   = dvDataObject.planetFitConfigurationStruct.transitDurationMultiplier;
  iterationToFreezeCadencesForFit             = dvDataObject.planetFitConfigurationStruct.iterationToFreezeCadencesForFit;
  deemphasisWeightsEnabled                    = dvDataObject.planetFitConfigurationStruct.deemphasisWeightsEnabled;
  
  fitterTransitRemovalMethod = ...
      dvDataObject.planetFitConfigurationStruct.fitterTransitRemovalMethod ;
  fitterTransitRemovalBufferTransits = ...
      dvDataObject.planetFitConfigurationStruct.fitterTransitRemovalBufferTransits ;

  bufKeplerIds = [dvDataObject.barycentricCadenceTimes.keplerId];
  barycentricCadenceTimes = dvDataObject.barycentricCadenceTimes(keplerId==bufKeplerIds);
  
% load the conditioned ancillary data file

  load(conditionedAncillaryDataFile, 'conditionedAncillaryDataArray');
  
% get the cadence labels for the whitening filter model

  cadenceQuarterLabels = get_intra_quarter_cadence_labels( dvDataObject.dvCadenceTimes.quarters, ...
      dvDataObject.targetStruct(iTarget).rawFluxTimeSeries.gapIndicators );

% if we are doing the all-transits fit then we currently have transit parameters estimated
% by TPS, which are in observable format (transit duration, period, and epoch in MJD).  We
% need to construct the "first-guess" transitModel now, which includes those parameters.

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

  
% When geometric transit model is not used, the requested fit type is initially fitting the orbital period
% and not the impact parameter if we are doing all-transit fits.
% When geometric transit model is used, fitType is set to 11 (DV fitter in the unwhitened domain);
% otherwise, fitType is set to 1

% Since there is no acceptable reason to fit the data in the unwhitened domain in DV, it is decided in
% a meeting by JJ, JT, PT and JL on January 21, 2011 that the data should always be fitted in the  
% whitened domain in DV.

  if strcmp(dvDataObject.dvConfigurationStruct.transitModelName, 'mandel-agol_geometric_transit_model')
%     fitType = 11;         % DV fitter in the unwhitened domain
      fitType = 12;         % DV fitter in the   whitened domain
  else
      fitType = 1 ;
  end
      
  if ( oddEvenFlag > 0 )
      
%     alternately, if we are on the odd- or even-transit fitting, then we can use the
%     fitted transit parameters from the reduced parameter fit with minimum chi-square
%     metric (if reduced parameetr fit is enabled) or the TCE parameters (if 
%     the reduced parameter fit is diabled) to generate the first-guess model of the
%     transit; also, we can gap and fill the flux time series for the transits which we
%     don't want to use (ie, gap the odd transits for the even-transit fitting, and
%     vice-versa).  While we are at it, figure out whether the fit should use the impact
%     parameter or the orbital period as fit parameters.

      [transitModel, fitType] = compute_odd_even_transit_model( transitModel, targetResultsStruct.planetResultsStruct(iPlanet), trapezoidalModelFittingEnabled, ...
                                                                dvDataObject.planetFitConfigurationStruct.reducedParameterFitsEnabled );
      
  end
  
  transitObject = transitGeneratorCollectionClass( transitModel, oddEvenFlag ) ;
  
% Update the limb darkening coefficient values in the DV results structure
% if this is the first all-transits fit for the given target. For now, set
% the LD coefficients identically for all target tables. If and when DV is
% updated with module output specific LD coefficients, the per target table
% coefficients will have to be set accordingly.

  if oddEvenFlag == 0
      limbDarkeningCoefficients = ...
          get(transitObject, 'limbDarkeningCoefficients');
      limbDarkeningStruct = ...
          dvResultsStruct.targetResultsStruct(iTarget).limbDarkeningStruct;
      for iTable = 1 : length(limbDarkeningStruct)
          if limbDarkeningStruct(iTable).coefficient1 == 0 && ...
                  limbDarkeningStruct(iTable).coefficient2 == 0 && ...
                  limbDarkeningStruct(iTable).coefficient3 == 0 && ...
                  limbDarkeningStruct(iTable).coefficient4 == 0
              limbDarkeningStruct(iTable).coefficient1 = ...
                  limbDarkeningCoefficients(1);
              limbDarkeningStruct(iTable).coefficient2 = ...
                  limbDarkeningCoefficients(2);
              limbDarkeningStruct(iTable).coefficient3 = ...
                  limbDarkeningCoefficients(3);
              limbDarkeningStruct(iTable).coefficient4 = ...
                  limbDarkeningCoefficients(4);
          end
      end
      dvResultsStruct.targetResultsStruct(iTarget).limbDarkeningStruct = ...
          limbDarkeningStruct;
  end
  
% Remove the trend from the target flux time series.
  
  originalTargetFluxTimeSeries = targetFluxTimeSeries;
  if dvDataObject.planetFitConfigurationStruct.cotrendingEnabled
      targetFluxTimeSeries = ...
          remove_timeseries_trend( conditionedAncillaryDataArray, ...
          targetFluxTimeSeries, ancillaryDesignMatrixConfigurationStruct, ...
          pdcConfigurationStruct, saturationSegmentConfigurationStruct, ...
          gapFillConfigurationStruct );
  end
  
% begin the iterative process

  converged                     = false;
  secondaryConverged            = false;
  alertMessageStruct.identifier = '';
  alertMessageStruct.message    = '';
  
  nIter = 0;
  transitFitObjectLastIter = [];
  whitenedFluxLastIter     = [];
  whitenedFluxUsedLastIter = [];
  bestTransitFitObjectOldType = [];
  whitenedModel = zeros(size(targetFluxTimeSeries.values));
  whitenedModelGapIndicators = (cadenceQuarterLabels == -1);
  loopStartTimestamp = clock;
  
  doRobustFit   = false ;
  defaultPeriod = transitModel.planetModel.orbitalPeriodDays;
  
  transitFitResultStruct = [];
  cadencesUsed           = [];
  
  while ~converged
      
      nIter = nIter + 1 ;
      
%     if the number of iterations is exhausted, retrun with an alert message.

      if nIter > iterLimit

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
          
%           targetTableDataStruct = dvDataObject.targetTableDataStruct;
%           cadenceNumbers        = dvDataObject.dvCadenceTimes.cadenceNumbers;
%           generate_transit_fit_plots( transitFitObjectLastIter,  originalTargetFluxTimeSeries, targetTableDataStruct, cadenceNumbers, ...
%               dvResultsStruct.targetResultsStruct(iTarget).dvFiguresRootDirectory, keplerId, iPlanet, impactParameterSeed, ...
%               reducedParameterFitsEnabled, transitDurationMultiplier, true );
%               
%         end
              
          alertMessageStruct.identifier = 'dv:performIterativeWhiteningAndModelFitting:iterationLimitExhausted';
          alertMessageStruct.message    = 'perform_iterative_whitening_and_model_fitting: limit on iterations exhausted';
              
          return
              
      end
      
      iterationStartTimestamp = clock ;
      disp( ['      Starting whitening / fitting iteration ', num2str(nIter)] ) ;
      
%     test the transit object to see if its light curve is identically zero, if so return with an alert message

      lightCurveLastIteration = generate_planet_model_light_curve( transitObject );
      
      if all( lightCurveLastIteration( isfinite(lightCurveLastIteration) & isreal(lightCurveLastIteration) ) == 0 )
          
          if secondaryConverged
              
              dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet) = ...
                  fill_planet_results_struct( transitFitObjectLastIter, dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet), ...
                    whitenedModel, whitenedModelGapIndicators, converged, seededWithPriorFitFlag );

          end

          alertMessageStruct.identifier = 'dv:performIterativeWhiteningAndModelFitting:lightCurveAllZeroes';
          alertMessageStruct.message    = 'perform_iterative_whitening_and_model_fitting: last-iter transit model light curve is identically zero';
              
          return

      end
            
%     subtract the model transit from the flux time series to get a residual time series
      
      residualFluxTimeSeries = remove_transit_signature_from_flux_time_series(targetFluxTimeSeries, transitObject, fitterTransitRemovalMethod, fitterTransitRemovalBufferTransits);
      
%     compute the whitening filter parameters

      whiteningFilterModel = generate_whitening_filter_model(residualFluxTimeSeries.values, residualFluxTimeSeries.gapIndicators, trialTransitPulseDuration, ...
                                                             gapFillConfigurationStruct, tpsConfigurationStruct, cadenceQuarterLabels);
      
%     apply the whitening filter to the target flux time series including the transit. 
%     the whitener does *not* update the uncertainties in the whitened time series,
%     but it does ostensibly produce a whitened time series with uncorrelated samples.
%     Since the whitener also performs a scale transformation on the time series, apply
%     that scale transformation to the uncertainties in the fit, so that chisq will come
%     out correctly.

      whiteningFilterObject = whiteningFilterClass( whiteningFilterModel ) ;
      transitModelValues = generate_planet_model_light_curve( transitObject );
      
      [whitenedResidualFluxValues, whitenedTransitModelValues] = ...
          whiten_time_series( whiteningFilterObject, transitModelValues ) ;
      whitenedFluxTimeSeries.values = ...
          whitenedResidualFluxValues + whitenedTransitModelValues ;
      whitenedFluxTimeSeries.gapIndicators = ...
          false(size(whitenedFluxTimeSeries.values));
      newFilledIndices = get( whiteningFilterObject, 'filledIndices' ) ;
      whitenedFluxTimeSeries.filledIndices = unique( [newFilledIndices(:) ; ...
          residualFluxTimeSeries.filledIndices(:)] ) ;      

%     Compute the deemphasis weights
  
      if deemphasisWeightsEnabled
          deemphasisWeights = compute_deemphasis_weights(dvDataObject, whitenedFluxTimeSeries, outlierIndices, discontinuityIndices);
      else
          deemphasisWeights = ones(length(whitenedFluxTimeSeries.values), 1);
      end
  
%     construct the struct for instantiation for the transitFitClass object

%     When geometric transit model is used, fitTYpe is changed to 12 (DV fitter in the whitened domain)
%     in the 2nd loop of iterative whitening and model fitting, and targetFluxTimeSeries is added to 
%     transitFitStruct

      if strcmp(dvDataObject.dvConfigurationStruct.transitModelName, 'mandel-agol_geometric_transit_model')
          
          for i=1:length(fitType)
              if (fitType(i)==11)&&(nIter>1)
                fitType(i)=12;
              end
          end
      
          transitFitStruct.targetFluxTimeSeries    = targetFluxTimeSeries;
          transitFitStruct.barycentricCadenceTimes = barycentricCadenceTimes;
          
      end

      transitFitStruct.whitenedFluxTimeSeries = whitenedFluxTimeSeries;
      transitFitStruct.whiteningFilterModel   = whiteningFilterModel;
      transitFitStruct.transitGeneratorObject = transitObject;
      transitFitStruct.deemphasisWeights      = deemphasisWeights;
      transitFitStruct.debugLevel             = dvDataObject.dvConfigurationStruct.debugLevel;

      transitFitStruct.configurationStruct = dvDataObject.planetFitConfigurationStruct;
      if exist( 'fitTimeoutDatenum', 'var' ) && ~isempty( fitTimeoutDatenum )
          transitFitStruct.configurationStruct.fitTimeoutDatenum = fitTimeoutDatenum;
      else
          transitFitStruct.configurationStruct.fitTimeoutDatenum = inf;
      end
      transitFitStruct.configurationStruct.robustFitEnabled = doRobustFit;
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
      
      % Set flag impactParameterRangeZeroToOne by HARD-CODING IN v8.0.
      % It will be included in module parameters in the future versions.
      transitFitStruct.configurationStruct.impactParameterRangeZeroToOne                = true;
      transitFitStruct.configurationStruct.tightParameterConvergenceTolerance           = tightParameterConvergenceTolerance;
      transitFitStruct.configurationStruct.looseParameterConvergenceTolerance           = looseParameterConvergenceTolerance;
      transitFitStruct.configurationStruct.tightSecondaryParameterConvergenceTolerance  = tightSecondaryParameterConvergenceTolerance;
      transitFitStruct.configurationStruct.looseSecondaryParameterConvergenceTolerance  = looseSecondaryParameterConvergenceTolerance;
      transitFitStruct.configurationStruct.chiSquareConvergenceTolerance                = chiSquareConvergenceTolerance;
      
      % Save transitEpochBkjd and orbitalPeriodDays from TCE to check fit results later. Ajdust transitEpochBkjd if necessary
      transitEpochBkjdTce  = thresholdCrossingEvent.epochMjd - kjd_offset_from_mjd;
      orbitalPeriodDaysTce = thresholdCrossingEvent.orbitalPeriod;
     
      epochOffsetPeriods = 0;
      while ( transitEpochBkjdTce + epochOffsetPeriods*orbitalPeriodDaysTce ) < barycentricCadenceTimes.startTimestamps(1)
          epochOffsetPeriods = epochOffsetPeriods + 1;
      end
      
      transitFitStruct.configurationStruct.transitEpochBkjdTce  = transitEpochBkjdTce + epochOffsetPeriods*orbitalPeriodDaysTce;
      transitFitStruct.configurationStruct.orbitalPeriodDaysTce = orbitalPeriodDaysTce;
      
      if nIter>iterationToFreezeCadencesForFit
          transitFitStruct.configurationStruct.cadencesUsedFixedFlag = true;
      else
          transitFitStruct.configurationStruct.cadencesUsedFixedFlag = false;
      end
      transitFitStruct.configurationStruct.cadencesUsed = cadencesUsed;
      
      transitFitObject = transitFitClass( transitFitStruct, fitType );
            
%     perform the fit 
      try
          
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
          
%           targetTableDataStruct = dvDataObject.targetTableDataStruct;
%           cadenceNumbers        = dvDataObject.dvCadenceTimes.cadenceNumbers;
%           generate_transit_fit_plots( transitFitObjectLastIter,  originalTargetFluxTimeSeries, targetTableDataStruct, cadenceNumbers, ...
%               dvResultsStruct.targetResultsStruct(iTarget).dvFiguresRootDirectory, keplerId, iPlanet, impactParameterSeed, ...
%               reducedParameterFitsEnabled, transitDurationMultiplier, true );
%               
%         end

          alertMessageStruct.identifier = lastError.identifier;
          alertMessageStruct.message    = lastError.message;

          return
              
      end
      
      % generate and save figures

      targetTableDataStruct = dvDataObject.targetTableDataStruct;
      cadenceNumbers        = dvDataObject.dvCadenceTimes.cadenceNumbers;
      generate_transit_fit_plots( transitFitObject, originalTargetFluxTimeSeries, targetTableDataStruct, cadenceNumbers, ...
          dvResultsStruct.targetResultsStruct(iTarget).dvFiguresRootDirectory, keplerId, iPlanet, defaultPeriod, impactParameterSeed, ...
          reducedParameterFitsEnabled, transitDurationMultiplier, true);
      
%     perform all the end-of-loop tasks and decisions

      [converged, secondaryConverged, fitType, bestTransitFitObjectOldType, iterLimit, ...
          transitFitObjectLastIter, transitObject, doRobustFit, normParameterVariation, deltaChiSquare, finalParValues] = ...
          iterator_loop_end_logic( transitFitObject, transitFitObjectLastIter, ...
          bestTransitFitObjectOldType, iterLimit, robustFitEnabled, kicStarRadius, nIter );

      fitConfigurationStruct = get(transitFitObject, 'configurationStruct');
      chiSquare              = get(transitFitObject, 'chisq');
      allTransitSnr          = get(transitFitObject, 'allTransitSnr');
      oddTransitSnr          = get(transitFitObject, 'oddTransitSnr');
      evenTransitSnr         = get(transitFitObject, 'evenTransitSnr');
      parameterValues        = get(transitFitObject, 'finalParValues');
      cadencesUsed           = fitConfigurationStruct.cadencesUsed;
      
      whitenedFlux           = whitenedFluxTimeSeries.values;
      whitenedModel          = model_function(transitFitObject, finalParValues, true, true);
      whitenedFluxUsed       = whitenedFlux(cadencesUsed);
      if nIter>1
          diffWhitenedFlux                  = whitenedFlux     - whitenedFluxLastIter;
          relativeVariationWhitenedFlux     = sqrt( sum(diffWhitenedFlux.^2)    /sum(whitenedFluxLastIter.^2)     );
      else
          relativeVariationWhitenedFlux     = -1;
      end
      if nIter>iterationToFreezeCadencesForFit
          diffWhitenedFluxUsed              = whitenedFluxUsed - whitenedFluxUsedLastIter;
          relativeVariationWhitenedFluxUsed = sqrt( sum(diffWhitenedFluxUsed.^2)/sum(whitenedFluxUsedLastIter.^2) );
      else
          relativeVariationWhitenedFluxUsed = -1;
      end
      whitenedFluxLastIter                  = whitenedFlux;
      whitenedFluxUsedLastIter              = whitenedFluxUsed;
      
      transitFitResultStruct(nIter).iTarget                                     = iTarget;
      transitFitResultStruct(nIter).iPlanet                                     = iPlanet;
      transitFitResultStruct(nIter).oddEvenFlag                                 = oddEvenFlag;
      transitFitResultStruct(nIter).fitType                                     = fitType;
      if saveTimeSeriesEnabled
          transitFitResultStruct(nIter).whitenedFluxTimeSeriesValues            = whitenedFluxTimeSeries.values;
          transitFitResultStruct(nIter).whitenedModelTimeSeriesValues           = whitenedModel;
          transitFitResultStruct(nIter).cadenceUsed                             = cadencesUsed;
      else
          transitFitResultStruct(nIter).whitenedFluxTimeSeriesValues            = [];
          transitFitResultStruct(nIter).whitenedModelTimeSeriesValues           = [];
          transitFitResultStruct(nIter).cadenceUsed                             = [];
      end
      transitFitResultStruct(nIter).relativeVariationWhitenedFlux               = relativeVariationWhitenedFlux;
      transitFitResultStruct(nIter).relativeVariationWhitenedFluxUsed           = relativeVariationWhitenedFluxUsed;
      transitFitResultStruct(nIter).converged                                   = converged;
      transitFitResultStruct(nIter).secondaryConverged                          = secondaryConverged;
      transitFitResultStruct(nIter).doRobustFit                                 = doRobustFit;
      transitFitResultStruct(nIter).chiSquare                                   = chiSquare;
      if oddEvenFlag==0
          transitFitResultStruct(nIter).modelFitSnr                             = allTransitSnr;
      elseif oddEvenFlag==1
          transitFitResultStruct(nIter).modelFitSnr                             = [oddTransitSnr evenTransitSnr];
      end
      transitFitResultStruct(nIter).parameterValues                             = parameterValues;
      transitFitResultStruct(nIter).normParameterVariation                      = normParameterVariation;
      transitFitResultStruct(nIter).deltaChiSquare                              = deltaChiSquare;
      transitFitResultStruct(nIter).parameterConvergenceToleranceArray          = fitConfigurationStruct.parameterConvergenceToleranceArray;
      transitFitResultStruct(nIter).secondaryParameterConvergenceToleranceArray = fitConfigurationStruct.secondaryParameterConvergenceToleranceArray;
      transitFitResultStruct(nIter).chiSquareConvergenceTolerance               = fitConfigurationStruct.chiSquareConvergenceTolerance;
      
      disp(['      refTime ' num2str(etime(clock, refTime), '%6.2f') ' seconds : convergenceFlag = ' num2str(converged) ', secondaryConvergenceFlag = ' num2str(secondaryConverged)]);
      if oddEvenFlag==0 
          
          if ~reducedParameterFitsEnabled && length(parameterValues)==5
              disp(['         chiSquare = ' num2str(chiSquare) ', deltaChiSquare = ' num2str(deltaChiSquare)]);  
              disp(['         parameterValues:   transitEpochBkjd_all  = '               num2str(parameterValues(1)) ...
                                              ', orbitalPeriodDays_all  = '              num2str(parameterValues(5)) ...
                                              ', ratioPlanetRadiusToStarRadius_all  = '  num2str(parameterValues(2)) ...
                                              ', ratioSemiMajorAxisToStarRadius_all  = ' num2str(parameterValues(3)) ...
                                              ', minImpactParameter_all  = '             num2str(parameterValues(4))]);
              disp(['         normParaVariation: transitEpochBkjd_all  = '               num2str(normParameterVariation(1)) ... 
                                              ', orbitalPeriodDays_all  = '              num2str(normParameterVariation(5)) ...
                                              ', ratioPlanetRadiusToStarRadius_all  = '  num2str(normParameterVariation(2)) ...
                                              ', ratioSemiMajorAxisToStarRadius_all  = ' num2str(normParameterVariation(3)) ...
                                              ', minImpactParameter_all  = '             num2str(normParameterVariation(4))]);
          elseif reducedParameterFitsEnabled && length(parameterValues)==4
              disp(['         chiSquare = ' num2str(chiSquare) ', deltaChiSquare = ' num2str(deltaChiSquare)]);  
              disp(['         parameterValues:   transitEpochBkjd_all  = '               num2str(parameterValues(1)) ...
                                              ', orbitalPeriodDays_all  = '              num2str(parameterValues(4)) ...
                                              ', ratioPlanetRadiusToStarRadius_all  = '  num2str(parameterValues(2)) ...
                                              ', ratioSemiMajorAxisToStarRadius_all  = ' num2str(parameterValues(3))]);
              disp(['         normParaVariation: transitEpochBkjd_all  = '               num2str(normParameterVariation(1)) ... 
                                              ', orbitalPeriodDays_all  = '              num2str(normParameterVariation(4)) ...
                                              ', ratioPlanetRadiusToStarRadius_all  = '  num2str(normParameterVariation(2)) ...
                                              ', ratioSemiMajorAxisToStarRadius_all  = ' num2str(normParameterVariation(3))]);
          end
          
      elseif oddEvenFlag==1 && length(parameterValues)==10
          
          disp(['         chiSquare = ' num2str(chiSquare) ', deltaChiSquare = ' num2str(deltaChiSquare)]);  
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
          disp(['         normParaVariation: transitEpochBkjd_odd  = '               num2str(normParameterVariation(1)) ... 
                                          ', orbitalPeriodDays_odd  = '              num2str(normParameterVariation(5)) ...
                                          ', ratioPlanetRadiusToStarRadius_odd  = '  num2str(normParameterVariation(2)) ...
                                          ', ratioSemiMajorAxisToStarRadius_odd  = ' num2str(normParameterVariation(3)) ...
                                          ', minImpactParameter_odd  = '             num2str(normParameterVariation(4))]);
          disp(['                            transitEpochBkjd_even = '               num2str(normParameterVariation(6)) ... 
                                          ', orbitalPeriodDays_even = '              num2str(normParameterVariation(10)) ...
                                          ', ratioPlanetRadiusToStarRadius_even = '  num2str(normParameterVariation(7)) ...
                                          ', ratioSemiMajorAxisToStarRadius_even = ' num2str(normParameterVariation(8)) ...
                                          ', minImpactParameter_even = '             num2str(normParameterVariation(9))]);

      end
      disp(['      Iteration ',num2str(nIter),' completed, elapsed time ', num2str( etime( clock, iterationStartTimestamp ) ), ' seconds']) ;
      

%     Select the better of the two fit types, if both fit types have been performed, and
%     keep it as the one which is returned.
%     Note: the selection is only done when geometric transit model is not used

      if converged && ~strcmp(dvDataObject.dvConfigurationStruct.transitModelName, 'mandel-agol_geometric_transit_model')
          
          oldFitType = fitType ;
          [transitFitObject, fitType, chiSquares] = select_best_transit_fit_object( ...
              transitFitObject, bestTransitFitObjectOldType ) ;
          if fitType ~= oldFitType
              disp( '      Reverting to impact parameter == 0 fit based on chi-square' ) ;
              disp( [ '      chi-square values:  ',num2str(chiSquares(1)),' and ', ...
                  num2str(chiSquares(2)) ] ) ;
          end
          
      end
      
  end % while not converged loop
  
  disp( ['      Converged on iteration ',num2str(nIter),' after ', num2str( etime( clock, loopStartTimestamp ) ),' seconds from beginning of iterative whitening and model fitting loop'] ) ;
  
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
      fill_planet_results_struct( transitFitObject, dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet), ...
      whitenedModel, whitenedModelGapIndicators, converged, seededWithPriorFitFlag );
 
% generate and save figures

%   targetTableDataStruct = dvDataObject.targetTableDataStruct;
%   cadenceNumbers        = dvDataObject.dvCadenceTimes.cadenceNumbers;
%   generate_transit_fit_plots( transitFitObject, originalTargetFluxTimeSeries, targetTableDataStruct, cadenceNumbers, ...
%       dvResultsStruct.targetResultsStruct(iTarget).dvFiguresRootDirectory, keplerId, iPlanet, impactParameterSeed, ...
%       reducedParameterFitsEnabled, transitDurationMultiplier, true);
  
return

% And that's all that has to happen here -- I think...

