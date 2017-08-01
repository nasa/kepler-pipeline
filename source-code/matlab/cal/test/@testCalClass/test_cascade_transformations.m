function self = test_cascade_transformations( self )

%% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function self = test_cascade_transformations( self )
% This test verifies that cascade_transformations.m propagates the primitive
% data and the primitive covariance correctly by comparing the output of the
% cascaded transformation to explicitly generated equivalents. A dummy
% errorPropStruct populated with random primitive data and self
% consistant transformations is used as input. This structure is shown in
% comments below the help header.
%
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
%  Use a test runner to run the test method:
%  Example: run(text_test_runner, testCalClass('test_cascade_transformations'));
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

%% call function to generate dummy data

A = make_dummy_errorPropStruct;

[index, varList] = iserrorPropStructVariable(A,'');                                                                                 %#ok<*ASGLU>
numVars = length(varList);

% The dummy struct contains the following data and transformations:
%varList =

%     'calibratedBlack'
%     'calibratedSmear'
%     'calibratedDark'
%     'V1'
%     'V2'
%
% For each of the variables in varList (i=1 through 5) the transformations 
% are shown below. x = propagated base data, Cx = covariance associated with
% the propagated base data, P denotes the primitive data.
% 1) scale, scaleV, addV --> x{1} = xP{1} .* s1 .* sV1 + xP{4}
%                           Cx{1} = scalecol(sV1,scalerow(sV1,CxP{1} .* s1^2)) + Cx{4} 
% 2) scale, scaleV, addV --> x{2} = xP{2} .* s2 .* sV2 + xP{2}
%                           Cx{2} = scalecol(sV2,scalerow(sV2,CxP{2} .* s2^2)) + Cx{5}
% 3) scale, scaleV, addV --> x{3} = xP{3} .* s3 .* sV3 + sV4
%                           Cx{3} = scalecol(sV4,scalerow(sV4(scalecol(sV3,scalerow(sV3,CxP{3} .* s1^2))) 
% 4) no transforms - primitive data only
%                        --> x{4} = xP{4} 
%                           Cx{4} = CxP{4}
% 5) no transforms - primitive data only
%                        --> x{5} = xP{5} 
%                           Cx{5} = CxP{5} 
%
%
% Construct transformation chains explicitly.

%% get primitve data
x = cell(numVars,1);
Cx = cell(numVars,1);
xP = cell(numVars,1);
CxP = cell(numVars,1);
x_exp = cell(numVars,1);
Cx_exp = cell(numVars,1);
for i=1:numVars
    [xP{i}, CxP{i}] = get_primitive_data(A,varList{i});
    % expand covariance to diagnonal matrix if it is stored as a vector
    if(isvector(CxP{i}))
        CxP{i}=diag(CxP{i});
    end
end

%% load expected results for variables with zero length transformation chains first
% set the expected results equal to these primitives
x_exp{4} = xP{4};
x_exp{5} = xP{5};
Cx_exp{4} = CxP{4};
Cx_exp{5} = CxP{5};

%% load transformation data for the rest and propagate the transformations to the expected results
s1  = A(1).transformStructArray(1).transformParamStruct.scaleORweight;
sV1 = A(1).transformStructArray(2).transformParamStruct.scaleORweight;
x_exp{1}  = xP{1} .* s1 .* sV1 + xP{4};
Cx_exp{1} = scalecol(sV1,scalerow(sV1,CxP{1} .* s1^2)) + CxP{4};

s2  = A(2).transformStructArray(1).transformParamStruct.scaleORweight;
sV2 = A(2).transformStructArray(2).transformParamStruct.scaleORweight;
x_exp{2} = xP{2} .* s2 .* sV2 + xP{5};
Cx_exp{2} = scalecol(sV2,scalerow(sV2,CxP{2} .* s2^2)) + CxP{5};

s3  = A(3).transformStructArray(1).transformParamStruct.scaleORweight;
sV3 = A(3).transformStructArray(2).transformParamStruct.scaleORweight;
sV4 = A(3).transformStructArray(3).transformParamStruct.scaleORweight;
x_exp{3} = xP{3} .* s3 .* sV3 .* sV4;
Cx_exp{3} = scalecol(sV4,scalerow(sV4,scalecol(sV3,scalerow(sV3,CxP{3} .* s3^2))));

%% check function w/o varargin
for i=1:length(varList)
    [x{i}, Cx{i}] = cascade_transformations(A, varList{i});
    assert_equals(x{i},x_exp{i},['x error on index ',num2str(i)]);
    assert_equals(Cx{i},Cx_exp{i},['Cx error on index ',num2str(i)]);
end

%% check function w/ mode = 0, both x and Cx returned
mode = 0;
indices = [];
level = [];
for i=1:length(varList)
    [x{i}, Cx{i}] = cascade_transformations(A, varList{i}, indices, level, mode);
    assert_equals(x{i},x_exp{i},['x error on index ',num2str(i)]);
    assert_equals(Cx{i},Cx_exp{i},['Cx error on index ',num2str(i)]);
end

%% check function w/ mode =1, x returned, Cx = []
mode = 1;
indices = [];
level = [];
for i=1:length(varList)
    [x{i}, Cx{i}] = cascade_transformations(A, varList{i}, indices, level, mode);
    assert_equals(x{i},x_exp{i},['x error on index ',num2str(i)]);
    assert_equals(Cx{i},[],['Cx error on index ',num2str(i)]);
end

%% check function w/ mode = 0, level = 1, 2, 3, both x and Cx returned propagated through level= i transformation
mode = 0; 
indices = [];
level = 1;
x_exp{1}  = xP{1} .* s1;
Cx_exp{1} = CxP{1} .* s1^2;

x_exp{2} = xP{2} .* s2;
Cx_exp{2} = CxP{2} .* s2^2;

x_exp{3} = xP{3} .* s3;
Cx_exp{3} = CxP{3} .* s3^2;

for i=1:length(varList)
    [x{i}, Cx{i}] = cascade_transformations(A, varList{i}, indices, level, mode);
    assert_equals(x{i},x_exp{i},['x error on index ',num2str(i)]);
    assert_equals(Cx{i},Cx_exp{i},['Cx error on index ',num2str(i)]);
end

mode = 0;
indices = [];
level = 2;
x_exp{1}  = xP{1} .* s1 .* sV1;
Cx_exp{1} = scalecol(sV1,scalerow(sV1,CxP{1} .* s1^2));

x_exp{2} = xP{2} .* s2 .* sV2;
Cx_exp{2} = scalecol(sV2,scalerow(sV2,CxP{2} .* s2^2));

x_exp{3} = xP{3} .* s3 .* sV3;
Cx_exp{3} = scalecol(sV3,scalerow(sV3,CxP{3} .* s3^2));
for i=1:length(varList)
    [x{i}, Cx{i}] = cascade_transformations(A, varList{i}, indices, level, mode);
    assert_equals(x{i},x_exp{i},['x error on index ',num2str(i)]);
    assert_equals(Cx{i},Cx_exp{i},['Cx error on index ',num2str(i)]);
end

mode = 0;
indices = [];
level = 3;
x_exp{1}  = xP{1} .* s1 .* sV1 + xP{4};
Cx_exp{1} = scalecol(sV1,scalerow(sV1,CxP{1} .* s1^2)) + CxP{4};

x_exp{2} = xP{2} .* s2 .* sV2 + xP{5};
Cx_exp{2} = scalecol(sV2,scalerow(sV2,CxP{2} .* s2^2)) + CxP{5};

x_exp{3} = xP{3} .* s3 .* sV3 .* sV4;
Cx_exp{3} = scalecol(sV4,scalerow(sV4,scalecol(sV3,scalerow(sV3,CxP{3} .* s3^2))));
for i=1:length(varList)
    [x{i}, Cx{i}] = cascade_transformations(A, varList{i}, indices, level, mode);
    assert_equals(x{i},x_exp{i},['x error on index ',num2str(i)]);
    assert_equals(Cx{i},Cx_exp{i},['Cx error on index ',num2str(i)]);    
end
