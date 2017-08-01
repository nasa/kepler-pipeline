function A = make_dummy_errorPropStruct()

% generate some random data and transformations and load into an errorPropStruct
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

dataSize = 10;
nGaps = 3;
gaps = unique(sort(ceil(dataSize*rand(nGaps,1))));

s1 = 100;
s2 = 10;
s3 = 1000;

o1 = 0.25;
o2 = 0.50;
o3 = 1.00;

A=repmat(empty_errorPropStruct,5,1);

A(1).variableName='calibratedBlack';
A(1).xPrimitive=s1.*(rand(dataSize,1)-o2);
A(1).CxPrimitive=s2.*rand(dataSize);
A(1).gapList=gaps;
A(1).transformStructArray=repmat(empty_tStruct,3,1);
    A(1).transformStructArray(1).transformType='scale';
    A(1).transformStructArray(1).transformParamStruct.scaleORweight=s2*s1;
    A(1).transformStructArray(2).transformType='scaleV';
    A(1).transformStructArray(2).transformParamStruct.scaleORweight=rand(dataSize,1)./s3;
    A(1).transformStructArray(3).transformType='addV';
    A(1).transformStructArray(3).yDataInputName='V1';


A(2).variableName='calibratedSmear';
A(2).xPrimitive=s3.*(rand(dataSize,1)-o2);
A(2).CxPrimitive=s2.*(rand(dataSize,1)-o2);
A(2).gapList=gaps;    
A(2).transformStructArray=repmat(empty_tStruct,3,1);
    A(2).transformStructArray(1).transformType='scale';
    A(2).transformStructArray(1).transformParamStruct.scaleORweight=s2*rand;
    A(2).transformStructArray(2).transformType='scaleV';
    A(2).transformStructArray(2).transformParamStruct.scaleORweight=s1.*(rand(dataSize,1)-o3);
    A(2).transformStructArray(3).transformType='addV';
    A(2).transformStructArray(3).yDataInputName='V2';

    
A(3).variableName='calibratedDark';
A(3).xPrimitive=(rand(dataSize,1)-o1)./s2;
A(3).CxPrimitive=(rand(dataSize,1)-o2)./s1;
A(3).gapList=gaps;
A(3).transformStructArray=repmat(empty_tStruct,3,1);
    A(3).transformStructArray(1).transformType='scale';
    A(3).transformStructArray(1).transformParamStruct.scaleORweight=s3*rand;
    A(3).transformStructArray(2).transformType='scaleV';
    A(3).transformStructArray(2).transformParamStruct.scaleORweight=s1.*rand(dataSize,1);
    A(3).transformStructArray(3).transformType='scaleV';
    A(3).transformStructArray(3).transformParamStruct.scaleORweight=s2.*rand(dataSize,1);


A(4).variableName='V1';
A(4).xPrimitive=s1.*(rand(dataSize,1)-o3);
A(4).CxPrimitive=s1.*(rand(dataSize,1)-o3);
A(4).gapList=gaps;

A(5).variableName='V2';
A(5).xPrimitive=s1.*(rand(dataSize,1)-o2);
A(5).CxPrimitive=s1.*(rand(dataSize)-o3)./s3;
A(5).gapList=gaps;


