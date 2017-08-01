function hgnDataObject = hgnDataClass(hgnDataStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Constructor hgnDataObject = hgnDataClass(hgnDataStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% hgnDataClass.m - Class Constructor
%
% Based on the constructors developed for pdqScience by H. Chandrasekaran 
% and for rpts by E. Quintana.
%
% This method first checks for the presence of expected fields in the input
% structure and then checks whether each parameter is within the appropriate
% range. Once the validation of the inputs is complete, this method then
% implements the constructor for the hgnDataClass. THERE IS NO VALIDATION
% OF THE FIELDS OF THE FcCONSTANTS STRUCTURE.
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% INPUT:  A data structure hgnDataStruct with the following fields:
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%   Top level:
%
%     hgnDataStruct contains the following fields:
%
%         hgnModuleParameters: [struct]  module parameters
%                 fcConstants: [struct]  Fc constants
%                      ccdModule: [int]  CCD module number
%                      ccdOutput: [int]  CCD output number
%         invocationCadenceStart: [int]  first cadence for this invocation
%           invocationCadenceEnd: [int]  last cadence for this invocation
%      firstMatlabInvocation: [logical]  flag to indicate initial run
%                requantTable: [struct]  requantization table
%         cadencePixels: [struct array]  requantized pixels for each cadence
%                      debugFlag: [int]  indicates debug level
%
%--------------------------------------------------------------------------
%   Second level
%
%     hgnDataStruct.hgnModuleParameters is a struct with the following
%     field:
%
%        baselineIntervals: [int array]  intervals for histogram generation
%
%--------------------------------------------------------------------------
%   Second level
%
%     hgnDataStruct.requantTable is a struct with the following fields:
%
%                     externalId: [int]  table ID
%                    startMjd: [double]  table start time, MJD
%           requantEntries: [int array]  requantization table entries
%         meanBlackEntries: [int array]  mean black table entries
%
%--------------------------------------------------------------------------
%   Second level
%
%     hgnDataStruct.cadencePixels is a struct array with the following 
%     fields:
%
%                        cadence: [int]  cadence of pixel values
%              pixelValues: [int array]  requantized pixel values
%        gapIndicators: [logical array]  missing pixel indicators
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% OUTPUT:  An object 'hgnDataObject' of class 'hgnDataClass' containing the
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
    error('GAR:hgnDataClass:EmptyInputStruct', ...
        'The constructor must be called with an input structure.');
end
    
% Set debug flag to zero if it was not specified.
if ~isfield(hgnDataStruct, 'debugFlag')
        hgnDataStruct.debugFlag = 0;
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
% Validate all fields in hgnDataStruct.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(10,4);
fieldsAndBounds(1,:)  = { 'hgnModuleParameters'; []; []; []};
fieldsAndBounds(2,:)  = { 'fcConstants'; []; []; []};
fieldsAndBounds(3,:)  = { 'ccdModule'; '>= 2'; '<= 24'; []};
fieldsAndBounds(4,:)  = { 'ccdOutput'; '>= 1'; '<= 4'; []};
fieldsAndBounds(5,:)  = { 'invocationCadenceStart'; '> -2^20'; '< 2^20'; []};  % for now
fieldsAndBounds(6,:)  = { 'invocationCadenceEnd'; '> -2^20'; '< 2^20'; []};    % for now
fieldsAndBounds(7,:)  = { 'firstMatlabInvocation'; '>= 0'; '<= 1'; []};
fieldsAndBounds(8,:)  = { 'requantTable'; []; []; []};
fieldsAndBounds(9,:)  = { 'cadencePixels'; []; []; []};
fieldsAndBounds(10,:)  = { 'debugFlag'; '>= 0'; '<= 3'; []};  % 3 levels max

validate_structure(hgnDataStruct, fieldsAndBounds, 'hgnDataStruct');

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Second level validation.
% Validate the structure field hgnDataStruct.hgnModuleParameters.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(1,4);
fieldsAndBounds(1,:)  = { 'baselineIntervals'; '>= 2'; '<= 336'; []};  % 1 week max

validate_structure(hgnDataStruct.hgnModuleParameters, fieldsAndBounds, ...
    'hgnDataStruct.hgnModuleParameters');

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Second level validation.
% Validate the structure field hgnDataStruct.requantTable.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(4,4);
fieldsAndBounds(1,:)  = { 'externalId'; '>= 0'; '<= 255'; []};  % 1 byte
fieldsAndBounds(2,:)  = { 'startMjd'; '> 54500'; '< 70000'; []}; %  2/4/2008 to 7/13/2050
fieldsAndBounds(3,:)  = { 'requantEntries'; '>= 0'; '< 2^23'; []}; %  23 bits max
fieldsAndBounds(4,:)  = { 'meanBlackEntries'; '>= 0'; '< 2^23'; []}; %  23 bits max

validate_structure(hgnDataStruct.requantTable, fieldsAndBounds, ...
    'hgnDataStruct.requantTable');

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% Second level validation.
% Validate the structure field hgnDataStruct.cadencePixels.
%--------------------------------------------------------------------------
fieldsAndBounds = cell(3,4);
fieldsAndBounds(1,:)  = { 'cadence'; '> -2^20'; '< 2^20'; []};  % for now
fieldsAndBounds(2,:)  = { 'pixelValues'; '>= 0'; '< 2^23'; []};
fieldsAndBounds(3,:)  = { 'gapIndicators'; '>= 0'; '<= 1'; []};

nStructures = length(hgnDataStruct.cadencePixels);

for j = 1 : nStructures
	validate_structure(hgnDataStruct.cadencePixels(j), fieldsAndBounds, ...
        'hgnDataStruct.cadencePixels');
end

clear fieldsAndBounds;

% Order the fields to avoid getting error messages like:
%   Error using ==> class 
%   Field names and parent classes for class hgnDataClass cannot be
%   changed without clear classes
hgnDataStruct = orderfields(hgnDataStruct);

hgnDataStruct.hgnModuleParameters = orderfields(hgnDataStruct.hgnModuleParameters);
hgnDataStruct.fcConstants = orderfields(hgnDataStruct.fcConstants);
hgnDataStruct.requantTable = orderfields(hgnDataStruct.requantTable);

if ~isempty(hgnDataStruct.cadencePixels)
    hgnDataStruct.cadencePixels = orderfields(hgnDataStruct.cadencePixels);
end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Input validation successfully completed!
% Create the hgnDataClass object.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
hgnDataObject = class(hgnDataStruct, 'hgnDataClass');

% Return.
return
