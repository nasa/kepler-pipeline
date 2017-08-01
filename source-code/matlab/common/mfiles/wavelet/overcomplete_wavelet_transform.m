%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [waveletDetailCoefftsAtEachScale] =
% overcomplete_wavelet_transform(timeSeries,scalingFilterCoefficients,
% maxScale)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Short description of the algorithm: 
%
% �	The Overcomplete Wavelet Transform (OWT) is a modified version of the
% discrete wavelet transform (DWT) and is also known as shift invariant
% DWT, Redundant DWT, stationary DWT, time invariant DWT, translation
% invariant DWT, and non-decimated DWT [1,2,3, 6]. 
% �	Unlike the Fourier transform, the overcomplete wavelet transform is a
% highly redundant nonorthogonal transform and obeys a form of Parseval�s
% energy conservation principle. 
% �	Unlike the Fourier transform which maps a time series (one dimensional
% signal) into a one dimensional sequence of coefficients in the frequency
% domain, the OWT maps the time series into a two dimensional array of
% coefficients localizing the signal both in time and in frequency. 
%
% �	Need for the Overcomplete Wavelet Transform (OWT): 
% The wavelet series expansion of a signal is not shift invariant. If the
% signal is circularly shifted, the discrete wavelet transform (DWT)
% coefficients do not simply shift; there is no simple relationship between
% the wavelet coefficients of the original and the shifted signal. The OWT
% implementation essentially computes the wavelet series expansion for all
% possible shifts of the signal and hence is the same for the signal and
% its shifted versions.
% The signal of interest is the transit pulse whose shape is known but
% where or how many times it occurs in the time series is not known. This
% signal detection problem is solved by (1) computing the overcomplete
% wavelet series expansion of the of the time series and th etransit pulse
% once, (2) calculating the matched filter detection statistic for the
% transit pulse located at all possible time instances in the time series,
% and (3) looking for the maximum multiple event detection statistic, the
% location of which gives the orbital period and phase of candidate
% planets.
%
%
% Inputs:
%       1. timeSeries - flux time series.  This can be a vector of nCadences, 
%          or a matrix of nCadences x nTimeSeries.  In the latter case, the OWT
%          will be applied to all of the time series, since this provides some
%          efficiencies compared to calling the OWT function once for each time
%          series.
%       2. scalingFilterCoefficients - scaling filter coefficients (currently
%          using Daubechies 12 tap filter coefficients but could be any other)
%       3. maxScale - number of scales or number of stages in the filter bank
%          in the wavelet series expansion
% Output:
%       1. waveletDetailCoefftsAtEachScale - a matrix of wavelet coefficients.
%          Matrix size is [nCadences,maxScale+1] when timeSeries is a vector,
%          or [nCadences,maxScale+1,nTimeSeries] when timeSeries is a matrix.
%
% References:
% [1]   KADN-26061 Wavelet Transform
% [2]	J. Jenkins, Algorithm Theoretical Basis Document for the Science
%       Operations Center, KSOC-21008-001, July 2004.
% [3]	M.Vetterli and J. Kova?evi?, Wavelets and Subband Coding,
%       Prentice-Hall Inc., 1995.
% [4]	C. S. Burrus, R. A. Gopinath, and H. Guo, Introduction to Wavelets
%       and Wavelet Transforms - A Primer, Prentice-Hall Inc., 1998.
% [5]	D. A. Jay and E. P. Flinchen, �Wavelet Transform Analyses of
%       Non-Stationary Tidal Currents,� Proceedings of the IEEE Fifth Working
%       Conference on Current Measurement, 1995, 7-9 Feb. 1995 Pages 100 -105.
% [6]	A. Jensen and A. la-Cour-Harbo, Ripples in Mathematics - The
%       Discrete Wavelet Transform, Springer-Verlag, 2001.
% [7]	D. B. Percival and A. T. Walden, Wavelet Methods for Time Series
%       Analysis, Cambridge University Press, 2000.
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

function [waveletDetailCoefftsAtEachScale] = overcomplete_wavelet_transform(...
    timeSeries,scalingFilterCoefficients,maxScale)



h0 = scalingFilterCoefficients;
% reverting to using h0, h1, g0, g1 to indicate analysis bank LPF, analysis bank HPF,
% synthesis bank LPF, synthesis bank HPF as this notation is the standard in
% the wavelet literature.


nLength = size(timeSeries,1); % input data vector length, must be a power of 2

nTimeSeries = size(timeSeries,2) ;


filterLength = length(h0);% scaling function (low pass filter impulse response) 
                          % coefficients length



% coefficients of the wavelet (high pass filter) obtained as
% (+/-)*((-1)^n)*h0(N-n) where N = length of h0
% (under orthogonality conditions for scaling and wavelet functions)
h1 = flipud(h0).*(-1).^(0:filterLength-1)';


% Y = fft(X,n) returns the n-point DFT. If the length of X is less than n,
% X is padded with trailing zeros to length n. If the length of X is greater
% than n, the sequence X is truncated. When X is a matrix, the length of the
% columns are adjusted in the same manner

H0 = fft(h0,nLength); % LPF (Filter bank terminology) Scaling coefficients at scale k 
%                       /Wavelet terminology

H1 = fft(h1,nLength); % HPF (Filter bank terminology) 
%                      Wavelet expansion coefficients at scale k /Wavelet terminology

% higher scale wavelet components can be considered as details on a lower
% scale signal

% find out how many stages of filtering to do
% for any signal that is band limited, there will be an upper scale j = J,
% above which the wavelet coefficients are negligibly small
% - that is indicated by maxScale

waveletDetailCoefftsAtEachScale = zeros(nLength,maxScale+1,nTimeSeries);


X = fft(timeSeries);


for j = 1:maxScale+1
    
    if j == maxScale+1
        H1 = ones(size(H1)) ;
    end

    for iTimeSeries = 1:nTimeSeries

        % wavelet expansion of signal at scale k
        % signal filtered by wavelet coefficients at scale k (HPF at scale k)
        waveletDetailCoefftsAtEachScale(:,j,iTimeSeries)= ...
            real(ifft( X(:,iTimeSeries).*H1 ));

        % shifting the wavelet coefficients to align in time 
        % shift = (filter length - number of zeros trailing (same as the number
        % of zeros in between in between)

        shiftIndex = min( j, maxScale ) ;
        nShift = filterLength*2.^(shiftIndex-1)- 2.^(shiftIndex-1); 
        waveletDetailCoefftsAtEachScale(:,j,iTimeSeries) = ...
            circshift(waveletDetailCoefftsAtEachScale(:,j,iTimeSeries),-nShift);


        % low pass filter the signal for the next iteration
        X(:,iTimeSeries) = X(:,iTimeSeries).*H0;

    end % loop over time series
    
    % Refer to Gilbert Strang and Truong Nguyen, 'Wavelets and Filter
    % Banks', Wellesley College, 1996
    
    % MULTIRATE IDENTITIES:  Interchange of filtering and downsampling:
    % downsampling by N followed by filtering with H(z) is equivalent to
    % filtering with the upsampled filter(H(z^N)) before downsampling.
    % (upsampling a filter impulse response is equivalent to introducing
    % 2^k zeros between nonzero coefficients at scale k filter
    H0=[H0(1:2:end);H0(1:2:end)];


    % Upsampling shrinks the original spectrum and creates a compressed
    % image next to it
    H1 = [H1(1:2:end);H1(1:2:end)];


end % loop over scales

% if the original timeSeries was a vector, the caller is doubtless expecting a 2-d array
% instead of 3-d, so take care of that now

  if isvector(timeSeries)
      waveletDetailCoefftsAtEachScale = reshape( waveletDetailCoefftsAtEachScale, ...
          nLength,maxScale+1 ) ;
  end

return
