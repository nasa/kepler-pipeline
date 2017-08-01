function [phase, phaseSorted, sortKey, varargout] = fold_time_series( cadenceTimes, mjd0, ...
    periodDays, varargin ) 
%
% fold_time_series -- general purpose time-series folding tool
%
% phase = fold_time_series( cadenceTimes, mjd0, periodDays ) takes a vector of cadence
%    times, a central cadence time, and a period, and converts the cadence times to
%    phases, where phase is in [-0.5,0.5], the phase of mjd0 == 0, and the phase of mjd0 +
%    periodDays/2 == 0.5.
%
% [phase, phaseSorted] = fold_time_series( ... ) also returns a vector of phases sorted
%    from lowest to highest.
%
% [phase, phaseSorted, sortKey] = fold_time_series( ... ) returns the ordering vector for
%    the sorted phases, ie, phaseSorted = phase(sortKey).
%
% [..., sortedVector1, sortedVector2, ...] = fold_time_series( ..., vector1, vector2, ...
%    ) takes an arbitrary number of vectors and returns them sorted via the sortKey.  The
%    vectors must have the same dimension as cadenceTimes.
%
% Version date:  2009-August-05.
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

% check dimensions

  if (~isvector( cadenceTimes ) )
      error('foldTimeSeries:cadenceTimesNotVector', ...
          'fold_time_series:  argument cadenceTimes must be a vector') ;
  end
  
  if (nargin > 3)
      nVarArg = length(varargin) ;
      for iTimeSeries = 1:nVarArg
          if ( ~isequal( size(varargin{iTimeSeries}), size(cadenceTimes) ) )
              error('foldTimeSeries:timeSeriesInvalidShape', ...
                  'fold_time_series:  all time series must match shape of cadenceTimes') ;
          end
      end
  else
      nVarArg = 0 ;
  end
  
% convert cadence times to phase

  phase = mod( cadenceTimes - mjd0, periodDays ) / periodDays ;
  overOneHalf = phase > 0.5 ;
  phase(overOneHalf) = phase(overOneHalf) - 1 ;
  
% sort the phases

  [phaseSorted, sortKey] = sort( phase ) ;
  
% sort the other time series

  for iTimeSeries = 1:nVarArg
      timeSeries = varargin{iTimeSeries} ;
      varargout{iTimeSeries} = timeSeries(sortKey) ;
  end
  
return

% and that's it!

%
%
%
