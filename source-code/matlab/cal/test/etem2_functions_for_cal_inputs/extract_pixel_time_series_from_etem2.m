function extract_pixel_time_series_from_etem2(etem2RunDirName, etem2RunDir, pixelDataMatFilename, getRequantizedPixFlag, includeCosmicRaysFlag)
%function extract_pixel_time_series_from_etem2(etem2RunDirName, etem2RunDir, pixelDataMatFilename, getRequantizedPixFlag, includeCosmicRaysFlag)
%
% function to extract pixel time series (for target, background, black, 
% virtual smear, and/or masked smear), and target/background mask definitions,
% from an ETEM2 run.  
%
% Options are to extract requantized pixels (getRequantizedPixFlag = true)
% and to include the injected cosmic rays (includeCosmicRaysFlag = true). 
% By default (if only three arguments are given), the pixels extracted are 
% requantized and do not include cosmic rays.
%
% Example inputs:
%  etem2RunDirName      = 'cal_ETEM2outputs_AllOffGainOn_SEPT4'
%  etem2RunDir          = 'run_long_m3o3s1'
%  pixelDataMatFilename = 'cal_pixelStructs_AllOffGainOn_SEPT4'
%
%  extract_pixel_time_series_from_one_etem2_run('cal_ETEM2outputs_AllOffGainOn_SEPT4', 'run_long_m3o3s1', 'cal_pixelStructs_AllOffGainOn_SEPT4')
%
% etem2RunDirName are directories that have been created from individual 
% etem2 runs, all located in:  /path/to/matlab/etem2/mfiles/
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


if (nargin < 3)
    %error    
elseif (nargin == 3)

    % by default extract requantized pixels without cosmic rays
    getRequantizedPixFlag = false;
    includeCosmicRaysFlag = false;
elseif (nargin == 4)

    % by default extract pixels without cosmic rays
    includeCosmicRaysFlag = false;
end


tic;
outputLocation = [etem2RunDirName, '/', etem2RunDir];

eval(['cd ' outputLocation ]);

%--------------------------------------------------------------------------
% extract pixel time series for all pixel types, these are not correct for
% fixed offset or mean black:
%
% pixelSeries = get_cal_pixel_time_series(location, type, quantize, cosmicRays)
%--------------------------------------------------------------------------

targetPixels = get_cal_pixel_time_series(outputLocation, 'targets', getRequantizedPixFlag, includeCosmicRaysFlag);             %#ok<NASGU>
backgroundPixels = get_cal_pixel_time_series(outputLocation, 'background', getRequantizedPixFlag, includeCosmicRaysFlag);      %#ok<NASGU> % an nPixels x nCadences array
blackPixels = get_cal_pixel_time_series(outputLocation, 'black', getRequantizedPixFlag, includeCosmicRaysFlag);                %#ok<NASGU> % 1 x 1070 array with summed black values
maskedSmearPixels = get_cal_pixel_time_series(outputLocation, 'maskedSmear', getRequantizedPixFlag, includeCosmicRaysFlag);    %#ok<NASGU> % 1 x 1100 array with summed masked smear values
virtualSmearPixels = get_cal_pixel_time_series(outputLocation, 'virtualSmear', getRequantizedPixFlag, includeCosmicRaysFlag);  %#ok<NASGU> % 1 x 1100 array with summed virtual smear values


%--------------------------------------------------------------------------
% extract target definitions for target and background pixels.  Some information
% in targetDefinitionStruct may overlap with targetPixels struct, but the
% targetDefinitionStruct is used to extract the reference row/cols
%--------------------------------------------------------------------------

% returns the target definitions
%   targetDefinitionStruct().referenceRow (in 0 - based indexing!!!!)
%   targetDefinitionStruct().referenceColumn (in 0 - based indexing!!!!)
%   targetDefinitionStruct().maskIndex (in 1 - based indexing!!!!)

targetDefinitionStruct = get_target_definitions(outputLocation, 'target');               %#ok<NASGU>
backgroundTargetDefinitionStruct = get_target_definitions(outputLocation, 'background'); %#ok<NASGU>

%--------------------------------------------------------------------------
% extract mask definitions for target and background pixels
%--------------------------------------------------------------------------

% maskDefinitionTableStruct is a 1 x nmasks structure array each containing
% the 1 x npixels structure array offsets.  Each offsets contains the
% fields .row and .column, giving the row and column offsets of that pixel

targetMaskDefinitionTableStruct = get_mask_definitions(outputLocation, 'target');         %#ok<NASGU>
backgroundMaskDefinitionTableStruct = get_mask_definitions(outputLocation, 'background'); %#ok<NASGU>

% extract number of targets for target and background pixels
nTargets = get_num_targets(outputLocation, 'target');               %#ok<NASGU>
nBackgroundTargets = get_num_targets(outputLocation, 'background'); %#ok<NASGU>



%--------------------------------------------------------------------------
% save all (target, background, and collateral) pixel time series, target
% definitions, and mask definitions.
%--------------------------------------------------------------------------
duration = toc;

if (getRequantizedPixFlag && ~includeCosmicRaysFlag)

    cd ..
    eval(['save ' pixelDataMatFilename '_RQ_cr.mat ' ...
        ' nTargets nBackgroundTargets ' ...
        ' targetPixels ' ...
        ' targetDefinitionStruct '...
        ' targetMaskDefinitionTableStruct '  ...
        ' backgroundPixels ' ...
        ' backgroundTargetDefinitionStruct ' ...
        ' backgroundMaskDefinitionTableStruct '  ...
        ' blackPixels '...
        ' maskedSmearPixels '...
        ' virtualSmearPixels '])

    display(['Requantized pixel data extracted (without cosmic rays) for ETEM2 run ' etem2RunDirName ' : ' num2str(duration/60) ' minutes']);

elseif (getRequantizedPixFlag && includeCosmicRaysFlag)

    cd ..
    eval(['save ' pixelDataMatFilename '_RQ_CR.mat ' ...
        ' nTargets nBackgroundTargets ' ...
        ' targetPixels ' ...
        ' targetDefinitionStruct '...
        ' targetMaskDefinitionTableStruct '  ...
        ' backgroundPixels ' ...
        ' backgroundTargetDefinitionStruct ' ...
        ' backgroundMaskDefinitionTableStruct '  ...
        ' blackPixels '...
        ' maskedSmearPixels '...
        ' virtualSmearPixels '])

    display(['Requantized pixel data extracted (with cosmic rays) for ETEM2 run ' etem2RunDirName ' : ' num2str(duration/60) ' minutes']);

elseif (~getRequantizedPixFlag && ~includeCosmicRaysFlag)

    cd ..
    eval(['save ' pixelDataMatFilename '_rq_cr.mat ' ...
        ' nTargets nBackgroundTargets ' ...
        ' targetPixels ' ...
        ' targetDefinitionStruct '...
        ' targetMaskDefinitionTableStruct '  ...
        ' backgroundPixels ' ...
        ' backgroundTargetDefinitionStruct ' ...
        ' backgroundMaskDefinitionTableStruct '  ...
        ' blackPixels '...
        ' maskedSmearPixels '...
        ' virtualSmearPixels '])
    
    display(['Unrequantized pixel data extracted (without cosmic rays) for ETEM2 run ' etem2RunDirName ' : ' num2str(duration/60) ' minutes']);

elseif  (~getRequantizedPixFlag && includeCosmicRaysFlag)

    cd ..
    eval(['save ' pixelDataMatFilename '_rq_CR.mat ' ...
        ' nTargets nBackgroundTargets ' ...
        ' targetPixels ' ...
        ' targetDefinitionStruct '...
        ' targetMaskDefinitionTableStruct '  ...
        ' backgroundPixels ' ...
        ' backgroundTargetDefinitionStruct ' ...
        ' backgroundMaskDefinitionTableStruct '  ...
        ' blackPixels '...
        ' maskedSmearPixels '...
        ' virtualSmearPixels '])
    display(['Unrequantized pixel data extracted (with cosmic rays) for ETEM2 run ' etem2RunDirName ' : ' num2str(duration/60) ' minutes']);
end


return;
