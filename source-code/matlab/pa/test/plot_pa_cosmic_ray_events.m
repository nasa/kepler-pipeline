function theseEvents = plot_pa_cosmic_ray_events(inputsStruct, outputsStruct, pixelRow, pixelColumn)
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



rowSize = size(pixelRow);
colSize = size(pixelColumn);

mod = inputsStruct.ccdModule;
out = inputsStruct.ccdOutput;

if( min(rowSize)~=1 )
    error('pixelRow and pixelColumn must be nx1 or 1xn');
end

if( ~isequal(rowSize, colSize) )
    error('pixelRow and pixelColumn must have same size and shape');
end


% extract set of events and row/column pairs from outputsStruct
if( ~isempty(outputsStruct.targetStarCosmicRayEvents) )
    events = rowvec(outputsStruct.targetStarCosmicRayEvents);
    eventRows = [outputsStruct.targetStarCosmicRayEvents.ccdRow];
    eventCols = [outputsStruct.targetStarCosmicRayEvents.ccdColumn];
elseif( ~isempty(outputsStruct.backgroundCosmicRayEvents) )
    events = rowvec(outputsStruct.backgroundCosmicRayEvents);
    eventRows = [outputsStruct.backgroundCosmicRayEvents.ccdRow];
    eventCols = [outputsStruct.backgroundCosmicRayEvents.ccdColumn];
else
    events = [];
    eventRows = [];
    eventCols = [];    
end

clear outputsStruct


% extract location of all pixels in input struct
% should only have background or target pixel not both bu this code will
% handle the case where both are available
if( ~isempty(inputsStruct.targetStarDataStruct) )
    inPixels = [inputsStruct.targetStarDataStruct.pixelDataStruct];
elseif( ~isempty(inputsStruct.backgroundDataStruct) )
    inPixels = [inputsStruct.backgroundDataStruct];
else
    inPixels = [];
end
    
% get caence times
cadenceTimes = [inputsStruct.cadenceTimes.midTimestamps];

clear inputsStruct

% collect pixel location and values
rows = [inPixels.ccdRow];
cols = [inPixels.ccdColumn];
vals = [inPixels.values];
gaps = [inPixels.gapIndicators];



% find which pixels are in input list
inputPixelLogical = ismember(  [rows(:), cols(:)], [pixelRow(:), pixelColumn(:)], 'rows' );

% trim to only the ones founds in the input list
rows = rows(inputPixelLogical);
cols = cols(inputPixelLogical);
vals = vals(:,inputPixelLogical);
gaps = gaps(:,inputPixelLogical);

% set gaps to nan
vals(gaps) = NaN;

% plot time series for input pixels
% figure;
plot(vals);
hold on;


% find subset of events for these input pixels
[validEvent, pixelIndex] = ismember([eventRows(:), eventCols(:)], [rows(:), cols(:)], 'rows' );

% get timestamp index of all valid events
if( ~isempty(events) )
    [tfCadence, timestampIndex] = ...
        ismember([events(validEvent).mjd],cadenceTimes);
end


% overlay CR event markers and fixed points
if( any(validEvent) && any(tfCadence) )
    
    theseEvents = events(validEvent);
    thesePixelIndices = pixelIndex(validEvent);
    theseDeltas = [theseEvents.delta];    
    
    thesePixelVals = vals(sub2ind(size(vals),timestampIndex(:),thesePixelIndices(:)));    
    
    plot(timestampIndex, thesePixelVals(:), 'ko','MarkerSize',10);    
    plot(timestampIndex, thesePixelVals(:) - theseDeltas(:), 'r.');
else
    theseEvents = [];
end


grid;
hold off;
title(['\bfMod.Out = ',num2str(mod),'.',num2str(out),' - Cosmic Rays Detected']);
xlabel('\bfrelative cadence #');
ylabel('\bfpixel value (e-)');



