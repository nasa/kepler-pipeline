function cdpp = compute_cdpp_via_fft( syntheticNoiseObject, pulseDuration, nSampleSmooth, ...
    nSampleOffset )
%
% compute_cdpp_via_fft -- estimate the CDPP for a given pulse duration on the light curve
% in a syntheticNoiseClass object via an FFT-related approach
%
% cdpp = compute_cdpp_via_fft( syntheticNoiseObject, pulseDuration ) estimates the CDPP
%     for detection of a pulse of a given duration in samples against the stellar noise of
%     the syntheticNoiseObject.  This estimate is obtained by summing in quadrature the
%     ratio of the FFTs of the pulse signal and the stellar noise.
%
% cdpp = compute_cdpp_via_fft( syntheticNoiseObject, pulseDuration, nSampleSmooth ) allows
%     the user to median-filter the stellar noise.  This is usually necessary because
%     otherwise individual frequencies which have extremely low power due to fluctuations
%     can generate an unrealistically low CDPP.
%
% cdpp = compute_cdpp_via_fft( syntheticNoiseObject, pulseDuration, nSampleSmooth,
%     nSampleOffset ) allows specification of an offset in the pulse boundaries relative
%     to the sample boundaries.
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

% start with the optional arguments

  if ~exist( 'nSampleSmooth', 'var' ) || isempty( nSampleSmooth )
      nSampleSmooth = 1 ;
  end
  if ~exist( 'nSampleOffset', 'var' ) || isempty( nSampleOffset )
      nSampleOffset = 0 ;
  end
  
% get the pulse and FFT it

  pulseVector = construct_pulse_vector( syntheticNoiseObject, pulseDuration, ...
      nSampleOffset ) ;
  pulseVectorFft = abs(fft(pulseVector)) ;
  
% get the FFT of the stellar noise and smooth it

  starFft = abs(fft(syntheticNoiseObject.coloredNoise)) ;
  starFftSmoothed = medfilt1( starFft, nSampleSmooth ) ;
  
% compute the CDPP

  nyquist = length(starFft) / 2 ;
  lowestBin = floor( nSampleSmooth / 2 ) + 1 ;
  
% perform logarithmic extrapolation below the lowest bin

  goodBins = log(lowestBin+1:nyquist) ;
  badBins  = log(1:lowestBin) ;
  logPower = log(starFftSmoothed) ;
  
  starFftSmoothed(1:lowestBin) = exp( interp1( goodBins, logPower(lowestBin+1:nyquist), ...
      badBins, 'linear', 'extrap' ) ) ;
  
  cdpp = 1e6 / sqrt( sum( (pulseVectorFft(2:nyquist) ...
      ./ starFftSmoothed(2:nyquist)).^2 ) ) ;


return

