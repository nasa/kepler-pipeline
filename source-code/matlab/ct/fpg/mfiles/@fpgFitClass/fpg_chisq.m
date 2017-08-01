function [chisq,ndof] = fpg_chisq( fpgFitObject, useInitialValues, useCorrelations, ...
                                          useRobustWeights )
%
% FPG_CHISQ compute the chi-square value for an FPG fit.
%
% [chisq,ndof] = fpg_chisq( fpgFitObject, useInitialValues, useCorrelations, 
%    useRobustWeights) computes the chi-square of an FPG fit, represented by the
%    fpgFitObject argument.  The remaining 3 arguments are interpreted as follows:
%
%        useInitialValues:  if TRUE, the fpgFitObject.initialParValues set of model values
%          is used.  If FALSE, the fpgFitObject.finalParValues set of model values is
%          used.
%
%        useCorrelations:  if TRUE, the off-diagonal terms of the covariance matrix are
%          used; if FALSE, only the diagonal terms are used.
%
%        useRobustWeights:  if TRUE, the weights applied to the data points by the robust
%          fitter are included in the calculation; if FALSE, the robust weights are
%          ignored.
%
% Note that the returned chi-square value is not normalized to the number of degrees of
%    freedom of the fit.  The number of degrees of freedom, ndof, is also returned.
%
% Version date:  2008-December-17.
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
%    2008-December-17, PT:
%        fix case when inverting big sparse matrix causes a crash due to inv() desparsing
%        the thing internally, resulting in out of memory error.  For diagonal matrix we
%        now manually construct a sparse inverse.  For non-diagonal matrix there is no
%        fix, so out-of-memory error is still a strong possibility.
%
%=========================================================================================

% First step is to get the residuals, which in turn requires that the model values be
% computed.  Depending on the setting of useInitialValues, this requires either the
% initial or the fitted values (which may not be present, if no fit has been performed).

  if (useInitialValues)
      modelValues = model_function( fpgFitObject, fpgFitObject.initialParValues ) ;
      
  else
      if (~isempty(fpgFitObject.finalParValues))
          modelValues = model_function( fpgFitObject, fpgFitObject.finalParValues ) ;
      else
          error('FPG:fpgChisq:finalParValues',...
              'fpg_chisq:  finalParValues member of fpgFitObject is empty') ;
      end
  end
  
  residuals = fpgFitObject.constraintPoints - modelValues ;
  residuals = residuals(:) ;
  
% Note that either the constraintPoints or the modelValues can in principle have NaN's in
% them, signalling a mismatch between the expected mod/out and the actual one.  Either a
% NaN in the constraintPoints or in the modelValues will lead to one in the residuals.  We
% can handle that by (1) noting the # of NaNs in residuals and taking that into account in
% computing the number of degrees of freedom, (2) setting any NaN in the residual to zero
% so it does not contribute to the chisq but also does not cause chisq -> NaN, (3) raising
% a warning to the user.

  nanIndex = find(isnan(residuals)) ;
  if (isempty(nanIndex))
      numNaNs = 0 ;
  else
      numNaNs = length(nanIndex) ;
      residuals(nanIndex) = 0 ;
      warning('FPG:fpgChisq:NaNs',...
          'fpg_chisq: NaN values detected in residual vector') ;
  end
  
% now we need to use the correct error model:  errors with or without the robust weights,
% and with or without use of the off-diagonal components of the covariance matrix.  Start
% with the robust weights:  if robust weights are selected, then the diagonal terms of the
% covariance matrix should be divided by the square of the weights, since the weights are
% the weights in amplitude space.

  covariance = fpgFitObject.constraintPointCovariance ;
  
  if ( useRobustWeights )
      
      if (~isempty(fpgFitObject.robustWeights))
      
          for iPoint = 1:fpgFitObject.nConstraintPoints
              covariance(iPoint,iPoint) = covariance(iPoint,iPoint) ...
                                        / fpgFitObject.robustWeights(iPoint)^2 ;
          end
          
      else
          error('FPG:fpgChisq:robustWeights',...
              'fpg_chisq: robustWeights member of fpgFitObject is empty') ;
      end
      
  end
  
% if the user wanted just the diagonal terms, take care of that now.  Note that if you
% use the form which includes correlations and it is very large, the inversion can run out
% of memory even if the covariance matrix is sparse.  

  if ( ~useCorrelations )
      covariance = diag(covariance) ;
      invCovarianceVector = 1./covariance ;
      invCovariance = sparse([1:fpgFitObject.nConstraintPoints], ...
          [1:fpgFitObject.nConstraintPoints], invCovarianceVector , ...
          fpgFitObject.nConstraintPoints, fpgFitObject.nConstraintPoints) ;
  else
      invCovariance = inv(covariance) ;
  end
  
% get the normalized square of the residuals

  chisqContribution = residuals' * invCovariance * residuals ;
  
  chisq = sum(chisqContribution) ;
  
  ndof = length(residuals) - length(fpgFitObject.initialParValues) - numNaNs ;
  
% and that's it!

%
%
%
