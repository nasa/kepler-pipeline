function result = std_w_NaNs_2D(X, varargin)
%
% function result = std_w_Nans_2D(X, varargin)
% where varargin = {FLAG, DIM}
%
% Calls MATLAB std(X, FLAG, DIM) operating across DIM on only the 
% non-NaN entries and returns the result. The variable argunments
% accepted are varargin{1} == FLAG and varargin{2} == DIM, as in 
% std(X). The possible values are FLAG = {0,1} and DIM = {1,2} 
% where these enumerations are as defined in STD. X must be a 2D
% array.
%
%   See also STD
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

% check dimension of X
if(ndims(X)~=2)
    error('X must be a 2-D array.');
end

% get size of array
[rows, cols] = size(X);

% trivial case, X = []
if(rows==0 || cols==0)
    result = NaN;
    return;
end

% default FLAG and DIM values as defined in STD
FLAG = 0;
DIM = 1;

% load FLAG and DIM values from argument list
if(nargin>1)
    FLAG = varargin{1};
end
if(nargin>2)
    DIM = varargin{2};
end

% check FLAG values, FLAG == {0,1}
if(all([0,1]~=FLAG))
    error('If FLAG argument is specified it must be 0 or 1.');
end

% check DIM values, DIM == {1,2}
if(all([1,2]~=DIM))
    error('If DIM argument is specified it must be 1 or 2.');
end


 

% locate non-NaN entries
% perform std on non-NaNs across DIM

validIdx = ~isnan(X);

if(rows==1 || cols==1)
    % treat row or column vector as special case
    result = std(X(validIdx),FLAG,DIM);
else
    if(DIM==1)
        result = zeros(1,cols);
                
     elseif(DIM==2)
        result = zeros(rows,1);
        
        % set up the transpose problem
        X = X';
        validIdx = validIdx';
        [rows, cols] = size(X);
    end
    
    % DIM unspecified in STD --> DIM == 1
    % operate across rows
    for i = 1:cols
        tempX = X((i-1)*rows + 1:i*rows);
        tempIdx = validIdx((i-1)*rows + 1:i*rows);
        if( all(~tempIdx) )
            result(i) = NaN;
        else
            result(i) = std(tempX(tempIdx),FLAG);
        end
    end
end


    