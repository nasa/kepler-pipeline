function prfObject = prfClass(prfData, prfSpecification)
% function prfObject = prfClass(prfData)
% 
% instantiator for the PRF class
% required fields: polyData can be either: 
%   - a polyStruct PRF polynomial structure
% or
%   - a 4-dimensional coefficient matrix with dimensions
%       max # of coefficients x # of pixels in PRF array x # of sub rows x
%       # of sub columns
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

% make an abstract parent class that just contains methods
parentStruct.name = 'prfClass';
prfParentObject = class(parentStruct, 'prfClass');

if nargin < 2 && ~strcmp(class(prfData), 'char')
    prfSpecification.type = 'PRF_POLY_WITHOUT_UNCERTAINTIES';
elseif nargin < 2 && strcmp(class(prfData), 'char')
    prfSpecification.type = 'PRF_DISCRETE';
elseif isfield(prfSpecification, 'oversample')
    prfSpecification.type = 'PRF_DISCRETE';
end

% make the appropriate type of PRF class
switch class(prfData)
    case 'char' 
        % this is a discrete PRF object
        % assume this is the filename of a pre-computed PRF array
        prfObject = prfDiscreteClass(prfData, prfSpecification, ...
            prfParentObject);
        
    case {'struct'} 
        % prfData specifies a polynomial PRF, but if there is a 
        % prfSpecification then this is a discrete PRF
        % struct: assume this is the required PRF polynomial structure
        if nargin > 1 && ~isempty(prfSpecification) ...
                && strcmp(prfSpecification.type, 'PRF_DISCRETE')
            prfObject = prfDiscreteClass(prfData, ...
                prfSpecification, prfParentObject);
        else
            prfObject = prfPolyClass(prfData, prfSpecification, prfParentObject);
        end
        
    case {'double'} 
        if ndims(prfData) == 2
            % assume this is a 2D discrete PRF array
            prfObject = prfDiscreteClass(prfData, prfSpecification, ...
                prfParentObject);
        elseif ndims(prfData) == 4
            % prfData specifies a polynomial PRF, but if there is a 
            % prfSpecification then this is a discrete PRF
            % assume this is a 4D coefficient matrix
            if nargin > 1 && ~isempty(prfSpecification) ...
                && strcmp(prfSpecification.type, 'PRF_DISCRETE')
                prfObject = prfDiscreteClass(prfData, ...
                    prfSpecification, prfParentObject);
            else
                prfObject = prfPolyClass(prfData, prfSpecification, prfParentObject);
            end
        end
        
    otherwise
        prfObject = [];
        error('prfClass: bad prfData');
end

