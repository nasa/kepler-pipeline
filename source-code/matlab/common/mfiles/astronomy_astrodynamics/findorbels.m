  function [p,e,i,Omega,omega,nu0,T,P,Q,W]=findorbels(t,r,v,body);
% [p,e,i,Omega,omega,nu0,T,P,Q,W]=findorbels(t,r,v);
% returns the best-fit classical orbital elements corresponding to a satellite
% with position r and velocity at times in array t. (in km and km/s)
% p == semilatus rectum
% e == eccentricity
% i == inclination
% Omega == longitude of ascending node
% omega == argument of periapsis
% nu0 == true anomaly at epoch
% T == time of periapsis
% P,Q,W are the unit vectors of the perifocal coordinate system in terms
% of the input coordinate system
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

% body is the central orbiting body
% 0==sun
% 1==Mercury, etc.

% some useful arrays
  rmag=magvec(r);
  vmag=magvec(v);
  if nargin==4,
    mu=gmp(body)/1000^3;% km^(-3)/s^2
  else
    mu=gmp(2)/1000^3;% km^(-3)/s^2
  end

% determine angular momentum vectors
  h=uxv(r,v);
  hmag=magvec(h);

% determine node vector
  n=uxv([0 0 1],h);
  nmag=magvec(n);

% determine evec
  scal1=(vmag.^2-mu./rmag)/mu;
  scal2=udotv(r,v)/mu;
  evec=scalev(scal1,r)-scalev(scal2,v);

% determine orbital elements

  p=hmag.^2/mu;% semi-latus rectum
  if nargout==1, return, end

  e=magvec(evec);% eccentricity
  if nargout==2, return, end

  a=p./(1-e.^2);% major axis

  i=acos(h(:,3)./hmag);% inclination
  if nargout==3, return, end

  Omega=acos(n(:,1)./nmag);% longitude of ascending node
  j=find(n(:,2)<=0);
  if ~isempty(j),
    Omega(j)=2*pi-Omega(j);
  end
  if nargout==4, return, end

  omega=acos(udotv(n,evec)./(nmag.*e));% argument of periapsis
  j=find(evec(:,3)<=0);
  if ~isempty(j),
    omega(j)=2*pi-omega(j);
  end
  if nargout==5, return, end

  nu0=acos(udotv(evec,r)./(e.*rmag));% true anomaly at epoch
  j=find(udotv(r,v)<=0);
  if ~isempty(j),
    nu0(j)=-nu0(j);
  end
  if nargout==6, return, end

  u0=acos(udotv(n,r)./(nmag.*rmag));
  j=find(r(:,3)<=0);
  if ~isempty(j),
    u0(j)=2*pi-u0(j);
  end

  l0=Omega+u0;

  E=acos((e+cos(nu0))./(1+e.*cos(nu0)));% mean anomaly
  j=find(sign(E)~=sign(nu0));
  if ~isempty(j),
    E(j)=-E(j);
  end

% find time of flight to periapsis
  t_T=sqrt(a.^3/mu).*(E-e.*sin(E));
  T=t-t_T;
  if nargout==7, return, end

% determine P, Q and W
  P=unitv(evec);
  W=unitv(h);
  Q=unitv(uxv(W,P));
