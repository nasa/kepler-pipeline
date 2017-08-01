function [calObject, calIntermediateStruct, calTransformStruct] = ...
    correct_collateral_pix_black_level(calObject, calIntermediateStruct, calTransformStruct)
%function [calObject, calIntermediateStruct, calTransformStruct] = ...
%    correct_collateral_pix_black_level(calObject, calIntermediateStruct, calTransformStruct)
%
% This calClass method corrects black level for collateral pixel data for each cadence on a module/output. For each cadence, the following
% steps are performed: 
%
%   (1) Subtract either a static 2D black level (dynamic2DBlackEnabled = false) or a dynamic 2D black level(dynamic2DBlackEnabled = true)
%       from black, vsmear, and msmear (black is now 'black residual'). 
%
%   (2) If dynamic2DBlackEnabled = true, skip to step 4.
%       Choose a polynomial model order to fit black residual, collect terms for propagation of uncertainties OR perform fit to custom
%       two-exponential 1D black model depending on how flags are set.
%
%   (3) Subtract black correction from masked and virtual smear pixels for cadences with available black pixels.
%
%   (4) Correct for cosmic rays. 
%
%   (5) If dynamic2DBlackEnabled = true, skip to step 6.
%       Apply black correction to cadences with missing black pixels. If no black pixels are available for the first cadence, then fill the
%       structure with the data from the nearest cadence.
%
%   (6) Create figures of the black correction over the black pixels for diagnostics.
%
%   (7) Save black correction to matfile for photometric black correction.
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

% hard coded constants
TITLE_FONTSIZE = 14;
AXIS_LABEL_FONTSIZE = 12;
AXIS_NUMBER_FONTSIZE = 12;
LEGEND_FONTSIZE = 10;

% extract state file pathname
stateFilePath = calObject.localFilenames.stateFilePath;

% extract module/output for figure titles
ccdModule = calIntermediateStruct.ccdModule;
ccdOutput = calIntermediateStruct.ccdOutput;

% normalize data on plots to DN / read
numberOfExposures = calIntermediateStruct.numberOfExposures;

% extract black rows that are excluded in fit for 1D Black plots
[blackRowsToExcludeInFit, chargeInjectionRows, frameTransferRows] = get_black_rows_to_exclude_for_1D_black_fit(calObject);                  

% create strings for figure titles/filenames
cadenceType = calIntermediateStruct.dataFlags.cadenceType;
if strcmpi(cadenceType, 'long')
    cadenceTypeStringForPlot = 'LC';
elseif strcmpi(cadenceType, 'short')
    cadenceTypeStringForPlot = 'SC';
elseif strcmpi(cadenceType, 'ffi')
    cadenceTypeStringForPlot = 'FFI';
end

% extract data flags
processShortCadence     = calObject.dataFlags.processShortCadence;
processLongCadence      = calObject.dataFlags.processLongCadence;
processFFI              = calObject.dataFlags.processFFI;
dynamic2DBlackEnabled   = calObject.dataFlags.dynamic2DBlackEnabled;
performExpLc1DblackFit  = calObject.dataFlags.performExpLc1DblackFit;
performExpSc1DblackFit  = calObject.dataFlags.performExpSc1DblackFit;
crCorrectionEnabled     = calObject.moduleParametersStruct.crCorrectionEnabled;
pouEnabled              = calObject.pouModuleParametersStruct.pouEnabled;
isAvailableBlackPix     = calObject.dataFlags.isAvailableBlackPix;

% extract timestamp (mjds)
cadenceTimes    = calObject.cadenceTimes;
timestamp       = cadenceTimes.timestamp;
timestampGaps   = cadenceTimes.gapIndicators;

% extract number of cadences and missing cadences
nCadences = calIntermediateStruct.nCadences;
missingBlackCadences = calIntermediateStruct.missingBlackCadences;

%--------------------------------------------------------------------------
% allocate arrays to create 1D black diagnostic figures
%--------------------------------------------------------------------------
validTimestamps = find(~timestampGaps);

% select cadences near start/middle/end of cadence timestamps for figures
% for FFI or unit of work shorter than 20 cadences plot only first cadence
if processFFI || length(validTimestamps) < 20
    plot1DBlackCadenceArray = 1;
else
    plot1DBlackCadenceArray = [5; floor(length(validTimestamps)/2) ; length(validTimestamps)-5];
end

%--------------------------------------------------------------------------
% extract all 2D black pixels
%--------------------------------------------------------------------------
if dynamic2DBlackEnabled
    
    display('CAL:correct_collateral_pix_black_level: Applying dynamic 2D black correction to collateral pixels.');
    
    % retrieve spatially coadded  and averaged blacks for all cadences
    dynamicCollateralTwoDBlackStruct = retrieve_dynamic_2d_black_for_collateral_data(calObject);               
    
else
    
    display('CAL:correct_collateral_pix_black_level: Applying static 2D black correction to collateral pixels.');

    % extract 2D black model from cal object
    twoDBlackModel = calObject.twoDBlackModel;

    % create the 2D black object
    twoDBlackObject = twoDBlackClass(twoDBlackModel);

    clear twoDBlackModel
end


%--------------------------------------------------------------------------
% Step 1: subtract 2D black model from valid black and smear pixels
%--------------------------------------------------------------------------
lastDuration = 0;
tic

% perform black level corrections on a per cadence basis
for cadenceIndex = 1:nCadences
    
    if isempty(missingBlackCadences) || (~isempty(missingBlackCadences) && ~any(ismember(missingBlackCadences, cadenceIndex)))
        
        % get twoDBlack pixels for this cadence
        if dynamic2DBlackEnabled
            
            % build 2D array for this cadence; size(twoDBlackArray) = [1070, 1132]
            twoDBlackArray = build_two_d_black_collateral_for_cadence(calIntermediateStruct, dynamicCollateralTwoDBlackStruct, cadenceIndex);

        else
            
            % use static 2D black - retrieve full array using get method in twoDBlackClass; size = 1070x1132
            twoDBlackArray = get_two_d_black(twoDBlackObject, timestamp(cadenceIndex)); 
            
        end
        
        [calObject, calIntermediateStruct, calTransformStruct] = ...
            subtract_black2DModel_from_collateral_pixels(calObject, calIntermediateStruct, twoDBlackArray, cadenceIndex, calTransformStruct);
        
        duration = toc;
        if (duration > 10+lastDuration)
            lastDuration = duration;
            display(['CAL:correct_collateral_pix_black_level: 2D black correction applied for cadence ',...
                num2str(cadenceIndex) ', cumulative duration: ' num2str(duration/60, '%10.2f') ' minutes']);
        end
        
    else
        % set POU cadence gap flag for blackResidual, mSmearEstimate, vSmearEstimate
        if pouEnabled
            variableList = {'residualBlack','mSmearEstimate','vSmearEstimate'};
            calTransformStruct(:,cadenceIndex) = ...
                insert_POU_cadence_gaps(calTransformStruct(:,cadenceIndex), variableList);
            
            % set POU cadence gap flag for mBlackEstimate, vBlackEstimate, and fittedBlackBias
            if processShortCadence
                variableList = {'mBlackEstimate','vBlackEstimate','fittedBlackBias'};
                calTransformStruct(:,cadenceIndex) = ...
                    insert_POU_cadence_gaps(calTransformStruct(:,cadenceIndex), variableList);
            end
        end
    end
end




if ~dynamic2DBlackEnabled

    %--------------------------------------------------------------------------
    % Step 2: estimate 1D black correction and collect terms for propagation
    % of uncertainties.  Note the black residuals are saved to the outputs
    % (calibratedCollateralPixels.blackResidual), and the black-corrected
    % smear pixels are calibrated further.
    %--------------------------------------------------------------------------

    % default 1D black fit
    modelName = 'robust polynomial';

    % set up coeffs struct for new model
    if (processLongCadence && performExpLc1DblackFit)
        modelName = 'robust two-exponential';
        blackCorrectionStructLC = struct('timestamp', timestamp,...
            'gapIndicators', true(size(timestamp)),...
            'original',  zeros(nCadences, 6),...
            'originalCovariance',zeros(nCadences,6,6),...
            'smoothed',  zeros(nCadences, 6),...
            'smoothedCovariance', zeros(nCadences,6,6));

        % gap all cadences with missing black data
        blackCorrectionStructLC.gapIndicators(missingBlackCadences) = true;
    end

    if (processShortCadence && performExpSc1DblackFit)
        modelName = 'interpolated and scaled LC two-exponential + robust bias term';
        blackCorrectionStructSC = struct('timestamp', timestamp,...
            'gapIndicators', timestampGaps,...
            'original',  zeros(nCadences, 6),...
            'originalCovariance',zeros(nCadences,6,6),...
            'smoothed',  zeros(nCadences, 6),...
            'smoothedCovariance', zeros(nCadences,6,6));

        blackCorrectionStructSC.gapIndicators(missingBlackCadences) = true;

        % load blackCorrectionStructLC and interpolate coeffs and covariance on SC timestamps
        blackCorrectionStructLC = calObject.blackCorrectionStructLC;
        shortsPerLong = calIntermediateStruct.numberOfShortCadencesPerLong;
        blackCorrectionStructSC = ...
            get_black_correction_coeffs_for_sc(blackCorrectionStructLC, blackCorrectionStructSC, shortsPerLong);
    end


    display(['CAL:correct_collateral_pix_black_level: Fit 1D black to "',modelName,'" model...']);

    % initialize oneDBlackFitStruct
    calIntermediateStruct.oneDBlackFitStruct.overrideCoeffsUsed = false;

    lastDuration = 0;
    tic
    for cadenceIndex = 1:nCadences

        % if data is available, correct for 1D black
        if isempty(missingBlackCadences) || (~isempty(missingBlackCadences) && ...
                ~any(ismember(missingBlackCadences, cadenceIndex)))


            % check if original 1D black model should be used (same algorithms
            % apply to LC, SC, and FFIs)
            if (processLongCadence && ~performExpLc1DblackFit) || (processShortCadence && ~performExpSc1DblackFit)

                %----------------------------------------------------------------------
                % perform 1d black fit with original (v6.2) model
                %----------------------------------------------------------------------
                [calObject, calIntermediateStruct, calTransformStruct] = ...
                    fit_residual_black_with_poly_for_collateral(calObject, calIntermediateStruct, cadenceIndex, calTransformStruct);


            elseif (processLongCadence && performExpLc1DblackFit)

                %----------------------------------------------------------------------
                % perform 1d black fit with new (v7.0) model
                %----------------------------------------------------------------------
                [calObject, calIntermediateStruct, calTransformStruct] = ...
                    fit_lc_residual_black_with_ancillary_data(calObject, calIntermediateStruct, cadenceIndex, calTransformStruct);

                % extract 1D black fit coefficients and covariance
                if pouEnabled
                    [blackCoeffs, CblackCoeffs] = get_primitive_data(calTransformStruct(:,cadenceIndex),'fittedBlack');
                else
                    blackCoeffs  = calIntermediateStruct.blackUncertaintyStruct(cadenceIndex).bestPolyCoeffts;
                    CblackCoeffs = calIntermediateStruct.blackUncertaintyStruct(cadenceIndex).CblackPolyFit;
                end

                % update data structure
                blackCorrectionStructLC.original(cadenceIndex,:) = blackCoeffs;
                blackCorrectionStructLC.originalCovariance(cadenceIndex,:,:) = CblackCoeffs;
                blackCorrectionStructLC.gapIndicators(cadenceIndex) = false;


            elseif (processShortCadence && performExpSc1DblackFit)

                %----------------------------------------------------------------------
                % perform 1d black fit with new (v7.0) model
                %----------------------------------------------------------------------
                [calObject, calIntermediateStruct, calTransformStruct] = ...
                    fit_sc_residual_black_with_ancillary_data(calObject, calIntermediateStruct, ...
                    cadenceIndex, blackCorrectionStructSC, calTransformStruct);
            end


            %----------------------------------------------------------------------
            % Step 3: apply black correction to available collateral pixels
            %----------------------------------------------------------------------
            [calObject, calIntermediateStruct, calTransformStruct] = ...
                apply_black_correction_to_collateral_pixels(calObject, calIntermediateStruct, cadenceIndex, calTransformStruct);

            duration = toc;
            if (duration > 10+lastDuration)
                lastDuration = duration;
                display(['CAL:correct_collateral_pix_black_level: Black level correction applied for cadence ',...
                    num2str(cadenceIndex),', cumulative duration:  ',num2str(duration/60,'%10.2f'),' minutes']);
            end

        else

            % set POU cadence gap flag for fittedBlack, meanBlackmSmear, meanBlackvSmear
            if pouEnabled

                variableList = {'fittedBlack','meanBlackmSmear','meanBlackvSmear'};
                calTransformStruct(:,cadenceIndex) = ...
                    insert_POU_cadence_gaps(calTransformStruct(:,cadenceIndex), variableList);

                % set POU cadence gap flag for SC meanBlackmBlack, meanBlackvBlack
                if(processShortCadence)
                    variableList = {'meanBlackmBlack','meanBlackvBlack','fittedBlackBias'};
                    calTransformStruct(:,cadenceIndex) = ...
                        insert_POU_cadence_gaps(calTransformStruct(:,cadenceIndex), variableList);
                end
            end
        end
    end

    % smooth black correction coeffs and covariance and save for blob
    if processLongCadence && performExpLc1DblackFit && ~processFFI
        blackCorrectionStructLC = get_smoothed_black_coeffs(blackCorrectionStructLC);
        calIntermediateStruct.blackCorrectionStructLC = blackCorrectionStructLC;
    end
end


%----------------------------------------------------------------------
% find cosmic ray hits and compute metrics
%----------------------------------------------------------------------
if crCorrectionEnabled &&  nCadences > 1
    tic
    
    [calObject, calIntermediateStruct, numBlackCrEventsArray] = ...
        correct_black_pix_for_cosmic_rays(calObject, calIntermediateStruct);
    
    display_cal_status('CAL:correct_collateral_pix_black_level: Black pixels corrected for cosmic rays', 1);
    
    
    %--------------------------------------------------------------------------
    % plot cosmic ray corrected black pixels and display #hits detected
    %--------------------------------------------------------------------------
    if ~isempty(calIntermediateStruct.cosmicRayEvents.black)
        
        nBlackEvents = length([calIntermediateStruct.cosmicRayEvents.black.delta]);
        display(['CAL:correct_collateral_pix_black_level: Number of cosmic rays detected in black region: ' num2str(nBlackEvents) ]);
        plot_black_cosmic_ray_metrics(calIntermediateStruct, numBlackCrEventsArray);
    else
        display('CAL:correct_collateral_pix_black_level: No cosmic rays detected in black region');
    end
    
    if processShortCadence
        % display # if any cosmic rays hits in masked black
        if ~isempty(calIntermediateStruct.cosmicRayEvents.maskedBlack)
            
            nMblackEvents = length([calIntermediateStruct.cosmicRayEvents.maskedBlack.delta]);
            display(['CAL:correct_collateral_pix_black_level: Number of cosmic rays detected in masked black region: ' num2str(nMblackEvents) ]);
        else
            display('CAL:correct_collateral_pix_black_level: No cosmic rays detected in masked black region');
        end
        
        % display # if any cosmic rays hits in virtual black
        if (~isempty(calIntermediateStruct.cosmicRayEvents.virtualBlack))
            
            nVblackEvents = length([calIntermediateStruct.cosmicRayEvents.virtualBlack.delta]);
            display(['CAL:correct_collateral_pix_black_level: Number of cosmic rays detected in virtual black region' num2str(nVblackEvents) ]);
        else
            display('CAL:correct_collateral_pix_black_level: No cosmic rays detected in virtual black region');
        end
    end
end




if ~dynamic2DBlackEnabled

    %--------------------------------------------------------------------------
    % Step 4: apply correction to cadences with missing black pixels
    %
    % if no black pixels are available for the first cadence, then it would be
    % impossible to fill the structure with the data from the nearest cadence;
    % iterate through all the cadences before filling in the missing cadence
    %--------------------------------------------------------------------------
    if ~isempty(missingBlackCadences)

        % if all cadences are missing black pixels (should never happen)
        if length(missingBlackCadences) == nCadences

            display(['CAL:correct_collateral_pix_black_level: No black levels available for ' num2str(nCadences) ' cadences - cannot do black correction!']);

        else
            for mCadence = 1:length(missingBlackCadences)

                availableCadences = setxor(missingBlackCadences, (1:nCadences)');

                % use the black levels of the nearest non-missing cadence
                missingCadence = missingBlackCadences(mCadence);

                [minDist, minIndex] = min(abs(availableCadences - missingCadence));                                                         %#ok<ASGLU>
                nearestAvailableCadence = availableCadences(minIndex);

                display(['CAL:correct_collateral_pix_black_level: No black levels available for cadence '...
                    num2str(missingCadence) ' - using the next nearest cadence: ' num2str(nearestAvailableCadence)]);

                % transfer black correction from nearest available cadences
                calIntermediateStruct.blackCorrection(:, missingCadence) = ...
                    calIntermediateStruct.blackCorrection(:, nearestAvailableCadence);


                %------------------------------------------------------------------
                % apply black correction to missing cadences
                %------------------------------------------------------------------
                [calObject, calIntermediateStruct, calTransformStruct] = ...
                    apply_black_correction_to_collateral_pixels(calObject, calIntermediateStruct, missingCadence, calTransformStruct);

                % update missing cadence black pixels - transfer fields from nearest available cadences
                calIntermediateStruct.blackPixels(:, missingCadence) = ...      %1070 x nCadences
                    calIntermediateStruct.blackPixels(:, nearestAvailableCadence);

                if ~pouEnabled
                    calIntermediateStruct.blackUncertaintyStruct(missingCadence) = ...
                        calIntermediateStruct.blackUncertaintyStruct(nearestAvailableCadence);
                end

                calIntermediateStruct.blackGaps(:, missingCadence) = ...        %1070 x nCadences
                    calIntermediateStruct.blackGaps(:, nearestAvailableCadence);

            end
        end
    end
end



%--------------------------------------------------------------------------
% Create figures of the correction over the pixels for diagnostics
%
% Note: If using dynamic 2D balck correction the correction to the black pixels
% includes the mean 2D black value. If using static 2D balck + 1D black correction
% the correction to the black pixels includes only the delta from the mean 2D black
% value.
%--------------------------------------------------------------------------

% plot only select cadences
for cadenceIndex = rowvec(plot1DBlackCadenceArray)
    
    if isAvailableBlackPix
        
        % black residual data
        blackPixels = calIntermediateStruct.blackPixels(:, cadenceIndex);
        blackGaps = calIntermediateStruct.blackGaps(:, cadenceIndex);
        
        % black correction from blackAlgorithm fit
        blackCorrection = calIntermediateStruct.blackCorrection(:, cadenceIndex);
        
        % find valid pixel indices:
        validBlackPixelIndicators = ~blackGaps;
        
        if any(validBlackPixelIndicators)            
            
            newValidIndicators = validBlackPixelIndicators;
            
            % don't consider pixels for charge injection rows
            newValidIndicators(chargeInjectionRows) = false;
            
            % for polynomial or exponential 1D black fits, don't consider excluded black rows ( FGS + charge injection)
            % note dynablack correction takes FGS rows into account
            %             if ~dynamic2DBlackEnabled
            newValidIndicators(blackRowsToExcludeInFit) = false;
            %             end
            
            % if no valid pixels in trimmed set plot all available pixels
            if( all(~newValidIndicators) )
                newValidIndicators = validBlackPixelIndicators;
            end
            
            correctedBlackPixels = blackPixels./numberOfExposures;
            blackCorrectionForCadence = blackCorrection./numberOfExposures;
            blackCorrectionForCadence(~newValidIndicators) = NaN;
            
            uncorrectedPixelsForCadence = nan(size(blackCorrectionForCadence));
            uncorrectedPixelsForCadence(newValidIndicators) = correctedBlackPixels(newValidIndicators) + blackCorrectionForCadence(newValidIndicators);
            
            %------------------------------------------------------------------
            % create figures of black correction for these select cadences
            %------------------------------------------------------------------
            
            % plot only non-fgs and non-charge control rows
            close all;
            paperOrientationFlag = true;
            
            h = figure;
            h1 = plot(uncorrectedPixelsForCadence, 'ro', 'markersize', 7);
            hold on
            h2 = plot(blackCorrectionForCadence, 'c.', 'markersize', 7);
            
            title(['[CAL] ' num2str(cadenceTypeStringForPlot)  ' Black Correction for Channel ' ...
                num2str(convert_from_module_output(ccdModule, ccdOutput)) ' Cadence ' num2str(cadenceIndex)], 'fontsize', TITLE_FONTSIZE);
                        
            xlabel('CCD Row Index', 'fontsize', AXIS_LABEL_FONTSIZE);
            ylabel('Black Pixel Values (ADU/exposure)', 'fontsize', AXIS_LABEL_FONTSIZE);
            
            if ~dynamic2DBlackEnabled
                z = legend([h1 h2], ' 2D black-corrected pixels ', ' Black correction ', 'Location', 'Best');
            else
                z = legend([h1 h2], ' raw black pixels ', ' Black correction ', 'Location', 'Best');
            end
            set(z, 'fontsize', LEGEND_FONTSIZE);            
            set(h, 'PaperPositionMode', 'auto');
            set(gca, 'fontsize', AXIS_NUMBER_FONTSIZE);
            
            figureFilename = ['cal_1dblack_over_pixels_cad' num2str(cadenceIndex)];
            plot_to_file(figureFilename, paperOrientationFlag);
            close all
            
            % short cadence will have too few data points for histogram
            if ~processShortCadence
                h2 = figure;
                
                hist(correctedBlackPixels(newValidIndicators), 51);
                
                title(['[CAL] ' num2str(cadenceTypeStringForPlot)  ' Black Residuals (bin = 51) for Channel ' ...
                    num2str(convert_from_module_output(ccdModule, ccdOutput)) ' Cadence ' num2str(cadenceIndex)], 'fontsize', TITLE_FONTSIZE);
                
                xlabel('Black Residuals (ADU/exposure)', 'fontsize', AXIS_LABEL_FONTSIZE);
                ylabel('Number', 'fontsize', AXIS_LABEL_FONTSIZE);
                
                set(h2, 'PaperPositionMode', 'auto');
                set(gca, 'fontsize', AXIS_NUMBER_FONTSIZE);
                
                figureFilename = ['cal_black_residuals_hist_cad' num2str(cadenceIndex)];
                plot_to_file(figureFilename, paperOrientationFlag);
                close all
            end
            
            % plot only fgs rows
            fgsValidIndicators = false(size(validBlackPixelIndicators));
            fgsValidIndicators(frameTransferRows) = validBlackPixelIndicators(frameTransferRows);
            
            if any(fgsValidIndicators)
                
                close all;
                paperOrientationFlag = true;
                
                fgsCorrection = nan(size(blackCorrectionForCadence));
                fgsCorrection(fgsValidIndicators) = blackCorrection(fgsValidIndicators)./numberOfExposures;
                fgsPix = nan(size(correctedBlackPixels));
                fgsPix(fgsValidIndicators) = correctedBlackPixels(fgsValidIndicators) + fgsCorrection(fgsValidIndicators);
                
                h = figure;
                h1 = plot(fgsPix, 'ro', 'markersize', 7);
                hold on
                h2 = plot(fgsCorrection, 'c.', 'markersize', 7);
                
                title(['[CAL] ' num2str(cadenceTypeStringForPlot)  ' Black Correction for Channel ' ...
                    num2str(convert_from_module_output(ccdModule, ccdOutput)) ' Cadence ' num2str(cadenceIndex) ' FGS Pixels Only'], 'fontsize', TITLE_FONTSIZE);
                                
                xlabel('CCD Row Index', 'fontsize', AXIS_LABEL_FONTSIZE);
                ylabel('Black Pixel Values (ADU/exposure)', 'fontsize', AXIS_LABEL_FONTSIZE);
                
                if ~dynamic2DBlackEnabled
                    z = legend([h1 h2], ' 2D black-corrected pixels ', ' Black correction ', 'Location', 'Best');
                else
                    z = legend([h1 h2], ' raw black pixels ', ' Black correction ', 'Location', 'Best');
                end
                set(z, 'fontsize', LEGEND_FONTSIZE);                
                set(h, 'PaperPositionMode', 'auto');
                set(gca, 'fontsize', AXIS_NUMBER_FONTSIZE);
                
                figureFilename = ['cal_1dblack_over_fgs_pixels_cad' num2str(cadenceIndex)];
                plot_to_file(figureFilename, paperOrientationFlag);
                close all
            end
        end
    end
end


%--------------------------------------------------------------------------
% save black correction to local .mat file for photometric pixel calibration
%--------------------------------------------------------------------------
blackCorrection = calIntermediateStruct.blackCorrection;            %#ok<NASGU>
blackAvailable  = calIntermediateStruct.blackAvailable;             %#ok<NASGU>
dynablackScBias = calIntermediateStruct.dynablackScBias;            %#ok<NASGU>
CdynablackScBias = calIntermediateStruct.CdynablackScBias;          %#ok<NASGU>

save([stateFilePath, 'cal_black_levels.mat'], 'blackCorrection', 'blackAvailable', 'dynablackScBias','CdynablackScBias');
calIntermediateStruct = rmfield(calIntermediateStruct, {'blackCorrection','dynablackScBias','CdynablackScBias'});
display('CAL:correct_collateral_pix_black_level: Black correction saved in cal_black_levels.mat');

%--------------------------------------------------------------------------
% save and plot black-corrected black pixels (residuals)
%--------------------------------------------------------------------------
plot_black_correction(calIntermediateStruct, stateFilePath);



return;
