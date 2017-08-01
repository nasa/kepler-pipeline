function [smooth filter] = fast_local_polyfit(data, inOrder, inWidth, term)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function smooth = fast_local_polyfit(data, order, width, term)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% quickly compute local interpolated value or derivatives of an input data
% series via a polynomial fit.  Fit is performed using a clever convolution
% trick.
%
% inputs:
%   data: time series of data
%   order: order of polynomial to perform local fit.  Should be no more
%       than inWidth.  If order > inWidth it is set to inWidth
%   inWidth: half-width of window in which to do polynomial fit.  Should be >
%       length(data)/2.  If inWidth < length(data)/2 then inWidth is set to
%       length(data)/2.
%   term: which value to return:
%       term = 1: local interpolated value
%       term = 2: local interpolated first derivative
%       term = n: local interpolated (n-1)th derivative
%
% outputs:
%   smooth: array of same size as data which contains the local
%       interpolated values as specified by term
%   filter: the filter matrix describing this interpolation
%
% 
% Copyright 2017 United States Government as represented by the
% Administrator of the National Aeronautics and Space Administration.
% All Rights Reserved.
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

N = length(data);
% require that the length no be less than the width
if N < 2*inWidth
    width = fix(N/2);
else
    width = inWidth;
end

% require that order be no more than width
if inOrder > width
    order = width;
else
    order = inOrder;
end

% we handle boundaries by extending the data through
% reflecting the data across each boundary so that
% the first derivative is approximately continuous

% create data array d which contains the extended data
d = zeros(1, N + 2*width);
if N <= 5
    meanWidth = fix(N/2);
else
    meanWidth = 5;
end
% set the extended data on the left side, using an average of the v
% left-most points to compute the value at the reflection
d(1:width) = 2*mean(data(1:meanWidth+1)) - data(width+1:-1:2);
% set the data in the center
d(width+1:width+N) = data;
% set the extended data on the right side, using an average of the
% meanWidth right-most points to compute the value at the reflection
d(width+N+1:2*width+N) = 2*mean(data(N-meanWidth:N)) - data(N-1:-1:N-width);

% we contstruct a polynomial fit at each point centered on that point in a
% coordinate system where the each point is at 0.  Then the design matrix A
% is the same for every point and the value or derivative evaluated at that
% point is just the nth coefficient.  Then this coefficient at each point
% is computed as the convolution of the desired coeffient's column of 
% the filter matrix inv(A'A)*A' based on the design matrix, with the data.

% build the design matrix a A for the local coordinate system of point i
% with index space -r < i < r
M = 2*width+1; % size of the local window
A = zeros(M, order+1); % pre-allocate the design matrix
i=-width:width; % index space for the window
% compute the design matrix for each order
for o=1:order+1
    A(:,o) = power(i,o-1);
end
% compute the filter matrix
ATAinv = inv(A'*A);
ATAinvAT = ATAinv*A';

% pick out the row of the filter matrix for the desired return type
filter = ATAinvAT(term,:);
% perform the convolution computing the return array
s = conv(filter, d);
% pick out the return data from the input range of the extended arrays
smooth = s(2*width+1:2*width+N);
    
