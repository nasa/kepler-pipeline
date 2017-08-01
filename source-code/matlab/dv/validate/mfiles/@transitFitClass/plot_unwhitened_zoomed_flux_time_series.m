function plotHandle = plot_unwhitened_zoomed_flux_time_series( transitFitObject, targetFluxTimeSeries, nTransitsZoom ) 
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function plotHandle = plot_unwhitened_zoomed_flux_time_series( transitFitObject, targetFluxTimeSeries, nTransitsZoom )
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% Plot the flux as a function of time, omitting the gapped or filled cadences, and zoom in on the region containing 
% the last nTransits transits.  
%
% Version date:  2011-February-08.
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

% Modification Date:
%
%    2111-February-08, JL:
%        set plot start time from ungapped transits.
%
%========================================================================================================================

% if zoomFlag is missing or empty, set it

  if ~exist( 'nTransitsZoom', 'var' ) || isempty( nTransitsZoom )
      nTransitsZoom = inf ;
  end

% get the cadences to use

  includedCadences = get_included_excluded_cadences( transitFitObject ) ;
  
% get the fitted transit object

  transitObject = get_fitted_transit_object( transitFitObject ) ;
  cadenceTimes = get( transitObject, 'cadenceTimes' ) ;
  
% get the transit information from the transitObject

  transitObjectVector = get( transitObject, 'transitGeneratorObjectVector' ) ;
  [numExpectedTransits, numActualTransits, transitStruct] = ...
      get_number_of_transits_in_time_series( transitObjectVector(1), cadenceTimes, ~includedCadences, [] ) ;
  
  transitStartTimes = [transitStruct.bkjdTransitStart];
  transitEndTimes   = [transitStruct.bkjdTransitEnd  ];
  gapIndicator      = [transitStruct.gapIndicator    ];
  
  transitStartTimesValid = transitStartTimes(~gapIndicator);
  transitEndTimesValid   = transitEndTimes(~gapIndicator);
  
% if there are at least 6 transits, then the zoom flag will zoom on the last 5; otherwise,
% the plot ignores the zoom flag

  if length( transitStartTimesValid ) > nTransitsZoom
      plotStartTime = mean([transitStartTimesValid(end-nTransitsZoom+1) transitEndTimesValid(end-nTransitsZoom)]);
      plotStartIndex = find( cadenceTimes < plotStartTime, 1, 'last' );
  else 
      plotStartIndex = 1;
  end
  
% now we are ready to do the plot

  includedCadences = includedCadences( plotStartIndex:end ) ;
  cadenceTimes     = cadenceTimes( plotStartIndex:end ) ;
  flux             = targetFluxTimeSeries.values( plotStartIndex:end ) ;
  
  figure 
  plot( cadenceTimes( includedCadences ), flux( includedCadences ), 'bd' ) ;
  xlabel(['BJD - ',num2str(kjd_offset_from_jd)]) ;
  ylabel('Relative Flux') ;
  
  plotHandle = gcf ;
  
return

% and that's it!

%
%
%
