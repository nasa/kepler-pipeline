% =========================================================================
% function test_spsd_robustness( flags, testDir, resultsDir )
% =========================================================================
% Perform robustness test including corner cases and regression tests.
%
% Inputs:
%     flags : A N_TESTS-element logical vector indicating which tests
%             should be performed.
%
%             flags(1) : Process problematic input from smoke
%                        test pdc-matlab-18-138, which casued an infite
%                        detection/correction loop due to inability to
%                        adequately "correct" a deep transit feature.
%             flags(2) : Process problematic data from integ run PID=5140.
%             flags(3) : Test gap handling.
%             flags(4) : Test handling of input with NO gaps.
%             flags(5) : test handling of extreme, constant, or otherwise
%                        unusual flux values.
%             flags(6) : Test handling of outliers.
%
%     testDir : Directory containing a working copy of 
%               svn+ssh://host/path/to/robustness
%     resultsDir : directory to save results
%
% Outputs: 
%     A results directory is created under testDir and populated with the
%     following files: 
%         smoke_test_result.mat
%         problem_integ5140_channel_test.mat
%         gap_handling_test.mat
%         nongap_handling_test.mat
%         extreme_value_test.mat
%         outlier_test.mat
% =========================================================================
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
function test_spsd_robustness( flags, testDir, resultsDir )

    N_TESTS = 6;

    if nargin < 1
        flags = true(N_TESTS, 1);
    end
    
    if nargin < 2
        testDir = '/path/to/robustness';
    end
    
    DO_SMOKE_TEST     = flags(1)
    DO_INTEG5140_TEST = flags(2)
    DO_GAP_TEST       = flags(3)
    DO_NONGAP_TEST    = flags(4)
    DO_VALUE_TEST     = flags(5)
    DO_OUTLIER_TEST   = flags(6)

    SMOKE_TEST_DIR            = fullfile(testDir, 'pdc-matlab-18-138');
    PROBLEM_INTEG_CHANNEL_DIR = fullfile(testDir, 'pdc-matlab-5140-191495');
    NORMAL_TASK_DIR           = fullfile(testDir, 'pdc-matlab-5140-191508');
    RESULTS_DIR               = resultsDir;
    
    if ~exist(RESULTS_DIR, 'dir')
        mkdir(RESULTS_DIR);
    end
    
    %----------------------------------------------------------------------
    % Process problematic smoke test (pdc-matlab-18-138)
    %----------------------------------------------------------------------
    if DO_SMOKE_TEST
        [inputsStruct, targetDataStruct, uhat] = load_inputs_from_task_files(SMOKE_TEST_DIR);
        cfo = spsdCorrectedFluxClass(inputsStruct, targetDataStruct, uhat);
        save(fullfile(RESULTS_DIR, 'smoke_test_result.mat'), 'cfo'); 
    end % DO_SMOKE_TEST
    
    %----------------------------------------------------------------------
    % Process problematic channel (??) from PID=5140 integ run.
    %----------------------------------------------------------------------
    if DO_INTEG5140_TEST
        [inputsStruct, targetDataStruct, uhat] = load_inputs_from_task_files(PROBLEM_INTEG_CHANNEL_DIR);    
        cfo = spsdCorrectedFluxClass(inputsStruct, targetDataStruct, uhat);
        save(fullfile(RESULTS_DIR, 'problem_integ5140_channel_test.mat'), 'cfo'); 
    end % DO_INTEG5140_TEST

    %----------------------------------------------------------------------
    % Test gap handling
    %----------------------------------------------------------------------
    if DO_GAP_TEST
        [inputsStruct, targetDataStruct, uhat] = load_inputs_from_task_files(NORMAL_TASK_DIR);
        nTargets  = length(targetDataStruct);
        nCadences = length(targetDataStruct(1).values);

        randomIndexList = randperm(nTargets);
        listIterator = 1;

        % Set gaps for one time series
        targetDataStruct(randomIndexList(listIterator)).gapIndices(:) = true;
        listIterator = listIterator + 1;

        % Random gaps for one time series
        gapInd = randi(nCadences, fix(nCadences/6), 1);
        targetDataStruct(randomIndexList(listIterator)).gapIndices(gapInd) = true;
        listIterator = listIterator + 1;

        % Gaps at end points
        gapInd = [1:100 nCadences-100+1:nCadences];
        targetDataStruct(randomIndexList(listIterator)).gapIndices(gapInd) = true;
        listIterator = listIterator + 1;

        % Gap N cadences across all targets
        gapInd = randi(nCadences, 10, 1);
        for i = 1:nTargets
            targetDataStruct(i).gapIndicators(gapInd) = true;
        end
        
        % Isolate various sized islands of valid cadences between gaps across all targets.
        gapLen = 3;
        minIslandSize = 1;
        maxIslandSize = 5;
        numOfEachIslandSize = 2;
        
        valid = ~targetDataStruct(1).gapIndicators;
        valid(1:gapLen) = false;
        valid(end-maxIslandSize:end) = false;
        
        for islandSize = minIslandSize:maxIslandSize
            for k = 1:minIslandSize
                valid = valid & circshift(valid,-1);
            end
            
            validIndices = find(valid);
            isolateInd = validIndices(randi(length(validIndices), numOfEachIslandSize, 1));
            for i = 1:nTargets
                for j = 1:length(isolateInd)
                    targetDataStruct(i).gapIndicators(isolateInd(j)-gapLen:isolateInd(j)-1) = true;
                    targetDataStruct(i).gapIndicators(isolateInd(j)+islandSize:isolateInd(j)+islandSize+gapLen-1) = true;
                end
            end
        end

        gapImage = [targetDataStruct.gapIndicators]';
        colormap([ 0 0 0; 1 1 1]);
        image(gapImage);
        gapFigFileName = fullfile(RESULTS_DIR, 'gaps_inserted.fig');
        saveas(gcf, gapFigFileName);
        
        cfo = spsdCorrectedFluxClass(inputsStruct, targetDataStruct, uhat);
        save(fullfile(RESULTS_DIR, 'gap_handling_test.mat'), 'cfo'); 
    end % DO_GAP_TEST
    
    %----------------------------------------------------------------------
    % Test handling of data WITHOUT gaps
    %----------------------------------------------------------------------
    if DO_NONGAP_TEST
        [inputsStruct, targetDataStruct, uhat] = load_inputs_from_task_files(NORMAL_TASK_DIR);
        nTargets  = length(targetDataStruct);
        nCadences = length(targetDataStruct(1).values);
        
        for i = 1:nTargets
            targetDataStruct(i).values(:) = 1e7* (ones(nCadences,1) + randi([0 10], nCadences, 1));
            targetDataStruct(i).gapIndicators(:) = false;
        end

        cfo = spsdCorrectedFluxClass(inputsStruct, targetDataStruct, uhat);
        save(fullfile(RESULTS_DIR, 'nongap_handling_test.mat'), 'cfo'); 
    end % DO_NONGAP_TEST
    
    %----------------------------------------------------------------------
    % Test handling of time series with unusual values
    %----------------------------------------------------------------------
    if DO_VALUE_TEST
        [inputsStruct, targetDataStruct, uhat] = load_inputs_from_task_files(NORMAL_TASK_DIR);
        nTargets  = length(targetDataStruct);
        nCadences = length(targetDataStruct(1).values);

        randomIndexList = randperm(nTargets);
        listIterator = 1;

        % Insert a time series containing random values in the range [0, 1e10]
        targetDataStruct(randomIndexList(listIterator)).values = randi([0 1e10], nCadences, 1);
        listIterator = listIterator + 1;

        % Insert a time series containing all zeros.
        targetDataStruct(randomIndexList(listIterator)).values(:) = 0;
        listIterator = listIterator + 1;

        % Insert a time series containing a single non-zero value.
        targetDataStruct(randomIndexList(listIterator)).values(:) = randi(1e10, 1);
        listIterator = listIterator + 1;

        % Insert a time series containing a single non-zero value with one
        % cadence containing twice that value.
        targetDataStruct(randomIndexList(listIterator)).values(:) = randi(1e10, 1);
        targetDataStruct(randomIndexList(listIterator)).values(:) = 2 * targetDataStruct(randomIndexList(listIterator)).values(:);
        listIterator = listIterator + 1;

        % Insert a time series containing all NaNs.
        targetDataStruct(randomIndexList(listIterator)).values(:) = NaN;
        listIterator = listIterator + 1;

        % Insert a time series containing all Inf.
        targetDataStruct(randomIndexList(listIterator)).values(:) = Inf;
        listIterator = listIterator + 1;

        cfo = spsdCorrectedFluxClass(inputsStruct, targetDataStruct, uhat);
        save(fullfile(RESULTS_DIR, 'extreme_value_test.mat'), 'cfo'); 

    end % DO_VALUE_TEST

    %----------------------------------------------------------------------
    % Test with outlier cadences across all targets
    %----------------------------------------------------------------------
    if DO_OUTLIER_TEST
        [inputsStruct, targetDataStruct, uhat] = load_inputs_from_task_files(NORMAL_TASK_DIR); 
        nTargets  = length(targetDataStruct);
        nCadences = length(targetDataStruct(1).values);

        % Insert outliers across all targets
        OUTLIER_FACTOR = 1.25;
        outlierInd = randi(nCadences, 10, 1);
        for i = 1:nTargets
            targetDataStruct(i).values(outlierInd) = OUTLIER_FACTOR * targetDataStruct(i).values(outlierInd);
        end

        cfo = spsdCorrectedFluxClass(inputsStruct, targetDataStruct, uhat);
        save(fullfile(RESULTS_DIR, 'outlier_test.mat'), 'cfo'); 

    end % DO_OUTLIER_TEST
        
end

function [inputsStruct, targetDataStruct, uhat] = load_inputs_from_task_files(taskDir)
    s = load(fullfile(taskDir, 'spsdCorrectedFluxObject_1.mat'));
    
    if isfield(s.spsdCorrectedFluxObject, 'inputTargetDataStruct')
        targetDataStruct = s.spsdCorrectedFluxObject.inputTargetDataStruct;
    elseif isfield(s.spsdCorrectedFluxObject.debugObject.data, 'inputTimeSeries')
        targetDataStruct = s.spsdCorrectedFluxObject.debugObject.data.inputTimeSeries;
    end
    
    if isfield(s.spsdCorrectedFluxObject, 'mapBasisVectors')
        uhat = s.spsdCorrectedFluxObject.mapBasisVectors;
    elseif isfield(s.spsdCorrectedFluxObject.debugObject.data, 'mapBasis')
        uhat = s.spsdCorrectedFluxObject.debugObject.data.mapBasis;
    end
    
    s = load(fullfile(taskDir, 'pdc-inputs-0.mat'));
    inputsStruct = s.inputsStruct;
    
    if ~isfield(inputsStruct.spsdDetectionConfigurationStruct, 'excludeWindowHalfWidth')
        inputsStruct.spsdDetectionConfigurationStruct.excludeWindowHalfWidth = 4;
    end
    
    if ~isfield(inputsStruct.spsdDetectionConfigurationStruct, 'quickSpsdEnabled')
        inputsStruct.spsdDetectionConfigurationStruct.quickSpsdEnabled = false;
    end
    
end


