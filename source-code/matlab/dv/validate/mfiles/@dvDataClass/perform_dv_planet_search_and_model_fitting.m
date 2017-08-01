function [dvResultsStruct] = ...
    perform_dv_planet_search_and_model_fitting(dvDataObject, dvResultsStruct, ...
    normalizedFluxTimeSeriesArray, refTime)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [dvResultsStruct] = ...
%     perform_dv_planet_search_and_model_fitting(dvDataObject, dvResultsStruct, ...
%     normalizedFluxTimeSeriesArray, refTime)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Perform multiple planet search (if enabled) for all targets, and fit
% planet model to each threshold crossing planet candidate. Also fit planet
% model separately to odd and event transits for each candidate. Compute
% the single event statistics for each trial transit pulse against the
% final residual flux time series for each target after all of the planets
% have been removed.
%
% Upon return, the DV results structure is updated with all planet
% candidates, model fits (all transits for each planet candidate plus
% separate fits to odd and even transits for each planet), residual flux
% time series for each target and all single event statistic time series
% for each target.
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

% Get fields from the input structure.
targetStruct = dvDataObject.targetStruct ;

dvConfigurationStruct = dvDataObject.dvConfigurationStruct ;
maxCandidatesPerTarget = dvConfigurationStruct.maxCandidatesPerTarget ;
weakSecondaryTestEnabled = dvConfigurationStruct.weakSecondaryTestEnabled ;
taskTimeoutSecs = dvDataObject.taskTimeoutSecs ;
debugLevel = dvConfigurationStruct.debugLevel ;
minTpsTaskTimeSecs = 120;           % minimum TPS task time: 120 seconds

% Compute the per target timeout.
nTargets = length(dvDataObject.targetStruct);
targetTimeoutHours = ...
    taskTimeoutSecs * get_unit_conversion('sec2hour') / nTargets;

% If debug level is non-zero, track the execution speed.
timingFilename = '' ;
if debugLevel ~= 0
    timingFilename = ['dv-fitter-timing-',datestr(now,30),'.txt'] ;
    timingFileId = fopen(timingFilename,'wt') ;
end % if

% Get the randstreams if they exist.
streams = false ;
fields = fieldnames(dvDataObject) ;
if any(strcmp('randStreamStruct', fields))
    randStreams = dvDataObject.randStreamStruct.fitterRandStreams ;
    streams = true ;
end % if
    
% Loop over the targets with initial TCE's. Perform iterative whitening and
% multiple planet search (if enabled). Compute single event statistics for
% all trial transit pulses against final residual flux time series.
nTargets = length(targetStruct);

% initialize TPS dawg struct
tpsDawgStruct = collect_results_for_dawg_file([],[]) ;
tpsDawgStruct = repmat(tpsDawgStruct, nTargets * maxCandidatesPerTarget, 1) ;
dawgIndex = 0 ;

% initialize TPS metrics struct
tpsMetricsStruct = collect_results_for_metrics_file([],[]) ;
tpsMetricsStruct = repmat(tpsMetricsStruct, nTargets * maxCandidatesPerTarget, 1) ;
metricsIndex = 0 ;

for iTarget = 1 : nTargets
    
    % Get the KepID.
    keplerId = targetStruct(iTarget).keplerId ;
    
    % Set target-specific randstreams.
    if streams
        randStreams.set_default(keplerId) ;
    end % if
    
    % set the quarterGapIndicators -- the DAWG struct function needs these
    quartersInUnitOfWork = [dvDataObject.targetTableDataStruct.quarter] ;
    quartersObserved     = [targetStruct(iTarget).targetDataStruct.quarter] ;
    quartersIndicators   = ismember( quartersInUnitOfWork(:), quartersObserved(:) ) ;
    targetStruct(iTarget).quarterGapIndicators = ~quartersIndicators(:) ;
    
    % Get the initial threshold crossing event for the given target.
    thresholdCrossingEvent = ...
        dvDataObject.targetStruct(iTarget).thresholdCrossingEvent(1) ;
    
    % Initialize planet counter.
    iPlanet = 0;
    
    % get the start and end of the unit of work
    unitOfWorkStart = ...
        min( dvDataObject.barycentricCadenceTimes(iTarget).startTimestamps ) ;
    unitOfWorkEnd = ...
        max( dvDataObject.barycentricCadenceTimes(iTarget).endTimestamps ) ;

    % prepare the fit timeout datenum value
    fitTimeoutDatenum = targetTimeoutHours * ...
        dvDataObject.planetFitConfigurationStruct.fitterTimeoutFraction * ...
        get_unit_conversion('hour2day') + datenum(now) ;
        
    % Loop until there are no more valid TCE's.
    while ~isempty(thresholdCrossingEvent)
        
        % Perform iterative whitening and planet model fitting to the TCE.
        % Also update the residual flux by removing the transit signature
        % for the fitted planet.
        iPlanet = iPlanet + 1;
        disp(' ');
        disp(['refTime ' num2str(etime(clock, refTime), '%6.2f') ' seconds : Starting fit process on target ', num2str(iTarget), ', planet candidate ', num2str(iPlanet)]);
        disp(' ');
        
        % If requested, write the start time to a file.
        timeVector = clock ;
        timeString = datestr(timeVector) ;
        string = [timeString,' -- starting fit process on target ', num2str(iTarget), ...
            ', planet candidate ', num2str(iPlanet)] ;
        if ~isempty(timingFilename)
            timingFileId = fopen(timingFilename,'at') ;
            fprintf(timingFileId,'%s\n',string) ;
            fclose(timingFileId) ;
        end % if
        
        % at this point we are done with TPS, so force warnings on; if warnings were
        % turned off in TPS, this will fix it!
        
        warning on all ;
        
        if thresholdCrossingEvent.orbitalPeriod < 0
            
            % if the TCE has a period of -1, this indicates that the TCE is based upon one
            % single event statistic plus some gaps, rather than a true set of SES's.  
            % In this case, set orbital period to a big value and then determine other parameters.
            
            thresholdCrossingEventBuf = thresholdCrossingEvent;
            thresholdCrossingEventBuf.orbitalPeriod = 10 * (unitOfWorkEnd - unitOfWorkStart);
            
            dvResultsStruct = fill_transit_fit_struct_with_tce(dvDataObject, dvResultsStruct, iTarget, iPlanet, thresholdCrossingEventBuf);
            dvResultsStruct = subtract_model_transit_from_flux(dvDataObject, dvResultsStruct, iTarget, iPlanet, thresholdCrossingEventBuf);
            
            % Set 'orbitalPeriodDays' of allTransitsFit to -1
            
            modelParameterNames = { dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).allTransitsFit.modelParameters.name };
            indexBuf            = ismember(modelParameterNames, 'orbitalPeriodDays'); 
            dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).allTransitsFit.modelParameters(indexBuf).value = -1;
            
            alertMessage = 'Threshold Crossing Event orbital period < 0, identifier = dv:performPlanetSearchAndModelFitting:negativeTceOrbitalPeriod';
            disp( alertMessage );
            dvResultsStruct = add_dv_alert( dvResultsStruct, 'planet-search', 'warning', alertMessage, iTarget, keplerId, iPlanet );

        else
            
            
            % perform trapezidal model fit
            
            trapezoidalModelFittingEnabled = dvDataObject.planetFitConfigurationStruct.trapezoidalModelFitEnabled;

            if trapezoidalModelFittingEnabled
                
                try
                    
                    dvFiguresRootDirectory  = dvResultsStruct.targetResultsStruct(iTarget).dvFiguresRootDirectory;
                    planetFolder            = sprintf('planet-%02d', iPlanet);
                    fitFolder               = 'trapezoidal-model-fit';
                    fullDirectory           = fullfile( dvFiguresRootDirectory, planetFolder, 'planet-search-and-model-fitting-results', fitFolder );
                    
                    if ~exist(fullDirectory, 'dir')
                        mkdir(fullDirectory);
                    end
                    
                    t1 = clock;
                    [trapezoidalModelFitData] = perform_flux_time_series_smoothing(dvDataObject, dvResultsStruct, thresholdCrossingEvent, iTarget, iPlanet);
                    
                    if ~trapezoidalModelFitData.safeToMinimizeFlag
                        
                        alertMessage = ['  refTime ', num2str(etime(clock, refTime), '%6.2f'), ' seconds : trapezoidal fit of target ', num2str(iTarget), ' planet candidate ', num2str(iPlanet), ...
                            ' failed after ',  num2str(etime(clock, t1)), ' seconds, identifier = dv:performPlanetSearchAndModelFitting:insufficientDataInTransitsForTrapezoidalFit'];
                        disp(' ');
                        disp(alertMessage);
                        disp(' ');
                        dvResultsStruct = add_dv_alert(dvResultsStruct, 'fitter', 'warning', alertMessage, iTarget, keplerId, iPlanet);
                        
                    elseif isempty(trapezoidalModelFitData.detrendOutputs.newFluxValues)
                        
                        alertMessage = ['  refTime ', num2str(etime(clock, refTime), '%6.2f'), ' seconds : trapezoidal fit of target ', num2str(iTarget), ' planet candidate ', num2str(iPlanet), ...
                            ' failed after ',  num2str(etime(clock, t1)), ' seconds, identifier = dv:performPlanetSearchAndModelFitting:missingDetrendedFluxForTrapezoidalFit'];
                        disp(' ');
                        disp(alertMessage);
                        disp(' ');
                        dvResultsStruct = add_dv_alert(dvResultsStruct, 'fitter', 'warning', alertMessage, iTarget, keplerId, iPlanet);
                        
                    else
                        
                        [trapezoidalModelFitData] = perform_trapezoidal_model_fitting(dvDataObject, trapezoidalModelFitData);
                        
                        if trapezoidalModelFitData.trapezoidalFitMinimized
                            
                            disp(' ');
                            disp(['  refTime ', num2str(etime(clock, refTime), '%6.2f'), ' seconds : trapezoidal fit of target ', num2str(iTarget), ' planet candidate ', num2str(iPlanet), ...
                                ' converged in ', num2str(etime(clock,t1)), ' seconds']);
                            disp(' ');
                            
                            generate_trapezoidal_fit_plots(dvDataObject, dvResultsStruct, trapezoidalModelFitData);
                            
                            [dvResultsStruct] = fill_trapezoidal_fit_struct(dvDataObject, dvResultsStruct, trapezoidalModelFitData);
                            [dvResultsStruct] = fill_trapezoidal_model_light_curve(dvDataObject, dvResultsStruct, trapezoidalModelFitData);
                            
                        else
                            
                            alertMessage = ['  refTime ', num2str(etime(clock, refTime), '%6.2f'), ' seconds : trapezoidal fit of target ', num2str(iTarget), ' planet candidate ', num2str(iPlanet), ...
                                ' failed to converge after ', num2str(etime(clock,t1)) ' seconds'];
                            disp(' ');
                            disp(alertMessage);
                            disp(' ');
                            dvResultsStruct = add_dv_alert( dvResultsStruct, 'fitter', 'warning', alertMessage, iTarget, keplerId, iPlanet );
                            
                        end
                        
                    end
                    
                    trapezoidalModelFitDataSaved = trapezoidalModelFitData;
                    eval(['save trapezoidalFit_target_' num2str(iTarget) '_planet_' num2str(iPlanet) '.mat trapezoidalModelFitDataSaved']);
                    
                catch
                    
                    lastError = lasterror;
                    alertMessage = ['  refTime ', num2str(etime(clock, refTime), '%6.2f'), ' seconds : trapezoidal fit of target ', num2str(iTarget), ' planet candidate ', num2str(iPlanet), ...
                        ' failed after ', num2str(etime(clock, t1)), ' seconds, identifier = ', lastError.identifier];
                    disp(' ');
                    disp(alertMessage);
                    disp(' ');
                    dvResultsStruct = add_dv_alert(dvResultsStruct, 'fitter', 'warning', alertMessage, iTarget, keplerId, iPlanet);
                    
                end % try-catch block
                
            end
            
                  
            % fill dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet) with TCE data
            
            dvResultsStruct = fill_transit_fit_struct_with_tce(dvDataObject, dvResultsStruct, iTarget, iPlanet, thresholdCrossingEvent);
           
            % do a first search for gigantic EB signatures at the timestamps corresponding to
            % the TCE, and if there are any remove them
        
            try
            
                startTime = clock;
                [dvResultsStruct, removedEclipsingBinary, gappedTransitStruct] = identify_and_gap_eclipsing_binaries( dvDataObject, dvResultsStruct, iTarget, thresholdCrossingEvent );
                endTime   = clock;

                elapsedSeconds = etime(endTime, startTime);
                disp(['refTime ' num2str(etime(clock, refTime), '%6.2f') ' seconds : identify_and_gap_eclipsing_binaries completed in ' num2str(elapsedSeconds, '%6.2f') ' seconds']);
                disp(' ');
            
            catch
                
                lastError = lasterror;
                alertMessage = ['EB identification failed, identifier = ', lastError.identifier];
                disp(alertMessage);
                dvResultsStruct = add_dv_alert( dvResultsStruct, 'fitter', 'warning', alertMessage, iTarget, keplerId, iPlanet );
                
            end
        
            if removedEclipsingBinary
            
                try
                
                    startTime = clock;
                    dvResultsStruct = fill_fit_results_with_gapped_eclipses( dvDataObject, dvResultsStruct, iTarget, iPlanet, thresholdCrossingEvent, gappedTransitStruct );
                    endTime   = clock;
                
                    elapsedSeconds = etime(endTime, startTime);
                    disp(['refTime ' num2str(etime(clock, refTime), '%6.2f') ' seconds : fill_fit_results_with_gapped_eclipses completed in ' num2str(elapsedSeconds, '%6.2f') ' seconds']);
                    disp(' ');

                    planetResultsStruct = dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet);
                    planetResultsStruct = check_planet_model_parameter_validity( planetResultsStruct, unitOfWorkStart, unitOfWorkEnd, 0 );
                    dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet) = planetResultsStruct;
                    
                    disp( [ 'Target ', num2str(iTarget), ', planet ', num2str(iPlanet), ' identified as eclipsing binary, gapping transits and not fitting'] );
                    alertMessage = 'TCE identified as eclipsing binary and eclipses successfully gapped';
                    dvResultsStruct = add_dv_alert( dvResultsStruct, 'fitter', 'warning', alertMessage, iTarget, keplerId, iPlanet );
                    
                catch
                    
                    lastError = lasterror;
                    alertMessage = ['EB removal failed, identifier = ', lastError.identifier];
                    disp(alertMessage);
                    dvResultsStruct = add_dv_alert( dvResultsStruct, 'fitter', 'warning', alertMessage, iTarget, keplerId, iPlanet );

                end
            
            else % no EB, so fit a planet to the TCE
              
                
                reducedParameterFitsEnabled    = dvDataObject.planetFitConfigurationStruct.reducedParameterFitsEnabled;
                impactParametersForReducedFits = dvDataObject.planetFitConfigurationStruct.impactParametersForReducedFits;
                % whitenerIterationsEnabled      = dvDataObject.planetFitConfigurationStruct.whitenerIterationsEnabled;
                whitenerIterationsEnabled      = true;
                
                if isempty(impactParametersForReducedFits)
                    reducedParameterFitsEnabled = false;
                end
                
                if reducedParameterFitsEnabled
                    
                    for iFit=1:length(impactParametersForReducedFits)
                        
                        oddEvenFlag         = 0;
                        impactParameterSeed = impactParametersForReducedFits(iFit);
                        
                        disp(' ');
                        disp(['  refTime ', num2str(etime(clock, refTime), '%6.2f'), ' seconds : Starting all-transits fit with fixed impact parameter ' num2str(impactParameterSeed, '%1.2f'), ...
                            ' of target ', num2str(iTarget), ' planet candidate ', num2str(iPlanet)]);
                        
                        try 

                            % fill dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet) with TCE data and the impact parameter seed
            
                            dvResultsStruct = fill_transit_fit_struct_with_tce(dvDataObject, dvResultsStruct, iTarget, iPlanet, thresholdCrossingEvent, impactParameterSeed);
                            dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).allTransitsFit = ...
                                reset_transit_fit_struct(dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).allTransitsFit);
                        
                            t1 = clock;
                            if whitenerIterationsEnabled
                                
                                [dvResultsStruct, convergenceFlag, secondaryConvergenceFlag, alertMessageStruct] = ...
                                    perform_iterative_whitening_and_model_fitting(dvDataObject, dvResultsStruct, thresholdCrossingEvent, iTarget, iPlanet, oddEvenFlag, fitTimeoutDatenum, refTime, ...
                                                                                    impactParameterSeed, reducedParameterFitsEnabled);
                                                                                
                            else
                                
                                [dvResultsStruct, convergenceFlag, secondaryConvergenceFlag, alertMessageStruct] = ...
                                    perform_whitening_and_model_fitting(dvDataObject, dvResultsStruct, thresholdCrossingEvent, iTarget, iPlanet, oddEvenFlag, fitTimeoutDatenum, refTime, ...
                                                                                    impactParameterSeed, reducedParameterFitsEnabled);
                                                                                
                            end
                            
                            if ( dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).allTransitsFit.modelChiSquare==-1 ) 
                           
                                alertMessage = ['  refTime ' num2str(etime(clock, refTime), '%6.2f') ' seconds : all-transits fit with fixed impact parameter ', num2str(impactParameterSeed, '%1.2f'), ...
                                    ' of target ', num2str(iTarget), ' planet candidate ', num2str(iPlanet), ' failed after ', num2str(etime(clock,t1)), ' seconds, identifier = ', alertMessageStruct.identifier];
                                disp(alertMessage);
                                dvResultsStruct = add_dv_alert(dvResultsStruct, 'fitter', 'warning', alertMessage, iTarget, keplerId, iPlanet);
                                
                            else
                                
                                if convergenceFlag || secondaryConvergenceFlag
                                
                                    [dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).allTransitsFit, nonPhysicalParameterDetected] = ...
                                        remove_non_physical_model_parameters(dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).allTransitsFit);

                                end
                                
                                if convergenceFlag
                            
                                    disp(['  refTime ', num2str(etime(clock, refTime), '%6.2f'), ' seconds : all-transits fit with fixed impact parameter ', num2str(impactParameterSeed, '%1.2f'), ...
                                        ' of target ', num2str(iTarget), ' planet candidate ', num2str(iPlanet), ' completed with full convergence in ', num2str(etime(clock,t1)), ' seconds']);
                            
                                elseif secondaryConvergenceFlag

                                    alertMessage = ['  refTime ' num2str(etime(clock, refTime), '%6.2f') ' seconds : all-transits fit with fixed impact parameter ', num2str(impactParameterSeed, '%1.2f'), ...
                                        ' of target ', num2str(iTarget), ' planet candidate ', num2str(iPlanet), ' completed with secondary convergence after ', num2str(etime(clock,t1)), ...
                                        ' seconds, identifier = ', alertMessageStruct.identifier];
                                    disp(alertMessage);
                                    dvResultsStruct = add_dv_alert( dvResultsStruct, 'fitter', 'warning', alertMessage, iTarget, keplerId, iPlanet );
                                    
                                else
                                    
                                    alertMessage = ['  refTime ' num2str(etime(clock, refTime), '%6.2f') ' seconds : all-transits fit with fixed impact parameter ', num2str(impactParameterSeed, '%1.2f'), ...
                                        ' of target ', num2str(iTarget), ' planet candidate ', num2str(iPlanet), ' failed to converge after ', num2str(etime(clock,t1)), ...
                                        ' seconds, identifier = ', alertMessageStruct.identifier];
                                    disp(alertMessage);
                                    dvResultsStruct = add_dv_alert( dvResultsStruct, 'fitter', 'warning', alertMessage, iTarget, keplerId, iPlanet );                                    
                            
                                end                               
                            
                            end
                            
                        catch 

                            lastError = lasterror;
                            alertMessage = ['  refTime ' num2str(etime(clock, refTime), '%6.2f') ' seconds : all-transits fit with fixed impact parameter ', num2str(impactParameterSeed, '%1.2f'), ...
                                ' of target ', num2str(iTarget), ' planet candidate ', num2str(iPlanet), ' failed after ', num2str(etime(clock,t1)), ' seconds, identifier = ', lastError.identifier];
                            disp(alertMessage);
                            dvResultsStruct = add_dv_alert(dvResultsStruct, 'fitter', 'warning', alertMessage, iTarget, keplerId, iPlanet);
                            
                            dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).allTransitsFit = ...
                                reset_transit_fit_struct(dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).allTransitsFit);

                        end % try-catch block                       
                        
                        reducedParameterFits(iFit) = dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).allTransitsFit;
                        
                    end % for iFit=1:nFixedImpactParameters
                    
                    dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).reducedParameterFits = reducedParameterFits;
                    generate_plots_of_reduced_parameter_fits(dvDataObject, dvResultsStruct, iTarget, iPlanet);
                    
                    dvResultsStruct = fill_transit_fit_struct_with_tce(dvDataObject, dvResultsStruct, iTarget, iPlanet, thresholdCrossingEvent);
                    dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).allTransitsFit = ...
                        reset_transit_fit_struct(dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).allTransitsFit);
                    
                end % if reducedParameterFitsEnabled
                
                
                
                % since the all-transits, odd-transits, and even-transits fit processes are almost
                % identical, we can perform them inside a loop with appropriate execution control

                impactParameterSeed         = dvDataObject.planetFitConfigurationStruct.impactParameterSeed;
                allTransitsFitSuccessful    = true;
                reducedParameterFitsEnabled = false;
                
                for oddEvenFlag = 0:1

                    % define the odd-even-all keyword
                    switch oddEvenFlag
                        case 0
                            oddEvenKeyword = 'all';
                        case 1
                            oddEvenKeyword = 'odd-even';
                        case 2
                            oddEvenKeyword = 'individual';
                    end

                    % always perform the fit when we are on all-transits case; 
                    % for odd-even, do it only if all-transits succeeded

                    if oddEvenFlag == 0 || allTransitsFitSuccessful

                        % Since a host of exciting errors can occur deep down in the fitter,
                        % use a try-catch block to manage the error and keep DV as a whole
                        % executing even if individual fits fail out.
                        disp(' ');
                        disp(['  refTime ' num2str(etime(clock, refTime), '%6.2f') ' seconds : Starting ', oddEvenKeyword, '-transits fit of target ', num2str(iTarget), ', planet candidate ', num2str(iPlanet)]);
                        
                        try 
                        
                            t1 = clock;
                            if whitenerIterationsEnabled
                                
                                [dvResultsStruct, convergenceFlag, secondaryConvergenceFlag, alertMessageStruct] = ...
                                    perform_iterative_whitening_and_model_fitting(dvDataObject, dvResultsStruct, thresholdCrossingEvent, iTarget, iPlanet, oddEvenFlag, fitTimeoutDatenum, refTime, ...
                                                                                    impactParameterSeed, reducedParameterFitsEnabled);
                                                                                
                            else
                                
                                [dvResultsStruct, convergenceFlag, secondaryConvergenceFlag, alertMessageStruct] = ...
                                    perform_whitening_and_model_fitting(dvDataObject, dvResultsStruct, thresholdCrossingEvent, iTarget, iPlanet, oddEvenFlag, fitTimeoutDatenum, refTime, ...
                                                                                    impactParameterSeed, reducedParameterFitsEnabled);
                                                                                
                            end
                            
                            planetResultsStruct = dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet);
                            planetResultsStruct = check_planet_model_parameter_validity(planetResultsStruct, unitOfWorkStart, unitOfWorkEnd, oddEvenFlag);
                            dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet) = planetResultsStruct;
                        
                            if ( (oddEvenFlag==0 && planetResultsStruct.allTransitsFit.modelChiSquare~=-1) || ...
                                 (oddEvenFlag==1 && planetResultsStruct.oddTransitsFit.modelChiSquare~=-1)  ) 
                                
                                if convergenceFlag || secondaryConvergenceFlag
                                    
                                    if oddEvenFlag==0
                                        
                                        [dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).allTransitsFit, nonPhysicalParameterDetected] = ...
                                            remove_non_physical_model_parameters(dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).allTransitsFit);
                                        
                                        if nonPhysicalParameterDetected
                                            
                                            alertMessage = ['      Semi major axis determined by Kepler''s law is non-physical for all-transits fit of target ', ...
                                                num2str(iTarget), ' planet candidate ', num2str(iPlanet), ...
                                                ', identifier = dv:perform_dv_planet_search_and_model_fitting:semiMajorAxisNonPhysical'];
                                            disp(' ');
                                            disp(alertMessage);
                                            disp(' ');
                                            dvResultsStruct = add_dv_alert(dvResultsStruct, 'fitter', 'warning', alertMessage, iTarget, keplerId, iPlanet);
                                            
                                        end
                                        
                                    else
                                        
                                        [dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).oddTransitsFit, nonPhysicalParameterDetected] = ...
                                            remove_non_physical_model_parameters(dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).oddTransitsFit);
                                        
                                        [dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).evenTransitsFit, nonPhysicalParameterDetected] = ...
                                            remove_non_physical_model_parameters(dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).evenTransitsFit);
                                        
                                    end
                                    
                                end
                                
                                if convergenceFlag
                            
                                    disp(['  refTime ' num2str(etime(clock, refTime), '%6.2f') ' seconds : ', oddEvenKeyword, '-transits fit of target ', num2str(iTarget), ' planet candidate ', num2str(iPlanet), ...
                                        ' completed with full convergence in ', num2str(etime(clock,t1)), ' seconds']);
                            
                                elseif secondaryConvergenceFlag

                                    alertMessage = ['  refTime ' num2str(etime(clock, refTime), '%6.2f') ' seconds : ', oddEvenKeyword, '-transits fit of target ', num2str(iTarget), ' planet candidate ', num2str(iPlanet), ...
                                        ' completed with secondary convergence after ', num2str(etime(clock,t1)), ' seconds, identifier = ', alertMessageStruct.identifier];
                                    disp(alertMessage);
                                    dvResultsStruct = add_dv_alert( dvResultsStruct, 'fitter', 'warning', alertMessage, iTarget, keplerId, iPlanet );
                                    
                                else
                                    
                                    alertMessage = ['  refTime ' num2str(etime(clock, refTime), '%6.2f') ' seconds : ', oddEvenKeyword, '-transits fit of target ', num2str(iTarget), ' planet candidate ', num2str(iPlanet), ...
                                        ' failed to converge after ', num2str(etime(clock,t1)), ' seconds, identifier = ', alertMessageStruct.identifier];
                                    disp(alertMessage);
                                    dvResultsStruct = add_dv_alert( dvResultsStruct, 'fitter', 'warning', alertMessage, iTarget, keplerId, iPlanet );                                    
                            
                                end
                            
                            else
                           
                                alertMessage = ['  refTime ' num2str(etime(clock, refTime), '%6.2f') ' seconds : ', oddEvenKeyword, '-transits fit of target ', num2str(iTarget), ' planet candidate ', num2str(iPlanet), ...
                                    ' failed after ', num2str(etime(clock,t1)), ' seconds, identifier = ', alertMessageStruct.identifier];
                                disp(alertMessage);
                                dvResultsStruct = add_dv_alert(dvResultsStruct, 'fitter', 'warning', alertMessage, iTarget, keplerId, iPlanet);
                                    
                                if ( oddEvenFlag==0 ) 
                                    
                                    allTransitsFitSuccessful = false;
                                    dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).allTransitsFit = ...
                                        reset_transit_fit_struct(dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).allTransitsFit);
                                
                                    fluxValues = dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).planetCandidate.initialFluxTimeSeries.values;
                                    dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).modelLightCurve.values                = zeros(size(fluxValues));
                                    dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).modelLightCurve.gapIndicators         = true(size(fluxValues));
                                    dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).whitenedModelLightCurve.values        = zeros(size(fluxValues));
                                    dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).whitenedModelLightCurve.gapIndicators = true(size(fluxValues));
                                    dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).whitenedFluxTimeSeries.values         = zeros(size(fluxValues));
                                    dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).whitenedFluxTimeSeries.gapIndicators  = true(size(fluxValues));  
                                
                                else
                                
                                    dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).oddTransitsFit = ...
                                        reset_transit_fit_struct(dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).oddTransitsFit);
                                    dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).evenTransitsFit = ...
                                        reset_transit_fit_struct(dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).evenTransitsFit);                                
                                
                                end
                                
                            end
                            
                            disp(' ');
                            
                        catch 

                            lastError = lasterror;
                            alertMessage = ['  refTime ' num2str(etime(clock, refTime), '%6.2f') ' seconds : ', oddEvenKeyword, '-transits fit of target ', num2str(iTarget), ' planet candidate ', num2str(iPlanet), ...
                                ' failed after ', num2str(etime(clock,t1)), ' seconds, identifier = ', lastError.identifier];
                            disp(alertMessage);
                            dvResultsStruct = add_dv_alert(dvResultsStruct, 'fitter', 'warning', alertMessage, iTarget, keplerId, iPlanet);
                            
                            if ( oddEvenFlag == 0)
                                
                                allTransitsFitSuccessful = false;
                                dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).allTransitsFit = ...
                                    reset_transit_fit_struct(dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).allTransitsFit);
                                
                                fluxValues = dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).planetCandidate.initialFluxTimeSeries.values;
                                dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).modelLightCurve.values                = zeros(size(fluxValues));
                                dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).modelLightCurve.gapIndicators         = true(size(fluxValues));
                                dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).whitenedModelLightCurve.values        = zeros(size(fluxValues));
                                dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).whitenedModelLightCurve.gapIndicators = true(size(fluxValues));
                                dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).whitenedFluxTimeSeries.values         = zeros(size(fluxValues));
                                dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).whitenedFluxTimeSeries.gapIndicators  = true(size(fluxValues));
                                
                            else
                                
                                dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).oddTransitsFit = ...
                                    reset_transit_fit_struct(dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).oddTransitsFit);
                                dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).evenTransitsFit = ...
                                    reset_transit_fit_struct(dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).evenTransitsFit);
                                
                            end

                        end % try-catch block
                        
                        % update user data of fit diagnostic plots
                        update_diagnostic_plot_userdata(dvDataObject, dvResultsStruct, iTarget, iPlanet, oddEvenFlag);

                    end % if oddEvenFlag==0 || allTransitsFitSuccessful

                end % loop over oddEvenFlag values
        
            end % removed-EB conditional
            
            % Subtract off the all-transits model of the transit from the flux
            % time series to produce the residual flux time series for TPS.  We
            % can't do this inside the iterative-whitening method because we need
            % to use the same residual flux time series for odd- and even-transit
            % fits as we do for all-transits fit, and only then subtract the transit
            % model from the flux time series.
            
            [dvResultsStruct] = subtract_model_transit_from_flux(dvDataObject, dvResultsStruct, iTarget, iPlanet, thresholdCrossingEvent );
            
        end % if thresholdCrossingEvent.orbitalPeriod < 0
        
        % Generate weak secondary plots for this target and planet.
        weakSecondaryStruct = thresholdCrossingEvent.weakSecondaryStruct;
        
        if weakSecondaryTestEnabled && weakSecondaryStruct.mesMad ~= -1
            dvResultsStruct = perform_dv_secondary_modeling( dvDataObject, ...
                dvResultsStruct, iTarget, iPlanet );
            dvResultsStruct = generate_weak_secondary_plots( dvDataObject, ...
                dvResultsStruct, thresholdCrossingEvent, iTarget, iPlanet );
        elseif ~weakSecondaryTestEnabled
            if iPlanet == 1
                alertMessage = 'Weak secondary diagnostic test is disabled, identifier = dv:performPlanetSearchAndModelFitting:weakSecondaryTestDisabled';
                disp( alertMessage );
                dvResultsStruct = add_dv_alert( dvResultsStruct, 'planet-search', 'warning', alertMessage, iTarget, keplerId );
            end % if
        elseif weakSecondaryStruct.mesMad == -1
            alertMessage = 'Weak secondary diagnostic results are unavailable, identifier = dv:performPlanetSearchAndModelFitting:weakSecondaryResultsUnavailable';
            disp( alertMessage );
            dvResultsStruct = add_dv_alert( dvResultsStruct, 'planet-search', 'warning', alertMessage, iTarget, keplerId, iPlanet );
        end % if / elseif / elseif
        
        disp(' ');
        disp(['refTime ' num2str(etime(clock, refTime), '%6.2f') ' seconds : Fitting of target ', num2str(iTarget), ', planet candidate ', num2str(iPlanet),' really and truly done!']);
        disp(' ');
        
        tpsTaskTimeoutSecs = floor( ( fitTimeoutDatenum - datenum(now) ) * get_unit_conversion('day2sec') );
        if tpsTaskTimeoutSecs > minTpsTaskTimeSecs

            % Search for additional planets. If the multi-planet search is 
            % not enabled or if the planet candidate limit has been reached,
            % an empty threshold crossing event structure is returned. In
            % this case only the single event statistics will be updated
            % for each trial transit pulse width given the residual flux
            % time series. If the multiple planet search is enabled and the
            % candidate limit has not yet been reached, update the single
            % event statistics, and also create a new planet results
            % structure if there is a new threshold crossing event.
            
            try

                startTime = clock;
                % Add tpsInputStruct as an output argument, since collect_results_for_metrics_file
                % needs it as an input. 
                [dvResultsStruct, thresholdCrossingEvent, tpsResults, tpsInputStruct] = conduct_additional_planet_search(dvDataObject, dvResultsStruct, iTarget, tpsTaskTimeoutSecs);
                endTime   = clock;

                elapsedSeconds = etime(endTime, startTime);
                disp(['refTime ' num2str(etime(clock, refTime), '%6.2f') ' seconds : conduct_additional_planet_search completed in ' num2str(elapsedSeconds, '%6.2f') ' seconds']);
                disp(' ');

            catch
                
                lastError = lasterror;
                alertMessage = ['Additional-planet search algorithm failed, identifier = ', lastError.identifier];
                disp(alertMessage);
                dvResultsStruct = add_dv_alert( dvResultsStruct, 'Multi-planet-search', 'warning', alertMessage, iTarget, keplerId, iPlanet );
                disp(['Additional planet searching and fitting for target ', num2str(iTarget),' shall be skipped.']);
                
                thresholdCrossingEvent = [] ;
                tpsResults = [] ;
                tpsInputStruct = [] ;
                
            end
            
            if ~isempty(tpsResults)
                
                % for dawg struct: determine the lowest empty member of the struct array
                dawgIndex = ismember([tpsDawgStruct.keplerId], []) ;
                if isempty(dawgIndex)
                    % first pass
                    dawgIndex = 1 ;
                else
                    dawgIndex = length(dawgIndex) + 1 ;
                end
                
                % collect info for dawg struct
                tpsDawgStruct(dawgIndex) = collect_results_for_dawg_file( targetStruct(iTarget), tpsResults, dvDataObject.dvCadenceTimes ) ;

                % for metrics struct: determine the lowest empty member of the struct array
                metricsIndex = ismember([tpsMetricsStruct.keplerId], []) ;
                if isempty(metricsIndex)
                    % first pass
                    metricsIndex = 1 ;
                else
                    metricsIndex = length(metricsIndex) + 1 ;
                end
                
                % collect info for metrics struct
                tpsMetricsStruct(metricsIndex) = collect_results_for_metrics_file( tpsInputStruct, tpsResults ) ;
            end
            
        else % no more planet searching
            
            alertMessage = ['Additional planet searching and fitting for target ', num2str(iTarget),' is skipped due to fit time limit exceeded, identifier = dv:performPlanetSearchAndModelFitting:fitTimeLimitExceeded'];
            disp(alertMessage);
            dvResultsStruct = add_dv_alert( dvResultsStruct, 'planet-search', 'warning', alertMessage, iTarget, keplerId, iPlanet );
            thresholdCrossingEvent = [] ;
            
        end % condition on fitTimeoutDatenum > datenum(now)
        
        disp(['refTime ' num2str(etime(clock, refTime), '%6.2f') ' seconds : Elapsed time on target ', num2str(iTarget), ', planet candidate ', num2str(iPlanet),' = ', num2str(etime(clock,timeVector)),' seconds']) ;
        
    end % while
    
    % Generate the summary plot of flux time series and transits 
    [dvResultsStruct] = generate_flux_time_series_and_transits_plots(dvDataObject, dvResultsStruct, iTarget, normalizedFluxTimeSeriesArray);
    
    % Generate plots phased whitened/unwhitened flux time series 
    plotWhitenedFluxFlag  = true;
    useTpsEpochPeriodFlag = false;
    generate_phased_flux_time_series_plots(dvDataObject, dvResultsStruct, iTarget,  plotWhitenedFluxFlag,  useTpsEpochPeriodFlag);
    generate_phased_flux_time_series_plots(dvDataObject, dvResultsStruct, iTarget, ~plotWhitenedFluxFlag,  useTpsEpochPeriodFlag);
    generate_phased_flux_time_series_plots(dvDataObject, dvResultsStruct, iTarget,  plotWhitenedFluxFlag, ~useTpsEpochPeriodFlag);
    generate_phased_flux_time_series_plots(dvDataObject, dvResultsStruct, iTarget, ~plotWhitenedFluxFlag, ~useTpsEpochPeriodFlag);
    
    generate_phased_flux_time_series_plot_by_quarter(dvDataObject, dvResultsStruct, iTarget, ~plotWhitenedFluxFlag)
    
    % Restore the default randstreams.
    if streams
        randStreams.restore_default() ;
    end % if

end % for iTarget

% Save the dawg file.
if dawgIndex
    tpsDawgStruct = tpsDawgStruct(1:dawgIndex) ;
    save tps-task-file-dawg-struct-dv.mat tpsDawgStruct ;
end

% Save the metrics file only if DV found one or more additional TCEs
if metricsIndex > 1
    tpsMetricsStruct = tpsMetricsStruct(1:metricsIndex) ;
    save tps-task-file-metrics-struct-dv.mat tpsMetricsStruct ;
end

% if requested, write the end-time to a file
timeVector = clock ;
timeString = datestr(timeVector) ;
string = [timeString,' -- fitting process completed!'] ;
if ~isempty(timingFilename)
    timingFileId = fopen(timingFilename,'at') ;
    fprintf(timingFileId,'%s\n',string) ;
    fclose(timingFileId) ;
end % if

% turn warnings on; this will force them on even if we wind up using all the catch blocks
% in the statements above

warning on all ;

% Return.
return
