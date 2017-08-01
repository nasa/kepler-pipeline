function cdppTimeSeries = compute_actual_cdpp( syntheticNoiseObject, pulseLengthSamples, ...
    windowLength, pulseOffsetSamples )
%
% compute_actual_cdpp -- compute the CDPP for the colored noise of a syntheticNoiseClass
% object
%
% cdppTimeSeries = compute_actual_cdpp( syntheticNoiseObject, pulseLengthSamples, 
%    windowLength ) computes the CDPP of the coloredNoise member of the
%    syntheticNoiseObject for a square pulse of length nSamples.  The windowLength
%    argument specifies the number of samples which is used to compute the variance for
%    each band, and is the same as the variance window length in TPS.  The method performs
%    the actual calculation, which involves computing the circular windowed variance of
%    the colored noise in the wavelet domain and convolving with the wavelet-transformed
%    pulse.
%
% cdppTimeSeries = compute_actual_cdpp( syntheticNoiseObject, pulseLengthSamples, 
%    windowLength, pulseOffsetSamples ) allows calculation of the CDPP in the case where
%    the model transit pulse does not line up in time exactly with the sample boundaries.
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

% optional argument

  if ~exist( 'pulseOffsetSamples', 'var' ) || isempty( pulseOffsetSamples )
      pulseOffsetSamples = 0 ;
  end

% start by computing the actual window length of the window for the highest frequency

  windowLength = windowLength * pulseLengthSamples ;
  
% perform the wavelet transform on the colored noise and on the test pulse

  pulseVector = construct_pulse_vector( syntheticNoiseObject, pulseLengthSamples, ...
      pulseOffsetSamples ) ;
  nBanks = compute_wavelet_filter_bank_length( syntheticNoiseObject ) ;
  nSamples = length( syntheticNoiseObject.whiteGaussianNoise ) ;
  pulseWavelets = overcomplete_wavelet_transform( pulseVector, ...
      syntheticNoiseObject.h0, nBanks ) ;
  
  coloredWavelets = overcomplete_wavelet_transform( syntheticNoiseObject.coloredNoise, ...
      syntheticNoiseObject.h0, nBanks ) ;
  
% set the window length for each band

  windowLength = windowLength * 2.^(0:nBanks) ;
  windowLength = min( windowLength, nSamples ) ;
  
% set the factor-of-2 rescaling for each band

  scaleFactor = 2.^(-1*[1:nBanks nBanks]) ;
  decimationFactor = 2.^([0:nBanks+1]) ;
  
  
  snrVector = zeros( nSamples, 1 ) ;
  
% loop over bands, performing the SNR calculation for each and summing  

  for ii = 1:nBanks+1
      
      bandSigma = moving_circular_mad( coloredWavelets(:,ii), ...
          windowLength(ii) * decimationFactor(ii), decimationFactor(ii), ...
          false, true ) ;
      snrVector = snrVector + scaleFactor(ii) * circfilt( bandSigma.^-2, ...
          flipud( pulseWavelets(:,ii).^2 ) ) ;
      
  end
  
  cdppTimeSeries = 1e6 ./ sqrt(snrVector) ;
  

end

