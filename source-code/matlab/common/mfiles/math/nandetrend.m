function Y = nandetrend( X, o, bp )
%
% function Y = nandetrend( X, o, bp )
%
%  NANDETREND Removes a linear trend from a vector, usually for FFT processing.
%     Y = NANDETREND(X) removes the best straight-line fit linear trend from the
%     data in vector X and returns the residual in vector Y.  If X is a
%     matrix, NANDETREND removes the trend from each column of the matrix.
%  
%     Y = NANDETREND(X,'constant') removes just the mean value from the vector X,
%     or the mean value from each column, if X is a matrix.
%  
%     Y = NANDETREND(X,'linear',BP) removes a continuous, piecewise linear trend.
%     Breakpoint indices for the linear trend are contained in the vector BP.
%     The default is no breakpoints, such that one single straight line is
%     removed from each column of X.
%
% This function first fills NaN data columnwise by fitting a polynomial of order 1
% to the non-NaN data indices then evaluating this polynomial at the NaN data indices.
% It then calls the MATLAB internal function DETREND to perform column-wise detrending
% of order 1. The NaNs are put back in at the end.
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


if nargin < 2, o  = 1; end
if nargin < 3, bp = 0; end

[rows, cols] = size(X);

nanIndex = isnan(X);

for i=1:cols
    
    y = X(~nanIndex(:,i),i);
    x = find(~nanIndex(:,i));
    xi = find(nanIndex(:,i));
    
    if(length(x) > 2)        
        p = polyfit(x,y,1);
        yi = polyval(p,xi);
        X(nanIndex(:,i),i) = yi;     
    end
    
end

Y = detrend( X, o, bp );
Y(nanIndex) = NaN;   
