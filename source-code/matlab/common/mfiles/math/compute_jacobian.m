function J = compute_jacobian( model, modelPars, X, stepSize, maxIter, ...
    maxDelta, deltaScale, failType )
%
% compute_jacobian -- numerically compute a Jacobian matrix for a model
%
% J = compute_jacobian( model, modelPars, X, stepSize ) computes the Jacobian for a model
%    at a given location.  Argument model is a model function, specified via @, which
%    produces a vector of outputs of length M; modelPars is a vector of length N of
%    parameters which is an argument to model; X is an optional argument to model (ie, the
%    call may be outputVector = model(modelPars) or outputVector = model(modelPars,X) ).
%    The resulting matrix, J, is M x N, and J(i,j) = d(output(i))/d(modelPars(j)).
%    Optional argument stepSize is a scalar or else vector of length N, which is the step
%    size to use in calculating the Jacobian.  If no step size is specified, a default
%    value will be obtained via the statset / statget operations.  The step size may be a
%    scalar or a vector of length N (ie, equal to modelPars).
%
% J = compute_jacobian( ..., maxIter, maxDelta, deltaScale failType ) uses optional
%    parameters to determine what to do if the computed Jacobian has an apparent zero
%    column, indicating that the Jacobian is independent of one of the model parameters:
%
%    maxIter:     maximum number of times that the differential will be scaled up in an
%                 attempt to find a change in the Jacobian which is larger than roundoff
%                 error (default:  inf)
%    maxDelta:    maximum value of the differential change in parameters which will be 
%                 used prior to termination (default:  realmax)
%    deltaScale:  factor that the differential change will be scaled on each iteration
%                 (default:  10)
%    failType:    desired activity if a zero column cannot be resolved by scaling up the
%                 differential value.  Options are 'error', 'warning', 'nothing'
%                 (default:  'error').
%
% Version date:  2009-October-09.
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
%    2009-October-09:
%        bugfixes -- proper handling of cases where we do and do not fall out of the loop
%        due to exhausting # of iterations and/or max delta.
%    2009-August-26, PT:
%        bugfix for cases in which user specifies 'nothing' failType and computation falls
%        out of while loop due to exhausted iterations or maxDelta exceeded.
%    2009-August-21, PT:
%        support for delta < 0.
%    2009-August-19, PT:
%        allow the user to specify maxIter, maxDelta, deltaScale, failType.
%
%=========================================================================================

% Implementation note:  this function is strongly derived from the getjacobian subfunction
% in nlinfit.

% hard-coded parameter:  minimum change in the model function from modelPars to modelPars
% + epsilon which is recognized as distinct from zero

  minDy = 1e-12 ; 
  
% set optional / default parameters

  if ~exist('maxIter','var') || isempty(maxIter)
      maxIter = inf ;
  end
  if ~exist('maxDelta','var') || isempty(maxDelta)
      maxDelta = realmax ;
  end
  if ~exist('deltaScale','var') || isempty(deltaScale)
      deltaScale = 10 ;
  end
  if ~exist('failType','var') || isempty(failType)
      failType = 'error' ;
  end
  
% error out if any of maxIter, maxDelta, deltaScale have invalid values

  if maxIter < 0 || maxDelta <= 0 || deltaScale <= 1
      error('common:computeJacobian:iterationParametersInvalid', ...
          'compute_jacobian:  invalid parameters for iteration') ;
  end
  
% if the stepSize is not defined, then define it

  if ( nargin < 4 ) || ( isempty(stepSize) )
      nlinfitOptions = kepler_set_soc('kepler_nonlinear_fit_soc') ;
      stepSize = nlinfitOptions.DerivStep * ones(size(modelPars)) ;
  end
  
% if stepSize is a scalar, make it a vector

  if ( isscalar(stepSize) )
      stepSize = stepSize * ones(size(modelPars)) ;
  end
  
% if stepSize is a vector with the wrong size, throw an error

  if ( length(modelPars(:)) ~= length(stepSize(:)) )
      error('common:computeJacobian:argumentSizeMismatch', ...
          'compute_jacobian: modelPars and stepSize dimensions are mismatched') ;
  end
  
% Get the values of the model function at the central values of the model pars

  oneArgumentModelFn = ( nargin < 3 ) || ( isempty(X) ) ;
  if oneArgumentModelFn
      y0 = model(modelPars) ;
  else
      y0 = model(modelPars,X) ;
  end
  y0 = y0(:) ;
  
% construct the return matrix and some other useful variables

  N = length(modelPars) ;
  M = length(y0) ;
  J = zeros(M,N) ;
  
  delta = zeros(size(modelPars)) ;
  
% loop over the parameters and perform the finite-difference calculation

  for iPar = 1:N
      
      if (modelPars(iPar) == 0)
          nb = sqrt(norm(modelPars)) ;
          delta(iPar) = stepSize(iPar) * ( nb + (nb==0) ) ;
      else
          delta(iPar) = stepSize(iPar) * modelPars(iPar) ; 
      end
      delta = delta / deltaScale ; 
      
%     compute the finite difference deriviative in a while-loop so that if the diff is
%     numerically indistinguishable from zero, we can try again with an order of magnitude
%     larger difference in the parameter, and continue to iterate up until we reach the
%     max value of the number
      
      dy = zeros(size(y0)) ;
      nIter = 0 ;

%     iteration occurs as long as the following conditions are true:
%     -> all finite diff values are < minDy
%     -> all delta values are < maxDelta
%     -> # of iterations <= maxIter
      
      while all(abs(dy) <= minDy) && all(abs(delta) < maxDelta) && nIter <= maxIter
          
          delta = delta * deltaScale ;          
          if oneArgumentModelFn
              yplus = model(modelPars+delta) ;
          else
              yplus = model(modelPars+delta,X) ;
          end
          nIter = nIter + 1 ;
      
          dy = yplus(:) - y0 ;
          
      end % while loop
      
%     if we fell out of the loop above due to exhausting the # of iterations or reached
%     the limit of maxDelta, we need to handle the failure based on the user's requested
%     handling mechanism (note that nIter = 1 greater than what it was on the last
%     iteration no matter what happened, so compensate for that now)

      if all(abs(dy) <= minDy) && ...
              ( any( delta >= maxDelta ) || nIter >= maxIter+1 )
          
          switch failType
              
              case 'error'
                  error('common:computeJacobian:badModelParameter', ...
                      ['compute_jacobian:  model is independent of parameter ', ...
                      num2str(iPar)]) ;
              case 'warning'
                  warning('common:computeJacobian:badModelParameter', ...
                      ['compute_jacobian:  model is independent of parameter ', ...
                      num2str(iPar)]) ;
              case 'nothing'
%                  do nothing, but continue on to the final steps in the calculation
              otherwise
                  error('common:computeJacobian:failTypeInvalid', ...
                      ['compute_jacobian: ''',failType,''' value of failType argument is invalid']) ;
                  
          end
                  
      end
      
%     divide dy by delta and put the resulting finite difference into J

      J(:,iPar) = dy / delta(iPar) ;
      delta(iPar) = 0 ;
      
  end % loop over parameters
  
return 

% and that's it!

%
%
%
