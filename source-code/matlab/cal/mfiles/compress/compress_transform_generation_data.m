function C = compress_transform_generation_data(S, variableName, transformLevel, tParamFieldName, sNum)

% function C = compress_tranform_generation_data(S, variableName, transformLevel, tParamFieldName, sNum)
%
% Compress the transform generation data time series stored in tParamFieldName of
% the transformLevel transformParamStruct of errorPropStruct S for variableName using 
% SVD with sNum signular values.
% Return the compressed result in the compressedStruct C.
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

% Example errorPropStruct:
% 
% display_structure(calTransformStruct(10,1));
%            variableName: 'calibratedPixels1'
%               xPrimitive: 'SVD'
%              CxPrimitive: []
%                      row: [5489x1 int16]
%                      col: [5489x1 int16]
%                  gapList: [0x1 int16]
%     transformStructArray: [8x1 struct]
%
%            transformType: 'diffV'
%             disableLevel: 0
%           yDataInputName: 'fittedBlack'
%     transformParamStruct: [1x1 struct]
%
%      scaleORweight: []
%     filterCoeffs_b: []
%     filterCoeffs_a: []
%          polyOrder: []
%        polyXvector: []
%           binSizes: []
%        FCmodelCall: []
%              userM: []


varIndex = iserrorPropStructVariable(S(:,1), variableName);

if(varIndex > 0)    
    if( transformLevel <= length(S(varIndex).transformStructArray) )        
        if( isfield(S(varIndex,1).transformStructArray(transformLevel).transformParamStruct, tParamFieldName ) ) 
            
            tData =  S(varIndex,1).transformStructArray(transformLevel).transformParamStruct.(tParamFieldName);           
            [nCadences, nIndices] = size(tData);
            
            C = empty_compressedTransformStruct();    
            
            % compress using SVD - assumes tData is array of time series, e.g. row==time, col==spatial index
            sEffective = min(sNum, rank(full(tData)));
            [U, S, V, convFlag] = svds(tData,sEffective);
            C.minimumAicOrder = zeros(nIndices,1);
            C.residualPower = zeros(nIndices,1);
            C.U = U;
            C.S = diag(S);
            C.V = V;
            C.convFlag = convFlag;            
            C.transformLevel = transformLevel;
            C.transformParamName = tParamFieldName;            
    
            % determine optimal model order using AIC
            for i=1:nIndices
                aicDone = false;
                currentAic = realmax;
                sOrder = 0;
                while( ~aicDone && sOrder < sEffective && sOrder < min([nCadences, nIndices]) )
                    
                    sOrder = sOrder + 1;
                    tBar = U(:,1:sOrder) * S(1:sOrder, 1:sOrder) * V(i,1:sOrder)';
                    mse = mean( (tData(:,i) - tBar).^2 );
                    aic = compute_aic_metric(mse, nCadences, sOrder);

                    if( aic > currentAic )
                        aicDone = true;
                    else
                        currentAic = aic;                        
                    end

                end    
                C.minimumAicOrder(i) = sOrder;
                C.residualPower(i) = mse * nCadences;
            end
            
        end        
    end    
end
