%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function [W] = OvercompleteWaveletTransform(x,h0,Maxscale)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Function Name:  OvercompleteWaveletTransform.m
%
% Modification History - This can be managed by a revision control system
%
% Software level: Prototype Code
%
% Description: This function returns the wavelet series expansion of the input signal
%
% Input:
%       Star flux data with planetary transit signature buried in it
%       Daubechies 12 tap scaling filter coefficients (could be any other)
%       number of stages of filter banks
%       Maxscale - number of scales or number of stages in the filter bank
%       in the wavelet series expansion
% Output:
%       Matrix of wavelet coefficients of size
%       (scales+1)x(length of signal)
%
% Author: J.Jenkins
% Comments: This function was part of the transitgame.m matlab software
% that demonstrated the effectiveness of wavelet based matched filter
% detection algorithm in extracting transit signatures buried in the
% DIARAD/SOHO solar irradiance measurements corrupted by instrumental and
% shot noise.
%
% H.Chandrasekaran - modified and added comments as part of the prototyping
% effort for Kepler data pipeline 10/25/04
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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

function [W] = OvercompleteWaveletTransform(x,h0,Maxscale)

nx = length(x);    % input data vector length, forced to be a power of 2

m = length(h0); % scaling function (low pass filter impulse response) coefficients length


% coefficients of the wavelet (high pass filter) obtained as
% (+/-)*((-1)^n)*h0(N-n) where N = length of h0
% (under orthogonality conditions for scaling and wavelet functions)

h1 = flipud(h0).*(-1).^(0:m-1)';

% Y = fft(X,n) returns the n-point DFT. If the length of X is less than n,
% X is padded with trailing zeros to length n. If the length of X is greater
% than n, the sequence X is truncated. When X is a matrix, the length of the
% columns are adjusted in the same manner

H0 = fft(h0,nx); % LPF (Filter bank terminology) Scaling coefficients at scale k /Wavelet terminology

H1 = fft(h1,nx); % HPF (Filter bank terminology) Wavelet expansion coefficients at scale k /Wavelet terminology

% higher scale wavelet components can be considered as details on a lower
% scale signal

% find out how many stages of filtering to do
% for any signal that is band limited, there will be an upper scale j = J,
% above which the wavelet coefficients are negligibly small
% - that is indicated by Maxscale

W = zeros(nx,Maxscale+1);


X = fft(x);


for j = 1:Maxscale

    % wavelet expansion of signal at scale k
    % signal filtered by wavelet coefficients at scale k (HPF at scale k)
    W(:,j)= real(ifft( X.*H1 ));
    
    % shifting the wavelet coefficients to align in time 
    % shift = (filter length - number of zeros trailing (same as the number
    % of zeros in between in between)
    
    nshift = m*2.^(j-1)- 2.^(j-1); 
    W(:,j) = circshift(W(:,j),-nshift);

    
    % low pass filter the signal for the next iteration
    X = X.*H0;

    % MULTIRATE IDENTITIES:  Interchange of filtering and downsampling:
    % downsampling by N followed by filtering with H(z) is equivalent to
    % filtering with the upsampled filter(H(z^N)) before downsampling.
    % (upsampling a filter impulse response is equivalent to introducing
    % 2^k zeros between nonzero coefficients at scale k filter


    H0=[H0(1:2:end);H0(1:2:end)];

    % Upsampling shrinks the original spectrum and creates a compressed
    % image next to it

    H1 = [H1(1:2:end);H1(1:2:end)];


end

x = real(ifft(X)); % lowest resolution signal
W(:,Maxscale+1) = x; % wavelet decomposition of the signal at (k+1)th scale
nshift = m*2.^(Maxscale-1) -2.^(Maxscale-1);
W(:,Maxscale+1) = circshift(x, -nshift); % wavelet decomposition of the signal at (k+1)th scale


return
