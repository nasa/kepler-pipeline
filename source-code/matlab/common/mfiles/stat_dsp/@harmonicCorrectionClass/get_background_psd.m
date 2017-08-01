function noiseFloor = get_background_psd( obj, subtractFittedHarmonics )
%
% get_background_psd -- compute the power spectral density of the background for an object
% of the harmonicCorrectionClass
%
% noiseFloor = obj.get_background_psd returns the noise floor computed by smoothing the
%    PSD of the time series in a harmonicCorrectionClass object across strong spikes.
%
% noiseFloor = obj.get_background_psd( subtractFittedHarmonics ) performs the calculation
%    for the time series with the current set of fitted frequencies subtracted.  The
%    default value of subtractFittedHarmonics is false.
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

% default argument

  if ~exist( 'subtractFittedHarmonics', 'var' ) || isempty( subtractFittedHarmonics )
      subtractFittedHarmonics = false ;
  end
  
% get the power spectral density for the time series

  powerSpectrum = obj.get_psd( subtractFittedHarmonics ) ;
  nPointFft = length(powerSpectrum) ;
  
% get the necessary parameters from the harmonic identification parameters

  medianWindowLength = ...
      obj.harmonicIdentificationParameters.medianWindowLengthForPeriodogramSmoothing ;
  movingAverageWindowLength = ...
      obj.harmonicIdentificationParameters.movingAverageWindowLength ;
  
% extend the PSD to the left and right with the median values at either end of the actual
% PSD
  
  leftExtrapVal = ...
        median(powerSpectrum(1:medianWindowLength));
  rightExtrapVal = ...
        median(powerSpectrum(end-medianWindowLength+1:end));
  padLength = (medianWindowLength - 1) / 2;
  backgroundPsd = [repmat(leftExtrapVal, [padLength, 1]); ...
        powerSpectrum; repmat(rightExtrapVal, [padLength, 1])];

% median filter the power spectrum using the median window length, and then slice out the
% part of it which isn't from the extension process above
    
  backgroundPsd = ...
        medfilt1(backgroundPsd, medianWindowLength) ;
  backgroundPsd = backgroundPsd(padLength+1 : padLength+nPointFft);
  
% apply moving average filter and save valid samples

  leftExtrapVal = median(backgroundPsd(1:movingAverageWindowLength));
  rightExtrapVal = median(backgroundPsd(end-movingAverageWindowLength+1:end));
  padLength = (movingAverageWindowLength - 1) / 2;
  backgroundPsd = [repmat(leftExtrapVal, [padLength, 1]); ...
        backgroundPsd; repmat(rightExtrapVal, [padLength, 1])];                            
  backgroundPsd = conv(backgroundPsd, ...
        ones(movingAverageWindowLength, 1) / movingAverageWindowLength);
  noiseFloor = ...
        backgroundPsd(movingAverageWindowLength : ...
        movingAverageWindowLength+nPointFft-1);

return

