function [pdqOutputStruct, modOutsWithMetrics] = process_reference_pixels(pdqScienceObject)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function pdqOutputStruct = process_reference_pixels(pdqScienceObject)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This method is the entry point for all PDQ processing. It takes an object
% 'pdqScienceObject' of type 'pdqScienceClass' as input and calls several
% class methods to perform all PDQ analysis.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%__________________________________________________________________________
% Output: An object 'pdqOutputStruct' of class 'pdqOutputStructClass'
% containing the following fields as data memebers.
%__________________________________________________________________________
%
%     pdqOutputStruct =
%
%                       outputPdqTsData: [1x1 struct]
%                   attitudeAdjustments: [1x4 struct]
%                pdqModuleOutputReports: [84x1 struct]
%                   pdqFocalPlaneReport: [1x1 struct]
%                      attitudeSolution: [4x3 double]
%     attitudeSolutionUncertaintyStruct: [4x1 struct]
%..........................................................................
%   pdqOutputStruct.outputPdqTsData
%
%             pdqModuleOutputTsData: [84x1 struct]
%                      cadenceTimes: [4x1 double]
%                attitudeSolutionRa: [1x1 struct]
%               attitudeSolutionDec: [1x1 struct]
%              attitudeSolutionRoll: [1x1 struct]
%                 desiredAttitudeRa: [1x1 struct]
%                desiredAttitudeDec: [1x1 struct]
%               desiredAttitudeRoll: [1x1 struct]
%                   deltaAttitudeRa: [1x1 struct]
%                  deltaAttitudeDec: [1x1 struct]
%                 deltaAttitudeRoll: [1x1 struct]
%     maxAttitudeResidualInPixels: [1x1 struct]
%..........................................................................
%
%     pdqOutputStruct.outputPdqTsData.moduleOutputTsData is a struct array with fields:
%         84x1 struct array with fields:
%             ccdModule
%             ccdOutput
%             blackLevels
%             smearLevels
%             darkCurrents
%             backgroundLevels
%             dynamicRanges
%             meanFluxes
%             centroidsMeanRows
%             centroidsMeanCols
%             encircledEnergies
%             plateScales
%
%     pdqOutputStruct.outputPdqTsData.moduleOutputTsData(1)
%                 ccdModule: 2
%                 ccdOutput: 1
%               blackLevels: [1x1 struct]
%               smearLevels: [1x1 struct]
%              darkCurrents: [1x1 struct]
%          backgroundLevels: [1x1 struct]
%             dynamicRanges: [1x1 struct]
%                meanFluxes: [1x1 struct]
%         centroidsMeanRows: [1x1 struct]
%         centroidsMeanCols: [1x1 struct]
%         encircledEnergies: [1x1 struct]
%               plateScales: [1x1 struct]
% pdqOutputStruct.outputPdqTsData.pdqModuleOutputTsData(1).backgroundLevels
%
%            values: [4x1 double]
%     gapIndicators: [4x1 logical]
%     uncertainties: [4x1 double]
%
%..........................................................................
%
%         pdqOutputStruct.attitudeAdjustments
%
%
%         1x4 struct array with fields:
%             quaternion
%
%..........................................................................
%
% pdqOutputStruct.pdqModuleOutputReports
%
%         84x1 struct array with fields:
%             ccdModule
%             ccdOutput
%             blackLevel
%             smearLevel
%             darkCurrent
%             backgroundLevel
%             dynamicRange
%             meanFlux
%             centroidsMeanRow
%             centroidsMeanCol
%             encircledEnergy
%             plateScale
%
%  pdqOutputStruct.pdqModuleOutputReports(1)
%
%                    ccdModule: 2
%                    ccdOutput: 1
%                   blackLevel: [1x1 struct]
%                   smearLevel: [1x1 struct]
%                  darkCurrent: [1x1 struct]
%              backgroundLevel: [1x1 struct]
%                 dynamicRange: [1x1 struct]
%                     meanFlux: [1x1 struct]
%             centroidsMeanRow: [1x1 struct]
%             centroidsMeanCol: [1x1 struct]
%              encircledEnergy: [1x1 struct]
%                   plateScale: [1x1 struct]
%
% pdqOutputStruct.pdqModuleOutputReports(1).blackLevel
%
%                             time: 55404.5306559697
%                            value: 1700.39389299665
%                      uncertainty: 0.6743727244103
%             adaptiveBoundsReport: [1x1 struct]
%                fixedBoundsReport: [1x1 struct]
%                           alerts: [0x0 struct]
%
% pdqOutputStruct.pdqModuleOutputReports(1).blackLevel.adaptiveBoundsReport
%
%                         outOfUpperBound: 0
%                         outOfLowerBound: 0
%                   outOfUpperBoundsCount: 0
%                   outOfLowerBoundsCount: 0
%                   outOfUpperBoundsTimes: [0x1 double]
%                   outOfLowerBoundsTimes: [0x1 double]
%                              upperBound: 1701.5955260059
%                              lowerBound: 1699.53974951101
%             upperBoundCrossingPredicted: 0
%             lowerBoundCrossingPredicted: 0
%                            crossingTime: -1
%..........................................................................
% pdqOutputStruct.pdqFocalPlaneReport
%
%                   deltaAttitudeRa: [1x1 struct]
%                  deltaAttitudeDec: [1x1 struct]
%                 deltaAttitudeRoll: [1x1 struct]
%
%             pdqOutputStruct.pdqFocalPlaneReport.deltaAttitudeRa
%
%                                 time: 55404.5306559697
%                                value: -8.01893992274927e-05
%                          uncertainty: 3.65918563418838e-09
%                 adaptiveBoundsReport: [1x1 struct]
%                    fixedBoundsReport: [1x1 struct]
%                               alerts: [0x0 struct]
%..........................................................................
%
% pdqOutputStruct.attitudeSolutionUncertaintyStruct(1)
%
%                     raStars: [415x1 double]
%                    decStars: [415x1 double]
%                centroidRows: [415x1 double]
%             centroidColumns: [415x1 double]
%                CcentroidRow: [415x415 double]
%             CcentroidColumn: [415x415 double]
%                   ccdModule: [415x1 double]
%                   ccdOutput: [415x1 double]
%             nominalPointing: [290.674345987126 44.5006596988479 -0.00754964877156059]
%                 cadenceTime: 55401.5207576949
%             CdeltaAttitudes: [3x3 double]
%__________________________________________________________________________
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

%----------------------------------------------------------------------
% preliminaries
%----------------------------------------------------------------------
warning on all;
close all;
fprintf('PDQ: Extracting FC models...\n');

% instantiate gain, read noise model ; these are simple FC models and
% contain one value per modout per time stamp or 84 such values per time
% stamp
[gainForAllCadencesAllModOuts, readNoiseForAllCadencesAllModOuts, configMapStruct, requantTableStruct] ...
    = extract_simple_focal_plane_models(pdqScienceObject);

% instantiate the undershoot model object
undershootObject = undershootClass(pdqScienceObject.undershootModel);


% instantiate raDec2Pix model
raDec2PixObject = raDec2PixClass(pdqScienceObject.raDec2PixModel, 'one-based');
pointingObject = pointingClass(pdqScienceObject.raDec2PixModel.pointingModel);


% get the number of modules from FC constants
nModOuts = pdqScienceObject.fcConstants.MODULE_OUTPUTS;

fcConstantsStruct  = pdqScienceObject.fcConstants;


% create output structure to be populated later
pdqOutputStruct = create_output_structure(nModOuts);


% set up a counter to count all the target stars (excluding dynamic range
% targets) over the entire focal plane; pdqScienceObject contains
% stellarPdqTargets field which also includes dynamic range targets
nTotalTargetStars = 0;


%----------------------------------------------------------------------
% process one module output at a time
%----------------------------------------------------------------------
modOutsProcessed = false(nModOuts,1);

for currentModOut = 1:nModOuts

    try
        % convert the modout number to {ccd, output} pair
        [ccdModule ccdOutput] = convert_to_module_output(currentModOut);

        % Find out if the current module/output has valid data to be processed
        fprintf('---------------------------------------------------------------\n');

        fprintf('PDQ: Processing module output {%d, %d} (%d/%d) ....\n', ccdModule, ccdOutput, currentModOut, nModOuts);

        fprintf('---------------------------------------------------------------\n');

        % add the ccdModule, ccdOutput values to the output structure
        pdqOutputStruct.outputPdqTsData.pdqModuleOutputTsData(currentModOut).ccdModule = ccdModule;
        pdqOutputStruct.outputPdqTsData.pdqModuleOutputTsData(currentModOut).ccdOutput = ccdOutput;
        pdqOutputStruct.pdqModuleOutputReports(currentModOut).ccdModule = ccdModule;
        pdqOutputStruct.pdqModuleOutputReports(currentModOut).ccdOutput = ccdOutput;

        %----------------------------------------------------------------------
        % pdqScienceObject contains targets from all the (84) modules in the
        % entire focal plane. select those stellar target pixels that belong to
        % the current module output
        %----------------------------------------------------------------------

        fprintf('PDQ: Collecting stellar target pixels ...\n');
        pdqTempStruct = determine_available_stellar_pixels(pdqScienceObject,  currentModOut);

        % add common data struct here as number of exposures is needed for
        % computing dynamic range per read

        pdqTempStruct.gainForAllCadencesAllModOuts        = gainForAllCadencesAllModOuts;
        pdqTempStruct.readNoiseForAllCadencesAllModOuts   = readNoiseForAllCadencesAllModOuts;
        pdqTempStruct.configMapStruct       = configMapStruct;
        pdqTempStruct.requantTableStruct    = requantTableStruct;


        % no stellar pixels (dynamic + target) so move on to next module output
        % warning issued already
        if(~pdqTempStruct.stellarPixelsAvailable)
            continue;
        end

        % get the coefficients of the undershoot filter for this modout

        undershootCoeffts = get_undershoot(undershootObject, pdqTempStruct.cadenceTimes, ccdModule, ccdOutput);
        pdqTempStruct.undershootCoeffts = undershootCoeffts'; % now of size nCoeffts x nCadences
        % only dynamic range targets
        if(~pdqTempStruct.stellarTargetsAvailable && pdqTempStruct.dynamicRangeTargetAvailable)
            % Run dynamic range; Track, trend, and bounds check dynamic ranges time series
            [pdqTempStruct, pdqOutputStruct] = compute_dynamic_range_metric_main(pdqScienceObject, pdqTempStruct, pdqOutputStruct, currentModOut);
            continue;
        end

        fprintf('PDQ: Number of stellar targets = %d\n', pdqTempStruct.numTargets  );
        fprintf('PDQ: Number of cadences = %d\n', pdqTempStruct.numCadences  );
        %----------------------------------------------------------------------
        % select those background pixels that belong to the current  module output
        %----------------------------------------------------------------------
        fprintf('PDQ: Collecting background pixels ...\n');
        [pdqTempStruct] = determine_available_bkgd_pixels(pdqScienceObject, pdqTempStruct,  currentModOut);

        %move on to the next module output as calibration is not possible
        if(~pdqTempStruct.backgroundPixelsAvailable)
            continue;
        end

        %----------------------------------------------------------------------
        % select those collateral (black + vsmear + msmear)  pixels that belong to the current  module output
        %----------------------------------------------------------------------
        fprintf('PDQ: Collecting black, virtual and masked smear pixels ...\n');
        [pdqTempStruct] = determine_available_collateral_pixels(pdqScienceObject, pdqTempStruct,  currentModOut);

        % no collateral pixels or no black pixels or no smear pixels
        % (vsmear + msmear) available and calibration is impossible
        if(~pdqTempStruct.collateralPixelsAvailable || ~pdqTempStruct.blackPixelsAvailable ||...
                (~pdqTempStruct.msmearPixelsAvailable && pdqTempStruct.vsmearPixelsAvailable) )
            continue;
        end


        %----------------------------------------------------------------------
        % Track, trend, and bounds check dynamic ranges time series
        %----------------------------------------------------------------------
        [pdqTempStruct, pdqOutputStruct] = compute_dynamic_range_metric_main(pdqScienceObject, pdqTempStruct, pdqOutputStruct, currentModOut);


        %----------------------------------------------------------------------
        % Perform pixel level calibration on input reference pixels
        % correct for black 2D, bin collateral pixels, correct for black, correct for gain, estimate smear and
        % correct for smear, estimate dark current level and correct for dark,
        % estimate background and correct for background level
        %----------------------------------------------------------------------
        % copy FC models to temp structure

        fprintf('PDQ: Instantiating flatfield and black2D models ....\n');
        % instantiate black 2D, flat field models for this mod/out
        [flatFieldObject, black2DObject] = instantiate_modout_specific_focal_plane_models(pdqScienceObject, currentModOut);


        pdqTempStruct.flatFieldObject   = flatFieldObject;
        pdqTempStruct.black2DObject     = black2DObject;

        fprintf('PDQ: Calibrating pixels ...\n');

        [pdqTempStruct, pdqOutputStruct] = calibrate_reference_pixels(pdqScienceObject, pdqTempStruct, pdqOutputStruct, currentModOut);

        % If calibration failed, skip to the next channel and leave
        % modOutsProcessed(currentModOut) set to 'false'
        if(~any(pdqTempStruct.backgroundPixelsAvailableFlag))
            warning('Calibration failed: no background pixels available. Proceeding to next channel.');
            continue
        end
        
        if(pdqTempStruct.debugLevel)
            warning off all;
            plot_target_and_bkgd_pixels_for_this_modout(pdqTempStruct);
            plot_calibrated_target_pixels_in_different_stages(pdqTempStruct);
            warning on all;
        end

        %----------------------------------------------------------------------
        % output smear, dark level, and background level metrics caculated in
        % pixel level calibration
        %----------------------------------------------------------------------

        [pdqTempStruct, pdqOutputStruct] = ...
            output_smear_metric(pdqScienceObject, pdqTempStruct, pdqOutputStruct, currentModOut);

        [pdqTempStruct, pdqOutputStruct] = ...
            output_dark_current_metric(pdqScienceObject, pdqTempStruct, pdqOutputStruct, currentModOut);

        [pdqTempStruct,pdqOutputStruct]  = ...
            output_background_correction_metric(pdqScienceObject, pdqTempStruct, pdqOutputStruct,currentModOut);

        %----------------------------------------------------------------------
        % compute target flux level, compute and output brightness metric
        %----------------------------------------------------------------------
        fprintf('PDQ: Computing brightness metric ...\n');
        [pdqTempStruct,pdqOutputStruct] = ...
            compute_brightness_metric_main(pdqScienceObject, pdqTempStruct, pdqOutputStruct,currentModOut);

        %----------------------------------------------------------------------
        % compute centroids (row & column)
        %----------------------------------------------------------------------
        fprintf('PDQ: Computing centroids ...\n');
        
        % Insert relevant data into temp struct if a preliminary attitude
        % solution was provided.
        if isfield(struct(pdqScienceObject), 'preliminaryAttitudeSolutionStruct')
            pdqTempStruct.preliminaryAttitudeSolutionStruct = ...
                pdqScienceObject.preliminaryAttitudeSolutionStruct;
            pdqTempStruct.raDec2PixModel = pdqScienceObject.raDec2PixModel;
        end
        
        %pdqTempStruct = compute_centroids(pdqTempStruct);
        pdqTempStruct = compute_prf_based_centroids(pdqTempStruct, pdqScienceObject.fcConstants);

        %----------------------------------------------------------------------
        % compute encircled energy and output encircled energy metric
        %----------------------------------------------------------------------
        % Generate encircled energy metric
        fprintf('PDQ: Computing encircled energy metric ...\n');
        [pdqTempStruct,pdqOutputStruct] = ...
            compute_encircled_energy_metric_main(pdqScienceObject, pdqTempStruct, pdqOutputStruct,currentModOut);

        %----------------------------------------------------------------------
        % keep track of total number of valid target stars per cadence across
        % the focal plane for setting up the attitude solution data structure
        %----------------------------------------------------------------------
        nTotalTargetStars = nTotalTargetStars + pdqTempStruct.numTargets;

        %----------------------------------------------------------------------
        % save pdqTempStruct for each module output separately for setting up
        % the attitude solution data structure
        %----------------------------------------------------------------------

        sFileName = ['pdqTempStruct_' num2str(currentModOut) '.mat'];

        save(sFileName, '-v7.3', 'pdqTempStruct', 'pdqOutputStruct');

        modOutsProcessed(currentModOut) = true;


    catch
        errorThrown = lasterror;
        stackLength = length(errorThrown.stack);
        for jStack = 1:stackLength
            disp(errorThrown.stack(jStack))
        end

        warning('PDQ:processReferencePixels', ...
            [errorThrown.message '   Unable to process module [' num2str(ccdModule) '] output [' num2str(ccdOutput) '] modout = ' num2str(currentModOut) ]);

        modOutsProcessed(currentModOut) = false;
        
        sFileName = ['failedToProcess_' num2str(currentModOut) '.mat'];

        save(sFileName, '-v7.3', 'pdqTempStruct', 'pdqOutputStruct');
    end

end


if(~any(modOutsProcessed)) % none of the modouts were processed succesfully, can't get attitude solution

    error('PDQ:processReferencePixels', ...
        'PDQ:process_reference_pixels:  Unable to process any of the modouts and hence can''t compute attitude solution...quitting');
end

%----------------------------------------------------------------------
% read pdqTempStruct for each module output and set up the attitude
% solution data structure
%----------------------------------------------------------------------
numCadences = length(pdqScienceObject.cadenceTimes); % the last pdqTempStruct might not have this information if it didn't have any targets
fprintf('PDQ: Extracting data for attitude solution from the intermediate mat files ...\n');

if(numCadences < 20) % due to memory limitation

    attitudeSolutionStruct = generate_attitude_solution_data(nModOuts, modOutsProcessed, numCadences, nTotalTargetStars, pointingObject);

    save attitudeSolutionStruct.mat attitudeSolutionStruct pdqOutputStruct numCadences nTotalTargetStars modOutsProcessed;

else
    %----------------------------------------------------------------------
    % For Monte Carlo validation, use the following method
    %----------------------------------------------------------------------

    generate_attitude_solution_temp_structure(nModOuts, pointingObject);
    attitudeSolutionStruct = generate_attitude_solution_data_100s_of_cadences(nModOuts, modOutsProcessed, numCadences, nTotalTargetStars);
    save attitudeSolutionStruct.mat attitudeSolutionStruct pdqOutputStruct numCadences nTotalTargetStars modOutsProcessed;

end


%----------------------------------------------------------------------
% Actual attitude
%----------------------------------------------------------------------
fprintf('PDQ: Solving for attitude solution ...\n');

[attitudeSolutionStruct, pdqOutputStruct] = ...
    obtain_attitude_solution(pdqScienceObject,attitudeSolutionStruct, pdqOutputStruct,raDec2PixObject);

%----------------------------------------------------------------------
% Desired attitude
%----------------------------------------------------------------------
% Calculate attitude adjustment based desired location of targets in the
% focal plane
[desiredAttitudes,pdqOutputStruct] = get_desired_attitude(pdqScienceObject, attitudeSolutionStruct,pdqOutputStruct);

%----------------------------------------------------------------------
% Attitude tweak (delta quaternion)
%----------------------------------------------------------------------
% Attitude tweak - calculate the delta quaternion necessary to adjust the
% attitude from its actual value, to its desired value
fprintf('PDQ: Calculating the delta quaternion (attitude tweak) ...\n');

[newCadenceIndex, allCadenceTimes] = get_new_cadence_index_in_sorted_cadence_times(pdqScienceObject);

pdqOutputStruct = compute_attitude_tweak_quaternion(pdqOutputStruct, newCadenceIndex, allCadenceTimes, raDec2PixObject);


fprintf('PDQ: Calculating the maximum attitude focal plane residual error...\n');
pdqOutputStruct = compute_max_attitude_focal_plane_residual(pdqScienceObject, pdqOutputStruct,raDec2PixObject);


pdqOutputStruct = compute_tweak_in_pixel_units(pdqOutputStruct, raDec2PixObject);

%----------------------------------------------------------------------
% Delta attitude metric
%----------------------------------------------------------------------
% Compute delta between desired attitude and attitute solution for tracking
% and trending
[pdqOutputStruct] = compute_delta_attitude(pdqScienceObject, pdqOutputStruct);

save attitudeSolutionStruct2.mat pdqOutputStruct nModOuts attitudeSolutionStruct;

%----------------------------------------------------------------------
% now that we have the attitude solution,  calculate the centroid metric
% and plate scale metric  using the attitude solution to get the predicted
% star position
% compute plate scale metric for each modout and output metric
%----------------------------------------------------------------------
fprintf('PDQ: Computing plate scale metric for all the module outputs...\n');

[pdqOutputStruct] = compute_plate_scale_metric_main(pdqScienceObject, pdqOutputStruct,nModOuts, modOutsProcessed,raDec2PixObject);


%----------------------------------------------------------------------
% compute output centroids metric(row & column)
% plot centroid bias over the entire focal plane regardless of debugLevel
%----------------------------------------------------------------------
fprintf('PDQ: Computing centroid metric for all the module outputs...\n');
[pdqOutputStruct] = compute_centroid_metric(pdqScienceObject, pdqOutputStruct, nModOuts, modOutsProcessed, raDec2PixObject);

cadenceIndex = length(newCadenceIndex); % last cadence

%---------------------------- RLM 1/14/11 ---------------------------------
% All the information we need exists at this point. The metric histories
% are in pdqScienceObject, while the new metrics, if they were
% successfully computed, are in pdqOutputStruct. Here we create a new
% output structure containing the metric histories and any available new
% metrics for each mod/out. 
%
% The flags modOutsWithMetrics indicate whether each channel contains
% any metrics, either new or historical. validReferencePixelsAvailable
% indicates whether any non-gapped reference pixels were in the input
% structure.
%--------------------------------------------------------------------------
pdqOutputStruct = merge_with_pdq_output_struct(pdqScienceObject, pdqOutputStruct);
modOutsWithMetrics = modouts_containing_metrics(pdqOutputStruct);
validReferencePixelsAvailable = valid_reference_data_available(pdqScienceObject);
%-------------------------------- RLM -------------------------------------

fprintf('PDQ: Plotting the centroid bias map ...\n');
plot_centroid_bias_over_entire_focal_plane(pdqOutputStruct, cadenceIndex, modOutsProcessed, raDec2PixObject);

fprintf('PDQ: Plotting the residual centroid time series  ...\n');
plot_residual_centroid_time_series(pdqScienceObject.pdqConfiguration.madThresholdForCentroidOutliers,attitudeSolutionStruct, raDec2PixObject);

% It would be better to pass flags indicating whether NEW metrics are
% available fro each channel, since that is what's being plotted here, but
% the plotting function is smart enough to do the right thing with gapped
% metrics. We therefore take the easiest route and pass modOutsWithMetrics
% (we could also just pass true(84,1) and should get the same result).
fprintf('PDQ: Plotting each metric on the focal plane  ...\n');
construct_pdq_pipeline_run_validation_plots_type_0(pdqOutputStruct, newCadenceIndex, modOutsWithMetrics, fcConstantsStruct);



%----------------------------------------------------------------------
% track and trend metrics
%----------------------------------------------------------------------
fprintf('PDQ: Tracking and trending of metrics ...\n');
[pdqOutputStruct] = ...
    track_trend_metrics(pdqScienceObject, pdqOutputStruct, nModOuts, ...
    modOutsWithMetrics);


printModOutLabels = true;
pdqModuleOutputReports = pdqOutputStruct.pdqModuleOutputReports;
pdqFocalPlaneReport = pdqOutputStruct.pdqFocalPlaneReport;
[warningCrossingsSummary, errorCrossingsSummary] =  plot_pdq_bound_crossings_summary(pdqModuleOutputReports, ...
    pdqFocalPlaneReport, pdqScienceObject.cadenceTimes(1), [], [], ...
    printModOutLabels, validReferencePixelsAvailable);
[warningPredictionsSummary, errorPredictionsSummary] = plot_pdq_bound_crossing_predictions_summary(pdqModuleOutputReports, ...
    pdqFocalPlaneReport, [], [], printModOutLabels, validReferencePixelsAvailable);



%----------------------------------------------------------------------
% validate output structure before returning to the module interface
% this validation excludes all the reports
%----------------------------------------------------------------------
pdqOutputStruct.warningCrossingsSummary = warningCrossingsSummary;
pdqOutputStruct.errorCrossingsSummary = errorCrossingsSummary;
pdqOutputStruct.warningPredictionsSummary = warningPredictionsSummary;
pdqOutputStruct.errorPredictionsSummary = errorPredictionsSummary;


save pdqOutputStruct.mat pdqOutputStruct ;


close all;

return


