function [detrendedFluxTimeSeries, frontExponentialSize, backExponentialSize] = ...
    detrend_edges_of_time_series(fluxTimeSeries, parametersStruct )
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


nCadencesPerDay = round(parametersStruct.cadencesPerDay); % just need an approximate value

[nCadences, nStars] = size(fluxTimeSeries);

if(nCadences < 3*nCadencesPerDay)
    detrendedFluxTimeSeries = fluxTimeSeries;
    frontExponentialSize = -1;
    backExponentialSize = -1;
    fprintf('too few cadences, so skipping detrending edges...\n');
    return;
end

if(nStars > 1)
    detrendedFluxTimeSeries = fluxTimeSeries;
    frontExponentialSize = -1;
    backExponentialSize = -1;
    fprintf('more than one time series, so skipping detrending edges...\n');
    return;
end
  
%------------------------------------------------------------------
% Detrend edges of quarterly flux
%------------------------------------------------------------------

% perform the exponential detrending

[detrendedFluxTimeSeries, frontExponentialSize, backExponentialSize] = ...
    exponential_edge_detrending( ...
    fluxTimeSeries ) ;   

return

%=========================================================================================

% subfunction to perform initial exponential detrending:  this attempts to perform a
% robust fit of the time series to a function with the form:
%
% y(t) = p_1 exp( -t/p_2 ) + p_3 * t + p_4 + p_5 * exp( (t-t_f) / p_6 ) , 
%
% in other words an exponential decay from an initial value to a time series with a linear
% trend, and then an exponential rise to the final value of the time series.

function [fluxTimeSeriesFinal,frontExponentialSize,backExponentialSize] = ...
    exponential_edge_detrending( fluxTimeSeriesInitial )

% set the nlinfit parameters

  opts = kepler_set_soc('nlinfit') ;
  opts.Robust = 'on' ;
  opts.convSigma = 0.5 ;
  opts.tolFun = 2e-02 ;
  
% model parameters are as follows:
%
%    Amplitude of leading-edge exponential [fraction]
%    Time constant of leading-edge exponential [cadences]
%    Slope of linear fit
%    Intercept of linear fit
%    Amplitude of trailing-edge exponential
%    Time constant of trailing-edge exponential
%
% Set model initial values -- note that if the initial amplitudes are exactly zero then
% the Jacobian for the exponential time constants becomes NaN.  Note also that the
% parameters in their natural state are poorly scaled, so we will apply a scale factor
% which will make all of the parameters of order unity.

  timeConstantInitialGuess = 49 ; % cadences

% for the amplitude initial guess, use the first and last nonzero values in the unit of
% work

  firstValue = fluxTimeSeriesInitial( find( fluxTimeSeriesInitial ~= 0, 1, 'first' ) ) ;
  lastValue  = fluxTimeSeriesInitial( find( fluxTimeSeriesInitial ~= 0, 1, 'last' ) ) ;
  
% there is a corner case in which this will still fail, namely, fluxTimeSeriesInitial is
% all zero-valued.  I can't imagine a case in which such a time series would get passed
% down here, but just in case I'll protect against it.

  if ~isempty( firstValue ) && ~isempty( lastValue )
      
%     if the scale of the initial time series is too small, nlinfit will error out since
%     it is looking for | delta_y | > 1e-12; so rescale any time series so that it has a
%     range of about unity, so that we are far away from this threshold

      timeSeriesRange = range( fluxTimeSeriesInitial ) ;
      rescaleExponent = -floor( log10( timeSeriesRange ) ) ;
      timeSeriesRescaleFactor = 10^rescaleExponent ;
      fluxTimeSeriesInitial = fluxTimeSeriesInitial * timeSeriesRescaleFactor ;
      firstValue            = firstValue            * timeSeriesRescaleFactor ;
      lastValue             = lastValue             * timeSeriesRescaleFactor ;
      
%     As if that wasn't enough, there is an additional conditioning problem for the fit,
%     which is the relative magnitudes of the columns of the Jacobian.  This is addressed
%     by applying a scale factor to the exponential amplitude parameters (and implicitly
%     the slope and offset of the line fit), and compensate for same in the model
%     function.
      
      jacobianScaleFactor = 1e6 ;
      initialParGuess = [firstValue * jacobianScaleFactor            ...
                         timeConstantInitialGuess                    ...
                          0                                          ...
                          0                                          ...
                         lastValue * jacobianScaleFactor             ...
                         timeConstantInitialGuess]                       ;
      initialParGuess = initialParGuess(:) ;
      initialParGuessThisIteration = initialParGuess ;


%     perform the fit

      x = 0:length(fluxTimeSeriesInitial)-1 ;
      x = x(:) ;
      fitMode = 'full' ;

%     construct the model function 

%     Under certain conditions, the fit will error out in kepler_nonlinear_fit_soc; this usually means
%     that it converged to a condition where one or the other exponential, or both,
%     has a near-infinite time constant, resulting in a jacobian explosion.  We need to
%     detect these cases and respond to them appropriately

      fitConverged = false ;
      while ~fitConverged 

          try
              
              modelFun = @(pars,y) exponentialDetrendModelFunction( pars, y, ...
                  jacobianScaleFactor, fitMode ) ;
              warningState = warning('off','all') ;
              [parValues,~,~,~,~,weights] = kepler_nonlinear_fit_soc( x, fluxTimeSeriesInitial, modelFun, ...
                  initialParGuessThisIteration, opts, true ) ;
              fitConverged = true ;

          catch lastError

              if ~isempty( strfind( lastError.identifier, 'parameterDeltaInvalid' ) ) && ...
                      ~strcmp( fitMode, 'linear' )
                  
                  disp(['      Exponential edge detrending failed, retrying with bad ', ...
                      'parameters removed']) ;
                  badParameter = str2num( lastError.message( ...
                      strfind( lastError.message, 'parameter' ) ...
                      + 10 ) ) ;
                  if strcmp( fitMode, 'full' ) && badParameter < 3 % first exponential bad
                      fitMode = 'last-only' ;
                      initialParGuessThisIteration = initialParGuess(3:6) ;
                  elseif strcmp( fitMode, 'full' ) && badParameter > 4 % 2nd bad
                      fitMode = 'first-only' ;
                      initialParGuessThisIteration = initialParGuess(1:4) ;
                  elseif strcmp( fitMode, 'linear' )  % very broken, rethrow error
                      rethrow( lastError ) ;
                  else                                                 % both exponentials bad
                      fitMode = 'linear' ;
                      initialParGuessThisIteration = initialParGuess(3:4) ;
                  end
                  
              else % some other error, rethrow
                  
                  rethrow( lastError ) ;
                  
              end
              
          end % try-catch block
          
          warning(warningState) ;
          
      end % while fit not converged

%     the detrended time series is the initial time series minus the trend  

       [fluxTimeSeriesModel, frontExponentialSize, backExponentialSize] = ...
           modelFun( parValues, x ) ;
       fluxTimeSeriesFinal  = fluxTimeSeriesInitial - fluxTimeSeriesModel ;
       fluxTimeSeriesFinal  = fluxTimeSeriesFinal   / timeSeriesRescaleFactor ;
       frontExponentialSize = frontExponentialSize  / timeSeriesRescaleFactor ;
       backExponentialSize  = backExponentialSize   / timeSeriesRescaleFactor ;
       
  else % corner case, time series is all zeros
      
      fluxTimeSeriesFinal = fluxTimeSeriesInitial ;
      frontExponentialSize = 0 ;
      backExponentialSize = 0 ;
      
  end
 
return

%=========================================================================================

function [yModel, frontExponentialSize, backExponentialSize] = ...
    exponentialDetrendModelFunction( pars, x, jacobianScaleFactor, fitMode )

% convert external to internal pars, based on the fit mode

  internalPars = [0 ; 1 ; 0 ; 0 ; 0 ; 1] ;
  switch fitMode
      
      case 'full'
          
          internalPars = pars ;
          
      case 'first-only'
          
          internalPars(1:4) = pars ;
          
      case 'last-only'
          
          internalPars(3:6) = pars ;
          
      case 'linear'
          
          internalPars(3:4) = pars ;
          
  end

% individual terms

  yModel1 = internalPars(1) * exp( -x / abs(internalPars(2)) ) ;
  yModel2 = internalPars(3) * x ;
  yModel3 = internalPars(4) ;
  yModel4 = internalPars(5) * exp( ( x - x(end) ) / abs(internalPars(6)) )  ;
  
  yModel = ( yModel1 + yModel2 + yModel3 + yModel4 ) / jacobianScaleFactor ;
  frontExponentialSize = (yModel1(1)-yModel1(end)) / jacobianScaleFactor ;
  backExponentialSize = (yModel4(end)-yModel4(1)) / jacobianScaleFactor ;
  
return
  


