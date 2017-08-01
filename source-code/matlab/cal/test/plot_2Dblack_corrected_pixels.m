function plot_2Dblack_corrected_pixels(calIntermediateStruct)
%
% function to plot the 2D black-corrected collateral pixels
%
%
% Note (7/12/10)
%   This function is no longer used in production (Pipeline) code.
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

isLandscapeOrientation = true;

% extract flag for short cadence data
processShortCadence = calIntermediateStruct.processShortCadence;

%--------------------------------------------------------------------------
% plot all available collateral pixel types corrected for black
%--------------------------------------------------------------------------
if (~isempty(calIntermediateStruct.blackPixels))

    blackPixels = calIntermediateStruct.blackPixels;
    blackGaps   = calIntermediateStruct.blackGaps;

    validBlack = full( blackPixels.*~blackGaps );
    validBlack(validBlack == 0) = NaN;

    %---------------------------------------------------------------------
    % plot black pixel values corrected for black
    figure
    subplot(2,1,1), plot(validBlack, 'g.');

    grid on
    title('[CAL] 2D Black-corrected black pixels');
    xlabel('Row Index');
    ylabel('Flux (ADU)');

    %---------------------------------------------------------------------
    % plot standard deviation of black pixels corrected for 2Dblack and
    % include raw pixel uncertainties (read noise + quantization noise, if
    % pixels are requantized)

    deltaRawBlack = [calIntermediateStruct.blackUncertaintyStruct.deltaRawBlack];  %1070 x nCadences
    validDeltaRawBlack = full( deltaRawBlack.*~blackGaps );
    validDeltaRawBlack(validDeltaRawBlack == 0) = NaN;

    subplot(2,1,2), plot(std_w_NaNs_2D(validBlack, 0, 2), 'b.')

    grid on
    hold on
    plot(validDeltaRawBlack, 'r.')

    title('Standard deviation of 2D black-corrected black pixels (blue) and raw black uncertainties (red)');
    xlabel('Row Index');
    ylabel('std(Flux) (ADU)');

    plot_to_file('cal_2Dblack_corrected_black', isLandscapeOrientation);
    clear validBlack validDeltaRawBlack
end


if (processShortCadence)

    if (~isempty(calIntermediateStruct.mBlackPixels))

        mBlackPixels = calIntermediateStruct.mBlackPixels;
        mBlackGaps = calIntermediateStruct.mBlackGaps;

        validMblack = full( mBlackPixels.*~mBlackGaps );
        validMblack(validMblack == 0) = NaN;

        %---------------------------------------------------------------------
        % plot masked black pixel values corrected for black
        figure
        plot(validMblack, 'g.');

        grid on
        title('[CAL] Masked black pixels corrected for 2D black');
        xlabel('Cadence Index');
        ylabel('Flux (ADU)');

        plot_to_file('cal_2Dblack_corrected_Mblack', isLandscapeOrientation);
        clear validMblack
    end

    if (~isempty(calIntermediateStruct.vBlackPixels))

        vBlackPixels = calIntermediateStruct.vBlackPixels;
        vBlackGaps = calIntermediateStruct.vBlackGaps;

        validVblack = full( vBlackPixels.*~vBlackGaps );
        validVblack(validVblack == 0) = NaN;

        %----------------------------------------------------------------------
        % plot virtual black pixel values corrected for black
        figure
        plot(validVblack, 'g.');

        grid on
        title('[CAL] Virtual black pixels corrected for 2D black');
        xlabel('Cadence Index');
        ylabel('Flux (ADU)');

        plot_to_file('cal_2Dblack_corrected_Vblack', isLandscapeOrientation);
        clear validVblack
    end
end

%--------------------------------------------------------------------------
% plot smear pixels
%--------------------------------------------------------------------------

if (~isempty(calIntermediateStruct.mSmearPixels) && ~isempty(calIntermediateStruct.vSmearPixels))

    mSmearPixels = calIntermediateStruct.mSmearPixels;
    mSmearGaps = calIntermediateStruct.mSmearGaps;

    vSmearPixels = calIntermediateStruct.vSmearPixels;
    vSmearGaps = calIntermediateStruct.vSmearGaps;

    validMsmear = full( mSmearPixels.*~mSmearGaps );
    validMsmear(validMsmear == 0) = NaN;

    validVsmear = full( vSmearPixels.*~vSmearGaps );
    validVsmear(validVsmear == 0) = NaN;

    %----------------------------------------------------------------------
    % plot smear pixel values corrected for 2D black

    figure
    subplot(2,1,1), plot(validMsmear, 'ro');

    grid on
    xlabel('Column Index');
    ylabel('Flux (ADU)');
    hold on

    plot(validVsmear, 'b+');
    title('[CAL] 2D Black-corrected masked smear (red) and virtual smear (blue) pixels');

    %--------------------------------------------------------------------------
    % plot standard deviation of smear pixels
    subplot(2,1,2), plot(std_w_NaNs_2D(validMsmear, 0, 2), 'r.');

    grid on
    xlabel('Column Index');
    ylabel('std(Flux) (ADU)');
    hold on

    plot(std_w_NaNs_2D(validVsmear, 0, 2), 'b.');
    title('Standard deviation of 2D black-corrected masked (red) and virtual (blue)');

    plot_to_file('cal_2Dblack_corrected_smear', isLandscapeOrientation);
    clear validMsmear validVsmear
end

close all;

return;
