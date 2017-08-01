function [corrComponents, normComponents, xComponents, nBands] = apply_wavelet_matched_filter_chisquare(fluxTimeSeries, ...
    h0, transitPulse, varianceWindowLength, mScale, whiteningCoefficientsIn )
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [correlationTimeSeries,normalizationTimeSeries] =
% WaveletMatchedFilter(fluxTimeSeries,h0,transitPulse,varianceWindowLength)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Description: This function returns the wavelet expansion of the input signal
%
% Input:
%     1. fluxTimeSeries: stellar flux with possible planetary transit
%        signature
%     2. h0: scaling filter coefficients (an example: Daubechies 12 tap)
%     3. transitPulse: trial transit pulse (an example: 3 hour rectangular
%        pulse represented as -ones(6,1), where the cadence duration is ~30
%        minutes)
%     4. varianceWindowLength: length of the window over which variance
%        estimation is carried out in the wavelet domain
%     5. mScale: number of stages in filter bank (optional)
%     6. currentTransitModelCurve - additional timeseries (current transit
%        model fit) to be whitened for iterative model fit (optional)
%     7. whiteningCoefficientsIn - set of precomputed whitening coefficients 
%        for each band (including DC).  These are used instead of
%        computed coefficients whenever present.  (optional)  
%
% Output:
%      1. correlationTimeSeries (see the references listed below):
%         measures the correlation between the flux time series and the
%         transit pulse at every cadence in the wavelet domain
%      2. normalizationTimeSeries (see the references listed below):
%         measures the noise power over a moving window of length
%         'varianceWindowLength' at every cadence in the wavelet domain
%      3. whitenedTimeSeries - 2-d array containing the whitened versions
%         of the flux time series, traial transit pulse, and current model
%         transit pulse (if present in inputs); whitenedTimeSeries(:,1) 
%         is the whitened flux time series, (:,2) is the transit pulse,
%         (:,3) is the whitened current model transit curve.
%      4. whiteningCoefficientsOut - whitening coefficients at each band -
%         dimensions [nLength, mScale] (DC band included)
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

%
% Comments:
%     This function (qwavsearch.m)is part of the transitgame.m matlab
%     software written by Jon Jenkins that demonstrated the effectiveness
%     of wavelet based matched filter based detection algorithm in
%     extracting transit signatures buried in the DIARAD/SOHO solar
%     irradiance measurements corrupted by instrumental and shot noise. It
%     combines overcomplete wavelet transform and matched filter detection
%     and forms the expected detection statistics in the same function to
%     conserve memory.
%
% References:
%  [1]. J. Jenkins, Algorithm Theoretical Basis Document for the Science
%       Operations Center, KSOC-21008-001, July 2004.
%  [2]. KADN-26063 Combined Differential Photometric Precision (CDPP)
%       Calculation
%  [3]. KADN-26062 Matched Filter
%  [4]. KADN-26061 Wavelet Transform
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

if ~exist('varianceWindowLength', 'var') || isempty( varianceWindowLength )
    varianceWindowLength = 30*length(transitPulse);
end

nCadences = length(fluxTimeSeries);
powerOfTwoLength = log2(nCadences);

if(floor(powerOfTwoLength) ~= ceil(powerOfTwoLength))
    error('TPS:applyWaveletMatchedFilter:notPowerOf2Length', ...
        'apply_wavelet_matched_filter: Input flux time series is not a power of 2 length time series... ');
end

% truncate the length to a power of 2 for fft
nLength = 2^powerOfTwoLength;

% duration of transit
mTransitLength = length(transitPulse);

% scaling (low pass filter) filter length
nFilterLength = length(h0);

if(~exist('mScale', 'var') || isempty(mScale)) 
    % find out how many stages of filtering to do
    % for any signal that is band limited, there will be an upper scale j = m,
    % above which the wavelet coefficients are negligibly small
    % also number of samples should be > filter length
    mScale = log2(nLength) - floor(log2(nFilterLength))+1;
    
end


originalTimeSeries = zeros( nLength, 2 ) ;
originalTimeSeries(:,1) = fluxTimeSeries ;
originalTimeSeries(1:length(transitPulse),2) = transitPulse ;

% perform the OWT on the flux time series, the model transit pulse, and if present the 
% current transit model curve.  Note that for some reason this algorithm truncates the OWT
% 1 band early and goes to base-band at that point.

owtTimeSeries = overcomplete_wavelet_transform( originalTimeSeries, h0, mScale-1 ) ;

% unpack

whitenedFluxTimeSeries = owtTimeSeries(:,:,1) ;
whitenedTransit        = owtTimeSeries(:,:,2) ;
  
% here I want to decouple the # of bands from mScale, so that in the code above we can
% change the way we use mScale and down here it will still do the right thing
  
nBands = size(whitenedFluxTimeSeries,2) ; 

if exist('whiteningCoefficientsIn','var')
    if isequal(size(whiteningCoefficientsIn),[nLength,nBands])
        haveWhiteningCoefficients = true;
    else
        warning('TPS:applyWaveletMatchedFilter', ...
        ['apply_wavelet_matched_filter: Input whitening coefficients have incorrect dimension;' ...
        'computing whitening coefficients from the input fluxTimeSeries']);
        haveWhiteningCoefficients = false;
    end
else
    haveWhiteningCoefficients = false;
end

k = varianceWindowLength;

corrComponents = zeros(nLength, nBands);
normComponents = zeros(nLength, nBands);
xComponents = zeros(nLength, nBands);

for i = 1:nBands
    
    % 2*varianceWindowLength+1 is the length of the variance estimation window
    k = min(k*2,nLength);
    
    % Compute the variance in this frequency band using a robust (moving-MAD) estimator
    % and rescaling to the equivalent RMS value.  Note that the value is then raised to
    % the -2 power, so we are computing the inverse square variance from the outset
    if ~haveWhiteningCoefficients
        % if i need the whitening coefficients for outputting or if I dont
        % have any coefficients that were input, then compute them
        decimationFactor= 2^(i-1);
        subtractMedianFlag = false ;
        scaleToStdFlag = true ;
        inverseWstd2 = moving_circular_mad(whitenedFluxTimeSeries(:,i),...
            varianceWindowLength*decimationFactor, ...
            decimationFactor, subtractMedianFlag, scaleToStdFlag).^(-2) ;
    else
        % the whitening coefficients were input, so use them instead
        inverseWstd2 = whiteningCoefficientsIn(:,i);
    end
    
    % calculate one term for scale i in the numerator and the denominator in
    % equation (7.7) in the ATBD
    % circfilt implements circular convolution by
    % product of ffts and ifft signal to noise ratio calculation
    
    % denominator term in equation (7.7) for scale i
    SNRi = circfilt(flipud(whitenedTransit(:,i).^2),inverseWstd2);  
    
    %+++++++++++NOTE++++++++++++++++++++++++++++++++++++++++++++++++++++++
    % this right shift by 1 is needed to align the time domain statistics
    % with the wavelet domain single event statistics calculation
    % can be explained when we realize that circular convolution function
    % obtains the first value by shifting the second series circularly by 1
    % sample; it is not for lag = 0;
    
    SNRi = circshift(SNRi,1);
       
    % scaling term - in OWT (implemented as an octave filter bank)
    % there is no downsampling by 2; in each bandpass there are still as
    % many samples as in the higher bandpass => i.e., twice the redundancy
    % (previous channel itself might contain redundant signals)
    % (two copies of each signal)
       
    % numerator term in equation (7.7) for scale i
    Li = circfilt(flipud(whitenedTransit(:,i)),whitenedFluxTimeSeries(:,i).*inverseWstd2);
    Li = circshift(Li,1);
    
    Xi = circfilt(flipud(whitenedTransit(:,i)),sqrt(inverseWstd2));  
    Xi = circshift(Xi,1);
    
    % scale the numerator term by 1/2^i to reflect absence of
    % downsampling in OWT and increase in number of samples in each scale by
    % a factor of 2
    
    corrComponents(:,i) = circshift(Li, fix(mTransitLength/2)) / (2^i);
    normComponents(:,i) = circshift(SNRi,fix(mTransitLength/2)) / (2^i);
    xComponents(:,i) = circshift(Xi,fix(mTransitLength/2)) / (2^i);
    
end

%xComponents = sum(xComponents,2);

return


