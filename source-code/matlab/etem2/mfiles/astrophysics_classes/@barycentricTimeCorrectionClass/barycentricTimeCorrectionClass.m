function barycentricTimeCorrectionObject = barycentricTimeCorrectionClass(...
    barycentricTimeCorrectionData, runParamsData)
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
etem2RaDec2PixObject = runParamsData.raDec2PixObject;
raDec2PixObject = get(etem2RaDec2PixObject, 'raDec2PixObject');

% get the spice file information required to get the spacecraft position
spiceFileDir  = get(raDec2PixObject, 'spiceFileDir');
spiceFileName = get(raDec2PixObject, 'spiceFileName');

% barycentricTimeCorrectionData.keplerSpiceKernel     = [spiceFileDir '/' spiceFileName];
% barycentricTimeCorrectionData.planetEphemerisKernel = [spiceFileDir '/de405.bsp'];
% barycentricTimeCorrectionData.leapsecondFilename    = [spiceFileDir '/cook_01.tls'];

% proper way to set these filenames from Kester
leapsecondFileName = get(raDec2PixObject, 'leapsecondFileName');
planetaryEphemerisFileName = get(raDec2PixObject, 'planetaryEphemerisFileName');

barycentricTimeCorrectionData.keplerSpiceKernel     = [spiceFileDir '/' spiceFileName];
barycentricTimeCorrectionData.planetEphemerisKernel = [spiceFileDir '/' leapsecondFileName];
barycentricTimeCorrectionData.leapsecondFilename    = [spiceFileDir '/' planetaryEphemerisFileName];

% the (x,y,z) coordinates returned by keplerStateVector are defined by:
% the (x,y) plane is in the Earth's coordinate plane the origin at the 
% solar system barycenter, +x axis pointing at RA = 12h (vernal equinox) and
% +y axis pointing at RA = 18h (winter solstice).  z is positive max at RA = 18h.
%
% Define conventional spherical coordinates 
% 	theta = angle from +x-axis towards the +y-axis,
% 	phi = angle from the +z-axis towards the x-y plane.
%
% To convert from RA (in hours), dec to this coordinate system:  
%	theta = (RA - 12)*15 (or theta = RA - 180 for RA in degrees)
% 	phi = 90 - dec
%
% The unit vector pointed at a given RA, dec has the coordinates
%	x = cos(theta)*sin(phi)
%	y = sin(theta)*sin(phi)
%	z = cos(phi)
% 

barycentricTimeCorrectionObject = class(barycentricTimeCorrectionData, ...
	'barycentricTimeCorrectionClass');
