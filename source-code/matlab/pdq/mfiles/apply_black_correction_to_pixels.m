function  s = apply_black_correction_to_pixels(s, cadenceIndex)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function  s = apply_black_correction_to_pixels(s, cadenceIndex)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This function corrects target pixels, background pixels , the binned and
% the raw virtual smear and masked smear pixels for black level.
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

% currentModOut = s.currentModOut;

% turning off warnings about negative pixels after 2D black subtraction as
% they can be negative due to undershoot/overshoot artifact



% Correct target reference pixels for black level
validTargetPixelIndices = find(~s.targetGapIndicators(:,cadenceIndex));

if(~isempty(validTargetPixelIndices))

    s.targetPixels(validTargetPixelIndices, cadenceIndex) = s.targetPixels(validTargetPixelIndices, cadenceIndex) - ...
        s.blackCorrection(s.targetPixelRows(validTargetPixelIndices), cadenceIndex);

    %     if(~isempty (find(s.targetPixels(validTargetPixelIndices, cadenceIndex) <= 0, 1, 'first')))
    %         warning('PDQ:apply_black_correction_to_pixels:NegativeValues', ...
    %             ['apply_black_correction_to_pixels: target pixels becoming negative after black correction for ' num2str(cadenceIndex) ' for modout ' num2str(currentModOut)]);
    %     end

end

% Correct background reference pixels for black level
validBkgdPixelIndices = find(~s.bkgdGapIndicators(:,cadenceIndex));

if(~isempty(validBkgdPixelIndices))

    s.bkgdPixels(validBkgdPixelIndices, cadenceIndex) = s.bkgdPixels(validBkgdPixelIndices,cadenceIndex) - ...
        s.blackCorrection(s.bkgdPixelRows(validBkgdPixelIndices), cadenceIndex);

    %     if(~isempty (find(s.bkgdPixels(validBkgdPixelIndices, cadenceIndex) <= 0, 1, 'first')))
    %         warning('PDQ:apply_black_correction_to_pixels:NegativeValues', ...
    %             ['apply_black_correction_to_pixels: background pixels becoming negative after black correction for ' num2str(cadenceIndex) ' for modout ' num2str(currentModOut)]);
    %     end

end



% Correct binned masked smear and binned virtual smear pixels for black level
validMsmearPixelIndices = find(~s.binnedMsmearGapIndicators(:,cadenceIndex));

if(~isempty(validMsmearPixelIndices))

    s.binnedMsmearPixels(validMsmearPixelIndices, cadenceIndex) = s.binnedMsmearPixels(validMsmearPixelIndices, cadenceIndex) - ...
        s.blackCorrection(s.binnedMsmearRow(cadenceIndex), cadenceIndex);

    %     if(~isempty (find(s.binnedMsmearPixels(validMsmearPixelIndices,cadenceIndex) <= 0, 1, 'first')))
    %         warning('PDQ:apply_black_correction_to_pixels:NegativeValues', ...
    %             ['apply_black_correction_to_pixels: masked smear pixels becoming negative after black correction for ' num2str(cadenceIndex) ' for modout ' num2str(currentModOut)]);
    %     end

end

% Correct virtual smear pixels for black level
validVsmearPixelIndices = find(~s.binnedVsmearGapIndicators(:,cadenceIndex));

if(~isempty(validVsmearPixelIndices))

    s.binnedVsmearPixels(validVsmearPixelIndices,cadenceIndex) = s.binnedVsmearPixels(validVsmearPixelIndices,cadenceIndex) - ...
        s.blackCorrection(s.binnedVsmearRow(cadenceIndex), cadenceIndex);

    %     if(~isempty (find(s.binnedVsmearPixels(validVsmearPixelIndices,cadenceIndex)  <= 0, 1, 'first')))
    %         warning('PDQ:apply_black_correction_to_pixels:NegativeValues', ...
    %             ['apply_black_correction_to_pixels: virtual smear pixels becoming negative after black correction for ' num2str(cadenceIndex) ' for modout ' num2str(currentModOut)]);
    %     end

end


%--------------------------------------------------------------------------
% apply black correction to unbinned msmear and vsmear pixels as well and
% preserve for estimation of shot noise which will feed into deltaRawMsmear
% and deltaRawVsmear
%--------------------------------------------------------------------------



% Correct original (unbinned) masked smear and virtual smear pixels for black level
validMsmearPixelIndices = find(~s.msmearGapIndicators(:,cadenceIndex));

if(~isempty(validMsmearPixelIndices))

    s.msmearPixels(validMsmearPixelIndices, cadenceIndex) = s.msmearPixels(validMsmearPixelIndices, cadenceIndex) - ...
        s.blackCorrection(s.msmearRows(validMsmearPixelIndices), cadenceIndex);

    %     if(~isempty (find(s.msmearPixels(validMsmearPixelIndices,cadenceIndex) <= 0, 1, 'first')))
    %         warning('PDQ:apply_black_correction_to_pixels:NegativeValues', ...
    %             ['apply_black_correction_to_pixels: masked smear pixels becoming negative after black correction for ' num2str(cadenceIndex) ' for modout ' num2str(currentModOut)]);
    %     end

end

% Correct virtual smear pixels for black level
validVsmearPixelIndices = find(~s.vsmearGapIndicators(:,cadenceIndex));

if(~isempty(validVsmearPixelIndices))

    s.vsmearPixels(validVsmearPixelIndices,cadenceIndex) = s.vsmearPixels(validVsmearPixelIndices,cadenceIndex) - ...
        s.blackCorrection(s.vsmearRows(validVsmearPixelIndices), cadenceIndex);

    %     if(~isempty (find(s.vsmearPixels(validVsmearPixelIndices,cadenceIndex)  <= 0, 1, 'first')))
    %         warning('PDQ:apply_black_correction_to_pixels:NegativeValues', ...
    %             ['apply_black_correction_to_pixels: virtual smear pixels becoming negative after black correction for ' num2str(cadenceIndex) ' for modout ' num2str(currentModOut)]);
    %     end

end

% preserve black corrected target and background pixels for propagation of
% uncertainties later....
s.targetPixelsBlackCorrected(:,cadenceIndex) = s.targetPixels(:,cadenceIndex);
s.bkgdPixelsBlackCorrected(:,cadenceIndex) = s.bkgdPixels(:,cadenceIndex);



return