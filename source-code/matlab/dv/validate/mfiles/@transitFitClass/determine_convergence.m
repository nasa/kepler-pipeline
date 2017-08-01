function [isConverged, isSecondaryConverged, normParameterVariation, deltaChiSquare] = ...
    determine_convergence(transitFitObject, oldTransitFitObject, parameterConvergenceToleranceArray, secondaryParameterConvergenceToleranceArray, chiSquareConvergenceTolerance)
%
% determine_convergence -- determine whether two transitFitClass objects are within errors
% of each other
%
% isConverged = determine_convergence( transitFitObject, oldTransitFitObject,
%    convergenceTolerance ) compares the fitted parameter values in two
%    transitFitClass objects and determines whether they are within errors of one another,
%    as specified by the convergenceTolerance value.  If so, true is returned, otherwise
%    false.
%
% Version date:  2012-October-17.
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
%    2012-October-17, JL:
%        Error out when numbers of fitted parameters are not equal bewteen current and 
%        previous fits
%    2012-July-03, JL:
%        Modify the calculation of 'normParameterVariation'
%    2012-March-07, JL:
%        The outputs 'isConverged' and 'isSecondaryConverged' should be logical 
%    2011-October-31, JL:
%        For parameter convergence, apply 'tightParameterConvergenceTolerane' and
%        'looseParameterConvergeneTolerance' to different parameters.
%        Add chiSquare convergence.
%        For inputs of 'determine_convergence', replace 'convergenceTolerance' and 
%       'secondaryConvergenceTolerance' with 'parameterConvergenceToleranceArray' and 
%       'secondaryParameterConvergenceToleranceArray', add 'chiSquareConvergenceTolerance'.
%        For outputs of 'determine_convergence', add 'normParameterVariation' and
%        'deltaChiSquare'.
%    2011-January-31, JL:
%        implement secondary convergence criterion
%    2009-November-09, PT:
%        change debug levels -- now debug level >= 2 produces printout of normalized
%        parameter variation.
%    2009-September-17, PT:
%        change back to simply perform the calculation of parameter difference vs
%        convergence tolerance and return a boolean.
%    2009-September-16, PT:
%        make use of transitFitObject.fitType member.
%    2009-August-28, PT:
%        redo the isConverged == 2 option to look at the star radius instead of the impact
%        parameter.
%    2009-July-28, PT:
%        display the normParameterVariation if debugLevel is set accordingly.
%    2009-June-26, PT:
%        bugfix in arithmetic to produce chi-square contributions.
%
%=========================================================================================
  
% compute the difference in fitted parameters, normalized by the uncertainties.  

  if isempty( oldTransitFitObject )
      isConverged            = false;
      isSecondaryConverged   = false;
      normParameterVariation = -1*ones(length(transitFitObject.finalParValues), 1);
      deltaChiSquare         = -1;
  else

      newParameterValues = transitFitObject.finalParValues ;
      oldParameterValues = get(oldTransitFitObject,'finalParValues') ;

      if length(newParameterValues)~=length(oldParameterValues)
          error('dv:determine_convergence:unequalNumberOfFittedParameters', 'numbers of fitted parameters are not equal between current and previous fits');
      end
      
      parValueDiff = newParameterValues - oldParameterValues ;
      parValueDiff = parValueDiff(:) ;
      
%     invCovariance = inv(transitFitObject.parValueCovariance) ;
%     normParameterVariation = parValueDiff .* (invCovariance * parValueDiff) ;
     
      covariance = transitFitObject.parValueCovariance;
      normParameterVariation = parValueDiff .* parValueDiff ./ diag(covariance);
      
      if ( transitFitObject.debugLevel > 1 )
          disp( '      normalized parameter variation:  ' ) ;
          for iPar = 1:length(normParameterVariation)
              disp( [ '         ',num2str( normParameterVariation(iPar) ) ] ) ;
          end
      end
  
      newChiSquare   = transitFitObject.chisq;
      oldChiSquare   = get(oldTransitFitObject, 'chisq');
      deltaChiSquare = newChiSquare - oldChiSquare;
  
%     convergence has occurred if all the normParameterVariation terms are smaller than
%     the convergence tolerance squared (remember that normParameterVariation is the moral
%     equivalent of chi-square).  Note also that normParameterVariation may not be not
%     positive definite due to the presence of correlation terms

      isConverged          = ( all( abs(normParameterVariation) <= parameterConvergenceToleranceArray          ) || ...
                               abs( deltaChiSquare ) <= chiSquareConvergenceTolerance * newChiSquare            );
      isSecondaryConverged = ( all( abs(normParameterVariation) <= secondaryParameterConvergenceToleranceArray ) || ...
                               abs( deltaChiSquare ) <= chiSquareConvergenceTolerance * newChiSquare            );
        
  end % isempty oldTransitFitObject condition
      
  
return

% and that's it!

%
%
%

  