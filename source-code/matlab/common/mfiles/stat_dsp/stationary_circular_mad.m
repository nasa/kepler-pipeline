function madValues = stationary_circular_mad( timeSeries, nAverage, decimationFactor, ...
    cadencesToEstimate, subtractMedianFlag, scaleToStdFlag )
% stationary_circular_mad -- perform a circular MAD calculation on a time series
%                            for a subset of it's points
%
% madValues = stationaryCircularMad( timeSeries, nAverage, decimationFactor, 
%    cadencesToEstimate ) performs a stationary circular MAD calculation on timeSeries, 
%    with a window size of nAverage samples, decimating the original time series by 
%    a factor of decimationFactor.  The value of decimationFactor must be integer-valued. 
%    When decimationFactor > 1, the time series is decimated so that only 1 sample 
%    every decimationFactor samples is used. The decimation is done in a such a way 
%    that the samples of interest specified in cadencesToEstimate are
%    never decimated away.
%
% madValues = stationary_circular_mad( ... , subtractMedianFlag ) determines whether the
%    calculation of madValues assumes that the median is zero.  When subtractMedianValue
%    is true, the median is calculated and subtracted off prior to the MAD
%    calculation. Default is subtractMedianValue == true.
%
% madValues = moving_circular_mad( ..., subtractMedianFlag, scaleToStd ) scales the
%    resulting MAD values to equivalent standard deviations of a normal distribution when
%    scaleToStd is true.  Default is scaleToStd == false.
%
%
% Version date:  2012-Dec-4.
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

% check input requirements

  if floor( decimationFactor ) ~= decimationFactor
      error( 'common:stationary_circular_mad:decimationFactorNotIntegerValued', ...
          'stationary_circular_mad:  decimationFactor not integer-valued' ) ;
  end
  
  if nAverage <= 0 || floor( nAverage ) ~= nAverage
      error( 'common:stationary_circular_mad:nAverageNotPositiveIntegerValued', ...
          'stationary_circular_mad:  nAverage must have a positive integer value' ) ;
  end
  
   if (~exist( 'cadencesToEstimate', 'var' ) || isempty( cadencesToEstimate ))
       error( 'common:stationary_circular_mad:noCadencesSpecified', ...
           'stationary_circular_mad: Must specify cadences to compute whitening coeffs for' ) ;
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
  
  % allocate output vector
  madValues = zeros( length(cadencesToEstimate), 1 ) ;
  
  nAverageDecimated = round( nAverage / decimationFactor ) ;
 
% if nAverageDecimated is as long as the time series (or longer!), we don't need to do all
% the gymnastics below, we can return MAD of the time series for each slot

  if nAverageDecimated < length( 1:decimationFactor:length(timeSeries) )
      
          startCadences = cadencesToEstimate - floor( (cadencesToEstimate-1)/decimationFactor ) * decimationFactor ; % integer in [1,decimationFactor]
          
          % shift the start cadence of the decimation to ensure the cadence
          % doesnt get decimated away
          for iStart = 1:decimationFactor
              decimateIndicator = ismember(startCadences, iStart) ;
              if any(decimateIndicator)
                  
                  % form the decimated time series
                  indicesToKeep     = iStart:decimationFactor:length(timeSeries) ;
                  decimatedTimeSeriesTemp = timeSeries( indicesToKeep ) ;
                  nSamples            = length( decimatedTimeSeriesTemp ) ;
                  
                  % do the circular extension
                  decimatedTimeSeries = [ decimatedTimeSeriesTemp(nSamples-nAverageDecimated+1:nSamples) ; ...
                      decimatedTimeSeriesTemp ; decimatedTimeSeriesTemp(1:nAverageDecimated) ] ;
                  
                  % convert indices to decimated indices
                  indicesOrig = cadencesToEstimate(decimateIndicator) ;
                  indicesConverted = floor( (indicesOrig - 1)/decimationFactor ) + nAverageDecimated + 1 ;
                  
                  % form an array of cadences to compute the MAD's with
                  valuesArray = zeros(nAverageDecimated, sum(decimateIndicator) ) ;
                  if isequal(mod(nAverageDecimated,2),0)
                      % n is even
                      for iArray = 1:sum(decimateIndicator)
                          iIndex = indicesConverted(iArray) ;
                          iRange = (iIndex - nAverageDecimated/2):(iIndex + nAverageDecimated/2 - 1) ;
                          valuesArray(:,iArray) = decimatedTimeSeries( iRange ) ;
                      end
                  else
                      % n is odd
                      for iArray = 1:sum(decimateIndicator)
                          iIndex = indicesConverted(iArray) ;
                          iRange = (iIndex - floor(nAverageDecimated/2)):(iIndex + floor(nAverageDecimated/2) ) ;
                          valuesArray(:,iArray) = decimatedTimeSeries( iRange ) ;
                      end                    
                  end
                  
                  % compute MAD's
                  if subtractMedianFlag
                      medianValue = median(valuesArray,2) ;
                  else
                      medianValue = zeros( 1, sum(decimateIndicator) ) ;
                  end
                  madValues(decimateIndicator) = median( abs( bsxfun(@minus,valuesArray,medianValue) ), 1 );
              end
              
          end
      
  else
      
      if subtractMedianFlag
          medianValue = median( timeSeries ) ;
      else
          medianValue = 0 ;
      end
      
      madValue = median( abs( timeSeries - medianValue ) )  ;
      madValues = repmat( madValue, size(madValues) ) ;
      
  end
  
% scale values if necessary

  if scaleToStdFlag
      madValues = madValues / 0.6745 ;
  end
  
% 
return