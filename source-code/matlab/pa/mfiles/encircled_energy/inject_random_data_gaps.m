function tppInputStruct = inject_random_data_gaps(tppInputStruct,cadenceGapFraction,targetFraction,pixelFraction)

% function tppInputStruct = inject_random_data_gaps(tppInputStruct,cadenceGapFraction,targetFraction,pixelFraction)
%
%   Randomly select cadenceGapFraction cadences to flag as data gaps. Gaps
%   are flagged in randomly selected targetFraction of total targets at the
%   target level and in randomly selected pixelFraction of the total pixels
%   at the pixel level. Modify tppInputStruct to reflect the data gaps.
%
%	INPUT:  Valid tppInputStruct with the following fields at a minimum:
%           tppInputStruct.targetStarStruct()
%               .labels      = cell array of labels
%               .rowCentroid = computed centroid row
%               .colCentroid = computed centroid column
%               .gapList     = # of gaps x 1 array containing the indices of cadence gaps at the target-level 
%               .pixelTimeSeriesStruct() = structre for each pixel in target with fields
%                   .timeSeries     = # of cadences x 1 array containing pixel brightness time series in electrons
%                   .uncertainties  = # of cadences x 1 array containing pixel uncertainty time series
%                   .row            = row of this pixel
%                   .column         = column of this pixel
%                   .gapList        = # of gaps x 1 array containing the indices of cadence gaps at the pixel-level
%
%           targetGapFract  = fraction of data to gap at the target level
%           pixelGapFract   = fraction of data to gap at the pixel level
%
%   OUTPUT: Same tppInputStruct with data gap lists and/or flags set.
%
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

disp(mfilename('fullpath'));

% find number of total targets, total cadences and total pixels - assumes
% valid tppInputStruct w/o gaps as input
nTargets = length(tppInputStruct.targetStarStruct);
nCadences = length(tppInputStruct.targetStarStruct(1).pixelTimeSeriesStruct(1).timeSeries);

% get pixel count for each target
pCount=zeros(nTargets,1);
for iTarget=1:nTargets
    pCount(iTarget)=length(tppInputStruct.targetStarStruct(iTarget).pixelTimeSeriesStruct);
end
% running sum used for pixel indexing later - total pixels is last entry in running sum
sumPixels=cumsum(pCount);
sumPixels=[0;sumPixels];                % add starting point
nPixels=sumPixels(end);

% generate list of random cadence numbers to gap based on cadenceGapFraction
randCadences = [];
while(length(randCadences) < cadenceGapFraction * nCadences)
    randCadences = unique(sort([randCadences,ceil(nCadences.*rand)]));
end

% generate list of random target numbers to gap based on targetFraction
randTargets = [];
while(length(randTargets) < targetFraction * nTargets)
    randTargets = unique(sort([randTargets,ceil(nTargets.*rand)]));
end

% generate list of random pixel numbers to gap based on pixelFraction
% pixels are numbered consectutively starting with target 1 and proceeding
% through target nTarget
randPixels = [];
while(length(randPixels) < pixelFraction * nPixels)
    randPixels = unique(sort([randPixels,ceil(nPixels.*rand)]));
end

% flag gaps at target level
for iTarget=randTargets
    tppInputStruct.targetStarStruct(iTarget).gapList=randCadences(:);
end

% flag gaps at pixel level
for iPixel=randPixels
    % get target index and pixel index within target
    iTarget=find(sumPixels<iPixel, 1, 'last' );
    iPixelTarget=iPixel-sumPixels(iTarget);
    
    % set gap list
    tppInputStruct.targetStarStruct(iTarget).pixelTimeSeriesStruct(iPixelTarget).gapList=randCadences(:);
    
end

