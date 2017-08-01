function combsRestored = restore_combs( obj )
%
% restore_combs -- identify and restore frequency combs to the time series in an object of
% the harmonicCorrectionClass
%
% combsRestored = obj.restore_combs causes the harmonicCorrectionClass object to attempt
%    to identify any frequency combs which have been removed during harmonic correction.
%    If these are identified, they are restored to the time series.  The point of this is
%    that frequency combs typically represent transit signatures, which should not be
%    removed if we can possibly prevent it.  If a comb is identified and restored,
%    combsRestored will be true, otherwise false.
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

% start by grabbing the frequency indices of the centers of each spike which has been
% removed; subtract 1 so that frequencyIndex == 0 represents DC

  frequencyIndices = unique([obj.fourierComponentStruct.centerIndex]) - 1 ;
  
% Get the indices of frequencies which have not yet been removed, the length of that
% vector, and the maximum number of center frequencies in a comb, using each frequency as
% the base frequency of said comb
  
  survivingFrequencyIndices = frequencyIndices ;
  nFrequencies = length( survivingFrequencyIndices ) ;
  expectedCombLength = floor( length(obj.get_psd_frequencies) ./ frequencyIndices ) ;

% build a matrix of indicators for each frequency to show whether it's in a comb, and if
% so which frequency is the base frequency for the comb

  inAComb = logical( eye( nFrequencies ) ) ;
  
% A comb requires at least 3 frequencies which are all multiples of the base frequency; so
% loop over frequencies up to the 3rd to last

  for iFreq = 1:nFrequencies-2
      
      thisIndex = frequencyIndices(iFreq) ;
      
%     the base frequency can be off by 1 from its true value, so we need to look at the
%     comb behavior for the neighboring frequencies as well as the nominal one
      
      thisIndex = repmat([thisIndex-1 thisIndex thisIndex+1],nFrequencies,1) ;
      allFreqs  = repmat(frequencyIndices(:),1,3) ;
      harmonic  = round(allFreqs ./ thisIndex) ;
      offset    = allFreqs - harmonic .* thisIndex ;
      
%     For a frequency to be in a comb with the current one, its index number cannot be
%     more than 1 off from a multiple of the base frequency, and it has to have a harmonic
%     # greater than 1, and the base index cannot be DC or negative
      
      combMember = thisIndex > 0 & harmonic > 1 & abs(offset) <= 1 ;
      
%     figure out which of the 3 base frequencies makes the best comb and preserve its flag
%     values
      
      nCombMembers = sum(combMember) ;
      [~,bestComb] = max(nCombMembers) ;
      inAComb(iFreq+1:end,iFreq) = combMember(iFreq+1:end,bestComb) ;
      
  end
  
% now we start looking for combs -- we need to iteratively locate the best comb and remove
% it, then look for more, because in a true comb there will be multiple solutions (ie, the
% set of 50, 100, 150, 200, 250, 300 is a comb, but so would be 100, 200, 300), and
% because there can be more than one true comb.  Also, factor in the number of spikes
% which were expected vs the number found -- this allows us to somewhat reduce the number
% of times that super-low frequencies are spuriously combined into a real comb

  combSum = sum(inAComb) ;
  while( max(combSum) >= 3 )
      
      combCriterion = combSum.^2 ./ expectedCombLength .* (combSum >= 3) ;
      [~,bestComb] = max(combCriterion) ;
      
%     now we need to make the frequencies in this comb inaccessible to any of the other
%     potential combs, and mark as being not surviving frequencies
      
      inThisComb = inAComb(:,bestComb) ;
      survivingFrequencyIndices(inThisComb') = -1 ;
      inThisComb = repmat(inThisComb,1,nFrequencies) ;
      inAComb = inAComb & ~inThisComb ;
      
      combSum = sum(inAComb) ;
      
  end

% pick out the frequency indices which have been identified as a comb -- remember to
% increment indices by 1 so that they match what's in the component struct

  combCenterIndex = 1+frequencyIndices( ~ismember( frequencyIndices, ...
      survivingFrequencyIndices ) ) ;
  
% find the frequencies which contribute to the comb

  combIndicator = ismember( [obj.fourierComponentStruct.centerIndex], combCenterIndex ) ;
  combMemberIndices = [obj.fourierComponentStruct(combIndicator).frequencyIndex] ;
  
% remove them

  if any( combIndicator )
      obj.fourierComponentStruct(combIndicator) = [] ;
      obj.protectedIndices = [obj.protectedIndices ; combMemberIndices(:)] ;
      combsRestored = true ;
  else
      combsRestored = false ;
  end
  
return

