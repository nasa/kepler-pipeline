function [phase, phaseSorted, sortKey, varargout] = fold_time_series_with_odd_even_transits( oddEvenStr, cadenceTimes, mjd0, periodDays, varargin ) 
%
%  This function calculates the phases of cadence times which are closer to the epoch times of the odd or even transits.
%  The input 'oddEvenStr' can be 'odd' or 'even', specifying whether calculated phases are referenced to the epoch times
%  of the odd or even transits. The output phase ranges in (-0.5, 0.5] and only includes the cadences closer to the odd
%  or even transits.
%
%  Inputs: 
%       oddEvenStr:     a string ('odd' or 'even')
%       cadenceTimes:   a vector of cadence times
%       mjd0:           epoch time (in BKJD) of the 1st transit
%       periodDays:     elapsed time (in days) between two neighbouring transits
%       varargin:       input time series, in the same size as 'cadenceTimes'
%
%  Outputs: 
%       phase:          a vector of phases of the cadences closer to the odd or even transit, depending on 'oddEvenStr' 
%       phaseSorted:    phases sorted from lowest to highest
%       sortKey:        ordering vector for the sorted phases, ie, phaseSorted = phase(sortKey)
%       varargout:      output time series at the cadences closer to the odd or even transits, 
%                       sorted via 'sortKey' and in the same size as 'phaseSorted'
%
% Version date:  2013-January-04.
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
%    2013-January-04, JL:
%       Initial release
%
%=========================================================================================

% check whether input cadenceTimes is a vector
if (~isvector( cadenceTimes ) )
    error('foldTimeSeriesWithOddEvenTransits:cadenceTimesNotVector', ...
        'fold_time_series_with_odd_even_transits:  argument cadenceTimes must be a vector');
end

% check dimensions of input time series
if (nargin > 4)
    nVarArg = length(varargin);
    for iTimeSeries = 1:nVarArg
        if ( ~isequal( size(varargin{iTimeSeries}), size(cadenceTimes) ) )
            error('foldTimeSeriesWithOddEvenTransits:timeSeriesInvalidShape', ...
                'fold_time_series_with_odd_even_transits:  all time series must match shape of cadenceTimes');
        end
    end
else
    nVarArg = 0 ;
end

if strcmp(oddEvenStr, 'odd')
    
    % For cadences closer to the odd transits, the phases are in the ranges of [0, 0.5] and
    % (1.5, 2) for an interval of two orbital periods. 
    % The output phase is adjusted to the range of (-0.5, 0.5]
    
    phaseBuf                 = mod( cadenceTimes - mjd0, 2*periodDays ) / periodDays;
    overOneAndHalf           = phaseBuf > 1.5 ;
    phaseBuf(overOneAndHalf) = phaseBuf(overOneAndHalf) - 2;
    
    validIndices = phaseBuf <= 0.5;
    phase        = phaseBuf(validIndices);
    
    % sort the phases
    [phaseSorted, sortKey] = sort( phase );
    
    % sort the other time series
    for iTimeSeries = 1:nVarArg
        timeSeries             = varargin{iTimeSeries} ;
        validTimeSeries        = timeSeries(validIndices);
        varargout{iTimeSeries} = validTimeSeries(sortKey) ;
    end
    
elseif strcmp(oddEvenStr, 'even')
    
    % For cadences closer to the even transits, the phases are in the range of (0.5, 1.5] 
    % for an interval of two orbital periods.
    % The output phase is adjusted to the range of (-0.5, 0.5].
    
    phaseBuf     = mod( cadenceTimes - mjd0, 2*periodDays ) / periodDays;
    
    validIndices = (phaseBuf <= 1.5) & (phaseBuf > 0.5);
    phase        = phaseBuf(validIndices) - 1;
    
    % sort the phases
    [phaseSorted, sortKey] = sort( phase );
    
    % sort the other time series
    for iTimeSeries = 1:nVarArg
        timeSeries = varargin{iTimeSeries} ;
        validTimeSeries = timeSeries(validIndices);
        varargout{iTimeSeries} = validTimeSeries(sortKey) ;
    end

else
    
    error('foldTimeSeriesWithOddEvenTransits:incorrectInput', ...
        'fold_time_series_with_odd_even_transits:  input oddEvenStr should be "odd" or "even"') ;
    
end

return


