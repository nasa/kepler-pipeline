function test_histogram_generator(path, runs, nCadencesPerChunk)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function test_histogram_generator(path, runs, nCadencesPerChunk)
%
% This function provides test data to the histogram_generator for one or
% more ETEM runs. The 'path' of the directory containing the local ETEM run
% subdirectories must be specified as an argument. The numbers of the run
% subdirectories must specified by 'runs', e.g. {'100100', '100200'}. The
% number of cadences to be processed in each invocation of the histogram
% generator is specified by 'nCadencesPerChunk'.
%
% For each ETEM run, the following files must be present in the respective
% run subdirectories: run_params_rundddddd.mat, bad_pixels_rundddddd.mat,
% quantize_rundddddd.mat and long_cadence_quant_rundddddd.dat. Input,
% output and state files will also be written to the local run
% subdirectories.
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% INPUT:
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
%                        path: [string]  path to local ETEM run subdirectories
%                    runs: [cell array]  number strings of run subdirectories
%               nCadencesPerChunk [int]  number of cadences per invocation
%                                        of the histogram generator
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


BYTES_PER_FLOAT32 = 4;
global quanttbl;

inputFileName = 'HgnInputs-1.bin';
outputFileName = 'HgnOutputs-1.bin';
origDir = pwd;

hgnDataStruct.debugFlag = 1;

hgnModuleParameters.baselineIntervals = ...
    [2 4 8 12 16 20 24 28 32 36 40 44 48 52 56 64 72 80 88 96]';
hgnDataStruct.hgnModuleParameters = hgnModuleParameters;

for i = 1 : length(runs)
    
    hgnDataStruct.firstMatlabInvocation = true;
    
    runString = ['run' runs{i}];
    disp([runString ': building huffman histograms (' datestr(clock) ')'])
    runDir = [path '/' runString];
    cd(runDir);

    etemRunParametersFilename = ['run_params_' runString '.mat'];
    load(etemRunParametersFilename);
    hgnDataStruct.ccdModule = run_params.module_number;
    hgnDataStruct.ccdOutput = run_params.output_number;
    
    badPixelFilename = ['bad_pixel_' runString '.mat'];
    load(badPixelFilename, 'kstarpix', 'kbackpix2', 'k_masked_smear', ...
        'k_virtual_smear', 'k_leading_black');
    nStarPixels = length(kstarpix);
    nBackgroundPixels = length(kbackpix2);
    nMaskedSmearPixels = length(k_masked_smear);
    nVirtualSmearPixels = length(k_virtual_smear);
    nLeadingBlackPixels = length(k_leading_black);
    nPixelsPerCadence = nStarPixels + nBackgroundPixels + nMaskedSmearPixels + ...
        nVirtualSmearPixels + nLeadingBlackPixels;
    
    % It is necessary to cast the quanttbl values to single precision for ETEM
    % data because the pixel values are stored in single precision, and then
    % round to the nearest integer because both requantization table and pixel
    % values should be integers.
    quantizationTableFilename = ['quantize_' runString '.mat'];
    load(quantizationTableFilename);
    requantTable = single((quanttbl(1 : end-1) + quanttbl(2 : end)) / 2);
    hgnDataStruct.requantTable = double(round(requantTable));
    
    longCadenceQuantFilename = ['long_cadence_quant_' runString '.dat'];
    fidLongCadenceQuant = fopen(longCadenceQuantFilename, 'r', 'ieee-le');
    fseek(fidLongCadenceQuant, 0, 'eof');
    nTotalBytes = ftell(fidLongCadenceQuant);
    frewind(fidLongCadenceQuant);
    nTotalCadences = floor((nTotalBytes/BYTES_PER_FLOAT32)/nPixelsPerCadence);
    
    cadence = 0;
    while (true)
        
        limit = min(nCadencesPerChunk, nTotalCadences - cadence);
        if limit < 1
            break;
        end
        hgnDataStruct.cadencePixels = repmat(struct( ...
            'cadence', [], ...
            'pixelValues', [], ...
            'gapIndicators', [] ), [1, limit]); 
        for j = 1 : limit
            cadence = cadence + 1;
            pixelValues = fread(fidLongCadenceQuant, [nPixelsPerCadence, 1], 'float32');
            hgnDataStruct.cadencePixels(j).cadence = -cadence;
            hgnDataStruct.cadencePixels(j).pixelValues = double(round(pixelValues));
            hgnDataStruct.cadencePixels(j).gapIndicators = ...
                repmat(false, [nPixelsPerCadence, 1]);
        end
        hgnDataStruct.invocationCadenceStart = hgnDataStruct.cadencePixels(1).cadence;
        hgnDataStruct.invocationCadenceEnd = hgnDataStruct.cadencePixels(limit).cadence;
        
        write_HgnInputs(inputFileName, hgnDataStruct);
        inputsStruct = read_HgnInputs(inputFileName);
        [hgnResultsStruct] = hgn_matlab_controller(inputsStruct);
        write_HgnOutputs(outputFileName, hgnResultsStruct);
        
        hgnDataStruct.firstMatlabInvocation = false;
        
    end  % while
    
    disp(['Best interval = ' int2str(hgnResultsStruct.modOutBestBaselineInterval) ...
        ';  Best storage rate = ' num2str(hgnResultsStruct.modOutBestStorageRate)]);
end  % for

cd(origDir);

return

    