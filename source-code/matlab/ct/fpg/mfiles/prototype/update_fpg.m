function [finalParValues,parCovariance,weights] = update_fpg( constraintPoints, covariance, ...
      fitterArgs, initialParValues, fitterOptions, doNlinfit, doLscov )
%
% update_fpg -- perform focal plane geometry fit.
%
% [finalParValues, parCovariance, weights] = update_fpg( constraintPoints, covariance, fitterArgs,
%    initialParValues, fitterOptions ) performs the focal plane geometry fit.  Its input
%    arguments are the output arguments from unpack_fpg_options.  Function update_fpg
%    returns finalParValues, a vector of final parameter values; parCovariance, the
%    covariance matrix for the fitted parameters; and weights, the robust weights applied
%    by the fitter.  The weights represent the fractional change in 1/sigma, with a weight
%    of 1 indicating that the point was not deweighted, a weight of 0.5 indicating that it
%    sigma was increased by a factor of 2, etc.
%
% [finalParValues, parCovariance, weights] = update_fpg( ... , doNlinfit, doLscov ) uses the
%    optional 6th and 7th arguments to indicate whether to perform the nonlinear fit stage
%    with nlinfit, and whether to perform the linear fit stage with lscov, respectively.
%    The default is to perform the nonlinear fit followed by the linear fit.
%
% See also:  unpack_fpg_options.  
%
% Version date:  2008-may-22.
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

% Modification history:
%
%    2008-may-22, PT:
%        in lscov fit, change chisq tolerance to a fractional-change instead of
%        absolute-change tolerance.
%    2008-may-19, PT:
%        support for unlimited # of fits with geometry parameters in them.
%    2008-may-15, PT:
%        protect against a fit with no data points!
%    2008-may-12, PT:
%        switch to use of kepler_nonlinear_fit_soc from nlinfit_fpg.
%    2008-may-02, PT:
%        use Hema's kepler_nonlinear_fit (returns weights), capture weight vectors.
%    2008-apr-30, PT:
%        restructure to support multiple independent fits in nlinfit, followed by one big
%        overall fit.
%
%=========================================================================================

% decode optional arguments

  if (nargin < 6)
      doNlinfit = 1;
  end
  if (nargin < 7)
      doLscov = 1 ;
  end
  
% if no fit selected, throw an error

  if ( (~doNlinfit) & (~doLscov) )
      error(' No fits selected in update_fpg') ;
  end
  
% initialize the nlinfitChisq to zero (we're going to use it later even if the nlinfit is
% not selected, so it has to be initialized)

  nlinfitChisq = 0 ;

% initialize performedNlinfit to 1, so that if the user just wants the lscov fit it 
% will execute properly

  performedNlinfit = 1 ;
  
% if selected, perform the non-linear fit

  if (doNlinfit)
      
      tic ;
      disp('...starting nlinfit...') ;
      
%     dimension the data structures which will capture the nlinfit results

      nlinfitParValues(length(fitterArgs)).array   = [] ;
      nlinfitResiduals(length(fitterArgs)).array   = [] ;
      nlinfitJacobian(length(fitterArgs)).matrix   = [] ;
      nlinfitCovariance(length(fitterArgs)).matrix = [] ;
      nlinfitChisq(length(fitterArgs))             = 0  ;
      weights(length(fitterArgs)).array            = [] ;

%     debugging garbage
%      fitterOptions(end) = fitterOptions(1) ; 
      
      for iFit = 1:length(fitterArgs)

%        check to make sure that there is some good data in this fit, otherwise skip it

         if (~isempty(covariance(iFit).matrix))
          
            performedNlinfit = 1 ;          
            tStart = clock ;
            disp(['   ...performing nlinfit step number ',num2str(iFit),'...']) ;

%           first step:  perform the non-linear fit with nlinfit -- it's a weighted fit, so use the
%           trick from Mathworks to do a weighted nlinfit call

            dataWeight = 1./diag(covariance(iFit).matrix) ;
  
%           define the anonymous function which has the weights but otherwise uses the
%           fpg_model_function to do its work

            weighted_model = @(b,x) sqrt(dataWeight) .* fpg_model_function(b,x) ;
          
%           perform the fit and capture the results in data structures
  
            [nlinfitParValues(iFit).array, nlinfitResiduals(iFit).array, ...
              nlinfitJacobian(iFit).matrix, nlinfitCovariance(iFit).matrix, ...
              nlinfitChisq(iFit),weights(iFit).array] = ...
              kepler_nonlinear_fit_soc( fitterArgs(iFit), sqrt(dataWeight).*constraintPoints(iFit).array, ...
                       weighted_model, ...
                       initialParValues(iFit).array, fitterOptions(iFit) ) ;
                   
%           if there's more than one fit, then we are doing a complicated multi-cadence,
%           multi-fit operation and need to capture the intermediate results for later use.
%           Do that now, unless we are on the last fit of the operation (in which case
%           there's nowhere to propagate the parameters to).

            if (iFit ~= length(fitterArgs))
              [initialParValues,fitterArgs] = capture_intermediate_par_values( ...
                            nlinfitParValues, fitterArgs, iFit, initialParValues ) ;
            end
                   
            tFinish = clock ;
            disp(['   ... done with nlinfit step ',num2str(iFit),', time = ',...
                  num2str(etime(tFinish,tStart)),'...']) ;
            disp(['      chisq / ndof for this step:  ',num2str(nlinfitChisq(iFit))]) ;
   
         else % no nlinfit because of lack of data

            performedNlinfit               = 0 ; 
            nlinfitParValues(iFit).array   = [] ; 
            nlinfitResiduals(iFit).array   = [] ;
            nlinfitJacobian(iFit).matrix   = [] ; 
            nlinfitCovariance(iFit).matrix = [] ;
            nlinfitChisq(iFit)             = NaN ;
            weights(iFit).array            = [] ;
            disp(['   ...skipped nlinfit step ',num2str(iFit),' due to lack of data ...']) ;

         end    
      
      end
               
      intermediateParValues = nlinfitParValues(end).array ;
      
      disp('...done with nlinfit!') ;
      disp(nlinfitChisq(end)) ;
      toc ;
                     
% if the nonlinear fit was not selected, then copy the initial values of the
% parameters into the nominal intermediate location

  else
      
      intermediateParValues = initialParValues ;
      
  end % doNlinfit condition
  
% if the linear fit was selected, then perform it now, unless the last nlinfit step failed

  if ( (doLscov) & (performedNlinfit) ) 
      
      tic ;
      disp('...starting lscov...') ;
      
%     Now, since this is a linear approximation of a nonlinear fit, iterations will be
%     required.  The iteration logic chosen here is the following:
%
%         always go at least twice through lscov
%         never go more than 10 times through lscov
%         iterate until the change in chisq < tolx
%         iterate until the RMS change in pars < tolfun.
%
%     initialize some variables related to that now

      iLscovIter = 0 ;
      deltaChisq = 0 ;
      deltaPar   = 0 ;
      oldMse     = nlinfitChisq ;
      
      tolx   = kepler_get_soc(fitterOptions,'TolX') ;
      tolfun = kepler_get_soc(fitterOptions,'TolFun') ;
      
      convergence = 0 ; 
      itersRemain = 1 ;
      
      while ( (~convergence) & (itersRemain) )
          
          iLscovIter = iLscovIter + 1 ;
      
%         numerically estimate the design matrix about the point which represents the current
%         best-guess of the parameters in the parameter space

          designMatrix = get_fpg_design_matrix( intermediateParValues, fitterArgs ) ;
      
%         Use lscov to estimate the change in parameters which best fits the residuals from
%         the current best-estimate parameter values

%         debugging garbage
%          covariance = diag(diag(covariance)) ;

          intermediateResiduals = constraintPoints(end).array - ...
              fpg_model_function( intermediateParValues, fitterArgs ) ;
          [deltaParValues,stdCov,mse,parCovariance] = ...
              lscov( designMatrix, intermediateResiduals, covariance(end).matrix ) ;
 
          intermediateParValues = intermediateParValues + deltaParValues ;

 %        calculate convergence criteria -- while we're at it, normalize chisq from lscov
 %        to ndof (nlinfit produces chisq/nu, lscov produces chisq)
  
          deltaChisq = abs(mse - oldMse) ;
          deltaPar = std(deltaParValues) ;
          oldMse = mse ;
          
          convergence = ( (deltaChisq < tolx*oldMse) & (deltaPar < tolfun) & (iLscovIter >= 2) ) ;
          itersRemain = ( iLscovIter < 10 ) ;
          
      end
      
      if (convergence)
        disp(['...done with lscov, converged after ',num2str(iLscovIter),' iterations!']) ;
      else
        disp(['...lscov failed to converge after ',num2str(iLscovIter),' iterations.']) ;
      end
      toc ;
      
% if the linear fit was not selected, then capture the covariance from nlinfit as the
% covariance of the fit

  else
      
      parCovariance = nlinfitCovariance ;
      
  end % doLscov condition
  
% no matter which fit was selected, capture the intermediate parameter values as final at
% this point, and return

  finalParValues = intermediateParValues ;
  
% and that's it!

%
%
%

%=========================================================================================

% compute the design matrix for lscov via numerical estimation 

function designMatrix = get_fpg_design_matrix( parValues, fitterArgs )

% get the values of the constraint points right at the point in parameter space
% represented by parValues

  y0 = fpg_model_function(parValues, fitterArgs) ;
  
% dimension the design matrix

  designMatrix = zeros(length(y0),length(parValues)) ;
  
% loop over members of the parameter value vector, adding a differential value to each one
% in turn and computing the resulting change in expected constraint point values

  dPar = 1e-8 ;
  dParVector = parValues ;
  
  for iPar = 1:length(parValues)
      dParVector(iPar) = dParVector(iPar) + dPar ;
      y1 = fpg_model_function(dParVector, fitterArgs) ;
      dParVector(iPar) = dParVector(iPar) - dPar ;
      designMatrix(:,iPar) = (y1-y0)/dPar ;
  end
  
% and that's it!

%
%
%

%=========================================================================================

% capture the intermediate geometry parameters and pointing error parameters and configure
% later fits to use that data appropriately.  This function has a hard-coded assumption
% that on the first fit only geometry parameters are being fitted via the reference
% cadence, that on subsequent fits the geometry of the off-reference cadences are being
% fitted, and that on the last fit there will be a combined fit of geometry and
% off-reference pointings.

function [initialParValues,fitterArgs] = capture_intermediate_par_values( ...
                          nlinfitParValues, fitterArgs, iFit, initialParValues )

% if this was a fit with geometry parameters included, then what we need to capture is the 
% geometry parameters for other such fits and for use in the fits which fit the pointing.
% Those parameters are put into the geometry model which is in the raDec2PixClass objects
% in fitterArgs (so that the fits of the off-normal pointings will get it), and also into
% the initialParValues array for the last fit.

  fitGeometryPars = [fitterArgs.fitGeometryFlag] ;
  fitsWithGeometry = find(fitGeometryPars ~= 0) ;

  if (~isempty(find(fitsWithGeometry == iFit)))
      
      
      
      geometryModel = get(fitterArgs(iFit).raDec2PixObject,'geometryModel') ;
      geometryParIndex = find(fitterArgs(iFit).geometryParMap ~= 0) ;
      nGeometryPar = length(geometryParIndex) ;
      plateScaleMap = fitterArgs(iFit).plateScaleParMap ;
      
      geometryModel.constants(1).array(geometryParIndex) = nlinfitParValues(iFit).array(1:nGeometryPar) ;
      
      if (plateScaleMap ~= 0)
          geometryModel.constants(1).array(253:336) = nlinfitParValues(iFit).array(plateScaleMap) ;
      end
      
%     since geometryModel often has multiple constant fields, make them all equal to the
%     first one now (ie, propagate the fitted constants to all constants fields)

      for iCon = 2:length(geometryModel.constants)
          geometryModel.constants(iCon).array = geometryModel.constants(1).array ;
      end
      
%     put the new geometryModel into all of the raDec2PixClass objects in fitterArgs

      for iFitArg = 2:length(fitterArgs)
          fitterArgs(iFitArg).raDec2PixObject = set(fitterArgs(iFitArg).raDec2PixObject, ...
              'geometryModel', geometryModel) ;
      end
      
%     extract the parameters from the geometryModel and insert them into the appropriate
%     slots of the initialParValues array for the other fits which have geometry fitting
%     in them.  Note that the various fits can have different mappings of geometry
%     parameters.

      for jFit = fitsWithGeometry(:)'

          geometryParIndexFinal = find(fitterArgs(jFit).geometryParMap ~= 0) ;
          nGeometryParFinal = length(geometryParIndexFinal) ;
          plateScaleMapFinal = fitterArgs(jFit).plateScaleParMap ;

          initialParValues(jFit).array(1:nGeometryParFinal) = ...
              geometryModel.constants(1).array(geometryParIndexFinal) ;
          if (plateScaleMapFinal~=0)
              initialParValues(jFit).array(plateScaleMapFinal) = ...
                  geometryModel.constants(1).array(336) ;    
          end
          
      end

  else 
      
% if we are on one of the later fits, then we need to capture the fitted pointing error of
% the current cadence, and put it into the initial values for the later fits in the
% correct slots

      currentRAPointer   = fitterArgs(iFit).cadenceRAMap   ;
      currentDecPointer  = fitterArgs(iFit).cadenceDecMap  ;
      currentRollPointer = fitterArgs(iFit).cadenceRollMap ;
      
      for jFit = fitsWithGeometry(:)'
          
        if (jFit > iFit)

          newRAPointer   = fitterArgs(jFit).cadenceRAMap(iFit)   ;
          newDecPointer  = fitterArgs(jFit).cadenceDecMap(iFit)  ;
          newRollPointer = fitterArgs(jFit).cadenceRollMap(iFit) ;

          initialParValues(jFit).array(newRAPointer)   = nlinfitParValues(iFit).array(currentRAPointer)   ;
          initialParValues(jFit).array(newDecPointer)  = nlinfitParValues(iFit).array(currentDecPointer)  ;
          initialParValues(jFit).array(newRollPointer) = nlinfitParValues(iFit).array(currentRollPointer) ;

        end
        
      end
      
  end
  
% and that's it!

%
%
%
      
