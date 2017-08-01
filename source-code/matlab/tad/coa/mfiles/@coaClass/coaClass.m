function coaObject = coaClass(coaInputStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function coaObject = coaCreateClass(coaInputStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Returns the coaObject of type coaClass containing the following fields:
% Fields set from fields of coaInputStruct:
%   .kicEntryDataStruct() - array of structs with KIC data for each object on 
%       the current CCD module.  Struct fields:
%       .dec Declination of the object in degrees
%       .RA  Right ascension of the object in hours
%       .magnitude  visual magnitude of the object
%       .KICID ID of the object in KIC
%   .pixelModelStruct - struct with the following fields
%       .wellCapacity maximum # of electrons in a pixel well
%       .saturationSpillUpFraction fraction of excess electrons spills up
%       .flux12 flux in electrons per second of a magnitude 12 star
%       .cadenceTime time in seconds of a long cadence
%       .integrationTime time in seconcs of a single integration
%       .transferTime time in seconds of a readout transfer
%       .exposuresPerCadence # of exposures in a long cadence
%       .parallelCTE charge transfer efficiency in the parallel direction
%       .serialCTE charge transfer efficiency in the serial direction
%       .readNoiseSquared square of read noise
%       .quantizationNoiseSquared square of quantization noise
%   .moduleDescriptionStruct - struct with the following fields
%       .nRowPix # of visible rows in the synthetic image we are generating
%       .nColPix # of visible columns in the synthetic image we are generating
%       .leadingBlack # of leading black pixels
%       .trailingBlack # of trailing black pixels
%       .virtualSmear # of virtual smear pixels
%       .maskedSmear # of masked smear pixels
%   .coaConfigurationStruct - struct with the following fields
%       .dvaMeshEdgeBuffer how close to the edge of a CCD we compute the dva
%       .dvaMeshOrder order of the polynomial fit to dva mesh
%       .nDvaMeshRows size of the mesh on which to compute DVA.
%       .nDvaMeshCols size of the mesh on which to compute DVA.
%       .nOutputBufferPix # of pixels to allow off visible ccd
%       .nStarImageRows # of rows in each star image.  Must be odd
%       .nStarImageCols # of columns in each star image.  Must be odd
%       .starChunkLength # of stars to process at a time
%       .raOffset, decOffset, phiOffset offsets from nominal pointing in degrees
%       .motionPolynomialsEnabled logical, use motion polynomials rather than ra_dec_2_pix if true
%       .backgroundPolynomialsEnabled logical, use background polynomials rather (zodi) model if true
%   .startTime - time at which to compute the star pixel locations,
%       typically the start time of the simulation
%   .duration duration of time in days to be simulated
%   .targetKeplerIDList n x 1 array of target star KIC id's
%   .module CCD module to be simulated
%   .output CCD module output to be simulated
%   .raDec2PixObject model containing ra_dec_2_pix object
%   .motionPolyStruct motion polynomials for given module output from PA
%   .backgroundPolyStruct background polynomials for given module output from PA
%   .debugFlag boolean to control debugging display
%
% Fields to be filled by COA operations:
%   .dvaCoeffStruct structure of polynomial coefficients giving the
%       aberrated star positions for each cadence
%   .outputImage simulated CCD output image before application of artefacts
%       such as smear, CTE etc.
%   .completeOutputImage simulated CCD output image after application of artefacts
%       such as smear, CTE etc.
%   .targetImages array of structures that contain optimal
%       apertures and other data about target stars
%   .targetImages array of structures that contain images, and other data about target stars
%   .numTargetImages # of defined target images
%   .minRow, .maxRow, .minCol, .maxCol bounding box of aberrated targets
%       on the CCD module output
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

load_previous = 0; % force a load of previously computed data

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
        {' >= -90 ',' <= 90 '};
    nfields = nfields + 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'RA';
    fieldsAndBoundsStruct(nfields).binaryCompare = ...
        {' >= 0 ', ' <= 24 '};
    nfields = nfields + 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'magnitude';
    fieldsAndBoundsStruct(nfields).binaryCompare = ...
        {' >= -10 ', ' <= 100 '};
    nfields = nfields + 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'KICID';
    fieldsAndBoundsStruct(nfields).binaryCompare = ...
        {' >= 0 ', ' <= 1e12 '};
    check_struct(coaInputStruct.kicEntryDataStruct, ...
        fieldsAndBoundsStruct, 'TAD:coaClass:kicEntryDataStruct');

    clear fieldsAndBoundsStruct;
    
    % check that the KICID field is all integer
    intTest = [coaInputStruct.kicEntryDataStruct.KICID];
    if any(intTest ~= fix(intTest))
        error('TAD:coaClass:notInteger:kicEntryDataStruct',...
            'KICID: not all integer')
    end
        
    % now check the fields of pixelModelStruct
    if(~isfield(coaInputStruct, 'pixelModelStruct'))
        error('TAD:coaClass:missingField:pixelModelStruct',...
            'pixelModelStruct: field not present in the input structure.')
    end
    
    nfields = 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'cadenceTime';
    fieldsAndBoundsStruct(nfields).binaryCompare = ...
        {' >= .1 ', ' <= 60*60 ' }; % seconds
    nfields = nfields + 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'wellCapacity';
    fieldsAndBoundsStruct(nfields).binaryCompare = ...
        {' >= 0 '};
    nfields = nfields + 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'saturationSpillUpFraction';
    fieldsAndBoundsStruct(nfields).binaryCompare = ...
        {' >= 0 ', ' <= 1 '};
    nfields = nfields + 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'flux12';
    fieldsAndBoundsStruct(nfields).binaryCompare = ...
        {' >= 0 '};
    nfields = nfields + 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'integrationTime';
    fieldsAndBoundsStruct(nfields).binaryCompare = ...
        {' >= 0 ', ' <= 60*60 '};
    nfields = nfields + 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'transferTime';
    fieldsAndBoundsStruct(nfields).binaryCompare = ...
        {' >= 0 ', ' <= 60*60 '};
    nfields = nfields + 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'exposuresPerCadence';
    fieldsAndBoundsStruct(nfields).binaryCompare = ...
        {' >= 0 ', ' <= 2000 '};
    nfields = nfields + 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'parallelCTE';
    fieldsAndBoundsStruct(nfields).binaryCompare = ...
        {' >= 0 ', ' <= 1 ' };
    nfields = nfields + 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'serialCTE';
    fieldsAndBoundsStruct(nfields).binaryCompare = ...
        {' >= 0 ', ' <= 1 ' };
    nfields = nfields + 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'readNoiseSquared';
    fieldsAndBoundsStruct(nfields).binaryCompare = ...
        {' >= 0 ', ' <= 1e8 ' };
    nfields = nfields + 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'quantizationNoiseSquared';
    fieldsAndBoundsStruct(nfields).binaryCompare = ...
        {' >= 0 ', ' <= 1e6 ' };
    check_struct(coaInputStruct.pixelModelStruct, ...
        fieldsAndBoundsStruct, 'TAD:coaClass:pixelModelStruct');

    clear fieldsAndBoundsStruct;
    
    % check that the exposuresPerCadence field is all integer
    intTest = coaInputStruct.pixelModelStruct.exposuresPerCadence;
    if any(intTest ~= fix(intTest))
        error('TAD:coaClass:notInteger:pixelModelStruct',...
            'exposuresPerCadence: not all integer')
    end

    % now check the fields of moduleDescriptionStruct
    if(~isfield(coaInputStruct, 'moduleDescriptionStruct'))
        error('TAD:coaClass:missingField:moduleDescriptionStruct',...
            'moduleDescriptionStruct: field not present in the input structure.')
    end
    
    nfields = 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'nRowPix';
    fieldsAndBoundsStruct(nfields).binaryCompare = ...
        {' >= 1000 ', ' <= 2000 '};
    nfields = nfields + 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'nColPix';
    fieldsAndBoundsStruct(nfields).binaryCompare = ...
        {' >= 1000 ', ' <= 2000 '};
    nfields = nfields + 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'leadingBlack';
    fieldsAndBoundsStruct(nfields).binaryCompare = ...
        {' >= 0 ', ' <= 100 '};
    nfields = nfields + 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'trailingBlack';
    fieldsAndBoundsStruct(nfields).binaryCompare = ...
        {' >= 0 ', ' <= 100 '};
    nfields = nfields + 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'virtualSmear';
    fieldsAndBoundsStruct(nfields).binaryCompare = ...
        {' >= 0 ', ' <= 100 '};
    nfields = nfields + 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'maskedSmear';
    fieldsAndBoundsStruct(nfields).binaryCompare = ...
        {' >= 0 ', ' <= 100 '};
     check_struct(coaInputStruct.moduleDescriptionStruct, ...
        fieldsAndBoundsStruct, 'TAD:coaClass:moduleDescriptionStruct');

    clear fieldsAndBoundsStruct;
    
    % check that the appropriate fields are all integer
    intTest = cell2mat(struct2cell(coaInputStruct.moduleDescriptionStruct));
    if any(intTest ~= fix(intTest))
        error('TAD:coaClass:notInteger:moduleDescriptionStruct',...
            'moduleDescriptionStruct: not all integer')
    end

    % now check the fields of coaConfigurationStruct
    if(~isfield(coaInputStruct, 'coaConfigurationStruct'))
        error('TAD:coaClass:missingField:coaConfigurationStruct',...
            'coaConfigurationStruct: field not present in the input structure.')
    end
    
    nfields = 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'dvaMeshEdgeBuffer';
    fieldsAndBoundsStruct(nfields).binaryCompare = ...
        {' >= -200 ', ' <= 200 '};
    nfields = nfields + 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'dvaMeshOrder';
    fieldsAndBoundsStruct(nfields).binaryCompare = ...
        {' >= 0 ', ' <= 20 '};
    nfields = nfields + 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'nDvaMeshRows';
    fieldsAndBoundsStruct(nfields).binaryCompare = ...
        {' >= 1 ', ' <= 200 '};
    nfields = nfields + 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'nDvaMeshCols';
    fieldsAndBoundsStruct(nfields).binaryCompare = ...
        {' >= 1 ', ' <= 200 '};
    nfields = nfields + 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'nOutputBufferPix';
    fieldsAndBoundsStruct(nfields).binaryCompare = ...
        {' >= -200 ', ' <= 200 '};
    nfields = nfields + 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'nStarImageRows';
    fieldsAndBoundsStruct(nfields).binaryCompare = ...
        {' >= 0 ', ' <= 1200 '};
    nfields = nfields + 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'nStarImageCols';
    fieldsAndBoundsStruct(nfields).binaryCompare = ...
        {' >= 0 ', ' <= 1200 '};
    nfields = nfields + 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'starChunkLength';
    fieldsAndBoundsStruct(nfields).binaryCompare = ...
        {' >= 1 ', ' <= 1e12 '};
    nfields = nfields + 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'raOffset';
    fieldsAndBoundsStruct(nfields).binaryCompare = ...
        {' >= 0 ', ' <= 360 '}; % days
    nfields = nfields + 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'decOffset';
    fieldsAndBoundsStruct(nfields).binaryCompare = ...
        {' >= 0 ', ' <= 360 '}; % days
    nfields = nfields + 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'phiOffset';
    fieldsAndBoundsStruct(nfields).binaryCompare = ...
        {' >= 0 ', ' <= 360 '}; % days
    nfields = nfields + 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'motionPolynomialsEnabled';
    fieldsAndBoundsStruct(nfields).binaryCompare = ...
        {' >= 0 ', ' <= 1 '}; % logical
    nfields = nfields + 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'backgroundPolynomialsEnabled';
    fieldsAndBoundsStruct(nfields).binaryCompare = ...
        {' >= 0 ', ' <= 1 '}; % logical
    check_struct(coaInputStruct.coaConfigurationStruct, ...
        fieldsAndBoundsStruct, 'TAD:coaClass:coaConfigurationStruct');

    clear fieldsAndBoundsStruct;
    
%     intStruct = coaInputStruct.coaConfigurationStruct;
%     % check that the appropriate fields are all integer
%     intStruct = rmfield(intStruct, 'raOffset');
%     intStruct = rmfield(intStruct, 'decOffset');
%     intStruct = rmfield(intStruct, 'phiOffset');
%     intTest = cell2mat(struct2cell(intStruct));
%     if any(intTest ~= fix(intTest))
%         error('TAD:coaClass:notInteger:coaConfigurationStruct',...
%             'coaConfigurationStruct: not all integer')
%     end

    % check that required parameters are odd
    if(~mod(coaInputStruct.coaConfigurationStruct.nStarImageRows,2))
        error('TAD:coaClass:notOdd:coaConfigurationStruct',...
            'coaConfigurationStruct: nStarImageRows must be odd.')
    end
    if(~mod(coaInputStruct.coaConfigurationStruct.nStarImageCols,2))
        error('TAD:coaClass:notOdd:coaConfigurationStruct',...
            'coaConfigurationStruct: nStarImageRows must be odd.')
    end

    % now check for the existence of prfStruct
	% prfStruct is opaque, so we cannot check its contents
    if(~isfield(coaInputStruct, 'prfStruct'))
        error('TAD:coaClass:missingField:prfStruct',...
            'prfStruct: field not present in the input structure.')
    end
    
    % now check for the existence of raDec2PixObject
	% raDec2PixObject is opaque, so we cannot check its contents
    if(~isfield(coaInputStruct, 'raDec2PixObject'))
        error('TAD:coaClass:missingField:raDec2PixObject',...
            'raDec2PixObject: field not present in the input structure.')
    end
    
    % check the fields in coaInputStruct
    nfields = 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'module';
    fieldsAndBoundsStruct(nfields).binaryCompare = ...
        {' >= 0 ', ' <= 100 '};
    nfields = nfields + 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'output';
    fieldsAndBoundsStruct(nfields).binaryCompare = ...
        {' >= 0 ', ' <= 5 '};
    nfields = nfields + 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'startTime';
    fieldsAndBoundsStruct(nfields).binaryCompare = [];
    nfields = nfields + 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'duration';
    fieldsAndBoundsStruct(nfields).binaryCompare = ...
        {' >= 0 ', ' <= 10000 '}; % days
    nfields = nfields + 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'targetKeplerIDList';
    fieldsAndBoundsStruct(nfields).binaryCompare = ...
        {' >= 0 ', ' <= 1e12 '};
    nfields = nfields + 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'debugFlag';
    fieldsAndBoundsStruct(nfields).binaryCompare = [];
    check_struct(coaInputStruct, fieldsAndBoundsStruct, ...
        'TAD:coaClass');
    
    %----------------------------------------------------------------------
    % Validate the structure field coaInputStruct.motionPolyStruct if it
    % exists.
    %----------------------------------------------------------------------
    if ~isempty(coaInputStruct.motionPolyStruct)

        fieldsAndBounds = cell(10,4);
        fieldsAndBounds(1,:)  = { 'cadence'; '>= 0'; '< 2e7'; []};
        fieldsAndBounds(2,:)  = { 'mjdStartTime'; '> 54500'; '< 70000'; []}; % 2/4/2008 to 7/13/2050
        fieldsAndBounds(3,:)  = { 'mjdMidTime'; '> 54500'; '< 70000'; []};   % 2/4/2008 to 7/13/2050
        fieldsAndBounds(4,:)  = { 'mjdEndTime'; '> 54500'; '< 70000'; []};   % 2/4/2008 to 7/13/2050
        fieldsAndBounds(5,:)  = { 'module'; []; []; '[2:4, 6:20, 22:24]'''};
        fieldsAndBounds(6,:)  = { 'output'; []; []; '[1 2 3 4]'''};
        fieldsAndBounds(7,:)  = { 'rowPoly'; []; []; []};
        fieldsAndBounds(8,:)  = { 'rowPolyStatus'; []; []; '[0:1]'''};
        fieldsAndBounds(9,:)  = { 'colPoly'; []; []; []};
        fieldsAndBounds(10,:) = { 'colPolyStatus'; []; []; '[0:1]'''};

        motionPolyStruct = coaInputStruct.motionPolyStruct;
        motionPolyGapIndicators = ...
            ~logical([motionPolyStruct.rowPolyStatus]');
        motionPolyStruct = motionPolyStruct(~motionPolyGapIndicators);

        nStructures = length(motionPolyStruct);

        for i = 1 : nStructures
            validate_structure(motionPolyStruct(i), fieldsAndBounds, ...
                'coaInputStruct.motionPolyStruct()');
        end

        clear fieldsAndBounds;

    end % if

    %----------------------------------------------------------------------
    % Validate the structure field coaInputStruct.motionPolyStruct().rowPoly
    % if it exists.
    %----------------------------------------------------------------------
    if ~isempty(coaInputStruct.motionPolyStruct)

        fieldsAndBounds = cell(13,4);
        fieldsAndBounds(1,:)  = { 'offsetx'; []; []; '0'};
        fieldsAndBounds(2,:)  = { 'scalex'; '>= 0'; []; []};
        fieldsAndBounds(3,:)  = { 'originx'; []; []; []};
        fieldsAndBounds(4,:)  = { 'offsety'; []; []; '0'};
        fieldsAndBounds(5,:)  = { 'scaley'; '>= 0'; []; []};
        fieldsAndBounds(6,:)  = { 'originy'; []; []; []};
        fieldsAndBounds(7,:)  = { 'xindex'; []; []; '-1'};
        fieldsAndBounds(8,:)  = { 'yindex'; []; []; '-1'};
        fieldsAndBounds(9,:)  = { 'type'; []; []; {'standard'}};
        fieldsAndBounds(10,:) = { 'order'; '>= 0'; '< 10'; []};
        fieldsAndBounds(11,:) = { 'message'; []; []; {}};
        fieldsAndBounds(12,:) = { 'coeffs'; []; []; []};                % TBD
        fieldsAndBounds(13,:) = { 'covariance'; []; []; []};            % TBD

        nStructures = length(motionPolyStruct);

        for i = 1 : nStructures
            validate_structure(motionPolyStruct(i).rowPoly, ...
                fieldsAndBounds, 'coaInputStruct.motionPolyStruct().rowPoly');
        end

        clear fieldsAndBounds;

    end % if

    %----------------------------------------------------------------------
    % Validate the structure field 
    % coaInputStruct.motionPolyStruct().colPoly if it exists.
    %----------------------------------------------------------------------
    if ~isempty(coaInputStruct.motionPolyStruct)

        fieldsAndBounds = cell(13,4);
        fieldsAndBounds(1,:)  = { 'offsetx'; []; []; '0'};
        fieldsAndBounds(2,:)  = { 'scalex'; '>= 0'; []; []};
        fieldsAndBounds(3,:)  = { 'originx'; []; []; []};
        fieldsAndBounds(4,:)  = { 'offsety'; []; []; '0'};
        fieldsAndBounds(5,:)  = { 'scaley'; '>= 0'; []; []};
        fieldsAndBounds(6,:)  = { 'originy'; []; []; []};
        fieldsAndBounds(7,:)  = { 'xindex'; []; []; '-1'};
        fieldsAndBounds(8,:)  = { 'yindex'; []; []; '-1'};
        fieldsAndBounds(9,:)  = { 'type'; []; []; {'standard'}};
        fieldsAndBounds(10,:) = { 'order'; '>= 0'; '< 10'; []};
        fieldsAndBounds(11,:) = { 'message'; []; []; {}};
        fieldsAndBounds(12,:) = { 'coeffs'; []; []; []};                % TBD
        fieldsAndBounds(13,:) = { 'covariance'; []; []; []};            % TBD

        nStructures = length(motionPolyStruct);

        for i = 1 : nStructures
            validate_structure(motionPolyStruct(i).colPoly, ...
                fieldsAndBounds, 'coaInputStruct.motionPolyStruct().colPoly');
        end

        clear fieldsAndBounds;

    end % if

    
    %----------------------------------------------------------------------
    % Validate the structure field coaInputStruct.backgroundPolyStruct() if
    % it exists.
    %----------------------------------------------------------------------
    if ~isempty(coaInputStruct.backgroundPolyStruct)

        fieldsAndBounds = cell(8,4);
        fieldsAndBounds(1,:)  = { 'cadence'; '>= 0'; '< 2e7'; []};
        fieldsAndBounds(2,:)  = { 'mjdStartTime'; '> 54500'; '< 70000'; []}; % 2/4/2008 to 7/13/2050
        fieldsAndBounds(3,:)  = { 'mjdMidTime'; '> 54500'; '< 70000'; []}; % 2/4/2008 to 7/13/2050
        fieldsAndBounds(4,:)  = { 'mjdEndTime'; '> 54500'; '< 70000'; []}; % 2/4/2008 to 7/13/2050
        fieldsAndBounds(5,:)  = { 'module'; []; []; '[2:4, 6:20, 22:24]'''};
        fieldsAndBounds(6,:)  = { 'output'; []; []; '[1 2 3 4]'''};
        fieldsAndBounds(7,:)  = { 'backgroundPoly'; []; []; []};
        fieldsAndBounds(8,:)  = { 'backgroundPolyStatus'; []; []; '[0:1]'''};

        backgroundPolyStruct = coaInputStruct.backgroundPolyStruct;
        backgroundPolyGapIndicators = ...
            ~logical([backgroundPolyStruct.backgroundPolyStatus]');
        backgroundPolyStruct = backgroundPolyStruct(~backgroundPolyGapIndicators);

        nStructures = length(backgroundPolyStruct);

        for i = 1 : nStructures
            validate_structure(backgroundPolyStruct(i), fieldsAndBounds, ...
                'coaInputStruct.backgroundPolyStruct()');
        end

        clear fieldsAndBounds;

    end % if

    %----------------------------------------------------------------------
    % Validate the structure field 
    % coaInputStruct.backgroundPolyStruct().backgroundPoly if it exists.
    %----------------------------------------------------------------------
    if ~isempty(coaInputStruct.backgroundPolyStruct)

        fieldsAndBounds = cell(13,4);
        fieldsAndBounds(1,:)  = { 'offsetx'; []; []; '0'};
        fieldsAndBounds(2,:)  = { 'scalex'; '>= 0'; []; []};
        fieldsAndBounds(3,:)  = { 'originx'; []; []; []};
        fieldsAndBounds(4,:)  = { 'offsety'; []; []; '0'};
        fieldsAndBounds(5,:)  = { 'scaley'; '>= 0'; []; []};
        fieldsAndBounds(6,:)  = { 'originy'; []; []; []};
        fieldsAndBounds(7,:)  = { 'xindex'; []; []; '-1'};
        fieldsAndBounds(8,:)  = { 'yindex'; []; []; '-1'};
        fieldsAndBounds(9,:)  = { 'type'; []; []; {'standard'}};
        fieldsAndBounds(10,:) = { 'order'; '>= 0'; '< 10'; []};
        fieldsAndBounds(11,:) = { 'message'; []; []; {}};
        fieldsAndBounds(12,:) = { 'coeffs'; []; []; []};                % TBD
        fieldsAndBounds(13,:) = { 'covariance'; []; []; []};            % TBD

        nStructures = length(backgroundPolyStruct);

        for i = 1 : nStructures
            validate_structure(backgroundPolyStruct(i).backgroundPoly, ...
                fieldsAndBounds, 'coaInputStruct.backgroundPolyStruct().backgroundPoly');
        end

        clear fieldsAndBounds;

    end % if
    
    % check that the appropriate fields are all integer
    intTest = coaInputStruct.module;
    if any(intTest ~= fix(intTest))
        error('TAD:coaClass:notInteger:coaInputStruct',...
            'module: not all integer')
    end
    intTest = coaInputStruct.output;
    if any(intTest ~= fix(intTest))
        error('TAD:coaClass:notInteger:coaInputStruct',...
            'output: not all integer')
    end
    intTest = coaInputStruct.targetKeplerIDList;
    if any(intTest ~= fix(intTest))
        error('TAD:coaClass:notInteger:coaInputStruct',...
            'targetKeplerIDList: not all integer')
    end
    intTest = coaInputStruct.debugFlag;
    if any(intTest ~= fix(intTest))
        error('TAD:coaClass:notInteger:coaInputStruct',...
            'debugFlag: not all integer')
    end

    startTime = datestr2julian(coaInputStruct.startTime);
    if(startTime < datestr2julian('01-Jan-2008'))
        error('TAD:coaClass:rangeCheck:coaInputStruct:startTime',...
            'coaInputStruct: startTime is too early')
    end
    if(startTime > datestr2julian('01-Jan-2030'))
        error('TAD:coaClass:rangeCheck:coaInputStruct:startTime',...
            'coaInputStruct: startTime is too late')
    end
    
    % add other fields that are computed later
    coaInputStruct.dvaCoeffStruct = [];
    coaInputStruct.outputImage = [];
    coaInputStruct.completeOutputImage = [];
    coaInputStruct.targetImages = struct([]);
    coaInputStruct.optimalApertures = struct([]);
    coaInputStruct.numTargetImages = 0;
    coaInputStruct.minRow = [];
    coaInputStruct.maxRow = [];
    coaInputStruct.minCol = [];
    coaInputStruct.maxCol = [];
    
    % load previous computations for development and testing
    if (load_previous)
        preCompute = load('coa_output');
        coaInputStruct.dvaCoeffStruct = ...
            preCompute(1,1).coaResultStruct.dvaCoeffStruct;        
        coaInputStruct.kicEntryDataStruct = ...
            preCompute(1,1).coaResultStruct.kicEntryDataStruct;
        coaInputStruct.targetKeplerIDList = ...
            preCompute(1,1).coaResultStruct.targetKeplerIDList;
        coaInputStruct.outputImage = preCompute(1,1).coaResultStruct.outputImage;
        coaInputStruct.targetImages = preCompute(1,1).coaResultStruct.targetImages;
    end
end

% make the coaClass object
coaObject = class(coaInputStruct, 'coaClass');
