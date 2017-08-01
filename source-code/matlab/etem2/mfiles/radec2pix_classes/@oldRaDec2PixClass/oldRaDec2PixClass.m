function raDec2PixObject = oldRaDec2PixClass(raDec2PixData, runParamsData)
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

observingSeason = runParamsData.simulationData.observingSeason;
moduleNumber = runParamsData.simulationData.moduleNumber;
outputNumber = runParamsData.simulationData.outputNumber;
timeVector = runParamsData.keplerData.timeVector;
orbitFile = runParamsData.keplerData.orbitFile;
numVisibleRows = runParamsData.keplerData.numVisibleRows;
numVisibleCols = runParamsData.keplerData.numVisibleCols;

raDec2PixData.observingSeason = observingSeason;
raDec2PixData.moduleNumber = moduleNumber;
raDec2PixData.timeVector = timeVector;
raDec2PixData.orbitFile = orbitFile;
raDec2PixData.numVisibleRows = numVisibleRows;
raDec2PixData.numVisibleCols = numVisibleCols;

raDec2PixData.raOffset = runParamsData.keplerData.raOffset;
raDec2PixData.decOffset = runParamsData.keplerData.decOffset;
raDec2PixData.phiOffset = runParamsData.keplerData.phiOffset;

fovOrientation = FOV_nominal_center;
[raDec2PixData.fovNominalRa, raDec2PixData.fovNominalDec, ...
    raDec2PixData.fovNominalPhi] = ...
    deal(fovOrientation(1), fovOrientation(2), fovOrientation(3));

% To compute the row/column for each star.  Aberrated pointing is needed.
[aberratedFovRa, aberratedFovDec] = ...
    aberrate_stars( raDec2PixData.fovNominalRa, ...
    raDec2PixData.fovNominalDec, timeVector(1), orbitFile );
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% compute the DVA motion of the center of the module, then find the
% time at which this DVA path is closest to the center of its bounding box.

% Find the RA/Dec of the center of the output for the aberrated pointing
[aberratedModOutCenterRa, aberratedModOutCenterDec] = Pix2RADec(moduleNumber, outputNumber, ...
            (numVisibleRows+1)/2, (numVisibleCols+1)/2, ...
            observingSeason, aberratedFovRa, aberratedFovDec, raDec2PixData.fovNominalPhi);

% Find the unaberrated/true ra/dec of the center of the mod out
% we find that unAberratedFovCenterRa is rather different from fovRa etc.
[unAberratedModOutCenterRa, unAberratedModOutCenterDec] = unaberrate_stars(...
    aberratedModOutCenterRa, aberratedModOutCenterDec, ...
    timeVector(1), orbitFile );

% Find the path of the center of the mod out
[tmpModule, tmpOutput, centerDvaPathRow, centerDvaPathColumn, ...
    aberratedFovPathRa, aberratedFovPathDec, aberratedFovPathPhi] ...
    = kepler_dva_aberrated_path(unAberratedModOutCenterRa, ...
    unAberratedModOutCenterDec, observingSeason, timeVector, 1, 1, orbitFile);
clear tmpModule tmpOutput
% save for later use
raDec2PixData.aberratedFovPath.ra = aberratedFovPathRa;
raDec2PixData.aberratedFovPath.dec = aberratedFovPathDec;
raDec2PixData.aberratedFovPath.phi = aberratedFovPathPhi;

% Find the min/max row & column excursions (by doing min/max across time dimension)
% (i.e. the "box" containing the dva path at the gridpoints)
minDvaRowExcursion = min(centerDvaPathRow);  % min row excursion
maxDvaRowExcursion = max(centerDvaPathRow);  % max row excursion
minDvaColumnExcursion = min(centerDvaPathColumn);  % min col excursion
maxDvaColumnExcursion = max(centerDvaPathColumn);  % max col excursion

% Find the center of the box
dvaRowCenter = (maxDvaRowExcursion + minDvaRowExcursion) / 2;
dvaColumnCenter = (maxDvaColumnExcursion + minDvaColumnExcursion) / 2;

% Find the time index that represents the closest point from the
% DVA curve to the center of the box.
distance = sqrt((centerDvaPathRow - dvaRowCenter).^2 ...
    + (centerDvaPathColumn - dvaColumnCenter).^2 );       
raDec2PixData.centerTimeIndex = find(distance == min(distance),1,'first');
raDec2PixData.centerTime = timeVector(raDec2PixData.centerTimeIndex);

raDec2PixObject = class(raDec2PixData, 'oldRaDec2PixClass');
