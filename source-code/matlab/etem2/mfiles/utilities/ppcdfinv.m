function x = ppcdfinv(ppcdf,y)
% x = ppcdfinv(ppcdf,y)
% attempts to invert a piecewise-polynomial cdf function with
% 1st order sections. Converts input uniform random deviates to samples
% from a probability distribution defined by ppcdf
% Inputs:
%   ppcdf - piecewise polynomial representation of a cumulative probability
%           distribution function (see mkpp() help for format)
%   y - vector of uniform random deviate values for which to compute probabilities
% Outputs:
%   x - vector of values drawn from probability distribution defined by ppcdf
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

ysize = size(y);

% Make y a column vector in case it was a row.
y = y(:);

% get the piecewise polynomial details
[breaks,coefs] = unmkpp(ppcdf);

% make 'breaks' a column
breaks = breaks(:);


% find the y values corresponding to the x-break points
ybreaks = ppval(ppcdf,breaks);


% find the unique y values (cdf becomes flat as it approaches 1)
[ybreaksu,iu] = unique(ybreaks);

% find the closest index <= y using "hunt" 
% hunt is a matlab script (converted from fortran code)
ilo = hunt(ybreaksu(1:end-1),y);

% get only the unique y axis bins
ilo = iu(ilo);

% 2nd order sections --> y = mx+c; x  = (y-c)/m  + xoffset
x = (y-coefs(ilo,2))./coefs(ilo,1) + breaks(ilo);

% Make x the same size as the original y
x = reshape(x,ysize);



return


