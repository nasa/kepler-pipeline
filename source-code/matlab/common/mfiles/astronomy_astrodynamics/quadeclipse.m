function L=quadeclipse(R1,R2,D,cl,tol)
% L=quadeclipse(R1,R2,D,cl,tol)
% calls quad to evaluate the integral over the portion of disk 1 (radius R1)
% that is obscurred by disk 2 (radius R2), when they are separated by distance
% D, and the limb-darkening coefficient is cl.
% see eclipse.m
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

R2=R2/R1;
D=D/R1;
R1=1;
L=zeros(size(D));
if nargin<5, tol=1e-4; end
 
for i=1:length(D),
    rmin=max([0,D(i)-R2]);
    if rmin==0, rmin=rmin+1e-10; end
    rmax=min([R1,D(i)+R2]);
    if rmin<R1
        L(i)=quadinctrap('eclipse',rmin,rmax,tol,cl,R1,R2,D(i));
    end
    %disp(['L(',int2str(i),')=',num2str(L(i))])
end

L0=pi*(1-cl/3);
L=L/L0;
il0=find(L<=0);
if ~isempty(il0), L(il0)=0*il0; end
return

function intgl=quadinctrap(fcn,x1,xend,tol,varargin)

M=100;
M_1=M-1;

x=(0:1/M_1:1)'*(xend-x1)+x1;

dx=x(2)-x(1);

dydx=feval(fcn,x,varargin{:});
sumdydx=sum(dydx)-dydx(1)/2-dydx(end)/2;

intgl=sumdydx*dx;
newval=intgl;

cnt=1;

while cnt<100&(cnt==1|abs(newval-intgl)/max(abs(intgl),1e-6)>tol)
    cnt=cnt+1;
    intgl=newval;
    dx=dx/2;
    xnew=(x(1:end-1)+x(2:end))/2;
    dydxnew=feval(fcn,xnew,varargin{:});
    sumdydx=sumdydx+sum(dydxnew);
    newval=sumdydx*dx;
    x=[x(:)';xnew(:)',0];
    x=x(:);
    x=x(1:end-1);
end

return
