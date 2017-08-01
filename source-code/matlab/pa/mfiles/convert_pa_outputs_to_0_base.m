function [paResultsStruct] = convert_pa_outputs_to_0_base(paResultsStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [paResultsStruct] = convert_pa_outputs_to_0_base(paResultsStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Convert the PA row/column outputs from 1-based indexing (Matlab) to 0-based
% indexing (Java). Include the row and column centroid time series.
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


% Decrement the referenceRow and referenceColumn for the targetStars, as
% well as the centroidRow and centroidColumn time series for each centroid
% type. Also decrement the CCD coordinates for the centroid aperture flags.
targetStarResultsStruct = paResultsStruct.targetStarResultsStruct;

if ~isempty(targetStarResultsStruct)
    
    nTargets = length(targetStarResultsStruct);
    referenceRowCellArray = num2cell([targetStarResultsStruct.referenceRow] - 1);
    [targetStarResultsStruct(1 : nTargets).referenceRow] = referenceRowCellArray{:};
    
    referenceColumnCellArray = num2cell([targetStarResultsStruct.referenceColumn] - 1);
    [targetStarResultsStruct(1 : nTargets).referenceColumn] = referenceColumnCellArray{:};
    
    for iTarget = 1 : nTargets
        
        targetStruct = targetStarResultsStruct(iTarget);
        
        % The optimalAperture struct also contains referenceRow and referenceColumn
        targetStruct.optimalAperture.referenceRow    = targetStruct.optimalAperture.referenceRow    - 1;
        targetStruct.optimalAperture.referenceColumn = targetStruct.optimalAperture.referenceColumn - 1;

        targetStruct.optimalAperture.distanceFromEdge = targetStruct.optimalAperture.distanceFromEdge - 1;

        targetStruct.prfCentroids.rowTimeSeries.values = ...
            targetStruct.prfCentroids.rowTimeSeries.values - 1;
        targetStruct.prfCentroids.columnTimeSeries.values = ...
            targetStruct.prfCentroids.columnTimeSeries.values - 1;
        targetStruct.fluxWeightedCentroids.rowTimeSeries.values = ...
            targetStruct.fluxWeightedCentroids.rowTimeSeries.values - 1;
        targetStruct.fluxWeightedCentroids.columnTimeSeries.values = ...
            targetStruct.fluxWeightedCentroids.columnTimeSeries.values - 1;
        
        pixelApertureStruct = targetStruct.pixelApertureStruct;
        nPixels = length(pixelApertureStruct);
        ccdRowCellArray = num2cell([pixelApertureStruct.ccdRow] - 1);
        [pixelApertureStruct(1 : nPixels).ccdRow] = ccdRowCellArray{:};
        ccdColumnCellArray = num2cell([pixelApertureStruct.ccdColumn] - 1);
        [pixelApertureStruct(1 : nPixels).ccdColumn] = ccdColumnCellArray{:};
        targetStruct.pixelApertureStruct = pixelApertureStruct;
        
        targetStarResultsStruct(iTarget) = targetStruct;
        
    end % for iTarget
    
    paResultsStruct.targetStarResultsStruct = targetStarResultsStruct;
    
end

% Decrement the ccdRow and ccdColumn for the cosmic ray events.
backgroundCosmicRayEvents = paResultsStruct.backgroundCosmicRayEvents;

if ~isempty(backgroundCosmicRayEvents)
    
    nEvents = length(backgroundCosmicRayEvents);
    ccdRowCellArray = num2cell([backgroundCosmicRayEvents.ccdRow] - 1);
    [backgroundCosmicRayEvents(1 : nEvents).ccdRow] = ccdRowCellArray{:};
    
    ccdColumnCellArray = num2cell([backgroundCosmicRayEvents.ccdColumn] - 1);
    [backgroundCosmicRayEvents(1 : nEvents).ccdColumn] = ccdColumnCellArray{:};
    
    paResultsStruct.backgroundCosmicRayEvents = backgroundCosmicRayEvents;
    
end

targetStarCosmicRayEvents = paResultsStruct.targetStarCosmicRayEvents;

if ~isempty(targetStarCosmicRayEvents)
    
    nEvents = length(targetStarCosmicRayEvents);
    ccdRowCellArray = num2cell([targetStarCosmicRayEvents.ccdRow] - 1);
    [targetStarCosmicRayEvents(1 : nEvents).ccdRow] = ccdRowCellArray{:};
    
    ccdColumnCellArray = num2cell([targetStarCosmicRayEvents.ccdColumn] - 1);
    [targetStarCosmicRayEvents(1 : nEvents).ccdColumn] = ccdColumnCellArray{:};
    
    paResultsStruct.targetStarCosmicRayEvents = targetStarCosmicRayEvents;
    
end

% Decrement the ccdRow and ccdColumn for the bad pixels.
badPixels = paResultsStruct.badPixels;

if ~isempty(badPixels)
    
    nEvents = length(badPixels);
    ccdRowCellArray = num2cell([badPixels.ccdRow] - 1);
    [badPixels(1 : nEvents).ccdRow] = ccdRowCellArray{:};
    
    ccdColumnCellArray = num2cell([badPixels.ccdColumn] - 1);
    [badPixels(1 : nEvents).ccdColumn] = ccdColumnCellArray{:};
    
    paResultsStruct.badPixels = badPixels;
    
end

% Decrement the Argabrightening and reaction wheel zero crossing cadence indices.
if( isfield(paResultsStruct,'argabrighteningIndices') )
    paResultsStruct.argabrighteningIndices = paResultsStruct.argabrighteningIndices - 1;
end

if( isfield(paResultsStruct,'reactionWheelZeroCrossingIndices') )
    paResultsStruct.reactionWheelZeroCrossingIndices  = paResultsStruct.reactionWheelZeroCrossingIndices - 1;
end

% Return.
return
