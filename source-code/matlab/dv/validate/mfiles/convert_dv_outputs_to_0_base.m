function [dvResultsStruct] = convert_dv_outputs_to_0_base(dvResultsStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [dvResultsStruct] = convert_dv_outputs_to_0_base(dvResultsStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Convert the DV outputs from 1-based indexing (Matlab) to 0-based indexing
% (Java).
%
% For each target with TCE, decrement the following:
%
%     - filled indices for residual flux
%     - filled indices for initial flux for each planet candidate
%     - CCD row and column coordinates for difference images
%     - centroid row and column for the control and difference images
%     - CCD row and column coordinates for pixel correlation tests
%     - centroid row and column for the control and correlation images
%
% Ensure that empty filled indices vectors are returned explicitly as []
% and not [0 x 1 double].
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

% Set constant.
GAP_VALUE = -1;

% Loop throught the targets, planet candidates and target tables and
% convert the outputs from 1- to 0-base as necessary.
targetResultsStruct = dvResultsStruct.targetResultsStruct;
nTargets = length(targetResultsStruct);

for iTarget = 1 : nTargets
    
    tStruct = targetResultsStruct(iTarget);
    if ~isempty(tStruct.residualFluxTimeSeries.filledIndices)
        tStruct.residualFluxTimeSeries.filledIndices = ...
            tStruct.residualFluxTimeSeries.filledIndices - 1;
    else
        tStruct.residualFluxTimeSeries.filledIndices = [];
    end % if / else
    
    nPlanets = length(tStruct.planetResultsStruct);
    
    for iPlanet = 1 : nPlanets
        
        pStruct = tStruct.planetResultsStruct(iPlanet);
        if ~isempty(pStruct.detrendedFluxTimeSeries.filledIndices)
            pStruct.detrendedFluxTimeSeries.filledIndices = ...
                pStruct.detrendedFluxTimeSeries.filledIndices - 1;
        else
            pStruct.detrendedFluxTimeSeries.filledIndices = [];
        end % if / else
        tStruct.planetResultsStruct(iPlanet) = pStruct;
        
        pStruct = tStruct.planetResultsStruct(iPlanet).planetCandidate;
        if ~isempty(pStruct.initialFluxTimeSeries.filledIndices)
            pStruct.initialFluxTimeSeries.filledIndices = ...
                pStruct.initialFluxTimeSeries.filledIndices - 1;
        else
            pStruct.initialFluxTimeSeries.filledIndices = [];
        end % if / else
        tStruct.planetResultsStruct(iPlanet).planetCandidate = pStruct;
        
        pStruct = tStruct.planetResultsStruct(iPlanet).differenceImageResults;
        nTables = length(pStruct);
        
        for iTable = 1 : nTables
            
            sStruct = pStruct(iTable).kicReferenceCentroid;
            if sStruct.row.uncertainty ~= GAP_VALUE
                sStruct.row.value = sStruct.row.value - 1;
            end % if
            if sStruct.column.uncertainty ~= GAP_VALUE
                sStruct.column.value = sStruct.column.value - 1;
            end % if
            if ~isempty(sStruct.transformationCadenceIndices)
                sStruct.transformationCadenceIndices = ...
                    sStruct.transformationCadenceIndices - 1;
            else
                sStruct.transformationCadenceIndices = [];
            end % if / else
            pStruct(iTable).kicReferenceCentroid = sStruct;
            
            sStruct = pStruct(iTable).controlImageCentroid;
            if sStruct.row.uncertainty ~= GAP_VALUE
                sStruct.row.value = sStruct.row.value - 1;
            end % if
            if sStruct.column.uncertainty ~= GAP_VALUE
                sStruct.column.value = sStruct.column.value - 1;
            end % if
            if ~isempty(sStruct.transformationCadenceIndices)
                sStruct.transformationCadenceIndices = ...
                    sStruct.transformationCadenceIndices - 1;
            else
                sStruct.transformationCadenceIndices = [];
            end % if / else
            pStruct(iTable).controlImageCentroid = sStruct;
            
            sStruct = pStruct(iTable).differenceImageCentroid;
            if sStruct.row.uncertainty ~= GAP_VALUE
                sStruct.row.value = sStruct.row.value - 1;
            end % if
            if sStruct.column.uncertainty ~= GAP_VALUE
                sStruct.column.value = sStruct.column.value - 1;
            end % if
            if ~isempty(sStruct.transformationCadenceIndices)
                sStruct.transformationCadenceIndices = ...
                    sStruct.transformationCadenceIndices - 1;
            else
                sStruct.transformationCadenceIndices = [];
            end % if / else
            pStruct(iTable).differenceImageCentroid = sStruct;
            
            sStruct = pStruct(iTable).differenceImagePixelStruct;
            nPixels = length(sStruct);
            
            for iPixel = 1 : nPixels;
                sStruct(iPixel).ccdRow = sStruct(iPixel).ccdRow - 1;
                sStruct(iPixel).ccdColumn = sStruct(iPixel).ccdColumn - 1;
            end % for iPixel
            
            pStruct(iTable).differenceImagePixelStruct = sStruct;
            
        end % for iTable
        
        tStruct.planetResultsStruct(iPlanet).differenceImageResults = pStruct;
        
        pStruct = tStruct.planetResultsStruct(iPlanet).pixelCorrelationResults;
        nTables = length(pStruct);
        
        for iTable = 1 : nTables
            
            sStruct = pStruct(iTable).kicReferenceCentroid;
            if sStruct.row.uncertainty ~= GAP_VALUE
                sStruct.row.value = sStruct.row.value - 1;
            end % if
            if sStruct.column.uncertainty ~= GAP_VALUE
                sStruct.column.value = sStruct.column.value - 1;
            end % if
            if ~isempty(sStruct.transformationCadenceIndices)
                sStruct.transformationCadenceIndices = ...
                    sStruct.transformationCadenceIndices - 1;
            else
                sStruct.transformationCadenceIndices = [];
            end % if / else
            pStruct(iTable).kicReferenceCentroid = sStruct;
            
            sStruct = pStruct(iTable).controlImageCentroid;
            if sStruct.row.uncertainty ~= GAP_VALUE
                sStruct.row.value = sStruct.row.value - 1;
            end % if
            if sStruct.column.uncertainty ~= GAP_VALUE
                sStruct.column.value = sStruct.column.value - 1;
            end % if
            if ~isempty(sStruct.transformationCadenceIndices)
                sStruct.transformationCadenceIndices = ...
                    sStruct.transformationCadenceIndices - 1;
            else
                sStruct.transformationCadenceIndices = [];
            end % if / else
            pStruct(iTable).controlImageCentroid = sStruct;
            
            sStruct = pStruct(iTable).correlationImageCentroid;
            if sStruct.row.uncertainty ~= GAP_VALUE
                sStruct.row.value = sStruct.row.value - 1;
            end % if
            if sStruct.column.uncertainty ~= GAP_VALUE
                sStruct.column.value = sStruct.column.value - 1;
            end % if
            if ~isempty(sStruct.transformationCadenceIndices)
                sStruct.transformationCadenceIndices = ...
                    sStruct.transformationCadenceIndices - 1;
            else
                sStruct.transformationCadenceIndices = [];
            end % if / else
            pStruct(iTable).correlationImageCentroid = sStruct;
            
            sStruct = pStruct(iTable).pixelCorrelationStatisticStruct;
            nPixels = length(sStruct);
            
            for iPixel = 1 : nPixels;
                
                sStruct(iPixel).ccdRow = sStruct(iPixel).ccdRow - 1;
                sStruct(iPixel).ccdColumn = sStruct(iPixel).ccdColumn - 1;
            
            end % for iPixel
            
            pStruct(iTable).pixelCorrelationStatisticStruct = sStruct;
            
        end % for iTable
        
        tStruct.planetResultsStruct(iPlanet).pixelCorrelationResults = pStruct;
        
    end % for iPlanet
    
    targetResultsStruct(iTarget) = tStruct;
    
end % for iTarget

dvResultsStruct.targetResultsStruct = targetResultsStruct;

% Return.
return
