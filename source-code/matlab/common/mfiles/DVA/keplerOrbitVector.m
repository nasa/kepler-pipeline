function [rk,vk] = keplerOrbitVector(t,arg2,v0,t0)
% function [rk,vk] = keplerOrbitVector(t) -or-
% function [rk,vk] = keplerOrbitVector(t, filename) -or-
% function [rk,vk] = keplerOrbitVector(t,r0,v0,t0)
%
% keplerOrbitVector() calculates the orbital position and velocity (rk,vk)
% vectors for an object in orbit around the Sun with initial position and
% velocity r0, v0 at julian day t0. It uses the "kepler" suite of functions.
% 
% Inputs:
%       t - julian day time or column-vector of julian days (in units of days)
%       arg2 depends on the number of arguments:
%           if nargin == 2 then arg2 is the filename of the initial orbit file
%           if nargin == 4 then arg2 is r0, the position vector [1x3] at t0 in ecliptic coordinates [I, J, K], in m
%       v0 - velocity vector [1x3] at t0 in ecliptic coordinates in m/s 
%       t0 - julian day of start time (when r0 & v0 were measured)
% Outputs:
%       rk - array of position vectors (km) corresponding to times 't'
%       vk - array of velocity vectors (km/s) corresponding to times 't'
%
% Optionally, the routine may be called with only an input time array t and
% it will use default values for the starting position and velocity vectors
% calculated for the perihelion of the spacecraft before launch. These
% values are loaded from the mat-file KeplerInitialOrbit. Their calculation is
% described in DN-#### 
% 
% Software Level: prototype code - calculate state vector from input orbit
%
% Modification History: written by Doug Caldwell 14 Jan 2005
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

% check to see what mode this was started in
if nargin==1
    load KeplerInitialOrbit
    r0 = r0ke;
    v0 = v0ke;
    t0 = t0jd;
elseif nargin==2
    eval(['load ' arg2]);
    r0 = r0ke;
    v0 = v0ke;
    t0 = t0jd;
elseif nargin==4
    % convert inputs to km because that's what kepler.m needs....
    r0=arg2;
    r0 = r0/1000;
    v0 = v0/1000;
    t0 = t0;
else
    error('keplerOrbitVector: must have 1, 2 or 4 inputs');
end
[rt,ct]=size(t);  % check to be sure t is a column vector, transpose if not
if ct>1 & rt==1
    t = t';  
    disp('keplerOrbitVector: transposing time array');
end

ts = (t-t0)*60*60*24;  % convert time array iinto seconds
t00 = 0;   % use zero for initial time
sun = 0;    % use sun as central body

% call the orbit calculation suite "kepler" to determine the position and
% velocity at the specified times:
%   [r,v]=kepler(t0,r0,v0,t,body,p,e)
%   given t0, r0, v0, t and central body number,
%   kepler returns the position and
%   velocities for the satellite at time(s) t.

[rk, vk] =  kepler(t00, r0, v0, ts, sun);

% Convert km to m
rk = rk*1000;
vk = vk*1000;

return
