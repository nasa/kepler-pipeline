function plotHandle = plot_fit_robust_weights( transitFitObject, nTransitsZoom )
%
% plot_fit_robust_weights -- plot the robust weights assigned during fitting
%
% plotHandle = plot_fit_robust_weights( transitFitObject ) produces a figure with 3
%    subplots.  The top plot shows the weights as a time series, the middle plot shows the
%    weights folded according to the fitted transit timing parameters, and the third plot
%    is a zoom of the second considering only the area around the transit.
%
% Version date:  2010-May-06.
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

% get the fitted transit object

  transitObject = get_fitted_transit_object( transitFitObject ) ;
  cadenceTimes = get( transitObject, 'cadenceTimes' ) ;
  planetModel = get( transitObject, 'planetModel' ) ;
  planetModel = planetModel(1) ;
  cadenceDurationDays = get( transitObject, 'cadenceDurationDays' ) ;
  transitEpochBkjd = planetModel.transitEpochBkjd ;
  orbitalPeriodDays = planetModel.orbitalPeriodDays ;
  transitDurationHours = planetModel.transitDurationHours ;
  transitDurationDays = transitDurationHours * get_unit_conversion('hour2day') ;

  robustWeights = transitFitObject.robustWeights ;
  
% first plot:  straight robust weights time series

  figure ;
  set(gcf,'units', 'pixels', 'position', [10 60 950 560]')
  subplot(3,1,1) ;
  plot( cadenceTimes, robustWeights, 'bo', 'markersize', 4 ) ;
  title( 'Robust Weights' ) ;
  ylabel( 'Weights' ) ;
  xlabel( ['BJD - ', num2str( kjd_offset_from_jd )] ) ;
  
% second plot:  folded robust weights time series

  [phase, phaseSorted, sortKey, robustWeights] = fold_time_series( cadenceTimes, ...
      transitEpochBkjd, orbitalPeriodDays, robustWeights ) ;
  phaseDays = phaseSorted * orbitalPeriodDays ;
  
  subplot(3,1,2) ;
  plot( phaseDays, robustWeights, 'bo', 'markersize', 4 ) ;
  title( 'Folded Robust Weights' ) ;
  ylabel( 'Weights' ) ;
  xlabel( 'Phase [Days]' ) ;
  
% third plot:  same as 2nd plot but also zoomed

  subplot(3,1,3) ;
  plot( phaseDays, robustWeights, 'bo', 'markersize', 4 ) ;
  xlim = max( abs( get( gca, 'xlim' ) ) ) ;
  set( gca, 'xlim', min( xlim, nTransitsZoom/2 * transitDurationDays ) * [-1 1] ) ;
  title( 'Folded Zoomed Robust Weights' ) ;
  ylabel('Weights') ;
  xlabel( 'Phase [Days]' ) ;

  plotHandle = gcf ;
  
return

% and that's it!

%
%
%


