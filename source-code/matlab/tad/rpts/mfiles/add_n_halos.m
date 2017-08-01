function [haloStellarApertures, haloPixelOffsets] = add_n_halos(nHaloRings, stellarApertures, ...
    ccdModule, ccdOutput, debugFlag)
%function [haloStellarApertures, haloPixelOffsets] = add_n_halos(nHaloRings, stellarApertures, ...
%   ccdModule, ccdOutput, debugFlag)
%
% function to add N buffer rings to the optimal aperture, where N is the input
% parameter nHaloRings.  For each row, an additional pixel is added to the left
% of the aperture pixels in order to calibrate the LDE undershoot properly.
% If nHaloRings = 0, then only the LHS pixels are added.
%
% INPUT
%             stellarApertures:   [struct array] consisting of the following fields:
%                     keplerId:   target star KIC id number
%                 referenceRow:   reference row on the module output for this aperture
%              referenceColumn:   reference column on the module output for this aperture
%                      offsets:   [struct array] consisting of the fields 'row' and 'column'
%                badPixelCount:   indices of bad pixels
%                   nHaloRings:   number of halo rings to add to optimal aperture
%
% OUTPUT
%         haloStellarApertures:   [struct array] new stellar apertures that include halo rings
%                                     consisting of the following field:
%                      offsets:   [struct array] consisting of the fields 'row' and 'column'
%                                     for each pixel in (stellar aperture + halo) aperture
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


close all;

set(gca, 'fontsize', 8);

% pre-allocate output struct arrays
haloStellarApertures = repmat(struct('offsets', []), 1, length(stellarApertures));
haloPixelOffsets = repmat(struct('offsets', []), 1, length(stellarApertures));

for j = 1:length(stellarApertures)

    % create aperture pixel image from the offsets data
    [aperture apertureCenter] = target_definition_to_image(stellarApertures(j));


    if (debugFlag >= 0)

        % plot stellar aperture logical image
        figure;
        imagesc(aperture)
        title(['Stellar aperture ' num2str(j) ',    Reference row/col: [' num2str(stellarApertures(j).referenceRow) ', ' num2str(stellarApertures(j).referenceColumn) '],    Logical center: ' mat2str(apertureCenter)]);
        xlabel('Columns');
        ylabel('Rows');

        fileNameStr = ['aperture_'  num2str(j) '_refRow' num2str(stellarApertures(j).referenceRow) '_refCol' num2str(stellarApertures(j).referenceColumn)];
        paperOrientationFlag = false;
        includeTimeFlag = false;
        printJpgFlag = false;

        plot_to_file(fileNameStr, paperOrientationFlag, includeTimeFlag, printJpgFlag);
        close all;
    end


    if (nHaloRings > 0)

        % create convolution kernel
        %haloKernel = [0,1,0;1,1,1;0,1,0];     % option 1 is a 3x3 cross shape
        haloKernel = [1,1,1;1,1,1;1,1,1];       % option 2 is a 3x3 square (more conservative)

        % incrementally add a 1 pixel buffer around the input aperture
        for k = 1:nHaloRings

            % convolve the aperture with halo
            nHaloAperture = conv2(haloKernel, aperture);

            aperture = nHaloAperture;
            apertureCenter = apertureCenter + 1;

            if (debugFlag >=  0)

                % plot stellar aperture logical image with halo
                figure;
                imagesc(aperture>0)
                title(['Stellar aperture ' num2str(j) '  with ' num2str(k) ' halo(s) added,    Reference row/col: [' num2str(stellarApertures(j).referenceRow) ', ' num2str(stellarApertures(j).referenceColumn) ']    New logical center: ' mat2str(apertureCenter)]);
                xlabel('Columns');
                ylabel('Rows');

                fileNameStr = ['aperture_'  num2str(j) '_with_' num2str(k) '_halos'];
                paperOrientationFlag = false;
                includeTimeFlag = false;
                printJpgFlag = false;

                plot_to_file(fileNameStr, paperOrientationFlag, includeTimeFlag, printJpgFlag);
                close all;
            end
        end
    end

    % save as logical array
    aperture = aperture > 0;

    % include a pixel to the immediate left of each aperture pixel for use
    % in correcting the lde undershoot
    apertureWithLeftColumn = [zeros(length(aperture(:, 1)), 1) aperture];

    apertureWithLeftPixAdded = [zeros(size(apertureWithLeftColumn,1), 1), aperture] | ...
        [aperture, zeros(size(apertureWithLeftColumn, 1), 1)];

    apertureCenter = [apertureCenter(1) apertureCenter(2)+1];

    % record the aperture center idx of convolved image and accounting for
    % left hand side pixels
    stellarRefRowNew = apertureCenter(1);
    stellarRefColNew = apertureCenter(2);

    if (debugFlag >= 0)

        % plot stellar aperture logical image with halos and LHS pixels
        figure;
        imagesc(apertureWithLeftPixAdded>0)
        title(['Stellar aperture ' num2str(j) ' with ' num2str(nHaloRings) ' halos and LHS pixels (for undershoot),    Reference row/col: [' num2str(stellarApertures(j).referenceRow) ', ' num2str(stellarApertures(j).referenceColumn) ']    New logical center: ' mat2str(apertureCenter) '    ']);
        xlabel('Columns');
        ylabel('Rows');

        fileNameStr = ['aperture_'  num2str(j) '_with_' num2str(k) '_halos_and_LHSpixels'];
        paperOrientationFlag = false;
        includeTimeFlag = false;
        printJpgFlag = false;

        plot_to_file(fileNameStr, paperOrientationFlag, includeTimeFlag, printJpgFlag);
        close all;
    end

    % convert aperture image to list of offsets with respect to apertureCenter
    haloStellarApertureDef = image_to_target_definition(apertureWithLeftPixAdded, apertureCenter);

    % save haloStellarApertures structure (with field 'offsets'), which
    % will be input into AMA along with the reference row/column
    haloStellarApertures(j) = haloStellarApertureDef;

    % create logical image of additional pixels added to target definition
    % (N halos and left hand side pixels) for validation
    haloImage = apertureWithLeftPixAdded;

    aperturePixelRows = stellarRefRowNew + [stellarApertures(j).offsets.row];
    aperturePixelCols = stellarRefColNew + [stellarApertures(j).offsets.column];

    apertureLinearIdx = sub2ind(size(haloImage), aperturePixelRows, aperturePixelCols);

    % exclude stellar aperture pixels
    haloImage(apertureLinearIdx) = false;

    % convert halo image to list of offsets
    haloPixelDefs = image_to_target_definition(haloImage, apertureCenter);
    haloPixelOffsets(j) = haloPixelDefs;


    % plot stellar aperture logical image with halos and LHS pixels
    if (debugFlag >= 0)
        figure;
        imagesc(haloImage>0)
        title([num2str(nHaloRings) ' halo(s) & LHS pixels added to stellar aperture ' num2str(j) ',    Reference row/col: [' num2str(stellarApertures(j).referenceRow) ', ' num2str(stellarApertures(j).referenceColumn) ']    Logical center: ' mat2str(apertureCenter)]);
        xlabel('Columns');
        ylabel('Rows');

        fileNameStr = ['aperture_'  num2str(j) '_halo_image'];
        paperOrientationFlag = false;
        includeTimeFlag = false;
        printJpgFlag = false;

        plot_to_file(fileNameStr, paperOrientationFlag, includeTimeFlag, printJpgFlag);
        close all;
    end
end
hold off;


%--------------------------------------------------------------------------
% save individual aperture figures to a local directory
%--------------------------------------------------------------------------
% create new directory with mod/out
newDirectory = ['figs_for_individual_apertures_mod' num2str(ccdModule) '_out' num2str(ccdOutput)];
eval(['mkdir ' newDirectory]);

% windows MATLAB doesn't recognize the unix mv command
%eval(['!mv cal_*.fig ', newDirectory]);
movefile('aperture_*.fig', newDirectory);

return;
