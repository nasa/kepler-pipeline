function test_histogram_accumulator(path, runs)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function test_histogram_accumulator(path, runs)
%
% This function provides test data to the histogram_accumulator for one or
% more ETEM runs. The 'path' of the directory containing the local ETEM run
% subdirectories must be specified as an argument. The histograms computed
% for each of these ETEM runs will be passed as input to the histogram
% accumulator. The numbers of the run subdirectories must specified by 'runs',
% e.g. {'100100', '100200'}. Each run is processed with a single invocation
% of the histogram accumulator. A 'hac' subdirectory must also be present in
% the specified path for storage of input, output and state files.
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% INPUT:
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
%                        path: [string]  path to local ETEM run subdirectories
%                    runs: [cell array]  number strings of run subdirectories
%
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


global huffmanHistograms;

hacDir = [path '/hac'];
inputFileName = 'HacInputs-1.bin';
outputFileName = 'HacOutputs-1.bin';
hgnFilename = 'hgn_state.mat';

origDir = pwd;

hacDataStruct.firstMatlabInvocation = true;
hacDataStruct.debugFlag = 1;

for i = 1 : length(runs)
    
    runString = ['run' runs{i}];
    disp([runString ': accumulating huffman histograms (' datestr(clock) ')'])
    runDir = [path '/' runString];
    cd(runDir);
    
    load(hgnFilename, 'intervals', 'huffmanHistograms', 'runParams');
    nIntervals = length(intervals);
    nRuns = length(runParams);
    hacDataStruct.invocationCcdModule = runParams(nRuns).ccdModule;
    hacDataStruct.invocationCcdOutput = runParams(nRuns).ccdOutput;
    hacDataStruct.cadenceStart = runParams(nRuns).overallCadenceStart;
    hacDataStruct.cadenceEnd = runParams(nRuns).invocationCadenceEnd;
    compressionPerformance = runParams(nRuns).compressionPerformance;
    
    hacDataStruct.histograms = repmat(struct( ...
        'baselineInterval', [], ...
        'uncompressedBaselineOverheadRate', [], ...
        'theoreticalCompressionRate', [], ...
        'totalStorageRate', [], ...
        'histogram', [] ), [1, nIntervals]);
        
    for j = 1 : nIntervals
        hacDataStruct.histograms(j).baselineInterval = intervals(j);
        hacDataStruct.histograms(j).uncompressedBaselineOverheadRate = ...
            compressionPerformance.uncompressedBaselineOverheadRate(j);
        hacDataStruct.histograms(j).theoreticalCompressionRate = ...
            compressionPerformance.theoreticalCompressionRate(j);
        hacDataStruct.histograms(j).totalStorageRate = ...
            compressionPerformance.totalStorageRate(j);
        hacDataStruct.histograms(j).histogram = huffmanHistograms( : , j);
    end
    
    cd(hacDir);
    write_HacInputs(inputFileName, hacDataStruct);
    [inputsStruct] = read_HacInputs(inputFileName);
    [hacResultsStruct] = hac_matlab_controller(inputsStruct);
    write_HacOutputs(outputFileName, hacResultsStruct);

    hacDataStruct.firstMatlabInvocation = false;
    
    disp(['Best interval = ' int2str(hacResultsStruct.overallBestBaselineInterval) ...
        ';  Best storage rate = ' num2str(hacResultsStruct.overallBestStorageRate)]);
end  % for

cd(origDir);

return

    