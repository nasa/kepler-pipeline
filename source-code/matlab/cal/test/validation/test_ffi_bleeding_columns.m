function test_ffi_bleeding_columns()

% To validate the bleeding columns algorithm:
%
% rerun invocation 0 for any channel with bleeding columns
% using on 7.0 branch fix and examine outputs
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


load('/path/to/matlab/data_cal/ffi_data/cal-matlab-6-76-FFI-data/cal-inputs-0.mat')

mSmearChannelsWithBadCols = [...
    5; 9; 20; 21; 22; 25; 26; 30; 31; 43; 52; 53; 55; 57; 66; 73; 82; ];

vSmearChannelsWithBadCols = [6; 23; 34; 35; 36; 60; 67; ];

allChannels = [mSmearChannelsWithBadCols; vSmearChannelsWithBadCols];


for i = 1:length(allChannels)
    
    newRunDir = ['ffi_channel_' num2str(allChannels(i))];
    
    mkdir(newRunDir)
    
    
    %------------------------------------------------------------------
    % update inputs
    %------------------------------------------------------------------
    
    % modify inputs so this appears to be a bleeding channel
    [mod out] = convert_to_module_output(allChannels(i));
    
    inputsStruct.ccdModule = mod;
    inputsStruct.ccdOutput = out;
    
    % disable POU
    inputsStruct.pouModuleParametersStruct.pouEnabled=false;
    
    % update old 6.2 inputs
    
    inputsStruct.season = 0;
    inputsStruct.moduleParametersStruct.performExpLc1DblackFit = 0;
    inputsStruct.moduleParametersStruct.performExpSc1DblackFit = 0;
    inputsStruct.moduleParametersStruct.defaultDarkCurrentElectronsPerSec = 1.0555;
    inputsStruct.moduleParametersStruct.minCadencesForCompression = 5;
    inputsStruct.moduleParametersStruct.nSigmaForFfiOutlierRejection = 2.5;
    inputsStruct.moduleParametersStruct.errorOnCoarsePointFfi = 0;
    
    
    %------------------------------------------------------------------
    % run CAL
    %------------------------------------------------------------------
    cd(newRunDir)
    
    outputsStruct = cal_matlab_controller(inputsStruct);
    
    display(['........... running CAL FFI for channel ' num2str(allChannels(i))])
    
    save  inputs_and_outputs inputsStruct outputsStruct
    
    display(['........... saving CAL inputs and outputs for FFI channel ' num2str(allChannels(i))])
    
    
    %------------------------------------------------------------------
    % create logical image
    %------------------------------------------------------------------
    % output pixel/gap/column arrays do not include pixels that are
    % gapped for all cadences, therefore reconstruct the array
    
    mSmearBleedingCols = get_masked_smear_columns_to_exclude(inputsStruct.season, allChannels(i));
    vSmearBleedingCols = get_virtual_smear_columns_to_exclude(inputsStruct.season, allChannels(i));
    
    bleedingCols = [mSmearBleedingCols; vSmearBleedingCols];
    
    figure;
    
    if ismember(allChannels(i), mSmearChannelsWithBadCols)
        
        outputGaps = [outputsStruct.calibratedCollateralPixels.maskedSmear.gapIndicators];
        outputColumns = [outputsStruct.calibratedCollateralPixels.maskedSmear.column];
        
    elseif ismember(allChannels(i), vSmearChannelsWithBadCols)
        
        outputGaps = [outputsStruct.calibratedCollateralPixels.virtualSmear.gapIndicators];
        outputColumns = [outputsStruct.calibratedCollateralPixels.virtualSmear.column];
    end
    
    nCadences = length(inputsStruct.cadenceTimes.midTimestamps);
    
    % allocate full nCadences x 1132 new gap array
    newGapArray = true(nCadences, 1132);
    
    % fill in valid columns with valid gap indicators
    newGapArray(:, outputColumns) = outputGaps;
    
    imagesc(newGapArray); colorbar;colormap gray
    
    xlabel(' Column Index ', 'fontsize', 12)
    ylabel(' Cadence Index ', 'fontsize', 12)
    title(['Channel ' num2str(allChannels(i)) ' Bleeding Cols:' mat2str(bleedingCols)],  'fontsize', 12)
    
    fileNameStr = 'bleeding_cols_image';
    plot_to_file(fileNameStr, true, false, false);
    
    %close all;
    cd ..
    
end

