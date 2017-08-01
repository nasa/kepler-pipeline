function fpgFitObject = do_fpg_fit( fpgFitObject )
%
% DO_FPG_FIT -- perform the Focal Plane Geometry fit associated with an fpgFitClass object
%
% do_fpg_fit( fpgFitObject ) performs the fit which is associated with an fpgFitClass
%    object, which can include a combination of focal plane geometry parameters, focal
%    plane plate scale parameter, and pointing parameters for cadences other than the
%    reference cadence represented in the fit.  
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
%        clear unnecessary jacobian.
%
%=========================================================================================

% make sure that there's a fit which can be performed -- this is indicated by the presence
% of a non-trivial covariance matrix

  if (~isempty(fpgFitObject.constraintPointCovariance))
      
%     compute the weights from the diagonal of the covariance matrix

      dataWeight = 1./sqrt(diag(fpgFitObject.constraintPointCovariance)) ;
            
%     define the anonymous function -- it has the weights, and also reverses the order
%     of the arguments, since the model_function requires the fpgFitObject as its first
%     argument (since it's a class method), while the nlinfit model requires the vector
%     of parameters as its first argument (because nlinfit wants it that way)

      weighted_model = @(b,x) dataWeight .* model_function(x,b) ;
        
%     do the fit via kepler_nonlinear_fit_soc and capture the returns which we want to capture

      [fpgFitObject.finalParValues, residuals, jacobian, fpgFitObject.parValueCovariance, ...
          chisq, fpgFitObject.robustWeights] = kepler_nonlinear_fit_soc( fpgFitObject, ...
          dataWeight .* fpgFitObject.constraintPoints, weighted_model, ...
          fpgFitObject.initialParValues, fpgFitObject.fitterOptions ) ;
      
%     the Jacobian is huge and not actually useful, so clear it

      clear jacobian ;
      
%     if the fit was not robust, then kepler_nonlinear_fit_soc returns an empty for the robust weights;
%     since we want those weights, set to a vector of ones in this case.

      if (isempty(fpgFitObject.robustWeights))
          fpgFitObject.robustWeights = ones(size(fpgFitObject.constraintPoints)) ;
      end
      
%     compute the chisq and the ndof of the final fit; use the robust weights and the
%     final values of the parameters but neglect the correlations in the covariance matrix

      [fpgFitObject.chisq, fpgFitObject.ndof] = fpg_chisq( fpgFitObject, 0, 0, 1 ) ;
      
% now handle the case in which the constraintPointsCovariance was empty -- raise a
% warning to the user

  else
      
      warning('FPG:doFpgFit:fitSkipped',...
          'do_fpg_fit: fit skipped due to empty covariance matrix') ;
      
  end
  
% and that's it!

%
%
%
