function [backwardIndex, forwardIndex] = determine_range_of_asymmetric_peak( ...
    foldedStatisticValues, limitOnExtentOfPeak )
%
% determine_range_of_asymmetric_peak -- locate the range of values which contain a
% potentially asymmetric peak
%
% [backwardIndex, forwardIndex] = determine_range_of_asymmetric_peak( 
%    foldedStatisticValues ) locates the max value in foldedStatisticValues, and searches
%    backwards and forwards to locate the values which are at half-max; the locations of
%    these values in the vector are returned.  In the event that the half-max points are
%    extremely distant, a hard-coded parameter limits the maximum half-width which will be
%    returned.  If there is something pathological about the peak, the location of the
%    absolute peak will be returned for both values.
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

% default to full range

  if ~exist('limitOnExtentOfPeak','var') || isempty( limitOnExtentOfPeak )
      limitOnExtentOfPeak = inf ;
  end

% subtract the minimum so that the distribution goes down to zero value -- note that we
% have to find the minimum value which is nonetheless > 0, now that we can produce MES
% values which are identically zero

  gtZeroIndex = foldedStatisticValues > 0 ;
  minFoldedStatistic = min(foldedStatisticValues(gtZeroIndex)) ;

  if isempty(minFoldedStatistic)
    % input has nothing larger than zero so set min to zero
      minFoldedStatistic = 0;
  end

  foldedStatisticValues = foldedStatisticValues(:) - minFoldedStatistic ;
  
% find the location and value of the maximum -- in the case of identically-equal values,
% pick the last one (this is to fix the nearly-circular EB multi-planet search corner
% case)

  maxIndex = find_last_max_value( foldedStatisticValues ) ;

%  maxValue = max(foldedStatisticValues) ;
%  maxIndexList = find( foldedStatisticValues == maxValue ) ;
%  maxIndex = maxIndexList(end) ;
  maxValue     = foldedStatisticValues( maxIndex ) ;
  halfMaxValue = maxValue/2 ;

% Look forwards and backwards to find the points closest to the peak which bracket the
% half-max;

  forwardIndex = find(foldedStatisticValues(maxIndex:end) < halfMaxValue , 1, 'first') ;
  forwardIndex = forwardIndex - 1 ;

  if(~isempty(forwardIndex))
    % in case the half width sample is found far away, limit the extent 
      forwardIndex = min(forwardIndex, limitOnExtentOfPeak);
      forwardIndex = forwardIndex + maxIndex;
      forwardIndex = forwardIndex(forwardIndex <= length(foldedStatisticValues));
  else
      forwardIndex = maxIndex ;
  end

  backwardIndex = find(foldedStatisticValues(1:maxIndex) < halfMaxValue , 1, 'last') ;

  if(~isempty(backwardIndex))
      backwardIndex = max(backwardIndex, (maxIndex-limitOnExtentOfPeak));
  else
      backwardIndex = maxIndex ;
  end
  
return