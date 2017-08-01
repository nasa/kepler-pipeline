function cleanedTimeSeries = get_harmonic_free_time_series( obj, scaleHarmonics )
%
% get_harmonic_free_time_series -- return the time series after removing identified
% harmonics
%
% cleanedTimeSeries = obj.get_harmonic_time_series returns the original time series after
%    subtracting off the fitted harmonic values.
%
% cleaned_time_series = obj.get_harmonic_time_series( scaleHarmonics ) returns the time
%    series after first scaling the fitted harmonics such that there is a residual power
%    remaining at each frequency.  The residual power is approximately equal to the
%    broadband noise floor at each frequency.  The default value of scaleHarmonics is
%    false.
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

  if isempty(obj.originalFluxTimeSeries)
      error('common:harmonicCorrectionClass:originalFluxTimeSeriesNotSet', ...
          'get_harmonic_free_time_series:  originalFluxTimeSeries property not set') ;
  end

  if ~exist( 'scaleHarmonics', 'var' ) || isempty( scaleHarmonics )
      scaleHarmonics = false ;
  end
  
% start by simply evaluating the fitted harmonics and removing them

  harmonicTimeSeries = obj.evaluate_harmonics ;
  cleanedTimeSeries  = obj.originalFluxTimeSeries - harmonicTimeSeries ;
  
% if no scaling is needed, then we are done, but otherwise we need to get the PSD of the
% original time series, and the background of the subtracted time series

  if scaleHarmonics && ~isempty(obj.fourierComponentStruct)
            
%     copy the original fourierComponentStruct before we start monkeying with it
      
      localFourierStruct = obj.fourierComponentStruct ;
      fourierIndices     = [localFourierStruct.frequencyIndex] ;
      
%     get the PSD of the original time series ...

      powerSpectrum = obj.get_psd ;
      
%     ... and the noise floor of the cleaned time series

      noiseFloor = obj.get_background_psd( true ) ;
      
%     the SNR of the fitted harmonics is the ratio of the original time series PSD to the
%     cleaned time series noise floor, at the frequencies of interest

      snr = powerSpectrum( fourierIndices ) ./ noiseFloor( fourierIndices ) ;
      
%     the amplitude ratio is the square root of the SNR

      amplitudeRatio = sqrt(snr) ;
      
%     to preserve the correct amplitude in the harmonics, we want to leave in enough
%     harmonics so that in the power domain the power of the remnant equals the power in
%     the noise floor.  To do that, we want to remove the amplitude difference between the
%     actual amplitude and the amplitude which gives the noise floor level of power.  

      removalRatio = (amplitudeRatio-1) ./ amplitudeRatio ;
      removalRatio( removalRatio < 0 ) = 0 ;
      
%     apply the ratios back into the amplitudes

      for iAmplitude = 1:length(obj.fourierComponentStruct)
          obj.fourierComponentStruct(iAmplitude).cosAmplitude = removalRatio(iAmplitude) * ...
              obj.fourierComponentStruct(iAmplitude).cosAmplitude ;
          obj.fourierComponentStruct(iAmplitude).sinAmplitude = removalRatio(iAmplitude) * ...
              obj.fourierComponentStruct(iAmplitude).sinAmplitude ;
      end
      
%     redo the calculation of the harmonic time series and the cleaned time series

      harmonicTimeSeries = obj.evaluate_harmonics ;
      cleanedTimeSeries  = obj.originalFluxTimeSeries - harmonicTimeSeries ;

%     put the original fourier component struct back into the object

      obj.fourierComponentStruct = localFourierStruct ;
      
  end
  
return

