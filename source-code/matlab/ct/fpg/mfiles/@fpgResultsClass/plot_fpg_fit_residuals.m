function [figureHandleBefore, figureHandleAfter] = plot_fpg_fit_residuals( fpgResultsObject )
%
% plot_fpg_fit_residuals -- plot the distribution of residuals from FPG before and after
% performing the fit.
%
% [h1, h2] = plot_fpg_fit_residuals( fpgResultsObject ) returns the figure handles for the
%    plots of fit residual distributions before and after the FPG fit.  In each plot, the
%    reference cadence is shown and the distribution over all cadences is shown as well.
%
% Version date:  2008-July-11.
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
%=========================================================================================

  fpgFitObject = fpgResultsObject.fpgFitClass ;
  
% use a helper function, since the two plots are pretty similar

  figureHandleBefore = plot_fpg_residuals( fpgFitObject, 0 ) ;
  figureHandleAfter  = plot_fpg_residuals( fpgFitObject, 1 ) ;
  
% and that's it!

%
%
%

%=========================================================================================

% here's the helper function which does all the work

function figHandle = plot_fpg_residuals( fpgFitObject, timeFlag )

% get the model values using either the initial or final parameters

  if (timeFlag == 0)
      parVector = get(fpgFitObject,'initialParValues') ;
  else
      parVector = get(fpgFitObject,'finalParValues') ;
  end
  
  modelValues = model_function( fpgFitObject, parVector ) ;
  residuals = get(fpgFitObject,'constraintPoints') - modelValues ;
  
  [scaleFactor,prefix] = get_engineering_notation_scaling( residuals ) ;

% do the all-cadences plot first

  figure ;
  subplot(2,1,2) ;
  hist(scaleFactor*residuals,0.5*sqrt(length(residuals))) ;
  if (timeFlag == 0)
      title('Pre-Fit Residuals, All Cadences') ;
  else
      title('Post-Fit Residuals, All Cadences') ;
  end
  xlabel(['Residuals [',prefix,'pixels]']) ;
  h1 = gca ;

% now produce the cadence-1 plot

  raDecModOut = get(fpgFitObject,'raDecModOut') ;
  nPointsRefCadence = size(raDecModOut(1).matrix,1) ;
  subplot(2,1,1) ;
  hist(scaleFactor*residuals(1:2*nPointsRefCadence),0.5*sqrt(2*nPointsRefCadence)) ;
  if (timeFlag == 0)
      title('Pre-Fit Residuals, Ref Cadence') ;
  else
      title('Post-Fit Residuals, Ref Cadence') ;
  end
  xlabel(['Residuals [',prefix,'pixels]']) ;
  h2 = gca ;

% set the x limits on both plots

  xLimit = [get(h1,'XLim') get(h2,'XLim')] ;
  xLimit = max(abs(xLimit)) ;
  set(h1,'XLim',[-xLimit xLimit]) ;
  set(h2,'XLim',[-xLimit xLimit]) ;
  
  figHandle = gcf ;
  
% and that's it!
