function [a,b,absdev] = mindevfit(xi,yi)
% function [a,b,absdev] = mindevfit(xt,yt)
%
% Written by:  Doug Caldwell  25 May 1998
%
% Fits a line to the (x,y) data points by minimizing the
% absolute deviation (y_i) of the data points.  The routine
% is taken from Numerical Recipies (Press, et al. 1988) Chapter 14.6
% (Robust Estimation)
%
% Inputs are vectors/arrays X & Y containing the data point.  If X & Y
% are arrays, they are assumed to contain separate data sets in each
% column.   That is, X(:,1), Y(:,1) is the first set, X(:,2), Y(:,2) the second, etc.
% Outputs are the vectors "a" & "b" containing the fitted parameters
%     Y(i) = a + b*X(i),
% and the vector "absdev" giving the mean absolute deviation (in y)
% of the data from the fitted line.
%
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

global aa abdev xt yt ndata
xt = xi;
yt = yi;

ndata = size(xt);  %get number of data points
ndata = ndata(1);

	% generate least-squares solution as a starting guess
sx = sum(xt);
sy = sum(yt);
sxy = sum( xt.*yt);
sxx = sum( xt.^2);
delta = ndata.* sxx - sx.^2;
aa = (sxx.*sy - sx.*sxy)./delta;  % y-intercept
bb = (ndata.*sxy - sx.*sy)./delta; % slope
   % calculate chi2 to use as iteration step size
chi2 = sum( (yt-(repmat(aa,ndata,1)-repmat(bb,ndata,1).*xt)).^2 );
sigb = sqrt(chi2./delta);
b1 = bb;
f1 = rofunc(b1);
b2 = bb + sign(f1).*abs(3*sigb);  % use 3-sigma bracket
f2 = rofunc(b2);
% bracket the root 
cont = 1;	% flag to test for bracketed roots
while cont  
%	prod = sign(f1(1,:).*f2(1,:));  
	prod = sign(f1.*f2);  
	ii = find(prod > 0);
	if isempty(ii)  % all roots bracketed
		cont=0;
	else		% bracket roots
		bb(ii) = 2*b2(ii) - b1(ii);
		b1(ii) = b2(ii);
		f1(ii) = f2(ii);
		b2(ii) = bb(ii);
		f2 = rofunc(b2);
	end % if isempty
end % while
sigb = 0.01*sigb;	% convergence limit
cont = 1;
while cont  % iterate until error is small fraction of standard dev.
	err = abs(b2 - b1);
	ierr = find( err > sigb);
	if isempty(ierr)
		cont = 0;
	else
		bb(ierr) = 0.5*(b1(ierr) + b2(ierr));  % bisection
		if bb==b1| bb==b2, % found solution, give up
			absdev = abs(abdev./ndata);  % set up return variables
			a = aa;
			b = bb;
			clear global aa abdev xt yt ndata;  % clean up globals
			return
		end  
		f = rofunc(bb);
		prod = f.*f1;
		ip = find(prod >=0);
		in = find(prod <0);
		f1(ip) = f(ip);
		b1(ip) = bb(ip);
		f2(in) = f(in);
		b2(in) = bb(in);
	end  % if isempty
end  % while

absdev = sum(abs(abdev))./ndata;  % set up return variables
a=aa;
b=bb;
clear global aa abdev xt yt ndata  %clean up globals
return


function f = rofunc(b)
% fuction f = rofunc(b)
% Function to evaluate: Sum( x_i * sgn(y_i  - a - b*x_i))
global aa abdev yt xt ndata

aa = median(yt - repmat(b,ndata,1).*xt);
abdev = yt - (repmat(b,ndata,1).*xt +repmat(aa,ndata,1));
dev = sign(abdev);
f = sum(dev.*xt);
return

