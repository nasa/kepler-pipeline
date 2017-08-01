function plot_cosmic_ray_metrics( realCRMetrics, detectedCRMetrics )
%
% plot_cosmic_ray_metrics -- plot the real and measured values of the cosmic ray metrics.
%
% plot_cosmic_ray_metrics( realCRMetrics, detectedCRMetrics ) plots the 5 CR metrics (hit
%    rate, energy, energy variance, energy skewness, energy kurtosis) as a function of
%    cadence number.  The real values are plotted in green, the measured values in
%    magenta.
%
% Version date:  2008-December-11.
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

% Pretty simple, all things considered

  subplot(5,1,1)
  cadence = find(realCRMetrics.hitRate.gapIndicators == false) ;
  plot(cadence,realCRMetrics.hitRate.values(cadence),'g') ;
  cadence = find(detectedCRMetrics.hitRate.gapIndicators == false) ;
  hold on
  plot(cadence,detectedCRMetrics.hitRate.values(cadence),'m') ;
  ylabel('Hit Rate') ;
  title('Green == Actual, Magenta == Detected') ;
  
  subplot(5,1,2)
  cadence = find(realCRMetrics.meanEnergy.gapIndicators == false) ;
  plot(cadence,realCRMetrics.meanEnergy.values(cadence),'g') ;
  cadence = find(detectedCRMetrics.meanEnergy.gapIndicators == false) ;
  hold on
  plot(cadence,detectedCRMetrics.meanEnergy.values(cadence),'m') ;
  ylabel('Mean Energy') ;
  
  subplot(5,1,3)
  cadence = find(realCRMetrics.energyVariance.gapIndicators == false) ;
  plot(cadence,realCRMetrics.energyVariance.values(cadence),'g') ;
  cadence = find(detectedCRMetrics.energyVariance.gapIndicators == false) ;
  hold on
  plot(cadence,detectedCRMetrics.energyVariance.values(cadence),'m') ;
  ylabel('Energy Variance') ;
  
  subplot(5,1,4)
  cadence = find(realCRMetrics.energySkewness.gapIndicators == false) ;
  plot(cadence,realCRMetrics.energySkewness.values(cadence),'g') ;
  cadence = find(detectedCRMetrics.energySkewness.gapIndicators == false) ;
  hold on
  plot(cadence,detectedCRMetrics.energySkewness.values(cadence),'m') ;
  ylabel('Energy Skewness') ;
  
  subplot(5,1,5)
  cadence = find(realCRMetrics.energyKurtosis.gapIndicators == false) ;
  plot(cadence,realCRMetrics.energyKurtosis.values(cadence),'g') ;
  cadence = find(detectedCRMetrics.energyKurtosis.gapIndicators == false) ;
  hold on
  plot(cadence,detectedCRMetrics.energyKurtosis.values(cadence),'m') ;
  ylabel('Energy Kurtosis') ;
  xlabel('Cadence') ;
  
return

% and that's it!

%
%
%
