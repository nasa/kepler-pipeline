function snrTimeSeries = ...
    compute_snr_using_known_noise_whitened_transit(noiseSigmaInEachScale, nLength, h0, transitPulse, varianceWindowLength)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function snrTimeSeries = ...
%     compute_snr_using_known_noise_whitened_transit(noiseSigmaInEachScale, nLength, h0, transitPulse, varianceWindowLength)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Description: This function returns the signal-to-noise ratio timeseries
% computed using equation 7.7 of the ATBD listed on page 51 of reference [1].
% Here the estimation of noise variance in the wavelet domain is not
% performed as the known noise variance is passed as 'noiseSigmaInEachScale' 
%
% Input:
%     1. noiseSigmaInEachScale: variance in each scale
%     2. nlength: length of time series 
%     2. h0: scaling filter coefficients (an example: Daubechies 12 tap)
%     3. transitPulse: trial transit pulse (an example: 3 hour rectangular
%     pulse represented as -ones(6,1), where the cadence duration is 30
%     minutes)
%     4. varianceWindowLength: length of the window over which variance
%     estimation is carried out in the wavelet domain
%
% Output:
%      1. snrTimeSeries (see the references listed below):
%      measures the signal-to-noise ratio at every cadence in the wavelet
%      domain
%
% Comments: This function is part of the transitgame.m matlab software
% written by Jon Jenkins that demonstrated the effectiveness of wavelet
% based matched filter based detection algorithm in extracting transit
% signatures buried in the DIARAD/SOHO solar irradiance measurements
% corrupted by instrumental and shot noise. It combines overcomplete
% wavelet transform and matched filter detection and forms the expected
% detection statistics in the same function to conserve memory.
%
% References:
%  [1]. J. Jenkins, Algorithm Theoretical Basis Document for the Science
%       Operations Center, KSOC-21008-001, July 2004.
%  [2]. KADN-26063 Combined Differential Photometric Precision (CDPP)
%       Calculation
%  [3]. KADN-26062 Matched Filter
%  [4]. KADN-26061 Wavelet Transform
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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

% duration of transit
mTransitLength = length(transitPulse);

% scaling (low pass filter) filter length
nFilterLength = length(h0);

% find out how many stages of filtering to do
% for any signal that is band limited, there will be an upper scale j = m,
% above which the wavelet coefficients are negligibly small
% also number of samples should be > filter length
mScale = log2(nLength) - floor(log2(nFilterLength))+1;


% coefficients of the wavelet (high pass filter) obtained as
% (+/-)*((-1)^nLength)*h0(N-nLength) where N = length of h0
% (under orthogonality conditions for scaling and wavelet functions)
h1 = flipud(h0).*(-1).^(0:nFilterLength-1)';


% Y = fft(X,nLength) returns the nLength-point DFT. If the length of X is less than nLength,
% X is padded with trailing zeros to length nLength. If the length of X is greater
% than nLength, the sequence X is truncated. When X is a matrix, the length of the
% columns are adjusted in the same manner


H0 = fft(h0,nLength); % LPF (Filter bank terminology) Scaling coefficients at scale k /Wavelet terminology

H1 = fft(h1,nLength); % HPF (Filter bank terminology) Wavelet expansion coefficients at scale k /Wavelet terminology


T = fft(transitPulse,nLength);


snrTimeSeries = 0;


k = varianceWindowLength;

for i = 1:mScale - 1

    % get wavelet coeffs at scale i for data and for transit pulse
    % wavelet expansion of signal containing transit signature and transit
    % pulse at scale i
    % (HPF at scale k)


    nShift = nFilterLength*2.^(i-1)- 2.^(i-1);

    Wtrani = real(ifft(T.*H1));

    Wtrani = circshift(Wtrani,-nShift);

    % low pass filter the signal and the transit pulse for the next iteration


    T = T.*H0;

    % MULTIRATE IDENTITIES:  Interchange of filtering and downsampling:
    % downsampling by N followed by filtering with H(z) is equivalent to
    % filtering with the upsampled filter(H(z^N)) before downsampling.
    % (upsampling a filter impulse response is equivalent to introducing
    % 2^k zeros between nonzero coefficients at scale k filter

    H0 = [H0(1:2:end);H0(1:2:end)];

    % Upsampling shrinks the original spectrum and creates a compressed
    % image next to it

    H1 = [H1(1:2:end);H1(1:2:end)];


    %  compute the time varying channel variance estimates
    %  implements the equation 7.6 in ATBD

    % 2*varianceWindowLength+1 is the length of the variance estimation window
    k = min(k*2,nLength);


    % sigma^2 time series calculation for each bandpass
    % notice the additional circular left shift by half window length
    % inverseWstd2 = circshift(movcircstd(Wxi,k),-k).^-2;% notice ^-2 = 1/Wstd^2
    inverseWstd2 = noiseSigmaInEachScale(i)*ones(length(Wtrani),1);
    inverseWstd2 = inverseWstd2.^-2;


    % calculate one term for scale i in the numerator and the denominator in
    % equation (7.7) in the ATBD
    % circfilt implements circular convolution by
    % product of ffts and ifft signal to noise ratio calculation

    % denominator term in equation (7.7) for scale i
    SNRi = circfilt(flipud(Wtrani.^2),inverseWstd2);

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
    snrTimeSeries = snrTimeSeries + SNRi/2^i;



end


Wtrani = real(ifft(T));
Wtrani = circshift(Wtrani,-nShift);

k = min(nLength,varianceWindowLength*2^(mScale+1));

inverseWstd2 = noiseSigmaInEachScale(i)*ones(length(Wtrani),1);
inverseWstd2 = inverseWstd2.^-2;


SNRi = circfilt(flipud(Wtrani.^2),inverseWstd2);
SNRi = circshift(SNRi,1);

snrTimeSeries = snrTimeSeries + SNRi/2^(mScale-1);

%snrTimeSeries = circshift(snrTimeSeries,-mTransitLength);
snrTimeSeries = circshift(snrTimeSeries,fix(mTransitLength/2));

snrTimeSeries = sqrt(snrTimeSeries);


return



function y = circfilt(h,fluxTimeSeries)
% y = circfilt(h,fluxTimeSeries)
% implements circular convolution by product of ffts and ifft

nLength = size(fluxTimeSeries,1);
X = fft(fluxTimeSeries);
H = fft(h,nLength);
y = real(ifft( scalecol(H,X) )); % scalecol does the multiplication

return


