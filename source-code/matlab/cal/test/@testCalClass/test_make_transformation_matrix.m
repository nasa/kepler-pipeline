function self = test_make_transformation_matrix( self )

%% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function self = test_make_transformation_matrix( self )
% This test verifies that make_transformation_matrix.m produces the correct
% transformation matrix (M) and Jacobian matrix (J) for each of the allowed
% transformation types by comparing the generated matrices to explicitly
% constructed expected matrices. See KADN-26185 for form of explicit
% transformation and Jacobian matrices.
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
%  Use a test runner to run the test method:
%  Example: run(text_test_runner, testCalClass('test_make_transformation_matrix'));
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

fractionalTolerance = 1e-10;

pSize = 1100;
inScale = 10000;
wScale = 100;
aFiltLen = 1;                                               %#ok<NASGU>
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
y = [];

% generate transformation and Jacobian matrices from structure
[M, J] = make_transformation_matrix(A, x, y);

% setup expected matrices
Mexpected = w .* speye(pSize);
Jexpected = Mexpected;

% compare generated matrices to expected
compare_matrices(M,J,Mexpected,Jexpected,transformType,fractionalTolerance);

%% test transform type 'scaleV'
transformType = 'scaleV';
w = wScale .* rand(pSize,1);

% setup errorPropStruct with random parameter data
A = empty_tStruct;
A.transformType = transformType;
A.transformParamStruct.scaleORweight = w;

% set up random input data vectors
x = inScale .* (1 - rand(pSize, 1));
y = [];

% generate transformation and Jacobian matrices from structure
[M, J] = make_transformation_matrix(A, x, y);

% setup expected matrices
Mexpected = sparse(diag(w));
Jexpected = Mexpected;

% compare generated matrices to expected
compare_matrices(M,J,Mexpected,Jexpected,transformType,fractionalTolerance);

%% test transform type 'addV'
transformType = 'addV';

% setup errorPropStruct with dummy variable
A = empty_tStruct;
A.transformType = transformType;

% set up input data vectors
x = inScale .* (1 - rand(pSize, 1));
y = inScale .* (1 - rand(pSize, 1));

% generate transformation and Jacobian matrices from structure
[M, J] = make_transformation_matrix(A, x, y);

% setup expected matrices
Mexpected = [speye(pSize), speye(pSize)];
Jexpected = Mexpected;

% compare generated matrices to expected
compare_matrices(M,J,Mexpected,Jexpected,transformType,fractionalTolerance);

%% test transform type 'diffV'
transformType = 'diffV';

% setup errorPropStruct with dummy variable
A = empty_tStruct;
A.transformType = transformType;

% set up input data vectors
x = inScale .* (1 - rand(pSize, 1));
y = inScale .* (1 - rand(pSize, 1));

% generate transformation and Jacobian matrices from structure
[M, J] = make_transformation_matrix(A, x, y);

% setup expected matrices
Mexpected = [speye(pSize), -speye(pSize)];
Jexpected = Mexpected;

% compare generated matrices to expected
compare_matrices(M,J,Mexpected,Jexpected,transformType,fractionalTolerance);

%% test transform type 'multV'
transformType = 'multV';

% setup errorPropStruct with dummy variable
A = empty_tStruct;
A.transformType = transformType;

% set up input data vectors
x = inScale .* (1 - rand(pSize, 1));
y = inScale .* (1 - rand(pSize, 1));

% generate transformation and Jacobian matrices from structure
[M, J] = make_transformation_matrix(A, x, y);

% setup expected matrices
Mexpected = 0.5 .* [sparse(diag(y)), sparse(diag(x))];
Jexpected = 2 .* Mexpected;

% compare generated matrices to expected
compare_matrices(M,J,Mexpected,Jexpected,transformType,fractionalTolerance);

%% test transform type 'divV'
transformType = 'divV';

% setup errorPropStruct with dummy variable
A = empty_tStruct;
A.transformType = transformType;

% set up input data vectors
x = inScale .* (1 - rand(pSize, 1));
y = inScale .* (1 - rand(pSize, 1));
y(y==0)=1;

% generate transformation and Jacobian matrices from structure
[M, J] = make_transformation_matrix(A, x, y);

% setup expected matrices
Mexpected = 0.5 .* [sparse(diag(1./y)), sparse(diag(x./(y.^2)))];
Jexpected = [sparse(diag(1./y)), -sparse(diag(x./(y.^2)))];

% compare generated matrices to expected
compare_matrices(M,J,Mexpected,Jexpected,transformType,fractionalTolerance);

%% test transform type 'wSum'
transformType = 'wSum';
w = wScale .* rand(pSize,1);
% setup errorPropStruct with dummy variable
A = empty_tStruct;
A.transformType = transformType;
A.transformParamStruct.scaleORweight = w;

% set up input data vectors
x = inScale .* (1 - rand(pSize, 1));
y = [];

% generate transformation and Jacobian matrices from structure
[M, J] = make_transformation_matrix(A, x, y);

% setup expected matrices
Mexpected = sparse(w(:)');
Jexpected = Mexpected;

% compare generated matrices to expected
compare_matrices(M,J,Mexpected,Jexpected,transformType,fractionalTolerance);

%% test transform type 'wMean'
transformType = 'wMean';
w = wScale .* rand(pSize,1);
% setup errorPropStruct with dummy variable
A = empty_tStruct;
A.transformType = transformType;
A.transformParamStruct.scaleORweight = w;

% set up input data vectors
x = inScale .* (1 - rand(pSize, 1));
y = [];

% generate transformation and Jacobian matrices from structure
[M, J] = make_transformation_matrix(A, x, y);

% setup expected matrices
Mexpected = sparse(w(:)')./length(x);
Jexpected = Mexpected;

% compare generated matrices to expected
compare_matrices(M,J,Mexpected,Jexpected,transformType,fractionalTolerance);

%% test transform type 'bin'
transformType = 'bin';
b = rand(binNum,1);
b = floor(pSize .* b ./ sum(b));
b(end) = b(end) + pSize - sum(b);

% setup errorPropStruct with dummy variable
A = empty_tStruct;
A.transformType = transformType;
A.transformParamStruct.binSizes = b;

% set up input data vectors
x = inScale .* (1 - rand(pSize, 1));
y = [];

% generate transformation and Jacobian matrices from structure
[M, J] = make_transformation_matrix(A, x, y);

% setup expected matrices
Mexpected = spalloc(binNum,sum(b),sum(b));
binIndex = 1;
for i = 1:binNum
    Mexpected(i, binIndex:binIndex + b(i) - 1 ) = 1;                                                                %#ok<*SPRIX>
    binIndex = binIndex + b(i);
end          
Jexpected = Mexpected;

% compare generated matrices to expected
compare_matrices(M,J,Mexpected,Jexpected,transformType,fractionalTolerance);

%% - not yet implemented in make_transformation_matrix
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
x = inScale .* (1 - rand(pSize, 1));
y = [];

% generate transformation and Jacobian matrices from structure
[M, J] = make_transformation_matrix(A, x, y);

% setup expected matrices
Mexpected = zeros(pSize, p + 1);
for i=p:-1:0
    Mexpected(:,p-i+1) = z.^i;
end
Mexpected = scalecol(w,Mexpected);
Jexpected = Mexpected;

% compare generated matrices to expected
compare_matrices(M,J,Mexpected,Jexpected,transformType,fractionalTolerance);

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
y = [];

% generate transformation and Jacobian matrices from structure
[M, J] = make_transformation_matrix(A, x, y);

% setup expected matrices
Mexpected = zeros( nIndices, nDecayConstants );
for i=1:nDecayConstants
    Mexpected(:,i) = exp(xIndices./K(i));
end
Jexpected = Mexpected;

% compare generated matrices to expected
compare_matrices(M,J,Mexpected,Jexpected,transformType,fractionalTolerance);

%% test transform type 'custom01_calFitted1DBlack'
transformType = 'custom01_calFitted1DBlack';
nIndices = 1070;
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
A.transformParamStruct.scaleORWeight(1)   = Klong;
A.transformParamStruct.scaleORWeight(2)   = Kshort;
A.transformParamStruct.polyXvector        = xIndices;
A.transformParamStruct.xIndices           = mSmearRows;
A.transformParamStruct.filterCoeffs_b     = scipixStartRow;
A.transformParamStruct.filterCoeffs_a     = maxSmearRow;

% set up dummy input data vectors
x = rand(nFitParameters,1);
y = [];

% generate transformation and Jacobian matrices from structure
[M, J] = make_transformation_matrix(A, x, y);

% setup expected matrices per transformation definition above
Mexpected = zeros( nIndices, nFitParameters );
mSmearSelect = xIndices <= maxSmearRow;
xOffset = (nIndices - mod(nIndices,2))/2;

Mexpected(:,1) = 1 .* double( ~mSmearSelect );
Mexpected(:,2) = ((xIndices - xOffset) ./ xOffset) .* double( ~mSmearSelect );
Mexpected(:,3) = exp( - (xIndices - scipixStartRow)./Klong);
Mexpected(1:maxSmearRow,3) = 0;
Mexpected(:,4) = exp( - (xIndices - scipixStartRow)./Kshort);
Mexpected(1:maxSmearRow,4) = 0;
Mexpected(1:maxSmearRow,5) = 1;
Mexpected(1:maxSmearRow,6) = xIndices(1:maxSmearRow) - mean(xIndices(mSmearRows(mSmearRows<maxSmearRow)));

Jexpected = Mexpected;

% compare generated matrices to expected
compare_matrices(M,J,Mexpected,Jexpected,transformType,fractionalTolerance);


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
y = [];
Cx = rand(pSize);

% generate transformation and Jacobian matrices from structure
[M, J] = make_transformation_matrix(A, x, y);

% setup expected results --> X = filter(b,a,x) = M * x
%                        --> CX = filter(b,a,filter(b,a,Cx')')
%                               = J * Cx * J'
%                               = M * Cx * M'
X = filter(b,a,x);
CX = filter(b,a,filter(b,a,Cx')');

% compare generated results to expected
compare_matrices(M*x, J*Cx*J', X, CX, transformType,fractionalTolerance);

%% - not yet implemented in make_transformation_matrix
% test transform type 'FCModelScale'
%transformType = 'FCModelScale';

%% - not yet implemented in make_transformation_matrix
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
y = [];

% generate transformation and Jacobian matrices from structure
[M, J] = make_transformation_matrix(A, x, y);

% setup expected matrices - Jacobian of constant transformation matrix = transformation
Mexpected = Minput;
Jexpected = Minput;

% compare generated matrices to expected
compare_matrices(M,J,Mexpected,Jexpected,transformType,fractionalTolerance);

%% - not yet implemented in make_transformation_matrix
% test transform type 'clearVar'
%transformType = 'clearVar';

%% - not yet implemented in make_transformation_matrix
% test transform type 'clearAll'
%transformType = 'clearAll';

%% test transform type 'eye'
transformType = 'eye';

% setup errorPropStruct with dummy variable
A = empty_tStruct;
A.transformType = transformType;

% set up input data vectors
x = inScale .* (1 - rand(pSize, 1));
y = [];

% generate transformation and Jacobian matrices from structure
[M, J] = make_transformation_matrix(A, x, y);

% setup expected matrices - Jacobian of constant transformation matrix = transformation
Mexpected = eye(length(x));
Jexpected = Mexpected;

% compare generated matrices to expected
compare_matrices(M,J,Mexpected,Jexpected,transformType,fractionalTolerance);

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
message = ['Wrong transformation matrix returned for transform type ',transformType];
assert( all(all(abs(2.*N./D)<fractionalTolerance)), message);
N = J - Jexpected;
D = max(max(abs(J + Jexpected)));
if(D == 0)
    D = 1;
end
message = ['Wrong Jacobian matrix returned for transform type ',transformType];
assert( all(all(abs(2.*N./D)< fractionalTolerance)), message);
return
