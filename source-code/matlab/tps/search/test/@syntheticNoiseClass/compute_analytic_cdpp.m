function cdppTimeSeries = compute_analytic_cdpp( syntheticNoiseObject, ...
    pulseLengthSamples, pulseOffsetSamples )
%
% compute_analytic_cdpp -- perform quasi-analytic calculation of SNR and CDPP given a
% syntheticNoiseClass object and a desire pulse length in samples
%
% cdppTimeSeries = compute_analytic_cdpp( syntheticNoiseObject, pulseLengthSamples )
%     performs a calculation of the SNR time series via Eqn 12 of Jenkins' 2002 paper on
%     TPS.  The pulse vector is wavelet-transformed, but the in-band variance of each
%     channel is assumed to be given by the product of the RMS of the in-band variance of
%     the original white noise vector and the in-band variance scaling function of the
%     syntheticNoiseClass object.  
%
% cdppTimeSeries = compute_analytic_cdpp( syntheticNoiseObject, pulseLengthSamples, 
%     pulseOffsetSamples ) introduces an offset of pulseOffsetSamples, useful for
%     obtaining the CDPP for a pulse which is delayed by a fraction of a sample.
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

% optional last argument

  if ~exist( 'pulseOffsetSamples', 'var' ) || isempty( pulseOffsetSamples )
      pulseOffsetSamples = 0 ;
  end

% start by getting the interpolated spectrum array, which defines the overall scaling of
% the wavelet bands

  interpolatedSpectrumArray = interpolate_spectrum_array( syntheticNoiseObject ) ;
  
% since this array has low frequencies in the leftmost columns, but the wavelet
% decomposition has the opposite convention, flip the array now

  interpolatedSpectrumArray = fliplr( interpolatedSpectrumArray ) ;
  nBanks = compute_wavelet_filter_bank_length( syntheticNoiseObject ) ;
  nSamples = length( syntheticNoiseObject.whiteGaussianNoise ) ;
  
% perform the wavelet transformation of the white noise

  whiteNoiseWavelets = overcomplete_wavelet_transform( ...
      syntheticNoiseObject.whiteGaussianNoise, syntheticNoiseObject.h0, nBanks ) ;
  
% perform the same transformation on the pulse vector

  pulseVector = construct_pulse_vector( syntheticNoiseObject, pulseLengthSamples, ...
      pulseOffsetSamples ) ;
  pulseWavelets = overcomplete_wavelet_transform( pulseVector, ...
      syntheticNoiseObject.h0, nBanks ) ;
  
% compute the RMS of each of the white noise wavelets, and apply to the spectrum

  whiteNoiseWaveletRms = std( whiteNoiseWavelets ) ;
  channelVariance = interpolatedSpectrumArray .* repmat( whiteNoiseWaveletRms, ...
      nSamples, 1 ) ;
  
% perform the computation described in Jenkins 2002

  snrVector = zeros(nSamples,1) ;
  for ii = 1:nBanks+1
      
      bankScaleFactor = 2^-min(ii,nBanks) ;
      snrContribution = bankScaleFactor * circfilt( channelVariance(:,ii).^-2, ...
          flipud( pulseWavelets(:,ii).^2 ) ) ;
      snrVector = snrVector + snrContribution ;      
      
  end
  
  cdppTimeSeries = 1e6./sqrt(snrVector) ;

return

