function [ses, bestMes, bestPulse] = get_single_event_statistics( ...
    tpsDiagnosticStruct, goodTimeStampsKjd, transitTimesKjd )
%
% get_single_event_statistics -- reconstruct the single event statistics of a transit from
% information in the diagnostic struct and transit timing information
%
% [ses, bestMes, bestPulse] = get_single_event_statistics( tpsDiagnosticStruct,
%     goodTimeStampsKjd, transitTimesKjd ) returns the single event statistics time
%     series, best multiple event statistic, and pulse # of the pulse which produces the
%     best multiple event statistic, given a diagnostic struct, a vector of timestamps,
%     and a vector of transit times.  The timestamps and transit times must be in the same
%     units (JD, KJD, etc), and time stamps which occur on a gap must be set to NaN.
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

%=======================================================================================

% find the NaN values in goodTimeStampsKjd, and replace with interpolated values

  badTimestamps  = find( isnan(goodTimeStampsKjd)) ;
  goodTimestamps = find(~isnan(goodTimeStampsKjd)) ;
  
  goodTimeStampsKjd(badTimestamps) = interp1( goodTimestamps, ...
      goodTimeStampsKjd(goodTimestamps), badTimestamps, 'linear', 'extrap' ) ;
  
% find the transit cadences

  transitCadences = get_transit_cadences( transitTimesKjd, goodTimeStampsKjd ) ;
  
% remove the transits which are on gapped cadences

  transitCadences( ismember(transitCadences,badTimestamps) ) = [] ;
  
% compute the multiple event statistic on each pulse duration, looking for the max value

  mes = zeros(length(tpsDiagnosticStruct),1) ;
  for iPulse = 1:length(tpsDiagnosticStruct)
      mes0 = sum( tpsDiagnosticStruct(iPulse).correlationTimeSeries(transitCadences) ) / ...
          sqrt(sum( tpsDiagnosticStruct(iPulse).normalizationTimeSeries(transitCadences).^2 ) ) ;
      mes(iPulse) = mes0 ;
  end
  [bestMes,bestPulse] = max(mes) ;
  
% compute the single event statistics time series on the pulse with the best MES  
  
  ses = tpsDiagnosticStruct(bestPulse).correlationTimeSeries ./ ...
      tpsDiagnosticStruct(bestPulse).normalizationTimeSeries ;


return

