function prfObject = prfDiscreteClass(prfData, discretePrfSpecification, ...
    prfParentObject)
% function prfObject = prfDiscreteClass(prfData, discretePrfSpecification, ...
%     prfParentObject)
%
% instantiator for the PRF discrete class
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

if nargin < 3
    parentStruct.name = 'prfClass';
    prfParentObject = class(parentStruct, 'prfClass');
end

if isempty(discretePrfSpecification)
    discretePrfSpecification.type = 'PRF_DISCRETE';
    discretePrfSpecification.oversample = 50;
    disp('no discrete PRF specification, using default values');
elseif isfield(discretePrfSpecification, 'oversample')
    discretePrfSpecification.type = 'PRF_DISCRETE';
end
        
switch class(prfData)
    case 'char' % assume this is the filename of a pre-computed PRF array
        prfData = build_from_file(prfData, discretePrfSpecification);
        
    case {'struct'} 
            % struct: assume this is the required PRF polynomial structure
        prfData = build_from_standard_prf(prfData, discretePrfSpecification);
        
    case {'double'} 
        if ndims(prfData) == 2
            % assume this is a 2D discrete PRF array
            prfData = build_from_array(prfData);
        elseif ndims(prfData) == 4
            % assume this is a 4D polynomial coefficient matrix
            prfData = build_from_standard_prf(prfData, discretePrfSpecification);
        end
    otherwise
        error('prfClass: bad prfData');
end

prfData = set_up_coordinates(prfData);

prfObject = class(prfData, 'prfDiscreteClass', prfParentObject);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%
% build the discrete PRF from the file pointed at by filename
%
%% function prfData = build_from_file(filename, discretePrfSpecification)
function prfData = build_from_file(filename, discretePrfSpecification)

fid = fopen(filename, 'r');
prfArray = fread(fid, 'float32'); % load as float array
fclose(fid);

% infer the size of the discrete PRF array, assuming it is square
prfArraySize = sqrt(length(prfArray));
if prfArraySize ~= fix(prfArraySize)
    error('prfDiscreteClass: input array not square');
end
% reshape into a square array 
prfArray = reshape(prfArray, prfArraySize, prfArraySize);

% infer the number of array elements per Kepler pixel.  This array
% corresponds to either 11 or 15 Kepler pixels on a side
% assume that the oversampling factor 
if prfArraySize/11 == fix(prfArraySize/11)
    oversample = prfArraySize/11;
    nPrfArrayRows = 11;
elseif prfArraySize/15 == fix(prfArraySize/15)
    oversample = prfArraySize/15;
    nPrfArrayRows = 15;
else
    error('prfDiscreteClass: input array size not consistent with Kepler pixels');
end

prfData.type = discretePrfSpecification.type;
prfData.prfArray = prfArray;
prfData.oversample = oversample;
prfData.nPrfArrayRows = nPrfArrayRows;
prfData.nPrfArrayCols = nPrfArrayRows;
prfData.nPrfArray = nPrfArrayRows*nPrfArrayRows;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%
% build the discrete PRF from the file pointed at by filename
%
%% function prfData = build_from_Array(prfArray, discretePrfSpecification)
function prfData = build_from_array(prfArray)

if iscolumn(prfArray) || isrow(prfArray)
    % infer the size of the discrete PRF array, assuming it is square
    prfArraySize = sqrt(length(prfArray));
    if prfArraySize ~= fix(prfArraySize)
        error('prfDiscreteClass: input array not square');
    end
    % reshape into a square array 
    prfArray = reshape(prfArray, prfArraySize, prfArraySize);
else
    if size(prfArray, 1) ~= size(prfArray, 2)
        error('prfDiscreteClass: input array not square');
    end
    prfArraySize = size(prfArray, 1);
end

% infer the number of array elements per Kepler pixel.  This array
% corresponds to either 11 or 15 Kepler pixels on a side
% assume that the oversampling factor 
if prfArraySize/11 == fix(prfArraySize/11)
    oversample = prfArraySize/11;
    nPrfArrayRows = 11;
elseif prfArraySize/15 == fix(prfArraySize/15)
    oversample = prfArraySize/15;
    nPrfArrayRows = 15;
else
    error('prfDiscreteClass: input array size not consistent with Kepler pixels');
end

prfData.type = 'PRF_DISCRETE';
prfData.prfArray = prfArray;
prfData.oversample = oversample;
prfData.nPrfArrayRows = nPrfArrayRows;
prfData.nPrfArrayCols = nPrfArrayRows;
prfData.nPrfArray = nPrfArrayRows*nPrfArrayRows;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%
% build the discrete PRF from a prfClass input
%
%% function prfData = build_from_standard_prf(prfData, discretePrfSpecification)
function prfData = build_from_standard_prf(prfPolyData, discretePrfSpecification)
oversample = discretePrfSpecification.oversample;
% make a single prfClass object
prfObject = prfClass(prfPolyData);
% get the number of Kepler pixels on a side
nPrfArrayRows = get(prfObject, 'nPrfArrayRows');
% make the oversampled array
prfArray = make_array(prfObject, oversample*nPrfArrayRows);

prfData.type = discretePrfSpecification.type;
prfData.prfArray = prfArray;
prfData.oversample = oversample;
prfData.nPrfArrayRows = nPrfArrayRows;
prfData.nPrfArrayCols = get(prfObject, 'nPrfArrayRows');
prfData.nPrfArray = nPrfArrayRows*prfData.nPrfArrayCols;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%
% set up the pixel array coordinate system in Kepler pixel coordinates
% 
% Kepler pixel coordinates have the following properties:
% - pixel coordinate (0,0) is in the center of the central Kepler pixel
%
%% function prfData = set_up_coordinates(prfData)
function prfData = set_up_coordinates(prfData)

% x and y coordinates are the same, so compute the linear coordinate once,
% use for both x and y

% get the coordinate of each array element
arrayCoord = 1:size(prfData.prfArray, 1);
% transform to Kepler pixels, with (0,0) at the center
pixelCoord = arrayCoord/prfData.oversample;
pixelCoord = pixelCoord - max(pixelCoord)/2;

[prfData.arrayCol, prfData.arrayRow] = meshgrid(pixelCoord, pixelCoord);


