function c = make_weighted_poly(dimension, order, size, type)
% function poly = make_weighted_poly(dimension, order, size, [type])
% 
% return an array of empty polynomial structures, which will evaluate to
% zero.  Used for input verification tests
%
% The return struct c is passed to the routine weighted_polyval2D for 
% evaluation of the polynomial
% 
% inputs:
%   dimension: dimension of the polynomial domain (1D or 2D)
%   order: order of the empty polynomial to be created
%   size: size of the polynomial array to return
%   type: optional, string, can be 'standard', not_scaled', 'legendre'
% 
% returns:
%   c: a struct that comtains the following fields
%       .coeff: coefficient vector for the polynomial basis
%       .covariance: matrix giving the uncertainties in the coefficients
%       .order: order of the polynomial for these coefficients
%       .type: type of the polynomial for these coefficients
%       .offsetx, .scalex, .originx, .offsety, .scaley, .originy: data
%           that allows the scaling of the domain for improved numerical 
%           performance.  The values of these fields depends on the type
%           of polynomial
%       .xindex, .yindex: index of column of x and y values in design
%       matrix.  Only valid for polys of type "not_scaled".
%       .message space for a message in case of an anomalous condition
% 
% 
%   See also WEIGHTED_POLYFIT2D, WEIGHTED_POLYFIT
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

% first create a prototype polynomial structure with the desired dimension
% and order

if (nargin == 3)
    type = 'standard' ;
end

switch type
    case {'standard','legendre'}
        xindex = -1 ;
        yindex = -1 ;
    case 'not_scaled'
        xindex = 2 ;
        yindex = 3 ;
    otherwise
        error('make_weighted_poly: bad type') ;
end

if dimension == 1
    nterms = order+1;
    
    cPrototype.offsetx = 0;
    cPrototype.scalex = 1;        
    cPrototype.originx = 0;
    cPrototype.xindex = xindex;
elseif dimension == 2
    op1 = order+1;
    nterms = op1*(op1+1)/2; 
    
    cPrototype.offsetx = 0;
    cPrototype.scalex = 1;
    cPrototype.originx = 0;
    cPrototype.offsety = 0;
    cPrototype.scaley = 1;
    cPrototype.originy = 0;
    cPrototype.xindex = xindex;
    cPrototype.yindex = yindex;
else
    error('make_weighted_poly:bad dimension');
end

cPrototype.type = type;
cPrototype.order = order;
cPrototype.message = [];

cPrototype.coeffs = zeros(nterms, 1);
cPrototype.covariance = eye(nterms, nterms);


% now create a size x 1 array of copies of the prototype polynomial for the
% return object
c = repmat(cPrototype, size, 1);

