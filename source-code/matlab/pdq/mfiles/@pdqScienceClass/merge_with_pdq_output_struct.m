function  pdqOutputStruct = merge_with_pdq_output_struct(pdqScienceObject, pdqOutputStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function  pdqOutputStruct = merge_with_pdq_output_struct(pdqScienceObject,
% pdqOutputStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This function attempts to merge a possibly corrupted pdqOutputStruct with
% a pdqScienceClass object, presumed uncorrupted, to produce a new and
% usable pdqOutputStruct. It pulls the metric histories, if any, from the
% pdqScienceObject, looks for any new metrics in pdqOutputStruct and 
% attempts to insert everything in the proper locations. For every mod/out
% and every cadence, gaps are inserted where metrics are missing.
% 
% INPUT
%
%    - pdqScienceObject : an object of class pdqScienceClass containing 
%                         both time stamps for the N new reference pixels  
%                         and the metric time series and time stamps for M 
%                         prior cadences. Metric histories may be present
%                         or absent for any number of modouts. 
%
%         The data structures containing metric histories for each mod/out 
%         are assumed to have the following properties: 
%
%         1. the field pdqScienceObject.inputPdqTsData.pdqModuleOutputTsData 
%            contains entries for all 84 modouts. If there is no metric
%            history yet, the time series arrays for each metric will
%            be empty.
%         2. All metric history arrays must have the same length. If one is
%            empty, all are empty. This is ensured by the pdqScienceClass 
%            constructor.
%         3. Metrics in each time series array are aligned with  
%            corresponding time stamps in the cadenceTimes array.
%         4. Cadences are not necessarily in chronological order.
%         5. Gaps may occur anywhere or everywhere in a time series.
%
%         In the case where no metric history exists for any mod/out, an
%         array of 84 default structures filled with empty arrays is
%         created by the pdqScienceClass() constructor. Otherwise, the
%         constructor ensures all histories have the same length by gapping 
%         missing cadences and missing modouts. The following diagram is 
%         intended to clarify the relevant contents of a pdqScienceClass 
%         object, the various cases that must be handled, and the 
%         conditions under which they arise:
%         
%         pdqScienceObject
%          |
%          +-> cadenceTimes         new reference pixel time stamps
%          |   [ t1 t2 ... tN ]     N > 0 (always)
%          |   
%          +-> inputPdqTsData       Results of M previously processed cadences
%               |
%               +-> cadenceTimes    previous cadence time stamps
%               |   []              M = 0
%               |   [t1 t2 ... tM]  M > 0
%               |
%               +-> pdqModuleOutputTsData              metric time series
%                   [modout_1 modout_2 ... moudout_84] (always 84 elements)
%                     |
%                     +-> ccdModule  []     M = 0
%                     |              1-24   otherwise
%                     |
%                     +-> ccdOutput  []     M = 0
%                     |              1-4    otherwise
%                     |
%                     +-> backgroundLevels
%                     |    |
%                     |    +-> values 
%                     |    |   []              M = 0
%                     |    |   [v1 v2 ... vM]  M > 0
%                     |    |
%                     |    +-> gapIndicators 
%                     |    |   []              M = 0
%                     |    |   [g1 g2 ... gM]  M > 0
%                     |    |
%                     |    +-> uncertainties 
%                     |    |   []              M = 0
%                     |    |   [u1 u2 ... uM]  M > 0
%                     |    |
%                     :    :
%
% 
%
%     - pdqOutputStruct : a structure containing the following fields:
% 
%             .outputPdqTsData.cadenceTimes
%             .outputPdqTsData.pdqModuleOutputTsData
% 	
%         The one STRONG ASSUMPTION about the contents of pdqOutputStruct 
%         is that any metrics in the time series must be aligned with 
%         corresponding time stamps in the cadenceTimes array.
% 
%         Any of the following issues are permissible and will be correctly
%         handled:
% 	
%         1. Unlike the requirement for the input structure, the field 
%            .outputPdqTsData.pdqModuleOutputTsData may contain any number 
%            of entries in any order.
%         2. Each metric time series from each mod/out may have a different 
%            length or be empty.
%         3. Time series array elements may be in any order, so long as
%            they are correctly aligned with their respective time stamps.
% 
%
% OUTPUT
%
%     - pdqOutputStruct : a copy of the input structure of the same name, 
%         with the fields .outputPdqTsData.cadenceTimes and 
%         .outputPdqTsData.pdqModuleOutputTsData modified such that
%
%         1. Both the cadence times array and the metric time series arrays
%            are in chronological order.
%         2. All mod/outs are represented in the output and mod/out K is
%            indexed by ..pdqModuleOutputTsData(K)
%         3. Each metric time series in each mod/out has the same length as
%            the cadenceTimes array
%         4. Metric time series contain metric histories and any new 
%            metrics successfully computed. Remaining cadences are gapped.
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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
ots = pdqOutputStruct.outputPdqTsData.pdqModuleOutputTsData; % Output time series struct

% If no time series data, do nothing
if isempty(ots)
    return
end

fn = fieldnames(ots(1));
metrics = fn(3:end); % first two elements are ccdModule and ccdOuput
nMetrics = numel(metrics);

M = numel(pdqScienceObject.inputPdqTsData.cadenceTimes); % Number of history cadences
N = length(pdqScienceObject.cadenceTimes);               % Number of new cadences
nCadences = M + N;

defaultNewTsStruct = struct('values',-1*ones(N,1), 'gapIndicators', ...
    true(N,1), 'uncertainties', -1*ones(N,1));

% Initialize a default module output structure
defaultTsStruct = struct('values',-1*ones(M+N,1), 'gapIndicators', ...
    true(M+N,1), 'uncertainties', -1*ones(M+N,1));
defaultModOutStruct.ccdModule = -1;
defaultModOutStruct.ccdOutput = -1;
for i = 1:nMetrics
    defaultModOutStruct.(metrics{i}) = defaultTsStruct;
end
defaultModOutStruct = orderfields(defaultModOutStruct, ...
                 pdqScienceObject.inputPdqTsData.pdqModuleOutputTsData(1));


%-------------------------------------------------------------------------
% Initialize cadenceTimes by copying historical cadence times, then
% appending new cadence times to them. No sorting is done yet.
%-------------------------------------------------------------------------
newCadenceTimes = pdqScienceObject.cadenceTimes;
cadenceTimes = [pdqScienceObject.inputPdqTsData.cadenceTimes; ...
                newCadenceTimes];

%-------------------------------------------------------------------------
% Initialize tsData as metric history with N gaps appended to each time 
% series. The pdqScienceClass constructor ensures that the Kth element of
% the pdqModuleOutputTsData structure array corresponds to mod/out K. Any
% empty ccdModule and ccdOutput fields are filled with correct values.
%-------------------------------------------------------------------------
history = pdqScienceObject.inputPdqTsData.pdqModuleOutputTsData;

tsData = history;
for i = 1:numel(history)
    if ~isempty(history(i).ccdModule)
        for j = 1:nMetrics
           tsStruct.values = [history(i).(metrics{j}).values; ...
               defaultNewTsStruct.values];
           tsStruct.gapIndicators = [history(i).(metrics{j}).gapIndicators; ...
               defaultNewTsStruct.gapIndicators];
           tsStruct.uncertainties = [history(i).(metrics{j}).uncertainties; ...
               defaultNewTsStruct.uncertainties];

           tsData(i).(metrics{j}) = tsStruct;
        end
    else % Handle empty mod/out structures
        tsData(i) = defaultModOutStruct;
        
        [module, output] = convert_to_module_output(i);
        tsData(i).ccdModule = module;
        tsData(i).ccdOutput = output;
    end
end

%-------------------------------------------------------------------------
% Check the contents of pdqOutputStruct at new cadence indices. If valid
% new metrics exist, insert them in the appropriate positions in the 
% tsData time series. 
%-------------------------------------------------------------------------

% The following pruning step is necessary when we intentionally skip one or 
% more mod/outs in the main loop of process_reference_pixels.m, which is 
% only done for debugging purposes. Nonetheless, it adds robustness to the
% code and is worth doing as a preventative measure.
%
% create_output_struct.m initializes all fields to [], but the ccdModule
% and ccdOutput fields are set to meaningful values at the beginning of the
% main loop in process_reference_pixels.m. If we skip the initialization
% for any mod/out we risk an indexing error below unless we prune the
% skipped mod/outs.

% prune structs with empty mod/out fields (these do not contain metrics).
% This is necessary to avoid numel(ots) ~= numel(otsModouts) below in the
% case where ccdModule or ccdOutput is empty for one or more mod/outs.
empty_indices = [];
for i = 1:numel(ots)
    if isempty(ots(i).ccdModule) || isempty(ots(i).ccdOutput)
       empty_indices = [empty_indices; i];
    end
end
ots(empty_indices) = [];


modules = [ots(:).ccdModule]'; 
outputs = [ots(:).ccdOutput]';
otsModouts = convert_from_module_output(modules, outputs); 

otsTimeStamps = pdqOutputStruct.outputPdqTsData.cadenceTimes;
[dummy, otsNewCadenceIndices] = intersect(otsTimeStamps, newCadenceTimes);
tsDataNewCadenceIndices = [M+1:M+N]';

for i = 1:numel(ots) % for each mod/out represented in ots ...
    
    % Map the ith struct in ots to the corresponding struct in tsData 
    modout = otsModouts(i);
    
    for j = 1:nMetrics
        
        % Find in-bounds indices of new cadences (time series may be
        % incomplete)
        inBounds = otsNewCadenceIndices <= numel(ots(i).(metrics{j}).values);
        tsDataIndices = tsDataNewCadenceIndices(inBounds);
        otsIndices = otsNewCadenceIndices(inBounds);
       
        % Place new metric time series data in appropriate array locations
        tsData(modout).(metrics{j}).values(tsDataIndices) = ...
            ots(i).(metrics{j}).values(otsIndices);
        tsData(modout).(metrics{j}).gapIndicators(tsDataIndices) = ...
            ots(i).(metrics{j}).gapIndicators(otsIndices);
        tsData(modout).(metrics{j}).uncertainties(tsDataIndices) = ...
            ots(i).(metrics{j}).uncertainties(otsIndices);
    end
end

%-------------------------------------------------------------------------
% Sort all time series in tsData using cadenceTimes as the sorting key
%-------------------------------------------------------------------------
[sortedCadenceTimes, I] = sort(cadenceTimes);

if I ~= [1:nCadences]'; % Skip this step if already sorted
    for i = 1:numel(tsData) % for each mod/out ...       
        for j = 1:nMetrics
            tsData(i).(metrics{j}).values = tsData(i).(metrics{j}).values(I);
            tsData(modout_idx).(metrics{j}).gapIndicators = ...
                tsData(modout_idx).(metrics{j}).gapIndicators(I);
            tsData(modout_idx).(metrics{j}).uncertainties = ...
                tsData(modout_idx).(metrics{j}).uncertainties(I);
        end
    end
end

%-------------------------------------------------------------------------
% Assign tsData and sorted cadenceTimes to output structure
%-------------------------------------------------------------------------
pdqOutputStruct.outputPdqTsData.cadenceTimes = sortedCadenceTimes;
pdqOutputStruct.outputPdqTsData.pdqModuleOutputTsData = tsData;

return

