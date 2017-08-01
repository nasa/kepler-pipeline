function transitFitObject = transitFitClass( transitFitStruct, fitType )
%
% transitFitClass -- constructor for transitFitClass objects
%
% transitFitObject = transitFitClass( transitFitStruct ) is the constructor for the
%    transitFitClass.  The transitFitStruct is a Matlab struct which can either have the
%    fields returned by a get(transitFitObject,'*') operation, or else the following:
%
%    whitenedFluxTimeSeries         [struct]  struct of data which constrains the fit
%    whiteningFilterModel           [struct]  struct needed to build whitening filter
%    transitGeneratorObject         [struct]  initial guess model for transit
%    configurationStruct            [struct]  convergence parameters for fitter
%    debugLevel                     [int] (optional) debug level
%
% transitFitObject = transitFitClass( transitFitStruct, fitType ) allows selection of
% different sets of fit parameters.  When fitType == 0 (default), parameters are the
% transit epoch, the planet radius, the semi-major axis, and the impact parameter.  When
% fitType == 1, the orbital period is substituted for the impact parameter.
%
% When geometric transit model is used in the fitter, the input transitFitStruct has one
% additional field targetFluxTimeSeries, and fitType is set to the following values:
%   11 - fit with 5 parameters in the unwhitened domain
%   12 - fit with 5 parameters in the   whitened domain
%   13 - fit with 4 parameters (no orbital period) in the unwhitened domain
%   14 - fit with 4 parameters (no orbital period) in the   whitened domain
%
% transitFitObject = transitFitClass( ..., robustFit ) defeats the robustFitEnabled flag
%    in configurationStruct when robustFit == false.  The default is robustFit == true.
%
% Version date:  2013-April-04.
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
%    2013-April-04, JL:
%       Add the filed 'deemphasisWeights' in transitFitObject
%    2012-July-05, JL:
%       Implement the reduced parameter fit algorithm
%    2011-October-31, JL:
%        add the fields 'parameterConvergenceToleranceArray' and 'secondaryParameterConvergenceToleranceArray'
%        in transitFitObject.configurationStruct.
%    2011-June-28, JL:
%        add the field 'barycentricCadenceTimes' in transitFitObject
%    2011-June-06, JL:
%        add three fields -- 'allTransitSnr', 'oddTransitSnr' and 'evenTransitSnr' -- 
%        in transitFitObject
%    2011-February-18, JL:
%        add two fields -- 'parMessages' and 'configurationStruct' -- in transitObject
%    2011-February-14, JL:
%        add two fields -- 'parValueLowerBounds' and 'parValueUpperBounds' -- defining
%        lower/upper bounds to fitted parameters
%    2010-Nov-29, JL:
%        fix a bug related to ratioPlanetRadiusToStarRadiusStepSize and 
%        ratioSemiMajorAxisToStarRadiusStepSize
%    2010-Nov-05, JL:
%        add the fitter with geometric transit model
%    2010-July-07, PT:
%        bugfix for KSOC-871:  fitType variable was doubling in length on each iteration
%        of odd-even fitting, until it was so large it was crashing the workers.
%    2010-May-05, PT:
%        convert from transitEpochMjd to transitEpochBkjd.
%    2010-April-27, PT:
%        support for transitGeneratorCollectionClass use.  Eliminate use of oddEvenFlag as
%        parameter in transitFitStruct, since it's already in transitGeneratorObject and
%        the 2 values have to be consistent with each other.
%    2010-January-06, PT:
%        add fitTimeoutDatenum member, which holds the datenum at which fitting this
%        target times out.
%    2009-September-23, PT:
%        eliminate chisqRobustWeights field.
%    2009-September-21, PT:
%        eliminate unused targetStruct field in format 1 constructor.  Fixes to bugs
%        unearthed by constructor unit test.
%    2009-September-17, PT:
%        take the transitGeneratorObject as a field for both formats.
%    2009-September-16, PT:
%        handle case of fitting with 0 or 1 actual transits.
%    2009-September-02, PT:
%        support for odd, even, or all transit fitting.
%    2009-August-17, PT:
%        support for two different fitType values.
%    2009-July-28, PT:
%        add debugLevel to struct and class.
%    2009-July-27, PT:
%        update to match current design of code, inc. new instantiation parameters from
%        TPS, use of minImpactParameter rather than inclinationDegrees, and use of
%        internal / external fit parameters to allow bounded fitting.
%    2009-June-23, PT:
%        bugfix in code which constructs fitting options struct.
%    2009-May-27, PT:
%        updates to match changes in design to transitGeneratorClass and general
%        immprovements.
%    2009-May-15, PT:
%        Eliminate use of star intensity parameter, since we are fitting in
%        median-corrected regime.
%    2009-May-11, PT:
%        Adjust order of parameters and improve test for multiple transits present in flux
%        time series.
%
%=========================================================================================

% If the input struct does not have a debugLevel, set it now

  if ( ~isfield( transitFitStruct, 'debugLevel' ) || isempty( transitFitStruct.debugLevel )  )
      transitFitStruct.debugLevel = 0;
  end

% First step is to determine whether the transitFitStruct is correctly formatted, and if
% so which of the two legal structs it represents.  We will do this by interrogating the
% fields of the struct and comparing to the two legal formats

  legalFieldsFormat1 = {'whitenedFluxTimeSeries', 'whiteningFilterModel',  'transitGeneratorObject', ...
      'configurationStruct', 'debugLevel' };
  
  legalFieldsFormat2 = {'whitenedFluxTimeSeries', 'whiteningFilterObject', 'transitGeneratorObject', ...
      'parameterMapStruct', 'initialParValues', 'finalParValues', 'parValueCovariance', ...
      'robustWeights', 'chisq', 'ndof', 'fitType', 'fitOptions', 'oddEvenFlag', 'debugLevel', 'fitTimeoutDatenum'};

% Set legal field formats 3&4 with one addtional field targetFluxTimeSeries, 
% which are used for the fitter with geometric transit model

  legalFieldsFormat3 = {'targetFluxTimeSeries', 'barycentricCadenceTimes', 'whitenedFluxTimeSeries', 'whiteningFilterModel',  'transitGeneratorObject', ...
      'deemphasisWeights', 'configurationStruct', 'debugLevel'} ;
  
  legalFieldsFormat4 = {'targetFluxTimeSeries', 'barycentricCadenceTimes', 'whitenedFluxTimeSeries', 'whiteningFilterObject', 'transitGeneratorObject', ...
      'parameterMapStruct', 'initialParValues', 'finalParValues', 'parValueLowerBounds', 'parValueUpperBounds', 'parMessages', 'parValueCovariance', ...
      'deemphasisWeights', 'configurationStruct', 'robustWeights', 'chisq', 'ndof', 'allTransitSnr', 'oddTransitSnr', 'evenTransitSnr', 'fitType', ...
      'fitOptions', 'oddEvenFlag', 'debugLevel', 'fitTimeoutDatenum'};

  isFormat1 = all( isfield(transitFitStruct,legalFieldsFormat1) ) && length(fieldnames(transitFitStruct)) == length(legalFieldsFormat1);
  
  isFormat2 = all( isfield(transitFitStruct,legalFieldsFormat2) ) && length(fieldnames(transitFitStruct)) == length(legalFieldsFormat2);
  
  isFormat3 = all( isfield(transitFitStruct,legalFieldsFormat3) ) && length(fieldnames(transitFitStruct)) == length(legalFieldsFormat3);
  
  isFormat4 = all( isfield(transitFitStruct,legalFieldsFormat4) ) && length(fieldnames(transitFitStruct)) == length(legalFieldsFormat4);

  if ( ~(isFormat1 || isFormat2 || isFormat3 || isFormat4) )
      error('dv:transitFitClass:invalidStructFormat', 'transitFitClass: instantiating struct has invalid format');
  end
  
% Next step:  we need to do different things to impedance-match the struct if we are in
% one format vs the other; handle that now

  if (isFormat1)
      
      transitFitModel = construct_transitFitModel_from_format1_struct(transitFitStruct, fitType);
      
  elseif (isFormat3)
      
      transitFitModel = construct_transitFitModel_from_format3_struct(transitFitStruct, fitType);

  else
      
      transitFitModel = construct_transitFitModel_from_format2or4_struct(transitFitStruct);
  
  end
  
% instantiate the object!
 
  if (isFormat1 || isFormat2)
      transitFitObject = class( orderfields(transitFitModel,legalFieldsFormat2), 'transitFitClass' );
  else
      transitFitObject = class( orderfields(transitFitModel,legalFieldsFormat4), 'transitFitClass' );
  end
  
return

% and that's it!

%
%
%

%=========================================================================================
      
% subfunction which translates from the structure format 1 to the transitFitModel itself

function transitFitModel = construct_transitFitModel_from_format1_struct( ...
          transitFitStruct, fitType )

% set odd-even flag based on transitGeneratorObject's value

  transitFitStruct.oddEvenFlag = get( transitFitStruct.transitGeneratorObject, ...
      'oddEvenFlag' ) ;
            
% no parameters in the fit yet, so set the counter to zero

  fitParCounter = 0 ;
      
% some fields can simply be copied over; do that now

  transitFitModel.whitenedFluxTimeSeries = transitFitStruct.whitenedFluxTimeSeries ;
  transitFitModel.debugLevel = transitFitStruct.debugLevel ;
      
% we need an embedded whiteningFilterClass object

  transitFitModel.whiteningFilterObject = whiteningFilterClass( ...
      transitFitStruct.whiteningFilterModel ) ;
  
% we need an embedded transitGeneratorClass object; right now, instantiate that directly
% from the initialTransitModel struct. 

  transitFitModel.transitGeneratorObject = transitFitStruct.transitGeneratorObject ;
  planetModel = get(transitFitModel.transitGeneratorObject,'planetModel') ;
  oddEvenFlag = transitFitStruct.oddEvenFlag ;
  transitGeneratorObjectVector = get( transitFitModel.transitGeneratorObject, ...
      'transitGeneratorObjectVector' ) ;
  nObjects = length( transitGeneratorObjectVector ) ;
  cadenceTimes = get( transitFitModel.transitGeneratorObject, 'cadenceTimes' ) ;
  gapIndicators = transitFitModel.whitenedFluxTimeSeries.gapIndicators ;
  filledIndices = transitFitModel.whitenedFluxTimeSeries.filledIndices ;
  
% Generate the parameter mappings which allow the interchange of parameter values between
% the vector of parameters and transitGeneratorObject's members

  parameterMapStruct = struct( ...
      'transitEpochBkjd',0, 'planetRadiusEarthRadii',0, 'semiMajorAxisAu',0, ...
      'minImpactParameter',0, 'orbitalPeriodDays',0 ) ;  
  parameterMapStruct = repmat( parameterMapStruct, ...
      nObjects, 1 ) ;
  transitFitModel.parameterMapStruct = [] ; % placeholder
  
% default the fitType of each object to the requested type.  Note that on the first
% iteration of odd-even or individual-transits fitting we get only the fit type of the
% parent all-transits fit, so we need to expand it to the length of the number of transit
% generator objects; in subsequent iterations, we do not need to do this.
  
  if length( fitType ) < nObjects
      fitType = repmat( fitType, nObjects, 1 ) ;
  end
    
% assign the parameterMapStruct values and the fitType values; we need to do something
% somewhat different for the various odd-even flag values

  switch oddEvenFlag
      
      case 0
          
%         all-transits fit:  one object, the fitType is accepted unless there is only 1
%         transit which is not gapped; if that is the case, error exit

          [numExpectedTransits, numActualTransits] = ...
              get_number_of_transits_in_time_series( ...
          transitGeneratorObjectVector, cadenceTimes, gapIndicators, filledIndices ) ;
           
          if numActualTransits < 2
              error('dv:transitFitClass:insufficientTransitsToFit', ...
              'transitFitClass: # of ungapped transits too small to perform fit') ;
          end
          
          parameterMapStruct.transitEpochBkjd = 1 ;
          parameterMapStruct.planetRadiusEarthRadii = 2 ;
          parameterMapStruct.semiMajorAxisAu = 3 ;
          
          if fitType == 0
              parameterMapStruct.minImpactParameter = 4 ;
          elseif fitType == 1
              parameterMapStruct.orbitalPeriodDays = 4 ;
          end
          fitParCounter = 4 ;
          
      case 1
          
%         odd-even fits:  2 objects, we can do the fit if even 1 transit is present in
%         either one, but need to set fitType to 2 and handle the parameter mapping
%         correctly in that eventuality

          [numExpectedTransits, numActualTransits, transitStruct] = ...
              get_number_of_transits_in_time_series( ...
          transitGeneratorObjectVector(1), cadenceTimes, gapIndicators, filledIndices ) ;
          transitGapIndicators = [transitStruct.gapIndicator] ;
          validTransits = find( ~transitGapIndicators ) ;
          oddTransits = intersect( 1:2:numExpectedTransits, validTransits ) ;
          evenTransits = intersect( 2:2:numExpectedTransits, validTransits ) ;
          if length(oddTransits) < 1 || length(evenTransits) < 1
              error('dv:transitFitClass:insufficientTransitsToFit', ...
              'transitFitClass: # of ungapped transits too small to perform fit') ;
          end
         
%         capture the # of valid odd and valid even transits

          nValidTransits = [ length( intersect( validTransits, oddTransits ) ) ; ...
              length( intersect( validTransits, evenTransits ) ) ] ;
          
%         for both transit generator objects, determine whether fitType needs to be reset
%         to 2, and which fit parameters can be included; this can be done in a loop

          for iObject = 1:2
              
              parameterMapStruct( iObject ).transitEpochBkjd = ...
                  fitParCounter + 1 ;
              parameterMapStruct( iObject ).planetRadiusEarthRadii = ...
                  fitParCounter + 2 ;
              parameterMapStruct( iObject ).semiMajorAxisAu = ...
                  fitParCounter + 3 ;
              if nValidTransits( iObject ) < 2
                  fitType( iObject ) = 2 ;
              end
              
              switch fitType(iObject)
                  
                  case 0 % fit impact parameter, not period
                      
                      parameterMapStruct( iObject ).minImpactParameter = ...
                          fitParCounter + 4 ;
                      fitParCounter = fitParCounter + 4 ;
                      
                  case 1 % fit period, not impact parameter
                      
                      parameterMapStruct( iObject ).orbitalPeriodDays = ...
                          fitParCounter + 4 ;
                      fitParCounter = fitParCounter + 4 ;
                      
                  case 2 % fit neither period nor impact parameter
                      
                      fitParCounter = fitParCounter + 3 ;
                      
              end % switch on fitType
              
          end % loop over objects
          
      case 2
          
%         fit of individual transits:  set all fit types to 2, set parameters, leave out
%         parameters in transit generators which correspond to missing transits

          fitType = 2 * ones( nObjects, 1 ) ;
          
          [numExpectedTransits, numActualTransits, transitStruct] = ...
              get_number_of_transits_in_time_series( ...
          transitGeneratorObjectVector(1), cadenceTimes, gapIndicators, filledIndices ) ;
          transitGapIndicators = [transitStruct.gapIndicator] ;
          
          for iObject = 1:nObjects
              
              if ~transitGapIndicators( iObject )
                  
                  parameterMapStruct( iObject ).transitEpochBkjd = ...
                      fitParCounter + 1 ;
                  parameterMapStruct( iObject ).planetRadiusEarthRadii = ...
                      fitParCounter + 2 ;
                  parameterMapStruct( iObject ).semiMajorAxisAu = ...
                      fitParCounter + 3 ;
                  fitParCounter = fitParCounter + 3 ;
                  
              end % conditional on good transit for this object
              
          end % loop over objects
          
  end % switch statement on odd-even flag
                    
% get the initial values for the fit parameters

  parameterList = fieldnames(parameterMapStruct) ;
  for iObject = 1:nObjects
    for iField = 1:length(parameterList)
      parameterPointer = parameterMapStruct(iObject).(parameterList{iField}) ;
      if (  parameterPointer ~= 0 )
          transitFitModel.initialParValues(parameterPointer) = ...
              planetModel(iObject).(parameterList{iField}) ;
      end
    end
  end
        
% put in slots for the final parameters and the covariance, plus other fit-related stuff

  transitFitModel.parameterMapStruct = parameterMapStruct ;
  transitFitModel.finalParValues = [] ;
  transitFitModel.parValueCovariance = [] ;
  transitFitModel.robustWeights = [] ;
  transitFitModel.chisq = 0 ;
  transitFitModel.ndof = 0 ;
  transitFitModel.fitType = fitType ;
  if isfield( transitFitStruct.configurationStruct, 'fitTimeoutDatenum' )
      transitFitModel.fitTimeoutDatenum = ...
          transitFitStruct.configurationStruct.fitTimeoutDatenum ;
  else
      transitFitModel.fitTimeoutDatenum = inf ;
  end
  
% put in the oddEvenFlag unless its value is invalid

  transitFitModel.oddEvenFlag = transitFitStruct.oddEvenFlag ;
  
% get an options struct for the fit

  configurationStruct = transitFitStruct.configurationStruct ;

  transitFitModel.fitOptions = kepler_set_soc( ...
      'tolX', configurationStruct.tolX, ... 
      'convSigma', configurationStruct.tolSigma, ... 
      'tolFun', configurationStruct.tolFun, ...
      'convSigma', configurationStruct.tolSigma ) ;
  if ( configurationStruct.robustFitEnabled )
      transitFitModel.fitOptions = kepler_set_soc( transitFitModel.fitOptions, ...
          'robust', 'on' ) ;
  else
      transitFitModel.fitOptions = kepler_set_soc( transitFitModel.fitOptions, ...
          'robust', 'off' ) ;
  end

  epochParameterPointer = nonzero_values( [parameterMapStruct.transitEpochBkjd] ) ;
  radiusParameterPointer = nonzero_values( [parameterMapStruct.planetRadiusEarthRadii] ) ;
  axisParameterPointer = nonzero_values( [parameterMapStruct.semiMajorAxisAu] ) ;
  periodParameterPointer = nonzero_values( [parameterMapStruct.orbitalPeriodDays] ) ;
  impactParameterPointer = nonzero_values( [parameterMapStruct.minImpactParameter] ) ;
    
% set the step size for each parameter

  defaultOptions = kepler_set_soc( 'nlinfit' ) ;
  derivStep = repmat(defaultOptions.DerivStep, size(transitFitModel.initialParValues)) ;

  if configurationStruct.transitEpochStepSizeCadences ~= -1 && ...
          ~isempty( epochParameterPointer ) 
      derivStep(epochParameterPointer) = ...
          configurationStruct.transitEpochStepSizeCadences * ...
          get( transitFitModel.transitGeneratorObject, 'cadenceDurationDays' ) ./ ...
          transitFitModel.initialParValues( epochParameterPointer ) ;
  end
  if configurationStruct.planetRadiusStepSizeEarthRadii ~= -1 && ...
          ~isempty( radiusParameterPointer )
      derivStep(radiusParameterPointer) = ...
          configurationStruct.planetRadiusStepSizeEarthRadii ./ ...
          transitFitModel.initialParValues( radiusParameterPointer ) ;
  end
  if configurationStruct.semiMajorAxisStepSizeAu ~= -1 && ...
          ~isempty( axisParameterPointer ) 
      derivStep(axisParameterPointer) = ...
          configurationStruct.semiMajorAxisStepSizeAu ./ ...
          transitFitModel.initialParValues( axisParameterPointer ) ;
  end
  if configurationStruct.minImpactParameterStepSize ~= -1 && ...
          ~isempty( impactParameterPointer )
      derivStep(impactParameterPointer) = ...
          configurationStruct.minImpactParameterStepSize ;
  end
  if configurationStruct.orbitalPeriodStepSizeDays ~= -1 && ...
          ~isempty( periodParameterPointer ) 
      derivStep(periodParameterPointer) = ...
          configurationStruct.orbitalPeriodStepSizeDays ./ ...
          transitFitModel.initialParValues( periodParameterPointer ) ;
  end
  
  transitFitModel.fitOptions = kepler_set_soc( transitFitModel.fitOptions, ...
      'DerivStep', derivStep ) ;
  
  
return

% end of construct_transitFitModel_from_format1_struct subfunction

%
%
%
%=========================================================================================
      
% subfunction which translates from the structure format 3 to the transitFitModel itself
% This format is for the fitter with geometric transit model

function transitFitModel = construct_transitFitModel_from_format3_struct(transitFitStruct, fitType)

% set odd-even flag based on transitGeneratorObject's value

  transitFitStruct.oddEvenFlag = get(transitFitStruct.transitGeneratorObject, 'oddEvenFlag') ;
  oddEvenFlag                  = transitFitStruct.oddEvenFlag ;
          
% no parameters in the fit yet, so set the counter to zero

  fitParCounter = 0 ;
      
% some fields can simply be copied over; do that now

  transitFitModel.targetFluxTimeSeries      = transitFitStruct.targetFluxTimeSeries;
  transitFitModel.barycentricCadenceTimes   = transitFitStruct.barycentricCadenceTimes;
  transitFitModel.whitenedFluxTimeSeries    = transitFitStruct.whitenedFluxTimeSeries;
  transitFitModel.deemphasisWeights         = transitFitStruct.deemphasisWeights;
  transitFitModel.debugLevel                = transitFitStruct.debugLevel;
      
  configurationStruct                       = transitFitStruct.configurationStruct;
  reducedParameterFitsEnabled               = configurationStruct.reducedParameterFitsEnabled;
  transitFitModel.configurationStruct       = configurationStruct;

  % we need an embedded whiteningFilterClass object

  transitFitModel.whiteningFilterObject  = whiteningFilterClass(transitFitStruct.whiteningFilterModel) ;
  
% we need an embedded transitGeneratorClass object; right now, instantiate that directly
% from the initialTransitModel struct. 

  transitFitModel.transitGeneratorObject = transitFitStruct.transitGeneratorObject ;
  cadenceTimes                           = get( transitFitModel.transitGeneratorObject, 'cadenceTimes'                 ) ;
  planetModel                            = get( transitFitModel.transitGeneratorObject, 'planetModel'                  ) ;
  transitGeneratorObjectVector           = get( transitFitModel.transitGeneratorObject, 'transitGeneratorObjectVector' ) ;
  
  nObjects      = length( transitGeneratorObjectVector ) ;
  gapIndicators = transitFitModel.whitenedFluxTimeSeries.gapIndicators ;
  filledIndices = transitFitModel.whitenedFluxTimeSeries.filledIndices ;
  
% Generate the parameter mappings which allow the interchange of parameter values between
% the vector of parameters and transitGeneratorObject's members


  if ~reducedParameterFitsEnabled
      parameterMapStruct = struct(  'transitEpochBkjd',                 0,  ...
                                    'ratioPlanetRadiusToStarRadius',    0,  ...
                                    'ratioSemiMajorAxisToStarRadius',   0,  ...
                                    'minImpactParameter',               0,  ...
                                    'orbitalPeriodDays',                0  );
  else
      parameterMapStruct = struct(  'transitEpochBkjd',                 0,  ...
                                    'ratioPlanetRadiusToStarRadius',    0,  ...
                                    'ratioSemiMajorAxisToStarRadius',   0,  ...
                                    'orbitalPeriodDays',                0  );
  end
  parameterMapStruct = repmat( parameterMapStruct, nObjects, 1 ) ;
  transitFitModel.parameterMapStruct = [] ; % placeholder
  
  
  tightParameterConvergenceTolerance          = configurationStruct.tightParameterConvergenceTolerance;
  looseParameterConvergenceTolerance          = configurationStruct.looseParameterConvergenceTolerance;
  tightSecondaryParameterConvergenceTolerance = configurationStruct.tightSecondaryParameterConvergenceTolerance;    
  looseSecondaryParameterConvergenceTolerance = configurationStruct.looseSecondaryParameterConvergenceTolerance;    
  
% default the fitType of each object to the requested type.  Note that on the first
% iteration of odd-even or individual-transits fitting we get only the fit type of the
% parent all-transits fit, so we need to expand it to the length of the number of transit
% generator objects; in subsequent iterations, we do not need to do this.
  
  if length( fitType ) < nObjects
      fitType = repmat( fitType, nObjects, 1 ) ;
  end
    
% assign the parameterMapStruct values and the fitType values; we need to do something
% somewhat different for the various odd-even flag values

  switch oddEvenFlag
      
      case 0
          
%         all-transits fit:  one object, the fitType is accepted unless there is only 1
%         transit which is not gapped; if that is the case, error exit

          [numExpectedTransits, numActualTransits] = ...
              get_number_of_transits_in_time_series(transitGeneratorObjectVector, cadenceTimes, gapIndicators, filledIndices);
           
          if numActualTransits < 2
              error('dv:transitFitClass:insufficientTransitsToFit', 'transitFitClass: # of ungapped transits too small to perform fit') ;
          end
          
          if ~reducedParameterFitsEnabled
              
            parameterMapStruct.transitEpochBkjd               = 1;
            parameterMapStruct.ratioPlanetRadiusToStarRadius  = 2;
            parameterMapStruct.ratioSemiMajorAxisToStarRadius = 3;
            parameterMapStruct.minImpactParameter             = 4;
            parameterMapStruct.orbitalPeriodDays              = 5;

            parValueLowerBounds(1) = configurationStruct.transitEpochBkjdLowerBound;
            parValueLowerBounds(2) = configurationStruct.ratioPlanetRadiusToStarRadiusLowerBound;
            parValueLowerBounds(3) = configurationStruct.ratioSemiMajorAxisToStarRadiusLowerBound;
            parValueLowerBounds(4) = configurationStruct.minImpactParameterLowerBound;
            parValueLowerBounds(5) = configurationStruct.orbitalPeriodDaysLowerBound;
         
            parValueUpperBounds(1) = configurationStruct.transitEpochBkjdUpperBound;
            parValueUpperBounds(2) = configurationStruct.ratioPlanetRadiusToStarRadiusUpperBound;
            parValueUpperBounds(3) = configurationStruct.ratioSemiMajorAxisToStarRadiusUpperBound;
            parValueUpperBounds(4) = configurationStruct.minImpactParameterUpperBound;
            parValueUpperBounds(5) = configurationStruct.orbitalPeriodDaysUpperBound;
          
            parMessages{1} = 'transitEpochBkjd';
            parMessages{2} = 'ratioPlanetRadiusToStarRadius';
            parMessages{3} = 'ratioSemiMajorAxisToStarRadius';
            parMessages{4} = 'minImpactParameter';
            parMessages{5} = 'orbitalPeriodDays';
         
            parameterConvergenceToleranceArray(1)          = tightParameterConvergenceTolerance^2;
            parameterConvergenceToleranceArray(2)          = tightParameterConvergenceTolerance^2;
            parameterConvergenceToleranceArray(3)          = looseParameterConvergenceTolerance^2;
            parameterConvergenceToleranceArray(4)          = looseParameterConvergenceTolerance^2;
            parameterConvergenceToleranceArray(5)          = tightParameterConvergenceTolerance^2;
          
            secondaryParameterConvergenceToleranceArray(1) = tightSecondaryParameterConvergenceTolerance^2;
            secondaryParameterConvergenceToleranceArray(2) = tightSecondaryParameterConvergenceTolerance^2;
            secondaryParameterConvergenceToleranceArray(3) = looseSecondaryParameterConvergenceTolerance^2;
            secondaryParameterConvergenceToleranceArray(4) = looseSecondaryParameterConvergenceTolerance^2;
            secondaryParameterConvergenceToleranceArray(5) = tightSecondaryParameterConvergenceTolerance^2;

            fitParCounter = 5;
            
          else
              
            parameterMapStruct.transitEpochBkjd               = 1;
            parameterMapStruct.ratioPlanetRadiusToStarRadius  = 2;
            parameterMapStruct.ratioSemiMajorAxisToStarRadius = 3;
            parameterMapStruct.orbitalPeriodDays              = 4;

            parValueLowerBounds(1) = configurationStruct.transitEpochBkjdLowerBound;
            parValueLowerBounds(2) = configurationStruct.ratioPlanetRadiusToStarRadiusLowerBound;
            parValueLowerBounds(3) = configurationStruct.ratioSemiMajorAxisToStarRadiusLowerBound;
            parValueLowerBounds(4) = configurationStruct.orbitalPeriodDaysLowerBound;
         
            parValueUpperBounds(1) = configurationStruct.transitEpochBkjdUpperBound;
            parValueUpperBounds(2) = configurationStruct.ratioPlanetRadiusToStarRadiusUpperBound;
            parValueUpperBounds(3) = configurationStruct.ratioSemiMajorAxisToStarRadiusUpperBound;
            parValueUpperBounds(4) = configurationStruct.orbitalPeriodDaysUpperBound;
          
            parMessages{1} = 'transitEpochBkjd';
            parMessages{2} = 'ratioPlanetRadiusToStarRadius';
            parMessages{3} = 'ratioSemiMajorAxisToStarRadius';
            parMessages{4} = 'orbitalPeriodDays';
         
            parameterConvergenceToleranceArray(1)          = tightParameterConvergenceTolerance^2;
            parameterConvergenceToleranceArray(2)          = tightParameterConvergenceTolerance^2;
            parameterConvergenceToleranceArray(3)          = looseParameterConvergenceTolerance^2;
            parameterConvergenceToleranceArray(4)          = tightParameterConvergenceTolerance^2;
          
            secondaryParameterConvergenceToleranceArray(1) = tightSecondaryParameterConvergenceTolerance^2;
            secondaryParameterConvergenceToleranceArray(2) = tightSecondaryParameterConvergenceTolerance^2;
            secondaryParameterConvergenceToleranceArray(3) = looseSecondaryParameterConvergenceTolerance^2;
            secondaryParameterConvergenceToleranceArray(4) = tightSecondaryParameterConvergenceTolerance^2;

            fitParCounter = 4;
            
          end
          
     case 1
          
%         odd-even fits:  2 objects, we can do the fit if even 1 transit is present in
%         either one, but need to set fitType to 13 or 14 and handle the parameter mapping
%         correctly in that eventuality

          [numExpectedTransits, numActualTransits, transitStruct] = ...
              get_number_of_transits_in_time_series(transitGeneratorObjectVector(1), cadenceTimes, gapIndicators, filledIndices) ;
          transitGapIndicators  = [transitStruct.gapIndicator] ;
          validTransits         = find( ~transitGapIndicators ) ;
          oddTransits           = intersect( 1:2:numExpectedTransits, validTransits ) ;
          evenTransits          = intersect( 2:2:numExpectedTransits, validTransits ) ;
          
          if length(oddTransits) < 1 || length(evenTransits) < 1
              error('dv:transitFitClass:insufficientTransitsToFit', 'transitFitClass: # of ungapped transits too small to perform fit') ;
          end
         
%         capture the # of valid odd and valid even transits

          nValidTransits = [ length( intersect( validTransits, oddTransits ) );  length( intersect( validTransits, evenTransits ) ) ] ;
          
%         for both transit generator objects, determine whether fitType needs to be reset
%         to 13 or 14, and which fit parameters can be included; this can be done in a loop

          for iObject = 1:2
              
             
              if nValidTransits( iObject ) < 2
                  
                  if fitType( iObject )==11
                        fitType( iObject ) = 13 ;
                  else
                        fitType( iObject ) = 14 ;
                  end
                  
                  if transitFitStruct.debugLevel>1
                      disp(' ');
                      if iObject==1
                          disp(['transitFitClass: there is only one valid  odd transit, fitType of  oddTransitsFit is set to ' num2str( fitType(iObject) )]);
                      else
                          disp(['transitFitClass: there is only one valid even transit, fitType of evenTransitsFit is set to ' num2str( fitType(iObject) )]);
                      end
                      disp(' ');
                  end
                  
                  parameterMapStruct( iObject ).transitEpochBkjd               = fitParCounter + 1;
                  parameterMapStruct( iObject ).ratioPlanetRadiusToStarRadius  = fitParCounter + 2;
                  parameterMapStruct( iObject ).ratioSemiMajorAxisToStarRadius = fitParCounter + 3;
                  parameterMapStruct( iObject ).minImpactParameter             = fitParCounter + 4;
                  
                  parValueLowerBounds(fitParCounter + 1) = configurationStruct.transitEpochBkjdLowerBound;
                  parValueLowerBounds(fitParCounter + 2) = configurationStruct.ratioPlanetRadiusToStarRadiusLowerBound;
                  parValueLowerBounds(fitParCounter + 3) = configurationStruct.ratioSemiMajorAxisToStarRadiusLowerBound;
                  parValueLowerBounds(fitParCounter + 4) = configurationStruct.minImpactParameterLowerBound;
         
                  parValueUpperBounds(fitParCounter + 1) = configurationStruct.transitEpochBkjdUpperBound;
                  parValueUpperBounds(fitParCounter + 2) = configurationStruct.ratioPlanetRadiusToStarRadiusUpperBound;
                  parValueUpperBounds(fitParCounter + 3) = configurationStruct.ratioSemiMajorAxisToStarRadiusUpperBound;
                  parValueUpperBounds(fitParCounter + 4) = configurationStruct.minImpactParameterUpperBound;

                  if iObject==1  
                      parMessages{fitParCounter + 1} = 'transitEpochBkjd_odd';
                      parMessages{fitParCounter + 2} = 'ratioPlanetRadiusToStarRadius_odd';
                      parMessages{fitParCounter + 3} = 'ratioSemiMajorAxisToStarRadius_odd';
                      parMessages{fitParCounter + 4} = 'minImpactParameter_odd';
                  else
                      parMessages{fitParCounter + 1} = 'transitEpochBkjd_even';
                      parMessages{fitParCounter + 2} = 'ratioPlanetRadiusToStarRadius_even';
                      parMessages{fitParCounter + 3} = 'ratioSemiMajorAxisToStarRadius_even';
                      parMessages{fitParCounter + 4} = 'minImpactParameter_even';
                  end
                  
                  parameterConvergenceToleranceArray(fitParCounter + 1)          = tightParameterConvergenceTolerance^2;
                  parameterConvergenceToleranceArray(fitParCounter + 2)          = tightParameterConvergenceTolerance^2;
                  parameterConvergenceToleranceArray(fitParCounter + 3)          = looseParameterConvergenceTolerance^2;
                  parameterConvergenceToleranceArray(fitParCounter + 4)          = looseParameterConvergenceTolerance^2;
          
                  secondaryParameterConvergenceToleranceArray(fitParCounter + 1) = tightSecondaryParameterConvergenceTolerance^2;
                  secondaryParameterConvergenceToleranceArray(fitParCounter + 2) = tightSecondaryParameterConvergenceTolerance^2;
                  secondaryParameterConvergenceToleranceArray(fitParCounter + 3) = looseSecondaryParameterConvergenceTolerance^2;
                  secondaryParameterConvergenceToleranceArray(fitParCounter + 4) = looseSecondaryParameterConvergenceTolerance^2;

                  fitParCounter = 4;
                  
              else
                  
                  parameterMapStruct( iObject ).transitEpochBkjd               = fitParCounter + 1;
                  parameterMapStruct( iObject ).ratioPlanetRadiusToStarRadius  = fitParCounter + 2;
                  parameterMapStruct( iObject ).ratioSemiMajorAxisToStarRadius = fitParCounter + 3;
                  parameterMapStruct( iObject ).minImpactParameter             = fitParCounter + 4;
                  parameterMapStruct( iObject ).orbitalPeriodDays              = fitParCounter + 5;
                  
                  parValueLowerBounds(fitParCounter + 1) = configurationStruct.transitEpochBkjdLowerBound;
                  parValueLowerBounds(fitParCounter + 2) = configurationStruct.ratioPlanetRadiusToStarRadiusLowerBound;
                  parValueLowerBounds(fitParCounter + 3) = configurationStruct.ratioSemiMajorAxisToStarRadiusLowerBound;
                  parValueLowerBounds(fitParCounter + 4) = configurationStruct.minImpactParameterLowerBound;
                  parValueLowerBounds(fitParCounter + 5) = configurationStruct.orbitalPeriodDaysLowerBound;
         
                  parValueUpperBounds(fitParCounter + 1) = configurationStruct.transitEpochBkjdUpperBound;
                  parValueUpperBounds(fitParCounter + 2) = configurationStruct.ratioPlanetRadiusToStarRadiusUpperBound;
                  parValueUpperBounds(fitParCounter + 3) = configurationStruct.ratioSemiMajorAxisToStarRadiusUpperBound;
                  parValueUpperBounds(fitParCounter + 4) = configurationStruct.minImpactParameterUpperBound;
                  parValueUpperBounds(fitParCounter + 5) = configurationStruct.orbitalPeriodDaysUpperBound;
                 
                  if iObject==1
                      parMessages{fitParCounter + 1} = 'transitEpochBkjd_odd';
                      parMessages{fitParCounter + 2} = 'ratioPlanetRadiusToStarRadius_odd';
                      parMessages{fitParCounter + 3} = 'ratioSemiMajorAxisToStarRadius_odd';
                      parMessages{fitParCounter + 4} = 'minImpactParameter_odd';
                      parMessages{fitParCounter + 5} = 'orbitalPeriodDays_odd';
                  else
                      parMessages{fitParCounter + 1} = 'transitEpochBkjd_even';
                      parMessages{fitParCounter + 2} = 'ratioPlanetRadiusToStarRadius_even';
                      parMessages{fitParCounter + 3} = 'ratioSemiMajorAxisToStarRadius_even';
                      parMessages{fitParCounter + 4} = 'minImpactParameter_even';
                      parMessages{fitParCounter + 5} = 'orbitalPeriodDays_even';
                  end
                  
                  parameterConvergenceToleranceArray(fitParCounter + 1)          = tightParameterConvergenceTolerance^2;
                  parameterConvergenceToleranceArray(fitParCounter + 2)          = tightParameterConvergenceTolerance^2;
                  parameterConvergenceToleranceArray(fitParCounter + 3)          = looseParameterConvergenceTolerance^2;
                  parameterConvergenceToleranceArray(fitParCounter + 4)          = looseParameterConvergenceTolerance^2;
                  parameterConvergenceToleranceArray(fitParCounter + 5)          = tightParameterConvergenceTolerance^2;
          
                  secondaryParameterConvergenceToleranceArray(fitParCounter + 1) = tightSecondaryParameterConvergenceTolerance^2;
                  secondaryParameterConvergenceToleranceArray(fitParCounter + 2) = tightSecondaryParameterConvergenceTolerance^2;
                  secondaryParameterConvergenceToleranceArray(fitParCounter + 3) = looseSecondaryParameterConvergenceTolerance^2;
                  secondaryParameterConvergenceToleranceArray(fitParCounter + 4) = looseSecondaryParameterConvergenceTolerance^2;
                  secondaryParameterConvergenceToleranceArray(fitParCounter + 5) = tightSecondaryParameterConvergenceTolerance^2;

                  fitParCounter = 5;
                  
              end
              
          end % loop over objects
          
      case 2
          
%         fit of individual transits:  set all fit types to 13 or 14, set parameters, leave out
%         parameters in transit generators which correspond to missing transits

          [numExpectedTransits, numActualTransits, transitStruct] = ...
              get_number_of_transits_in_time_series(transitGeneratorObjectVector(1), cadenceTimes, gapIndicators, filledIndices) ;
          transitGapIndicators = [transitStruct.gapIndicator] ;
          
          for iObject = 1:nObjects
              
              if fitType( iObject )==11
                  fitType( iObject ) = 13 ;
              else
                  fitType( iObject ) = 14 ;
              end

              if ~transitGapIndicators( iObject )
                  
                  parameterMapStruct( iObject ).transitEpochBkjd               = fitParCounter + 1;
                  parameterMapStruct( iObject ).ratioPlanetRadiusToStarRadius  = fitParCounter + 2;
                  parameterMapStruct( iObject ).ratioSemiMajorAxisToStarRadius = fitParCounter + 3;
                  parameterMapStruct( iObject ).minImpactParameter             = fitParCounter + 4;
                  
                  parValueLowerBounds(fitParCounter + 1) = configurationStruct.transitEpochBkjdLowerBound;
                  parValueLowerBounds(fitParCounter + 2) = configurationStruct.ratioPlanetRadiusToStarRadiusLowerBound;
                  parValueLowerBounds(fitParCounter + 3) = configurationStruct.ratioSemiMajorAxisToStarRadiusLowerBound;
                  parValueLowerBounds(fitParCounter + 4) = configurationStruct.minImpactParameterLowerBound;
         
                  parValueUpperBounds(fitParCounter + 1) = configurationStruct.transitEpochBkjdUpperBound;
                  parValueUpperBounds(fitParCounter + 2) = configurationStruct.ratioPlanetRadiusToStarRadiusUpperBound;
                  parValueUpperBounds(fitParCounter + 3) = configurationStruct.ratioSemiMajorAxisToStarRadiusUpperBound;
                  parValueUpperBounds(fitParCounter + 4) = configurationStruct.minImpactParameterUpperBound;
                  
                  parMessages{fitParCounter + 1} = ['transitEpochBkjd_' num2str(iObject)];
                  parMessages{fitParCounter + 2} = ['ratioPlanetRadiusToStarRadius_' num2str(iObject)];
                  parMessages{fitParCounter + 3} = ['ratioSemiMajorAxisToStarRadius_' num2str(iObject)];
                  parMessages{fitParCounter + 4} = ['minImpactParameter_' num2str(iObject)];
                  
                  parameterConvergenceToleranceArray(fitParCounter + 1)          = tightParameterConvergenceTolerance^2;
                  parameterConvergenceToleranceArray(fitParCounter + 2)          = tightParameterConvergenceTolerance^2;
                  parameterConvergenceToleranceArray(fitParCounter + 3)          = looseParameterConvergenceTolerance^2;
                  parameterConvergenceToleranceArray(fitParCounter + 4)          = looseParameterConvergenceTolerance^2;
          
                  secondaryParameterConvergenceToleranceArray(fitParCounter + 1) = tightSecondaryParameterConvergenceTolerance^2;
                  secondaryParameterConvergenceToleranceArray(fitParCounter + 2) = tightSecondaryParameterConvergenceTolerance^2;
                  secondaryParameterConvergenceToleranceArray(fitParCounter + 3) = looseSecondaryParameterConvergenceTolerance^2;
                  secondaryParameterConvergenceToleranceArray(fitParCounter + 4) = looseSecondaryParameterConvergenceTolerance^2;

                  fitParCounter = fitParCounter + 4;                  
                  
              end % conditional on good transit for this object
              
          end % loop over objects
          
  end % switch statement on odd-even flag
                    
% get the initial values for the fit parameters

  parameterList = fieldnames(parameterMapStruct) ;
  for iObject = 1:nObjects
    for iField = 1:length(parameterList)
      parameterPointer = parameterMapStruct(iObject).(parameterList{iField});
      if (  parameterPointer ~= 0 )
          transitFitModel.initialParValues(parameterPointer) = planetModel(iObject).(parameterList{iField});
      end
    end
  end
        
% put in slots for the final parameters and the covariance, plus other fit-related stuff

  transitFitModel.parameterMapStruct  = parameterMapStruct;
  transitFitModel.parValueLowerBounds = parValueLowerBounds;
  transitFitModel.parValueUpperBounds = parValueUpperBounds;
  transitFitModel.parMessages         = parMessages;                   
  transitFitModel.finalParValues      = [];
  transitFitModel.parValueCovariance  = [];
  transitFitModel.robustWeights       = [];
  transitFitModel.chisq               = -1;
  transitFitModel.ndof                = -1;
  transitFitModel.allTransitSnr       = -1;
  transitFitModel.oddTransitSnr       = -1;
  transitFitModel.evenTransitSnr      = -1;
  transitFitModel.fitType             = fitType;
  if isfield( transitFitStruct.configurationStruct, 'fitTimeoutDatenum' )
      transitFitModel.fitTimeoutDatenum = transitFitStruct.configurationStruct.fitTimeoutDatenum;
  else
      transitFitModel.fitTimeoutDatenum = inf;
  end
  transitFitModel.configurationStruct.parameterConvergenceToleranceArray          = parameterConvergenceToleranceArray(:);
  transitFitModel.configurationStruct.secondaryParameterConvergenceToleranceArray = secondaryParameterConvergenceToleranceArray(:);
  
% put in the oddEvenFlag unless its value is invalid

  transitFitModel.oddEvenFlag = transitFitStruct.oddEvenFlag ;
  
% get an options struct for the fit

  transitFitModel.fitOptions = kepler_set_soc( 'tolX',   configurationStruct.tolX,   ... 
                                            'tolFun', configurationStruct.tolFun );
  if ( configurationStruct.robustFitEnabled )
      transitFitModel.fitOptions = kepler_set_soc( transitFitModel.fitOptions, 'robust',    'on'  ) ;
      transitFitModel.fitOptions = kepler_set_soc( transitFitModel.fitOptions, 'convSigma', configurationStruct.tolSigma  ) ;
  else
      transitFitModel.fitOptions = kepler_set_soc( transitFitModel.fitOptions, 'robust',    'off' ) ;
      transitFitModel.fitOptions = kepler_set_soc( transitFitModel.fitOptions, 'convSigma', 0     ) ;
  end

  epochParameterPointer                 = nonzero_values( [parameterMapStruct.transitEpochBkjd] ) ;
  ratioPlanetRadiusParameterPointer     = nonzero_values( [parameterMapStruct.ratioPlanetRadiusToStarRadius] ) ;
  ratioSemiMajorAxisParameterPointer    = nonzero_values( [parameterMapStruct.ratioSemiMajorAxisToStarRadius] ) ;
  if ~reducedParameterFitsEnabled
      impactParameterPointer            = nonzero_values( [parameterMapStruct.minImpactParameter] ) ;
  end
  periodParameterPointer                = nonzero_values( [parameterMapStruct.orbitalPeriodDays] ) ;
    
% set the step size for each parameter

  defaultOptions = kepler_set_soc( 'nlinfit' ) ;
  derivStep = repmat(defaultOptions.DerivStep, size(transitFitModel.initialParValues)) ;

  if configurationStruct.transitEpochStepSizeCadences           ~= -1 && ~isempty( epochParameterPointer  ) 
      derivStep(epochParameterPointer)  = configurationStruct.transitEpochStepSizeCadences * get( transitFitModel.transitGeneratorObject, 'cadenceDurationDays' ) ./ ...
                                          transitFitModel.initialParValues( epochParameterPointer );
  end
  if configurationStruct.ratioPlanetRadiusToStarRadiusStepSize  ~= -1 && ~isempty( ratioPlanetRadiusParameterPointer )
      derivStep(ratioPlanetRadiusParameterPointer)  = configurationStruct.ratioPlanetRadiusToStarRadiusStepSize;
  end
  if configurationStruct.ratioSemiMajorAxisToStarRadiusStepSize ~= -1 && ~isempty( ratioSemiMajorAxisParameterPointer   ) 
      derivStep(ratioSemiMajorAxisParameterPointer) = configurationStruct.ratioSemiMajorAxisToStarRadiusStepSize;
  end
  if ~reducedParameterFitsEnabled
      if configurationStruct.minImpactParameterStepSize             ~= -1 && ~isempty( impactParameterPointer )
          derivStep(impactParameterPointer) = configurationStruct.minImpactParameterStepSize;
      end
  end
  if configurationStruct.orbitalPeriodStepSizeDays              ~= -1 && ~isempty( periodParameterPointer ) 
      derivStep(periodParameterPointer) = configurationStruct.orbitalPeriodStepSizeDays ./ transitFitModel.initialParValues( periodParameterPointer );
  end
  
  transitFitModel.fitOptions = kepler_set_soc( transitFitModel.fitOptions, 'DerivStep', derivStep ) ;
  
return

% end of construct_transitFitModel_from_format3_struct subfunction

%=========================================================================================

% subfunction which does some minor checks on the format 2 or 4 structure before sending it for
% instantiation

function transitFitModel = construct_transitFitModel_from_format2or4_struct( ...
          transitFitStruct )
      
% to good approximation the two structures are the same

  transitFitModel = transitFitStruct ;
  
% if the two embedded objects are in fact structs, instantiate them now

  if ( isa(transitFitModel.transitGeneratorObject,'struct') )
      transitFitModel.transitGeneratorObject = transitGeneratorClass( ...
          transitFitModel.transitGeneratorObject ) ;
  end
  if ( isa(transitFitModel.whiteningFilterObject,'struct') )
      transitFitModel.whiteningFilterObject = whiteningFilterClass( ...
          transitFitModel.whiteningFilterObject ) ;
  end
  
return

% end of construct_transitFitModel_from_format24_struct subfunction

%=========================================================================================

% subfunction which returns nonzero values from a vector

function values = nonzero_values( valuesAll )

  values = valuesAll( valuesAll ~= 0 ) ;
  
return

% and that's it!

%
%
%
