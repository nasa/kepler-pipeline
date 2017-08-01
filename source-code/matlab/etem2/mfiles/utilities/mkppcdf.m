function ppcdf = mkppcdf(xx,yy)
% function ppcdf = mkppcdf(xx,yy)
%
% models cdf as piece-wise constant
% xx and yy are as returned from [yy,xx]=hist(w) where w is a set of
% numbers.
% xx is the x-axis (vector) values of the data.
% yy is the y vector associated with xx and represents the density at xx
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

% Make xx and yy columns (if they are not)
xx     = xx(:);
yy     = yy(:);

% Use only values of yy that are positive (the normal case)
imax   = max(find(yy>0));
imin   = min(find(yy>0));  % SOMETHING is odd here...should find([],'first' or 'last') be used? jjg 3/10/05

% Doing this assumes some sort of nice conditioning to the data.
% It limits the results to the range of first to last non-zero values.
yy     = yy(imin:imax);
xx     = xx(imin:imax);

% Identify the locations of the breaks in the polynomial as half way
% between consectutive xx points.  1st and last point are handled separately.
breaks = [xx(1)-diff(xx(1:2))/2;...         % A point just before the 1st point
		 (xx(1:end-1)+xx(2:end))/2;...      % All half-way points between xx's
	      xx(end)+diff(xx(end-1:end))/2];   % A point just after the last point

% find the pdf and cdf of the data
pdf    = yy / sum(yy);  % normalize, in case it didn't come into the routine that way.
cdf    = cumsum(pdf);   % compute cdf from the pdf 

% Find the coefs: [linear term, constant term]
% pdf ./ diff(breaks) is a "rise-over-run" slope estimate
% [0 cdf(1:end-1)] is .....
coefs  = [pdf./diff(breaks), [0;cdf(1:end-1)]];

% Make the piecewise polynomial out of breaks & coefs
ppcdf  = mkpp(breaks, coefs);

return