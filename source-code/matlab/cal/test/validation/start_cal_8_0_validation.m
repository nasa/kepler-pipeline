function start_cal_8_0_validation(quarterString, monthString, cadenceTypeString)
%
% function/wrapper to collect data and figures for CAL 8.0 Validation. This 
% function is a copy of cal/test/data_review/start_Q8_cal_data_review which
% is used for DAWGing, but the test data directories are updated for CAL V&V.
% This function calls start_cal_data_review with the following parameters:
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
dawgFigureFlag = false;
%skipDataCollectionFlag = false;
%collateralFigurePath   = [];

skipDataCollectionFlag = true;
% collateralFigurePath = '/path/to/cal_Q8_data_review_test_jun8/long_cadence_m1/collateral/';
collateralFigurePath = '/path/to/cal_8_0_validation_figures/long_cadence_m1/collateral/';

%--------------------------------------------------------------------------
% set default paths for DAWG Q* Data Review
%--------------------------------------------------------------------------

figureDir = '/path/to/cal_8_0_validation_figures/';
mkdir(figureDir)


if strcmpi(cadenceTypeString, 'long')
    
    dataDir = '/path/to/TEST/pipeline_results/photometry/lc/cal/i5001-i8.0-at-44376-cal-ksop-991-q7/';
    
    taskfileMap = 'i5001-lc-cal-ksop-991-task-to-mod-out-map.csv';
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
        
        dataDir     = 'tbd';
        taskfileMap = 'tbd.csv';
        
        channelArray = [19; 41; 46; 58; 10];
        figureDir    = [figureDir 'short_cadence_m1/'];
        mkdir(figureDir)
        
        
    elseif strcmpi(monthString, 'M2')
        
        dataDir     = 'tbd';
        taskfileMap = 'tbd.csv';
        
        channelArray = [19; 41; 46; 58; 10];
        figureDir    = [figureDir 'short_cadence_m2/'];
        mkdir(figureDir)
        
    elseif strcmpi(monthString, 'M3')
        
        dataDir     = 'tbd';
        taskfileMap = 'tbd.csv';
      
        channelArray = [19; 41; 46; 58; 10];
        figureDir    = [figureDir 'short_cadence_m3/'];
        mkdir(figureDir)
    end
end



start_cal_data_review(quarterString, monthString, cadenceTypeString, ...
    figureDir, dataDir, taskfileMap, channelArray, invocation, savePixelDataFlag, ...
    dawgFigureFlag, skipDataCollectionFlag, collateralFigurePath)

return;

