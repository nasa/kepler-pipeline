function self = test_perform_dv_centroid_tests(self)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function self = test_perform_dv_centroid_tests(self)
% 
% This function loads ETEM2 test data which has been processed through DV
% to the point in the dv_matlab_controller where perform_dv_centroid_tests
% is called. The raw data is from a small collection of targets containing
% several types of transit signatures (see comments under 'pick test 
% target KeplerIDs'below). The ground truth from which this raw data was
% generated is also read in and used to populate the model fit parameters
% in the dvResultsStruct. A simulated transit signature is also injected
% into the centroid time series for each target.
% 
%    Test:
%       Run perform_dv_centroid_tests on a subset of the data avaiable in
%       the dvDataStruct including a simulated transit signature injected
%       into the centroid time series (both prf and flux weighted
%       centroids).
%
%    Expected results:
%       1) Peak row and column offset detected must match injected offset
%          within max_sigma * propagated uncertainty.
%       2) Gapped centroid timeseries must return default statistics.
%
% If any of the above checks fail, an error condition occurs.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%  Use a test runner to run the test method:
%  Example: run(text_test_runner, testDvDataClass('test_perform_dv_centroid_tests'));
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
%     max_sigma                 number of sigmas allowed for agreement between 
%                               injected and measured transit signal
%     raOffset                 row offset of injected transit signal (pixels)
%     decOffset                 column offset of injected transit signal (pixels)
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
% 5) Inject simulated transit signal into all selected targets as last
%    planet and update dvResultsStruct with the model for this simulated
%    transit.
% 6) Make plot directories.
% 7) Run perform_dv_centroid_tests and produce output (an updated
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
delete temp_workspace.mat


%% Hard coded test parameters

% conversions
ARCS_OVER_DEGREES = 60*60*24/360;

% number of sigma agreement required for detection of injected transit signal
max_sigma = 6;

% select debugLevel
debugLevel = 0;

% pick test target KeplerIDs from 8/30/09 set
test_target_keplerIDs = [5097847,...
                         5360750,...
                         5184620,...
                                ];
                            
% choose paramters of simulated transit signal
raOffset = 0.050;                  % arcs
decOffset = -0.030;                % arcs
epochBaryMjd = 55013;           % Mjd days
period = 19.1;                  % days
duration = 12.6;                % hours
                            
% get Kepler Barycentric Julian Date epoch from epochBaryMjd
% these are the units currently used by the transit model generator and
% what is expected in the model fit parameters
% (5/25/2010)
epochBaryBkjd = epochBaryMjd - kjd_offset_from_mjd;


%% Set up paths for test-data and test-meta data
initialize_soc_variables;
testDataRepo = [socTestDataRoot filesep 'dv' filesep 'unit-tests' filesep 'centroidtest'];
testMetaDataRepo = [socTestMetaDataRoot filesep 'dv' filesep 'unit-tests' filesep 'centroidtest'];                                          %#ok<NASGU>
addpath(testDataRepo);

% data filenames
testDataFile        = 'centroidUnitTestData.mat';
groundTruthFile     = 'dvGroundTruth.mat';
resultsFile         = 'centroidUnitTestResults.mat';

%% Read test data

disp(mfilename('fullpath'));

% load dv data and results struct
disp(['Loading ',testDataFile,' ...']);
load(testDataFile);

% TODO Delete if test data updated.
dvDataStruct = dv_convert_62_data_to_70(dvDataStruct);                                                                                      %#ok<NODEF>
dvDataStruct = dv_convert_70_data_to_80(dvDataStruct); 
dvDataStruct = dv_convert_80_data_to_81(dvDataStruct); 

% load truth file
disp(['Loading ',groundTruthFile,' ...']);
load(groundTruthFile);

% remove results file and old plots
delete(resultsFile);
delete_dv_centroid_plots(dvResultsStruct);                                                                                                  %#ok<NODEF>

%% Make substruct of dvInputsStruct

% set debug level
dvDataStruct.dvConfigurationStruct.debugLevel = debugLevel;

% update spice directory
dvDataStruct.raDec2PixModel.spiceFileDir = fullfile(socTestDataRoot, 'fc', 'spice');

% parse the dv structs down to only test targets
test_target_idx = find(ismember([dvDataStruct.targetStruct.keplerId],test_target_keplerIDs));
dvDataStruct.targetStruct = dvDataStruct.targetStruct(test_target_idx);
dvResultsStruct.targetResultsStruct = dvResultsStruct.targetResultsStruct(test_target_idx);

%% Inject simulated signaland update dvResultsStruct with ground truth

% make the data object
dvDataObject = dvDataClass(dvDataStruct);

% add the blobs
dvDataObject = convert_dv_blobs(dvDataObject);

% update model fit with ground truth
dvResultsStruct = update_transit_model_with_truth(dvResultsStruct,...
                                                    dvTargetList,...
                                                    dvBackgroundBinaryList,...
                                                    dvDataStruct.raDec2PixModel);

% inject simulated transit signal into all selected targets as last planet in list
for iTarget = 1:length(test_target_keplerIDs)
    [dvDataObject, dvResultsStruct] = ...
        inject_transit_signature_into_centroid_data(dvDataObject,...
                                                    dvResultsStruct,...
                                                    iTarget,...
                                                    raOffset/ARCS_OVER_DEGREES,...
                                                    decOffset/ARCS_OVER_DEGREES,...
                                                    epochBaryBkjd,...
                                                    period,...
                                                    duration);
end

% make directories for plots
dvResultsStruct = create_directories_for_dv_figures(dvDataObject, dvResultsStruct);

% delete stale plots
delete_dv_centroid_plots(dvResultsStruct);

%% Run centroid tests

% run perform_dv_centroid_tests and the assert tests in a try/catch loop so current working directory and warning state will be restored on error

try
    
    warningState = warning('query','all');
    warning off all;

    disp(' ');
    
    testResultsStruct = perform_dv_centroid_tests( dvDataObject, dvResultsStruct );
    
    save(resultsFile,'testResultsStruct');


%% check test output against expected results

    % Peak ra and dec offset detected must match injected offset within max_sigma.

    disp(' ');
    disp('Test for correct detection of injected transit signal...');
    disp(['Injected ra/dec offset sigma threshold = ',num2str(max_sigma),' sigma.']);

    for iTarget = 1:length(test_target_keplerIDs)

        % check prf centroid results for last planet (injected signal)
        prfRaValue = ...
            [testResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(end).centroidResults.prfMotionResults.peakRaOffset.value];
        prfRaUnc = ...
            [testResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(end).centroidResults.prfMotionResults.peakRaOffset.uncertainty];
        prfDecValue = ...
            [testResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(end).centroidResults.prfMotionResults.peakDecOffset.value];
        prfDecUnc = ...
            [testResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(end).centroidResults.prfMotionResults.peakDecOffset.uncertainty];

        if( prfRaUnc ~= -1 )                                                                                                                %#ok<*BDSCI>
            numSigma = abs( prfRaValue - raOffset ) / prfRaUnc;
            if( numSigma < max_sigma )
                sigmaTestResult = 'PASS';
            else
                sigmaTestResult = 'FAIL';
            end                
            disp(['Target ',num2str(testResultsStruct.targetResultsStruct(iTarget).keplerId),...
                ' prf ra offset estimate agreement = ',num2str(numSigma),' sigma   ',sigmaTestResult]);
            assert( numSigma < max_sigma,...
                'Measured prf peakRaOffset does not agree with injected value within sigma threshold.');
        end
        if( prfDecUnc ~= -1 )
            numSigma = abs( prfDecValue - decOffset ) / prfDecUnc;
            if( numSigma < max_sigma )
                sigmaTestResult = 'PASS';
            else
                sigmaTestResult = 'FAIL';
            end
            disp(['Target ',num2str(testResultsStruct.targetResultsStruct(iTarget).keplerId),...
                ' prf dec offset estimate agreement =  ',num2str(numSigma),' sigma   ',sigmaTestResult]);
            assert( numSigma < max_sigma,...
                'Measured prf peakDecOffset does not agree with injected value within sigma threshold.');
        end

        % check flux weighted centroid results for last planet (injected signal)
        fluxWeightedRaValue = ...
            [testResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(end).centroidResults.fluxWeightedMotionResults.peakRaOffset.value];
        fluxWeightedRaUnc = ...
            [testResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(end).centroidResults.fluxWeightedMotionResults.peakRaOffset.uncertainty];
        fluxWeightedDecValue = ...
            [testResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(end).centroidResults.fluxWeightedMotionResults.peakDecOffset.value];
        fluxWeightedDecUnc = ...
            [testResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(end).centroidResults.fluxWeightedMotionResults.peakDecOffset.uncertainty];

        if( fluxWeightedRaUnc ~= -1 )
            numSigma = abs( fluxWeightedRaValue - raOffset ) / fluxWeightedRaUnc;
            if( numSigma < max_sigma )
                sigmaTestResult = 'PASS';
            else
                sigmaTestResult = 'FAIL';
            end
            disp(['Target ',num2str(testResultsStruct.targetResultsStruct(iTarget).keplerId),...
                ' flux weighted ra offset estimate agreement =  ',num2str(numSigma),' sigma   ',sigmaTestResult]);
            assert( numSigma < max_sigma,...
                'Measured flux weighted peakRaOffset does not agree with injected value within sigma threshold.');
        end
        if( fluxWeightedDecUnc ~= -1 )
            numSigma = abs( fluxWeightedDecValue - decOffset ) / fluxWeightedDecUnc;
            if( numSigma < max_sigma )
                sigmaTestResult = 'PASS';
            else
                sigmaTestResult = 'FAIL';
            end
            disp(['Target ',num2str(testResultsStruct.targetResultsStruct(iTarget).keplerId),...
                ' flux weighted dec offset estimate agreement =  ',num2str(numSigma),' sigma   ',sigmaTestResult]);
            assert( numSigma < max_sigma,...
                'Measured flux weighted peakDecOffset does not agree with injected value within sigma threshold.');
        end
    end


    %% check that gapped centroid timeseries returns default statistics
    % If centroid time series data is missing (all gapped) the motion results
    % must indicate no result i.e. uncertainty == -1, value == 0 for all
    % results.

    disp(' ');
    disp('Test for correct default values of motion results ...');
    
    for iTarget = 1:length(test_target_keplerIDs)

        % check default prfCentroid motion results
        
        nPlanets = length(testResultsStruct.targetResultsStruct(iTarget).planetResultsStruct);        
        planetPass = true(nPlanets,1);

        if( all(dvDataStruct.targetStruct(iTarget).centroids.prfCentroids.columnTimeSeries.gapIndicators) || ...
                all(dvDataStruct.targetStruct(iTarget).centroids.prfCentroids.rowTimeSeries.gapIndicators) )
                  
            for iPlanet = 1:nPlanets

                prfMotionStatisticValue = ...
                    [testResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).centroidResults.prfMotionResults.motionDetectionStatistic.value];
                prfMotionStatisticSig = ...
                    [testResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).centroidResults.prfMotionResults.motionDetectionStatistic.significance];

                prfRaValue = ...
                    [testResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).centroidResults.prfMotionResults.peakRaOffset.value];
                prfRaUnc = ...
                    [testResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).centroidResults.prfMotionResults.peakRaOffset.uncertainty];

                prfDecValue = ...
                    [testResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).centroidResults.prfMotionResults.peakDecOffset.value];
                prfDecUnc = ...
                    [testResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).centroidResults.prfMotionResults.peakDecOffset.uncertainty];

                prfSourceRaOffsetValue = ...
                    [testResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).centroidResults.prfMotionResults.sourceRaOffset.value];
                prfSourceRaOffsetUnc = ...
                    [testResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).centroidResults.prfMotionResults.sourceRaOffset.uncertainty];

                prfSourceDecOffsetValue = ...
                    [testResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).centroidResults.prfMotionResults.sourceDecOffset.value];
                prfSourceDecOffsetUnc = ...
                    [testResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).centroidResults.prfMotionResults.sourceDecOffset.uncertainty];

                prfSourceRaValue = ...
                    [testResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).centroidResults.prfMotionResults.sourceRaHours.value];
                prfSourceRaUnc = ...
                    [testResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).centroidResults.prfMotionResults.sourceRaHours.uncertainty];

                prfSourceDecValue = ...
                    [testResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).centroidResults.prfMotionResults.sourceDecDegrees.value];
                prfSourceDecUnc = ...
                    [testResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).centroidResults.prfMotionResults.sourceDecDegrees.uncertainty];

                
                motionStatPass = true(7,1);
                
                motionStatPass(1) = prfMotionStatisticValue == -1 & prfMotionStatisticSig == -1;
                motionStatPass(2) = prfRaValue == 0 & prfRaUnc == -1;
                motionStatPass(3) = prfDecValue == 0 & prfDecUnc == -1;
                motionStatPass(4) = prfSourceRaOffsetValue == 0 & prfSourceRaOffsetUnc == -1;
                motionStatPass(5) = prfSourceDecOffsetValue == 0 & prfSourceDecOffsetUnc == -1;
                motionStatPass(6) = prfSourceRaValue == 0 & prfSourceRaUnc == -1;
                motionStatPass(7) = prfSourceDecValue == 0 & prfSourceDecUnc == -1;
                
                planetPass(iPlanet) = all(motionStatPass);                            

                assert( motionStatPass(1),'prf motionDetectionStatistic not default value for gapped centroid time series.');
                assert( motionStatPass(2),'prf peakRaOffset not default value for gapped centroid time series.');
                assert( motionStatPass(3),'prf peakDecOffset not default value for gapped centroid time series.');
                assert( motionStatPass(4),'prf sourceRaOffset not default value for gapped centroid time series.');
                assert( motionStatPass(5),'prf sourceDecOffset not default for gapped centroid time series.');
                assert( motionStatPass(6),'prf sourceRaHours not default value for gapped centroid time series.');
                assert( motionStatPass(7),'prf sourceDecDegrees not default value for gapped centroid time series.');
            end
            
            if( all(planetPass) )
                defaultTestResult = 'PASS';
            else
                defaultTestResult = 'FAIL';
            end
            disp(['Target ',num2str(testResultsStruct.targetResultsStruct(iTarget).keplerId),...
            ' Gapped prf centroid time series produces default statistic values.     ',defaultTestResult]);           
            
        end

        % check default fluxWeightedCentroid motion results
        % This test is here for completeness. The fluxWeighted centroids 
        % should always be available so this test may never actually
        % execute.

        if( all(dvDataStruct.targetStruct(iTarget).centroids.fluxWeightedCentroids.columnTimeSeries.gapIndicators) || ...
                all(dvDataStruct.targetStruct(iTarget).centroids.fluxWeightedCentroids.rowTimeSeries.gapIndicators) )

            for iPlanet = 1:length(testResultsStruct.targetResultsStruct(iTarget).planetResultsStruct)
                fluxWeightedMotionStatisticValue = ...
                    [testResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).centroidResults.fluxWeightedMotionResults.motionDetectionStatistic.value];
                fluxWeightedMotionStatisticSig = ...
                    [testResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).centroidResults.fluxWeightedMotionResults.motionDetectionStatistic.significance];

                fluxWeightedRaValue = ...
                    [testResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).centroidResults.fluxWeightedMotionResults.peakRaOffset.value];
                fluxWeightedRaUnc = ...
                    [testResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).centroidResults.fluxWeightedMotionResults.peakRaOffset.uncertainty];

                fluxWeightedDecValue = ...
                    [testResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).centroidResults.fluxWeightedMotionResults.peakDecOffset.value];
                fluxWeightedDecUnc = ...
                    [testResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).centroidResults.fluxWeightedMotionResults.peakDecOffset.uncertainty];

                fluxWeightedSourceRaOffsetValue = ...
                    [testResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).centroidResults.fluxWeightedMotionResults.sourceRaOffset.value];
                fluxWeightedSourceRaOffsetUnc = ...
                    [testResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).centroidResults.fluxWeightedMotionResults.sourceRaOffset.uncertainty];

                fluxWeightedSourceDecOffsetValue = ...
                    [testResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).centroidResults.fluxWeightedMotionResults.sourceDecOffset.value];
                fluxWeightedSourceDecOffsetUnc = ...
                    [testResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).centroidResults.fluxWeightedMotionResults.sourceDecOffset.uncertainty];

                fluxWeightedSourceRaValue = ...
                    [testResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).centroidResults.fluxWeightedMotionResults.sourceRaHours.value];
                fluxWeightedSourceRaUnc = ...
                    [testResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).centroidResults.fluxWeightedMotionResults.sourceRaHours.uncertainty];

                fluxWeightedSourceDecValue = ...
                    [testResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).centroidResults.fluxWeightedMotionResults.sourceDecDegrees.value];
                fluxWeightedSourceDecUnc = ...
                    [testResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).centroidResults.fluxWeightedMotionResults.sourceDecDegrees.uncertainty];

                motionStatPass = true(7,1);
                
                motionStatPass(1) = fluxWeightedMotionStatisticValue == -1 & fluxWeightedMotionStatisticSig == -1;
                motionStatPass(2) = fluxWeightedRaValue == 0 & fluxWeightedRaUnc == -1;
                motionStatPass(3) = fluxWeightedDecValue == 0 & fluxWeightedDecUnc == -1;
                motionStatPass(4) = fluxWeightedSourceRaOffsetValue == 0 & fluxWeightedSourceRaOffsetUnc == -1;
                motionStatPass(5) = fluxWeightedSourceDecOffsetValue == 0 & fluxWeightedSourceDecOffsetUnc == -1;
                motionStatPass(6) = fluxWeightedSourceRaValue == 0 & fluxWeightedSourceRaUnc == -1;
                motionStatPass(7) = fluxWeightedSourceDecValue == 0 & fluxWeightedSourceDecUnc == -1;
                
                planetPass(iPlanet) = all(motionStatPass);

                assert( motionStatPass(1),'fluxWeighted motionDetectionStatistic not default value for gapped centroid time series.');
                assert( motionStatPass(2),'fluxWeighted peakRaOffset not default value for gapped centroid time series.');
                assert( motionStatPass(3),'fluxWeighted peakDecOffset not default value for gapped centroid time series.');
                assert( motionStatPass(4),'fluxWeighted sourceRaOffset not default value for gapped centroid time series.');
                assert( motionStatPass(5),'fluxWeighted sourceDecOffset not default for gapped centroid time series.');
                assert( motionStatPass(6),'fluxWeighted sourceRaHours not default value for gapped centroid time series.');
                assert( motionStatPass(7),'fluxWeighted sourceDecDegrees not default value for gapped centroid time series.');
            end
            
            if( all(planetPass) )
                defaultTestResult = 'PASS';
            else
                defaultTestResult = 'FAIL';
            end
            disp(['Target ',num2str(testResultsStruct.targetResultsStruct(iTarget).keplerId),...
                ' Gapped fluxWeighted centroid time series produces default statistic values.     ',defaultTestResult]);
            
        end
    end
    
    % save results file
    save(resultsFile,'testResultsStruct');
    
catch exception
    % restore warning state and remove path augmentation
    warning(warningState);
    rmpath(testDataRepo);
    rethrow(exception);
end

% restore warning state and remove path augmentation
warning(warningState);
rmpath(testDataRepo);

