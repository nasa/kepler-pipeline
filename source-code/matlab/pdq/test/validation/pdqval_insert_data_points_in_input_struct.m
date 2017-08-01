function [pdqInputStruct, ind] = pdqval_insert_data_points_in_input_struct(pdqInputStruct, dataPoints)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [pdqInputStruct, ind] = pdqval_insert_data_points_in_input_struct(pdqInputStruct, dataPoints)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Inserts dataPoints into the reference pixel time series of a
% pdqInputStruct. 
%
% Input:
%     pdqInputStruct    
%         A valid PDQ input structure.
%
%     dataPoints      
%         A struct array of data point structures.
%
% Ouput:
%     pdqInputStruct 
%         A copy of the input structure with the value and gap state of
%         each dataPoint inserted in the specified location.
%
%     ind
%         The row indices of gaps that were actually inserted.
%         gaps(rowIndices) reteives the gaps that were inserted into
%         pdqInputStruct. 
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
if nargin < 2
    return
end

rowsPerChannel = 1024;
columnsPerChannel = 1100;

validRows = [1:rowsPerChannel]';
validColumns = [1:columnsPerChannel]';

validTargetFields = [ {'stellarPdqTargets'}; {'backgroundPdqTargets'}; ...
                 {'collateralPdqTargets'} ];
validTargetTypes = [ {'PDQ_STELLAR'}; {'PDQ_BACKGROUND'}; ... 
                {'PDQ_BLACK_COLLATERAL'}; {'PDQ_SMEAR_COLLATERAL'}; ...
                {'PDQ_DYNAMIC_RANGE'} ];
            
nCadences = length(pdqInputStruct.pdqTimestampSeries.startTimes) ...
            - length(pdqInputStruct.inputPdqTsData.cadenceTimes);
validCadences = [1:nCadences]';

%validChannels = pdqval_get_available_channels(pdqInputStruct);
validChannels = [1:84]';

nDataPoints = size(dataPoints,1);

ind = [];
for n = 1:nDataPoints

   targetIndex = dataPoints(n).target.idx;
   targetTypeStr = dataPoints(n).target.type;
   [module, output] = convert_to_module_output(dataPoints(n).target.channel);
   pixelIndex = dataPoints(n).pixel.idx;
   cadenceIndex = dataPoints(n).cadence;
   
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
   pdqInputStruct.(targetTypeStr)(targetIndex).referencePixels(pixelIndex).timeSeries(cadenceIndex) = dataPoints(n).value;
   pdqInputStruct.(targetTypeStr)(targetIndex).referencePixels(pixelIndex).gapIndicators(cadenceIndex) = dataPoints(n).gapped;
   ind = [ind; n];
end
