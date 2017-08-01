function [ccdData skyData] = get_star_position(location, keplerIdList)
% function [ccdData skyData] = get_star_position(location, keplerIdList)
%
% return the ETEM pixel position for each star in the keplerIdList for a
% specific ETEM run
%
% inputs:
%   location: ETEM output directory for the desired run.  Must contain the
%   files catalogData.mat and motionBasis.mat.
% 
%   keplerIdList (optional): list of Kepler IDs for the desired stars. If
%   this is missing, the kepler IDs of the target stars for this run are
%   loaded (from the file scienceTargetList.mat).
%
% outputs:
%   ccdData: # of Kepler IDs x 1 struct array with the following
%   fields:
%       .row, .column: # of cadences x 1 arrays with the row and column
%       positions of this star for each cadence
%       .keplerId: keplerId of this star
%   skyData: (optional) # of Kepler IDs x 1 struct array with the following
%   fields:
%       .ra, .dec: # of cadences x 1 arrays with the ra and dec
%       positions of this star for each cadence
%       .keplerId: keplerId of this star
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

% load the required data
if nargin < 2
    load([location filesep 'scienceTargetList.mat']);
    keplerIdList = [targetList.keplerId];
end
load([location filesep 'catalogData.mat']);
load([location filesep 'motionBasis.mat']);
load([location filesep 'inputStructs.mat']);

raDec2PixObject = raDec2PixClass(retrieve_ra_dec_2_pix_model(), 'one-based');
mjdDate = datestr2mjd(runParamsData.simulationData.runStartDate);

simData = runParamsData.keplerData;
% compute the mjd time of each cadence
cadenceTime = simData.exposuresPerShortCadence * simData.shortsPerLongCadence ...
	* (simData.integrationTime + simData.transferTime)/(24*3600);

% # of sub-pixel locations that ETEM bins star positions to
nSubPix = runParamsData.keplerData.nSubPixelLocations;

nKeplerIds = length(keplerIdList);
nCadences = size(motionBasis1(1,1).designMatrix, 1);
ccdData = repmat(struct('row', zeros(nCadences, 1), ...
    'column', zeros(nCadences, 1), 'keplerId', 0), nKeplerIds, 1);
	
if nargout > 1
	ccdData = repmat(struct('ra', zeros(nCadences, 1), ...
    	'dec', zeros(nCadences, 1), 'keplerId', 0), nKeplerIds, 1);
end 
% module = repmat(runParamsData.simulationData.moduleNumber, nCadences, 1);
% output = repmat(runParamsData.simulationData.outputNumber, nCadences, 1);
module = runParamsData.simulationData.moduleNumber;
output = runParamsData.simulationData.outputNumber;

timeVector = mjdDate + cadenceTime*((1:nCadences) - 1);

nMotionRows = size(motionBasis1, 1);
nMotionCols = size(motionBasis1, 2);

% get the positions at which the DVA/jitter motion offset are defined
rowArray = zeros(nCadences, nMotionRows, nMotionCols);
colArray = zeros(nCadences, nMotionRows, nMotionCols);
for r=1:nMotionRows
    for c=1:nMotionCols
        constantTerm = motionBasis1(r, c).designMatrix(:,1);
        rowArray(:, r, c) = motionBasis1(r, c).designMatrix(:,2)./constantTerm;
        colArray(:, r, c) = motionBasis1(r, c).designMatrix(:,3)./constantTerm;
    end
end

% get the DVA/jitter motion offset data and create interpolation
% polynomials
for cadence=1:nCadences
    rowData = squeeze(rowArray(cadence, :, :));
    colData = squeeze(colArray(cadence, :, :));
    rowMotionPoly(cadence) = weighted_polyfit2d(motionGridRow(:), ... 
        motionGridCol(:), rowData(:), 1, 3);
    colMotionPoly(cadence) = weighted_polyfit2d(motionGridRow(:), ...
        motionGridCol(:), colData(:), 1, 3);
end

% compute the star positions for all cadences
for k= 1:nKeplerIds
    % find the catalog entry for this star
    catalogIndex = find(keplerIdList(k) == catalogData.kicId);
    if ~isempty(catalogIndex)
        % invert the ETEM binning for formula
        baseRow = catalogData.row(catalogIndex) ...
            + (catalogData.rowFraction(catalogIndex)-1)/nSubPix;
        baseColumn = catalogData.column(catalogIndex) ...
            + (catalogData.columnFraction(catalogIndex)-1)/nSubPix;

        % add interpolated DVA/jitter motion
        ccdData(k).row = baseRow ...
            + weighted_polyval2d(baseRow, baseColumn, rowMotionPoly);
        ccdData(k).column = baseColumn ...
            + weighted_polyval2d(baseRow, baseColumn, colMotionPoly);
        % set the Kepler ID
        ccdData(k).keplerId = keplerIdList(k);

		if nargout > 1
			for c = 1:nCadences
        		[skyData(k).ra(c), skyData(k).dec(c)] = pix_2_ra_dec(raDec2PixObject, ...
            		module, output, ccdData(k).row(c), ccdData(k).column(c), timeVector(c));
        		% set the Kepler ID
        		skyData(k).keplerId = keplerIdList(k);
			end
		end

        % row = baseRow + rowArray(:,3,3);
        % column = baseColumn + colArray(:,3,3);
    end
end
