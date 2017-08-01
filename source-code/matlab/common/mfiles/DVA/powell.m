function [p,fret,xi,iter]=powell(fun,p,xi,ftol)
% [p,fret,xi,iter]=powell(fun,p,xi,ftol)
% Conjugate gradient search algorithm to minimize multidimensional function
% fun, given initial point p and directions xi (usually n unit vectors).
% See Numerical Recipes.
% ftol is the fractional function tolerance
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

n=length(p); % dimension of parameter space

ITMAX=200*n;

fret=fun(p); % get initial value at starting point

pt=p; % save initial point

iter = 0;

while 1
    iter = iter+1;
    
    fp = fret;
    
    ibig = 0;
    del = 0;
    
    for i = 1:n
        
        xit = xi(:,i); % direction to minimize in 
        
        fptt = fret; % best value so far
        
        fun2=@(lambda)(fun(p+lambda*xit)); % set up anonymous function for 1-D mins
        
        [ax,bx,cx,fa,fb,fc]=mnbrak(fun2,0,1); % bracket minimum
        
        [lambda,fret]=fminbnd(fun2,min(ax,cx),max(ax,cx),optimset('tolfun',ftol)); % line minimization
        
        xit=xit*lambda; % adjust length of step to line minimumum
        
        p=p+xit; % move point to current location of minimum
                
        if abs( fptt - fret ) > del,
            del = abs( fptt - fret );
            ibig = i;
        end
        
    end
    
    if 2*abs(fp-fret)<=ftol*(abs(fp)+abs(fret))||norm(p-pt)<ftol, 
        return, 
    end % termination criterion met
    
    if iter>ITMAX, 
        warning('powell: too many iterations')
        return
    end
    
    % construct the extrapolated point and the average direction moved.
    % Save old point.
    ptt=2*p-pt;
    xit=p-pt;
    pt=p;
    
    fptt=fun(ptt);
    
    if fptt< fp, % keep going
        
        t=2*(fp-2*fret+fptt)*(fp-fret-del)^2-del*(fp-fptt)^2;
        if t<0 % keep going
            %call linmin(p,xit,n,fret)
        
            fun2=@(lambda)(fun(p+lambda*xit)); % set up anonymous function for 1-D mins
        
            [ax,bx,cx,fa,fb,fc]=mnbrak(fun2,0,1); % bracket minimum
        
            [lambda,fret]=fminbnd(fun2,min(ax,cx),max(ax,cx),optimset('tolfun',ftol)); % line minimization
        
            xit=xit*lambda; % adjust length of step to line minimumum
        
            p=p+xit; % move point to current location of minimum

            xi(:,ibig)=xi(:,n);
            xi(:,n)=xit;
        end
        
    end
    
end

return

function [ax,bx,cx,fa,fb,fc]=mnbrak(func,ax,bx)
    
GOLD=1.618034;
TINY=1e-20;
GLIMIT=100;

fa=func(ax);
fb=func(bx);

if fb>fa
    dum=ax;
    ax=bx;
    bx=dum;
    dum=fb;
    fb=fa;
    fa=dum;
end

cx=bx+GOLD*(bx-ax);

fc=func(cx);

while fb >= fc
    r = (bx-ax) * (fb-fc);
    q=(bx-cx)*(fb-fc);
    u=bx-((bx-cx)*q-(bx-ax)*r)/2*(max(abs(q-r),TINY)*sign(q-r));
    ulim=bx+GLIMIT*(cx-bx);
    if (bx-u)*(u-cx)>0
        fu=func(u);
        if fu<fc,
            ax=bx;
            fa=fb;
            bx=u;
            fb=fu;
            return
        elseif fu>fb,
            cx=u;
            fc=fu;
            return
        end
        u=cx+GOLD*(cx-bx);
        fu=func(u);
    elseif (cx-u)*(u-ulim)>0,
        fu=func(u);
        if fu<fc,
            bx=cx;
            cx=u;
            u=cx+GOLD*(cx-bx);
            fb=fc;
            fc=fu;
            fu=func(u);
        end
    elseif (u-ulim)*(ulim-cx)>0,
        u=ulim;
        fu=func(u);
    else
        u=cx+GOLD*(cx-bx);
        fu=func(u);
    end
    ax=bx;
    bx=cx;
    cx=u;
    fa=fb;
    fb=fc;
    fc=fu;
end

return
