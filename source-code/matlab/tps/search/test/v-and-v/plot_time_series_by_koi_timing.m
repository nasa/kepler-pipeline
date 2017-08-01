function plot_time_series_by_koi_timing( tceStruct, koiStruct, koiRadiusEarthRadii, ...
    koiPeriodDays )
%
% plot_time_series_by_koi_timing( tceStruct, koiStruct, koiRadiusEarthRadii, koiPeriodDays
% ) -- look up the requested KOI by finding the one which comes closest to matching the
% requested period and radius, plot the corresponding flux time series.
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

% perform the search

  dR = koiRadiusEarthRadii - koiStruct.planetRadiusEarthRadii ;
  dP = koiPeriodDays - koiStruct.periodDays ;
  
  dd = sqrt(dR.^2 + dP.^2) ;
  [mindd,iMin] = min(dd) ;
  
  keplerId = koiStruct.keplerId(iMin) ;
  radius   = koiStruct.planetRadiusEarthRadii(iMin) ;
  period   = koiStruct.periodDays(iMin) ;
  epoch    = koiStruct.epochKjd(iMin) ;
  
% display the located target

  disp(['Kepler ID ', num2str(keplerId)]) ;  
  disp(['   KOI radius:  ', num2str(radius),' Earth radii']) ;
  disp(['   KOI period:  ', num2str(period),' days']) ;
  disp(['   KOI epoch:    KJD ', num2str(epoch)]) ;

% now look it up in TCE-land

  iTce = find(keplerId == tceStruct.keplerId) ;
  tpsPeriod = tceStruct.periodDays(iTce) ;
  tpsEpoch  = tceStruct.epochKjd(iTce) ;
  tpsMes    = tceStruct.maxMes(iTce) ;
  tpsDir    = [tceStruct.topDir,'/tps-matlab',tceStruct.taskfile{iTce}] ;
  disp(['   TCE period:  ',num2str(tpsPeriod),' days'] ) ;
  disp(['   TCE epoch:   KJD ', num2str(tpsEpoch)]) ;
  disp(['   MES:         ', num2str(tpsMes),' sigmas']) ;
  
% do the plot

  tpsInputs = read_TpsInputs([tpsDir,'/tps-inputs-0.bin']) ;
  load([tpsDir,'/tps-diagnostic-struct.mat']) ;
  
  timeSeries0 = tpsInputs.tpsTargets.fluxValue ;
  timeSeries1 = tpsDiagnosticStruct(1).detrendedFluxTimeSeries ;
  
  gapIndicators = false( size( timeSeries0 ) ) ;
  gapIndicators( tpsInputs.tpsTargets.gapIndices+1) = true ;
  validPoints = find( ~gapIndicators ) ;
  invalidPoints = find( gapIndicators ) ;
  
  validCadenceTimes = find( ~tpsInputs.cadenceTimes.gapIndicators ) ;
  invalidCadenceTimes = find( tpsInputs.cadenceTimes.gapIndicators ) ;

  cadenceTimes = tpsInputs.cadenceTimes.midTimestamps ;
  cadenceTimes( invalidCadenceTimes ) = interp1( validCadenceTimes, ...
      cadenceTimes(validCadenceTimes), invalidCadenceTimes, 'linear', 'extrap' ) ;
  cadenceTimes = cadenceTimes - kjd_offset_from_mjd ;
  
% get the valid and invalid segments

  validSegments   = identify_contiguous_integer_values( validPoints ) ;
  invalidSegments = identify_contiguous_integer_values( invalidPoints ) ;
  
% do some plottin' 

  figure 
  subplot(2,1,1) ; 
  for iSegment = 1:length(validSegments)
      indices = validSegments{iSegment} ;
      plot( cadenceTimes(indices), timeSeries0(indices) ) ;
      hold on
  end
  hold off
  ylabel('Absolute Flux [e^-]') ;
  title( [ 'Kepler ID ', num2str(keplerId) ] ) ;
  
  subplot(2,1,2) ;
  for iSegment = 1:length(validSegments)
      indices = validSegments{iSegment} ;
      plot( cadenceTimes(indices), timeSeries1(indices) ) ;
      hold on
  end
  for iSegment = 1:length(invalidSegments)
      indices = invalidSegments{iSegment} ;
      plot( cadenceTimes(indices), timeSeries1(indices), 'r' ) ;
      hold on
  end
  hold off
  xlabel('Time Since Start of Unit Of Work [Days]') ;
  ylabel('Relative Flux') ;
  
% adjust the horizontal axes

  subplot(2,1,2) ;
  xlimDesired = get( gca, 'xlim' ) ;
  subplot(2,1,1) ;
  set( gca, 'xlim', xlimDesired ) ;
  
% set the size

  set(gcf,'position',[30 300 1300 700]) ;
  
  
return

