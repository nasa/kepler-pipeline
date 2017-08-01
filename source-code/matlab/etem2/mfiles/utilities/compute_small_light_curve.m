function mu = compute_small_light_curve(p, c1, c2, c3, c4, z);
% ; This routine approximates the lightcurve for a small 
% ; planet. (See section 5 of Mandel & Agol (2002) for
% ; details).  Please cite Mandel & Agol (2002) if making
% ; use of this routine.
% ; Input:
% ;  p      ratio of planet radius to stellar radius
% ;  c1-c4  non-linear limb-darkening coefficients
% ;  z      impact parameters (normalized to stellar radius)
% ;        - this is an array which must be input to the routine
% ; Output:
% ;  mu     flux relative to unobscured source for each z
% ;
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

nb=length(z);
mu=zeros(nb,  1)+1;

indx=find((z >= 1-p) & (z <= 1+p));

norm=pi*(1-c1/5-c2/3-3*c3/7-c4/2);
x=1-(z(indx)-p).^2;

tmp=(1-c1*(1-4/5*x.^0.25)-c2*(1-2/3.*x.^0.5) ...
	-c3*(1-4/7*x.^0.75)-c4*(1-4/8*x));
mu(indx)=1-tmp.*(p.^2.*acos((z(indx)-1)/p) ...
    -(z(indx)-1).*sqrt(p.^2-(z(indx)-1).^2))/norm;

indx=find((z <= 1-p) & (z ~= 0));
mu(indx)=1-pi*p.^2*iofr(c1,c2,c3,c4,z(indx),p)/norm;
indx=find(z == 0);
if(sum(indx) >= 0) 
    mu(indx)=1-pi*p.^2/norm;
end

function result = iofr(c1,c2,c3,c4,r,p)
sig1=sqrt(sqrt(1-(r-p).^2));
sig2=sqrt(sqrt(1-(r+p).^2));
result = 1 -c1*(1.+(sig2.^5-sig1.^5)/5/p./r) ...
    -c2*(1+(sig2.^6-sig1.^6)/6/p./r) ...
    -c3*(1+(sig2.^7-sig1.^7)/7/p./r) ...
    -c4*(1+(sig2.^8-sig1.^8)/8/p./r);
%    -c4*(p.^2+r.^2);


