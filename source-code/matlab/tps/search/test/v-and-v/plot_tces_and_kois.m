function [dEpoch, dPeriod] = plot_tces_and_kois( tceStruct, koiStruct, minEpoch, ...
    linePlotPercentile, suppressMultiples, flagZeroOnly )
%
% plot_tces_and_kois -- plot TCEs and overly KOIs
%
% [dEpoch, dPeriod] = plot_tce_and_kois( tceStruct, koiStruct, minEpoch,  
%    linePlotPercentile, suppressMultiples ) plots the epoch (KJD) and period (Days) of
%    each TCE which corresponds by Kepler ID to a KOI, and overlays a plot of the epoch
%    and period of the KOIs which correspond by Kepler ID to a TCE.  The TCEs and KOIs
%    which correspond to a particular star are then connected by solid lines. Epochs of
%    the KOIs are adjusted to fall after the minEpoch; this is done by adding the period
%    of each KOI to its epoch repeatedly until the result is greater than minEpoch.  Solid
%    lines are only drawn for stars for which the TCE and KOI distance is below a
%    user-selected percentile, set by linePlotPercentile; suppressMultiples allows the
%    user to either draw lines from each TCE to each associated KOI, or to draw only the
%    line from each TCE to the nearest KOI.  Setting flagZeroOnly to true
%    does the analysis only for koi's that have a flag of zero (best
%    planetary targets).
%    
%
% Note that in this case, TCE does not imply that the max MES > the threshold in the TPS
%    run, it simply is the TPS result for each target with the max MES, regardless of
%    whether that MES was over or under the TPS threshold.
%
% Version date:  2010-November-12.
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
%    2010-November-12, PT:
%        replaced the algorithm for determining and removing duplicates.
%
%=========================================================================================

% if flagZeroOnly is set to true then exclude everything else from struct

if flagZeroOnly
    flagZero = koiStruct.flag == 0 ;
    koiStruct.keplerId = koiStruct.keplerId( flagZero ) ;
    koiStruct.periodDays = koiStruct.periodDays( flagZero ) ;
    koiStruct.epochKjd = koiStruct.epochKjd( flagZero ) ;
    koiStruct.planetRadiusEarthRadii = koiStruct.planetRadiusEarthRadii( flagZero ) ;
    koiStruct.flag = koiStruct.flag( flagZero ) ;
end

% set a maximum period, since for some strange reason a few of Jason's TCE's have absurdly
% huge periods

  maxKoiPeriodDays = 500 ;
  
% convert the line-plot percentile to a fraction

  linePlotFraction = linePlotPercentile / 100 ;
  
% find the Kepler IDs of KOIs which have periods less than the maximum

  koiKeplerIds = koiStruct.keplerId( koiStruct.periodDays < maxKoiPeriodDays ) ;
  
  disp( [ 'Number of KOIs with period > ', num2str(maxKoiPeriodDays),' days:  ', ...
      num2str( length( koiStruct.keplerId ) - length( koiKeplerIds ) ) ] ) ;

% find the TCEs which correspond to a star on the KOI list and which have a valid TPS
% result

  tcePointer = ismember( tceStruct.keplerId, koiKeplerIds ) & ...
      tceStruct.periodDays > 0 ;
  disp( [ 'Number of TCEs which match KOIs:  ', num2str(length(find(tcePointer))) ] ) ;
  
% plot the TCE epoch and period for those target stars

  figure ;
  plot( tceStruct.epochKjd( tcePointer ), tceStruct.periodDays( tcePointer ), '.' ) ;
  
% get the period and epoch of each KOI which matches one of those target stars

  targetStarKeplerId = tceStruct.keplerId( tcePointer ) ;
  koiPointer = ismember( koiStruct.keplerId, targetStarKeplerId ) ;
  koiKeplerId = koiStruct.keplerId(koiPointer) ;
  koiEpochKjd = koiStruct.epochKjd(koiPointer) ;
  koiPeriodDays = koiStruct.periodDays(koiPointer) ;
  koiRadius = koiStruct.planetRadiusEarthRadii(koiPointer) ;
  
% find the KOIs for which the epoch lies prior to the minEpoch, and add periods until it
% no longer does

  epochLagPeriods = (koiEpochKjd - minEpoch) ./ koiPeriodDays ;
  epochTooEarly = epochLagPeriods < 0 ;
   koiEpochKjd(epochTooEarly) = koiEpochKjd(epochTooEarly) - ...
       floor( epochLagPeriods(epochTooEarly) ) .* koiPeriodDays(epochTooEarly) ;
   
% find the KOIs for which the epoch is > 1 period later than the minEpoch, and subtract
% periods until it is no longer so far away

  epochTooLate = epochLagPeriods > 1 ;
  koiEpochKjd(epochTooLate) = koiEpochKjd(epochTooLate) - ...
      floor( epochLagPeriods(epochTooLate) ) .* koiPeriodDays(epochTooLate) ;
  
  hold on
  plot( koiEpochKjd, koiPeriodDays, 'g.' ) ;
  legend( 'TCE', 'KOI' ) ;
  
% find the distance in epoch-period space between each KOI and its corresponding TCE, and
% also plot a line connecting each KOI to its corresponding TCE

  dEpoch        = zeros( size( koiKeplerId ) ) ;
  dPeriod       = zeros( size( koiKeplerId ) ) ;
  tceEpochKjd   = zeros( size( koiKeplerId ) ) ;
  tcePeriodDays = zeros( size( koiKeplerId ) ) ;
  tceMes        = zeros( size( koiKeplerId ) ) ;
  tceSes        = zeros( size( koiKeplerId ) ) ;
  
  for iPointer = 1:length( koiKeplerId )
      thisKeplerId = koiKeplerId(iPointer) ;
      tcePointer = find( tceStruct.keplerId == thisKeplerId ) ;
      tceEpochKjd(iPointer)   = tceStruct.epochKjd(tcePointer) ;
      tcePeriodDays(iPointer) = tceStruct.periodDays(tcePointer) ;
      tceMes(iPointer) = tceStruct.maxMes(tcePointer) ;
      tceSes(iPointer) = tceStruct.maxSes(tcePointer) ;
      dEpoch(iPointer)  = tceEpochKjd(iPointer) - koiEpochKjd(iPointer) ;
      dPeriod(iPointer) = tcePeriodDays(iPointer) - koiPeriodDays(iPointer) ;
  end

  dTime = sqrt( dEpoch.^2 + dPeriod.^2 ) ;
  
% if multiples are supposed to be suppressed, find the KOI in each multiple which has the
% smallest dTime value and remove all other entries in the TCE and KOI vectors; alas, the
% only way I can think to do this is in a loop

  koiKeplerIdUnique = koiKeplerId ;
  keepValue = true( size( koiKeplerId ) ) ;
  if suppressMultiples
      for iKeplerId = unique(koiKeplerId')
          thisKeplerIdEntries = find( koiKeplerId == iKeplerId ) ;
          if length( thisKeplerIdEntries ) > 1
              [minTime,minTimePointer] = min( dTime( thisKeplerIdEntries ) ) ;

              thisKeplerIdEntries(minTimePointer) = [] ;
              keepValue(thisKeplerIdEntries) = false ;

          end

      end
      
      koiKeplerIdUnique(~keepValue) = [] ;
      tceEpochKjd(~keepValue) = [] ;
      tcePeriodDays(~keepValue) = [] ;
      tceMes(~keepValue) = [] ;
      tceSes(~keepValue) = [] ;
      koiEpochKjd(~keepValue) = [] ;
      koiPeriodDays(~keepValue) = [] ;
      dEpoch(~keepValue) = [] ;
      dPeriod(~keepValue) = [] ;
      dTime(~keepValue) = [] ;
      koiRadius(~keepValue) = [] ;
      
      
  end
  
  [dTimeSorted, sortKey] = sort(dTime) ;
  dTime = dTime(sortKey) ;
  dEpoch = dEpoch(sortKey) ;
  dPeriod = dPeriod(sortKey) ;
  maxIndex = round( length( sortKey ) * linePlotFraction ) ;
  disp( [ num2str( linePlotPercentile ),' percentile corresponds to dTime == ', ...
      num2str( dTimeSorted( maxIndex ) ), ' days' ] ) ;
  disp( [ 'Total of ', num2str( maxIndex ), ' out of ', num2str(length(dTime)), ...
      ' TCE / KOI pairs' ] ) ;
  
  sortKey = sortKey(:)' ;
  for iPointer = sortKey(1:maxIndex)
     plot( [tceEpochKjd(iPointer) koiEpochKjd(iPointer)], ...
         [tcePeriodDays(iPointer) koiPeriodDays(iPointer)], ...
         'm' ) ;
  end
  title('TCE and KOI Epoch vs Period Distribution')
  xlabel('Epoch [KJD]') ;
  ylabel('Period [Days]') ;
  
  figure
  plot(dTime,(1:length(dTime))'/length(dTime),'-o')
  ylabel('Percent Of Targets (%)');
  xlabel('dTime (days)');
  title('Percentage of targets less than dTime')
  
% now plot the KOI period and planet radius for KOIs which have a good match to a TPS
% detection, for KOIs which have only a poor match, and for KOIs which are on a star which
% has a period of -1 (so we see how badly we are being trashed by our inability to
% suppress the events which cause period == -1).
      
  figure ; 
  plot( koiRadius(sortKey(1:maxIndex)), koiPeriodDays(sortKey(1:maxIndex)),'b.' ) ;
  hold on
  if maxIndex < length(sortKey)
      plot(koiRadius(sortKey(maxIndex+1:end)), ...
          koiPeriodDays(sortKey(maxIndex+1:end)),'g.') ;
  end
  tceBadPeriodIndex = find( tceStruct.periodDays <= 0 ) ;
  keplerIdBadPeriod = tceStruct.keplerId( tceBadPeriodIndex ) ;
  koiBadTcePeriodIndex = find( ismember( koiStruct.keplerId, keplerIdBadPeriod ) ) ;
  plot( koiStruct.planetRadiusEarthRadii( koiBadTcePeriodIndex ), ...
      koiStruct.periodDays( koiBadTcePeriodIndex ), 'r.' ) ;
  if maxIndex < length(sortKey)
      legend('Good agreement with TCE','Poor Agreement with TCE', 'TCE Period <= 0') ;
  else
      legend('Good agreement with TCE','TCE Period <= 0') ;
  end
  title('KOI Planet Radius and Orbital Period Distribution') ;
  xlabel('Planet Radius [Earth Radii]') ;
  ylabel('Orbital Period [Days]') ;
  
% now plot the planet radius vs max MES for the good matches

  figure ;
  plot( koiRadius(sortKey(1:maxIndex)),tceMes(sortKey(1:maxIndex)), '.' ) ;
  xlabel( 'KOI Planet Radius [Earth Radii]') ;
  ylabel( 'TPS Multiple Event Statistic [\sigma]' ) ;
  title( 'KOI Planet Radius and TPS Multiple Event Statistic Distribution' ) ;
  
  figure ;
  plot( koiRadius(sortKey(1:maxIndex)), ...
      tceMes(sortKey(1:maxIndex)) ./ tceSes(sortKey(1:maxIndex)), '.' ) ;
  xlabel( 'KOI Planet Radius [Earth Radii]') ;
  ylabel( 'TPS MES / SES Ratio' ) ;
  title( 'KOI Planet Radius and TPS MES / SES Ratio Distribution' ) ;
  
  
return

