function start_cal_validation(dataTypeString, quarterString, monthString, ...
    cadenceTypeString, figureDir, dataDir, taskfileMap, channelArray, invocation, ...
    savePixelDataFlag, createPlotFlag, createImageFlag, printEpsFlag, printPngFlag, ...
    skipDataCollectionFlag, existingFigurePath, createPhotometricPlotsOnly)
%
% function to collect the diagnostic figures for CAL 7.0 validation
%
% (1) This script loops over all available channels and collects collateral
%     data to create diagnostic figures to examine the black and smear
%     corrections across the focal plane array.
%
% (2) This script loops over a subset of channels (determined by the Kepler
%     Science Office) to collect the figures output by the SOC V7.0 Pipeline.
%
% (3) This script loops over the same subset of channels to reprocess a
%     subset of the photometric pixel inputs up through the 2D Black correction,
%     since these intermediate pixels aren't saved in the Pipeline due to
%     memory constraints, and then compares the output calibrated photometric
%     pixels to these 2D Black-corrected pixels.
%
% SEE KSOP-776 FOR STATUS OF DATA
%--------------------------------------------------------------------------
% Ready as of 3/15/11:
%
%   start_cal_validation('etem', 'Q6', 'M1', 'long')
%   start_cal_validation('etem', 'Q6', 'M1', 'short')
%   start_cal_validation('flight', 'Q6', 'M1', 'long')
%   start_cal_validation('flight', 'Q6', 'M2', 'long')
%   start_cal_validation('flight', 'Q6', 'M3', 'long')
%
%
% Data not available yet:
%   start_cal_validation('flight', 'Q6', 'M1', 'short')
%   start_cal_validation('flight', 'Q6', 'M2', 'short')
%   start_cal_validation('flight', 'Q6', 'M3', 'short')
%
%--------------------------------------------------------------------------
%
%
% INPUTS:
%   dataTypeString    [string] data type: 'etem' or 'flight'
%   quarterString     [string] quarter of data ('Q6')
%   monthString       [string] month of data ('M1', 'M2', ..., or 'M1-M3')
%   cadenceTypeString [string] cadence type ('long', 'short', or 'ffi')
%
%
% Addtional fields that can be preset at beginning of script:
%
%   figureDir         [string] directory to save output matfiles/figures
%   dataDir           [string] directory with flight data taskfiles
%   taskfileMap       [string] name of taskfile map (.csv file) in dataDir
%   channelArray      [array]  list of LC and SC channels to analyze
%   invocation        [scalar] LC invocation to analyze (=1 for SC)
%   uowArray          [array]  list of SC unit-of-work (cadence chunks) to analyze
%
%   savePixelDataFlag  [logical] flag to save collateral data for each channel
%   createPlotFlag     [logical] flag to create 2D plot figures
%   createImageFlag    [logical] flag to create 2D image figures
%   printEpsFlag       [logical] flag to create eps figures
%   printPngFlag       [logical] flag to createpng figures
%   skipDataCollectionFlag [logical] flag to skip collection of collateral data
%   existingFigurePath [logical] figure path if skipDataCollectionFlag = true
%
%--------------------------------------------------------------------------
%
% OUTPUT:
%
% Figures created from this function are noted in the comments of:
%
%       collect_collateral_for_validation.m
%       create_black_validation_figures.m
%       create_smear_validation_figures.m
%       collect_photometric_for_validation
%
%
%--------------------------------------------------------------------------
% Location of Q6 FFI Data
%
% FFI /path/to/TEST/pipeline_results/photometry/ffi/cal/i4117--release-7.0-at-42127--q7
%
% reprocessed with all KSOC fixes:
% dataDir = '/path/to/TEST/pipeline_results/photometry/ffi/cal/i4339--release-7.0-at-42287--q8m1/';
% dataDir = '/path/to/TEST/pipeline_results/photometry/ffi/cal/i4341--release-7.0-at-42287--q8m2/';
%--------------------------------------------------------------------------
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


%--------------------------------------------------------------------------
% set default paths for CAL 7.0 validation
%--------------------------------------------------------------------------
if strcmpi(dataTypeString, 'flight') && strcmpi(quarterString, 'Q6') && nargin < 5
    
    %figureDir = '/path/to/cal_validation/flight/';
    
    % reprocessed to include all 7.0 ksocs:
    figureDir = '/path/to/cal_validation/flight_reprocessed_april21/';
    mkdir(figureDir)
    
    
    if strcmpi(cadenceTypeString, 'long')
        
        %dataDir     = '/path/to/TEST/pipeline_results/photometry/lc/cal/i3817--release-7.0-at-41606--q6/';
        % reprocessed to include all 7.0 ksocs:
        dataDir     = '/path/to/TEST/pipeline_results/photometry/lc/cal/i4217--release-7.0-at-42287--q6/';
        
        %taskfileMap = 'i3817-q6-cal-final.csv';
        % reprocessed to include all 7.0 ksocs:
        taskfileMap = 'q6-cal-task-to-mod-out-id-map.csv';
        invocation = 7;
        
        if strcmpi(monthString, 'M1')
            
            channelArray = [19; 41; 46; 58; 10; 60; 73]; %60 and 73 are bleeding for Q6S0
            figureDir    = [figureDir 'long_cadence_m1/'];
            mkdir(figureDir)
            
        elseif strcmpi(monthString, 'M2')
            
            channelArray = 19;
            figureDir    = [figureDir 'long_cadence_m2/'];
            mkdir(figureDir)
            
        elseif strcmpi(monthString, 'M3')
            channelArray = 19;
            figureDir    = [figureDir 'long_cadence_m3/'];
            mkdir(figureDir)
        end
        
        % set the following to recreate plots from existing arrays (if the data
        % has already been collected and you want to edit or recreate figures)
        skipDataCollectionFlag = false;
        existingFigurePath     = [];
        createPhotometricPlotsOnly = false;
        
        
    elseif strcmpi(cadenceTypeString, 'short')
        
        invocation = 1;
        if strcmpi(monthString, 'M1')
            
            %dataDir     = '/path/to/TEST/pipeline_results/photometry/sc/cal/i4077--release-7.0-at-42127--q6/';
            %taskfileMap = 'q6-cal-task-to-mod-out-id-map.csv';
            
            % reprocessed to include all 7.0 ksocs:
            dataDir     = '/path/to/TEST/pipeline_results/photometry/sc/cal/i4237--release-7.0-at-42287--q6_complete_copy/';
            %dataDir     = '/path/to/TEST/pipeline_results/photometry/sc/cal/i4237--release-7.0-at-42287--q6_complete_copy/';
            taskfileMap = 'q6-cal-task-to-mod-out-id-map.csv';
            
            channelArray = [19; 46; 58; 10; 60; 73]; %channel 41 has no targets
            figureDir    = [figureDir 'short_cadence_m1/'];
            mkdir(figureDir)
            
            
        elseif strcmpi(monthString, 'M2')
            
            dataDir     = 'TBD/';
            taskfileMap = 'TBD.csv';
            
            channelArray = [19; 41; 46; 58; 10];
            figureDir    = [figureDir 'short_cadence_m2/'];
            mkdir(figureDir)
            
        elseif strcmpi(monthString, 'M3')
            
            dataDir     = 'TBD/';
            taskfileMap = 'TBD.csv';
            
            channelArray = [19; 41; 46; 58; 10];
            figureDir    = [figureDir 'short_cadence_m3/'];
            mkdir(figureDir)
        end
        
        % set the following to recreate plots from existing arrays (if the data
        % has already been collected and you want to edit or recreate figures)
        skipDataCollectionFlag = true;
        existingFigurePath     = '/path/to/cal_validation/flight_reprocessed_april21/short_cadence_m1/collateral/';
        createPhotometricPlotsOnly = true;
        
        
    end
    
    savePixelDataFlag         = true;
    createPlotFlag            = true;
    createImageFlag           = true;
    printEpsFlag              = true;
    printPngFlag              = true;
    
    
end


if strcmpi(dataTypeString, 'etem') && strcmpi(quarterString, 'Q6') && nargin < 5
    
    figureDir = '/path/to/cal_validation/etem/';
    mkdir(figureDir)
    
    
    if strcmpi(cadenceTypeString, 'long')
        
        dataDir     = '/path/to/TEST/pipeline_results_etem/photometry/lc/cal/i16--release-7.0-at-41630/';
        taskfileMap = '';
        invocation = 7;
        
        % we only examine 1 month (1 taskfile) for cal-etem validation
        channelArray = 19;
        figureDir    = [figureDir 'long_cadence_m1/'];
        mkdir(figureDir)
        
    elseif strcmpi(cadenceTypeString, 'short')
        
        dataDir     = '/path/to/TEST/pipeline_results_etem/photometry/sc/cal/i21--release-7.0-at-41630/';
        taskfileMap = '';
        invocation = 1;
        
        channelArray = 19;
        figureDir    = [figureDir 'short_cadence_m1/'];
        mkdir(figureDir)
    end
    
    savePixelDataFlag         = true;
    createPlotFlag            = true;
    createImageFlag           = true;
    printEpsFlag              = true;
    printPngFlag              = true;
    
    % set the following to recreate plots from existing arrays (if the data
    % has already been collected and you want to just edit or recreate figures)
    skipDataCollectionFlag = false;
    
    %  set the following if skipDataCollectionFlag=true
    existingFigurePath     = [];  %'/path/to/cal_validation/etem/long_cadence_m1/collateral/';
end


if ~createPhotometricPlotsOnly
    %--------------------------------------------------------------------------
    % create figure path to collect collateral data and figures
    %--------------------------------------------------------------------------
    if ~skipDataCollectionFlag
        
        collateralFigurePath  = [figureDir 'collateral/'];
        mkdir(collateralFigurePath)
    else
        collateralFigurePath = existingFigurePath;
    end
    
    
    %--------------------------------------------------------------------------
    % collect the relevant black/smear data from the available data dirs
    %--------------------------------------------------------------------------
    if ~skipDataCollectionFlag
        
        collect_collateral_for_validation(dataTypeString, cadenceTypeString, ...
            dataDir, collateralFigurePath, taskfileMap, savePixelDataFlag, channelArray)
        
        eval(['save ' figureDir, 'val_' dataTypeString '_' cadenceTypeString '_' quarterString '_' monthString '_results.mat'])
    end
    
    
    
    %--------------------------------------------------------------------------
    % create the black residual images (median values across the FPA)
    %--------------------------------------------------------------------------
    create_black_validation_figures(dataTypeString, quarterString, cadenceTypeString, monthString, ...
        collateralFigurePath, createPlotFlag, createImageFlag, printEpsFlag, printPngFlag)
    
    
    %--------------------------------------------------------------------------
    % create the smear/dark images (median values across the FPA)
    %--------------------------------------------------------------------------
    create_smear_validation_figures(dataTypeString, quarterString, cadenceTypeString, monthString, ...
        collateralFigurePath, createPlotFlag, createImageFlag, printEpsFlag, printPngFlag)
    
else
    collateralFigurePath  = [figureDir 'collateral/'];
end


%--------------------------------------------------------------------------
% collect and plot the photometric pixels for select channels
%--------------------------------------------------------------------------
photometricFigurePath  = [figureDir 'photometric/'];
mkdir(photometricFigurePath)

for i = 1:length(channelArray)
    
    if strcmpi(dataTypeString, 'flight')
        
        taskMapFile = dir([dataDir '*cal*csv*']);
        
        % extract all taskfiles;  there should be three taskfiles for LC (one
        % per month), and numerous taskfiles for SC (one per uow).  Generally,
        % only the first taskfile for LC is populated except for channel 19 in
        % which case the first three taskfiles are populated (one per month).
        % For each SC directory (each month), only the first taskfile is
        % populated for each channel, except for channel 19 in which all
        % cadence chunks should be available
        taskfiles = [];
        for k = 1:length(taskMapFile)
            
            taskfilesTmp = get_taskfiles_from_modout(taskMapFile(k).name, 'cal', channelArray(i), dataDir);
            
            taskfiles = [taskfiles; taskfilesTmp]; %#ok<AGROW>
        end
        
        
        % for LC, create figures for each channel in channelArray for the given
        % month (for flight data, M1 includes all select channels, M2 and M3 includes
        % channel 19 only; for etem data, only M1 is available)
        if strcmpi(cadenceTypeString, 'long')
            
            if strcmpi(monthString, 'M1')
                
                taskfileDir = [dataDir cell2mat(taskfiles(1)) '/'];
                
            elseif strcmpi(monthString, 'M2')
                
                taskfileDir = [dataDir cell2mat(taskfiles(2)) '/'];
                
            elseif strcmpi(monthString, 'M3')
                
                taskfileDir = [dataDir cell2mat(taskfiles(3)) '/'];
            end
            
            
            validDir = exist(taskfileDir, 'dir');
            
            % proceed if there is valid data in the taskfile
            if validDir == 7
                
                % collect and plot the photometric data
                collect_photometric_for_validation(dataTypeString, quarterString, ...
                    monthString, cadenceTypeString, taskfileDir, photometricFigurePath, ...
                    collateralFigurePath, invocation, [], printEpsFlag, printPngFlag)
            end
            
            
            % for SC, create figures for each channel in channelArray for the given
            % month using the first unit-of-work. For channel 19, month 1 use the
            % first three invocations (first three taskfiles in directory)
        elseif strcmpi(cadenceTypeString, 'short')
            
            if strcmpi(monthString, 'M1') && (channelArray(i) == 19)
                
                uowArray = 1:3;
            else
                uowArray = 1;
            end
            
            for k = 1:length(uowArray)
                
                taskfileDir = [dataDir cell2mat(taskfiles(k)) '/'];
                
                validDir = exist(taskfileDir, 'dir');
                
                % proceed if there is valid data in the taskfile
                if validDir == 7
                    
                    % collect and plot the photometric data
                    collect_photometric_for_validation(dataTypeString, quarterString, ...
                        monthString, cadenceTypeString, taskfileDir, photometricFigurePath, ...
                        collateralFigurePath, invocation, uowArray(k), printEpsFlag, printPngFlag)
                end
            end
        end
        
    elseif strcmpi(dataTypeString, 'etem')
        
        % for etem validation, only one taskfile is available for each SC/LC
        taskfile = dir([dataDir '/cal*']);
        
        taskfileDir = [dataDir taskfile.name];
        
        validDir = exist(taskfileDir, 'dir');
        
        % proceed if there is valid data in the taskfile
        if validDir == 7
            
            % collect and plot the photometric data
            collect_photometric_for_validation(dataTypeString, quarterString, ...
                monthString, cadenceTypeString, taskfileDir, photometricFigurePath, ...
                collateralFigurePath, invocation, 1, printEpsFlag, printPngFlag)
        end
    end
end


return;
