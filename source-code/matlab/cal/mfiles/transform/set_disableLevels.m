function [S, resultFlag] = set_disableLevels(S, variableName, disableLevelMask)
%
% function [S, resultFlag] = set_disableLevels(S, variableName, disableLevelMask)
%
% Set the disableLevel in the chain of transformations stored in errorPropStruct S for variableName.
% 
% For transformation T, the base data (x) and covariance (Cx) are transformed
% into xnew and Cx new as follows, depending on the value of disableLevel:
%           disableLevel =  0 --> xnew = T*x, Cxnew = T*Cx*T'   (both x and Cx are transformed - none disabled)
%                           1 --> xnew = T*x, Cxnew = I*Cx      (only x is transformed - Cx disabled)
%                           2 --> xnew = I*x, Cxnew = T*Cx*T'   (only Cx is transformed - x disabled)
%                           3 --> xnew = I*x, Cxnew = I*Cx      (neither x or Cx are transformed - both disabled)%
%
% INPUT     S                   = errorPropStruct
%           variableName        = errorPropStruct variable to set disable
%                                 transform mask
%
%           disableLevelMask    = vector containing transformation disable mask, one element for each transformation
%                                 in the chain. If disableLevelMask is a scalar, each transformation in chain
%                                 recieves the same disableLevel value. If the length is less than the number of
%                                 transformations, only the first len(disableLevelMask) transformation disable levels are set.
%
% OUTPUT    S                   = input struct with new mask installed
%           resultFlag          = Boolean. Set on successful mask set.
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
resultFlag = 0;
varIndex = iserrorPropStructVariable(S, variableName);

if(varIndex)
    
    numTransforms = length(S(varIndex).transformStructArray);
    numMask = length(disableLevelMask);
    
    if(numMask == 1)
        disableLevelMask = ones(numTransforms,1) .* disableLevelMask;
        numMask = numTransforms;
    else if (numMask > numTransforms)
            disableLevelMask = disableLevelMask(1:numTransforms);
        end
    end
    
    for i=1:min(numMask,numTransforms)
        S(varIndex).transformStructArray(i).disableLevel = disableLevelMask(i);
    end
    
    resultFlag = 1;
end
