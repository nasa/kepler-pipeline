raDec2PixObject = raDec2PixClass(retrieve_ra_dec_2_pix_model(), 'one-based');
% get the spice file information required to get the spacecraft position
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
spiceFileDir  = get(raDec2PixObject, 'spiceFileDir');
spiceFileName = get(raDec2PixObject, 'spiceFileName');

keplerSpiceKernel     = [spiceFileDir '/' spiceFileName];
planetEphemerisKernel = [spiceFileDir '/de405.bsp'];
leapsecondFilename    = [spiceFileDir '/cook_01.tls'];

keplerSpiceId = '-227';
earthSpiceId = '3';
spiceEpoch    = 'J2000';

startDateJulian = datestr2julian('1-Jan-2010');
oneYear = 1:400;
tic
x = zeros(size(oneYear));
y = zeros(size(oneYear));
z = zeros(size(oneYear));
r = zeros(size(oneYear));
for day=oneYear
    utcTimes = julian2datestr(startDateJulian + day -1)';
    [pos vel] = keplerStateVector(utcTimes, earthSpiceId, 'ssb', spiceEpoch,keplerSpiceKernel, planetEphemerisKernel, leapsecondFilename);
    x(day) = pos(1);
    y(day) = pos(2);
    z(day) = pos(3);
    r(day) = norm(pos);
end
toc

figure
plot(oneYear, x, oneYear, y);
legend('x', 'y');
figure
plot(oneYear, z);
title('z');
figure
plot(oneYear, r);
title('r');
