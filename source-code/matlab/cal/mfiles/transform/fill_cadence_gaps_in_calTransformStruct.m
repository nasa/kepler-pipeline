function calTransformStruct = fill_cadence_gaps_in_calTransformStruct(calTransformStruct)
%
% function calTransformStruct = fill_cadence_gaps_in_calTransformStruct(calTransformStruct)
% 
% Check across cadences for gaps in the calTransformStruct (a 2D array of
% errorPropStruct - column == variable index, row == cadence) by examining
% the cadenceGapped and cadenceGapFilled flags at the root level of each
% calTransformStruct element. A gap for variable index i at cadence j will
% appear as:
%           calTransformStruct(i,j).cadenceGapped = true;
%           calTransformStruct(i,j).cadenceGapFilled = false;
% 
% Fill these data gaps with nearest neighbor (in cadence) errorPropStruct
% and set the cadence gap filled flag to true.
%
% INPUT:    calTransformStruct  = 2D array of structs of type errorPropStruct. Must be uncompressed and maximized.
% OUTPUT:   calTransformStruct  = Same errorPropStruct array as input with gaps filled across cadences
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


% generate list of all variable names
[~, variableList] = iserrorPropStructVariable(calTransformStruct(:,1),'');

% step through variable names looking for gaps
for i=1:length(variableList)
    
    cadenceGaps = [calTransformStruct(i,:).cadenceGapped];
    filledGaps = [calTransformStruct(i,:).cadenceGapFilled];
    
    if any(cadenceGaps & ~filledGaps)
        
        missingCadences = find(cadenceGaps & ~filledGaps);
        availableCadences = find(~(cadenceGaps & ~filledGaps));
        
        for j=1:length(missingCadences)
            
            % find the nearest filled cadence
            [~, minIndex] = min(abs(availableCadences - missingCadences(j)));
            nearestAvailableCadence = availableCadences(minIndex);
            
            % overwrite the missing one with the nearest valid one
            calTransformStruct(i,missingCadences(j)) = calTransformStruct(i,nearestAvailableCadence);
            
            % reset the cadence gapflags since the original calTransformStruct entry was overwritten
            calTransformStruct(i,missingCadences(j)).cadenceGapped = true;
            
            % set the gapFilled flag since it has been filled
            calTransformStruct(i,missingCadences(j)).cadenceGapFilled = true;
            
        end
    end
end
