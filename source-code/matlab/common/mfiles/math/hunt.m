function [x] = hunt(y_is_fx, ynew)
% function [x] = hunt(y_is_fx, ynew)
%
% Finds the values of x given a function y = f(x) and a range of y values.
%
% Finding the values of the inverse function x = g(y) for certain values of
% y given y = f(x).
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

% hunt.m is often called by yvals = ppcdfinv(ppcdf,y) which attempts to invert a
% piecewise-polynomial cdf function with 2nd order sections.'hunt' finds
% the closest index <= y (converted from fortran code)




% Make space for the results
x = zeros(length(ynew),1);

% make sure that given values of ynew are within the y range
% do not extrapolate
idxlo = find(ynew < min(y_is_fx)); % collect indices lower than ymin
idxhi = find(ynew > max(y_is_fx)); % collect indices higher than ymin

% make sure that given values of ynew are within the y range
% do not extrapolate
idxok = 1:length(ynew);
idxok = setxor(idxok, idxlo); % eliminate indices lower than ymin
idxok = setxor(idxok, idxhi); % eliminate indices higher than ymax

% through 1-d interpolation, find the values of x for given ynew within
% range
x(idxok) = floor(interp1(y_is_fx, (1:length(y_is_fx))', ynew(idxok), 'linear'));
x(idxlo) = 1;              % set x values for indices in ynew lower than ymin to xmin (=1) 
x(idxhi) = length(y_is_fx);% set x values for indices in ynew higher than ymax to xmax (= length of y) 

return