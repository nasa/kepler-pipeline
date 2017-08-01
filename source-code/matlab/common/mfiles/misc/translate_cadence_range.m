function newCadenceRange = translate_cadence_range(inputsStruct,varargin)

% This tool remaps the a cadence range according to the hard coded newQuarterAssignment map given the originalQuarterAssignment map.
% ORIGINAL_Q4_FAILURE_CADENCE_RANGE of 12935:16310 is used a default cadenceRange input. It is built from subfunctions of
% permute_quarterly_data. InputsStruct is from an original unpermuted dv-inputs-0.mat file. Only the cadenceTimes sub-struct is used.
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


% constants
newQuarterAssignment      = [ 0 16 15 14 13 12 11 10  9  8  7  6  5  4  3  2  1 17];
originalQuarterAssignment = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9,10,11,12,13,14,15,16,17];
ORIGINAL_Q4_FAILURE_CADENCE_RANGE = (12935 : 16310)';

% get optional input
if nargin > 1
    % get cadence range
    cadenceRange = varargin{1};
    % make it a column vector
    cadenceRange = cadenceRange(:);
else
    % use original q4 failure cadences
    cadenceRange = ORIGINAL_Q4_FAILURE_CADENCE_RANGE;
end

% --------------- break out quarters and cadence number vectors
cadenceTimes = inputsStruct.dvCadenceTimes;
quarters = cadenceTimes.quarters;
cadenceNumbers = cadenceTimes.cadenceNumbers;

% --------------- first fill the gaps in quarters
filledQuarters = -ones(size(quarters));
uniqueQuarters = setdiff(unique(quarters),-1);
nQuarters = length(uniqueQuarters);

% first fill any intra-quarter gaps with valid quarter numbers
for i = 1:nQuarters
    startValidIdx = find(quarters==uniqueQuarters(i),1,'first');  
    endValidIdx = find(quarters==uniqueQuarters(i),1,'last');    
    filledQuarters(startValidIdx:endValidIdx) = uniqueQuarters(i);
end    

% fill remaining inter-quarter gaps with quarter number - puts large quarterly gaps at the end of the quarters
lenQuarters = length(filledQuarters);
startIdx = find(filledQuarters==-1,1,'first');
while ~isempty(startIdx)
    endIdx = startIdx + find(filledQuarters(startIdx:lenQuarters)~=-1,1,'first') - 1;
    if ~isempty(endIdx)        
        if startIdx == 1
            % assign any leading gaps to the first valid quarter (this should not happen)
            filledQuarters(startIdx:endIdx) = uniqueQuarters(1);
        else            
            filledQuarters(startIdx:(endIdx-1)) = filledQuarters(startIdx - 1);
        end
        startIdx = find(filledQuarters==-1,1,'first');
    else
        % gap runs to the end of the data set
        filledQuarters(startIdx:lenQuarters) = filledQuarters(startIdx - 1);
        startIdx = [];
    end    
    
end


% --------------- use the filled quarters to generate the new indix mapping (idx)
uniqueQuarters = unique(filledQuarters);
idx = -ones(size(filledQuarters));
newQuarters = -ones(size(filledQuarters));
quarterReindexing = -ones(size(uniqueQuarters));

% loop over quarters in order and assign new indices
startIdx = 1;
startQuarterIdx = 1;
for i = 1:length(originalQuarterAssignment)
    oldIdx = find(filledQuarters == newQuarterAssignment(i));
    if ~isempty(oldIdx)
        % translate indices
        idx(startIdx:(startIdx+length(oldIdx)-1)) = oldIdx;
        newQuarters(startIdx:(startIdx+length(oldIdx)-1)) = originalQuarterAssignment(i);
        startIdx = startIdx+length(oldIdx);
        
        % translate quarter indices
        quarterIdx = find(uniqueQuarters == newQuarterAssignment(i));
        quarterReindexing(startQuarterIdx) = quarterIdx;
        startQuarterIdx = startQuarterIdx + 1;
    end
end

% sanity checks
% final index size equals original index size
if startIdx ~= (length(filledQuarters) + 1)
    error('Size mismatch in new indexing');
end
% final idx values contain all and only the original index values without duplication
if ~isempty(setdiff(idx,1:length(filledQuarters))) || ~isequal(unique(idx),sort(idx))
    error('Bad index reassignment');
end
% new quarter numbers are exactly the original quarter numbers
if ~isempty(setdiff(unique(newQuarters),unique(filledQuarters)))
    error('Bad quarter reassignment');
end
% quarter reassignment must contain exactly the members of unique new quarters
if ~isempty(setdiff(unique(newQuarters),quarterReindexing)) || ~isequal(length(unique(newQuarters)),length(quarterReindexing))
    error('Bad quarter reindexing');
end


% --------------- translate failure cadence range to new range
% find original indices
[tf, idx1] = ismember(cadenceRange,cadenceNumbers);
% find where these original indices are in the new indices
[tf, idx2] = ismember(idx1(tf),idx);
% those locations into original cadence numbers give the new range
newCadenceRange = cadenceNumbers(idx2(tf));

% cadence range checks
if ~all((cadenceRange - newCadenceRange) == (cadenceRange(1) - newCadenceRange(1)));
    error('New failure cadence range is not uniquely translated.');
end
if ~isequal(length(cadenceRange),length(newCadenceRange))
    error('New failure cadence range is diffenet length.');
end
