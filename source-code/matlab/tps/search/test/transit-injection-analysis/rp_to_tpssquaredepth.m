function [depth]=rp_to_tpssquaredepth(rStar,rPlanet,impactParameter)
% Gives transit depth for a given planet and star radius
% INPUT
% rStar (scalar/vector) - Radius of star units of [Rsun]
% rPlanet (scalar/vector) - Radius of planet *** units of [Rearth]***
% OUTPUT
% depth (scalar/vector) - Depth of transit [ppm]
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

% This function converts the physical planet radius
% into the Square pulse TPS match filter depth
%  It starts by converting the k=rPlanet/rStar ratio into the average
%  expected limb darkened transit depth at midpoint.
%  Then scales the midpoint depth to the average depth using
%  results of Q4 injection run results

% Using results from /path/to/depth2rp
% Determined that for linear limb darkening =0.6
% The average limb darkened transit depth, D to purely geometric radius ratio depth, k^2=(rPlanet/rs)^2
% is a roughly linear function of radius ratio
% D/k^2=alpha-beta*k
% For 
%  u = 0.6 alpha = 1.0874 beta = 1.0187
%  u = 0.7 alpha = 1.1068 beta = 1.0379
%  u = 0.5 alpha = 1.0696 beta = 1.001

% Ratio of planet to star radius
% rEarthTorSunRatio=6378137.0/696000000.0;
rEarthMeters = 6378137.0;
rSunMeters = 696000000.0;
planetToStarRadiusRatio =(rPlanet.*rEarthMeters)./(rStar.*rSunMeters);

% Geometric Depth
geometricDepth = (planetToStarRadiusRatio).^2;

% Limb darkening correction with quadratic limb-darkening law
% I/I0 = 1 - alpha.*( 1 - mu ) - beta.*( 1 - mu ).^2;
alpha = 0.40;
beta = 0.27;
mu = sqrt ( 1 - impactParameter.^2);

% Factor of 1.25 scales depth at zero impact parameter
limbDarkeningCorrection =  1.25.*(1 - alpha.*( 1 - mu ) - beta.*( 1 - mu ).^2);

% Transit depth in parts per million
depth = 1.e6.*geometricDepth.*limbDarkeningCorrection;

% Limb darkening correction
% alpha = 1.0874;
% beta = 1.0187;
% depth=(alpha-beta.*sqrt(geometricDepth)).*geometricDepth.*1.0e6;

% Look at /path/to/traninject
% This gives the averaged over transit depth relative to 
%  min transit depth

% This factor corrects for the square wave transit model mismatch
% Used in 9.1 but not in 9.2
% REALDEPTH2TPSSQUARE=0.864;
% depth=depth.*REALDEPTH2TPSSQUARE;

end
