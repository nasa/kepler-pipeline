%%  compute_model 
% Constructs SG+discontinuity design matrix.
% Returns only step height convolution kernel and zeros of kernel.
% 
%   Revision History:
%
%       Version 0   - 3/14/11     released for Science Office use
%       Version 0.1 - 4/30/11     improved/corrected documentation
% 
% <html>
% <style type="text/css"> pre.codeinput {background: #FFFF66; padding: 30px;} </style>
% </html>
% 
%%
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
function modelStruct = compute_model(modelLength,polynomialOrder,discontinuityOrder)
%% 1.0 ARGUMENTS
% 
% Function returns:
%
% * |modelStruct     -| Design matrix parameters structure
% * |.pseudoinverse     -| Component vector of left inverse matrix which gives the step
% height when multiplied by data
% * |.zeroCrossings  -| zero-crossing positions in the vector modelStruct.pseudoinverse, relative to
% center position
%
% Function Arguments:
%
% * |modelLength      -| The desired length of the model components: sets the scale
% for the model. modelLength should always be odd.
% * |polynomialOrder   -| The polynomial order for the polynomial components of the
% design matrix which extend for the entire range
% * |discontinuityOrder   -| The polynomial order for the polynomial components of the
% design matrix which are discontinuous. These components zero before the
% center position. They are discontinuous only in the derivative order
% corresponding to their polynomial order.
%
%% 2.0 CODE
%

%% 2.1 INITIALIZATION
%

% Range for polynomial generation:
range = -1.0:2/(modelLength-1):1.0;

% Center position (midpoint location of step and other discontinuities):
center = (modelLength-1)/2+1;

% Total number of vector components in design matrix=
% sum of polynomial orders, including zeroth:
nComponents = polynomialOrder+discontinuityOrder+2;

% Range for non-zero elements of discontinuity components
rightHalfRange = center+1:modelLength;        

% offset count (or index) to the component vector of left 
% inverse matrix which gives the step height when multiplied by data
stepComponentIndex = polynomialOrder+2; 

% Initialize design matrix designMatrix
designMatrix = zeros(nComponents,modelLength);

%% 2.2 BUILD DESIGN MATRIX
%

% vector #1: constant term
designMatrix(1,:) = ones(1,modelLength);

% vectors #2 to #polynomialOrder+1: polynomial terms 
for k = 1:polynomialOrder
    % calculates all associated legendre polynomials:
    legendreFunctions = legendre(k,range); 
    % only uses first legendre polynomial
    % adjusts center value to zero
    designMatrix(k+1,:) = legendreFunctions(1,:)-legendreFunctions(1,center);
end

% vector #polynomialOrder+2: STEP TERM
designMatrix(stepComponentIndex,rightHalfRange) = ones(1,length(rightHalfRange));
designMatrix(stepComponentIndex,center) = 0.5;
designMatrix(stepComponentIndex,:) = designMatrix(stepComponentIndex,:)-0.5;

% vector #polynomialOrder+3 to #polynomialOrder+discontinuityOrder+2: discontinuous polynomial terms
for k = 1:discontinuityOrder
    % calculates all associated legendre polynomials:
    legendreFunctions = legendre(k,range);
    % only uses first legendre polynomial
    % adjusts center value to zero
    % values before center remain at zero
    designMatrix(stepComponentIndex+k,rightHalfRange)=legendreFunctions(1,rightHalfRange)-legendreFunctions(1,center); 
end

%% 2.3 LEFT INVERSE MATRIX GENERATION
%

% Pseudoinverse:
U = ((designMatrix*designMatrix')\designMatrix)'; 

% Component which gives the step height when multiplied by data:
pseudoinverse = U(:,stepComponentIndex);

%% 2.4 ZEROS OF DESIRED COMPONENT
%

% because these are smooth functions pseudoinverse is smooth so
% just find the zero-crossings, i.e. places where the sign of pseudoinverse changes
zx = diff(sign(pseudoinverse));

% pseudoinverse is antisymmetric so only need to find zeros of one side of center
zeroCrossings = find(zx(1:center-2)~=0);

% zero-crossing locations relative to center
zeroCrossings = sort(center-zeroCrossings);

%% 2.5 RESULTS

modelStruct.pseudoinverse = pseudoinverse;
modelStruct.zeroCrossings = zeroCrossings;

end

