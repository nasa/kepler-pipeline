function start_cal_data_review(quarterString, monthString, cadenceTypeString, ...
    figureDir, dataDir, taskfileMap, channelArray, invocation, savePixelDataFlag, ...
    dawgFigureFlag, skipDataCollectionFlag, collateralFigurePath)
%
% function to create and collect diagnostic figures for use by the CAL DAWG
% Data Review presentation
%
% (1) This script loops over all available channels and collects collateral
%     data to create diagnostic figures to examine the black and smear
%     corrections across the focal plane array.
%
% (2) This script loops over a subset of channels (determined by the Kepler
%     Science Office) to collect the figures output by the SOC Pipeline.
%
% (3) This script loops over the same subset of channels to reprocess a
%     subset of the photometric pixel inputs up through the 2D Black correction,
%     since these intermediate pixels aren't saved in the Pipeline due to
%     memory constraints, and then compares the output calibrated photometric
%     pixels to these 2D Black-corrected pixels.
%
%
% INPUTS:
%
%   quarterString     [string] quarter of data ('Q6')
%   monthString       [string] month of data ('M1', 'M2', ..., or 'M1-M3')
%   cadenceTypeString [string] cadence type ('long', 'short', or 'ffi')
%
%   figureDir         [string] directory to save output matfiles/figures
%   dataDir           [string] directory with flight data taskfiles
%   taskfileMap       [string] name of taskfile map (.csv file) in dataDir
%   channelArray      [array]  list of LC and SC channels to analyze
%   invocation        [scalar] LC invocation to analyze (=1 for SC)
%
%   savePixelDataFlag  [logical] flag to save collateral data for each channel
%   dawgFigureFlag     [logical] flag to create only those figures that are
%                                embedded in the DAWG final presentation.
%                                Additional diagnostic figures can be created
%                                for further analysis if set to false
%
%   skipDataCollectionFlag [logical] flag to skip collection of collateral data
%   collateralFigurePath [logical] figure path if skipDataCollectionFlag = true
%
% OUTPUT:
% Figures created from this function are noted in the comments of:
%
%       collect_collateral_for_validation.m
%       plot_calibrated_black.m
%       plot_calibrated_smear.m
%       collect_photometric_data.m
%
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


display(' ')
display(' ')
display(['Starting data collection and figure generation for ' quarterString ' ' monthString ' ' cadenceTypeString ' data...'])
display(' ')
display(' ')
%--------------------------------------------------------------------------
% create figure path to collect collateral data and figures
%--------------------------------------------------------------------------
if isempty(collateralFigurePath)
    
    collateralFigurePath  = [figureDir 'collateral/'];
    mkdir(collateralFigurePath)
end

%%{

%--------------------------------------------------------------------------
% collect the relevant black/smear data from the available data dirs
%--------------------------------------------------------------------------
if ~skipDataCollectionFlag
    
    collect_collateral_data_for_dawg(quarterString, monthString, cadenceTypeString, dataDir, ...
        collateralFigurePath, taskfileMap, savePixelDataFlag, channelArray)
    
    eval(['save ' figureDir, quarterString '_' cadenceTypeString '_' monthString '_collateral_results.mat'])
end



%--------------------------------------------------------------------------
% create the black residual images (median values across the FPA)
%--------------------------------------------------------------------------
display(' ')
display('Creating black residual figures for all channels ...');
create_black_figures_for_dawg(quarterString, monthString, cadenceTypeString, ...
    collateralFigurePath, dawgFigureFlag)


%--------------------------------------------------------------------------
% create the smear/dark images (median values across the FPA)
%--------------------------------------------------------------------------
display(' ')
display('Creating smear figures for all channels ...');
create_smear_figures_for_dawg(quarterString, monthString, cadenceTypeString, ...
    collateralFigurePath, dawgFigureFlag)

%%}

%--------------------------------------------------------------------------
% collect and plot the photometric pixels for select channels
%--------------------------------------------------------------------------
display(' ')
display('Calculating 2D black-corrected pixels, and creating photometric figures for select channels ...');

photometricFigurePath  = [figureDir 'photometric/'];
mkdir(photometricFigurePath)

for i = 1:length(channelArray)
    
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
    % month (M1 includes all select channels, M2 and M3 includes channel 19 only)
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
            collect_photometric_data_for_dawg(quarterString, monthString, cadenceTypeString, ...
                taskfileDir, photometricFigurePath, collateralFigurePath, invocation, [], dawgFigureFlag)
        else
            display(['Taskfile for ' quarterString ' ' monthString ' ' cadenceTypeString ' invocation=' num2str(invocation) ' is unavailable or empty'])
        end
    end
    
    
    % for SC, create figures for each channel in channelArray for the given
    % month using the first unit-of-work. For channel 19, month 1 use the
    % first three invocations (first three taskfiles in directory)
    if strcmpi(cadenceTypeString, 'short')
        
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
                collect_photometric_data_for_dawg(quarterString, monthString, cadenceTypeString, ...
                    taskfileDir, photometricFigurePath, collateralFigurePath, invocation, uowArray(k), dawgFigureFlag)
            else
                display(['Taskfile for ' quarterString ' ' monthString ' ' cadenceTypeString ' UOW=' uowArray(k) ' is unavailable or empty'])
            end
        end
    end
end

display(['DAWG figures created for ' quarterString ' ' monthString ' ' cadenceTypeString ' data.'])
display(' ')
display(' ')

return;
