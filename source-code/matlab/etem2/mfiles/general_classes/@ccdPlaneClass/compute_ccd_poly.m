function ccdPlaneObject = compute_ccd_poly(ccdPlaneObject, ccdObject)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% function ccdPlaneObject = compute_ccd_poly(ccdPlaneObject, ccdObject)
%
% imbed the visible pixel polynomial coefficients into the full ccd
% based on the first half of ETEM1 gencccdnew.m
%
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

if exist(ccdPlaneObject.ccdPixelPolyFilename, 'file')
    return;
end

runParamsObject = ccdPlaneObject.runParamsClass;
numVisibleRows = get(runParamsObject, 'numVisibleRows');
numVisibleCols = get(runParamsObject, 'numVisibleCols');
numMaskedSmear = get(runParamsObject, 'numMaskedSmear');
numVirtualSmear = get(runParamsObject, 'numVirtualSmear');
numLeadingBlack = get(runParamsObject, 'numLeadingBlack');
numTrailingBlack = get(runParamsObject, 'numTrailingBlack');
numCcdRows = get(runParamsObject, 'numCcdRows');
numCcdCols = get(runParamsObject, 'numCcdCols');
integrationTime = get(runParamsObject, 'integrationTime');
transferTime = get(runParamsObject, 'transferTime');
nCoefs = get(runParamsObject, 'nCoefs');
endian = get(runParamsObject, 'endian');
targetImageSize = get(runParamsObject, 'targetImageSize');

flatFieldObjectList = get(ccdObject, 'flatFieldObjectList');
visibleBackgroundObjectList = get(ccdObject, 'visibleBackgroundObjectList');
pixelBackgroundObjectList = get(ccdObject, 'pixelBackgroundObjectList');

planeNumber = ccdPlaneObject.planeNumber;

displayFlag = ccdPlaneObject.diagnosticDisplay;

visiblePixPolyInputFilename = ccdPlaneObject.visiblePixelPolyFilename;
ccdPolyOutputFilename = ccdPlaneObject.ccdPixelPolyFilename;

visiblePixPolyInputFid = fopen(visiblePixPolyInputFilename, 'r', endian);
ccdPixPolyOutputFid = fopen(ccdPolyOutputFilename, 'w', endian);

flatField = ones(numVisibleRows, numVisibleCols);
% build the flat field signal
nSignals = length(flatFieldObjectList);
for s = 1:nSignals 
    flatField = flatField .* get(flatFieldObjectList{s});
end
% diagnostic flat:
% flatField = ones(size(flatField));
% flatField(:,200:400) = 0.1;
% flatField(100:150,:) = 0.1;

nPrfs = length(ccdPlaneObject.psf);
for p=1:nPrfs
	h = waitbar(0, ['computing ccd pixel polynomial for prf ' num2str(p)]);

	% compute each coefficient for the full ccd polynomial
	for c = 1:nCoefs
    	% get the visible pixel polynomial coefficients for this polnomial term
    	visiblePixPolyCoefPlane = fread(visiblePixPolyInputFid, ...
        	[numVisibleRows, numVisibleCols], 'float32');

    	% scale by the integration time
    	visiblePixPolyCoefPlane = visiblePixPolyCoefPlane * integrationTime;

    	% if this is constant term on the first plane add the noise sources
    	if c == 1 && planeNumber == 1
        	background = 0;
        	% get the astrophysical background signal for visible pixels
        	nSignals = length(visibleBackgroundObjectList);
        	for s = 1:nSignals 
            	background = background + get(visibleBackgroundObjectList{s});
        	end
        	visiblePixPolyCoefPlane = visiblePixPolyCoefPlane + background * integrationTime;

        	clear background
        end
        
        % apply spatially varying quantum efficiency
        visiblePixPolyCoefPlane = modulate_spatial_qe( ...
            get(ccdObject, 'electronsToAduObject'), visiblePixPolyCoefPlane);
        
    	if c == 1 && planeNumber == 1
        	background = 0;
        	% get the pixel background signal for all physical pixels (e.g.
        	% dark current)
        	nSignals = length(pixelBackgroundObjectList);
        	for s = 1:nSignals 
            	background = background + get(pixelBackgroundObjectList{s});
        	end
        	visiblePixPolyCoefPlane = visiblePixPolyCoefPlane + background * integrationTime;

        	clear background
    	end
    	% multiply by the flat field signals
        visiblePixPolyCoefPlane = visiblePixPolyCoefPlane .* flatField;

    	% imbed the polynomial pixels into the larger ccd containing smear and
    	% black pixels
    	visiblePixPolyCoefPlane = ...
        	[zeros(numMaskedSmear, numVisibleCols); visiblePixPolyCoefPlane; ...
        	zeros(numVirtualSmear, numVisibleCols)];

    	% now add the noise signals to the physical collateral pixels
    	% if this is the constant term on the first plane
    	if c == 1 && planeNumber == 1
        	background = 0;
        	% get the pixel background signal for all physical pixels (e.g.
        	% dark current)
        	nSignals = length(pixelBackgroundObjectList);
        	for s = 1:nSignals 
            	background = background + get(pixelBackgroundObjectList{s});
        	end
        	% add the background only to the physical masked smear pixels
        	visiblePixPolyCoefPlane(1:numMaskedSmear,:) = ...
            	visiblePixPolyCoefPlane(1:numMaskedSmear,:) + background * integrationTime;

        	clear background
        end

        if ~get(runParamsObject, 'supressSmear');
            % add smear, average of all the pixel values in a column (including
            % smear), scaled to per second, times the transfer time.
            smearSignal = sum(visiblePixPolyCoefPlane, 1)*transferTime ...
                / (integrationTime * numCcdRows);

            % add the smear to each row
            for r=1:numCcdRows
                visiblePixPolyCoefPlane(r, :) = visiblePixPolyCoefPlane(r, :) + smearSignal;
            end
            clear smearSignal
        end
        
    	% add in the black columns, setting black values to zero
    	visiblePixPolyCoefPlane = [zeros(size(visiblePixPolyCoefPlane,1),numLeadingBlack), ...
        	visiblePixPolyCoefPlane, zeros(size(visiblePixPolyCoefPlane,1),numTrailingBlack)];

    	fwrite(ccdPixPolyOutputFid, visiblePixPolyCoefPlane, 'float32');
    	waitbar(c/nCoefs);
	end
	close (h);
end % loop over PRFs
