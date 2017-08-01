function  s = subtract_black2DModel_from_pixels(s, cadenceIndex, currentModOut)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function  s = subtract_black2DModel_from_pixels(s, cadenceIndex, currentModOut)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Description:
% Corrects target, background, smear, and black pixels for 2D black level
%
% 2d black structure is present across all mod outs  from the FGS clocking
% cross talk and indicates the deviation from normal when FGS clocks are
% running
% subtract 2D black model
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

numberOfExposuresPerLongCadence = s.configMapStruct.numberOfExposuresPerLongCadence(cadenceIndex);

requantizationTableFixedOffset  = s.requantTableStruct.requantizationTableFixedOffset(cadenceIndex);
meanBlackFromTable              = s.requantTableStruct.meanBlackEntries(currentModOut,cadenceIndex);
% need the mod out
meanBlackFromTable              = meanBlackFromTable * numberOfExposuresPerLongCadence;

% currentModOut                   = s.currentModOut;

% turning off warnings about negative pixels after 2D black subtraction as
% they can be negative due to undershoot/overshoot artifact


%--------------------------------------------------------------------------
% black2DObject contains black2D values for all the rows, columns of all
% the pixels (collateral + target + background)
%--------------------------------------------------------------------------
black2DForBlackPixels   = get_two_d_black(s.black2DObject, s.cadenceTimes(cadenceIndex),s.blackRows,s.blackColumns);

% these black2D values are per read out; scale it up by number of exposures
% (from SC config map) to get the black 2D values for a long cadence

black2DForBlackPixels = black2DForBlackPixels * numberOfExposuresPerLongCadence;

validBlackPixelIndices = find(~s.blackGapIndicators(:,cadenceIndex));


if(~isempty(validBlackPixelIndices))

    s.blackPixels(validBlackPixelIndices, cadenceIndex) = s.blackPixels(validBlackPixelIndices, cadenceIndex) - ...
        black2DForBlackPixels(validBlackPixelIndices) - requantizationTableFixedOffset + meanBlackFromTable;

%     if(~isempty (find(s.blackPixels(validBlackPixelIndices, cadenceIndex) <= 0, 1, 'first')))
%         warning('PDQ:subtract_black2DModel_from_pixels:NegativeValues', ...
%             ['subtract_black2DModel_from_pixels: black pixels becoming negative after 2D black subtraction for cadence ' num2str(cadenceIndex) ' for modout ' num2str(currentModOut)]);
%     end


end

%--------------------------------------------------------------------------
% subtract black 2D from target pixels
%--------------------------------------------------------------------------

black2DForTargetPixels   = get_two_d_black(s.black2DObject, s.cadenceTimes(cadenceIndex),s.targetPixelRows,s.targetPixelColumns);

black2DForTargetPixels = black2DForTargetPixels * numberOfExposuresPerLongCadence;



validTargetPixelIndices = find(~s.targetGapIndicators(:,cadenceIndex));

if(~isempty(validTargetPixelIndices))

    s.targetPixels(validTargetPixelIndices, cadenceIndex) = s.targetPixels(validTargetPixelIndices, cadenceIndex) - ...
        black2DForTargetPixels(validTargetPixelIndices) - requantizationTableFixedOffset + meanBlackFromTable;

%     if(~isempty (find(s.targetPixels(validTargetPixelIndices, cadenceIndex) <= 0, 1, 'first')))
%         warning('PDQ:subtract_black2DModel_from_pixels:NegativeValues', ...
%             ['subtract_black2DModel_from_pixels: target pixels becoming negative after 2D black subtraction for cadence ' num2str(cadenceIndex) ' for modout ' num2str(currentModOut)]);
%     end
end

%--------------------------------------------------------------------------
% subtract black 2D from background pixels
%--------------------------------------------------------------------------
black2DForBkgdPixels   = get_two_d_black(s.black2DObject, s.cadenceTimes(cadenceIndex),s.bkgdPixelRows,s.bkgdPixelColumns);

black2DForBkgdPixels = black2DForBkgdPixels * numberOfExposuresPerLongCadence;


% Correct background reference pixels for black level
validBkgdPixelIndices = find(~s.bkgdGapIndicators(:,cadenceIndex));

if(~isempty(validBkgdPixelIndices))

    s.bkgdPixels(validBkgdPixelIndices, cadenceIndex) = s.bkgdPixels(validBkgdPixelIndices, cadenceIndex) - ...
        black2DForBkgdPixels(validBkgdPixelIndices) - requantizationTableFixedOffset + meanBlackFromTable;

%     if(~isempty (find(s.bkgdPixels(validBkgdPixelIndices, cadenceIndex) <= 0, 1, 'first')))
%         warning('PDQ:subtract_black2DModel_from_pixels:NegativeValues', ...
%             ['subtract_black2DModel_from_pixels: background pixels becoming negative after 2D black subtraction for cadence ' num2str(cadenceIndex) ' for modout ' num2str(currentModOut)]);
%     end

end

%--------------------------------------------------------------------------
% subtract black 2D from masked smear pixels
%--------------------------------------------------------------------------
black2DForMsmearPixels   = get_two_d_black(s.black2DObject, s.cadenceTimes(cadenceIndex),s.msmearRows,s.msmearColumns);

black2DForMsmearPixels = black2DForMsmearPixels * numberOfExposuresPerLongCadence;


validMsmearPixelIndices = find(~s.msmearGapIndicators(:,cadenceIndex));

if(~isempty(validMsmearPixelIndices))

    s.msmearPixels(validMsmearPixelIndices,cadenceIndex) = s.msmearPixels(validMsmearPixelIndices,cadenceIndex) - ...
        black2DForMsmearPixels(validMsmearPixelIndices)- requantizationTableFixedOffset + meanBlackFromTable;

%     if(~isempty (find(s.msmearPixels(validMsmearPixelIndices,cadenceIndex) <= 0, 1, 'first')))
%         warning('PDQ:subtract_black2DModel_from_pixels:NegativeValues', ...
%             ['subtract_black2DModel_from_pixels: masked smear pixels becoming negative after 2D black subtraction for cadence ' num2str(cadenceIndex) ' for modout ' num2str(currentModOut)]);
%     end
end

%--------------------------------------------------------------------------
% subtract black 2D from virtual smear pixels
%--------------------------------------------------------------------------
black2DForVsmearPixels   = get_two_d_black(s.black2DObject, s.cadenceTimes(cadenceIndex),s.vsmearRows,s.vsmearColumns);

black2DForVsmearPixels = black2DForVsmearPixels * numberOfExposuresPerLongCadence;

validVsmearPixelIndices = find(~s.vsmearGapIndicators(:,cadenceIndex));

if(~isempty(validVsmearPixelIndices))

    s.vsmearPixels(validVsmearPixelIndices,cadenceIndex) = s.vsmearPixels(validVsmearPixelIndices,cadenceIndex) - ...
        black2DForVsmearPixels(validVsmearPixelIndices)- requantizationTableFixedOffset + meanBlackFromTable;

%     if(~isempty (find(s.vsmearPixels(validVsmearPixelIndices,cadenceIndex)  <= 0, 1, 'first')))
%         warning('PDQ:subtract_black2DModel_from_pixels:NegativeValues', ...
%             ['subtract_black2DModel_from_pixels: virtual smear pixels becoming negative after 2D black subtraction for cadence ' num2str(cadenceIndex) ' for modout ' num2str(currentModOut)]);
%     end


end

%--------------------------------------------------------------------------
% copy black2D pixles for all types into s for propagation of uncertainties
%--------------------------------------------------------------------------

s.black2DForBlackPixels(:,cadenceIndex)         = black2DForBlackPixels;
s.black2DForTargetPixels(:,cadenceIndex)        = black2DForTargetPixels;
s.black2DForBkgdPixels(:,cadenceIndex)          = black2DForBkgdPixels;
s.black2DForMsmearPixels(:,cadenceIndex)        = black2DForMsmearPixels;
s.black2DForVsmearPixels(:,cadenceIndex)        = black2DForVsmearPixels;





return