function [madValues] = moving_circular_mad( timeSeries, nAverage, decimationFactor, ...
    subtractMedianFlag, scaleToStdFlag )
% moving_circular_mad -- perform a moving circular MAD calculation on a time series
%
% madValues = movingCircularMad( timeSeries, nAverage, decimationFactor ) performs a 
%    moving circular MAD calculation on timeSeries, with a window size of nAverage
%    samples, decimating the original time series by a factor of decimationFactor.  The
%    value of decimationFactor must be integer-valued. When decimationFactor > 1, the time
%    series is decimated so that only 1 sample every decimationFactor samples is used; the
%    MAD is then computed for the decimated samples by interpolation.
%
% madValues = moving_circular_mad( ... , subtractMedianFlag ) determines whether the
%    calculation of madValues assumes that the median is zero.  When subtractMedianValue
%    is true, the calculation is
%
%       madValues(i) = median( abs(timeSeries(i-nAverage/2:i+nAverage/2)) - ...
%                           median(timeSeries(i-nAverage/2:i+nAverage/2))   )
%
%    while for subtractMedianValue == false, the calculation is
%
%       madValues(i) = median( abs(timeSeries(i-nAverage/2:i+nAverage/2)) ) .
%
%    Default is subtractMedianValue == true.
%
% madValues = moving_circular_mad( ..., subtractMedianFlag, scaleToStd ) scales the
%    resulting MAD values to equivalent standard deviations of a normal distribution when
%    scaleToStd is true.  Default is scaleToStd == false.
%
% Version date:  2010-October-20.
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

% SET CONSTANT FOR NOW TO PREVENT LARGE MEMORY SPIKES
MEDFILT1_BLKSZ_LIMIT = 9000;

% check input requirements

  if floor( decimationFactor ) ~= decimationFactor
      error( 'common:moving_circular_mad:decimationFactorNotIntegerValued', ...
          'moving_circular_mad:  decimationFactor not integer-valued' ) ;
  end
  if nAverage <= 0 || floor( nAverage ) ~= nAverage
      error( 'common:moving_circular_mad:nAverageNotPositiveIntegerValued', ...
          'moving_circular_mad:  nAverage must have a positive integer value' ) ;
  end
  
% set default if necessary

  if ~exist( 'subtractMedianFlag', 'var' ) || isempty( subtractMedianFlag )
      subtractMedianFlag = true ;
  end
  if ~exist( 'scaleToStdFlag', 'var' ) || isempty( scaleToStdFlag )
      scaleToStdFlag = false ;
  end
  if decimationFactor < 1
      decimationFactor = 1 ;
  end
  
% construct the return vector

  madValues = zeros( size( timeSeries ) ) ;
  
% form a decimated time series, based on the decimation factor; while we're at it,
% determine the indices which will need to be interpolated, and the indices which will be
% used to perform the interpolation.  Note that when the time series is decimated, the
% number of samples per window must be reduced by the same factor so that the window in
% the decimated regime covers the same number of undecimated samples.

  indicesToKeep     = 1:decimationFactor:length(timeSeries) ;
  indicesToDecimate = setdiff( 1:length(timeSeries), indicesToKeep ) ;
  nAverageDecimated = round( nAverage / decimationFactor ) ;
  
  decimatedTimeSeries = timeSeries( indicesToKeep ) ;
  nSamples            = length( decimatedTimeSeries ) ;
  
% if nAverageDecimated is as long as the time series (or longer!), we don't need to do all
% the gymnastics below, we can return MAD of the time series for each slot

  if nAverageDecimated < nSamples
      
%     limit median filter order and blksz to prevent large memory spikes

      if nAverageDecimated > MEDFILT1_BLKSZ_LIMIT
          warning('Common:movingCircularMad:medfilt1BlkszLimitReached', ...
              'movingCircularMad: medfilt1 filter order and blksz reduced from %d to %d cadences ... ', ...
              nAverageDecimated, MEDFILT1_BLKSZ_LIMIT);
          nAverageDecimated = MEDFILT1_BLKSZ_LIMIT;
      end % if
  
%     perform circular extension of the decimated time series

      decimatedTimeSeries = [ decimatedTimeSeries(nSamples-nAverageDecimated+1:nSamples) ; ...
                              decimatedTimeSeries ; ...
                              decimatedTimeSeries(1:nAverageDecimated) ] ;
      nSamplesCirc        = length( decimatedTimeSeries ) ;
                      
%     if median subtracted is desired, compute the median; otherwise, set equal to zero

      if subtractMedianFlag
          medianValue = median_filter( decimatedTimeSeries, nAverageDecimated ) ;
      else
          medianValue = zeros( size( decimatedTimeSeries ) ) ;
      end
  
%     perform the MAD calculation on the decimated time series; use blksz =
%     nAverageDecimated to minimize memory usage; it has been observed in
%     calls from DV that huge memory spikes result if the blksz is not
%     specified; the run time for Q1-Q6 is not substantially impacted with
%     the specified blksz
      
      madValueDecimated = median_filter( abs( decimatedTimeSeries - medianValue ), ...
          nAverageDecimated ) ;
  
%     truncate the circular extension

      madValueDecimated = ...
          madValueDecimated( nAverageDecimated+1:nSamplesCirc-nAverageDecimated ) ;
  
%     fill the return vector

      madValues( indicesToKeep ) = madValueDecimated ;
      if (decimationFactor == 1)
          madValues( indicesToDecimate ) = interp1( indicesToKeep , madValueDecimated , ...
              indicesToDecimate, 'pchip') ;          
      else
          madValues( indicesToDecimate ) = interp1( [indicesToKeep length(timeSeries)], [madValueDecimated;madValueDecimated(1)], ...
              indicesToDecimate, 'pchip') ;
      end
      
  else
      
      if subtractMedianFlag
          medianValue = median( timeSeries ) ;
      else
          medianValue = 0 ;
      end
      
      madValue = median( abs( timeSeries - medianValue ) )  ;
      madValues = repmat( madValue, size( timeSeries ) ) ;
      
  end
  
% scale values if necessary

  if scaleToStdFlag
      madValues = madValues / 0.6745 ;
  end
  
% 
return

