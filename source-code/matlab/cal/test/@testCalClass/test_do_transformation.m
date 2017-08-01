function self = test_do_transformation( self )

%% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function self = test_do_transformation( self )
% This test verifies that do_transformation.m produces the correct output 
% for each of the allowed transformation types by comparing the generated 
% output to explicitly constructed expected output. See KADN-26185 for
% explicit form of propagated covariance matrix.
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

% For each transformation type check each of the possible disable levels
% disableLevel = 0  -->    perform both x and Cx transformations
% disableLevel = 1  -->    perform only x transformation, Cx not transformed
% disableLevel = 2  -->    perform only Cx transformation, x not performed
% disableLevel = 3  -->    neither x nor Cx transformations
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
%  Use a test runner to run the test method:
%  Example: run(text_test_runner, testCalClass('test_do_transformation'));
%

fractionalTolerance = 1e-10;

pSize = 1100;
inScale = 10000;

wScale = 100;
aFiltLen = 1; %#ok<NASGU>
bFiltLen = 3;
binNum = 20;
maxPolyOrder = 10;



%% test transform type 'scale'
transformType = 'scale';
w = wScale .* rand;

% setup errorPropStruct with dummy variable
A = empty_tStruct;
A.transformType = transformType;
A.transformParamStruct.scaleORweight = w;

% set up random input data vectors
x = inScale .* (1 - rand(pSize, 1));
Cx = inScale .* ( 1 - rand(pSize) );
y = [];
Cy = [];

A.disableLevel = 0;
% generate transformation output
[X, CX] = do_transformation(A, x, y, Cx, Cy);
% setup expected output matrices
Xexpected = w .* x;
CXexpected = (w.^2).*Cx;
% compare generated matrices to expected
compare_matrices(X,CX,Xexpected,CXexpected,transformType,fractionalTolerance);

A.disableLevel = 1;
% generate transformation output
[X, CX] = do_transformation(A, x, y, Cx, Cy);
% setup expected output matrices
Xexpected = w .* x;
CXexpected = Cx;
% compare generated matrices to expected
compare_matrices(X,CX,Xexpected,CXexpected,transformType,fractionalTolerance);

A.disableLevel = 2;
% generate transformation output
[X, CX] = do_transformation(A, x, y, Cx, Cy);
% setup expected output matrices
Xexpected = x;
CXexpected = (w.^2).*Cx;
% compare generated matrices to expected
compare_matrices(X,CX,Xexpected,CXexpected,transformType,fractionalTolerance);

A.disableLevel = 3;
% generate transformation output
[X, CX] = do_transformation(A, x, y, Cx, Cy);
% setup expected output matrices
Xexpected = x;
CXexpected = Cx;
% compare generated matrices to expected
compare_matrices(X,CX,Xexpected,CXexpected,transformType,fractionalTolerance);

%% test transform type 'scaleV'
transformType = 'scaleV';
w = wScale .* rand(pSize,1);

% setup errorPropStruct with random parameter data
A = empty_tStruct;
A.transformType = transformType;
A.transformParamStruct.scaleORweight = w;

% set up random input data vectors
x = inScale .* (1 - rand(pSize, 1));
Cx = inScale .* ( 1 - rand(pSize) );
y = [];
Cy = [];

A.disableLevel = 0;
% generate transformation output
[X, CX] = do_transformation(A, x, y, Cx, Cy);
% setup expected output matrices
Xexpected = w .* x;
CXexpected = scalecol(w, scalerow(w, Cx));
% compare generated matrices to expected
compare_matrices(X,CX,Xexpected,CXexpected,transformType,fractionalTolerance);

A.disableLevel = 1;
% generate transformation output
[X, CX] = do_transformation(A, x, y, Cx, Cy);
% setup expected output matrices
Xexpected = w .* x;
CXexpected = Cx;
% compare generated matrices to expected
compare_matrices(X,CX,Xexpected,CXexpected,transformType,fractionalTolerance);

A.disableLevel = 2;
% generate transformation output
[X, CX] = do_transformation(A, x, y, Cx, Cy);
% setup expected output matrices
Xexpected = x;
CXexpected = scalecol(w, scalerow(w, Cx));
% compare generated matrices to expected
compare_matrices(X,CX,Xexpected,CXexpected,transformType,fractionalTolerance);

A.disableLevel = 3;
% generate transformation output
[X, CX] = do_transformation(A, x, y, Cx, Cy);
% setup expected output matrices
Xexpected = x;
CXexpected = Cx;
% compare generated matrices to expected
compare_matrices(X,CX,Xexpected,CXexpected,transformType,fractionalTolerance);

%% test transform type 'addV'
transformType = 'addV';

% setup errorPropStruct with dummy variable
A = empty_tStruct;
A.transformType = transformType;

% set up input data vectors
x = inScale .* (1 - rand(pSize, 1));
Cx = inScale .* ( 1 - rand(pSize) );
y = inScale .* (1 - rand(pSize, 1));
Cy = inScale .* ( 1 - rand(pSize) );

A.disableLevel = 0;
% generate transformation output
[X, CX] = do_transformation(A, x, y, Cx, Cy);
% setup expected output matrices
Xexpected = x + y;
CXexpected = Cx + Cy;
% compare generated matrices to expected
compare_matrices(X,CX,Xexpected,CXexpected,transformType,fractionalTolerance);

A.disableLevel = 1;
% generate transformation output
[X, CX] = do_transformation(A, x, y, Cx, Cy);
% setup expected output matrices
Xexpected = x + y;
CXexpected = Cx;
% compare generated matrices to expected
compare_matrices(X,CX,Xexpected,CXexpected,transformType,fractionalTolerance);

A.disableLevel = 2;
% generate transformation output
[X, CX] = do_transformation(A, x, y, Cx, Cy);
% setup expected output matrices
Xexpected = x;
CXexpected = Cx + Cy;
% compare generated matrices to expected
compare_matrices(X,CX,Xexpected,CXexpected,transformType,fractionalTolerance);

A.disableLevel = 3;
% generate transformation output
[X, CX] = do_transformation(A, x, y, Cx, Cy);
% setup expected output matrices
Xexpected = x;
CXexpected = Cx;
% compare generated matrices to expected
compare_matrices(X,CX,Xexpected,CXexpected,transformType,fractionalTolerance);

%% test transform type 'diffV'
transformType = 'diffV';

% setup errorPropStruct with dummy variable
A = empty_tStruct;
A.transformType = transformType;

% set up input data vectors
x = inScale .* (1 - rand(pSize, 1));
Cx = inScale .* ( 1 - rand(pSize) );
y = inScale .* (1 - rand(pSize, 1));
Cy = inScale .* ( 1 - rand(pSize) );

A.disableLevel = 0;
% generate transformation output
[X, CX] = do_transformation(A, x, y, Cx, Cy);
% setup expected output matrices
Xexpected = x - y;
CXexpected = Cx + Cy;
% compare generated matrices to expected
compare_matrices(X,CX,Xexpected,CXexpected,transformType,fractionalTolerance);

A.disableLevel = 1;
% generate transformation output
[X, CX] = do_transformation(A, x, y, Cx, Cy);
% setup expected output matrices
Xexpected = x - y;
CXexpected = Cx;
% compare generated matrices to expected
compare_matrices(X,CX,Xexpected,CXexpected,transformType,fractionalTolerance);

A.disableLevel = 2;
% generate transformation output
[X, CX] = do_transformation(A, x, y, Cx, Cy);
% setup expected output matrices
Xexpected = x;
CXexpected = Cx + Cy;
% compare generated matrices to expected
compare_matrices(X,CX,Xexpected,CXexpected,transformType,fractionalTolerance);

A.disableLevel = 3;
% generate transformation output
[X, CX] = do_transformation(A, x, y, Cx, Cy);
% setup expected output matrices
Xexpected = x;
CXexpected = Cx;
% compare generated matrices to expected
compare_matrices(X,CX,Xexpected,CXexpected,transformType,fractionalTolerance);

%% test transform type 'multV'
transformType = 'multV';

% setup errorPropStruct with dummy variable
A = empty_tStruct;
A.transformType = transformType;

% set up input data vectors
x = inScale .* (1 - rand(pSize, 1));
Cx = inScale .* ( 1 - rand(pSize) );
y = inScale .* (1 - rand(pSize, 1));
Cy = inScale .* ( 1 - rand(pSize) );

A.disableLevel = 0;
% generate transformation output
[X, CX] = do_transformation(A, x, y, Cx, Cy);
% setup expected output matrices
Xexpected = x .* y;
CXexpected = scalecol(x, scalerow(x, Cy) ) + scalecol(y, scalerow(y, Cx) );
% compare generated matrices to expected
compare_matrices(X,CX,Xexpected,CXexpected,transformType,fractionalTolerance);

A.disableLevel = 1;
% generate transformation output
[X, CX] = do_transformation(A, x, y, Cx, Cy);
% setup expected output matrices
Xexpected = x .* y;
CXexpected = Cx;
% compare generated matrices to expected
compare_matrices(X,CX,Xexpected,CXexpected,transformType,fractionalTolerance);

A.disableLevel = 2;
% generate transformation output
[X, CX] = do_transformation(A, x, y, Cx, Cy);
% setup expected output matrices
Xexpected = x;
CXexpected = scalecol(x, scalerow(x, Cy) ) + scalecol(y, scalerow(y, Cx) );
% compare generated matrices to expected
compare_matrices(X,CX,Xexpected,CXexpected,transformType,fractionalTolerance);

A.disableLevel = 3;
% generate transformation output
[X, CX] = do_transformation(A, x, y, Cx, Cy);
% setup expected output matrices
Xexpected = x;
CXexpected = Cx;
% compare generated matrices to expected
compare_matrices(X,CX,Xexpected,CXexpected,transformType,fractionalTolerance);

%% test transform type 'divV'
transformType = 'divV';

% setup errorPropStruct with dummy variable
A = empty_tStruct;
A.transformType = transformType;

% set up input data vectors
x = inScale .* (1 - rand(pSize, 1));
Cx = inScale .* ( 1 - rand(pSize) );
y = inScale .* (1 - rand(pSize, 1));
Cy = inScale .* ( 1 - rand(pSize) );
% replace any zeros with ones in random data
y(y==0)=1;

A.disableLevel = 0;
% generate transformation output
[X, CX] = do_transformation(A, x, y, Cx, Cy);
% setup expected output matrices
Xexpected = x ./ y;
CXexpected = scalecol(1./y, scalerow(1./y, Cx)) + scalecol(x./(y.^2), scalerow(x./(y.^2), Cy));
% compare generated matrices to expected
compare_matrices(X,CX,Xexpected,CXexpected,transformType,fractionalTolerance);

A.disableLevel = 1;
% generate transformation output
[X, CX] = do_transformation(A, x, y, Cx, Cy);
% setup expected output matrices
Xexpected = x ./ y;
CXexpected = Cx;
% compare generated matrices to expected
compare_matrices(X,CX,Xexpected,CXexpected,transformType,fractionalTolerance);

A.disableLevel = 2;
% generate transformation output
[X, CX] = do_transformation(A, x, y, Cx, Cy);
% setup expected output matrices
Xexpected = x;
CXexpected = scalecol(1./y, scalerow(1./y, Cx)) + scalecol(x./(y.^2), scalerow(x./(y.^2), Cy));
% compare generated matrices to expected
compare_matrices(X,CX,Xexpected,CXexpected,transformType,fractionalTolerance);

A.disableLevel = 3;
% generate transformation output
[X, CX] = do_transformation(A, x, y, Cx, Cy);
% setup expected output matrices
Xexpected = x;
CXexpected = Cx;
% compare generated matrices to expected
compare_matrices(X,CX,Xexpected,CXexpected,transformType,fractionalTolerance);

%% test transform type 'wSum'
transformType = 'wSum';
w = wScale .* rand(pSize,1);
% setup errorPropStruct with dummy variable
A = empty_tStruct;
A.transformType = transformType;
A.transformParamStruct.scaleORweight = w;

% set up input data vectors
x = inScale .* (1 - rand(pSize, 1));
Cx = inScale .* ( 1 - rand(pSize) );
y = [];
Cy = [];

A.disableLevel = 0;
% generate transformation output
[X, CX] = do_transformation(A, x, y, Cx, Cy);
% setup expected output matrices
Xexpected = sum(w .* x);
CXexpected = w(:)' * Cx * w(:);
% compare generated matrices to expected
compare_matrices(X,CX,Xexpected,CXexpected,transformType,fractionalTolerance);

A.disableLevel = 1;
% generate transformation output
[X, CX] = do_transformation(A, x, y, Cx, Cy);
% setup expected output matrices
Xexpected = sum(w .* x);
CXexpected = Cx;
% compare generated matrices to expected
compare_matrices(X,CX,Xexpected,CXexpected,transformType,fractionalTolerance);

A.disableLevel = 2;
% generate transformation output
[X, CX] = do_transformation(A, x, y, Cx, Cy);
% setup expected output matrices
Xexpected = x;
CXexpected = w(:)' * Cx * w(:);
% compare generated matrices to expected
compare_matrices(X,CX,Xexpected,CXexpected,transformType,fractionalTolerance);

A.disableLevel = 3;
% generate transformation output
[X, CX] = do_transformation(A, x, y, Cx, Cy);
% setup expected output matrices
Xexpected = x;
CXexpected = Cx;
% compare generated matrices to expected
compare_matrices(X,CX,Xexpected,CXexpected,transformType,fractionalTolerance);

%% test transform type 'wMean'
transformType = 'wMean';
w = wScale .* rand(pSize,1);
% setup errorPropStruct with dummy variable
A = empty_tStruct;
A.transformType = transformType;
A.transformParamStruct.scaleORweight = w;

% set up input data vectors
x = inScale .* (1 - rand(pSize, 1));
Cx = inScale .* ( 1 - rand(pSize) );
y = [];
Cy = [];

A.disableLevel = 0;
% generate transformation output
[X, CX] = do_transformation(A, x, y, Cx, Cy);
% setup expected output matrices
Xexpected = mean(w .* x);
CXexpected = (1/length(x)^2).*( w(:)' * Cx * w(:));
% compare generated matrices to expected
compare_matrices(X,CX,Xexpected,CXexpected,transformType,fractionalTolerance);

A.disableLevel = 1;
% generate transformation output
[X, CX] = do_transformation(A, x, y, Cx, Cy);
% setup expected output matrices
Xexpected = mean(w .* x);
CXexpected = Cx;
% compare generated matrices to expected
compare_matrices(X,CX,Xexpected,CXexpected,transformType,fractionalTolerance);

A.disableLevel = 2;
% generate transformation output
[X, CX] = do_transformation(A, x, y, Cx, Cy);
% setup expected output matrices
Xexpected = x;
CXexpected = (1/length(x)^2).*( w(:)' * Cx * w(:));
% compare generated matrices to expected
compare_matrices(X,CX,Xexpected,CXexpected,transformType,fractionalTolerance);

A.disableLevel = 3;
% generate transformation output
[X, CX] = do_transformation(A, x, y, Cx, Cy);
% setup expected output matrices
Xexpected = x;
CXexpected = Cx;
% compare generated matrices to expected
compare_matrices(X,CX,Xexpected,CXexpected,transformType,fractionalTolerance);

%% test transform type 'bin'
transformType = 'bin';

% set up random bin sizes
bins = floor(rand(binNum,1).*pSize/binNum);
while(sum(bins)<pSize)
    binIndex = ceil(rand*binNum);
    bins(binIndex) = bins(binIndex) + 1;
end

% setup errorPropStruct with dummy variable
A = empty_tStruct;
A.transformType = transformType;
A.transformParamStruct.binSizes = bins;

% set up input data vectors
x = inScale .* (1 - rand(pSize, 1));
Cx = inScale .* ( 1 - rand(pSize) );
y = [];
Cy = [];

A.disableLevel = 0;
% generate transformation output
[X, CX] = do_transformation(A, x, y, Cx, Cy);
% setup expected output matrices
Xexpected = zeros(length(bins),1);
CXexpected = zeros(length(bins));
a = 1;
for i=1:length(bins)
    b = a + bins(i) - 1;
    Xexpected(i) = sum(x(a:b));
    aa = 1;
    for j=1:length(bins)
        bb = aa + bins(j) - 1;
        CXexpected(i,j) = sum(sum(Cx(a:b,aa:bb),2),1);
        aa = bb + 1;
    end
    a = b + 1;
end
% compare generated matrices to expected
compare_matrices(X,CX,Xexpected,CXexpected,transformType,fractionalTolerance);

A.disableLevel = 1;
% generate transformation output
[X, CX] = do_transformation(A, x, y, Cx, Cy);
% setup expected output matrices
Xexpected = zeros(length(bins),1);
CXexpected = Cx;
a = 1;
for i=1:length(bins)
    b = a + bins(i) - 1;
    Xexpected(i) = sum(x(a:b));
    a = b + 1;
end
% compare generated matrices to expected
compare_matrices(X,CX,Xexpected,CXexpected,transformType,fractionalTolerance);

A.disableLevel = 2;
% generate transformation output
[X, CX] = do_transformation(A, x, y, Cx, Cy);
% setup expected output matrices
Xexpected = x;
CXexpected = zeros(length(bins));
a = 1;
for i=1:length(bins)
    b = a + bins(i) - 1;
    aa = 1;
    for j=1:length(bins)
        bb = aa + bins(j) - 1;
        CXexpected(i,j) = sum(sum(Cx(a:b,aa:bb),2),1);
        aa = bb + 1;
    end
    a = b + 1;
end
% compare generated matrices to expected
compare_matrices(X,CX,Xexpected,CXexpected,transformType,fractionalTolerance);

A.disableLevel = 3;
% generate transformation output
[X, CX] = do_transformation(A, x, y, Cx, Cy);
% setup expected output matrices
Xexpected = x;
CXexpected = Cx;
% compare generated matrices to expected
compare_matrices(X,CX,Xexpected,CXexpected,transformType,fractionalTolerance);


%% - not yet implemented in do_transformation
% % test transform type 'lsPolyFit'
% transformType = 'lsPolyfit';
% 

%% test transform type 'wPoly'
transformType = 'wPoly';
w = wScale .* rand(pSize,1);
p = ceil( maxPolyOrder * rand );
z = sort(inScale .* (1 - rand(pSize, 1)));

% setup errorPropStruct with dummy variable
A = empty_tStruct;
A.transformType = transformType;
A.transformParamStruct.scaleORweight = w;
A.transformParamStruct.polyOrder = p;
A.transformParamStruct.polyXvector = z;

% set up input data vectors
x = inScale .* rand(p+1, 1);
Cx = inScale .* rand(p+1);
y = [];
Cy = [];

A.disableLevel = 0;
% generate transformation output
[X, CX] = do_transformation(A, x, y, Cx, Cy);
% setup expected output matrices
M = fliplr(weighted_design_matrix(z, w, p, 'standard'));
Xexpected = M * x;
CXexpected = M * Cx * M';
% compare generated matrices to expected
compare_matrices(X,CX,Xexpected,CXexpected,transformType,fractionalTolerance);

A.disableLevel = 1;
% generate transformation output
[X, CX] = do_transformation(A, x, y, Cx, Cy);
% setup expected output matrices
M = fliplr(weighted_design_matrix(z, w, p, 'standard'));
Xexpected = M * x;
CXexpected = Cx;
% compare generated matrices to expected
compare_matrices(X,CX,Xexpected,CXexpected,transformType,fractionalTolerance);

A.disableLevel = 2;
% generate transformation output
[X, CX] = do_transformation(A, x, y, Cx, Cy);
% setup expected output matrices
M = fliplr(weighted_design_matrix(z, w, p, 'standard'));
Xexpected = x;
CXexpected = M * Cx * M';
% compare generated matrices to expected
compare_matrices(X,CX,Xexpected,CXexpected,transformType,fractionalTolerance);

A.disableLevel = 3;
% generate transformation output
[X, CX] = do_transformation(A, x, y, Cx, Cy);
% setup expected output matrices
M = eye(length(x));
Xexpected = x;
CXexpected = M * Cx * M';
% compare generated matrices to expected
compare_matrices(X,CX,Xexpected,CXexpected,transformType,fractionalTolerance);

%% test transform type 'expSum'
transformType = 'expSum';
nDecayConstants = 5;
nIndices = 1070;

% set up input
K = rand(nDecayConstants,1);
xIndices = sort(rand(nIndices, 1));

% setup errorPropStruct with dummy variable
A = empty_tStruct;
A.transformType = transformType;
A.transformParamStruct.polyOrder = K;
A.transformParamStruct.polyXvector = xIndices;

% set up dummy input data vectors
x = rand(nDecayConstants,1);
Cx = rand(nDecayConstants);
y = [];
Cy = [];

% setup expected matrices
M = zeros( nIndices, nDecayConstants );
for i=1:nDecayConstants
    M(:,i) = exp(xIndices./K(i));
end


% test case 0
A.disableLevel = 0;
[X, CX] = do_transformation(A, x, y, Cx, Cy);
Xexpected = M * x;
CXexpected = M * Cx * M';
% compare generated matrices to expected
compare_matrices(X,CX,Xexpected,CXexpected,transformType,fractionalTolerance);

% test case 1
A.disableLevel = 1;
[X, CX] = do_transformation(A, x, y, Cx, Cy);
Xexpected = M * x;
CXexpected = Cx;
% compare generated matrices to expected
compare_matrices(X,CX,Xexpected,CXexpected,transformType,fractionalTolerance);

% test case 2
A.disableLevel = 2;
[X, CX] = do_transformation(A, x, y, Cx, Cy);
Xexpected = x;
CXexpected = M * Cx * M';
% compare generated matrices to expected
compare_matrices(X,CX,Xexpected,CXexpected,transformType,fractionalTolerance);

% test case 3
A.disableLevel = 3;
[X, CX] = do_transformation(A, x, y, Cx, Cy);
Xexpected = x;
CXexpected = Cx;
% compare generated matrices to expected
compare_matrices(X,CX,Xexpected,CXexpected,transformType,fractionalTolerance);

%% test transform type 'custom01_calFitted1DBlack'
transformType = 'custom01_calFitted1DBlack';
nIndices        = 1070;
nFitParameters  = 6;
Klong           = nIndices * rand;
Kshort          = rand * Klong;
xIndices        = 1:nIndices;
mSmearRows      = 6:18;
maxSmearRow     = 20;
scipixStartRow  = maxSmearRow + 3;

        % Functional form:
        % Sum of linear + two exponentials(~select indices) + linear(select indices)
        % z = T * A
        %
        % Where:
        % T = [ 1 .* double(~mSmearSelect);
        %      ( x - (R - mod(R,2))/2 ) ./ ( (R - mod(R,2))/2 ) .* double(~mSmearSelect);
        %      exp(-( x-B ) / Klong) .* double(~mSmearSelect);
        %      exp(-( x-B ) / Kshort) .* double(~mSmearSelect); 
        %      double(mSmearSelect);
        %      ( x .* double(mSmearSelect) - mean( x(mSmearRows).*double(mSmearSelect(mSmearRows)) ) .* double(mSmearSelect)]     
        %    
        %    x = 1:R        == black collateral rows (one-based)
        %    B              == start of science rows (one-based)
        %    Klong          == long decayy constant
        %    Kshort         == short decay constant
        %    mSmearRows     == list of masked smear rows used
        %    mSearSelect    == logical array indicating rows <= maxSmearRow
        %
        % Assign inputs to existing parameter names (some don't really match the meaning of the parameter, but they are just names):
        % inputData{1}  == [Klong, Kshort]              == scaleORweight
        % inputData{2}  == x                            == polyXvector
        % inputData{3}  == mSmearRows                   == xIndices
        % inputData{4}  == B                            == filterCoeffs_b
        % inputData{5}  == maxSmearRow                  == filterCoeffs_a

% setup errorPropStruct with dummy variable
A = empty_tStruct;
A.transformType = transformType;
A.transformParamStruct.scaleORweight(1)   = Klong;
A.transformParamStruct.scaleORweight(2)   = Kshort;
A.transformParamStruct.polyXvector        = xIndices;
A.transformParamStruct.xIndices           = mSmearRows;
A.transformParamStruct.filterCoeffs_b     = scipixStartRow;
A.transformParamStruct.filterCoeffs_a     = maxSmearRow;

% setup expected matrices per transformation definition above
xOffset = (nIndices - mod(nIndices,2))/2;

M = zeros( nIndices, nFitParameters );
M(:,1) = 1;
M(1:maxSmearRow,1) = 0;
M(:,2) = ((xIndices - xOffset) ./ xOffset);
M(1:maxSmearRow,2) = 0;
M(:,3) = exp( - (xIndices - scipixStartRow)./Klong);
M(1:maxSmearRow,3) = 0;
M(:,4) = exp( - (xIndices - scipixStartRow)./Kshort);
M(1:maxSmearRow,4) = 0;
M(1:maxSmearRow,5) = 1;
M(1:maxSmearRow,6) = (xIndices(1:maxSmearRow) - mean(xIndices(mSmearRows(mSmearRows<maxSmearRow))));

% set up dummy input data vectors
x = rand(nFitParameters,1);
Cx = rand(nFitParameters);
y = [];
Cy = [];

% test case 0
A.disableLevel = 0;
[X, CX] = do_transformation(A, x, y, Cx, Cy);
Xexpected = M * x;
CXexpected = M * Cx * M';
% compare generated matrices to expected
compare_matrices(X,CX,Xexpected,CXexpected,transformType,fractionalTolerance);

% test case 1
A.disableLevel = 1;
[X, CX] = do_transformation(A, x, y, Cx, Cy);
Xexpected = M * x;
CXexpected = Cx;
% compare generated matrices to expected
compare_matrices(X,CX,Xexpected,CXexpected,transformType,fractionalTolerance);

% test case 2
A.disableLevel = 2;
[X, CX] = do_transformation(A, x, y, Cx, Cy);
Xexpected = x;
CXexpected = M * Cx * M';
% compare generated matrices to expected
compare_matrices(X,CX,Xexpected,CXexpected,transformType,fractionalTolerance);

% test case 3
A.disableLevel = 3;
[X, CX] = do_transformation(A, x, y, Cx, Cy);
Xexpected = x;
CXexpected = Cx;
% compare generated matrices to expected
compare_matrices(X,CX,Xexpected,CXexpected,transformType,fractionalTolerance);


%% test transform type 'filter'
transformType = 'filter';
a = 1;
b = rand(bFiltLen,1)-0.5;
b = b ./ sqrt(abs(b)' * abs(b));

% setup errorPropStruct with dummy variable
A = empty_tStruct;
A.transformType = transformType;
A.transformParamStruct.filterCoeffs_a = a;
A.transformParamStruct.filterCoeffs_b = b;

% set up input data vectors
x = inScale .* (1 - rand(pSize, 1));
Cx = rand(pSize);
y = [];
Cy = [];

A.disableLevel = 0;
% generate transformation output
[X, CX] = do_transformation(A, x, y, Cx, Cy);

% setup expected results --> X = filter(b,a,x) = M * x
%                        --> CX = filter(b,a,filter(b,a,Cx')')
%                               = J * Cx * J'
%                               = M * Cx * M'
Xexpected = filter(b,a,x);
CXexpected = filter(b,a,filter(b,a,Cx')');
% compare generated results to expected
compare_matrices(X, CX, Xexpected, CXexpected, transformType,fractionalTolerance);

A.disableLevel = 1;
% generate transformation output
[X, CX] = do_transformation(A, x, y, Cx, Cy);

% setup expected results --> X = filter(b,a,x) = M * x
%                        --> CX = filter(b,a,filter(b,a,Cx')')
%                               = J * Cx * J'
%                               = M * Cx * M'
Xexpected = filter(b,a,x);
CXexpected = Cx;
% compare generated results to expected
compare_matrices(X, CX, Xexpected, CXexpected, transformType,fractionalTolerance);

A.disableLevel = 2;
% generate transformation output
[X, CX] = do_transformation(A, x, y, Cx, Cy);

% setup expected results --> X = filter(b,a,x) = M * x
%                        --> CX = filter(b,a,filter(b,a,Cx')')
%                               = J * Cx * J'
%                               = M * Cx * M'
Xexpected = x;
CXexpected = filter(b,a,filter(b,a,Cx')');
% compare generated results to expected
compare_matrices(X, CX, Xexpected, CXexpected, transformType,fractionalTolerance);

A.disableLevel = 3;
% generate transformation output
[X, CX] = do_transformation(A, x, y, Cx, Cy);

% setup expected results --> X = filter(b,a,x) = M * x
%                        --> CX = filter(b,a,filter(b,a,Cx')')
%                               = J * Cx * J'
%                               = M * Cx * M'
Xexpected = x;
CXexpected = Cx;
% compare generated results to expected
compare_matrices(X, CX, Xexpected, CXexpected, transformType,fractionalTolerance);

%% - not yet implemented in do_transformation
% test transform type 'FCModelScale'
%transformType = 'FCModelScale';

%% - not yet implemented in do_transformation
% test transform type 'FCModelAdd'
%transformType = 'FCModelAdd';

%% test transform type 'userM'
transformType = 'userM';

Minput = wScale .* rand(maxPolyOrder, pSize);

% setup errorPropStruct with dummy variable
A = empty_tStruct;
A.transformType = transformType;
A.transformParamStruct.userM = Minput;

% set up input data vectors
x = inScale .* (1 - rand(pSize, 1));
Cx = rand(pSize);
y = [];
Cy = [];

A.disableLevel = 0;
% generate transformation output
[X, CX] = do_transformation(A, x, y, Cx, Cy);
% setup expected output matrices - Jacobian of constant transformation matrix = transformation
Xexpected = Minput * x;
CXexpected = Minput * Cx * Minput';
% compare generated matrices to expected
compare_matrices(X,CX,Xexpected,CXexpected,transformType,fractionalTolerance);

A.disableLevel = 1;
% generate transformation output
[X, CX] = do_transformation(A, x, y, Cx, Cy);
% setup expected output matrices - Jacobian of constant transformation matrix = transformation
Xexpected = Minput * x;
CXexpected = Cx;
% compare generated matrices to expected
compare_matrices(X,CX,Xexpected,CXexpected,transformType,fractionalTolerance);

A.disableLevel = 2;
% generate transformation output
[X, CX] = do_transformation(A, x, y, Cx, Cy);
% setup expected output matrices - Jacobian of constant transformation matrix = transformation
Xexpected = x;
CXexpected = Minput * Cx * Minput';
% compare generated matrices to expected
compare_matrices(X,CX,Xexpected,CXexpected,transformType,fractionalTolerance);

A.disableLevel = 3;
% generate transformation output
[X, CX] = do_transformation(A, x, y, Cx, Cy);
% setup expected output matrices - Jacobian of constant transformation matrix = transformation
Xexpected = x;
CXexpected = Cx;
% compare generated matrices to expected
compare_matrices(X,CX,Xexpected,CXexpected,transformType,fractionalTolerance);

%% - not yet implemented in do_transformation
% test transform type 'clearVar'
%transformType = 'clearVar';

%% - not yet implemented in do_transformation
% test transform type 'clearAll'
%transformType = 'clearAll';

%% test transform type 'eye'
transformType = 'eye';

% setup errorPropStruct with dummy variable
A = empty_tStruct;
A.transformType = transformType;

% set up input data vectors
x = inScale .* (1 - rand(pSize, 1));
Cx = rand(pSize);
y = [];
Cy = [];

A.disableLevel = 0;
% generate transformation output
[X, CX] = do_transformation(A, x, y, Cx, Cy);
% setup expected output matrices - Jacobian of constant transformation matrix = transformation
Xexpected = x;
CXexpected = Cx;
% compare generated matrices to expected
compare_matrices(X,CX,Xexpected,CXexpected,transformType,fractionalTolerance);

A.disableLevel = 1;
% generate transformation output
[X, CX] = do_transformation(A, x, y, Cx, Cy);
% setup expected output matrices - Jacobian of constant transformation matrix = transformation
Xexpected = x;
CXexpected = Cx;
% compare generated matrices to expected
compare_matrices(X,CX,Xexpected,CXexpected,transformType,fractionalTolerance);

A.disableLevel = 2;
% generate transformation output
[X, CX] = do_transformation(A, x, y, Cx, Cy);
% setup expected output matrices - Jacobian of constant transformation matrix = transformation
Xexpected = x;
CXexpected = Cx;
% compare generated matrices to expected
compare_matrices(X,CX,Xexpected,CXexpected,transformType,fractionalTolerance);

A.disableLevel = 3;
% generate transformation output
[X, CX] = do_transformation(A, x, y, Cx, Cy);
% setup expected output matrices - Jacobian of constant transformation matrix = transformation
Xexpected = x;
CXexpected = Cx;
% compare generated matrices to expected
compare_matrices(X,CX,Xexpected,CXexpected,transformType,fractionalTolerance);

%%
% allowedTypes = {'scale';...
%                 'scaleV';...
%                 'addV';...
%                 'diffV';...
%                 'multV';...
%                 'divV';...
%                 'wSum';...
%                 'wMean';...
%                 'bin';...
%                 'lsPolyFit';...
%                 'wPoly';...
%                 'filter';...
%                 'FCmodelScale';...
%                 'FCmodelAdd';...
%                 'userM';...
%                 'clearVar';...
%                 'clearAll';...
%                 'eye'};


%%

function compare_matrices(M, J, Mexpected, Jexpected, transformType, fractionalTolerance)

% compare generated matrices to expected matices. Agreement expected to
% within fractionalTolerance
N = M - Mexpected;
D = max(max(abs(M + Mexpected)));
if(D == 0)
    D = 1;
end
message = ['Wrong transformed data returned for transform type ',transformType];
assert( all(all(abs(2.*N./D)<fractionalTolerance)), message);
N = J - Jexpected;
D = max(max(abs(J + Jexpected)));
if(D == 0)
    D = 1;
end
message = ['Wrong transformed covariance returned for transform type ',transformType];
assert( all(all(abs(2.*N./D)< fractionalTolerance)), message);
return


