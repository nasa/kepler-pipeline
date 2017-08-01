function catalogData = read_catalog(modifyCatalogObject, ccdObject)
%
% Copyright 2017 United States Government as represented by the
% Administrator of the National Aeronautics and Space Administration.
% All Rights Reserved.
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

runParamsObject = modifyCatalogObject.runParamsClass;

moduleNumber = get(runParamsObject, 'moduleNumber');
outputNumber = get(runParamsObject, 'outputNumber');
observingSeason = get(runParamsObject, 'observingSeason');
numVisibleRows = get(runParamsObject, 'numVisibleRows');
numVisibleCols = get(runParamsObject, 'numVisibleCols');
timeVector = get(runParamsObject, 'timeVector'); % in julian days
raDec2PixObject = get(runParamsObject, 'raDec2PixObject');
centerTimeIndex = get(raDec2PixObject, 'centerTimeIndex');

catalogData = read_catalog(modifyCatalogObject.inputCatalogObject);

%  set the time for the catalog load
catalogLoadTime = timeVector(centerTimeIndex); % convert to mjd

%%%%%
% remove stars
%%%%%

for i=1:length(modifyCatalogObject.removeStarsList)
    magnitudeRange = modifyCatalogObject.removeStarsList(i).magnitudeRange;
    % find candidate stars
    inRangeIndex = find(catalogData.keplerMagnitude >= magnitudeRange(1) ...
        & catalogData.keplerMagnitude <= magnitudeRange(2));
    % mix 'em up
    inRangeIndex = inRangeIndex(randperm(length(inRangeIndex)));
    nStarsToRemove = min(length(inRangeIndex), ...
        modifyCatalogObject.removeStarsList(i).nStarsToRemove);
    % pick the first nStarsToRemove to remove
    selectedIndex = inRangeIndex(1:nStarsToRemove);
    % remove those stars
    [rejectedStars, catalogData] = select_structure_vectors(catalogData, selectedIndex);
end

%%%%%
% modify the magnitudes of stars
%%%%%

for i=1:length(modifyCatalogObject.modifyMagnitudesList)
    magnitudeRange = modifyCatalogObject.modifyMagnitudesList(i).magnitudeRange;
    % find candidate stars
    inRangeIndex = find(catalogData.keplerMagnitude >= magnitudeRange(1) ...
        & catalogData.keplerMagnitude <= magnitudeRange(2));
    % mix 'em up
    inRangeIndex = inRangeIndex(randperm(length(inRangeIndex)));
    nStarsToModify = min(length(inRangeIndex), ...
        modifyCatalogObject.modifyMagnitudesList(i).nStarsToModify);
    % pick the first nStarsToRemove to remove
    selectedIndex = inRangeIndex(1:nStarsToModify);
    % modify those star's magnitudes
    magnitudeOffsetCenter = modifyCatalogObject.modifyMagnitudesList(i).magnitudeOffsetCenter;
    magnitudeOffsetStd = modifyCatalogObject.modifyMagnitudesList(i).magnitudeOffsetStd;
    magnitudeOffsets = magnitudeOffsetCenter + magnitudeOffsetStd*randn(nStarsToModify,1);
    switchSigns = rand(size(magnitudeOffsets));
    magnitudeOffsets(switchSigns < 0.5) = -magnitudeOffsets(switchSigns < 0.5);
    catalogData.keplerMagnitude(selectedIndex) = ...
        catalogData.keplerMagnitude(selectedIndex) + magnitudeOffsets;
end

%%%%%
% add stars
%%%%%

% get the ra and dec of the corners of the mod/out to get a rough guess of
% legal ra, dec
cornerRow = [1 1 1024 1024 1]';
cornerCol = [1 1100 1100 1 1]';
[cornerRa cornerDec] = ...
    pix_to_ra_dec(raDec2PixObject, repmat(moduleNumber, size(cornerRow)), ...
	repmat(outputNumber, size(cornerRow)), ...
    cornerRow, cornerCol, catalogLoadTime, 1);
maxRa = max(cornerRa);
minRa = min(cornerRa);
maxDec = max(cornerDec);
minDec = min(cornerDec);

fakeKicId = modifyCatalogObject.fakeKicIdStart;
nStarsInOriginalCatalog = length(catalogData.kicId);
for i=1:length(modifyCatalogObject.addStarsList)
    magnitudeRange = modifyCatalogObject.addStarsList(i).magnitudeRange;
    nStarsToAdd = modifyCatalogObject.addStarsList(i).nStarsToAdd;
    
    newMagnitudes = magnitudeRange(1) ...
		+ rand(nStarsToAdd,1)*(magnitudeRange(2) - magnitudeRange(1));
    for s=1:nStarsToAdd
        % find a legal ra and dec
        looking = 1;
        lcount = 0;
        while looking
            % guess a legal ra, dec
            ra = minRa + rand(1,1)*(maxRa - minRa);
            dec = minDec + rand(1,1)*(maxDec - minDec);
            % check to see if it's on silicon
            % Find the module, output, row, and column of the stars left in the catalog
            [m, o, r, c] = ...
                ra_dec_to_pix(raDec2PixObject, ra, dec, catalogLoadTime); 
            if m == moduleNumber && o == outputNumber
                looking = 0;
            end
            lcount = lcount + 1;
            if lcount > 1e3
                error('taking too long to find a legal ra, dec');
            end
        end
        % copy some random star's data
        sourceStarIndex = randperm(nStarsInOriginalCatalog);
        catalogData.ra  = [catalogData.ra; ra];
        catalogData.dec = [catalogData.dec; dec];
        catalogData.kicId = [catalogData.kicId; fakeKicId];
        catalogData.keplerMagnitude = [catalogData.keplerMagnitude; newMagnitudes(s)];
        catalogData.logSurfaceGravity = [catalogData.logSurfaceGravity; ...
            catalogData.logSurfaceGravity(sourceStarIndex(1))];
        catalogData.logMetallicity = [catalogData.logMetallicity; ...
            catalogData.logMetallicity(sourceStarIndex(1))];
        catalogData.effectiveTemperature = [catalogData.effectiveTemperature; ...
            catalogData.effectiveTemperature(sourceStarIndex(1))];
        fakeKicId = fakeKicId + 1;
    end
end


