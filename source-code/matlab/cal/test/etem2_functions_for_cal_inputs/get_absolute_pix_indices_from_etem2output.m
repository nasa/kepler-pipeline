function [absoluteIdxPerPixelStruct, absoluteIdxPerTargetStruct] = ...
    get_absolute_pix_indices_from_etem2output(pixels, ...
    targetDefinitionStruct, maskDefinitionTableStruct, pixelType)

%function [absoluteRowColsPerTarget, absoluteRowColsPerPixel] = ...
%            get_absolute_pix_indices_from_etem2output(pixels, ...
%            targetDefinitionStruct, maskDefinitionTableStruct, pixelType)
%
% This function converts target definitions (output from ETEM2) into absolute
% pixel indices.
%
% Target definitions consist of pixel flux values (an nCadence by nPixels array),
% a reference row, a reference column, and an index into a mask definition table.
%
% For stellar targets, the mask definition is a set of offsets
% relative to the stellar reference row/column index.  For background
% pixels, the mask index is always "1", and the mask definition contains
% the row/col indices of four pixels.
%
% Stellar target, background, and collateral pixel target definitions are
% extracted using the function extract_pixel_time_series_from_one_etem2_run.m 
% The following relevant parameters are saved in cal_all_pixel_ts_aug6.mat
% 
%   nTargets 
%   nBackgroundTargets 
%   targetPixels 
%   targetPixelsWithCosmicRays 
%   targetDefinitionStruct 
%   targetMaskDefinitionTableStruct  
%   backgroundPixels 
%   backgroundPixelsWithCosmicRays 
%   backgroundTargetDefinitionStruct 
%   backgroundMaskDefinitionTableStruct  
% 
% This function is called with either target or background data in inputs
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



if (strcmpi(pixelType, 'target') || strcmpi(pixelType, 'targets'))
    disp('finding stellar pixel absolute indices')
     
[absoluteIdxPerPixelStruct, absoluteIdxPerTargetStruct] = ...
    get_target_absolute_idx(pixels, targetDefinitionStruct, maskDefinitionTableStruct);

elseif (strcmpi(pixelType, 'background'))
    disp('finding background pixel absolute indices')
    
   [absoluteIdxPerPixelStruct, absoluteIdxPerTargetStruct] = ...
        get_background_absolute_idx(pixels, targetDefinitionStruct, maskDefinitionTableStruct);

else
    error('First argument must be strings: target or background');
end


return;

