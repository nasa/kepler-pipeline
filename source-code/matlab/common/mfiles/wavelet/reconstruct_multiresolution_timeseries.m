%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [multiResolutionTimeSeries] =
% reconstruct_multiresolution_timeseries(waveletCoefftsAtEachScale,
% scalingLPFilterCoefficients)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% Description: This function reconstructs the multiresolution signal from
% the overcomplete wavelet series expansion of the signal
%
% Input:
%       (1) waveletCoefftsAtEachScale - a matrix of size signal_length x nScales containing the
%       overcomplete wavelet series coefficients
%       (2) scalingLPFilterCoefficients - low pass analysis bank filter for the lowest nScales
%
% Output:
%       multiResolutionTimeSeries - multi resolution signal in matrix form
%       of the same size as 'waveletCoefftsAtEachScale'
%
% Reference: 'Ripples in Mathematics - The Discrete Wavelet Transform'
% by A. Jensen and A.la Cour-Harbo, Springer-Verlag, 2001
%
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
function [multiResolutionTimeSeries] = reconstruct_multiresolution_timeseries(waveletCoefftsAtEachScale,scalingLPFilterCoefficients)

% This code is easily understood if figure 5 from the Overcomplete Wavelet
% Transform prototype document is nearby for reference.


h0 = scalingLPFilterCoefficients;
[nRows nColumns] = size(waveletCoefftsAtEachScale);

multiResolutionTimeSeries = zeros(nRows, nColumns);

nScales = nColumns-1;


% Orthogonal wavelet filter set
% [h0, h1, g0, g1] = can be computed from the basic protype low pass
% scaling filter h0.
% 
%  h0 - Decomposition low-pass filter
%  h1 - Decomposition high-pass filter
%  g0 - Reconstruction low-pass filter
%  g1 - Reconstruction high-pass filter


initialFilterLength = length(h0);
% high pass
h1 = flipud(h0).*(-1).^(0:initialFilterLength-1)';

reconstructionLPF = zeros(nRows,nColumns);
reconstructionHPF = zeros(nRows,nColumns);
filterLengthAtEachScale = zeros(1,nColumns-1);


g0 = flipud(h0);
g1 = flipud(h1);

for iScale = 1:nScales
    currentFilterLength = initialFilterLength*2^(iScale-1);
    % filters with holes or zeros
    % we can create these filters from the basic h0 = daubh0(12) by filling
    % 2^(j-1) zeros in between samples for each nScales j. Here these filters
    % were obtained from OWT

    currentFilterCoeffts = reshape([g0';zeros(2^(iScale-1)-1,initialFilterLength)], currentFilterLength, 1);
    reconstructionLPF(1:currentFilterLength,iScale) =  currentFilterCoeffts;

    currentFilterCoeffts = reshape([g1';zeros(2^(iScale-1)-1,initialFilterLength)], currentFilterLength, 1);
    reconstructionHPF(1:currentFilterLength,iScale) =  currentFilterCoeffts;
    filterLengthAtEachScale(iScale) = currentFilterLength;
end;

% treat nScales+1 differently
% uses only low pass filters
waveletCoefftsAtLastScale = waveletCoefftsAtEachScale(:,nScales+1);
% this was the shift introduced in overcomplete_wavelet_transform to align
% the wavelet coefficients in time. 
nShift = filterLengthAtEachScale(nScales) - 2.^(nScales-1);
waveletCoefftsAtLastScale = circshift(waveletCoefftsAtLastScale,nShift);

% for the last nScales use the same filter length as the (last-1) nScales
for iScale = nScales:-1:1

    currentFilterLength = filterLengthAtEachScale(iScale);
    % filters with holes or zeros
    % we can create these filters from the basic h0  by filling
    % 2^(iScale-1) zeros in between samples for each iScale
    currentFilterCoeffts = reconstructionLPF(1:currentFilterLength,iScale) ;
    waveletCoefftsAtLastScale = convolve_circular(waveletCoefftsAtLastScale, currentFilterCoeffts,iScale);% this is circular convolution followed by a shift

end;

waveletCoefftsAtLastScale = waveletCoefftsAtLastScale .* 2^-nScales; % for OWT nScales each signal
multiResolutionTimeSeries(:,nScales+1) = waveletCoefftsAtLastScale ;

for jScale = nScales:-1:1
    for iScale = jScale:-1:1
        currentFilterLength = filterLengthAtEachScale(iScale);
        if(iScale == jScale) % beginning, copy wavelet coefficients array into waveletCoefftsAtLastScale
            waveletCoefftsAtLastScale = waveletCoefftsAtEachScale(:,iScale);
            nShift = filterLengthAtEachScale(iScale) - 2.^(iScale-1);
            % this was the shift introduced in overcomplete_wavelet_transform to align
            % the wavelet coefficients in time. 
            waveletCoefftsAtLastScale = circshift(waveletCoefftsAtLastScale,nShift);
            currentFilterCoeffts = reconstructionHPF(1:currentFilterLength,iScale);
        else
            currentFilterCoeffts = reconstructionLPF(1:currentFilterLength,iScale);
        end;
        waveletCoefftsAtLastScale = convolve_circular(waveletCoefftsAtLastScale, currentFilterCoeffts,iScale); % this is circular convolution followed by a shift

    end;
    multiResolutionTimeSeries(:,jScale) = waveletCoefftsAtLastScale .* 2^-jScale; % nScales the coefficients
end;
return;


function filteredTimeSeries = convolve_circular(waveletCoefftsAtLastScale,currentFilterCoeffts,iScale)

nLength = length(waveletCoefftsAtLastScale);
timeSeriesFFT = fft(waveletCoefftsAtLastScale,nLength);
filterTransferFunction = fft(currentFilterCoeffts,nLength);
filteredTimeSeries =  real(ifft(timeSeriesFFT.*filterTransferFunction));
nShift = length(currentFilterCoeffts) - 2.^(iScale-1);
filteredTimeSeries = circshift(filteredTimeSeries, -nShift);
return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%