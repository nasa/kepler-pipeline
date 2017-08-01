function pdqTempStruct = correct_for_undershoot(pdqTempStruct)

%--------------------------------------------------------------------------
% correct masked smear pixels for under/overshoot
%--------------------------------------------------------------------------
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

% smear pixels have already been black corrected, binned, and gain adjusted
msmearPixels = pdqTempStruct.binnedMsmearPixels;
msmearColumns = pdqTempStruct.binnedMsmearColumns;
msmearGapIndicators = pdqTempStruct.binnedMsmearGapIndicators;
undershootCoeffts = pdqTempStruct.undershootCoeffts;



module                      = pdqTempStruct.ccdModule;
output                      = pdqTempStruct.ccdOutput;
currentModOut               = pdqTempStruct.currentModOut;

nCadences = pdqTempStruct.numCadences;

nCcdColumns = pdqTempStruct.nCcdColumns;

ccdColumns = (1:nCcdColumns)';

if(pdqTempStruct.debugLevel) % one figure for all the cadences
    h = figure;
    set(gca, 'fontsize', 8);

    hold on;
end


for cadenceIndex = 1:nCadences


    validPixelIndicators = ~msmearGapIndicators(:, cadenceIndex);
    validPixels   = msmearPixels(validPixelIndicators, cadenceIndex);
    validColumns  = msmearColumns(validPixelIndicators);

    if (isempty(validPixels) || length(validPixels) < 2)
        warning('PDQ:correct_for_undershoot:NotEnoughValidData', ...
            ['Less than two valid masked smear pixels are available; cannot perform undershoot correction for cadence = ' num2str(cadenceIndex)]);

    else
        %--------------------------------------------------------------------------
        % reconstruct row to account for any spatial gaps, and interpolate
        %--------------------------------------------------------------------------
        interpColumns = max(min(ccdColumns, max(validColumns)), min(validColumns)); % this clips the columns to range of populated ones

        entireRowInterp = interp1(validColumns, validPixels, interpColumns, 'linear');


        %--------------------------------------------------------------------------
        % apply filter
        %--------------------------------------------------------------------------
        undershootCorrectedRow = filter(1, undershootCoeffts(:, cadenceIndex), entireRowInterp);
        undershootCorrectedRow = undershootCorrectedRow';

        % plotting every cadence seems to slow it down, so
        % temporarily plotting one cadence only
        if((pdqTempStruct.debugLevel)&& (cadenceIndex == 1))
            h1 = plot(entireRowInterp, 'b.');
            h2 = plot(undershootCorrectedRow, 'mo');
        end

        %--------------------------------------------------------------------------
        % save corrected pixels
        pdqTempStruct.binnedMsmearPixels(validPixelIndicators, cadenceIndex) = undershootCorrectedRow(validColumns);

        pdqTempStruct.undershootCorrectedMsmearPixels(validPixelIndicators, cadenceIndex) = ...
            undershootCorrectedRow(validColumns);

    end
end

%--------------------------------------------------------------------------
% calibrate virtual smear pixels for under/overshoot
%--------------------------------------------------------------------------


% smear pixels have already been black corrected, binned, and gain adjusted
vsmearPixels = pdqTempStruct.binnedVsmearPixels;
vSmearColumns = pdqTempStruct.binnedVsmearColumns;
vsmearGapIndicators = pdqTempStruct.binnedVsmearGapIndicators;

for cadenceIndex = 1:nCadences



    validPixelIndicators = ~vsmearGapIndicators(:, cadenceIndex);

    validPixels  = vsmearPixels(validPixelIndicators, cadenceIndex);
    validColumns = vSmearColumns(validPixelIndicators);

    if (isempty(validPixels) || length(validPixels) < 2)
        warning('PDQ:correct_for_undershoot:NotEnoughValidData', ...
            ['Less than two valid virtual smear pixels are available; cannot perform undershoot correction for cadence = ' num2str(cadenceIndex)]);

    else
        %--------------------------------------------------------------------------
        % reconstruct row to account for any spatial gaps, and interpolate
        %--------------------------------------------------------------------------
        interpColumns = max(min(ccdColumns, max(validColumns)), min(validColumns)); % this clips the columns to range of populated ones

        entireRowInterp = interp1(validColumns, validPixels, interpColumns, 'linear');



        %--------------------------------------------------------------------------
        % apply filter
        %--------------------------------------------------------------------------
        undershootCorrectedRow = filter(1, undershootCoeffts(:, cadenceIndex), entireRowInterp);
        undershootCorrectedRow = undershootCorrectedRow';

        % plotting every cadence seems to slow it down, so
        % temporarily plotting one cadence only
        if((pdqTempStruct.debugLevel)&& (cadenceIndex == 1))
            h1 = plot(entireRowInterp, 'b.');
            h2 = plot(undershootCorrectedRow, 'mo');
        end

        %--------------------------------------------------------------------------
        % save corrected pixels
        pdqTempStruct.binnedVsmearPixels(validPixelIndicators, cadenceIndex) = undershootCorrectedRow(validColumns);

        pdqTempStruct.undershootCorrectedVsmearPixels(validPixelIndicators, cadenceIndex) = ...
            undershootCorrectedRow(validColumns);
    end
end

%--------------------------------------------------------------------------
% calibrate target pixels for under/overshoot
%--------------------------------------------------------------------------

targetPixels            = pdqTempStruct.targetPixels;
targetPixelColumns      = pdqTempStruct.targetPixelColumns;
targetPixelRows         = pdqTempStruct.targetPixelRows;
targetGapIndicators     = pdqTempStruct.targetGapIndicators;


bkgdPixels              = pdqTempStruct.bkgdPixels;
bkgdPixelColumns        = pdqTempStruct.bkgdPixelColumns;
bkgdPixelRows           = pdqTempStruct.bkgdPixelRows;
bkgdGapIndicators       = pdqTempStruct.bkgdGapIndicators;


nTargetPixels = length(targetPixelColumns);


photometricPixels = [targetPixels;bkgdPixels];

photometricRows = [targetPixelRows; bkgdPixelRows];

photometricColumns = [targetPixelColumns; bkgdPixelColumns];

photometricGaps = [targetGapIndicators; bkgdGapIndicators];


rowsNotCorrected = -1*ones(nTargetPixels, nCadences);


for cadenceIndex = 1:nCadences

    validPixelIndicators = ~photometricGaps(:, cadenceIndex);

    pixelValuesToCorrect = photometricPixels(validPixelIndicators, cadenceIndex);


    if (isempty(pixelValuesToCorrect) || length(pixelValuesToCorrect) < 2)
        warning('PDQ:correct_for_undershoot:NoValidData', ...
            ['There are not any or enough available pixels for undershoot correction for cadence = ' num2str(cadenceIndex)]);
    else

        pixelRowsToCorrect = photometricRows(validPixelIndicators);
        pixelColumnsToCorrect = photometricColumns(validPixelIndicators);

        uniqueValidRows = unique(pixelRowsToCorrect(:, 1));
        numValidRows = length(uniqueValidRows);


        % loop over unique rows
        for rowIndex = 1:numValidRows                    % ex. 141 unique rows

            pixelRow = uniqueValidRows(rowIndex);

            pixelValuesInRow = pixelValuesToCorrect(pixelRowsToCorrect == pixelRow);

            % check to ensure there are enough pixels in row for interpolation
            if (~isempty(pixelValuesInRow) && length(pixelValuesInRow) >= 2)

                pixelCols = pixelColumnsToCorrect(pixelRowsToCorrect == pixelRow);

                [uniquePixelCols, indexIntoPixelCols] =  unique(pixelCols);

                interpColumns = max(min(ccdColumns, max(uniquePixelCols)), min(uniquePixelCols)); %#ok<UDIM> % this clips the columns to range of populated ones

                interpColumns = interpColumns(:);

                entireRowInterp = interp1(uniquePixelCols, pixelValuesInRow(indexIntoPixelCols), interpColumns, 'linear');


                % apply undershoot correction filter to row
                undershootCorrectedRow = filter(1, undershootCoeffts(:, cadenceIndex), entireRowInterp);  % 1132 x 1

                % plotting every cadence seems to slow it down, so
                % temporarily plotting one cadence only
                if((pdqTempStruct.debugLevel)&& (cadenceIndex == 1))
                    h1 = plot(entireRowInterp, 'b.');
                    h2 = plot(undershootCorrectedRow, 'mo');
                end

                % save the undershoot corrected pixels
                correctedPixelValues = undershootCorrectedRow(pixelCols);

                pixelValuesToCorrect(pixelRowsToCorrect == pixelRow) = correctedPixelValues;
            else

                rowsNotCorrected(rowIndex, cadenceIndex) = pixelRow;

            end
        end

        % save all corrected pixels for this cadence
        photometricPixels(validPixelIndicators, cadenceIndex) = pixelValuesToCorrect;


    end
end

rowsNotCorrected = rowsNotCorrected(rowsNotCorrected ~= -1);
rowsNotCorrected = unique(rowsNotCorrected);
if(~isempty(rowsNotCorrected))

    warning('PDQ:correct_for_undershoot:NoValidData', ...
        ['These row(s) not corrected for undershoot due to insufficient number of pixels  ' num2str(rowsNotCorrected(:)')]);
end


if(pdqTempStruct.debugLevel && exist('h1','var')) % RLM 2/17/11 -- added '&& exist('h1','var')'

    %legend([h1 h2], {'interpolated row'; 'undershoot corrected row';}, 0);
    warning off all;
    legend([h1 h2], {'interpolated row'; 'undershoot corrected row';}, 'Location', 'Best');
    warning on all;

    xlabel('column number');
    ylabel('pixel values in photoelectrons');
    title(['Undershoot correction for module ' num2str(module) ' output ', num2str(output), ' modout '  num2str(currentModOut) ]);
    drawnow
    fileNameStr = ['undershoot correction_module_'  num2str(module) '_output_', num2str(output)  '_modout_' num2str(currentModOut) ];
    paperOrientationFlag = false;
    includeTimeFlag = false;
    printJpgFlag = false;

    % add figure caption as user data
    plotCaption = strcat(...
        'In this plot, undershoot corrected reference pixels are plotted along with the  \n',...
        'interpolated pixels (prior to undershoot correction). \n',...
        'Click on the link to open the figure in Matlab to examine the pixels closely. \n');

    set(h, 'UserData', sprintf(plotCaption));

    plot_to_file(fileNameStr, paperOrientationFlag, includeTimeFlag, printJpgFlag);
end





% save to intermediate struct
pdqTempStruct.targetPixelsUndershootCorrected = photometricPixels(1:nTargetPixels,:);
pdqTempStruct.bkgdPixelsUndershootCorrected = photometricPixels(nTargetPixels+1:end,:);

pdqTempStruct.targetPixels = photometricPixels(1:nTargetPixels,:);
pdqTempStruct.bkgdPixels = photometricPixels(nTargetPixels+1:end,:);

return

