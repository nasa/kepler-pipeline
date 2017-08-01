function inputsStruct = convert_dynablack_inputs(inputsStruct)
% function inputsStruct = convert_dynablack_inputs(inputsStruct)
% 
% This function is used to change from zero-based indices used on the java side to one-based indices used on the MATLAB side.
% 
% INPUTS:   inputsStruct    = unmodified dynablack input structure
% OUTPUTS:  inputsStruct    = modified dynablack input structure
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


% return without validation if uow is invalid
if ~inputsStruct.validUow
    return;
end


% extract pixel zero-based row and column and add one
maskedSmearColumns = [inputsStruct.maskedSmearPixels.column] + 1;
virtualSmearColumns = [inputsStruct.virtualSmearPixels.column] + 1;
blackRows = [inputsStruct.blackPixels.row] + 1;

arpRows = [inputsStruct.arpTargetPixels.row] + 1;
arpColumns = [inputsStruct.arpTargetPixels.column] + 1;

backgroundRows = [inputsStruct.backgroundPixels.row] + 1;
backgroundColumns = [inputsStruct.backgroundPixels.column] + 1;

if inputsStruct.dynablackModuleParameters.reverseClockedEnabled
    rcMaskedSmearColumns = [inputsStruct.reverseClockedMaskedSmearPixels.column] + 1;
    rcVirtualSmearColumns = [inputsStruct.reverseClockedVirtualSmearPixels.column] + 1;
    rcBlackRows = [inputsStruct.reverseClockedBlackPixels.row] + 1;
    
    rcBackgroundRows = [inputsStruct.reverseClockedBackgroundPixels.row] + 1;
    rcBackgroundColumns = [inputsStruct.reverseClockedBackgroundPixels.column] + 1;
    
    rcTargetRows = [inputsStruct.reverseClockedTargetPixels.row] + 1;
    rcTargetColumns = [inputsStruct.reverseClockedTargetPixels.column] + 1;
end

% read back into inputs
for i = 1:length(maskedSmearColumns)
    inputsStruct.maskedSmearPixels(i).column = maskedSmearColumns(i);
end
for i = 1:length(virtualSmearColumns)
    inputsStruct.virtualSmearPixels(i).column = virtualSmearColumns(i);
end
for i = 1:length(blackRows)
    inputsStruct.blackPixels(i).row = blackRows(i);
end

for i = 1:length(arpRows)
    inputsStruct.arpTargetPixels(i).row = arpRows(i);
end
for i = 1:length(arpColumns)
    inputsStruct.arpTargetPixels(i).column = arpColumns(i);
end

for i = 1:length(backgroundRows)
    inputsStruct.backgroundPixels(i).row = backgroundRows(i);
end
for i = 1:length(backgroundColumns)
    inputsStruct.backgroundPixels(i).column = backgroundColumns(i);
end

% conditionally read back into inputs if reverse clocked data is available
if inputsStruct.dynablackModuleParameters.reverseClockedEnabled
    for i = 1:length(rcMaskedSmearColumns)
        inputsStruct.reverseClockedMaskedSmearPixels(i).column = rcMaskedSmearColumns(i);
    end
    for i = 1:length(rcVirtualSmearColumns)
        inputsStruct.reverseClockedVirtualSmearPixels(i).column = rcVirtualSmearColumns(i);
    end
    for i = 1:length(rcBlackRows)
        inputsStruct.reverseClockedBlackPixels(i).row = rcBlackRows(i);
    end
    
    for i = 1:length(rcBackgroundRows)
        inputsStruct.reverseClockedBackgroundPixels(i).row = rcBackgroundRows(i);
    end
    for i = 1:length(rcBackgroundColumns)
        inputsStruct.reverseClockedBackgroundPixels(i).column = rcBackgroundColumns(i);
    end
    
    for i = 1:length(rcTargetRows)
        inputsStruct.reverseClockedTargetPixels(i).row = rcTargetRows(i);
    end
    for i = 1:length(rcTargetColumns)
        inputsStruct.reverseClockedTargetPixels(i).column = rcTargetColumns(i);
    end
end


