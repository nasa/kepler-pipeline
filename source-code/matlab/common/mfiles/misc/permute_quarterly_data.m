function is = permute_quarterly_data( is, varargin )
%
% function is = permute_quarterly_data( is, varargin )
%
% This function accepts either a TPS or DV inputsStruct plus an optional 17-element quarter assignment map. The data in the inputsStruct is
% re-indexed according to the quarter assignment map. If no map is provided the default quarter assignment map is selected.
%
% INPUTS:           is == TPS or DV inputsStruct
%             varargin == quarter assignment map; 1 x 17 vector where each element contains the new quarter assignment relative to the
%                         original quarter assignment. The original quarter assignment is assumed to be:
%                         ORIGINAL_QUARTER_ASSIGNMENT = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9,10,11,12,13,14,15,16,17];
%                         example quarter reassignment:
%                           ORIGINAL_QUARTER_ASSIGNMENT   = [ 0  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17]
%                           newQuarterAssignment          = [ 0 13 14 15 16  9 10 11 12  5  6  7  8  1  2  3  4 17]
%                           Suppose the incoming inputsStruct contains data from quarters 1 through 17 in ascending order. The output of
%                           this function will contain the same data but reindexed so that the q13 comes first followed by q14, q15, q16, q9
%                           etc. The quarter labels (in cadenceTimes.quarters for example) would still be q1, q2, q3, q4, q5 etc.
%
% OUTPUT:           is == inputsStruct with reindexed data
%
% This funtion is based on Chris Burke's Prototype code available in KDAWG-203 in script form.
%
% For a TPS inputsStruct the following fields are reindexed:
%   cadenceTimes -- all fields except {startTimestamps, midTimestamps, endTimestamps, cadenceNumbers, lcTargetTableIds, scTargetTableIds} + all fields under dataAnomalyFlags
%                -- The values under cadenceTimes.quarters are adjusted to reflect the new data order
%   tpsTargets -- fluxValue, uncertainty
%              -- the following fields containing indices are translated to the new index base
%                   gapIndices
%                   fillIndices
%                   outlierIndices
%                   discontinuityIndices
%                   quarterGapIndicators
%               -- the following field is apparently not used in TPS and will not be adjusted
%                   transitEphemeris
%               -- diagnostics
%                   This field is not used in TPS to calculate tces but may be used in post processing analysis. It contains fields which
%                   contain arrays or struct arrays organized by quarter. These array will be reindexed according to newQuarterAssignment.
%
%               No other TPS inputsStruct fields are reindexed or translated.
%
% For a DV inputsStruct the following fields are reindexed:
%   dvCadenceTimes -- all fields except {startTimestamps, midTimestamps, endTimestamps, cadenceNumbers, lcTargetTableIds, scTargetTableIds} + all fields under dataAnomalyFlags
%                  -- The values under cadenceTimes.quarters are adjusted to reflect the new data order
%   targetStruct -- all fields under correctedFluxTimeSeries, rawFluxTimeSeries, centroids.prfCentroids, centroids.fluxWeightedCentroids,
%                   rollingBandContaminationStruct.severityFlags
%                -- targetDataStruct array is rearranged for the new quarter order. quarter, startCadence, endCadence, startMjd, endMjd
%                   fields in this structure are modified to be consistent with the new quarter mapping
%                -- the following fields containing indices are translated to the new index base
%                     discontinuityIndices
%                     correctedFluxTimeSeries.fillIndices
%                -- the following contain a list of indices, values at those indices and uncertainties on those values
%                     outliers.indices
%                       The indices are translated to the new index base and the lists of outliers.values and outliers.uncertainties are rearranged so they
%                       follow the original indices
%   targetTableDataStruct -- struct array is reindexed to agree with new quarter assignment
%                         -- the backgroundBlobs, cbvBlobs and motionBlobs are modified so the external and cadence and timestamp fields
%                            agree with the new quarter and data indexing. The modified blobs are written to new files and the blobfile
%                            names are adjusted to point to these new blobs.
%
%               No other DV inputsStruct fields are reindexed or translated.
%
% For both DV and TPS, the gapped startTimestamps, midTimestamps and endTimestamps are first filled by linear interpolation on
% cadenceNumbers. When the reindexing map has been computed, the timestamps corresponding to the new gap indicators are replaced with the
% incoming gapped timestamp value (seems to be always zero). 
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



% define constants
ORIGINAL_QUARTER_ASSIGNMENT = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9,10,11,12,13,14,15,16,17];
DEFAULT_QUARTER_ASSIGNMENT  = [0,13,14,15,16, 9,10,11,12, 5, 6, 7, 8, 1, 2, 3, 4,17];
BLOBS_TO_UPDATE = {'backgroundBlobs','cbvBlobs','motionBlobs'};

% list fields to permute
cadenceTimesFieldsToPermute = {'gapIndicators',...
                                'requantEnabled',...
                                'isSefiAcc',...
                                'isSefiCad',...
                                'isLdeOos',...
                                'isFinePnt',...
                                'isMmntmDmp',...                            
                                'isLdeParEr',...
                                'isScrcErr',...
                                'lcTargetTableIds',...
                                'scTargetTableIds',...
                                'dataAnomalyFlags'};                        
tpsTargetStructFieldsToPermute = {'fluxValue',...
                                    'uncertainty'};                                
timeseriesFieldsToPermute = {'values','gapIndicators','uncertainties'};


% check for variable input
if nargin > 1
    newQuarterAssignment = varargin{1};
else
    newQuarterAssignment = DEFAULT_QUARTER_ASSIGNMENT;
end

% check quarter assignment inputs
if ~isvector(newQuarterAssignment) ||...
        length(newQuarterAssignment) ~= length(ORIGINAL_QUARTER_ASSIGNMENT) ||...
        ~all(ismember(newQuarterAssignment,ORIGINAL_QUARTER_ASSIGNMENT)) ||...
        ~isequal(unique(newQuarterAssignment),sort(newQuarterAssignment))
    error('Invalid quarter assignment. Must be a permutation of 0:17 with all entries unique.');
end

% determine tps or dv style input struct
if isfield(is,'dvCadenceTimes')
    inputStyle = 'DV';
elseif isfield(is,'cadenceTimes')
    inputStyle = 'TPS';
else
    error('Not a TPS or DV inputsStruct');
end

% display a message
disp('Permuting data by quarters.')
disp('Original quarter map: ');
disp(ORIGINAL_QUARTER_ASSIGNMENT);
disp('New quarter map:');
disp(newQuarterAssignment);

% extract cadenceTimes and targetStruct structures
switch inputStyle
    case 'DV'
        cadenceTimes = is.dvCadenceTimes;
        targetStruct = is.targetStruct;
    case 'TPS'
        cadenceTimes = is.cadenceTimes;
        targetStruct = is.tpsTargets;
end

% get the original quarter assignment with gaps filled to next quarter
% associate inter-quarter gaps with previous quarter
filledQuarters = fill_quarters(cadenceTimes.quarters);

% identify which quarters we have in data set. Note the structure of the data in tpsTargets assumes the index of
% quarterGapIndicators is in ascending order of quarter, so we will too.
uniqueQuarters = unique(filledQuarters);


% Do permutation on cadenceTimes --------------------------------------

% extract gaps and cadence numbers
cadenceNumbers = cadenceTimes.cadenceNumbers;
gaps = cadenceTimes.gapIndicators;

% extract timestamp fields to fill gaps
startTimestamps = cadenceTimes.startTimestamps;
midTimestamps = cadenceTimes.midTimestamps;
endTimestamps = cadenceTimes.endTimestamps;

% save original gap values
if any(gaps)
    timestampGapValue = median(midTimestamps(gaps));
    if ~all(midTimestamps(gaps) == timestampGapValue)
        error('Timestamp gap value is varaible');
    end
    quarterGapValue = median(cadenceTimes.quarters(gaps));
    if ~all(cadenceTimes.quarters(gaps) == quarterGapValue)
        error('Quarter gap value is varaible');
    end
else
    timestampGapValue = 0;
    quarterGapValue = -1;
end

% fill original gaps in timestamps by linear interpolation on cadence numbers
startTimestamps(gaps) = interp1(cadenceNumbers(~gaps),startTimestamps(~gaps),cadenceNumbers(gaps),'linear','extrap');
midTimestamps(gaps) = interp1(cadenceNumbers(~gaps),midTimestamps(~gaps),cadenceNumbers(gaps),'linear','extrap');
endTimestamps(gaps) = interp1(cadenceNumbers(~gaps),endTimestamps(~gaps),cadenceNumbers(gaps),'linear','extrap');

% build gap filled timestamps for use in modifying blobs
gapFilledTimeStamps.startTimestamps = startTimestamps;
gapFilledTimeStamps.midTimestamps = midTimestamps;
gapFilledTimeStamps.endTimestamps = endTimestamps;
gapFilledTimeStamps.cadenceNumbers = cadenceNumbers;

% get index reassignment and quarter index assignment from filledQuarters and new quarter assignment map vs original
[newIndices, updatedQuarters, quarterIdx] = reassign_indices_by_quarter(newQuarterAssignment, ORIGINAL_QUARTER_ASSIGNMENT, filledQuarters, uniqueQuarters);

% reassign appropriate fields in cadenceTimes and cadenceTimes.dataAnomalyFlags
cadenceTimes = reindex_field_contents(cadenceTimes,newIndices,cadenceTimesFieldsToPermute);

% get updated gapIndicators
gaps = cadenceTimes.gapIndicators;

% place correct gap value in gapped quarters
updatedQuarters(gaps) = quarterGapValue;

% place correct gap value in gapped timestamps
startTimestamps(gaps) = timestampGapValue;
midTimestamps(gaps) = timestampGapValue;
endTimestamps(gaps) = timestampGapValue;

% replace timestamps and quarters in cadenceTimes
cadenceTimes.startTimestamps = startTimestamps;
cadenceTimes.midTimestamps = midTimestamps;
cadenceTimes.endTimestamps = endTimestamps;
cadenceTimes.quarters = updatedQuarters;

% find new quarter beginning and ending valid data cadence numbers
startCadence = nan(size(uniqueQuarters));
endCadence = nan(size(uniqueQuarters));
startMjd = nan(size(uniqueQuarters));
endMjd = nan(size(uniqueQuarters));
for iQuarter = 1:length(uniqueQuarters)
    startIdx = find(updatedQuarters == uniqueQuarters(iQuarter),1,'first');
    endIdx = find(updatedQuarters == uniqueQuarters(iQuarter),1,'last');
    startCadence(iQuarter) = cadenceNumbers(startIdx);
    endCadence(iQuarter) = cadenceNumbers(endIdx);
    startMjd(iQuarter) = startTimestamps(startIdx);
    endMjd(iQuarter) = endTimestamps(endIdx);
end


% Do permutation on targetStruct and prepare output --------------------------------------

% particulars depend on whether targetStruct came from DV or TPS
switch inputStyle    
    case 'TPS'
        % loop over targets
        for iTarget = 1:length(targetStruct)
            
            % reassign appropriate fields in targetStruct
            targetStruct(iTarget) = reindex_field_contents(targetStruct(iTarget),newIndices,tpsTargetStructFieldsToPermute);
            
            % permute any indices
            % set up temporary struct of logical indicators
            tempStruct = struct('gapIndices',false(size(cadenceNumbers)),...
                'fillIndices',false(size(cadenceNumbers)),...
                'outlierIndices',false(size(cadenceNumbers)),...
                'discontinuityIndices',false(size(cadenceNumbers)));
            
            % convert indices to logicals - incoming indices are zero-based
            tempStruct.gapIndices(targetStruct(iTarget).gapIndices + 1) = true;
            tempStruct.fillIndices(targetStruct(iTarget).fillIndices + 1) = true;
            tempStruct.outlierIndices(targetStruct(iTarget).outlierIndices + 1) = true;
            tempStruct.discontinuityIndices(targetStruct(iTarget).discontinuityIndices + 1) = true;
            
            % reassign all fields in tempStruct according to newIndices
            tempStruct = reindex_field_contents(tempStruct,newIndices);
            
            % convert logicals back to zero-based indices and store
            targetStruct(iTarget).gapIndices = find(tempStruct.gapIndices) - 1;
            targetStruct(iTarget).fillIndices = find(tempStruct.fillIndices) - 1;
            targetStruct(iTarget).outlierIndices = find(tempStruct.outlierIndices) - 1;
            targetStruct(iTarget).discontinuityIndices = find(tempStruct.discontinuityIndices) - 1;
            
            %         Gap reassignment example:
            %         ORIGINAL_QUARTER_ASSIGNMENT   = [ 0  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17]
            %         newQuarterAssignment          = [ 0 13 14 15 16  9 10 11 12  5  6  7  8  1  2  3  4 17]
            %         uniqueQuarters                = [    1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17]
            %         gapIndiators                  = [    0  0  0  0  1  1  0  1  0  0  0  1  0  0  0  1  0]
            %         updatedGapIndicators          = [    0  0  0  1  0  0  0  1  1  1  0  1  0  0  0  0  0]
            
            % update quarter gap indicators
            targetStruct(iTarget).quarterGapIndicators = targetStruct(iTarget).quarterGapIndicators(quarterIdx);
            
            % reindex diagnostics struct            
            targetStruct(iTarget).diagnostics.ccdModule = targetStruct(iTarget).diagnostics.ccdModule(quarterIdx);
            targetStruct(iTarget).diagnostics.ccdOutput = targetStruct(iTarget).diagnostics.ccdOutput(quarterIdx);
            targetStruct(iTarget).diagnostics.crowding = targetStruct(iTarget).diagnostics.crowding(quarterIdx);
            targetStruct(iTarget).diagnostics.gapIndicators = targetStruct(iTarget).diagnostics.gapIndicators(quarterIdx);
            targetStruct(iTarget).diagnostics.pdcDataProcessingStruct = targetStruct(iTarget).diagnostics.pdcDataProcessingStruct(quarterIdx);
            
        end
        
        % set cadenceTimes and tpsTargets fields in TPS inputsStruct
        is.tpsTargets = targetStruct;
        is.cadenceTimes = cadenceTimes;
        
    case 'DV'
        % loop over targets
        for iTarget = 1:length(targetStruct)
            % permute the flux timeseries
            targetStruct(iTarget).correctedFluxTimeSeries = reindex_field_contents(targetStruct(iTarget).correctedFluxTimeSeries,newIndices,timeseriesFieldsToPermute);
            targetStruct(iTarget).rawFluxTimeSeries = reindex_field_contents(targetStruct(iTarget).rawFluxTimeSeries,newIndices,timeseriesFieldsToPermute);
            
            % permute flux weighted centroid timeseries
            targetStruct(iTarget).centroids.fluxWeightedCentroids.rowTimeSeries = ...
                reindex_field_contents(targetStruct(iTarget).centroids.fluxWeightedCentroids.rowTimeSeries,newIndices);
            targetStruct(iTarget).centroids.fluxWeightedCentroids.columnTimeSeries = ...
                reindex_field_contents(targetStruct(iTarget).centroids.fluxWeightedCentroids.columnTimeSeries,newIndices);
            
            % permute prf centroid timeseries
            targetStruct(iTarget).centroids.prfCentroids.rowTimeSeries = ...
                reindex_field_contents(targetStruct(iTarget).centroids.prfCentroids.rowTimeSeries,newIndices);
            targetStruct(iTarget).centroids.prfCentroids.columnTimeSeries = ...
                reindex_field_contents(targetStruct(iTarget).centroids.prfCentroids.columnTimeSeries,newIndices);
            
            % permute rolling band contamination flags
            for iRba = 1:length(targetStruct(iTarget).rollingBandContaminationStruct)
                targetStruct(iTarget).rollingBandContaminationStruct(iRba).severityFlags = ...
                    reindex_field_contents(targetStruct(iTarget).rollingBandContaminationStruct(iRba).severityFlags,newIndices);
            end            
            
            % permute indices
            % set up temporary struct of indices as logical indicators and outlier values
            tempStruct = struct('filledIndices',false(size(cadenceNumbers)),...
                'discontinuityIndices',false(size(cadenceNumbers)),...
                'outlierIndices',false(size(cadenceNumbers)),...
                'values',zeros(size(cadenceNumbers)),...
                'uncertainties',zeros(size(cadenceNumbers)));
            
            % convert indices to logicals - incoming indices are zero-based
            tempStruct.filledIndices(targetStruct(iTarget).correctedFluxTimeSeries.filledIndices + 1) = true;
            tempStruct.discontinuityIndices(targetStruct(iTarget).discontinuityIndices + 1) = true;
            tempStruct.outlierIndices(targetStruct(iTarget).outliers.indices + 1) = true;
            
            % populate indexed outlier values and uncertainties
            tempStruct.values(targetStruct(iTarget).outliers.indices + 1) = targetStruct(iTarget).outliers.values;
            tempStruct.uncertainties(targetStruct(iTarget).outliers.indices + 1) = targetStruct(iTarget).outliers.uncertainties;
            
            % reassign all fields in tempStruct according to newIndices
            tempStruct = reindex_field_contents(tempStruct,newIndices);
            
            % convert logicals back to zero-based indices and store
            targetStruct(iTarget).correctedFluxTimeSeries.filledIndices = find(tempStruct.filledIndices) - 1;
            targetStruct(iTarget).discontinuityIndices = find(tempStruct.discontinuityIndices) - 1;
            targetStruct(iTarget).outliers.indices = find(tempStruct.outlierIndices) - 1;
            
            % pick out outlier values and uncertainties at new indices
            targetStruct(iTarget).outliers.values = tempStruct.values(tempStruct.outlierIndices);
            targetStruct(iTarget).outliers.uncertainties = tempStruct.uncertainties(tempStruct.outlierIndices);
            
            % find which quarters are actually presented in the DV array targetStruct.targetDataStruct
            % only quarters with target tables which contain this particular keplerId will have an array entry
            targetQuarters = [targetStruct(iTarget).targetDataStruct.quarter];
            
            % check for non-empty targetDataStruct array
            if isempty(targetQuarters)
                error('No quarters presented in targetDataStruct array -- targetDataStruct array has zero length.');
            end
            
            % check that quarters presented are all members of the uniqueQuarters list
            tf =ismember(targetQuarters,uniqueQuarters);
            if ~all(tf)
                disp('Quarters listed in targetDataStruct.');
                disp(targetQuarters);
                error('Invalid quarter(s) listed in targetDataStruct.');
            end
            
            % quarterIdx gives new indexing into uniqueQuarters under specified quarter permutation - use only quarters found in targetQuarters
            [tf, newIdx] =ismember(uniqueQuarters(quarterIdx),targetQuarters);
            targetStruct(iTarget).targetDataStruct = targetStruct(iTarget).targetDataStruct(newIdx(tf));
            
            newQuarterList = uniqueQuarters(tf);
            for iQuarter = 1:length(newQuarterList)
                
                % update targetDataStruct.quarter field to new quarter for array element
                targetStruct(iTarget).targetDataStruct(iQuarter).quarter = newQuarterList(iQuarter);
                
                % find position of new quarter in available targetQuarters
                qIdx = find(uniqueQuarters == newQuarterList(iQuarter));
                
                % update targetDataStruct begin and end cadences and mjds
                targetStruct(iTarget).targetDataStruct(iQuarter).startCadence = startCadence(qIdx);
                targetStruct(iTarget).targetDataStruct(iQuarter).endCadence = endCadence(qIdx);
                targetStruct(iTarget).targetDataStruct(iQuarter).startMjd = startMjd(qIdx);
                targetStruct(iTarget).targetDataStruct(iQuarter).endMjd = endMjd(qIdx);
                
            end
        end
        
        % reindex target table struct array arranged as quarterly vector
        % There is one entry in the array targetTableDataStruct for each unique ungapped quarter presented in dvCadenceTimes
        is.targetTableDataStruct = is.targetTableDataStruct(quarterIdx);
        
        for iQuarter = 1:length(uniqueQuarters)
            % update target table begin and end cadences
            is.targetTableDataStruct(iQuarter).startCadence = startCadence(iQuarter);
            is.targetTableDataStruct(iQuarter).endCadence = endCadence(iQuarter);
            is.targetTableDataStruct(iQuarter).quarter = uniqueQuarters(iQuarter);
            
            % update blobs
            for iBlob = 1:length(BLOBS_TO_UPDATE)
                
                blob = BLOBS_TO_UPDATE{iBlob};
            
                % update blob struct begin and end cadence entries
                is.targetTableDataStruct(iQuarter).(blob).startCadence = startCadence(iQuarter);
                is.targetTableDataStruct(iQuarter).(blob).endCadence = endCadence(iQuarter);
            
                % update blob internal cadence numbers and timestamps, generate new blob file and update blob file name
                % background
                blobfileList = is.targetTableDataStruct(iQuarter).(blob).blobFilenames;
                for jBlob = 1:length(blobfileList)
                    blobfileList{jBlob} = update_blob_internals(blobfileList{jBlob},newIndices,gapFilledTimeStamps);
                end
                is.targetTableDataStruct(iQuarter).(blob).blobFilenames = blobfileList;
                
            end
            
        end
        
        % set dvCadenceTimes and targetStruct fields in DV inputsStruct
        is.targetStruct = targetStruct;
        is.dvCadenceTimes = cadenceTimes;
end
end




function [idx, newQuarters, quarterReindexing] = reassign_indices_by_quarter(newQuarterAssignment,originalQuarterAssignment,filledQuarters,uniqueQuarters)

% This subfunction reassigns the base indices of filledQuarters given the new quarter assignment
% It also generates quarter reindexing based on the new quarter assignment which is simply a subset of the new quarter assignment vector

% initialize
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

end


function is = reindex_field_contents(is,newIdx,varargin)

% This function steps through the fields of the inputStruct (is) and reindexes the contents of the fields. An optional list of fieldnames to
% operate on may be provided, otherwise all fileds are considered. If a field contains a structure, the fields of that structure are
% reindexed.

if nargin > 2
    fields = varargin{1};
else
    fields = fieldnames(is);
end

for i = 1:length(fields)
    temp = is.(fields{i});
    if isstruct(temp)
        is.(fields{i}) = reindex_field_contents(temp,newIdx);
    else        
        is.(fields{i}) = temp(newIdx);
    end
end
end


function filledQuarters = fill_quarters(quarters)

% This function takes input of cadenceTimes.quarters which is a nCadences x 1 list of quarter numbers with gapped cadences
% getting a quarters value of -1. It will fill all the inter-quarter gapped values with the quarter number of the previous quarter.

% Assumptions:
% Quarters are in ascending order.
% First cadence in quarters has a valid quarter number (i.e. not -1)
% Inter-quarter gaps are associated with the end of the quarter

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
end


function newBlobfile = update_blob_internals(blobfile,newIndices,gapFilledTimeStamps)

% Load blob, modify timestamps and cadence number consistent with newIndices, save blob as new temp-blob-#.mat
% Return new blob filename.

% For cbvBlobs, the following fields are updated at the top level (there is no struct array for cbv blobs)
% e.g. field values
%                       startTimestamp: 5.496401099382000e+04
%                         endTimestamp: 5.499748122492000e+04
%                         startCadence: 1105
%                           endCadence: 2743 
%        gapFilledCadenceMidTimeStamps: [1639x1 double]
%
% For motion and background blobs, the following fields are updated per struct array entry
% e.g. entry values
%                  cadence: 1105
%             mjdStartTime: 5.496400077704000e+04
%               mjdMidTime: 5.496401099382000e+04
%               mjdEndTime: 5.496402121060000e+04

disp(['Updating internal cadence numbers and timestamps in ',blobfile]);

% constants
NEW_BLOB_ROOT = 'temp-blob-';

% extract cadence numbers and timestamps from gap filled timestamp input
cadences = gapFilledTimeStamps.cadenceNumbers;
startTimes = gapFilledTimeStamps.startTimestamps;
midTimes = gapFilledTimeStamps.midTimestamps;
endTimes = gapFilledTimeStamps.endTimestamps;

% get directory list of new blobs to generate next blob number
D = dir([NEW_BLOB_ROOT,'*.mat']);
nextBlobNumber = length(D) + 1;
newBlobfile = [NEW_BLOB_ROOT,num2str(nextBlobNumber),'.mat'];

% load existing blob
s = load(blobfile);
is = s.inputStruct;

% identify whether this is cbv blob or background or motion blob (~cbv blob) and extract blobCadences
if isfield(is,'bandSplittingConfigurationStruct')
    isCbvBlob = true;
    blobCadences = is.startCadence:is.endCadence;
else
    isCbvBlob = false;
    blobCadences = [is.cadence];
end
nCadences = length(blobCadences);

% find where the blob cadences are in the list of input cadence numbers
[tf, idx] = ismember(blobCadences,cadences);

% now find where these locations are in the newIndices list
[ttf, iidx] = ismember(idx(tf),newIndices);

% these locations give the list of indices into cadenceTimes.midTimestamps (for example) which give the new blob cadences numbers and
% timestamps
newIdx = iidx(ttf);

% update the  appropriate fields depending on blob type
if isCbvBlob
    
    % cbv blob are arranged as single level plu a mid timestamp vector
    
    % set new start and end cadences and timestamps
    is.startCadence = cadences(newIdx(1));
    is.endCadence = cadences(newIdx(end));
    is.startTimestamp = startTimes(newIdx(1));
    is.endTimestamp = endTimes(newIdx(end));
    
    % set new mid cadence timestamp vector
    is.gapFilledCadenceMidTimeStamps = midTimes(newIdx);
    
else
    
    % motion and background blobs are arranged as struct arrays
    
    % deal new cadence numbers
    C = num2cell(cadences(newIdx));
    [is(1:nCadences).cadence] = C{ : };
    % deal new start times
    C = num2cell(startTimes(newIdx));
    [is(1:nCadences).mjdStartTime] = C{ : };
    % deal new mid times
    C = num2cell(midTimes(newIdx));
    [is(1:nCadences).mjdMidTime] = C{ : };
    % deal new end times
    C = num2cell(endTimes(newIdx));
    [is(1:nCadences).mjdEndTime] = C{ : };  
    
end

% append to blob input to give correct field name
s.inputStruct = is;

% save inputStruct in new blobfile
save(newBlobfile,'-struct','s');

end