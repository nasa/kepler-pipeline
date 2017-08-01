  function [r,v]=calcrvfromels(a,e,i,Omega,omega,M,body,degflag);
% [r,v]=calcrvfromels(a,e,i,Omega,omega,M,body,degflag);
% returns the position and velocity of a satellite orbiting body (default Venus) (see gmp.m)
% with orbital elements:
% a 	mean distance in km
% e	eccentricity
% i	inclination
% Omega ascending node
% omega argument of periapsis
% M	mean anomaly
% body, 0 for sun, 1 for Mercury, 2 for Venus, etc.
% degflag (optional), if set, i, Omega, omega, and M are in degrees
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

% convert to radians if degflag is entered
  if nargin==8,
    if degflag==1,
      i=i/rad2deg;
      Omega=Omega/rad2deg;
      omega=omega/rad2deg;
      M=M/rad2deg;
    end
  end

% Determine eccentric anomaly using Newton iteration
  Eold=M;
  E=Eold;
  count=1;
  while count<25&(abs(E-Eold)>1e-7|count==1),
    count=count+1;
    E=E+(M-(E-e*sin(E)))./(1-e*cos(E));
  end

% Find true anomaly
  nu=acos((cos(E)-e)./(1-e*cos(E)));
  if M>.5, nu=2*pi-nu; end

% set up P and Q
  cO=cos(Omega);
  sO=sin(Omega);
  co=cos(omega);
  so=sin(omega);
  ci=cos(i);
  si=sin(i);
  P=[cO*co-sO*so*ci,sO*co+cO*so*ci,so*si];
  Q=[-cO*so-sO*co*ci,-sO*so+cO*co*ci,co*si];

% calculate r and v
  rmag=a*(1-e*cos(E));
  r=rmag*(cos(nu)*P+sin(nu)*Q);
  p=a*(1-e.^2);
  mu=gmp(body)/1000^3;
  v=sqrt(mu/p)*(-sin(nu)*P+(e+cos(nu))*Q);

