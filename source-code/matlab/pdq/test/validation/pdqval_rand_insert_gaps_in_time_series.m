function [pdqInputStruct, gaps] = pdqval_rand_insert_gaps_in_time_series(pdqInputStruct, nGaps, channels, cadences)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [pdqInputStruct, gaps] = pdqval_rand_insert_gaps_in_time_series(pdqInputStruct, nGaps, channels, cadences)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Inserts gaps in the reference pixel time series of a pdqInputStruct
%
% Input:
%     pdqInputStruct    
%         A valid PDQ input structure
%
%     nGaps      
%         A 1-, 4-, or 6-element vector specifying the number of gaps to
%         insert. If nGaps is 1x1, then gaps are inserted randomly across
%         all types of pixels. If nGaps is a 4-element vector, then
%         different numbers of gaps are inserted into pixels having any of
%         the following types: 
%         
%             nGaps = | a |  PDQ_STELLAR
%                     | b |  PDQ_BACKGROUND
%                     | c |  PDQ_BLACK_COLLATERAL
%                     | d |  PDQ_SMEAR_COLLATERAL
%
%
%         If nGaps is a 6-element vector, the pixel types are further 
%         refined:
%
%             nGaps = | a |  PDQ_STELLAR
%                     | b |  PDQ_BACKGROUND
%                     | c |  PDQ_BLACK_COLLATERAL
%                     | d |  PDQ_VSMEAR_COLLATERAL
%                     | e |  PDQ_MSMEAR_COLLATERAL
%                     | f |  PDQ_DYNAMIC_RANGE
%
%     channels
%         a vector specifying the set of channels in which to insert gaps
%         (default: all)
%
%     cadences
%         a vector specifying the set of cadences in which to insert gaps
%         (default: all)
%
% Ouput:
%     pdqInputStruct 
%         A copy of the input structure with gaps inserted
%
%     gaps      
%         An N x 6 matrix in which each row indicates the location of a gap
%         in the reference pixel data. Columns consist of integers having
%         the following meanings: 
%
%       [module, output, target_type, target_index, pixel_index, gap_index]   
%            
%               and target types are 1=stellar, 2 = background,
%               3=black, 4=smear
%
% Dependenceis:
%     convert_from_module_output.m
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
nChannels = 84;
%nCadences = numel(pdqInputStruct.pdqTimestampSeries.startTimes);
nCadences = length(pdqInputStruct.pdqTimestampSeries.startTimes) - length(pdqInputStruct.inputPdqTsData.cadenceTimes);
targetFields = [ {'stellarPdqTargets'}; {'backgroundPdqTargets'}; {'collateralPdqTargets'}; {'collateralPdqTargets'} ];
targetTypes = [ {'PDQ_STELLAR'}; {'PDQ_BACKGROUND'}; {'PDQ_BLACK_COLLATERAL'}; {'PDQ_SMEAR_COLLATERAL'} ];
  
if ~exist('channels', 'var')
    channels = [1:nChannels];
end

if ~exist('cadences', 'var')
    cadences = [1:nCadences];
end

lenChannels = length(channels);
lenCadences = length(cadences);

% Preallocate storage
nPixels = 0;
for i=1:numel(targetFields)
    targs = pdqInputStruct.(targetFields{i});
    nTargets = numel( targs );
    
    for j=1:nTargets
        c = convert_from_module_output(targs(j).ccdModule, targs(j).ccdOutput);
        if ((channels == nChannels) | ismember(c, channels) ) % Use short-circuit OR      
            nPixels = nPixels + numel( targs(j).referencePixels );
        end
    end
end
nDataPoints = nPixels * lenCadences;
elements = zeros(nDataPoints, 6);

% Generate list of data points
idxLow = 1;
for i=1:numel(targetFields)
    targs = pdqInputStruct.(targetFields{i});
    nTargets = numel( targs );
    
    for j=1:nTargets
        c = convert_from_module_output(targs(j).ccdModule, targs(j).ccdOutput);
        if ((lenChannels == nChannels) || ismember(c, channels) ) % Use short-circuit OR
            label = targs(j).labels; % If more than one label, take the first one
            type = find(strcmp(label, targetTypes));
            
            pix = targs(j).referencePixels;
            nPixels = numel( pix );
            for k=1:nPixels
                tmp = [repmat([targs(j).ccdModule targs(j).ccdOutput type j k], lenCadences, 1), [1:lenCadences]'];
                idxHi = idxLow + lenCadences - 1;
                elements(idxLow:idxHi, :) = tmp;
                idxLow = idxHi + 1;
            end
        end
    end
end

% Randomly select data points to gap
switch length(nGaps)
    case 1
        ind = randperm(size(elements,1));
        gaps = elements(ind(1:nGaps),:);
        
    case 4
    case 6
    otherwise
        error('Argument nGaps has invalid dimensions');
end

clear elements;
pdqInputStruct = insertGaps(pdqInputStruct, gaps);

return


%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Local function to insert gaps into a pdqInputStruct
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function pdqInputStruct = insertGaps(pdqInputStruct, gaps)

targetFields = [ {'stellarPdqTargets'}; {'backgroundPdqTargets'}; {'collateralPdqTargets'}; {'collateralPdqTargets'}];
nCadences = length(pdqInputStruct.pdqTimestampSeries.startTimes) ...
            - length(pdqInputStruct.inputPdqTsData.cadenceTimes);
nGaps = size(gaps,1);

for n = 1:nGaps
   module        = gaps(n,1);
   output        = gaps(n,2);
   targetTypeStr = targetFields{gaps(n,3)};
   targetIndex   = gaps(n,4);
   pixelIndex    = gaps(n,5);
   cadenceIndex  = gaps(n,6);

   % Check for existence of the designated target, pixel, and cadence
   if ~isfield(pdqInputStruct, targetTypeStr)
       continue;
   end
   
   if (targetIndex < 1) | ( targetIndex > numel(pdqInputStruct.(targetTypeStr)) )
       continue; 
   end
   
   target = pdqInputStruct.(targetTypeStr)(targetIndex);
      
   if (target.ccdModule ~= module) | (target.ccdOutput ~= output)
       continue;
   end
       
   if (pixelIndex < 1) | (pixelIndex > numel(target.referencePixels))
       continue;
   end
   
   if (cadenceIndex < 1) | (cadenceIndex > nCadences )
       continue;
   end

   % Insert the gap
   pdqInputStruct.(targetTypeStr)(targetIndex).referencePixels(pixelIndex).timeSeries(cadenceIndex) = -1;
   pdqInputStruct.(targetTypeStr)(targetIndex).referencePixels(pixelIndex).gapIndicators(cadenceIndex) = 1;
end


return



