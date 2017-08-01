function [durationHours]=transit_duration(rStar,logg,period,eccentricity)
% Calculate transit duration in hours
% assuming uniform distribution on cos(inc) orbits
% assuming rStar/a is small
% assuming rp/rStar is small
% Any vector inputs have to all be same length
% Ecc is hardcoded to be < 0.99
% INPUT
% rStar (scalar/vector) - Radius of star [Rsun]
% logg (scalar/vector) - log surface gravity [cgs]
% period (scalar/vector) - Period of orbit [day]
% eccentricity (scalar/vector) - Eccentricity 
% OUTPUT
% durationHours (scalar/vector) - Transit duration [hr]
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

% Replace large eccentricity with 0.99
eccentricity(eccentricity > 0.99)=0.99;

% Convert logg and rStar into stellar mass
% assuming logg_sun=4.437
mStar=10.0.^logg.*(rStar.^2)./10.0.^(4.437);

% Semi-major axis in AU
semimajorAxis=mStar.^(1.0/3.0).*(period./365.25).^(2.0/3.0);

% transit duration in hours, assuming e=0 and scaling by pi/4, for mean
% expected transit chord (this accounts for impact parameter)
% to account for expected transit chord 
% rSun=6.9598d10 ; %cm Ask Chris where this came from
rSun = 6.95508d10; %cm, from Allen's astrophysical quantities, 3rd ed.,  p. 340
au2cm=1.49598d13 ;% 1 AU = 1.49598e13 cm (agrees to 5 decimal places with Allen's astrophysical quantities, 3rd ed.,  p. 340)
% durationHours=(period.*24.0)./4.0.*(rStar.*rSun)./(semimajorAxis.*au2cm);

% Duration for *full* transit, i.e. impact parameter = 0
durationHours=(period.*24.0)*(rStar.*rSun)./(semimajorAxis.*au2cm)/pi;


% correction to transit duration for e > 0
% durationHours=durationHours.*sqrt(1.0-eccentricity.^2);

end
