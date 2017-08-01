
function [ccdModuleTilesInFocalPlane, modOutTilesInFocalPlane] = get_ccd_modout_tile_location_in_focal_plane()
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

a = reshape(1:25, 5,5);
a = a';
b = repmat(a,1,2);
c = reshape(b',5, 10);
d = repmat(c,1,2);


ccdModuleTilesInFocalPlane = reshape(d',10,10);


% cut out the corners
ccdModuleTilesInFocalPlane(1:2,1:2) = 0;
ccdModuleTilesInFocalPlane(1:2,end-1:end) = 0;
ccdModuleTilesInFocalPlane(end-1:end, 1:2) = 0;
ccdModuleTilesInFocalPlane(end-1:end, end-1:end) = 0;

o1 = [ 4 3; 1 2];
o2 = rot90(o1);
o3 = rot90(o2);
o4 = rot90(o3);

modOutTilesInFocalPlane = zeros(10,10);

% tile the focal plane with patterns o1 ...o4
modOutTilesInFocalPlane(1:2,:) = repmat(o1,1,5);
modOutTilesInFocalPlane(:,1:2) = repmat(o2,5,1);

modOutTilesInFocalPlane(end-1:end,:) = repmat(o3,1,5);
modOutTilesInFocalPlane(:,end-1:end) = repmat(o4,5,1);

% cut out the corners
modOutTilesInFocalPlane(1:2,1:2) = 0;
modOutTilesInFocalPlane(1:2,end-1:end) = 0;
modOutTilesInFocalPlane(end-1:end, 1:2) = 0;
modOutTilesInFocalPlane(end-1:end, end-1:end) = 0;

g = zeros(6,6);
g(1:2, 1:4) = repmat(o1, 1, 2);
g(end-3:end, 1:2) = repmat(o2,  2,1);

g(end-1:end, end-3:end) = repmat(o3,1, 2);
g(end-3:end, end-1:end) = repmat(o4,2,1);
g(1:4, end-1:end) = repmat(o4,2,1);

g(3:4, 3:4) = o3;

modOutTilesInFocalPlane(3:8, 3:8) = g;

return;

