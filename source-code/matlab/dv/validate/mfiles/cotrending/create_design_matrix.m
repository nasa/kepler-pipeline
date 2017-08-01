function [designMatrix] = ...
create_design_matrix(conditionedAncillaryDataStruct, nCadences)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [designMatrix] = ...
% create_design_matrix(conditionedAncillaryDataStruct, nCadences)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This PDC function creates the design matrix for cotrending of flux time
% series with conditioned ancillary data. All ancillary channels at this
% point should be sampled at the same rate and in the same phase as the
% short or long cadence flux time series. Interpolate any gapped values so
% that the design matrix columns can be filtered. There should not be any
% gapped values, however, for cadences where valid data exists.
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


% Define constant.
QUADRATIC_ORDER = 2;

% Get the number of ancillary data channels.
nChannels = length(conditionedAncillaryDataStruct);

% Return design matrix with single constant column if there is no
% conditioned ancillary data.
if nChannels == 0
    designMatrix = ones([nCadences, 1]);
    return
end % if

% Pack the ancillary time series into a single array, subtracting the mean
% value from each channel.
ancillaryTimeSeries = [conditionedAncillaryDataStruct.ancillaryTimeSeries];
ancillaryDataArray = [ancillaryTimeSeries.values];
ancillaryDataUncertaintiesArray = [ancillaryTimeSeries.uncertainties];                                          %#ok<NASGU>
ancillaryDataGapIndicatorsArray = [ancillaryTimeSeries.gapIndicators];

ancillaryDataArray(ancillaryDataGapIndicatorsArray) = 0;
ancillaryMeans = ...
    sum(ancillaryDataArray) ./ sum(~ancillaryDataGapIndicatorsArray);
ancillaryDataArray = ...
    ancillaryDataArray - repmat(ancillaryMeans, [nCadences, 1]);
ancillaryDataArray(ancillaryDataGapIndicatorsArray) = 0;

% DO NOT SCALE BY UNCERTAINTIES FOR NOW.
% ancillaryDataUncertaintiesArray(ancillaryDataGapIndicatorsArray) = 1;
% ancillaryDataArray = ...
%     ancillaryDataArray ./ ancillaryDataUncertaintiesArray;

% Interpolate any gapped values so that the design matrix columns can be
% filtered later. There should not be any gapped values, however, for
% cadences where valid data exists.
for i = 1 : nChannels
    gapIndicators = ancillaryDataGapIndicatorsArray( : , i);
    if any(gapIndicators)
        values = ancillaryDataArray( : , i);
        values(gapIndicators) = ...
            interp1(find(~gapIndicators), values(~gapIndicators), ...
            find(gapIndicators), 'linear', 'extrap');
        ancillaryDataArray( : , i) = values;
    end % if
end % for i

% Scale only for purposes of numerical conditioning. If the max value for a
% channel is zero then all values for that channel must be zero.
maxValues = max(abs(ancillaryDataArray));
maxValues(maxValues == 0) = 1;
ancillaryDataArray = ...
    ancillaryDataArray ./ repmat(maxValues, [nCadences, 1]);

clear ancillaryTimeSeries ancillaryDataUncertaintiesArray ...
    ancillaryDataGapIndicatorsArray;

% Get the interaction indices for each of the channels. Interactions with
% any mnemonics that could not be adquately conditioned will be ignored.
ancillaryMnemonics = {conditionedAncillaryDataStruct.mnemonic};

for i = 1 : nChannels
    conditionedAncillaryDataStruct(i).interactionIndices = ...
        find(ismember(ancillaryMnemonics, ...
        conditionedAncillaryDataStruct(i).interactions));
end
    
% Loop through the ancillary channels and determine the maximum model order
% and order for the interactions, and the dimension of the design matrix.
% Check for consistency in the designation of the interactions.
nDesignMatrixColumns = 1;
maxModelOrder = 0;
maxInteractionOrder = 0;

for i = 1 : nChannels
    dataStruct1 = conditionedAncillaryDataStruct(i);
    order = dataStruct1.modelOrder;
    maxModelOrder = max(maxModelOrder, order);
    nDesignMatrixColumns = nDesignMatrixColumns + order;
    if ~isempty(dataStruct1.interactionIndices)
        for j = 1 : length(dataStruct1.interactionIndices)
            index = dataStruct1.interactionIndices(j);
            dataStruct2 = conditionedAncillaryDataStruct(index);
            if i == index
                error('PDC:createDesignMatrix:invalidInteractionDefinition', ...
                    '%s is listed as an interaction for itself', ...
                    dataStruct1.mnemonic);
            end
            if ~ismember(i, dataStruct2.interactionIndices)
                error('PDC:createDesignMatrix:invalidInteractionDefinition', ...
                    '%s is listed as an interaction for %s, but not vice versa', ...
                    dataStruct2.mnemonic, dataStruct1.mnemonic);
            end
            if order ~= dataStruct2.modelOrder
                error('PDC:createDesignMatrix:invalidInteractionDefinition', ...
                    'Model orders do not agree for interaction mnemonics %s (%d) and %s (%d)', ...
                    dataStruct1.mnemonic, order, ...
                    dataStruct2.mnemonic, dataStruct2.modelOrder);
            end
            if order < QUADRATIC_ORDER
                error('PDC:createDesignMatrix:invalidInteractionDefinition', ...
                    'Invalid model order (%d) for interaction mnemonics %s and %s', ...
                    order, dataStruct1.mnemonic, dataStruct2.mnemonic);
            end
            if i < index
                maxInteractionOrder = ...
                    max(maxInteractionOrder, order);
                nDesignMatrixColumns = ...
                    nDesignMatrixColumns + (order * (order - 1) / 2);
            end
        end % for j
    end % if ~isempty
end % for i

% Create cell arrays with 'x2fx' polynomial and interaction input models
% for each polynomial order. Consult x2fx help for details.
if 0 < maxModelOrder
    x2fxPolyModel = cell([1, maxModelOrder]);
    polyModel = (1 : maxModelOrder)';
    for i = 1 : maxModelOrder
        x2fxPolyModel{i} = polyModel(1 : i);
    end
end

if QUADRATIC_ORDER <= maxInteractionOrder
    x2fxInteractionModel = cell([1, maxInteractionOrder]);
    order = maxInteractionOrder - 1;
    m1 = repmat((1 : order)', [order, 1]);
    m2 = repmat((1 : order), [order, 1]);
    interactionModel = sortrows([m1, m2( : ), m1 + m2( : )], 3);
    interactionModel = interactionModel( : , 1 : 2);
    for i = 1 : maxInteractionOrder
        x2fxInteractionModel{i} = interactionModel(sum(interactionModel, 2) <= i, : );
    end
end

% Initialize the design matrix and start column index.
designMatrix = ones([nCadences, nDesignMatrixColumns]);
startColumn = 2;

% Create the design matrix. Include the interactions. Use matlab 'x2fx'
% with input models to generate columns of design matrix.
for i = 1 : nChannels
    dataStruct1 = conditionedAncillaryDataStruct(i);
    order = dataStruct1.modelOrder;
    if 0 < order
        newColumns = x2fx(ancillaryDataArray( : , i), x2fxPolyModel{order});
        endColumn = startColumn + order - 1;
        designMatrix( : , startColumn : endColumn) = newColumns;
        startColumn = endColumn + 1;
        if ~isempty(dataStruct1.interactionIndices)
            for j = 1 : length(dataStruct1.interactionIndices)
                index = dataStruct1.interactionIndices(j);
                if i < index
                    newColumns = x2fx(ancillaryDataArray( : , [i, index]), ...
                        x2fxInteractionModel{order});
                    endColumn = startColumn + (order * (order - 1) / 2) - 1;
                    designMatrix( : , startColumn : endColumn) = newColumns;
                    startColumn = endColumn + 1;
                end
            end % for j
        end % if ~isempty
    end % if 0 < order
end % for i

% Return.
return
