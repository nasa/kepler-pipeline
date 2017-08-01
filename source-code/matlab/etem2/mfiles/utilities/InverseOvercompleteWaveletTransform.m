%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function [ReconstructedSignal, MRS] = InverseOvercompleteWaveletTransform.m(WC1,h0)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Function Name:  InverseOvercompleteWaveletTransform.m
%
%
% Modification History - This can be managed by a revision control system
%
% Software level: Prototype Code
%
% Description: This function reconstructs the multiresolution signal from
% the overcomplete wavelet series expansion of the signal
%
% Input:
%       (1) WC1 a matrix of size signal_length x scale containing the
%       overcomplete wavelet series coefficients
%       (2) ho - low pass analysis bank filter for the lowest scale
%
% Output:
%       ReconstructedSignal - reconstructed signal 
%       MRS - multi resolution signal, a matrix of size that of WC1
%
% Comments: Idea from 'Ripples in Mathematics - The Discrete Wavelet Transform'
% by A. Jensen and A.la Cour-Harbo, Springer-Veralg, 2001
%
% H.Chandrasekaran - initial version created as part of the prototyping
% effort for Kepler data pipeline 11/1/04
% rewritten on 3/31/2005
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
function [ReconstructedSignal, MRS] = InverseOvercompleteWaveletTransform(WC1,h0)

% This code is easily understood if figure 5 from the Overcomplete Wavelet
% Transform prototype document is nearby for reference.

[nrows ncols] = size(WC1);

MRS = zeros(nrows, ncols);
y = WC1;

scale = ncols-1;
n = nrows;

m = length(h0);
% high pass
h1 = flipud(h0).*(-1).^(0:m-1)';

rhlow = zeros(nrows,ncols);
rghigh = zeros(nrows,ncols);
filtlen = zeros(1,ncols-1);
filtlen(1) = m;


g0 = flipud(h0);
g1 = flipud(h1);

for ii = 1:scale
    L = filtlen(1)*2^(ii-1);
    % filters with holes or zeros
    % we can create these filters from the basic h0 = daubh0(12) by filling
    % 2^(j-1) zeros in between samples for each scale j. Here these filters
    % were obtained from OWT

    filter = reshape([g0';zeros(2^(ii-1)-1,m)], L, 1);
    rhlow(1:L,ii) =  filter;

    filter = reshape([g1';zeros(2^(ii-1)-1,m)], L, 1);
    rghigh(1:L,ii) =  filter;
    filtlen(ii) = L;
end;

% treat scale+1 differently
% uses only low pass filters
t = y(:,scale+1);
% this was the shift introduced in OvercompleteWavelet Transform.m to align
% the wavelet coefficients in time. Still can't understand why this has to
% be undone for perfect reconstruction!!!
nshift = filtlen(scale) - 2.^(scale-1);
t = circshift(t,nshift);

% for the last scale use the same filter length as the (last-1) scale
for ii = scale:-1:1

    L = filtlen(ii);
    % filters with holes or zeros
    % we can create these filters from the basic h0 = daubh0(12) by filling
    % 2^(j-1) zeros in between samples for each scale j. Here these filters
    % were obtained from OWT
    filter = rhlow(1:L,ii) ;
    t = circular_conv(t, filter,ii);% this is circular convolution followed by a shift

end;

t = t .* 2^-scale; % for OWT scale each signal
MRS(:,scale+1) = t ;

for jj = scale:-1:1
    for ii = jj:-1:1
        L = filtlen(ii);
        if(ii == jj) % beginning, copy wavelet coefficients array into t
            t = y(:,ii);
            nshift = filtlen(ii) - 2.^(ii-1);
            % this was the shift introduced in OvercompleteWavelet Transform.m to align
            % the wavelet coefficients in time. Still can't understand why this has to
            % be undone for perfect reconstruction!!!
            t = circshift(t,nshift);
            filter = rghigh(1:L,ii);
        else
            filter = rhlow(1:L,ii);
        end;
        t = circular_conv(t, filter,ii); % this is circular convolution followed by a shift

    end;
    t = t .* 2^-jj; % scale the coefficients
    MRS(:,jj) = t ;
end;

ReconstructedSignal = sum(MRS,2);
return;


function ct = circular_conv(t,filter,iscale)

nlength = length(t);
T = fft(t,nlength);
H = fft(filter,nlength);
ct =  real(ifft(T.*H));
nshift = length(filter) - 2.^(iscale-1);
ct = circshift(ct, -nshift);
return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%