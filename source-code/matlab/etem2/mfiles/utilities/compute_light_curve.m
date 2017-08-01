function [mulimb0, mulimbf, muNoDarkening] = compute_light_curve(rl, c1, c2, c3, c4, b0)
% function [limbMag, lightCurve] = compute_light_curve(rl, c1, c2, c3, c4, b0)
%
% straight variable-copy port of occultnl.pro IDL script implementing
% analytic light curve generation using the nonlinear limb darkening model
% implement Mandel & Abol (2002) http://arxiv.org/pdf/astro-ph/0210099
%
% we leave out the plotting variables
%
% the original header:
% ; Please cite Mandel & Agol (2002) if making use of this routine.
% timing=systime(1)
% ; This routine uses the results for a uniform source to
% ; compute the lightcurve for a limb-darkened source
% ; (5-1-02 notes)
% ;Input:
% ;  rl        radius of the lens   in units of the source radius
% ;  c1-c4     limb-darkening coefficients
% ;  b0        impact parameter normalized to source radius
% ;  plotquery =1 to plot magnification,  =0 for no plots
% ;  _extra=e  plot parameters
% ;Output:
% ; mulimb0 limb-darkened magnification
% ; mulimbf lightcurves for each component
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


mulimb0 = occult_uniform(b0, rl);
muNoDarkening = mulimb0;
bt0 = b0;
fac = max(abs(mulimb0-1));
omega=4*((1-c1-c2-c3-c4)/4+c1/5+c2/6+c3/7+c4/8);
nb = length(b0);
indx = find(mulimb0 ~= 1);
mulimb = mulimb0(indx);
mulimbf=zeros(nb,5);
mulimbf(:,1)=mulimbf(:,1)+1;
mulimbf(:,2)=mulimbf(:,2)+0.8;
mulimbf(:,2)=mulimbf(:,3)+2/3;
mulimbf(:,3)=mulimbf(:,4)+4/7;
mulimbf(:,4)=mulimbf(:,5)+0.5;

nr = 2;
dmumax = 1;
while (dmumax > fac*1e-3)
    mulimbp=mulimb;
    nr=nr*2;
    dt=0.5*pi/nr;
    t=dt*(0:nr+1);
    th=t+0.5*dt;
    r=sin(t);
    sig=sqrt(cos(th(nr)));
    mulimbhalf =sig^3.*mulimb0(indx)./(1-r(nr));
    mulimb1    =sig^4.*mulimb0(indx)./(1-r(nr));
    mulimb3half=sig^5.*mulimb0(indx)./(1-r(nr));
    mulimb2    =sig^6.*mulimb0(indx)./(1-r(nr));
    for i=2:nr
        % Calculate uniform magnification at intermediate radii:
        mu = occult_uniform(b0(indx)./r(i),rl./r(i));
        % Equation (29):
        sig1=sqrt(cos(th(i-1)));
        sig2=sqrt(cos(th(i)));
        mulimbhalf =mulimbhalf +r(i)^2*mu.*(sig1^3./(r(i)-r(i-1))-sig2^3./(r(i+1)-r(i)));
        mulimb1    =mulimb1    +r(i)^2*mu.*(sig1^4./(r(i)-r(i-1))-sig2^4./(r(i+1)-r(i)));
        mulimb3half=mulimb3half+r(i)^2*mu.*(sig1^5./(r(i)-r(i-1))-sig2^5./(r(i+1)-r(i)));
        mulimb2    =mulimb2    +r(i)^2*mu.*(sig1^6./(r(i)-r(i-1))-sig2^6./(r(i+1)-r(i)));
    end
    mulimb=((1-c1-c2-c3-c4)*mulimb0(indx)+c1*mulimbhalf*dt+c2*mulimb1*dt+ ...
           c3*mulimb3half*dt+c4*mulimb2*dt)/omega;
    ix1=find(mulimb+mulimbp ~= 0);
    dmumax=max(abs(mulimb(ix1)-mulimbp(ix1))./(mulimb(ix1)+mulimbp(ix1)));
end

mulimbf(indx,1)=mulimb0(indx);
mulimbf(indx,2)=mulimbhalf*dt;
mulimbf(indx,3)=mulimb1*dt;
mulimbf(indx,4)=mulimb3half*dt;
mulimbf(indx,5)=mulimb2*dt;
mulimb0(indx)=mulimb + (1 - max(mulimb)); % added last term to nomalize outside of transit at 1

  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function muo1 = occult_uniform(b0, w)
% ; This routine computes the lightcurve for occultation
% ; of a uniform source without microlensing  (Mandel & Agol 2002).
% ;Input:
% ;
% ; rs   radius of the source (set to unity)
% ; b0   impact parameter in units of rs
% ; w    occulting star size in units of rs
% ;
% ;Output:
% ; muo1 fraction of flux at each b0 for a uniform source

nb=length(b0);
muo1=zeros(nb, 1);
for i=1:nb 
    % substitute z=b0(i) to shorten expressions
    z=b0(i);
    % the source is unocculted:
    % Table 3, I.
    if (z >= 1+w) 
        muo1(i)=1;
    end 
    % the  source is completely occulted:
    % Table 3, II.
    if(w >= 1) && (z <= w-1)
        muo1(i)=0;
    end
    % the source is partly occulted and the occulting object crosses the limb:
    % Equation (26):
    if(z >= abs(1-w)) && (z <= 1+w)
        kap1=acos(min((1-w^2+z^2)/2/z, 1));
        kap0=acos(min((w^2+z^2-1.d0)/2/w/z, 1));
        lambdae=w^2*kap0+kap1;
        lambdae=(lambdae-0.5*sqrt(max(4*z^2-(1+z^2-w^2)^2, 0)))/pi;
        muo1(i)=1-lambdae;
    end
    % the occulting object transits the source star (but doesn't
    % completely cover it):
    if(z <= 1-w)  
        muo1(i)=1-w^2;
    end
end


