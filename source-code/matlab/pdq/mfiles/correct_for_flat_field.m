function pdqTempStruct  = correct_for_flat_field( pdqTempStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function pdqTempStruct  = correct_for_flat_field( pdqTempStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Correct reference pixels and background pixels for flat field
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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

%--------------------------------------------------------------------------
% Step 0: collect data from pdqTempStruct
%--------------------------------------------------------------------------
targetPixelRows         = pdqTempStruct.targetPixelRows;
targetPixelColumns      = pdqTempStruct.targetPixelColumns;

targetPixels            = pdqTempStruct.targetPixels;
targetGapIndicators     = pdqTempStruct.targetGapIndicators;
cadenceTimes            = pdqTempStruct.cadenceTimes;

numCadences              = pdqTempStruct.numCadences;

% The dimensions of the return data is MxN, where M is the length of
% the input argument mjd, and N is the length of the rows/columns
% fields in the flatFieldObject (if the rows/cols args aren't specified)
% or the length of the rows/cols arguments (if the rows/cols args are
% specified).

targetFlatField         = get_flat_field(pdqTempStruct.flatFieldObject, cadenceTimes, targetPixelRows, targetPixelColumns);


if(size(targetFlatField,2) ~= 1)
    targetFlatField = targetFlatField';
end

pdqTempStruct.targetFlatField = targetFlatField; % one value for each target pixel extracted from flat field model


bkgdPixelRows           = pdqTempStruct.bkgdPixelRows;
bkgdPixelColumns        = pdqTempStruct.bkgdPixelColumns;

bkgdPixels              = pdqTempStruct.bkgdPixels;
bkgdGapIndicators       = pdqTempStruct.bkgdGapIndicators;



bkgdFlatField = get_flat_field(pdqTempStruct.flatFieldObject, cadenceTimes, bkgdPixelRows, bkgdPixelColumns);

if(size(bkgdFlatField,2) ~= 1)
    bkgdFlatField = bkgdFlatField';
end

pdqTempStruct.bkgdFlatField  = bkgdFlatField;





for cadenceIndex = 1 : numCadences

    if( any(targetFlatField(:,cadenceIndex) == 0) || any(bkgdFlatField(:,cadenceIndex) == 0))
        warning('PDQ:correct_for_flat_field:zeroFlatFieldFound', ...
            ['correct_for_flat_field: zero flat field value found; treating the pixel as bad and setting the gap indicators to true for cadence  ' num2str(numCadences) ]);
    end

    if(any(targetFlatField(:,cadenceIndex) > 2) || any(bkgdFlatField(:,cadenceIndex) > 2))
        warning('PDQ:correct_for_flat_field:largeFlatFieldFound', ...
            ['correct_for_flat_field: flat field value > 2 found for cadence  ' num2str(numCadences) ]);
    end


    targetGapIndexForZeroFlatField = find(targetFlatField(:,cadenceIndex) == 0);
    %    targetGapIndexForLargeFlatField = find(targetFlatField(:,cadenceIndex) > 2);


    bkgdGapIndexForZeroFlatField = find(bkgdFlatField(:,cadenceIndex) == 0);
    %    bkgdGapIndexForLargeFlatField = find(bkgdFlatField(:,cadenceIndex) > 2);

    %     targetGapIndex = [targetGapIndexForZeroFlatField targetGapIndexForLargeFlatField];
    %     bkgdGapIndex =  [bkgdGapIndexForZeroFlatField bkgdGapIndexForLargeFlatField];


    targetGapIndex = targetGapIndexForZeroFlatField;
    bkgdGapIndex =   bkgdGapIndexForZeroFlatField;


    if(~isempty(targetGapIndex))
        targetGapIndicators(targetGapIndex, cadenceIndex) = true;
    end

    if(~isempty(bkgdGapIndex))
        bkgdGapIndicators(bkgdGapIndex, cadenceIndex) = true;
    end

end



% question: will flat field have uncertainties associated with it? errors
% associated with the measurement of flat fields are biases and don't
% participate in the propagation of uncertainties


%--------------------------------------------------------------------------
% Step 1: apply flat field correction
%--------------------------------------------------------------------------

for cadenceIndex = 1 : numCadences

    % the gap indicators might be different from the original data gap
    % indictaors as we might have added to this list based on the
    % availablity of smear pixels to do smear correction

    validTargetPixelIndices = find(~targetGapIndicators(:,cadenceIndex));
    if(~isempty(validTargetPixelIndices))

        targetPixels(validTargetPixelIndices,cadenceIndex) = targetPixels(validTargetPixelIndices,cadenceIndex) ./ targetFlatField(validTargetPixelIndices,cadenceIndex );

    end

    % Correct background reference pixels for black level
    validBkgdPixelIndices = find(~bkgdGapIndicators(:,cadenceIndex));

    if(~isempty(validBkgdPixelIndices))

        bkgdPixels(validBkgdPixelIndices, cadenceIndex)   = bkgdPixels(validBkgdPixelIndices, cadenceIndex) ./ bkgdFlatField(validBkgdPixelIndices, cadenceIndex);

    end


end

%--------------------------------------------------------------------------
% Step 2: save correctd pixels back in the object
%--------------------------------------------------------------------------

% flat field corrected target pixels and background pixels

pdqTempStruct.targetPixels  = targetPixels;
pdqTempStruct.bkgdPixels    =  bkgdPixels;

pdqTempStruct.targetGapIndicators     = targetGapIndicators;
pdqTempStruct.bkgdGapIndicators       = bkgdGapIndicators;


pdqTempStruct.targetPixelsAfterFF  = targetPixels;
pdqTempStruct.bkgdPixelsAfterFF    = bkgdPixels;

return