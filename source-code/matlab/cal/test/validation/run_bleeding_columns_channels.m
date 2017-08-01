function run_bleeding_columns_channels(cadenceTypeString)

% To validate the bleeding columns algorithm:
%
% rerun invocation 0 for channels with bleeding columns
% using on 7.0 branch fix and compare to those in dataDir
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

if strcmpi(cadenceTypeString, 'long')
    dataDir = '/path/to/TEST/pipeline_results/photometry/lc/cal/i3817--release-7.0-at-41606--q6/';
    
elseif strcmpi(cadenceTypeString, 'short')
    
    %dataDir = '/path/to/q6/pipeline_results/q6_archive_ksop652/sc/sc-m1/';  %old Q6 tests msmear: ok
    %dataDir = '/path/to/q5/pipeline_results/q5_archive_ksop568/sc-m1/';  %old Q5 tests vsmear: no luck
    dataDir = '/path/to/q4/pipeline_results/q4_archive_ksop479/sc/';  %old Q4 tests vsmear: ok for ch23
end

mSmearChannelsWithBadCols = [...
    5; 9; 20; 21; 22; 25; 26; 30; 31; 43; 52; 53; 55; 57; 66; 73; 82; ];

vSmearChannelsWithBadCols = [6; 23; 34; 35; 36; 60; 67; ];

allChannels = [mSmearChannelsWithBadCols; vSmearChannelsWithBadCols];


for i = 1:length(allChannels)
    
    if strcmpi(cadenceTypeString, 'long')
        
        newRunDir = ['lc_channel_' num2str(allChannels(i))];
        taskfiles = get_taskfiles_from_modout('i3817-q6-cal-final.csv', 'cal', allChannels(i), dataDir);
        
    elseif strcmpi(cadenceTypeString, 'short')
        
        newRunDir = ['sc_channel_' num2str(allChannels(i))];
        %taskfiles = get_taskfiles_from_modout('Q6M1_KSOP652_SC_with-mpe_cal-task-to-mod-out-map.csv', 'cal', allChannels(i), dataDir);
        %taskfiles = get_taskfiles_from_modout('Q5M1_SC_KSOP568_cal-task-to-mod-out-map.csv', 'cal', allChannels(i), dataDir);
        taskfiles = get_taskfiles_from_modout('Q4_KSOP479_SCM1_cal-task-to-mod-out-map.csv', 'cal', allChannels(i), dataDir);
    end
    
    
    if ~isempty(taskfiles)
        taskfileName = taskfiles{1};
        
        mkdir(newRunDir)
        
        
        % load cal inputs
        load([dataDir, taskfileName '/st-0/cal-inputs-0.mat'])
        display(['........... loading CAL inputs for channel ' num2str(allChannels(i))])
        
        %------------------------------------------------------------------
        % update inputs
        %------------------------------------------------------------------
        % disable POU
        inputsStruct.pouModuleParametersStruct.pouEnabled=false;
        
        % update old 6.2 SC inputs until new SC available
        if strcmpi(cadenceTypeString, 'short')
            inputsStruct.season = 0;
            inputsStruct.moduleParametersStruct.performExpLc1DblackFit = 0;
            inputsStruct.moduleParametersStruct.performExpSc1DblackFit = 0;
            inputsStruct.moduleParametersStruct.defaultDarkCurrentElectronsPerSec = 1.0555;
            inputsStruct.moduleParametersStruct.minCadencesForCompression = 5;
            inputsStruct.moduleParametersStruct.nSigmaForFfiOutlierRejection = 2.5;
            inputsStruct.moduleParametersStruct.errorOnCoarsePointFfi = 0;
        end
        
        % shorten to 101 cadences
        inputsStruct = get_subset_of_cal_inputs(inputsStruct, 101);
        
        
        %------------------------------------------------------------------
        % extract bleeding columns; check if there are any data in bleeding
        % columns
        %------------------------------------------------------------------
        channel = convert_from_module_output(inputsStruct.ccdModule, inputsStruct.ccdOutput);
        mSmearBleedingColsOneBase = get_masked_smear_columns_to_exclude(inputsStruct.season, channel);
        vSmearBleedingColsOneBase = get_virtual_smear_columns_to_exclude(inputsStruct.season, channel);
        
        bleedingColsOneBase = [mSmearBleedingColsOneBase; vSmearBleedingColsOneBase];
        
        
        % masked and virtual input columns are the same
        validSmearColsZeroBase  = [inputsStruct.maskedSmearPixels.column];
        validSmearColsOneBase   = validSmearColsZeroBase + 1;
        
        
        if any(ismember(bleedingColsOneBase, validSmearColsOneBase))
            
            
            %------------------------------------------------------------------
            % run CAL
            %------------------------------------------------------------------
            cd(newRunDir)
            
            outputsStruct = cal_matlab_controller(inputsStruct);
            
            display(['........... running CAL for channel ' num2str(allChannels(i))])
            
            save  inputs_and_outputs inputsStruct outputsStruct
            
            display(['........... saving CAL inputs and outputs for channel ' num2str(allChannels(i))])
            
            
            %------------------------------------------------------------------
            % create logical image
            %------------------------------------------------------------------
            % output pixel/gap/column arrays now include pixels that are
            % gapped for all cadences (updated 4/5/11)
            figure;
            
            if ismember(allChannels(i), mSmearChannelsWithBadCols)
                
                outputGaps = [outputsStruct.calibratedCollateralPixels.maskedSmear.gapIndicators];
                outputColumnsZeroBase = [outputsStruct.calibratedCollateralPixels.maskedSmear.column];
                
            elseif ismember(allChannels(i), vSmearChannelsWithBadCols)
                
                outputGaps = [outputsStruct.calibratedCollateralPixels.virtualSmear.gapIndicators];
                outputColumnsZeroBase = [outputsStruct.calibratedCollateralPixels.virtualSmear.column];
            end
            
            % update columns to one base for image
            outputColumnsOneBase = outputColumnsZeroBase + 1;
            
            % allocate full nCadences x 1132 new gap array
            nCadences = length(inputsStruct.cadenceTimes.midTimestamps);
            
            newGapArray = true(nCadences, 1132);
            
            newGapArray(:, outputColumnsOneBase) = outputGaps;
            
            imagesc(newGapArray); colorbar;colormap gray
            
            xlabel(' Column Index ', 'fontsize', 12)
            ylabel(' Cadence Index ', 'fontsize', 12)
            title(['Channel ' num2str(channel) ' Bleeding Cols (one-base):' mat2str(bleedingColsOneBase)],  'fontsize', 12)
            
            fileNameStr = 'bleeding_cols_image';
            plot_to_file(fileNameStr, true, false, false);
            
            %close all;
            cd ..
        else
            
            display(['There are no pixels in the bleeding columns for channel ' num2str(allChannels(i))])
        end
        
    else
        display(['There are no pixels available for channel ' num2str(allChannels(i))])
    end
end

