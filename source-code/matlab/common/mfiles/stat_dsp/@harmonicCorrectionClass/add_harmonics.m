function harmonicsAdded = add_harmonics( obj, centerFrequenciesHz )
%
% add_harmonics -- add to the harmonics which are included in an object of the
% harmonicCorrectionClass, and perform the fit of the harmonics
%
% harmonicsAdded = obj.add_harmonics adds frequencies, if necessary, to the set of
%    frequencies in a harmonicCorrectionClass object, and then performs the simultaneous
%    fit of all frequencies to the flux time series.  If harmonics are added, return
%    variable harmonicsAdded will be true, otherwise it will be false.  The case in which
%    no harmonics are added can occur if there are no longer any harmonics which are
%    sufficiently strong compared to the background, or if the maximum allowed number of
%    harmonics is reached.
%
% harmonicsAdded = obj.add_harmonics( centerFrequenciesHz ) allows the caller to specify a
%    list of frequencies, in Hz, which are to be included as center frequencies in the
%    process of adding frequencies regardless of their SNR.
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

% this only makes sense if the flux is set

  if isempty(obj.originalFluxTimeSeries)
      error('common:harmonicCorrectionClass:originalFluxTimeSeriesNotSet', ...
          'add_harmonics:  original flux time series not set') ;
  end

% default is no harmonics added

  harmonicsAdded = false ;

% extract useful parameters

  falseDetectionProbability = ...
      obj.harmonicIdentificationParameters.falseDetectionProbabilityForTimeSeries ;
  minSeparation = ...
      obj.harmonicIdentificationParameters.minHarmonicSeparationInBins ;
  maxCentralFrequencies = ...
      obj.harmonicIdentificationParameters.maxHarmonicComponents ;
  maxCentralFrequenciesToAdd = maxCentralFrequencies ;
  if ~isempty(obj.fourierComponentStruct)
      maxCentralFrequenciesToAdd = maxCentralFrequencies - ...
          length( unique( [obj.fourierComponentStruct.centerIndex] ) ) ;
  end
  
% determine the chi-square which corresponds to the specified probability that a
% particular spike is a false alarm, given the dimensions of the problem
  
  chiSquareProbabilityForThreshold = ...
      ( 1 -  falseDetectionProbability )^(1/(obj.get_fft_length / 2)) ;
  chiSquareThreshold = chi2inv(chiSquareProbabilityForThreshold,2) ;
  powerThreshold = chiSquareThreshold / chi2inv(0.5,2) ;
  
% get power spectrum and background power spectrum for the current cleaned time series,
% whilst also removing from consideration any protected frequencies and DC

  powerSpectrum    = obj.get_psd( true ) ;
  background       = obj.get_background_psd( true ) ;
  psdFrequenciesHz = obj.get_psd_frequencies ;
  psdPeriodsDays   = 1./psdFrequenciesHz * get_unit_conversion('sec2day') ;
  
% The power threshold for identifying the egdes of a peak can be different from the
% thresholds for identifying the center
  
  powerThresholdEdgeOfPeak = 1.0 ;
  
  snr = powerSpectrum ./ background ;
  maxSnr = max(snr) ;
  
% if there's a user-specified set of central frequencies, set the SNR for the nearest
% frequencies to inf

  if exist( 'centerFrequenciesHz', 'var' ) && ~isempty( centerFrequenciesHz )
      for centerFreq = centerFrequenciesHz(:)'
          [~,centerIndex] = min( abs( centerFreq - psdFrequenciesHz ) ) ;
          snr(centerIndex) = 2*maxSnr ;
      end
  end
  
  snr(obj.protectedIndices) = 0 ;
%  snr(1)                    = 0 ;

% protect the low-frequency "hump" from removal

  humpIndex = find(snr(2:end)<=1,1,'first')+1 ;
%  disp(psdPeriodsDays(humpIndex)) ;
  snr(1:humpIndex) = 0 ;
  
% In some cases, when we remove some frequencies and then re-compute SNR, some frequencies
% which had been low in power will be above the threshold for including in a neighboring
% peak.  Handle these "orphaned" frequencies now

  [obj.fourierComponentStruct, snr, orphansAdded] = capture_orphaned_frequencies( ...
      obj.fourierComponentStruct, snr, psdFrequenciesHz, powerThresholdEdgeOfPeak ) ;
  
  
  if maxCentralFrequenciesToAdd > 0 

%     get harmonic struct information for all new frequencies which lie above the threshold,
%     plus any frequencies which are in the same peak as one of the new ones; note that
%     depending on whether there are frequencies from the caller which we need to capture,
%     we will need to make this call slightly differently

      if exist( 'centerFrequenciesHz','var' ) && ~isempty( centerFrequenciesHz )
          
          newHarmonicStruct = get_new_harmonics( snr, 1.5 * maxSnr, psdFrequenciesHz, ...
              0, powerThresholdEdgeOfPeak ) ;
          
      else

          newHarmonicStruct = get_new_harmonics( snr, powerThreshold, psdFrequenciesHz, ...
              minSeparation, powerThresholdEdgeOfPeak ) ;
  
%         remove any new frequencies which are too close to an existing peak

          newHarmonicStruct = apply_peak_separation( obj.fourierComponentStruct, ...
              newHarmonicStruct, minSeparation ) ;
      
%         remove any frequencies which cause the central frequency count to exceed an
%         acceptable number

          newHarmonicStruct = apply_max_new_frequencies( newHarmonicStruct, ...
              maxCentralFrequenciesToAdd ) ;
          
      end
      
      
  else % ran out of frequencies case (NB issue the warning only once)
      
      warning('Common:addHarmonics:harmonicsLimitReached', ...
          ['add_harmonics: reached harmonics limit;\n' ...
          'stopped looking for more harmonics, returning the results from the last iteration']);
      warning('off','Common:addHarmonics:harmonicsLimitReached') ;
      newHarmonicStruct = [] ;

  end
  
  [obj.fourierComponentStruct, harmonicsAdded] = combine_and_eliminate_duplicates( ...
      obj.fourierComponentStruct, newHarmonicStruct ) ;
  harmonicsAdded = harmonicsAdded || orphansAdded ;
  if harmonicsAdded 
      obj.fit_harmonics ;
  end
  
  
return

%=========================================================================================

% subfunction which returns harmonics structs for any new harmonics which may need to be
% added to the master list of harmonics

function newHarmonicStruct = get_new_harmonics( snr, powerThreshold, psdFrequencies, ...
    minSeparation, powerThresholdEdgeOfPeak )

% initialize newHarmonicStruct to empty

  newHarmonicStruct = [] ;
  
% construct an anonymous function to handle the decision as to whether there are still
% peaks which are of interest to the detector

  still_scanning_check = @(x,y) max(x) >= y ;
    
  stillScanningFrequencies = still_scanning_check( snr, powerThreshold ) ;
  while stillScanningFrequencies

%     sort the harmonics into SNR order, and get a key to their indices

      [~,indicesSorted] = sort(snr,'descend') ;
      
%     identify the start and end of the spike which contains the strongest unfound
%     harmonic, and build an array of harmonic structs, one entry for each frequency in
%     the spike
      
      spikeCenter = indicesSorted(1) ;
      additionalHarmonicsStruct = get_additional_harmonic_struct_array( spikeCenter, snr, ...
          psdFrequencies, powerThresholdEdgeOfPeak ) ;
            
%     any frequency which is in the new struct array should be removed from the list which
%     we are searching

      additionalHarmonicIndices = [additionalHarmonicsStruct.frequencyIndex] ;
      snr(additionalHarmonicIndices) = 0 ;
      
%     any frequency which is too close to a frequency we found on a previous iteration of
%     this loop should be removed from the struct array

      additionalHarmonicsStruct = apply_peak_separation( newHarmonicStruct, ...
          additionalHarmonicsStruct, minSeparation ) ;
      
%     concatenate the new list onto the existing one

      newHarmonicStruct = [newHarmonicStruct ; additionalHarmonicsStruct] ;
      
      stillScanningFrequencies = still_scanning_check( snr, powerThreshold ) ;
      
  end
  
return

%=========================================================================================

% subfunction which finds the extent of a peak and returns an appropriate array of
% harmonic information structs

function additionalHarmonicsStruct = get_additional_harmonic_struct_array( spikeCenter, ...
    snr, psdFrequencies, powerThresholdEdgeOfPeak )

% search upstream from the center to find out where the SNR falls to the power threshold,
% or else go to the first frequency bin; perform a similar search for the end of the peak

  firstFrequencyIndex = find( snr(1:spikeCenter) <= powerThresholdEdgeOfPeak, 1, 'last' ) ;
  if isempty(firstFrequencyIndex)
      firstFrequencyIndex = 1 ;
  else
      firstFrequencyIndex = firstFrequencyIndex + 1 ;
  end
  lastFrequencyIndex = find( snr(spikeCenter+1:end) <= powerThresholdEdgeOfPeak, 1,'first' ) ;
  if isempty(lastFrequencyIndex)
      lastFrequencyIndex = length(snr) ;
  else
      lastFrequencyIndex = lastFrequencyIndex + spikeCenter - 1 ;
  end
  
% build the array

  frequencyIndices = firstFrequencyIndex:lastFrequencyIndex ;
  nFrequencies = length(frequencyIndices) ;
  additionalHarmonicsStruct = harmonicCorrectionClass.get_fourier_component_struct_array( ...
      psdFrequencies(spikeCenter), spikeCenter, nFrequencies ) ;
  
% put in the frequency stuff which needs to be added one at a time

  for iFreq = 1:nFrequencies
      thisIndex = frequencyIndices(iFreq) ;
      additionalHarmonicsStruct(iFreq).frequencyHz = psdFrequencies(thisIndex) ;
      additionalHarmonicsStruct(iFreq).frequencyIndex = thisIndex ;
      additionalHarmonicsStruct(iFreq).periodDays = ...
          1/additionalHarmonicsStruct(iFreq).frequencyHz * ...
          get_unit_conversion('sec2day') ; 
  end
  
return

%=========================================================================================

% subfunction which applies the requirement that new spikes which are added have an
% adequate separation from old ones which have already been accepted 

function newHarmonicStruct = apply_peak_separation( existingHarmonicStruct, ...
    newHarmonicStruct, minSeparation )

% trivial case

  if isempty( existingHarmonicStruct ) || isempty( newHarmonicStruct )
      return 
  end

% get the new and old spike locations

  newCenterIndices = [newHarmonicStruct.centerIndex] ;
  existingCenterIndices = unique( [existingHarmonicStruct.centerIndex] ) ;
  goodNewFrequency = true( size( newCenterIndices ) ) ;
  
% find the ones which are too close and mark them for removal -- this could be done using
% a couple of repmats and such, but since I've already been burned once by an
% out-of-control repmat'ing giving a huge memory spike, I'm going to use a loop to get
% this one

  for iFreq = 1:length(goodNewFrequency)
      
      if any( abs(existingCenterIndices-newCenterIndices(iFreq)) <= minSeparation )
          goodNewFrequency(iFreq) = false ;
      end
      
  end
  
% remove the bad entries from the array and allow it to return

  newHarmonicStruct = newHarmonicStruct(goodNewFrequency) ;
  
% now remove any new frequencies which are duplicates of existing frequencies

  newIndices        = [newHarmonicStruct.frequencyIndex] ;
  existingIndices   = [existingHarmonicStruct.frequencyIndex] ;
  duplicates        = ismember( newIndices, existingIndices ) ;
  newHarmonicStruct = newHarmonicStruct( ~duplicates ) ;
  
return

%=========================================================================================

% subfunction which applies the limit on the # of frequency spikes which are permitted

function newHarmonicStruct = apply_max_new_frequencies( newHarmonicStruct, ...
    maxFrequenciesToAdd )

% trivial case

  if isempty( newHarmonicStruct ) 
      return
  end
  
% get the unique central frequency indices, and most importantly the locations in the new
% harmonic struct where each streak of a given new central index ends

  [~,centralIndexEndLocation] = unique( [newHarmonicStruct.centerIndex] ) ;
  
% since the newHarmonicStruct is always in order from strongest to weakest, we want to
% sort the centralIndexEndLocation, this will give us an ordered list of the last
% frequency for each peak from the strongest peak to the weakest

  centralIndexEndLocation = sort(centralIndexEndLocation) ;
  
% if we have too many, then we want to lop off all the ones past the central index end #
% max frequency; otherwise we want to keep all of them
  
  if maxFrequenciesToAdd < length(centralIndexEndLocation)
      finalFrequency = centralIndexEndLocation(maxFrequenciesToAdd) ;
  else 
      finalFrequency = length(newHarmonicStruct) ; 
  end
  
  newHarmonicStruct = newHarmonicStruct(1:finalFrequency) ;
  
return

%=========================================================================================

% subfunction which identifies and handles frequencies which are "orphaned" from a peak

function [fourierComponentStruct, snr, harmonicsAdded] = capture_orphaned_frequencies( ...
      fourierComponentStruct, snr, psdFrequenciesHz, powerThresholdEdgeOfPeak )
  
  harmonicsAdded = false ;
  
% we only need to do this if fourierComponentStruct isn't empty

  if ~isempty( fourierComponentStruct )
      
%     loop over center frequencies

      uniqueCenterIndices = unique( [fourierComponentStruct.centerIndex] ) ;
      
      newIndices = [] ;
      newCenterIndices = [] ;
      for iCenter = uniqueCenterIndices(:)'
          
%         find all the indices which go with this peak

          indices = [fourierComponentStruct.centerIndex] == iCenter ;
          freqIndices = [fourierComponentStruct(indices).frequencyIndex] ;
          minFreqIndex = min(freqIndices) ;
          maxFreqIndex = max(freqIndices) ;
          
%         find the next-earliest frequency which is below the threshold

          thresholdIndex = find( snr(1:minFreqIndex-1) < powerThresholdEdgeOfPeak, 1, ...
              'last' ) ;
          
%         if the threshold index isn't contiguous with the lowest index in this peak, then
%         we have something to add

          if thresholdIndex ~= minFreqIndex - 1
              brandNewIndices = (thresholdIndex+1):(minFreqIndex-1) ;
              nNew = length(brandNewIndices) ;
              newIndices = [newIndices brandNewIndices] ;
              newCenterIndices = [newCenterIndices repmat(iCenter,1,nNew)] ;
          end
              
%         similar logic applies to the downstream edge

          thresholdIndex = find( snr(maxFreqIndex+1:end) < powerThresholdEdgeOfPeak, 1, ...
              'first' ) ;
          if thresholdIndex ~= 1
              thresholdIndex = thresholdIndex+maxFreqIndex ;
              brandNewIndices = (maxFreqIndex+1):(thresholdIndex-1) ;
              nNew = length(brandNewIndices) ;
              newIndices = [newIndices (maxFreqIndex+1):(thresholdIndex-1)] ;
              newCenterIndices = [newCenterIndices repmat(iCenter,1,nNew)] ;
          end
          
      end % loop over center frequencies
      
%     at this point, if we've found any orphaned frequencies, we need to build a struct
%     array to hold them

      if ~isempty(newIndices)
          orphanedStruct = harmonicCorrectionClass.get_fourier_component_struct_array( ...
              0, 0, length( newIndices ) ) ;
          for iFreq = 1:length(orphanedStruct)
              newIndex = newIndices(iFreq) ;
              newCenterIndex = newCenterIndices(iFreq) ;
              orphanedStruct(iFreq).frequencyHz = psdFrequenciesHz(newIndex) ;
              orphanedStruct(iFreq).frequencyIndex = newIndex ;
              orphanedStruct(iFreq).centerFrequencyHz = psdFrequenciesHz(newCenterIndex) ;
              orphanedStruct(iFreq).centerIndex = newCenterIndex ;
              orphanedStruct(iFreq).periodDays = 1/orphanedStruct(iFreq).frequencyHz * ...
                  get_unit_conversion('sec2day') ;
          end
          
%         concatenate onto the end of the existing array and sort it into frequency order

          fourierComponentStruct = [fourierComponentStruct ; orphanedStruct] ;
          [~,sortOrder] = sort([fourierComponentStruct.frequencyIndex]) ;
          fourierComponentStruct = fourierComponentStruct(sortOrder) ;
          
%         set SNR for the no-longer-orphaned frequencies to zero

          snr(newIndices) = 0 ;
          harmonicsAdded = true ;
          
      end % if statement on whether orphans were found
      
  end % if statement on whether there were pre-existing frequencies
  
return

%=========================================================================================

% subfunction to combine frequencies between two frequency struct arrays, remove any
% duplicates, and determine whether any frequencies were actually added

function [fourierComponentStruct, harmonicsAdded] = combine_and_eliminate_duplicates( ...
              fourierComponentStruct, newHarmonicStruct )
          
% start by eliminating any duplicates in the two structs passed in.  How can there be
% duplicates in these structures?  I don't know.  Don't ask me these questions.  I just
% want to be careful.

  fourierComponentStruct = eliminate_duplicates( fourierComponentStruct ) ;
  newHarmonicStruct      = eliminate_duplicates( newHarmonicStruct ) ;
  
% now combine them and do one additional elimination

  combinedStruct = [fourierComponentStruct ; newHarmonicStruct] ;
  combinedStruct = eliminate_duplicates( combinedStruct ) ;
  
% note whether we've added anything and return -- note that we need to handle the case in
% which the initial struct is empty, and in which both structs are empty

  emptyInitial = isempty(fourierComponentStruct) ;
  emptyFinal   = isempty(combinedStruct) ;
  identicalStructs = emptyInitial && emptyFinal ;
  
% note that if the initial struct is empty and the final is not, identicalStructs is
% false; if they are both empty, then it's true; so we only need to deal with the case of
% two non-empty structs

  if ~emptyInitial && ~emptyFinal
      identicalStructs = isequal( sort([fourierComponentStruct.frequencyIndex]) , ...
          sort([combinedStruct.frequencyIndex]) ) ;
  end
  harmonicsAdded = ~identicalStructs ;
  fourierComponentStruct = combinedStruct ; 
  
return

%=========================================================================================

% subfunction to eliminate duplicate entries in a fourier component struct

function fourierComponentStruct = eliminate_duplicates( fourierComponentStruct )

% get the frequency indices, get pointers to the unique ones, and return only those array
% members

  if ~isempty( fourierComponentStruct )
      frequencyIndices = [fourierComponentStruct.frequencyIndex] ;
      [~,uniquePointer] = unique(frequencyIndices) ;
      fourierComponentStruct = fourierComponentStruct(uniquePointer) ;
  end
  
return