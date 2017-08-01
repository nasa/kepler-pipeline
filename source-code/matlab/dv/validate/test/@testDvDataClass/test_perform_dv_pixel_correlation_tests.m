function self = test_perform_dv_pixel_correlation_tests(self)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function self = test_perform_dv_pixel_correlation_tests(self)
%
% 
% This function loads ETEM2 test data which has been processed through DV
% to the point in the dv_matlab_controller where perform_dv_pixel_correlation_tests
% is called. The raw data is from a small collection of targets containing
% several types of transit signatures (see comments under 'pick test 
% target KeplerIDs'below). The ground truth from which this raw data was
% generated is also read in and used to populate the model fit parameters
% in the dvResultsStruct. A simulated transit signature is also injected
% into the centroid time series for each target.
% 
%    Test:
%       Run perform_dv_pixel_correlation_tests on a subset of the data
%       avaiable in the dvDataStruct including a simulated transit
%       signature injected into the calibrated target pixel timeseries.
%
%    Expected results:
%       1) Gapped pixel timeseries must return default statistic and significance.
%       2) Pixels with injected simulated transit signal must return a
%       statistic significance above the card coded threshold (nominally
%       0.99).
%       3) The remainder of the dvResultsStruct must remain unchanged.
%
% If any of the above checks fail, an error condition occurs.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%  Use a test runner to run the test method:
%  Example: run(text_test_runner, testDvDataClass('test_perform_dv_pixel_correlation_tests'));
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


% Detailed Summary:
%
% User selected parameters (hard coded):
%     significanceThreshold     acceptance threshold for injected signal detection
%     epochBaryMjd              transit epoch of injected transit signal (mjd days)
%     period                    period of injected transit signal (days)
%     duration                  duration of injected transit signal (hours)
%     test_target_keplerIDs     list of KeplerIds from the ETEM data set to process
%
% 1) Read processed ETEM test data
%       variables:  dvDataStruct
%                   dvResultsStruct
%                   raDec2PixModel
% 2) Read ETEM ground truth
%       variables:  dvTargetList
%                   dvBackgroundBinaryList
% 3) Select targets from KeplerId list (test_target_keplerIDs). Selecting a
%    target w/o prfCentroids will exercise the default statistic value
%    test.
% 4) Update dvResultsStruct with transit models from dvGroundTruth
% 5) Inject simulated transit signal into all selected pixels as last
%    planet and update dvResultsStruct with the model for this simulated
%    transit.
% 6) Make plot directories.
% 7) Run perform_dv_pixel_correlation_tests and produce output (an updated
%    dvResultsStruct).
% 8) Check output against expected results using assert or assert_equals.
%

% Targets in ETEM data set (6/15/09):
% Index KID         Transit         Background  prfCentroids
% 
% 1     7538292     Jupiter                           
% 2     7618662     Jupiter                           y
% 3     7693242     Jupiter                           
% 4     7538367     Earth                             
% 5     7693172     Earth                             
% 6     7761004     Earth                             
% 7     7694138     Binary                            
% 8     7694539     Binary                            
% 9     7900695     Binary                            
% 10    7692284     Jupiter, Earth                    y
% 11    8037502     Jupiter, Binary                   
% 12    8175995     Earth, Binary                     
% 13    7762943                         Binary        y
% 14    7835135                         Binary        y
% 15    7903038                         Binary        y
% 
% Targets in ETEM data set (8/30/09):
% Index KID         Transit         Background  prfCentroids
% 1     5097392     Jupiter                         y
% 2     5183568     Jupiter                    
% 3     4922001     Jupiter                         y
% 4     5446068     Jupiter                    
% 5     5528728     Earth                      
% 6     5098334     Earth                      
% 7     5184620     Earth                           y
% 8     5530076     Earth                           y
% 9     5096906     Binary                          y
% 10    5357718     Binary                          y
% 11    5097847                         Binary          
% 12    5181857     Earth, Jupiter                    
% 13    5270106     Jupiter, Jupiter                    
% 14    5360750     Jupiter, Binary                     
% 15    5358499     Earth, Binary                   y

%% Clean up any stale dvDataClass definitions
save temp_workspace.mat
clear classes
load temp_workspace.mat


%% Hard coded test parameters

% significance expected for pixels with injected transit signal
significanceThreshold = 0.90;

% select debugLevel
debugLevel = 0;

% pick test target KeplerIDs from 8/30/09 set
test_target_keplerIDs = [5097847];                                                                                                          %#ok<NBRAK> % ,...
%                          5360750,...
%                          5184620,...
%                                 ];
                         
% choose paramters of simulated transit signal
fractionalTransitDepth = 1e-2;      % 10000 ppm transit signal
epochBaryMjd = 55013;               % Mjd days
period = 19.1;                      % days
duration = 12.6;                    % hours

injectTransitPixelIdx = [1,5,10];
allGappedPixelTimeSeriesIdx  = [2,6,11];
someGappedPixelTimeSeriesIdx = [3,7,12];

relativeCadencesToGap = 1:5:500;

% get Kepler Barycentric Julian Date epoch from epochBaryMjd
% these are the units currently used by the transit model generator and
% what is expected in the model fit parameters
% (5/25/2010)
epochBaryBkjd = epochBaryMjd - kjd_offset_from_mjd;


%% Set up paths for test-data and test-meta data
initialize_soc_variables;
testDataRepo = [socTestDataRoot filesep 'dv' filesep 'unit-tests' filesep 'pixelCorrelationTest'];
testMetaDataRepo = [socTestMetaDataRoot filesep 'dv' filesep 'unit-tests' filesep 'pixelCorrelationTest'];                                  %#ok<NASGU>
addpath(testDataRepo);

% data filenames
testDataFile        = 'pixelCorrelationUnitTestData.mat';
groundTruthFile     = 'dvGroundTruth.mat';
resultsFile         = 'pixelCorrelationUnitTestResults.mat';
baselineResults     = 'pixelCorrelationBaselineResults.mat';                                                                                %#ok<NASGU>

%% Read test data

disp(mfilename('fullpath'));

% load dv data and results struct
disp(['Loading ',testDataFile,' ...']);
load(testDataFile);

dvDataStruct = dv_convert_70_data_to_80(dvDataStruct); %#ok<NODEF>
dvDataStruct = dv_convert_80_data_to_81(dvDataStruct); 

% load truth file
disp(['Loading ',groundTruthFile,' ...']);
load(groundTruthFile);

% remove results file and old plots
delete(resultsFile);
delete_dv_pixel_correlation_plots(dvResultsStruct);                                                                                         %#ok<NODEF>

%% Make substruct of dvInputsStruct including only selected targets

% set debug level
dvDataStruct.dvConfigurationStruct.debugLevel = debugLevel;

% update spice directory
dvDataStruct.raDec2PixModel.spiceFileDir = fullfile(socTestDataRoot, 'fc', 'spice');

% parse the dv structs down to only test targets
test_target_idx = find(ismember([dvDataStruct.targetStruct.keplerId],test_target_keplerIDs));
dvDataStruct.targetStruct = dvDataStruct.targetStruct(test_target_idx);
dvResultsStruct.targetResultsStruct = dvResultsStruct.targetResultsStruct(test_target_idx);

%%  Update dvResultsStruct with ground truth and inject simulated transit signal and data gaps into pixel data

% make the data object
dvDataObject = dvDataClass(dvDataStruct);


% update model fit with ground truth
dvResultsStruct = update_transit_model_with_truth(dvResultsStruct,dvTargetList,dvBackgroundBinaryList,dvDataStruct.raDec2PixModel);

clear dvDataStruct;


for iTarget = 1:length(test_target_keplerIDs)
    
    % inject simulated transit signal into selected pixels for selected
    % target and model as last planet in list
    [dvDataObject, dvResultsStruct, oneBasedRowColInjected] = ...
        inject_transit_signature_into_pixel_data(dvDataObject,dvResultsStruct,...
                                                    iTarget,injectTransitPixelIdx,...
                                                    fractionalTransitDepth,epochBaryBkjd,period,duration);

    % gap all cadences of selected pixels for selected targets
    [dvDataObject] = gap_dv_pixel_timeseries(dvDataObject,iTarget,allGappedPixelTimeSeriesIdx,[]);
    
    % gap some cadences of selected pixels for selected targets
    [dvDataObject] = gap_dv_pixel_timeseries(dvDataObject,iTarget,someGappedPixelTimeSeriesIdx,relativeCadencesToGap);
                                                
end

% make directories for plots
dvResultsStruct = create_directories_for_dv_figures(dvDataObject, dvResultsStruct);

% delete stale plots
delete_dv_centroid_plots(dvResultsStruct);

%% Run pixel correlation tests

% Run perform_dv_pixel_correlation_tests and the assert tests in a try/catch loop
% Restore current working directory and warning state on error

try
    
    warningState = warning('query','all');                                                                                                  
    warning off all;
    disp(' ');
    
    testResultsStruct = perform_dv_pixel_correlation_tests( dvDataObject, dvResultsStruct );
    
    % save results file
    save(resultsFile,'testResultsStruct');

    
    %% check test output against expected results

    %     load( baselineResults );
    
    disp(' ');
    disp('TEST DEFINTIIONS');
    disp('TEST 0 - Check for successful completion using timeseries with some (but not all) gapped cadences.');
    disp('TEST 1 - Check for default values of statictic and significance for pixels with gapped timeseries.');
    disp('TEST 2 - Check for correct detection of injected transit signal.');
    disp(['   Expected significance threshold = ',num2str(significanceThreshold,'%2.4f')]);
    disp('   Signal injected as the last planet in the following zero-based row/column pairs:');
    disp(oneBasedRowColInjected-1);
    disp('TEST 3 - Check for non-corruption of the remaining (non-pixel correlation results) dvResultsStruct.');
    disp(' ');
    
    
    % make copies of results structs
    T0 = testResultsStruct;
    S0 = dvResultsStruct;
    
    for iTarget = 1:length(test_target_keplerIDs)
        
        nPlanets = length(T0.targetResultsStruct(iTarget).planetResultsStruct);
        
        T = T0.targetResultsStruct(iTarget);
        S = S0.targetResultsStruct(iTarget);
        
        for iPlanet = 1:nPlanets
            
            nTables = length(T.planetResultsStruct(iPlanet).pixelCorrelationResults);
            
            for iTable = 1:nTables
                
                val = [T.planetResultsStruct(iPlanet).pixelCorrelationResults(iTable).pixelCorrelationStatisticStruct.value];
                sig = [T.planetResultsStruct(iPlanet).pixelCorrelationResults(iTable).pixelCorrelationStatisticStruct.significance];
                
                
                % TEST 0)
                % statistic of some gapped pixel timeseries should be a valid value (~0)
                if( all( val(someGappedPixelTimeSeriesIdx) ~= 0 ) )
                    testResultString = 'PASS';
                else
                    testResultString = 'FAIL';
                end
                
                disp(['Target ',num2str(T0.targetResultsStruct(iTarget).keplerId),...
                    ' - Target table ',num2str(T.planetResultsStruct(iPlanet).pixelCorrelationResults(iTable).targetTableId),...
                    ' - Planet ',num2str(iPlanet),' TEST (1) - Default statistic test:              ',testResultString]);
                assert( all( val(someGappedPixelTimeSeriesIdx) ~= 0 ),...
                    'Detection statistic for pixels with all gapped timeseries not valid value but 0');
                
                                
                
                % TEST 1)
                % statistic of all gapped pixel timeseries should be default value (0)
                if( all( val(allGappedPixelTimeSeriesIdx) == 0 ) )
                    testResultString = 'PASS';
                else
                    testResultString = 'FAIL';
                end
                
                disp(['Target ',num2str(T0.targetResultsStruct(iTarget).keplerId),...
                    ' - Target table ',num2str(T.planetResultsStruct(iPlanet).pixelCorrelationResults(iTable).targetTableId),...
                    ' - Planet ',num2str(iPlanet),' TEST (1) - Default statistic test:              ',testResultString]);
                assert( all( val(allGappedPixelTimeSeriesIdx) == 0 ),...
                    ['Detection statistic for pixels with all gapped timeseries not default value (0) but [',...
                    num2str(val(allGappedPixelTimeSeriesIdx)),']']);
                
                % significance of all gapped pixel timeseries should be default value (-1)
                if( all( sig(allGappedPixelTimeSeriesIdx) == -1 ) )
                    testResultString = 'PASS';
                else
                    testResultString = 'FAIL';
                end
                
                disp(['Target ',num2str(T0.targetResultsStruct(iTarget).keplerId),...
                    ' - Target table ',num2str(T.planetResultsStruct(iPlanet).pixelCorrelationResults(iTable).targetTableId),...
                    ' - Planet ',num2str(iPlanet),' TEST (1) - Default statistic significance test: ',testResultString]);
                assert( all( sig(allGappedPixelTimeSeriesIdx) == -1 ),...
                    ['Detection statistic significance for pixels with all gapped timeseries not default value (-1) but [',...
                    num2str(sig(allGappedPixelTimeSeriesIdx)),']']);
                
                % TEST 2)
                if( iPlanet == nPlanets )
                    % injected signal model is captured as then last planet
                    % significance of all pixels with injcted signal should be above threshold
                    if( all(sig(injectTransitPixelIdx) > significanceThreshold) )
                        testResultString = 'PASS';
                    else
                        testResultString = 'FAIL';
                    end
                    
                    disp(['Target ',num2str(T0.targetResultsStruct(iTarget).keplerId),...
                        ' - Target table ',num2str(T.planetResultsStruct(iPlanet).pixelCorrelationResults(iTable).targetTableId),...
                        ' TEST (2) - Correlation statistic significance test: ',testResultString]);
                    assert( all(sig(injectTransitPixelIdx) > significanceThreshold),...
                        ['Detection statistic significance for pixels with injected signal not above threshold (',num2str(significanceThreshold),...
                        ') but above ',num2str(min(sig(injectTransitPixelIdx)))]);
                end
            end
        end
        
        % remove pixel correlation test results for this planet from copies of results structs
        T = rmfield(T.planetResultsStruct,'pixelCorrelationResults');
        S = rmfield(S.planetResultsStruct,'pixelCorrelationResults');
        T0.targetResultsStruct(iTarget).planetResultsStruct = T;
        S0.targetResultsStruct(iTarget).planetResultsStruct = S;
    end
    
    % remove alerts
    T0 = rmfield(T0,'alerts');
    S0 = rmfield(S0,'alerts');
    
    % TEST 3)
    % compare T0 and S0
    s_result = isequalStruct(T0,S0);
    if( s_result )
        testResultString = 'PASS';
    else
        testResultString = 'FAIL';
    end
    disp(['TEST (3) - dvResultsStruct corruption test: ',testResultString]);
    assert( s_result, 'dvResultsStruct corrupted by pixel correlation test.' );  
    
    
catch exception
    % restore warning state and remove path augmentation
    warning(warningState);
    rmpath(testDataRepo);
    rethrow(exception);
end

% restore warning state and remove path augmentation
warning(warningState);
rmpath(testDataRepo);
