function plot_ancillary_data(pdcDataStruct, conditionedAncillaryDataStruct, ancillaryDataList, manualPauseFlag)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function plot_ancillary_data(pdcDataStruct, conditionedAncillaryDataStruct, ancillaryDataList, manualPauseFlag)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Plot raw and conditioned ancillary data for the given ancillary data list
% (indices) from the PDC input and conditioned ancillary data structures.
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

cadenceTimes = pdcDataStruct.cadenceTimes;
midTimestamps = cadenceTimes.midTimestamps;
cadenceGapIndicators = cadenceTimes.gapIndicators;
dataAnomalyTypes = cadenceTimes.dataAnomalyTypes;
nCadences = length(cadenceGapIndicators);
cadences = (1 : nCadences)';
t0 = midTimestamps(find(~cadenceGapIndicators, 1));
p = polyfit(cadences(~cadenceGapIndicators), ...
    midTimestamps(~cadenceGapIndicators) - t0, 1);
midTimestamps(cadenceGapIndicators) = ...
    polyval(p, cadences(cadenceGapIndicators)) + t0;
[dataAnomalyIndicators] = parse_data_anomaly_types(dataAnomalyTypes);

ancillaryEngineeringDataStruct = pdcDataStruct.ancillaryEngineeringDataStruct;
ancillaryPipelineDataStruct = pdcDataStruct.ancillaryPipelineDataStruct;

if isfield(pdcDataStruct, 'motionBlobs')
    motionPolyStruct = poly_blob_series_to_struct(pdcDataStruct.motionBlobs);
    mpGapIndicators = ~logical([motionPolyStruct.rowPolyStatus]');
    mpValues = zeros(size(mpGapIndicators));
    mpTimestamps = [motionPolyStruct.mjdMidTime]';
    mpTimestamps = mpTimestamps(~mpGapIndicators);
end % if

targetDataStruct = pdcDataStruct.targetDataStruct;
targetGapIndicators = all([targetDataStruct.gapIndicators], 2) | ...
    dataAnomalyIndicators.attitudeTweakIndicators | ...
    dataAnomalyIndicators.safeModeIndicators | ...
    dataAnomalyIndicators.earthPointIndicators | ...
    dataAnomalyIndicators.coarsePointIndicators | ...
    dataAnomalyIndicators.argabrighteningIndicators | ...
    dataAnomalyIndicators.excludeIndicators;

for i = ancillaryDataList(:)'
    
    mnemonic = conditionedAncillaryDataStruct(i).mnemonic;
    if strncmpi(mnemonic, 'SOC_MP_COEFF_ROW', length('SOC_MP_COEFF_ROW'))
        index = str2double(mnemonic(18:end));
        values = mpValues;
        timestamps = mpTimestamps;
        for j = find(~mpGapIndicators)'
            values(j) = motionPolyStruct(j).rowPoly.coeffs(index);
        end
        values = values(~mpGapIndicators);
    elseif strncmpi(mnemonic, 'SOC_MP_COEFF_COL', length('SOC_MP_COEFF_COL'))
        index = str2double(mnemonic(18:end));
        values = mpValues;
        timestamps = mpTimestamps;
        for j = find(~mpGapIndicators)'
            values(j) = motionPolyStruct(j).colPoly.coeffs(index);
        end
        values = values(~mpGapIndicators);
    else
        index = strmatch(mnemonic, ...
            {ancillaryEngineeringDataStruct.mnemonic}, 'exact');
        if ~isempty(index)
            timestamps = ancillaryEngineeringDataStruct(index).timestamps;
            values = ancillaryEngineeringDataStruct(index).values;
        else
            index = strmatch(mnemonic, ...
                {ancillaryPipelineDataStruct.mnemonic}, 'exact');
            if ~isempty(index)
                timestamps = ancillaryPipelineDataStruct(index).timestamps;
                values = ancillaryPipelineDataStruct(index).values;
            else
                error(['mnemonic ', mnemonic, ' cannot be found']);
            end
        end % if / else
    end % if / elseif / else
    
    hold off
    plot(timestamps, values, '.-b')
    hold on
    ancillaryTimeSeries = ...
        conditionedAncillaryDataStruct(i).ancillaryTimeSeries;
    gapIndicators = ancillaryTimeSeries.gapIndicators;
    plot(midTimestamps(~gapIndicators), ...
        ancillaryTimeSeries.values(~gapIndicators), '.-r');
    plot(midTimestamps(~targetGapIndicators), ...
        ancillaryTimeSeries.values(~targetGapIndicators), 'og');
    % set interpreter to none so that underscores are not interpreted as
    % Latex subscripts
    title(['Ancillary Data -- ', mnemonic], 'Interpreter', 'none');
    legend('Raw', 'Conditioned', 'Cadences with Valid Data');
    
    if manualPauseFlag
        pause
    else
        pause(1)
    end
    
end % for i

 return
