function tppInputStruct = make_tpp_input_struct_w_cadence_select(tppInputStruct,cadenceSelect)
%
%   function tppInputStruct = make_tpp_input_struct_w_cadence_select(tppInputStruct,cadenceSelect)
%
%   Return the same structure as input containing only the cadences listed
%   in [cadenceSelect]
%
%	INPUT:  Valid tppInputStruct with the following fields at a minimum:
%           tppInputStruct.targetStarStruct()
%               .rowCentroid                = # of cadences x 1 array containing computed centroid row
%               .colCentroid                = # of cadences x 1 array containing computed centroid column
%               .gapList                    = # of gaps x 1 array containing the indices of cadence gaps at the target-level 
%               .pixelTimeSeriesStruct()    = structre for each pixel in target with fields
%                   .timeSeries                 = # of cadences x 1 array containing pixel time series data
%                   .uncertainties              = # of cadences x 1 array containing pixel uncertainty time series
%                   .row                        = row of this pixel
%                   .column                     = column of this pixel
%                   .gapList                    = # of gaps x 1 array containing the indices of cadence gaps at the pixel-level
%
%           cadenceSelect = # of cadenceSelect x 1 array containing cadence numbers
%
%	OUTPUT: Same structure as input with the following fields modified:
%           tppInputStruct.targetStarStruct()
%               .rowCentroid                = # of cadenceSelect x 1 array containing computed centroid row
%               .colCentroid                = # of cadenceSelect x 1 array containing computed centroid column
%               .gapList                    = # of gaps x 1 array containing the indices of cadence gaps at the target-level
%               .pixelTimeSeriesStruct()    = structre for each pixel in target with fields
%                   .timeSeries                 = # of cadenceSelect x 1 array containing pixel time series data
%                   .uncertainties              = # of cadenceSelect x 1 array containing pixel uncertainty time series
%                   .gapList                    = # of gaps x 1 array containing the indices of cadence gaps at the pixel-level
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

% number of input cadences defined by target(1).pixel(1).timeseries
numCadences = length(tppInputStruct.targetStarStruct(1).pixelTimeSeriesStruct(1).timeSeries);

% cadenceSelect must be an ordered, unique column vector and a subset of the original cadence set
cadenceSelect = intersect(cadenceSelect,1:numCadences);
cadenceSelect = cadenceSelect(:);

% send only the chosen cadences of data using tempStruct - loop through each target
for k=1:length(tppInputStruct.targetStarStruct)
    
    numPixels = length(tppInputStruct.targetStarStruct(k).pixelTimeSeriesStruct);
    
    % modify cetroid row and column to use only [cadenceSelect] cadences
    tppInputStruct.targetStarStruct(k).rowCentroid = tppInputStruct.targetStarStruct(k).rowCentroid(cadenceSelect);
    tppInputStruct.targetStarStruct(k).colCentroid = tppInputStruct.targetStarStruct(k).colCentroid(cadenceSelect);
    
    % adjust gap list at target level to correspond to new set of cadences
    tppInputStruct.targetStarStruct(k).gapList = ...
        intersect(tppInputStruct.targetStarStruct(k).gapList,cadenceSelect);
        
    % determine row indexing corresponding to fieldnames which uses cadence indexing
    S = fieldnames(tppInputStruct.targetStarStruct(k).pixelTimeSeriesStruct);
    iTimeSeries     = find(strcmp(S,'timeSeries'));
    iUncertainties  = find(strcmp(S,'uncertainties'));
    iGapList        = find(strcmp(S,'gapList'));   
    
    % convert sub-struct to temp cell array -  numFields x numPixels, cell
    tempCell = squeeze(struct2cell(tppInputStruct.targetStarStruct(k).pixelTimeSeriesStruct));
    
    % keep gap lists as cell array since lists can be of unequal lengths
    tempGapCell = tempCell(iGapList,:);
    
    % adjust gap list at pixel level to correspond to new set of cadences
    for iPix=1:numPixels
        tempGapCell{iPix} = intersect(tempGapCell{iPix},cadenceSelect);
    end

    % convert to matices
    tempTimeArray = cell2mat(tempCell(iTimeSeries,:));
    tempUncArray = cell2mat(tempCell(iUncertainties,:));
        
    % then back to cell arrays with only [cadenceSelect] cadences used
    tempTimeCell = mat2cell(tempTimeArray(cadenceSelect,:),length(cadenceSelect),ones(numPixels,1));
    tempUncCell = mat2cell(tempUncArray(cadenceSelect,:),length(cadenceSelect),ones(numPixels,1));
    
    % place back in temp cell array, in appropriate rows
    tempCell(iTimeSeries,:) = tempTimeCell;
    tempCell(iUncertainties,:) = tempUncCell;
    tempCell(iGapList,:) = tempGapCell;
    
    % convert back to struct and assign field names
    tppInputStruct.targetStarStruct(k).pixelTimeSeriesStruct = cell2struct(tempCell,S,1);

end
    
