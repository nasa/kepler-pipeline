function pdqTempStruct = correct_for_gain(pdqTempStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function pdqTempStruct = correct_for_gain(pdqTempStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This script converts pixel flux values which are in ADU or DN to
% photoelectrons by multiplying the flux values in ADU by the gain in
% photoelectrons per ADU. The gain value is obtained from FC gain model. 
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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

gains = pdqTempStruct.gainForAllCadencesAllModOuts(:,pdqTempStruct.currentModOut); % for all cadences in electrons per ADU


numCadences              = pdqTempStruct.numCadences;

targetPixels            = pdqTempStruct.targetPixels;
targetGapIndicators     = pdqTempStruct.targetGapIndicators;


bkgdPixels              = pdqTempStruct.bkgdPixels;
bkgdGapIndicators       = pdqTempStruct.bkgdGapIndicators;

% work only with binned msmear and vsmear values
msmearPixels            = pdqTempStruct.binnedMsmearPixels;
msmearGapIndicators     = pdqTempStruct.binnedMsmearGapIndicators;

vsmearPixels            = pdqTempStruct.binnedVsmearPixels;
vsmearGapIndicators     = pdqTempStruct.binnedVsmearGapIndicators;


% Read in gains from inputs
gains   = gains(end-numCadences+1 : end)';

for cadenceIndex = 1 : numCadences

    validTargetPixelIndices = find(~targetGapIndicators(:,cadenceIndex));

    if(~isempty(validTargetPixelIndices))
        cadenceIndexColumn = repmat(cadenceIndex, length(validTargetPixelIndices),1);
        targetPixels(validTargetPixelIndices, cadenceIndexColumn) = targetPixels(validTargetPixelIndices, cadenceIndexColumn)* gains(cadenceIndex);
    end

    validBkgdPixelIndices = find(~bkgdGapIndicators(:,cadenceIndex));
    if(~isempty(validBkgdPixelIndices))

        cadenceIndexColumn = repmat(cadenceIndex, length(validBkgdPixelIndices),1);
        bkgdPixels(validBkgdPixelIndices, cadenceIndexColumn) = bkgdPixels(validBkgdPixelIndices, cadenceIndexColumn) * gains(cadenceIndex);

    end
    
    
    validMsmearPixelIndices = find(~msmearGapIndicators(:,cadenceIndex));
    if(~isempty(validMsmearPixelIndices))

        cadenceIndexColumn = repmat(cadenceIndex, length(validMsmearPixelIndices),1);
        msmearPixels(validMsmearPixelIndices,cadenceIndexColumn) = msmearPixels(validMsmearPixelIndices,cadenceIndexColumn) * gains(cadenceIndex);
    end


    validVsmearPixelIndices = find(~vsmearGapIndicators(:,cadenceIndex));
    if(~isempty(validVsmearPixelIndices))

        cadenceIndexColumn = repmat(cadenceIndex, length(validVsmearPixelIndices),1);
        vsmearPixels(validVsmearPixelIndices,cadenceIndexColumn) = vsmearPixels(validVsmearPixelIndices,cadenceIndexColumn) * gains(cadenceIndex);
    end
    

end


pdqTempStruct.targetPixels          = targetPixels;
pdqTempStruct.bkgdPixels            = bkgdPixels;
pdqTempStruct.binnedMsmearPixels    = msmearPixels;
pdqTempStruct.binnedVsmearPixels    = vsmearPixels;

return
