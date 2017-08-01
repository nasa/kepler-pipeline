function plot_fpg_fit_residuals( parValues, fitterArgs, constraintPoints, covariance )
%
% PLOT_FPG_FIT_RESIDUALS -- produce a histogram of the FPG fit residuals for the reference
% cadence, and one for all cadences.
%
% plot_fpg_fit_residuals( parValues, fitterArgs, constraintPoints ) plots two histograms:
%    one of the fit residuals for the reference cadence, and one of the fit residuals for
%    all cadences.
%
% plot_fpg_fit_residuals( ..., covariance ) does the same thing, except that the residuals
%    are normalized to the error on each constraint point.
%
% Version date:  2008-May-30.
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
%    2008-May-30, PT:
%        revised to put all mod/outs, both rows and columns, on a single plot, rather than
%        4 plots (row, col, radius, angle) per mod/out.
%
%=========================================================================================

% get the model values and form the residuals

  modelValues = fpg_model_function( parValues, fitterArgs ) ;
  residuals = constraintPoints - modelValues ;
  
% if the covariance is supplied, normalize the residuals

  if (nargin == 4)
      sigma = sqrt(diag(covariance)) ;
      residuals = residuals ./ sigma ;
      scaleFactor = 1 ;
      prefix = [] ;
  else
      [scaleFactor,prefix] = get_engineering_notation_scaling( residuals ) ;
  end
        
% identify the ones which are on the first cadence -- this can be determined by the number
% of rows in fitterArgs.RADecModOut(1).matrix

  nPointsRefCadence = size(fitterArgs.RADecModOut(1).matrix,1) ;
  
% produce the all-cadence plot first

  figure ;
  subplot(2,1,2) ;
  hist(scaleFactor*residuals,0.5*sqrt(length(residuals))) ;
  if (nargin == 4)
      title('Normalized Residuals, All Cadences')
      xlabel('Residuals / \sigma') ;
  else
      title('Residuals, All Cadences') ;
      xlabel(['Residuals [',prefix,'pixels]']) ;
  end
  h1 = gca ;
  
% now produce the cadence-1 plot

  subplot(2,1,1) ;
  hist(scaleFactor*residuals(1:2*nPointsRefCadence),0.5*sqrt(2*nPointsRefCadence)) ;
  if (nargin == 4)
      title('Normalized Residuals, Reference Cadences')
      xlabel('Residuals / \sigma') ;
  else
      title('Residuals, Reference Cadences') ;
      xlabel(['Residuals [',prefix,'pixels]']) ;
  end
  h2 = gca ;

% set the x limits on both plots

  xLimit = [get(h1,'XLim') get(h2,'XLim')] ;
  xLimit = max(abs(xLimit)) ;
  set(h1,'XLim',[-xLimit xLimit]) ;
  set(h2,'XLim',[-xLimit xLimit]) ;
  
% and that's it!

%
%
%

%=========================================================================================

% for comparison, here's the original version

function plot_fpg_fit_residuals_old( mod, out, parValues, fitterArgs, constraintPoints, covariance )
%
% PLOT_FPG_FIT_RESIDUALS -- plot a histogram of the FPG fit residuals for a given module
% and output.
%
% plot_fpg_fit_residuals( mod, out, parValues, fitterArgs, constraintPoints ) plots
%    histograms of the row, column, radius, and angle residuals from the fit for the
%    selected mod/out.
%
% plot_fpg_fit_residuals( ..., covariance ) produces the same plot, except that residuals
%    are normalized to the error on each constraint point.
%
% Version date: 2008-May-27.
%

% Modification History:
% 
%=========================================================================================

% get the residuals

  if (nargin == 5)

      [dRow,dCol,dRadius,dAngle] = get_fpg_residuals( constraintPoints, fitterArgs, ...
                       parValues ) ;
      normString = ' ' ;
      angString = 'Degrees' ;
      posString = 'pxiels' ;
               
  else
      
      [dRow,dCol,dRadius,dAngle] = get_fpg_residuals( constraintPoints, fitterArgs, ...
                       parValues, covariance ) ;
      normString = ', normalized to sigma' ;
      angString = ' ' ;
      posString = ' ' ;
      
  end
  
% identify the channel of interest

  iChannel = convert_from_module_output( mod, out ) ;
  
% if the channel was not used, throw an error

  if (isempty(dRow(iChannel).residuals))
      error('  No data useful for plotting in selected module/output') ;
  end
  
% produce the plot

  figure ;
  subplot(2,2,1) 
  hist(dRow(iChannel).residuals) ;
  title(['Row Residuals',normString]) ;
  xlabel(posString) ;
  subplot(2,2,2)
  hist(dCol(iChannel).residuals) ;
  title(['Col Residuals',normString]) ;
  xlabel(posString) ;
  subplot(2,2,3)
  hist(dRadius(iChannel).residuals) ;
  title(['Radius Residuals',normString]) ;
  xlabel(posString) ;
  subplot(2,2,4) 
  hist(dAngle(iChannel).residuals) ;
  title(['Angle Residuals',normString]) ;
  xlabel(angString) ;

  