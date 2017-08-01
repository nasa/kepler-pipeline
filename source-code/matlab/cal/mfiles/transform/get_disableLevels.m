function [disableLevelMask, transformChain] = get_disableLevels(S, variableName)
%
% function [disableLevelMask, transformChain] = get_disableLevels(S, variableName)
%
% Get the disableLevel attribute for each of the transformations in the
% chain for variableName in errorPropStruct S and return in
% disableLevelMask. The chain of transformations expressed as a list of
% transformation types is returned in transformChain
% 
% For transformation T, the base data (x) and covariance (Cx) are transformed
% into xnew and Cx new as follows, depending on the value of disableLevel:
%           disableLevel =  0 --> xnew = T*x, Cxnew = T*Cx*T'   (both x and Cx are transformed - none disabled)
%                           1 --> xnew = T*x, Cxnew = I*Cx      (only x is transformed - Cx disabled)
%                           2 --> xnew = I*x, Cxnew = T*Cx*T'   (only Cx is transformed - x disabled)
%                           3 --> xnew = I*x, Cxnew = I*Cx      (neither x or Cx are transformed - both disabled)%
%
% INPUT     S                   = errorPropStruct
%           variableName        = errorPropStruct variable to get the disableLevelMask for%
% OUTPUT    disableLevelMask    = mask generated from disableLevel for each
%                                 transform in chain. If list of transforms
%                                 is empty, [] is returned.
%           transformChain      = List of transform types in chain. If
%                                 there are no transforms in chain, {} is
%                                 returned.
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

varIndex = iserrorPropStructVariable(S, variableName);

if(varIndex)    
    numTransforms = length(S(varIndex).transformStructArray);
    
    if( numTransforms == 1 && isempty(S(varIndex).transformStructArray(1).transformType) )
        disableLevelMask = [];
        transformChain = {};
    else
        disableLevelMask = [S(varIndex).transformStructArray.disableLevel];
        disableLevelMask = disableLevelMask(:);
        transformChain = cell(numTransforms,1);
        [transformChain{:}] = deal(S(varIndex).transformStructArray.transformType);
    end
else
    disableLevelMask = [];
    transformChain = {};
end
