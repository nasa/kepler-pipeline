function [ twoDBlackArray, twoDBlackArrayUnc ] = build_two_d_black_collateral_for_cadence(calIntermediateStruct, dynamicCollateralTwoDBlackStruct, cadenceIndex)
%
% function [ twoDBlackArray, twoDBlackArrayUnc ] = build_two_d_black_collateral_for_cadence(calIntermediateStruct, dynamicCollateralTwoDBlackStruct, cadenceIndex)
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


% Order of coadded and averaged black data in collateralTwoDBlack is: trailing black, masked smear, virtual smear, (maskedBlack,
% virtualBlack for SC only). Pixels are identified by the code in collateralType.
% 1 == trailing black
% 2 == masked smear
% 3 == virtual smear
% 4 == masked black
% 5 == virtual black


% initialize output arrays: nCcdRows x nCcdColumns
twoDBlackArray = zeros(calIntermediateStruct.nCcdRows,calIntermediateStruct.nCcdColumns);
twoDBlackArrayUnc = zeros(calIntermediateStruct.nCcdRows,calIntermediateStruct.nCcdColumns);

% unpack inputs
black   = dynamicCollateralTwoDBlackStruct.collateralBlack;
Cblack  = dynamicCollateralTwoDBlackStruct.collateralBlackErrors;
rows    = dynamicCollateralTwoDBlackStruct.collateralBlackRows;
cols    = dynamicCollateralTwoDBlackStruct.collateralBlackColumns;
type    = dynamicCollateralTwoDBlackStruct.collateralType;

blackIndicator  = type==1;
mSmearIndicator = type==2;
vSmearIndicator = type==3;
mBlackIndicator = type==4;
vBlackIndicator = type==5;

% extract row and column indices from inputs
blackRows     = rows(blackIndicator);
mSmearColumns = cols(mSmearIndicator);
vSmearColumns = cols(vSmearIndicator);

% extract which rows and columns were coadded and averaged in the inputs
blackColumns = calIntermediateStruct.blackColumnStart:calIntermediateStruct.blackColumnEnd;
mSmearRows   = calIntermediateStruct.mSmearRowStart:calIntermediateStruct.mSmearRowEnd;
vSmearRows   = calIntermediateStruct.vSmearRowStart:calIntermediateStruct.vSmearRowEnd;



% undo coadding and averaging by copying the mean value from the inputs into each of the pixels that were coaaded over orginally

% copy trailing black blacks and errors into output arrays
if any(blackIndicator)
    for c = blackColumns
        twoDBlackArray(blackRows,c) = black(blackIndicator,cadenceIndex);
        twoDBlackArrayUnc(blackRows,c) = Cblack(blackIndicator,cadenceIndex);
    end
end

% copy masked smear blacks and errors into output arrays
if any(mSmearIndicator)
    for r = mSmearRows
        twoDBlackArray(r,mSmearColumns) = black(mSmearIndicator,cadenceIndex);
        twoDBlackArrayUnc(r,mSmearColumns) = Cblack(mSmearIndicator,cadenceIndex);
    end
end

% copy virtual smear blacks and errors into output arrays
if any(vSmearIndicator)
    for r = vSmearRows
        twoDBlackArray(r,vSmearColumns) = black(vSmearIndicator,cadenceIndex);
        twoDBlackArrayUnc(r,vSmearColumns) = Cblack(vSmearIndicator,cadenceIndex);
    end
end

% copy masked blacks and errors into output arrays
if any(mBlackIndicator)
    for r = mSmearRows
        twoDBlackArray(r,blackColumns) = black(mBlackIndicator,cadenceIndex);
        twoDBlackArrayUnc(r,blackColumns) = Cblack(mBlackIndicator,cadenceIndex);
    end
end

% copy virtual blacks and errors into output arrays
if any(vBlackIndicator)
    for r = vSmearRows
        twoDBlackArray(r,blackColumns) = black(vBlackIndicator,cadenceIndex);
        twoDBlackArrayUnc(r,blackColumns) = Cblack(vBlackIndicator,cadenceIndex);
    end
end