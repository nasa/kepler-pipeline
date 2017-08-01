function coaObject = coaCreateClass(coaInputStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function coaObject = coaCreateClass(coaInputStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Returns the starCentroidObject of type coaClass.
% Inputs:   
%   coaInputStruct - struct that contains the folloing:
%   .kicEntryDataStruct() - array of structs with KIC data for each object on 
%       the current CCD module.  Struct fields:
%           .dec Declination of the object in degrees
%           .RA  Right ascension of the object in degrees
%           .magnitude  visual magnitude of the object
%           .KICID ID of the object in KIC
%   .startTime - time at which to compute the star pixel locations,
%       typically the start time of the simulation
% !!!???? need to add the following to inputs to TAD:
%   .flux12 Flux of a 12th magnitude start in e-/sec
%   .longCadenceTime Time in seconds of a long exposure
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

EARLIEST_DATE = '01-Jan-2008';
LATEST_DATE = '01-Jan-2030';
MIN_LONG_CADENCE_TIME = .5*60; % seconds
MAX_LONG_CADENCE_TIME = 60*60; % seconds
MIN_DEC = -90; % don't try to be on the Kepler FOV since the KIC has 
MAX_DEC = 90; % entries well off the FOV.  So accept the KIC struct and
MIN_RA = 0; % filter the objects later.
MAX_RA = 24;
MIN_MAGNITUDE = -1; % sanity check
MAX_MAGNITUDE = 100;
MIN_KICID = 0;
MAX_KICID = 1e12; % sanity check
MIN_DURATION = -0; % days
MAX_DURATION = 10000; % days
MIN_MODULE = 0;
MAX_MODULE = 100;
MIN_OUTPUT = 0;
MAX_OUTPUT = 5;
MIN_NROWPIX = 1000;
MAX_NROWPIX = 2000;
MIN_NCOLPIX = 1000;
MAX_NCOLPIX = 2000;

if nargin == 0
    % if no inputs generate an error
    error('TAD:coaClass:EmptyInputStruct',...
        'The constructor must be called with an input structure.');
else
    % check for the presence of the field kicEntryDataStruct, which is an
    % array of structs so needs special treatment
    if(~isfield(coaInputStruct, 'kicEntryDataStruct'))
        error('TAD:coaClass:missingField:kicEntryDataStruct',...
            'kicEntryDataStruct: field not present in the input structure.')
    end
    % now check the fields of kicEntryDataStruct
    nfields = 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'dec';
    fieldsAndBoundsStruct(nfields).binaryCompare = ...
        {[' >= ' num2str(MIN_DEC)], ...
        [' <= ' num2str(MAX_DEC)]};
    nfields = nfields + 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'RA';
    fieldsAndBoundsStruct(nfields).binaryCompare = ...
        {[' >= ' num2str(MIN_RA)], ...
        [' <= ' num2str(MAX_RA)]};
    nfields = nfields + 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'magnitude';
    fieldsAndBoundsStruct(nfields).binaryCompare = ...
        {[' >= ' num2str(MIN_MAGNITUDE)], ...
        [' <= ' num2str(MAX_MAGNITUDE)]};
    nfields = nfields + 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'KICID';
    fieldsAndBoundsStruct(nfields).binaryCompare = ...
        {[' >= ' num2str(MIN_KICID)], ...
        [' <= ' num2str(MAX_KICID)]};
    check_struct(coaInputStruct.kicEntryDataStruct, ...
        fieldsAndBoundsStruct, 'TAD:coaClass:kicEntryDataStruct');

    clear fieldsAndBoundsStruct;

    if(~isfield(coaInputStruct, 'pixelModelStruct'))
        error('TAD:coaClass:missingField:pixelModelStruct',...
            'pixelModelStruct: field not present in the input structure.')
    end
    
    % now check the fields of pixelModelStruct
    nfields = 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'longCadenceTime';
    fieldsAndBoundsStruct(nfields).binaryCompare = ...
        {[' >= ' num2str(MIN_LONG_CADENCE_TIME)], ...
        [' <= ' num2str(MAX_LONG_CADENCE_TIME)]};
    nfields = nfields + 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'flux12';
    fieldsAndBoundsStruct(nfields).binaryCompare = ...
        {' >=0 '};
    check_struct(coaInputStruct.pixelModelStruct, ...
        fieldsAndBoundsStruct, 'TAD:coaClass:pixelModelStruct');

    clear fieldsAndBoundsStruct;

    if(~isfield(coaInputStruct, 'moduleDescriptionStruct'))
        error('TAD:coaClass:missingField:moduleDescriptionStruct',...
            'moduleDescriptionStruct: field not present in the input structure.')
    end
    
    % now check the fields of moduleDescriptionStruct
    nfields = 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'module';
    fieldsAndBoundsStruct(nfields).binaryCompare = ...
        {[' >= ' num2str(MIN_MODULE)], ...
        [' <= ' num2str(MAX_MODULE)]};
    nfields = nfields + 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'output';
    fieldsAndBoundsStruct(nfields).binaryCompare = ...
        {[' >= ' num2str(MIN_OUTPUT)], ...
        [' <= ' num2str(MAX_OUTPUT)]};
    nfields = nfields + 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'nRowPix';
    fieldsAndBoundsStruct(nfields).binaryCompare = ...
        {[' >= ' num2str(MIN_NROWPIX)], ...
        [' <= ' num2str(MAX_NROWPIX)]};
    nfields = nfields + 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'nColPix';
    fieldsAndBoundsStruct(nfields).binaryCompare = ...
        {[' >= ' num2str(MIN_NCOLPIX)], ...
        [' <= ' num2str(MAX_NCOLPIX)]};    
     check_struct(coaInputStruct.moduleDescriptionStruct, ...
        fieldsAndBoundsStruct, 'TAD:coaClass:moduleDescriptionStruct');

    clear fieldsAndBoundsStruct;
    
    % check the scalar fields in coaInputStruct
    nfields = 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'startTime';
    fieldsAndBoundsStruct(nfields).binaryCompare = ...
        {[' > ' num2str(datestr2julian(EARLIEST_DATE))], ...
        [' < ' num2str(datestr2julian(LATEST_DATE))]};
    nfields = nfields + 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'duration';
    fieldsAndBoundsStruct(nfields).binaryCompare = ...
        {[' >= ' num2str(MIN_DURATION)], ...
        [' <= ' num2str(MAX_DURATION)]};
    check_struct(coaInputStruct, fieldsAndBoundsStruct, ...
        'TAD:coaClass');
    
    % add other fields
    coaInputStruct.starPixDataStruct = [];
    coaInputStruct.OffsetBasisCoeffStruct = [];
    coaInputStruct.outputImage = [];
    coaInputStruct.smearImage = [];
    coaInputStruct.abStarStruct = [];
end

coaObject = class(coaInputStruct, 'coaClass');
