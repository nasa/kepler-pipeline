function check_poly2d_struct(inStruct, mnemonic)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function check_poly2d_struct(inStruct, mnemonic)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% This function checks to make sure the input structure is a valid
% polynomial structure as returned by the weighted_polyfit_2d family of
% functions.
%
%   See also WEIGHTED_POLYFIT2D
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

nfields = 1;
fieldsAndBoundsStruct(nfields).fieldName = 'offsetx';
fieldsAndBoundsStruct(nfields).binaryCompare = ...
    {' >= -1e12 ', ' <= 1e12 '};
nfields = nfields + 1;
fieldsAndBoundsStruct(nfields).fieldName = 'scalex';
fieldsAndBoundsStruct(nfields).binaryCompare = ...
    {' >= -1e12 ', ' <= 1e12 '};
nfields = nfields + 1;
fieldsAndBoundsStruct(nfields).fieldName = 'originx';
fieldsAndBoundsStruct(nfields).binaryCompare = ...
    {' >= -1e12 ', ' <= 1e12 '};
nfields = nfields + 1;
fieldsAndBoundsStruct(nfields).fieldName = 'offsety';
fieldsAndBoundsStruct(nfields).binaryCompare = ...
    {' >= -1e12 ', ' <= 1e12 '};
nfields = nfields + 1;
fieldsAndBoundsStruct(nfields).fieldName = 'scaley';
fieldsAndBoundsStruct(nfields).binaryCompare = ...
    {' >= -1e12 ', ' <= 1e12 '};
nfields = nfields + 1;
fieldsAndBoundsStruct(nfields).fieldName = 'originy';
fieldsAndBoundsStruct(nfields).binaryCompare = ...
    {' >= -1e12 ', ' <= 1e12 '};
nfields = nfields + 1;
fieldsAndBoundsStruct(nfields).fieldName = 'order';
fieldsAndBoundsStruct(nfields).binaryCompare = ...
    {' >= 0 ', ' <= 1e4 '};
nfields = nfields + 1;
fieldsAndBoundsStruct(nfields).fieldName = 'xindex';
fieldsAndBoundsStruct(nfields).binaryCompare = ...
    {' >= -1 ', ' <= 4 '};
nfields = nfields + 1;
fieldsAndBoundsStruct(nfields).fieldName = 'yindex';
fieldsAndBoundsStruct(nfields).binaryCompare = ...
    {' >= -1 ', ' <= 4 '};
check_struct(inStruct, ...
    fieldsAndBoundsStruct, mnemonic);

% special case the .coeffs array
if(~isfield(inStruct, 'coeffs'))
     error([mnemonic ':missingField:coeffs'],...
         'coeffs: field not present in the input structure.')
end
% look for Nan or Inf
if any(any(~isfinite([inStruct.coeffs])))
    error([mnemonic ':rangeCheck:coeffs'],...
        'coeffs: contains a Nan or Inf.')
end
% check range
if ~all(all([inStruct.coeffs] > -1e12 ))
    error([mnemonic ':rangeCheck:coeffs'],...
        'coeffs: not all > -1e3.')
end
if ~all(all([inStruct.coeffs] < 1e12 ))
    error([mnemonic ':rangeCheck:coeffs'],...
        'coeffs: not all <= 1e9.')
end

% special case the .covariance array
if(~isfield(inStruct, 'covariance'))
    error([mnemonic ':missingField:covariance'],...
        'covariance: field not present in the input structure.')
end
% look for Nan or Inf
if any(any(~isfinite([inStruct.covariance])))
    error([mnemonic ':rangeCheck:covariance'],...
        'covariance: contains a Nan or Inf.')
end
% check range
if ~all(all([inStruct.covariance] > -1e12 ))
    error([mnemonic ':rangeCheck:covariance'],...
        'covariance: not all > -1e3.')
end
if ~all(all([inStruct.covariance] < 1e12 ))
    error([mnemonic ':rangeCheck:covariance'],...
        'covariance: not all <= 1e9.')
end

% special case the text fields
if(~isfield(inStruct, 'type'))
    error([mnemonic ':missingField:type'],...
        'type: field not present in the input structure.')
end
if ~(isequal(inStruct.type, 'standard') || isequal(inStruct.type, 'not_scaled') ...
        || isequal(inStruct.type, 'legendre'))
    error([mnemonic ':invalidField:type'], 'type: field not valid.')
end
if(~isfield(inStruct, 'message'))
    error([mnemonic ':missingField:message'],...
        'message: field not present in the input structure.')
end


