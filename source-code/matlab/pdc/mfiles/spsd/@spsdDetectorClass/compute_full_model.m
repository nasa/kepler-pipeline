%%  compute_full_model 
% Constructs SG+discontinuity design matrix.
% Returns design matrix and convolution kernels for all coefficients.
%
%   Revision History:
%
%       Version 0 - 3/14/11     released for Science Office use
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
function modelStruct = compute_full_model(paramStruct,paddingLength)
%% 1.0 ARGUMENTS
% 
% Function returns:
%
% * |    -| 
%
% Function Arguments:
%
% * |paramStruct.windowWidth-| which FGS-frame clock sequence numbers to model
% * |paramStruct.sgPolyOrder-| which FGS-frame clock sequence numbers to model
% * |paramStruct.sgStepPolyOrder-| which FGS-frame clock sequence numbers to model
%
%% 2.0 CODE
%

modelLength        = paramStruct.windowWidth;
polynomialOrder    = paramStruct.sgPolyOrder;
discontinuityOrder = paramStruct.sgStepPolyOrder;
range              = -1.0:2/(modelLength-1):1.0;
center             = (modelLength-1)/2+1;
nComponents      = polynomialOrder+discontinuityOrder+5;
rightHalfRange     = center+1:modelLength;
stepComponentIndex = polynomialOrder+5;
designMatrix       = zeros(nComponents,modelLength);
modelStruct.pseudoinverse = zeros(paddingLength,nComponents);
paddingCenter      = (paddingLength-1)/2+1;

%%
designMatrix(1,:) = ones(1,modelLength);
designMatrix(2,center-1) = 1;
designMatrix(3,center) = 1;
designMatrix(4,center+1) = 1;
for k = 1:polynomialOrder
    legendreFunctions = legendre(k,range);
    designMatrix(k+4,:) = legendreFunctions(1,:)-legendreFunctions(1,center);
end
designMatrix(stepComponentIndex,rightHalfRange) = ones(1,length(rightHalfRange));
designMatrix(stepComponentIndex,center) = 0.5;
designMatrix(stepComponentIndex,:) = designMatrix(stepComponentIndex,:)-0.5;
for k = 1:discontinuityOrder
    legendreFunctions = legendre(k,range);
    designMatrix(stepComponentIndex+k,rightHalfRange)=legendreFunctions(1,rightHalfRange)-legendreFunctions(1,center);
end
U = ((designMatrix*designMatrix')\designMatrix)';
modelStruct.pseudoinverse(paddingCenter-center+1:paddingCenter+center-1,:) = U;
modelStruct.designMatrix = designMatrix;
modelStruct.nComponents=nComponents;

end

