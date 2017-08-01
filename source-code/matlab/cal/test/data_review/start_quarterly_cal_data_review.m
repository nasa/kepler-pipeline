function start_quarterly_cal_data_review(figureDir, dataRootDir, quarterString, monthString, cadenceTypeString)
% function start_quarterly_cal_data_review(figureDir, dataRootDir, quarterString, monthString, cadenceTypeString)
%
% function/wrapper to collect data and figures for the DAWG Q*
% CAL Data Review latex presentation.  This function calls
% start_cal_data_review with the following parameters:
%
%   figureDir         [string] directory to save output matfiles/figures
%   dataRootDir       [string] directory with flight data taskfiles
%   quarterString     [string] quarter of data ('Q6')
%   monthString       [string] month of data ('M1', 'M2', ..., or 'M1-M3')
%   cadenceTypeString [string] cadence type ('long', 'short', or 'ffi')
%
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
%   skipDataCollectionFlag [logical] flag to skip collection of collateral
%                                data to recreate plots from existing arrays
%   collateralFigurePath   [logical] figure path if skipDataCollectionFlag = true
%
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


savePixelDataFlag = true;
dawgFigureFlag = true;
skipDataCollectionFlag = false;
collateralFigurePath   = [];

% skipDataCollectionFlag = true;
% collateralFigurePath = '/path/to/cal_Q8_data_review_test_jun8/long_cadence_m1/collateral/';


%--------------------------------------------------------------------------
% set default paths for DAWG Q* Data Review
%--------------------------------------------------------------------------

%%% edit the output location directory
% figureDir = '/path/to/dcaldwell/cal_dawg_q11_ksop-1169/';
if ~exist(figureDir,'dir')
    mkdir(figureDir)
end


%%% edit the data root directory, script assumed lc are in a subdirectory
%%% called "lc" and short cadence are in directories sc-m1, sc-m2, sc-m3
%%% also assumes task file map is the only .csv file in the directory
%%% note: lc directory may have 'mpe_false' and 'mpe_true' subdirectories, 
%%%% CAL products are in the 'mpe_false' directory
% dataRootDir = '/path/to/q11/pipeline_results/q11-for-archive-ksop1169/';


if strcmpi(cadenceTypeString, 'long')
    
    dataDir     = [dataRootDir,'lc/'];
%     dataDir     = [dataRootDir];
%     check for mpe_false, mpe_true directories
    if exist([dataDir,'mpe_false'],'dir')
        dataDir = [dataDir,'mpe_false/'];
    end
    taskfileMap = dir([dataDir,'*cal*.csv']);  % 'q2-lc-cal-ksop886-task-to-mod-out-map.csv';
    taskfileMap = taskfileMap.name;
    invocation = 7;
    
    if strcmpi(monthString, 'M1')
        
        channelArray = [19; 41; 46; 58; 10]; 
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
    
    
elseif strcmpi(cadenceTypeString, 'short')
    
    invocation = 1;
    if strcmpi(monthString, 'M1')
        
        dataDir     = [dataRootDir,'sc-m1/'];
%         dataDir     = [dataRootDir];
        taskfileMap = dir([dataDir,'*cal*.csv']);
        taskfileMap = taskfileMap.name;
        
        channelArray = [19; 41; 46; 58; 10];
        figureDir    = [figureDir 'short_cadence_m1/'];
        mkdir(figureDir)
        
        
    elseif strcmpi(monthString, 'M2')
        
        dataDir     = [dataRootDir,'sc-m2/'];
%         dataDir     = [dataRootDir];
        taskfileMap = dir([dataDir,'*cal*.csv']);
        taskfileMap = taskfileMap.name;
        
        channelArray = [19; 41; 46; 58; 10];
        figureDir    = [figureDir 'short_cadence_m2/'];
        mkdir(figureDir)
        
    elseif strcmpi(monthString, 'M3')
        
%        dataDir     = [dataRootDir,'sc-m3/'];
        dataDir     = [dataRootDir];
        taskfileMap = dir([dataDir,'*cal*.csv']);
        taskfileMap = taskfileMap.name;
        
        channelArray = [19; 41; 46; 58; 10];
        figureDir    = [figureDir 'short_cadence_m3/'];
        mkdir(figureDir)
    end
end



start_cal_data_review(quarterString, monthString, cadenceTypeString, ...
    figureDir, dataDir, taskfileMap, channelArray, invocation, savePixelDataFlag, ...
    dawgFigureFlag, skipDataCollectionFlag, collateralFigurePath)

return;

