function [catalog, maskStatistics] = extract_catalog_data(tadRunName, outputFilename)
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

useV10Table = 0;

dateStr = '1 May 2009';
dateMjd = datestr2mjd(dateStr);

catalog = struct('keplerMagnitude', [], ...
    'keplerId', [], ...
    'ra', [], ...
    'dec', [], ...
    'isATarget', [], ...
    'tadCrowding', [], ...
    'extendedCrowding', [], ...
    'fluxFractionInAperture', [], ...
    'SNR', [], ...
    'numPixels', [], ...
    'numTargetDefinitions', [], ...
    'tadStatus', [], ...
    'distanceFromEdge', [], ...
    'maskFlux', [], ...
    'optimalFlux', [], ...
    'maskList', [], ...
    'module', [], ...
    'output', []);

maskStatistics = struct('useCount', zeros(1024, 1), ...
	'size', zeros(1024, 2), ...
	'nPixels', zeros(1024, 1));
	
for module = [2:4 6:20 22:24]
    display(['module ' num2str(module)]);
    for output = 1:4
        [smallCatalog, maskStatistics] = extract_small_catalog(module, output, dateMjd, maskStatistics, tadRunName);
        
        catalog.keplerId = [catalog.keplerId smallCatalog.keplerId];
        catalog.keplerMagnitude = [catalog.keplerMagnitude smallCatalog.keplerMagnitude];
        catalog.ra = [catalog.ra smallCatalog.ra];
        catalog.dec = [catalog.dec smallCatalog.dec];
        catalog.isATarget = [catalog.isATarget smallCatalog.isATarget];
        catalog.tadCrowding = [catalog.tadCrowding smallCatalog.tadCrowding];
        catalog.extendedCrowding = [catalog.extendedCrowding smallCatalog.extendedCrowding];
        catalog.fluxFractionInAperture = [catalog.fluxFractionInAperture smallCatalog.fluxFractionInAperture];
        catalog.SNR = [catalog.SNR smallCatalog.SNR];
        catalog.numPixels = [catalog.numPixels smallCatalog.numPixels];
        catalog.numTargetDefinitions = [catalog.numTargetDefinitions smallCatalog.numTargetDefinitions];
        catalog.tadStatus = [catalog.tadStatus smallCatalog.tadStatus];
        catalog.distanceFromEdge = [catalog.distanceFromEdge smallCatalog.distanceFromEdge];
        catalog.maskFlux = [catalog.maskFlux smallCatalog.maskFlux];
        catalog.optimalFlux = [catalog.optimalFlux smallCatalog.optimalFlux];
        catalog.maskList = [catalog.maskList smallCatalog.maskList];
        catalog.module = [catalog.module module*ones(size(smallCatalog.keplerId))];
        catalog.output = [catalog.output output*ones(size(smallCatalog.keplerId))];
        clear smallCatalog;
    end
end

[catalog.keplerMagnitude sortIndex] = sort(catalog.keplerMagnitude, 'ascend');
catalog.keplerId = catalog.keplerId(sortIndex);
catalog.ra = catalog.ra(sortIndex);
catalog.dec = catalog.dec(sortIndex);
catalog.isATarget = catalog.isATarget(sortIndex);
catalog.tadCrowding = catalog.tadCrowding(sortIndex);
catalog.extendedCrowding = catalog.extendedCrowding(sortIndex);
catalog.fluxFractionInAperture = catalog.fluxFractionInAperture(sortIndex);
catalog.SNR = catalog.SNR(sortIndex);
catalog.numPixels = catalog.numPixels(sortIndex);
catalog.numTargetDefinitions = catalog.numTargetDefinitions(sortIndex);
catalog.tadStatus = catalog.tadStatus(sortIndex);
catalog.distanceFromEdge = catalog.distanceFromEdge(sortIndex);
catalog.maskFlux = catalog.maskFlux(sortIndex);
catalog.optimalFlux = catalog.optimalFlux(sortIndex);
catalog.maskList = catalog.maskList(sortIndex);
catalog.module = catalog.module(sortIndex);
catalog.output = catalog.output(sortIndex);

save(outputFilename, 'catalog', 'maskStatistics');

function [smallCatalog, maskStatistics] = extract_small_catalog(module, output, dateMjd, maskStatistics, tadRunName)
kics = retrieve_kics(module, output, dateMjd);
% tadStruct = retrieve_tad(module, output, 'prf-v3');
% tadStruct = retrieve_tad(module, output, 'prf-trimmed-v1');

tadStruct = retrieve_tad(module, output, tadRunName);
optAps = tadStruct.targets;

% load desired mask table here
masks = tadStruct.maskDefinitions;
targetDefs = tadStruct.targetDefinitions;


ccdImage = tadStruct.coaImage;

for m=1:length(masks)
	maskImage = target_definition_to_image(masks(m));
	maskStatistics.size(m,:) = size(maskImage);
	maskStatistics.nPixels(m) = sum(maskImage(:));
end

smallCatalog = struct('keplerMagnitude', zeros(1, length(kics)), ...
    'keplerId', zeros(1, length(kics)), ...
    'ra', zeros(1, length(kics)), ...
    'dec', zeros(1, length(kics)), ...
    'isATarget', zeros(1, length(kics)), ...
    'tadCrowding', zeros(1, length(kics)), ...
    'extendedCrowding', zeros(1, length(kics)), ...
    'fluxFractionInAperture', zeros(1, length(kics)), ...
    'SNR', zeros(1, length(kics)), ...
    'numPixels', zeros(1, length(kics)), ...
    'numTargetDefinitions', zeros(1, length(kics)), ...
    'tadStatus', zeros(1, length(kics)), ...
    'distanceFromEdge', zeros(1, length(kics)), ...
    'maskFlux', zeros(1, length(kics)), ...
    'optimalFlux', zeros(1, length(kics)), ...
	'maskList', repmat(struct('list', []), 1, length(kics)));

catalogCount = 1;
for i=1:length(kics)
    keplerId = double(kics(i).getKeplerId());
    keplerMagnitude = double(kics(i).getKeplerMag());
    ra = double(kics(i).getRa());
    dec = double(kics(i).getDec());
    
    if ~isempty(keplerId) && ~isempty(keplerMagnitude) && ~isempty(ra) ...
            && ~isempty(dec)
        if keplerMagnitude > 1 && keplerMagnitude < 15
            smallCatalog.keplerId(catalogCount) = keplerId;
            smallCatalog.keplerMagnitude(catalogCount) = keplerMagnitude;
            smallCatalog.ra(catalogCount) = ra;
            smallCatalog.dec(catalogCount) = dec;
			
			tadOptIndex = find([optAps.keplerId] == keplerId);
			if ~isempty(tadOptIndex)
				smallCatalog.isATarget(catalogCount) = 1;
				optAp = optAps(tadOptIndex);
            	smallCatalog.tadCrowding(catalogCount) = optAp.crowdingMetric;
            	smallCatalog.fluxFractionInAperture(catalogCount) = optAp.fluxFractionInAperture;
            	smallCatalog.SNR(catalogCount) = optAp.SNR;
				optApRows = optAp.referenceRow + 1 + [optAp.offsets.row];
				optApCols = optAp.referenceColumn + 1 + [optAp.offsets.column];
            	smallCatalog.optimalFlux(catalogCount) = 0;
				for p=1:length(optApRows)
					smallCatalog.optimalFlux(catalogCount) = smallCatalog.optimalFlux(catalogCount) ...
						+ ccdImage(optApRows(p), optApCols(p));
				end

				tadTargetDefIndex = find([targetDefs.keplerId] == keplerId);
				smallCatalog.numTargetDefinitions(catalogCount) = length(tadTargetDefIndex);
				smallCatalog.numPixels(catalogCount) = 0;
				smallCatalog.maskFlux(catalogCount) = 0;
				smallCatalog.tadStatus(catalogCount) = inf;
				smallCatalog.distanceFromEdge(catalogCount) = inf;
 				for t=1:length(tadTargetDefIndex)
					targetDef = targetDefs(tadTargetDefIndex(t));
					maskIndex = targetDef.maskIndex + 1;
					mask = masks(maskIndex);
					smallCatalog.maskList(catalogCount).list = [smallCatalog.maskList(catalogCount).list, maskIndex];
					maskStatistics.useCount(maskIndex) = maskStatistics.useCount(maskIndex) + 1;
					smallCatalog.numPixels(catalogCount) = smallCatalog.numPixels(catalogCount) ...
						+ length(mask.offsets);
					smallCatalog.tadStatus(catalogCount) ...
                        = min([smallCatalog.tadStatus(catalogCount), targetDef.status]);
					smallCatalog.distanceFromEdge(catalogCount) ...
                        = min([smallCatalog.distanceFromEdge(catalogCount), optAp.distanceFromEdge]);
					maskRows = targetDef.referenceRow + 1 + [mask.offsets.row];
					maskCols = targetDef.referenceColumn + 1 + [mask.offsets.column];
 					for p=1:length(maskRows)
						smallCatalog.maskFlux(catalogCount) = smallCatalog.maskFlux(catalogCount) ...
							+ ccdImage(maskRows(p), maskCols(p));
					end
				end
				smallCatalog.extendedCrowding(catalogCount) ...
					= (smallCatalog.tadCrowding(catalogCount)/smallCatalog.fluxFractionInAperture(catalogCount)) ...
						* (smallCatalog.optimalFlux(catalogCount)/smallCatalog.maskFlux(catalogCount));
			end
			
            catalogCount = catalogCount + 1;
        end
    end
end
clear kics
smallCatalog.keplerId(catalogCount:end) = [];
smallCatalog.keplerMagnitude(catalogCount:end) = [];
smallCatalog.ra(catalogCount:end) = [];
smallCatalog.dec(catalogCount:end) = [];
smallCatalog.isATarget(catalogCount:end) = [];
smallCatalog.tadCrowding(catalogCount:end) = [];
smallCatalog.extendedCrowding(catalogCount:end) = [];
smallCatalog.fluxFractionInAperture(catalogCount:end) = [];
smallCatalog.SNR(catalogCount:end) = [];
smallCatalog.numPixels(catalogCount:end) = [];
smallCatalog.numTargetDefinitions(catalogCount:end) = [];
smallCatalog.tadStatus(catalogCount:end) = [];
smallCatalog.distanceFromEdge(catalogCount:end) = [];
smallCatalog.maskFlux(catalogCount:end) = [];
smallCatalog.optimalFlux(catalogCount:end) = [];
smallCatalog.maskList(catalogCount:end) = [];


function a = ret_good(value)
if ~isempty(value)
    a = value;
else
    a = -1e18;
end
