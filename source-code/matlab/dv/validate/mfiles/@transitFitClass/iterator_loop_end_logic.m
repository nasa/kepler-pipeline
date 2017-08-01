function [convergenceFlag, secondaryConvergenceFlag, fitType, bestFitObjectPreviousType, iterLimitNew, ...
    transitFitObjectLastIter, transitObject, doRobustFit, normParameterVariation, deltaChiSquare, finalParValues] = ...
    iterator_loop_end_logic(transitFitObject, transitFitObjectLastIter,  bestFitObjectPreviousType, iterLimitOld, robustFitRequested, kicStarRadius, nIter)
%
% iterator_loop_end_logic -- perform all of the comparisions and calculations which are
% needed at the end of the iterative whitener fitter loop
%
% [convergenceFlag, fitType, bestFitObjectPreviousType, iterLimitNew,
%    transitFitObjectLastIter, transitObject, doRobustFit] = iterator_loop_end_logic( 
%    transitFitObject, transitFitObjectLastIter, iterLimitOld, robustFitRequested,
%    kicStarRadius, convergenceTolerance, nIter ) performs all of the tortuous
%    decision-making which has to be done at the end of the iterator fitter loop.  
%
% Version date:  2011-April-16.
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
%    2012-April-16, JL:
%        Add 'finalParValues' in the outputs
%    2011-October-31, JL:
%        For inputs of 'determine_convergence', replace 'convergenceTolerance' and 
%       'secondaryConvergenceTolerance' with 'parameterConvergenceToleranceArray' and 
%       'secondaryParameterConvergenceToleranceArray', add 'chiSquareConvergenceTolerance'.
%        For outputs of 'determine_convergence', add 'normParameterVariation' and
%        'deltaChiSquare'.
%    2011-January-31, JL:
%        implement secondary convergence criterion
%    2010-April-29, PT:
%        change in support of transitGeneratorCollectionClass.
%    2009-September-24, PT:
%        use get_robust_fit_status instead of if statement to determine whether the
%        transitFitClass object is configured for robust fitting.
%
%=========================================================================================

% we need a few more things from the object

  oddEvenFlag        = transitFitObject.oddEvenFlag;
  fitType            = transitFitObject.fitType;
  finalParValues     = transitFitObject.finalParValues;
  robustFitPerformed = get_robust_fit_status( transitFitObject );
%   if strcmpi( kepler_get_soc( transitFitObject.fitOptions, 'robust' ), 'on' )
%       robustFitPerformed = true ;
%   else
%       robustFitPerformed = false ;
%   end
  
% set default return values for everything except convergenceFlag

  iterLimitNew = iterLimitOld ;
  transitObject = get_fitted_transit_object( transitFitObject ) ;
  doRobustFit = robustFitPerformed ;
  
% first things first -- see whether the fit has even converged and update the last-iter
% object with the current-iter object

  parameterConvergenceToleranceArray          = transitFitObject.configurationStruct.parameterConvergenceToleranceArray;
  secondaryParameterConvergenceToleranceArray = transitFitObject.configurationStruct.secondaryParameterConvergenceToleranceArray;
  chiSquareConvergenceTolerance               = transitFitObject.configurationStruct.chiSquareConvergenceTolerance;
  
  [convergenceFlag, secondaryConvergenceFlag, normParameterVariation, deltaChiSquare] = ...
      determine_convergence( transitFitObject, transitFitObjectLastIter, ...
                             parameterConvergenceToleranceArray, secondaryParameterConvergenceToleranceArray, chiSquareConvergenceTolerance );
  transitFitObjectLastIter = transitFitObject ;
  
% If we have not yet done robust fitting, but are requested to do so, handle that case
% now.  That means clear the convergence flag (so the iterator will do more iterations),
% set the flag that says we are ready for robust fitting, and increase the iteration limit

  if convergenceFlag && (robustFitRequested && ~robustFitPerformed)
      doRobustFit              = true;
      convergenceFlag          = false;
      secondaryConvergenceFlag = false;
      iterLimitNew             = iterLimitOld + nIter;
      disp('      Switching to robust fitting') ;
  end
  
% Do we need to change to the other fit type?  This can be done only if we are fully
% converged, are in fit type 1, are doing all-transits fitting, and the fitted star radius
% is < the KIC star radius.  Also, if the attempt to recast the transit object with the
% new star radius fails, then we don't attempt to fit with the new fit type

  if convergenceFlag && oddEvenFlag == 0 && fitType == 1 && ...
          kicStarRadius > get( transitObject, 'starRadiusSolarRadii' )
      try
          transitObject = get_transit_object_with_new_star_radius( transitObject, ...
              kicStarRadius ) ;
          convergenceFlag = false ;
          fitType = 0 ;
          bestFitObjectPreviousType = transitFitObject ;
          transitFitObjectLastIter = [] ;
          doRobustFit = false ;
          iterLimitNew = iterLimitOld + nIter ;
          disp('      Switching to fitting impact parameter with star radius at KIC value') ;
      catch
          % do nothing, we are converged in this case
      end
  end
  
return

% and that's it!

%
%
%
