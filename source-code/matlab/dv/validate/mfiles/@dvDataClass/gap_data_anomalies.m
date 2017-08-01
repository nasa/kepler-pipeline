function [dvDataObject, gapIndicators] = ...
gap_data_anomalies(dvDataObject)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [dvDataObject, gapIndicators] = ...
% gap_data_anomalies(dvDataObject)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Set gaps in centroid time series, raw flux time series and motion
% polynomials for cadences marked by the following  data anomaly types:
% EXCLUDE, PLANET_SEARCH_EXCLUDE, SAFE_MODE, EARTH_POINT, ATTITUDE_TWEAK,
% COARSE_POINT, ARGABRIGHTENING. Also, set gaps for orphaned data anomaly
% cadences in corrected flux time series.
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

% SET CONSTANTS FOR HARD CODED FIX FOR MODULE 3 FAILURE.
Q4_TARGET_TABLE = 29;
Q4_FAILURE_MODULE = 3;
Q4_FAILURE_CADENCE_RANGE = (12935 : 16310)';

% Parse the data anomaly types.
cadenceTimes = dvDataObject.dvCadenceTimes;
cadenceNumbers = cadenceTimes.cadenceNumbers;
dataAnomalyIndicators = cadenceTimes.dataAnomalyFlags;

% Get all of the target table ID's.
targetTableDataStruct = dvDataObject.targetTableDataStruct;
targetTableIds = [targetTableDataStruct.targetTableId];

% Ensure that orphaned anomaly cadences are gapped in the corrected flux
% time series. These will be filled by the quarter stitcher. Orphaned
% anomaly cadences are those cadences for which data anomalies have been
% defined but the flux is neither gapped nor filled.
targetStruct = dvDataObject.targetStruct;
nTargets = length(targetStruct);

gapIndicators = ...
    dataAnomalyIndicators.attitudeTweakIndicators | ...
    dataAnomalyIndicators.safeModeIndicators | ...
    dataAnomalyIndicators.earthPointIndicators | ...
    dataAnomalyIndicators.coarsePointIndicators | ...
    dataAnomalyIndicators.argabrighteningIndicators | ...
    dataAnomalyIndicators.excludeIndicators | ...
    dataAnomalyIndicators.planetSearchExcludeIndicators;

for iTarget = 1 : nTargets
    
    correctedFluxTimeSeries = ...
        targetStruct(iTarget).correctedFluxTimeSeries;
    targetGapIndicators = gapIndicators;
    targetGapIndicators(correctedFluxTimeSeries.gapIndicators) = false;
    targetGapIndicators(correctedFluxTimeSeries.filledIndices) = false;
    
    correctedFluxTimeSeries.values(targetGapIndicators) = 0;
    correctedFluxTimeSeries.uncertainties(targetGapIndicators) = 0;
    correctedFluxTimeSeries.gapIndicators(targetGapIndicators) = true;
%     correctedFluxTimeSeries.filledIndices = ...
%         setdiff(correctedFluxTimeSeries.filledIndices, find(targetGapIndicators));
    targetStruct(iTarget).correctedFluxTimeSeries = ...
        correctedFluxTimeSeries;
    
end % for iTarget

% Set the desired gap indicators for centroid and raw flux time series.
% HARD CODE A FIX FOR THE MODULE 3 OUTPUTS IN Q4 UNTIL A PROPER FIX CAN BE
% IMPLEMENTED. IT APPEARS THAT PIXEL TIME SERIES FROM CAL ARE NOT GAPPED
% AFTER THE MODULE 3 FAILURE, BUT FLUX, CENTROIDS AND MOTION POLYNOMIALS
% FROM PA AND PDC ARE PROPERLY GAPPED (BECAUSE PA AND PDC WERE RUN ONLY UP
% UNTIL THE MODULE 3 FAILURE).
gapIndicators = ...
    dataAnomalyIndicators.attitudeTweakIndicators | ...
    dataAnomalyIndicators.safeModeIndicators | ...
    dataAnomalyIndicators.earthPointIndicators | ...
    dataAnomalyIndicators.coarsePointIndicators | ...
    dataAnomalyIndicators.argabrighteningIndicators | ...
    dataAnomalyIndicators.excludeIndicators | ...
    dataAnomalyIndicators.planetSearchExcludeIndicators;

[tf, loc] = ismember(Q4_TARGET_TABLE, targetTableIds);
if tf
    ccdModule = targetTableDataStruct(loc).ccdModule;
    if ccdModule == Q4_FAILURE_MODULE
        gapIndicators(ismember(cadenceNumbers, Q4_FAILURE_CADENCE_RANGE)) = true;
    end % if
end % if

baseCadence = cadenceTimes.cadenceNumbers(1);

for iTarget = 1 : nTargets
    
    rawFluxTimeSeries = targetStruct(iTarget).rawFluxTimeSeries;
    rawFluxTimeSeries.values(gapIndicators) = 0;
    rawFluxTimeSeries.uncertainties(gapIndicators) = 0;
    rawFluxTimeSeries.gapIndicators(gapIndicators) = true;
    targetStruct(iTarget).rawFluxTimeSeries = rawFluxTimeSeries;
    
    centroids = targetStruct(iTarget).centroids;
    
    prfCentroids = centroids.prfCentroids;
    rowTimeSeries = prfCentroids.rowTimeSeries;
    rowTimeSeries.values(gapIndicators) = 0;
    rowTimeSeries.uncertainties(gapIndicators) = 0;
    rowTimeSeries.gapIndicators(gapIndicators) = true;
    prfCentroids.rowTimeSeries = rowTimeSeries;
    
    columnTimeSeries = prfCentroids.columnTimeSeries;
    columnTimeSeries.values(gapIndicators) = 0;
    columnTimeSeries.uncertainties(gapIndicators) = 0;
    columnTimeSeries.gapIndicators(gapIndicators) = true;
    prfCentroids.columnTimeSeries = columnTimeSeries;
    
    fluxWeightedCentroids = centroids.fluxWeightedCentroids;
    rowTimeSeries = fluxWeightedCentroids.rowTimeSeries;
    rowTimeSeries.values(gapIndicators) = 0;
    rowTimeSeries.uncertainties(gapIndicators) = 0;
    rowTimeSeries.gapIndicators(gapIndicators) = true;
    fluxWeightedCentroids.rowTimeSeries = rowTimeSeries;
    
    columnTimeSeries = fluxWeightedCentroids.columnTimeSeries;
    columnTimeSeries.values(gapIndicators) = 0;
    columnTimeSeries.uncertainties(gapIndicators) = 0;
    columnTimeSeries.gapIndicators(gapIndicators) = true;
    fluxWeightedCentroids.columnTimeSeries = columnTimeSeries;
    
    centroids.prfCentroids = prfCentroids;
    centroids.fluxWeightedCentroids = fluxWeightedCentroids;
    targetStruct(iTarget).centroids = centroids;
    
    nTables = length(targetStruct(iTarget).targetDataStruct);
    
    for iTable = 1 : nTables
        
        targetDataStruct = targetStruct(iTarget).targetDataStruct(iTable);
        targetTableId = targetDataStruct.targetTableId;
        
        tf = ismember(targetTableId, targetTableIds);
        if ~tf
            error('dv:gapDataAnomalies:targetTableInconsistency', ...
                'unknown target table %d', targetTableId);
        end % if
        
    end % for iTable
    
end % for iTarget

% Set gaps for the motion polynomials associated with each
% target table. Include the argabrightening cadences even though the 
% polynomials should already be gapped for these. Don't trip if the
% motion polynomials are empty. This might occur on dead module outputs in
% quarters when the skygroup passes through.
nTables = length(targetTableDataStruct);

for iTable = 1 : nTables
        
    tableStruct = targetTableDataStruct(iTable);
    startCadence = tableStruct.startCadence;
    endCadence = tableStruct.endCadence;
    argabrighteningIndices = tableStruct.argabrighteningIndices;
    
    cadenceRange = (startCadence : endCadence) - baseCadence + 1;
    gapIndicatorsForTargetTable = gapIndicators(cadenceRange);
    gapIndicatorsForTargetTable(argabrighteningIndices) = true;
    
    motionPolyStruct = tableStruct.motionPolyStruct;

    if ~isempty(motionPolyStruct)
        
        status = logical([motionPolyStruct.rowPolyStatus]);
        statusCellArray = num2cell(double(status & ~gapIndicatorsForTargetTable( : )'));

        nCadences = length(motionPolyStruct);
        [motionPolyStruct(1 : nCadences).rowPolyStatus] = statusCellArray{ : };
        [motionPolyStruct(1 : nCadences).colPolyStatus] = statusCellArray{ : };
        tableStruct.motionPolyStruct = motionPolyStruct;
    
    end % if
    
    targetTableDataStruct(iTable) = tableStruct;
        
end % for iTable

% Update the DV data object.
dvDataObject.targetStruct = targetStruct;
dvDataObject.targetTableDataStruct = targetTableDataStruct;

% Return.
return
