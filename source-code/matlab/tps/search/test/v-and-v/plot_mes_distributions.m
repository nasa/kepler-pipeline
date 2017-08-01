function plot_mes_distributions( tpsDawgStruct )
%
% plot_mes_distributions -- generate summary plots related to TPS multiple event
% statistics distributions
%
% plot_mes_distributions( tpsDawgStruct ) plots the distributions of multiple event
%     statistics at several pulse durations, several quantiles of the multiple event
%     statistics for all distributions, and the data duty cycle distribution for one pulse
%     duration.
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

%=========================================================================================

% generate the 4 distributions

  pulseWidthHours = [3 6 12 15] ;
  pulseWidthIndex = find( ismember( tpsDawgStruct.pulseDurations, pulseWidthHours ) ) ;
  
  figure ;
  for iPulse = 1:length(pulseWidthIndex) 
      subplot(2,2,iPulse) ;
      
      plot_mes_histo( tpsDawgStruct, pulseWidthIndex(iPulse), ...
          pulseWidthHours(iPulse) ) ;
      
  end

% build the quantile vectors

  valuesMedian = median(tpsDawgStruct.strongestMes) ;
  values90 = quantile(tpsDawgStruct.strongestMes,0.9) ;
  values95 = quantile(tpsDawgStruct.strongestMes,0.95) ;
  valuesMean = mean(tpsDawgStruct.strongestMes) ;
  maxAcrossPulses = max(tpsDawgStruct.strongestMes,[],2) ;
  
  valuesMedian = [valuesMedian median(maxAcrossPulses)] ;
  values90 = [values90 quantile(maxAcrossPulses,.90)] ;
  values95 = [values95 quantile(maxAcrossPulses,.95)] ;
  valuesMean = [valuesMean mean(maxAcrossPulses)] ;
  
  pulseDurations = [tpsDawgStruct.pulseDurations ...
      tpsDawgStruct.pulseDurations(end) + 1] ;
  
% plot

  figure
  plot(pulseDurations, valuesMedian, 'b') ;
  hold on
  plot(pulseDurations, valuesMean, 'r') ;
  plot(pulseDurations, values90, 'g') ;
  plot(pulseDurations, values95, 'k') ;
  
  xLimits = get(gca,'xlim') ;
  plot(xLimits,[7.1 7.1],'m') ;
  title('MES Dist. vs. Transit Duration')
  ylabel('MES') ;
  xlabel('Transit Duration [Hr]') ;
  
  legend('Median','Mean','90%','95%', 'Location','northwest') ;
  hold off
  
% now do the duty cycle distribution

  dutyCycle = tpsDawgStruct.numValidCadences(:,1) ./ ...
      tpsDawgStruct.dataSpanInCadences(:,1) ;
  figure ;
  hist(dutyCycle,100) ;
  dcMedian = median(dutyCycle) ;
  dcMean = mean(dutyCycle) ;
  dcMax = max(dutyCycle) ;
  title({'Duty Cycle after TPS -- 1.5 [hr]' ; ...
      ['Mean = ',num2str(dcMean),'; Median = ',num2str(dcMedian), '; Max = ',num2str(dcMax)]}) ;
  xlabel('Duty Cycle') ;
  ylabel('N') ;
  hold on
  yLimits = get(gca,'ylim') ;
  plot([dcMedian dcMedian],yLimits,'g') ;
  plot([dcMean dcMean],yLimits,'m') ;

return

%=========================================================================================

% subfunction to do the histogram plotting

function plot_mes_histo( tpsDawgStruct, pulseWidthIndex, pulseWidthHours )

% plot limits

  plotMinMes = 2 ; plotMaxMes = 14 ;
  plotPointer = tpsDawgStruct.strongestMes(:,pulseWidthIndex) >= plotMinMes & ...
      tpsDawgStruct.strongestMes(:,pulseWidthIndex) <= plotMaxMes ;
  nPlotted = length(find(plotPointer)) ;
  nTotal = length(plotPointer) ;
  disp(['For pulse duration ', num2str(pulseWidthHours),' hours, distribution includes ', ...
      num2str(nPlotted),' out of ', num2str(nTotal),' targets']) ;
  hist(tpsDawgStruct.strongestMes(plotPointer,pulseWidthIndex),100) ;
  title(['MES Dist. After TPS-Pipeline -- ',num2str(pulseWidthHours),' [hr]']) ;
  set(gca,'xlim',[plotMinMes plotMaxMes]) ;
  yLimits = get(gca,'ylim') ;
  medianMes = median(tpsDawgStruct.strongestMes(:,pulseWidthIndex)) ;
  meanMes   = mean(tpsDawgStruct.strongestMes(:,pulseWidthIndex)) ;
  hold on
  plot([medianMes ; medianMes],yLimits(:),'r') ;
  plot([meanMes ; meanMes],yLimits(:),'m') ;
  plot([7.1 ; 7.1],yLimits(:),'k') ;
  hold off
  
return
  

