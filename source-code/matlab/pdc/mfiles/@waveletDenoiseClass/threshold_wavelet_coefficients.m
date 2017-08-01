function obj = threshold_wavelet_coefficients(obj)

% Applies SURE (or uniform) threshold to the wavelet coefficients of the
% *extended* time series
% INPUT
%   waveletCoefficientsExtended -- nCadences x nScales matrix
%   thresholdMethod -- 'sure', 'universal', 'bayes', or 'none'
%   thresholdType -- 'soft', or 'hard'
% OUTPUT
%    thresholds
%    thresholdedWaveletCoefficents (i.e. with thresholds applied)  -- nCadences x nScales matrix
%=========================================================================
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

% set inputs
iSignal = obj.iCurrentSignal;
waveletCoefficientsExtended = obj.waveletDataStruct(iSignal).waveletCoefficientsExtended;
thresholdType = obj.thresholdType;
thresholdMethod = obj.thresholdMethod;
noiseEstimationSubband = obj.noiseEstimationSubband;

% Check that thresholdMethod is 'universal' -- hardwired for now
assert(strcmp(thresholdMethod,'universal'),'threshold_wavelet_coefficients:inputParameters','Input error -- thresholdMethod must be ''universal''!')

% Check that thresholdType is 'hard' -- hardwired for now
assert(strcmp(thresholdType,'hard'),'threshold_wavelet_coefficients:inputParameters','Input error -- thresholdType must be ''hard''!')

% Get the number of scales and the number of cadences
nScales = size(waveletCoefficientsExtended,2);
nCadences = size(waveletCoefficientsExtended,1);

% The Rice University denoising package uses a multiplier of 3.6,
% i.e. threshold is 3.6*sigma for the overcomplete wavelet transform
% and of 3.0*sigma for the DWT. So the multiplier for the overcomplete wavelet
% transform should be set to 3.6/3.0 = 1.2 as a default
sigmaMultiplier = 1.2;

%==========================================================================
% Calculate the universal threshold

% If we are doing MSMAP, variation at the shortest scale is contained in band 3.
% The universal threshold for wavelet denoising depends on the information
% in the shortest scale subband; it is derived and applied when MSMAP processes band 3,
% but must also be available for denoising band 2. If we are processing
% band 2, waveletDenoiseObject needs a way to get the universal threshold
% (uThresh) as an input.
% So we need first of all to reverse the order of the band processing in
% MSMAP, so that it processes bands 3, 2, and 1 instead of 1, 2, and 3.
% That being done (in pdc_green_box_map_proper) we provide waveletDenoiseClass with two logical control inputs
% (1) saveUniversalThreshold
%       -- which (if true) causes a matfile containing the universal threshold uThresh to
%          be saved during band 3 processing, and
% (2) retrieveUniversalThreshold
%       -- which (if true) causes that matfile to be loaded during band 2 processing.

% Set the universal threshold
if(obj.retrieveUniversalThreshold)
    % Retrieve the universal threshold from the file where it has been saved during band 3 processing
    % retrieveUniversalThreshold should be set if and only if this is inside band 2 of msmap
    load('universalThresholdBand3')
else
    % Estimate the sigma of the highest band of wavelet coefficients, via MAD
    shortestScaleWaveletCoefficients = waveletCoefficientsExtended(:,noiseEstimationSubband);
    MAD = median(abs(shortestScaleWaveletCoefficients - median(shortestScaleWaveletCoefficients)));
    
    % Convert MAD to standard deviation
    sigmaHigh = MAD/0.6745;
    
    % Universal threshold
    uThresh = sigmaMultiplier*sigmaHigh*sqrt(2*log(nCadences));
end

% Save uThresh to a file
% saveUniversalTheshold should be set if and only if this is inside band 3 of msmap
if(obj.saveUniversalThreshold)
    save('universalThresholdBand3','uThresh')
end

% Calculate threshold
thresholds = calculate_wavelet_threshold(thresholdMethod,uThresh,nScales);

% Apply thresholds at each scale
obj.thresholds(iSignal).values = thresholds;

for iScale = 1:nScales
    
    % Apply thresholds
    switch thresholdType
        case 'hard'
            % Hard Threshold
            obj.waveletDataStruct(iSignal).thresholdedWaveletCoefficientsExtended(:,iScale) = ...
                waveletCoefficientsExtended(:,iScale).*(abs(waveletCoefficientsExtended(:,iScale)) > thresholds(iScale));
            
        case 'soft'
            % Soft Threshold
            obj.waveletDataStruct(iSignal).thresholdedWaveletCoefficientsExtended(:,iScale) = ...
                sign(waveletCoefficientsExtended(:,iScale)).*(abs(waveletCoefficientsExtended(:,iScale)) - ...
                thresholds(iScale)).*(abs(waveletCoefficientsExtended(:,iScale)) > thresholds(iScale));
            
    end % switch
    
end % loop over scales

end

% Right now only universal threshold is implemented
function thresholds = calculate_wavelet_threshold(thresholdMethod,uThresh,nScales)

if(strcmp(thresholdMethod,'universal'))
    thresholds = repmat(uThresh,1,nScales);
else
    fprintf('Error -- thresholdMethod must be universal!')
end

end
