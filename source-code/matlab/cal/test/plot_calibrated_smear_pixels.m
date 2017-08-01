function plot_calibrated_smear_pixels(calIntermediateStruct)
%function plot_calibrated_smear_pixels(calIntermediateStruct)
%
% function to plot the calibrated masked and virtual smear pixels, which
% have been corrected for fixed offset, mean black, #spatial coadds, 2D
% black, black residiual correction, and possibly (depending on which flags
% are enabled in the CAL inputs) nonlinearity, gain, undershoot, and cosmic rays.
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
close all;

calibratedMsmear = [calIntermediateStruct.calibratedMaskedSmear.values];
calibratedVsmear = [calIntermediateStruct.calibratedVirtualSmear.values];

if (~isempty(calibratedMsmear) && ~isempty(calibratedVsmear))

    calibratedMgaps = [calIntermediateStruct.calibratedMaskedSmear.gapIndicators];
    calibratedVgaps = [calIntermediateStruct.calibratedVirtualSmear.gapIndicators];

    % find valid pixel indices:
    validMsmearPixelIndicators = ~calibratedMgaps;
    validVsmearPixelIndicators = ~calibratedVgaps;

    %----------------------------------------------------------------------
    % plot smear pixel values
    figure
    subplot(2,1,1);
    plot(msmearPosition(validMsmearPixelIndicators),...
        calibratedMsmear(validMsmearPixelIndicators), 'ro');

    grid on
    xlabel('Column Index');
    ylabel('Flux (photoelectrons)');
    hold on

    plot(vsmearPosition(validVsmearPixelIndicators),...
        calibratedVsmear(validVsmearPixelIndicators), 'b+');
    title('[CAL] Calibrated masked (red) and virtual smear (blue) pixels');

    %--------------------------------------------------------------------------
    % plot standard deviation of smear pixels
    subplot(2,1,2);
    plot(msmearPosition(validMsmearPixelIndicators),...
        std(calibratedMsmear(validMsmearPixelIndicators), 0, 2), 'ro');

    grid on
    xlabel('Column Index');
    ylabel('std(Flux) (photoelectrons)');
    hold on

    plot(vsmearPosition(validVsmearPixelIndicators),...
        std(calibratedVsmear(validVsmearPixelIndicators), 0 , 2), 'b+');
    title('Standard deviation of calibrated masked (red) and virtual (blue) smear pixels');

    plot_to_file('cal_calibrated_smear_pixels', isLandscapeOrientation);    
end

close all;

return;
