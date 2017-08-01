function result = is_inside_polygon( x, y, X, Y, varargin )
% function result = is_inside_polygon( x, y, X, Y, varargin )
% 
% Determine if the cartesian pairs (x,y) are inside or outside the closed polygon
% defined by the set of ordered pairs [X,Y].
% INPUT
%       X, Y        Vertices of a closed polygon.
%                   A closed polygon has [X(1), Y(1)] = [X(n), Y(n)]
%                   [n x 1; float, int]
%       x, y        Coordinates of test points.
%                   [m x 1; float, int]
%       varargin    TOLERANCE == agreement needed on sum of angles to determine
%                   insideness or outsideness. Default = 1e-8
% OUTPUT
%       result      boolean. false = outside polygon, true = inside polygon
%                   [m x 1; logical]
%
% Get the angle between the test point and each vertex of the polygon by 
% expressing the difference between the test point coordinates and the 
% polygon vertices as a complex matrix. Then compute the angle between
% the test point/first vertex line segment  and the test point/vertex line
% segment for all vertices. The diff of this list will give the incremental
% angle as one moves from vetex to vertex around the polygon. If (x,y) is 
% inside the polygon, the sum of the incremental angles equals 2 pi. If 
% it is outside, the sum equals zero. If the polygon is not closed the sum
% equals some other value and will produce an error.
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

% get variable inputs
if(nargin == 4)
    TOLERANCE = 1e-8;
else
    TOLERANCE = varargin{1};
end

% check inputs
if( ~isvector(X) || ~isvector(Y) ||  length(X) ~= length(Y) )
    error('[X, Y] does not define a polygon.');
end

if( size(X) ~= size(Y) )
    error('X and Y must be the same shape.');
end

if( ~isvector(x) || ~isvector(y) || length(x) ~= length(y) )
    error('[x, y] does not define a list of test points.');
end

if( size(x) ~= size(y) )
    error('x and y must be the same shape.');
end


% return result same shape as x
result = false(size(x));

% step through points
for iPoint = 1:length(x)
    
    % get the absolute angles
    M = angle(X(:) - x(iPoint) + (Y(:) - y(iPoint)).*1i);
    
    % then relative angles - 0 to 2*pi
    relativeAngle = unwrap(M-M(1));
    
    % compute incremental sum
    totalAngle = sum(diff(relativeAngle));
    
    if( abs(totalAngle - 2*pi) < TOLERANCE )
        result(iPoint) = true;
    elseif( abs(totalAngle) > TOLERANCE )
        error('Polygon must be closed.');
    end
    
end

