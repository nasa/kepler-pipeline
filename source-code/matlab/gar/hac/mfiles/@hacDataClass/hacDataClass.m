function hacDataObject = hacDataClass(hacDataStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Constructor hacDataObject = hacDataClass(hacDataStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% hacDataClass.m - Class Constructor
%
% Based on the constructors developed for pdqScience by H. Chandrasekaran 
% and for rpts by E. Quintana.
%
% This method first checks for the presence of expected fields in the input
% structure and then checks whether each parameter is within the appropriate
% range. Once the validation of the inputs is complete, this method then
% implements the constructor for the hacDataClass. THERE IS NO VALIDATION
% OF THE FIELDS OF THE FcCONSTANTS STRUCTURE.
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% INPUT:  A data structure 'hacDataStruct' with the following fields:
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%   Top level:
%
%     hacDataStruct contains the following fields:
%
%                 fcConstants: [struct]  Fc constants
%            invocationCcdModule: [int]  CCD module for this invocation
%            invocationCcdOutput: [int]  CCD output for this invocation
%                   cadenceStart: [int]  first cadence for histograms
%                     cadenceEnd: [int]  last cadence for histograms
%      firstMatlabInvocation: [logical]  flag to indicate initial run
%            histograms: [struct array]  histograms for each baseline interval
%                      debugFlag: [int]  indicates debug level
%
%--------------------------------------------------------------------------
%   Second level
%
%     hacDataStruct.histograms is a struct array with the following 
%     fields:
%
%                    baselineInterval: [int]  interval (cadences)
%  uncompressedBaselineOverheadRate: [float]  overhead for baseline storage (bpp)
%        theoreticalCompressionRate: [float]  entropy computed from histogram (bpp)
%                  totalStorageRate: [float]  total storage requirement (bpp)
%                     histogram: [int array]  histogram for Huffman encoding
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% OUTPUT:  An object 'hacDataObject' of class 'hacDataClass' containing the
%          above fields.
%
% Comments: This function generates an error under the following scenarios:
%
%          (1) when invoked with no inputs
%          (2) when any of the fields are missing
%          (3) when any of the fields are NaNs/Infs or outside the
%              appropriate bounds
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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

% If no input, generate an error.
if nargin == 0
    error('GAR:hacDataClass:EmptyInputStruct', ...
        'The constructor must be called with an input structure.');
end

% Set debug flag to zero if it was not specified.
if ~isfield(hacDataStruct, 'debugFlag')
        hacDataStruct.debugFlag = 0;
end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Validate inputs and check fields and bounds.
%
% (1) check for the presence of all fields
% (2) check whether the parameters are within bounds and are not NaNs/Infs
%
% Note: if fields are structures, make sure that their bounds are empty.


%--------------------------------------------------------------------------
% Top level validation.
% Validate all fields in hacDataStruct.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(8,4);
fieldsAndBounds(1,:)  = { 'fcConstants'; []; []; []};
fieldsAndBounds(2,:)  = { 'invocationCcdModule'; '>= 2'; '<= 24'; []};
fieldsAndBounds(3,:)  = { 'invocationCcdOutput'; '>= 1'; '<= 4'; []};
fieldsAndBounds(4,:)  = { 'cadenceStart'; '> - 2^20'; '< 2^20'; []};  % for now
fieldsAndBounds(5,:)  = { 'cadenceEnd'; '> -2^20'; '< 2^20'; []};     % for now
fieldsAndBounds(6,:)  = { 'firstMatlabInvocation'; '>= 0'; '<= 1'; []};
fieldsAndBounds(7,:)  = { 'histograms'; []; []; []};
fieldsAndBounds(8,:)  = { 'debugFlag'; '>= 0'; '<= 3'; []};  % 3 levels max

validate_structure(hacDataStruct, fieldsAndBounds, 'hacDataStruct');

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Second level validation.
% Validate the structure field hacDataStruct.histograms.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(5,4);
fieldsAndBounds(1,:)  = { 'baselineInterval'; '>= 2'; '<= 336'; []}; % 1 week max
fieldsAndBounds(2,:)  = { 'uncompressedBaselineOverheadRate'; '>= 0'; []; []};
fieldsAndBounds(3,:)  = { 'theoreticalCompressionRate'; '>= 0'; []; []};
fieldsAndBounds(4,:)  = { 'totalStorageRate'; '>= 0'; []; []};
fieldsAndBounds(5,:)  = { 'histogram'; '>= 0'; '< 2^32'; []};

nStructures = length(hacDataStruct.histograms);

for j = 1 : nStructures
	validate_structure(hacDataStruct.histograms(j), fieldsAndBounds, 'hacDataStruct.histograms');
end

clear fieldsAndBounds;

% Order the fields to avoid getting error messages like:
%   Error using ==> class 
%   Field names and parent classes for class hgnDataClass cannot be
%   changed without clear classes
hacDataStruct = orderfields(hacDataStruct);

hacDataStruct.fcConstants = orderfields(hacDataStruct.fcConstants);
if ~isempty(hacDataStruct.histograms)
    hacDataStruct.histograms = orderfields(hacDataStruct.histograms);
end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Input validation successfully completed!
% Create the hacDataClass object.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
hacDataObject = class(hacDataStruct, 'hacDataClass');

% Return.
return
