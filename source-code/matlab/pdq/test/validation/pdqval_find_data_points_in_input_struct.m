function dataPoints = pdqval_find_data_points_in_input_struct(pdqInputStruct, template)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function dataPoints = pdqval_find_data_points_in_input_struct(pdqInputStruct, template)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Find time series data points matching a search template and return them
% in an array. The dataPoint structure is defined asa follows: 
%
% dataPoint
%     .target   [struct]
%         .type    [cell]    : 'stellarPdqTargets' | 'backgroundPdqTargets' 
%                              | 'collateralPdqTargets'
%         .idx     [int]     : e.g., pdqInputStruct.stellarPdqTargets(idx)
%         .channel [int]     : the channel [1:84] of the current target
%         .labels  [cell]    : set of labels that apply (e.g., 'PDQ_STELLAR')
%     .pixel    [struct]
%         .idx     [int]     : index of the pixel in the current target
%         .row     [int]     : pixel row on the target channel [1:1024]
%         .column  [int]     : pixel column on the target channel [1:1100]
%     .cadence     [int]     : the cadence index in the target time series
%     .value       [double]  : data value
%     .gapped      [logical] : indicates whether data point is gapped (true)
%                             or not (false)
%
% Inputs:
%
%     pdqInputStruct
%
%     template   : A dataPoint struct, used to indicate a set of data
%                  points by specifying sets and ranges of values to match
%                  for each field of the structure . Integer and string
%                  values are matched by finding set intersections, while
%                  floating point time series values are matched by the range provided.
%
%                  For example, the template below matches points in
%                  stellar and dynamic range targets on channels 7 and 65
%                  in the first 500 rows whose values lie in the range 
%                  [400000, 400100]. 
%
%                      template
%                          .target   
%                              .type    = {'stellarPdqTargets'}
%                              .idx     = [] 
%                              .channel = [ 7 65 ] 
%                              .labels  = {'PDQ_STELLAR'; 'PDQ_DYNAMIC_RANGE'}
%                          .pixel  
%                              .idx     = []
%                              .row     = [ 1 2 3 ... 499 500]
%                              .column  = []
%                          .cadence     = [1]
%                          .value       = [400000 400100]
%                          .gapped      = false
%
%                  Note that (1) empty arrays or cell arrays match any
%                  value, and (2) value is the only field matched by range.
%                  All other fields are matched to sets of values.
%
% Outputs:
%
%     dataPoints : An array of points matching the template
%
% Notes:
%     This function, and the dataPoint representation in general, is of
%     limited use since the memory requirements are significant. Use it to
%     process relatively small amounts of data.
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

validChannels = find(pdqval_get_valid_channels(pdqInputStruct));
%validChannels = [1:84]';

%--------------------------------------------------------------------------
% Construct and/or validate template
%--------------------------------------------------------------------------
if ~exist('template','var')
    template = pdqval_init_data_point_struct();
end


if isempty(template.target.type)
    template.target.type = validTargetFields;
else
    template.target.type = intersect(template.target.type, validTargetFields);
end

if isempty(template.target.labels)
    template.target.labels = validTargetTypes;
else
    template.target.labels = intersect(template.target.labels, validTargetTypes);
end

if isempty(template.target.channel)
    template.target.channel = validChannels;
else
    template.target.channel = intersect(template.target.channel, validChannels);
end

if isempty(template.pixel.row)
    template.pixel.row = validRows;
else
    template.pixel.row = intersect(template.pixel.row, validRows);
end

if isempty(template.pixel.column)
    template.pixel.column = validColumns;
else
    template.pixel.column = intersect(template.pixel.column, validColumns);
end

if isempty(template.cadence)
    template.cadence = validCadences;
else
    template.cadence = intersect(template.cadence, validCadences);
end

if isempty(template.gapped)
    template.gapped = [true false];
end


%--------------------------------------------------------------------------
% Find data points 
%--------------------------------------------------------------------------
dataPointStruct = pdqval_init_data_point_struct();
dataPoints = [];
for i=1:numel(template.target.type)
    
    targs = pdqInputStruct.(template.target.type{i});
    chans = convert_from_module_output([targs.ccdModule], [targs.ccdOutput]);
    matchingTargetIdices = find(ismember(chans, template.target.channel)); 
     
    for j = matchingTargetIdices(:)'
        
        if any(ismember([targs(j).labels], template.target.labels));
            
            pix = targs(j).referencePixels;
            matchingPixelIndices = [1:numel(pix)];
            if ~isempty(template.pixel.row) | ~isempty(template.pixel.column)
                matchingPixelIndices = find( ismember([pix.row], template.pixel.row) ...
                                      & ismember([pix.column], template.pixel.column) );
            end

            for k = matchingPixelIndices(:)'
                
                matchingGapStateIndices = find(ismember(pix(k).gapIndicators, template.gapped));
                matchingCadences = intersect(template.cadence, matchingGapStateIndices);
                
                for m = matchingCadences(:)'
                    
                    switch length(template.value)
                        
                        case 0
                            
                        case 1
                    
                            if pix(k).timeSeries(m) ~= template.value
                                continue
                            end
                        
                        case 2
                            
                            val = pix(k).timeSeries(m);
                            if val < template.value(1) | val > template.value(2);
                                continue
                            end
        
                        otherwise
                            warning('pdqval_find_data_points_in_input_struct: Field ''template.value'' must have 0, 1 or 2 elements.');
                            continue
                    end
                           
                    dp = dataPointStruct;
                    dp.target.type = template.target.type{i};
                    dp.target.idx = j;
                    dp.target.labels = targs(j).labels;
                    dp.target.channel = chans(j);
                    dp.pixel.idx = k;
                    dp.pixel.row = pix(k).row;
                    dp.pixel.column = pix(k).column;
                    dp.cadence = m;
                    dp.value = pix(k).timeSeries(m);
                    dp.gapped = pix(k).gapIndicators(m);
                    
                    dataPoints = [dataPoints; dp];
                  
                end
            end
        end
    end
end

return

