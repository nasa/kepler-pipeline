function [cadenceTimes, timeSeriesValuesBinAvg] = bin_and_average_time_series_by_cadence_time( ...
    cadenceTimes, timeSeriesValues, cadenceTimes0, binSizeDays, gapIndicators )
%
% bin_and_average_time_series_by_cadence_times -- combine folded time series values into
% bins, and average their values
%
% [cadenceTimesBinned, timeSeriesValuesBinAvg] = bin_and_average_time_series_by_cadence_times(
%    cadenceTimes, timeSeriesValues, cadenceTimes0, binSizeDays ) takes a vector of time
%    series and a vector of cadence times; bins the cadence times into bins of full width
%    binSizeDays, with one bin centered on cadenceTimes0; and returns a time series of
%    values which matches the cadenceTimes and contains the average of all the time series
%    values which fall into the binned cadence times.
%
% [...] = bin_and_average_time_series_by_cadence_times( ..., gapIndicators ) omits from
%    the timeSeriesValuesBinAvg vector any member of timeSeriesValues which is flagged as
%    a gap by gapIndicators.
%
% Version date:  2010-May-05.
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

% if gap indicators is missing or empty, set it to a vector of false

  if ~exist( 'gapIndicators', 'var' ) || isempty( gapIndicators )
      gapIndicators = false( size( timeSeriesValues ) ) ;
  end

% compute the bin edge values -- start by computing time in bins prior to and after the
% cadenceTimes0 value (which we want to have as a bin center)

  earliestTimeDays = cadenceTimes0 - min(cadenceTimes) ; 
  latestTimeDays   = max(cadenceTimes) - cadenceTimes0 ;
  
  earliestEdgeBins = ceil(earliestTimeDays / binSizeDays) + 0.5 ;
  latestEdgeBins   = ceil(latestTimeDays / binSizeDays) + 0.5 ;
  edgeRangeBins = -earliestEdgeBins:latestEdgeBins ;
  edgeRangeDays = edgeRangeBins * binSizeDays + cadenceTimes0 ;
  binCenterDays = edgeRangeDays + binSizeDays / 2 ;
  binCenterDays(end) = [] ;
  nBins = length(binCenterDays) ;
  
% perform the binning of cadence times

  [nCadencesPerBin, binIndex] = histc( cadenceTimes, edgeRangeDays ) ;
  
% eliminate gapped values

  binIndex = binIndex( ~gapIndicators ) ;
  timeSeriesValues = timeSeriesValues( ~gapIndicators ) ;
  timeSeriesValuesBinAvg = zeros( nBins, 1 ) ;
  nValuesPerBin = zeros( size( timeSeriesValuesBinAvg ) ) ;
  
% loop over bins and form the averaged value in each bin.  Note that sum([]) == 0,
% length([]) == 0, but mean([]) == NaN; so we do the mean as sum / length, where if length
% == 0 we use 1 instead of zero to get mean 0 for empty bins.
      
  for iBin = 1:nBins

      valuesIndex = find( binIndex == iBin ) ;
      nValuesPerBin(iBin) = length( valuesIndex ) ;
      timeSeriesValuesBinAvg(iBin) = sum( timeSeriesValues(valuesIndex) ) / max( 1, ...
          nValuesPerBin(iBin) ) ;

  end
  
% construct the returned timestamps

  cadenceTimes = binCenterDays ;
 
% remove zeros from the data, and remove the corresponding cadence times

  cadenceTimes( nValuesPerBin == 0 ) = [] ;
  timeSeriesValuesBinAvg( nValuesPerBin == 0 ) = [] ;

return


      
  