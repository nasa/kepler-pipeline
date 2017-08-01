function pa_dawg_metrics_script(configStruct)
%**************************************************************************
% function pa_dawg_metrics_script(configStruct)
%**************************************************************************
% Generate diagnostic figures and data for use in DAWG reviews of Kepler PA
% results .
%
% This script automates the generation of figures and data structures used
% to review PA results as part of the Data Analysis Working Group (DAWG).
% All .mat files containing summary data structures will be saved to the
% dawgPrepRoot directory. The .fig and .jpg files will be saved in a
% directory tree under dawgPrepRoot.
%
% INPUTS
%     configStruct : Configuration struct with the following fields:
%     |-.dawgPrepRoot        : A string containing the full path of the
%     |                        directory in which figures and data will be
%     |                        placed. 
%     |-.quarter            : An integer idenitfying the quarter being
%     |                        scrutinized. If empty, default to the
%     |                        earliest available quarter under 'pathName'.
%     |-.lcChannels          : An array of LC channel numbers to process.
%     |-.scChannels          : An array of LC channel numbers to process.
%     |-.pathName            : A cell array of strings containing full
%     |                        paths to directories containing task file
%     |                        directories.
%     |-.dataType            : A cell array of strings containing data type
%     |                        labels corresponding to path names above. 
%     |-.spiceFileDirectory  : A string containing the full path name to
%     |                        the local directory containing spice files
%     |                        for use by raDec2Pix.  
%     |-.cosmicRayPdf        : A string specifying the file containing the
%     |                        reference PDF for use on cosmic ray figures. 
%      -.plotCentroids       : Logical flag to enable/disable plotting of
%                              centroid time series. 
%
% OUTPUTS:  none
%
% NOTES:
%   - It is simplest and best to modify configure_pa_dawg_script.m and
%     use it to generate the configStruct.
%   - It is assumed that the cell array 'dataType' contains at most one
%     string with the substring 'lc', identifying it as long cadence (case
%     is ignored). The remaining entries in dataType are assumed to refer
%     to short cadence. For example: dataType = {'q3_lc', 'q3_sc'}. 
%**************************************************************************
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

% The various analyses may be enabled/disabled with the following flags:
evaluateBackgroundFits             = false; % Long cadence only.
evaluateMotionFits                 = false; % Long cadence only.
evaluateReactionWheelZeroCrossings = false;
evaluateFlux                       = false;
evaluateCentroids                  = false;
evaluateCosmicRays                 = true;
evaluateArga                       = false;
evaluatePaCoa                      = false;

if exist('configStruct', 'var')        
    % ~~~~~~~~~~~~~~~~~~ extract run parameters from configStruct 
    quarter      = configStruct.quarter;
    lcChannels    = configStruct.lcChannels;
    scChannels    = configStruct.scChannels;
    dawgPrepRoot  = configStruct.dawgPrepRoot;
    dataType      = configStruct.dataType;
    pathName      = configStruct.pathName;
    spiceFileDirectory = configStruct.spiceFileDirectory;   
    cosmicRayPdf  = configStruct.cosmicRayPdf;
    plotCentroids = configStruct.plotCentroids;
else

    % ~~~~~~~~~~~~~~~~~~ configure the run here if configStruct not passed

    % Which quarter are we DAWGing?
    quarter = 3;
    
    % Specify the set of channels to process, if they are available.
    lcChannels = [1:4, 9:16, 21:84];
    scChannels = [1:4, 9:16, 21:84];
    
    % corresponding data type (labels for output directories). Must contain
    % either 'lc', 'sc', or both.
    dataType = {'lc', 'sc'};

    % path to task file directories corresponding to each entry in
    % 'dataType'.
    pathName = {'/path/to/c3/pipeline-results/c3-for-archive-ksop2211/lc/pa2',...
                '/path/to/c3/pipeline-results/c3-for-archive-ksop2211/sc/pa'};

    % Specify the root directory for DAWG data products.    
    dawgPrepRoot = '/path/to/Tasks/pa/c3_dawg';

    % Specify the directory containing copies of the spice files needed for raDec2Pix
    spiceFileDirectory = '/path/to/data/spice';
             
    % Where to find the reference PDF for use on cosmic ray figures.
    configStruct.cosmicRayPdf = '/path/to/Tasks/q1_to_q17_dawg/condPdfStruct.mat';

    % Plotting centroids taks a long time - turn it off here to speed
    % things up.
    configStruct.plotCentroids = true;
end

longCadenceIndex  = find(~cellfun(@isempty, strfind(lower(dataType), 'lc')), 1);

% Assign a quarter string for use on plots.
campaignStr = strcat('Q', num2str(quarter));

% the output data tree will be saved in the current working directory
originalWorkingDir = pwd;

% try % ~~~~~~~~~~~~~~~~~~ 
    if ~isempty(longCadenceIndex)
        
        fprintf('\n===========================================================================\n');
        fprintf('Evaluating Long Cadence Results\n');
        fprintf('===========================================================================\n');
        
        channels = lcChannels;

        % background and motion polynomials apply to LC data only - do these first
        dataPath = pathName{longCadenceIndex};

        % ~~~~~~~~~~~~~~~~~~ evaluate background fits
        if evaluateBackgroundFits
            fprintf('\nEvaluating Background Fits ...\n');
            fprintf('------------------------------\n');
            
            mkdir(fullfile(dawgPrepRoot,'background_figures'));
            cd(fullfile(dawgPrepRoot,'background_figures'));
            Z = produce_dawg_background_summary(dataPath, channels, quarter);
            cd(dawgPrepRoot);
            save lc_background_analysis dataPath channels Z
            close all
            clear Z
        end % if evaluateBackgroundFits

        % ~~~~~~~~~~~~~~~~~~ evaluate motion fits
        if evaluateMotionFits
            fprintf('\nEvaluating Motion Fits ...\n');
            fprintf('--------------------------\n');
            
            dirName = fullfile(dawgPrepRoot,'/motion_figures');
            mkdir(dirName);
            cd(dirName);

            % Assess motion polynomial chatter.
            chatterStructArray = batch_evaluate_motion_polynomial_chatter(...
                'pathName', dataPath, 'channelList', channels, 'quarter', quarter, ...
                'firstDerivativeBreakpoints',  [0.0025, 0.010], ...
                'fractionOfCadencesThreshold',  0.005, ...
                'fractionOfTargetsThreshold',   0);        


            resultsStructArray = batch_compare_MP_raDec2Pix(dataPath, quarter, spiceFileDirectory);
            mod = [resultsStructArray.ccdModule];
            out = [resultsStructArray.ccdOutput];
            ch = convert_from_module_output(mod,out);

            R = [resultsStructArray.row];
            C = [resultsStructArray.col];

            rowResidual = [R.residual];
            colResidual = [C.residual];

            maxResidualRow = max(abs(rowResidual));
            maxResidualCol = max(abs(colResidual));

            modesRow = [R.modes];
            modesCol = [C.modes];
            firstModeRow = modesRow(1,:);
            firstModeCol = modesCol(1,:);

            madFromFirstModeRow = mad( rowResidual - repmat(firstModeRow,size(rowResidual,1),1),1);
            madFromFirstModeCol = mad( colResidual - repmat(firstModeCol,size(colResidual,1),1),1);

            maxDeviationFromFirstModeRow = max(abs(rowResidual - repmat(firstModeRow,size(rowResidual,1),1)));
            maxDeviationFromFirstModeCol = max(abs(colResidual - repmat(firstModeCol,size(colResidual,1),1)));

            f1 = plot_raDec2Pix_minus_MP(ch(:), maxResidualRow(:), firstModeRow(:), madFromFirstModeRow(:), maxDeviationFromFirstModeRow(:), campaignStr, 'ROW');
            f2 = plot_raDec2Pix_minus_MP(ch(:), maxResidualCol(:), firstModeCol(:), madFromFirstModeCol(:), maxDeviationFromFirstModeCol(:), campaignStr, 'COLUMN');

            rowOrder = [R.polyOrder];
            colOrder = [C.polyOrder];
            f3 = plot_MP_order_summary(ch,[colOrder(:),rowOrder(:)],campaignStr);
            axis([0 90 1 4]);

            saveas(f1,'diff_MP_raDec2Pix_row','fig');
            saveas(f2,'diff_MP_raDec2Pix_column','fig');
            saveas(f3,'row_and_column_MP_order','fig');

            cd(dawgPrepRoot);
            save lc_motion_analysis dataPath channels chatterStructArray resultsStructArray spiceFileDirectory
            close all
            clear chatterStructArray resultsStructArray
        end % if evaluateMotionFits

        % ~~~~~~~~~~~~~~~~~~ evaluate cosmic ray correction
        if evaluateCosmicRays
            fprintf('\nEvaluating Cosmic Ray Correction ...\n');
            fprintf('------------------------------------\n');
            generate_cosmic_ray_lc_figs_and_data(dataPath, dawgPrepRoot, ...
                lcChannels, quarter, cosmicRayPdf);
            
            % Copy figures representing the minimum and maximum chi square
            % distances. 
            s = load(fullfile(dawgPrepRoot, 'cosmic_ray', 'per_channel_distance_metrics.mat'));
            [~, maxDistIndex] = max(s.distance);
            [~, minDistIndex] = min(s.distance);
            
            cosmicRayLcDir = fullfile(dawgPrepRoot, 'cosmic_ray', ...
                'cosmic_ray_distribution_figs', 'lc');
            srcFile = fullfile(cosmicRayLcDir, sprintf('mod_%d_out_%d', ...
                s.modules(maxDistIndex), s.outputs(maxDistIndex)), ...
                'cr_energy_distribution.fig');
            dstFile = fullfile(cosmicRayLcDir, 'worst_case.fig');
            copyfile(srcFile, dstFile);

            srcFile = fullfile(cosmicRayLcDir, sprintf('mod_%d_out_%d', ...
                s.modules(minDistIndex), s.outputs(minDistIndex)), ...
                'cr_energy_distribution.fig');
            dstFile = fullfile(cosmicRayLcDir, 'best_case.fig');
            copyfile(srcFile, dstFile);
           
            % Clean up
            clear s maxDistIndex minDistIndex cosmicRayLcDir srcFile dstFile
            cd(dawgPrepRoot);
        end % evaluate cosmic ray correction

        % ~~~~~~~~~~~~~~~~~~ evaluate Argabrightening mitigation
        if evaluateArga
            fprintf('\nEvaluating Argabrightening Mitigation ...\n');
            fprintf('-----------------------------------------\n');
            dirName = fullfile(dawgPrepRoot,'/arga_figures');
            mkdir(dirName);
            cd(dirName);

            h = plot_argabrightening_mitigation(dataPath, 'quarterOrCampaign', quarter);

            saveas(h, fullfile(dirName, 'arga_cadences_over_median_calibrated_background.fig'));
            close(h);
            cd(dawgPrepRoot);
        end
        
        % ~~~~~~~~~~~~~~~~~~ evaluate PA-COA results
        if evaluatePaCoa
            fprintf('\nEvaluating PA-COA Results ...\n');
            fprintf('-----------------------------\n');
            dirName = fullfile(dawgPrepRoot,'/pa_coa');
            mkdir(dirName);
            cd(dirName);
            
            % JCS's FOV figures.
            [cdppFOVStruct, h] = paCoaClass.compile_FOV_statistics(quarter, dataPath);
            save(fullfile(dirName, 'cdppFOVStruct.mat'), 'cdppFOVStruct');
            
            saveas(h(1), fullfile(dirName, 'median_cdpp_improvement_fov.fig'));
            saveas(h(2), fullfile(dirName, 'top_tenth_percent_cdpp_improvement_fov.fig'));
            saveas(h(3), fullfile(dirName, 'top_tenth_percent_fractional_aperture_change_fov.fig'));
            saveas(h(4), fullfile(dirName, 'top_ninetieth_percent_fractional_aperture_change.fig'));
            saveas(h(5), fullfile(dirName, 'fraction_reverted_to_tad_fov.fig'));
            close(h);
            clear cdppFOVStruct
            
            % Plot position adjustments across the FOV.
            fovRaDecMagFitResults = ...
                aggregate_ra_dec_mag_fit_results_fov(dataPath, colvec(lcChannels), quarter);
            save(fullfile(dirName, 'fovRaDecMagFitResults.mat'), 'fovRaDecMagFitResults');
            
            h = plot_modeled_vs_catalog_ra_dec_mag_fov(fovRaDecMagFitResults);
            saveas(h(1), fullfile(dirName, 'modeled_vs_catalog_magnitude_fov.fig'));
            saveas(h(2), fullfile(dirName, 'modeled_vs_catalog_position_fov.fig'));
            close(h);
            
            h = scatter_plot_ra_dec_mag_results(fovRaDecMagFitResults, {'dr', 'dd', 'm', 'dm'});
            fprintf('Setting caxis([-1 1]) to highlight target magnitude changes.\n');
            caxis([-1 1]);
            saveas(h, fullfile(dirName, 'delta_ra_dec_mag_vs_magnitude_fov.fig'));
            close(h);            
            clear fovRaDecMagFitResults
            
            cd(dawgPrepRoot);
        end
        
    end

    for iType = 1:length(dataType)

        dataTypeString = dataType{iType};

        fprintf('\n===========================================================================\n');
        fprintf('Evaluating Data Type ''%s''\n', dataTypeString);
        fprintf('===========================================================================\n');
        
        processingLongCadence = ~isempty(strfind(lower(dataTypeString), 'lc'));

        if processingLongCadence
            channels = lcChannels;
        else
            channels = scChannels;
        end

        dataPath = pathName{iType};

        month = []; % This is a dummy argument for K2.

        % ~~~~~~~~~~~~~~~~~~ evaluate reaction wheel zero crossings
        if evaluateReactionWheelZeroCrossings
            fprintf('\nEvaluating RW Zero-Crossing Identification ...\n');
            fprintf('----------------------------------------------\n');
            
            dirName = fullfile(dawgPrepRoot,'reaction_wheel_figures');
            mkdir(dirName);
            cd(dirName);

            % rxWheel plots are the same for all channels so just select the first one in list
            channel = channels(1);
            taskFileDir = get_group_dir( 'PA', channel, ...
                'quarter', quarter, 'rootPath', dataPath, 'fullPath', false ); 
            taskFileDir = taskFileDir{1};

            % load rw input data and zero crossing indices
            load(fullfile(dataPath,taskFileDir,'st-0','/pa-inputs-0.mat'));
            load(fullfile(dataPath,taskFileDir,'st-0','/pa-outputs-0.mat'));
            % load([dataPath,taskFileDir,'/pa_state.mat'],'',''); 

            % display indices
            oneBasedRwIndices = outputsStruct.reactionWheelZeroCrossingIndices + 1;
            disp(oneBasedRwIndices');

            % display rw speed plot 
            f1 = open(fullfile(dataPath,taskFileDir,'pa_rw_zero_crossings.fig')); % Uncomment

            % mark rw crossing contiguous cadence start and stop times
            t0 = floor(inputsStruct.cadenceTimes.startTimestamps(1));
            rwCrossingStartTimestamps = inputsStruct.cadenceTimes.startTimestamps(oneBasedRwIndices) - t0;
            rwCrossingEndTimestamps = inputsStruct.cadenceTimes.endTimestamps(oneBasedRwIndices) - t0;
            hold on;
            plot(rwCrossingStartTimestamps,-5 .* ones(size(rwCrossingStartTimestamps)),'ko','MarkerSize',10);
            plot(rwCrossingEndTimestamps,-5 .* ones(size(rwCrossingEndTimestamps)),'k+','MarkerSize',10);
            hold off;

            % calculate median filtered wheel speeds. Note that for K2 we've added
            % thruster-related ancillary data, which needs to be differentiated
            % here from the RW speed data.
            rwSpeedIndicators = strncmp('ADRW', {inputsStruct.ancillaryEngineeringDataStruct.mnemonic}, 4);
            wheelSpeeds = [inputsStruct.ancillaryEngineeringDataStruct(rwSpeedIndicators).values];
            reactionWheelMedianFilterLength = inputsStruct.paConfigurationStruct.reactionWheelMedianFilterLength;
            filteredWheelSpeeds = medfilt1_soc(wheelSpeeds, reactionWheelMedianFilterLength);
            wheelTimes = median([inputsStruct.ancillaryEngineeringDataStruct(rwSpeedIndicators).timestamps],2);

            % overlay filtered speeds on plot
            hold on;
            plot(wheelTimes-t0,filteredWheelSpeeds,'x');
            hold off;

            saveas(f1,['reaction_wheel_speeds_',dataTypeString],'fig');
            cd(dawgPrepRoot);

            save([dataTypeString,'_reaction_wheel_analysis'],'oneBasedRwIndices','wheelSpeeds','wheelTimes','filteredWheelSpeeds','t0');
            close all
            clear inputsStruct outputsStruct taskFileDir channel 
            clear oneBasedRwIndices t0 rwCrossingStartTimestamps rwCrossingEndTimestamps wheelSpeeds reactionWheelMedianFilterLength filteredWheelSpeeds wheelTimes
        end % if evaluateReactionWheelZeroCrossings

        % ~~~~~~~~~~~~~~~~~~ evaluate flux
        if evaluateFlux
            fprintf('\nEvaluating Flux Time Series ...\n');
            fprintf('-------------------------------\n');
            
            dirName = fullfile(dawgPrepRoot,'flux_figures',dataTypeString);
            mkdir(dirName);
            cd(dirName);

            % Generate the Kepler flux figures.
            [F,S] = produce_dawg_flux_summary(dataPath, channels, quarter, month);                                                        %#ok<*NASGU,*ASGLU>
            cd(dawgPrepRoot);
            save([dataTypeString,'_flux_analysis'],'dataPath','channels','quarter','F','S');
            close all
            clear F S

        end % if evaluateFlux

        % ~~~~~~~~~~~~~~~~~~ evaluate centroids
        % Note that PRF centroids are not computed for short cadence, so some
        % SC figures will not contain meaningful data.
        if evaluateCentroids
            fprintf('\nEvaluating Centroids ...\n');
            fprintf('------------------------\n');
            
            dirName = fullfile(dawgPrepRoot,'centroid_figures',dataTypeString);
            mkdir(dirName);
            cd(dirName);
            [C,S] = produce_dawg_centroid_summary(dataPath, channels, quarter, month);
            save([dataTypeString,'_centroid_analysis'],'dataPath','channels', 'quarter', 'C','S');
            close all
            clear C S

            % ~~~~~~~~~~~~~~~~~~ plot centroids
            if plotCentroids
                fprintf('Plotting Centroids ...\n');
                fprintf('----------------------\n');
                
                turnPlotsOn = true;
                batch_plot_centroid_time_series('pathName', dataPath, ...
                    'channelList', channels, 'quarter', quarter, 'plotsOn', turnPlotsOn);
            end
            cd(dawgPrepRoot);
            close all
        end % if evaluateCentroids

    end
    
    cd(originalWorkingDir);
    
% catch e % ~~~~~~~~~~~~~~~~~~ 
%     cd(originalWorkingDir);
%     rethrow(e)
% end

%********************************** EOF ***********************************
