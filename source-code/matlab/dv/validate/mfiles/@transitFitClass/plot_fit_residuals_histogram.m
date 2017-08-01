function plotHandle = plot_fit_residuals_histogram( transitFitObject, constraintFlag )
%
% plot_fit_residuals_histogram -- plot histograms of transit fit residuals
%
% plotHandle = plot_fit_residuals_histogram( transitFitObject, constraintFlag ) plots the
% fit residuals of the transit fit contained in the transitFitObject.  If constraintFlag
% is true, then a single plot is produced which shows only the data points which were used
% to constrain the fit (ie, points near a transit).  If constraintFlag is false, then a
% 2-subplot figure is produced which shows all valid constraint points and all valid
% constraint points which are far from a transit (ie, valid constraint points which were
% not used for constraint purposes).
%
% Version date:  2011-January-31.
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
%    2011-January-31, JL:
%        add the flag fitTimeCheckSkipped in 'model_function'
%
%=========================================================================================

% identify all the good constraint points, all the used good ones, and all the unused good
% ones

  goodConstraintPoints = get_included_excluded_cadences( transitFitObject ) ;
  goodUsedConstraintPoints = get_included_excluded_cadences( transitFitObject, true ) ;
  goodUnusedConstraintPoints = goodConstraintPoints & ~goodUsedConstraintPoints ;
  
% get the whitened model values time series

  modelValues = model_function(transitFitObject, transitFitObject.finalParValues, true, true) ;
  
% get the residuals

  fitResiduals = transitFitObject.whitenedFluxTimeSeries.values - modelValues ;
  
% do somewhat different things depending on the constraintFlag value

  figure ;
  if (constraintFlag)
      
      dv_histfit(fitResiduals(goodUsedConstraintPoints));
      xlim = get( gca, 'xlim' ) ;
      set( gca, 'xlim', max(abs(xlim)) * [-1 1] ) ;
      xlabel( 'Fit Residual [\sigma]' ) ;
      
  else
      
      subplot(2,1,1) ;
      dv_histfit(fitResiduals(goodConstraintPoints));
      xlim = get( gca, 'xlim' ) ;
      title( 'All Valid Data Points' ) ;
      
      subplot(2,1,2) ;
      dv_histfit(fitResiduals(goodUnusedConstraintPoints));
      xlim = [xlim get( gca, 'xlim' )] ;
      title( 'Valid Non-Constraining Data Points' ) ;
      set( gca, 'xlim', max(abs(xlim))*[-1 1] ) ;
      xlabel( 'Fit Residual [\sigma]' ) ;
      subplot(2,1,1) ;
      set( gca, 'xlim', max(abs(xlim))*[-1 1] ) ;
      
  end
  
  plotHandle = gcf ;
  
return

% and that's it!

%
%
%
