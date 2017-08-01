function [conditionedAncillaryDataStruct] = ...
configure_cbv_for_dv_cotrending(cadenceTimes, cbvStruct, ...
cbvGapIndicators, cadenceRange)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [conditionedAncillaryDataStruct] = ...
% configure_cbv_for_dv_cotrending(cadenceTimes, cbvStruct, ...
% cbvGapIndicators, cadenceRange)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Configure the cotrending basis vectors (CBVs) generated in PDC for the
% given quarter/target table for cotrending pixel, centroid and/or flux
% time series in DV.
%
% INPUT:    cadenceTimes    Cadence times structure for target table
%           cbvStruct       CBV structure direct from PDC CBV blob
%           cbvGapIndicators 
%                           Indicators for cadences in target table where
%                           CBVs are not defined
%           cadenceRange    Cadence range with valid science data 
% OUTPUT:   conditionedAncillaryDataStruct
%                           Array containing synchronized ancillary data
%                           for each target table
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

% Get the number of cadences in the target table and target table
% midtimestamps;
nCadences = length(cbvGapIndicators);
midTimestamps = cadenceTimes.midTimestamps;

% Extract relevant input fields and trim or pad vectors as necessary. First
% determine if the PDC/CBV unit of work for the given target table extends
% beyond that of DV.
cbvTimestamps = cbvStruct.gapFilledCadenceMidTimeStamps;
basisVectorsNoBands = cbvStruct.basisVectorsNoBands;

synchronized = false;
for dvIndex = 1 : nCadences
    [tf, cbvIndex] = ismember(midTimestamps(dvIndex), cbvTimestamps);
    if tf
        synchronized = true;
        break;
    end % if
end % for dvIndex

if synchronized
    cbvOffset = cbvIndex - dvIndex;
    startIndex = max(cbvOffset + 1, 1);
    endIndex = min(cbvOffset + nCadences, length(cbvTimestamps));
else
    error('dv:configureCbvForDvCotrending:synchronizationError', ...
        'Unable to synchronize PDC CBVs with DV')
end % if / else
basisVectorsNoBands = basisVectorsNoBands(startIndex : endIndex, : );

basisVectors = zeros([nCadences, size(basisVectorsNoBands, 2)]);
basisVectors(~cbvGapIndicators, : ) = basisVectorsNoBands;
basisVectors = basisVectors(cadenceRange, : );

cbvTimestamps = cbvTimestamps(startIndex : endIndex);
timestamps = zeros([nCadences, 1]);
timestamps(~cbvGapIndicators) = cbvTimestamps;
timestamps = timestamps(cadenceRange);

% svdOrderForReducedRobustFit = cbvStruct.svdOrderForReducedRobustFit(1);

% Compute the number of basis vectors to use for DV cotrending.
% nVectors = min(size(basisVectors, 2), svdOrderForReducedRobustFit);
nVectors = size(basisVectors, 2);

% Initialize output structure array.
ancillaryTimeSeries = struct( ...
    'values', [], ...
    'uncertainties', [], ...
    'gapIndicators', [], ...
    'timestamps', []);

conditionedAncillaryDataStruct = repmat(struct( ...
    'mnemonic', [], ...
    'isAncillaryEngineeringData', [], ...
    'modelOrder', [], ...
    'interactions', [], ...
    'ancillaryTimeSeries', ancillaryTimeSeries), [1, nVectors]);

% Populate the output array. Linearly interpolate or extrapolate across any
% gaps although there should be no gaps remaining at this point unless
% something has gone wrong in SOC OPS.
gapIndicators = cbvGapIndicators(cadenceRange);

for iVector = 1 : nVectors
    
    ancillaryTimeSeries.values = basisVectors( : , iVector);
    ancillaryTimeSeries.uncertainties = zeros(size(timestamps));
    ancillaryTimeSeries.gapIndicators = gapIndicators;
    ancillaryTimeSeries.timestamps = timestamps;
    
    if any(gapIndicators)
        ancillaryTimeSeries.values(gapIndicators) = interp1( ...
            find(~gapIndicators), ancillaryTimeSeries.values(~gapIndicators), ...
            find(gapIndicators), 'linear', 'extrap');
        ancillaryTimeSeries.timestamps(gapIndicators) = interp1( ...
            find(~gapIndicators), ancillaryTimeSeries.timestamps(~gapIndicators), ...
            find(gapIndicators), 'linear', 'extrap');
        ancillaryTimeSeries.gapIndicators = false(size(gapIndicators));
    end % if
        
    conditionedAncillaryDataStruct(iVector).mnemonic = ...
        sprintf('SOC_CBV_%d', iVector);
    conditionedAncillaryDataStruct(iVector).isAncillaryEngineeringData = false;
    conditionedAncillaryDataStruct(iVector).modelOrder = 1;
    conditionedAncillaryDataStruct(iVector).interactions = {};
    conditionedAncillaryDataStruct(iVector).ancillaryTimeSeries = ...
        ancillaryTimeSeries;

end % for iVector

% Return.
return
