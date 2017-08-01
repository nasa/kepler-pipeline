function rptsResultsStruct = validate_rpts_results_struct(debugFlag, existingMasks, ...
    fcConstants, rptsResultsStruct)
% functionrptsResultsStruct = validate_rpts_results_struct(debugFlag, existingMasks,...
%   fcConstants, rptsResultsStruct)
%
% function to validate the fields and bounds of results structure prior to output:
% (1) checks for the presence of all output fields
% (2) check whether the parameters are within bounds (most bounds are dictated
%     by the # bits allowed in the target or aperture pattern definitions that
%     are described in the FS-GS ICD.
% (3) checks to make sure all output pixels are on CCD
%
% Note: if fields are structures, make sure their bounds are empty
% Based on algorithm validate_structure by H.C.
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

%--------------------------------------------------------------------------
% get values from the focal plane constants for check to make sure all output
% pixels are on the ccd - note results struct is now in java 0-base
%--------------------------------------------------------------------------

nRowsImaging    = fcConstants.nRowsImaging;   % 1024
nColsImaging    = fcConstants.nColsImaging;   % 1100
nLeadingBlack   = fcConstants.nLeadingBlack;  % 12
nTrailingBlack  = fcConstants.nTrailingBlack; % 20
nVirtualSmear   = fcConstants.nVirtualSmear;  % 26
nMaskedSmear    = fcConstants.nMaskedSmear;   % 20

%--------------------------------------------------------------------------
% top level validation
% check for the presence of all top level fields in rptsResultsStruct
%--------------------------------------------------------------------------
fieldsAndBounds(1,:)  = { 'stellarTargetDefinitions'; []; []; []};
fieldsAndBounds(2,:)  = { 'dynamicRangeTargetDefinitions'; []; []; []};
fieldsAndBounds(3,:)  = { 'backgroundTargetDefinition'; []; []; []};
fieldsAndBounds(4,:)  = { 'blackTargetDefinitions'; []; []; []};
fieldsAndBounds(5,:)  = { 'smearTargetDefinitions'; []; []; []};
fieldsAndBounds(6,:)  = { 'backgroundMaskDefinition'; []; []; []};
fieldsAndBounds(7,:)  = { 'blackMaskDefinition'; []; []; []};
fieldsAndBounds(8,:)  = { 'smearMaskDefinition'; []; []; []};

validate_structure(rptsResultsStruct, fieldsAndBounds, 'rptsResultsStruct');
clear fieldsAndBounds

%--------------------------------------------------------------------------
% second level validation
% validate the structure field stellarTargetDefinitions
% Note the values 2^n are taken from the format (#bits) of the target
% definition described in the FS-GS ICD: 10 bits for mask index,
% and 11 bits for the reference rows and columns

if (~isempty(rptsResultsStruct.stellarTargetDefinitions))
    fieldsAndBounds(1,:)  = { 'keplerId'; '>= 0'; '< 1e9'; []};
    fieldsAndBounds(2,:)  = { 'maskIndex'; '>= 0'; '< 2^10'; []};
    fieldsAndBounds(3,:)  = { 'excessPixels'; '>= 0'; '< 1e9'; []};

    nStructures = length(rptsResultsStruct.stellarTargetDefinitions);
    for j = 1:nStructures
        validate_structure(rptsResultsStruct.stellarTargetDefinitions(j), fieldsAndBounds, ...
            'rptsResultsStruct.stellarTargetDefinitions');
    end
    clear fieldsAndBounds

    if (debugFlag)
        %----------------------------------------------------------------------
        % check to ensure that all stellar target reference pixels are on the CCD
        for j = 1 : length([rptsResultsStruct.stellarTargetDefinitions])

            [stellarRows, stellarColumns] = get_absolute_pixel_indices(rptsResultsStruct.stellarTargetDefinitions(j), existingMasks);

            validRows = find((stellarRows(:) >= 0) & (stellarRows(:) < (nMaskedSmear + nRowsImaging + nVirtualSmear)));
            validColumns = find((stellarColumns(:) >= 0) & (stellarColumns(:) < (nLeadingBlack + nColsImaging + nTrailingBlack)));

            if (length(validRows) < length(stellarRows)) || ((length(validColumns) < length(stellarColumns)))
                warning('TAD:rpts:validateRptsResults', ...
                    'Warning: reference pixels for stellar targets are off the accumulation memory');
            end
        end
    end
end

%--------------------------------------------------------------------------
% second level validation
% validate the structure field dynamicRangeTargetDefinitions

% Note the values 2^n are taken from the format (#bits) of the target
% definition described in the FS-GS ICD: 10 bits for mask index,
% and 11 bits for the reference rows and columns

if (~isempty(rptsResultsStruct.dynamicRangeTargetDefinitions))
    fieldsAndBounds(1,:)  = { 'keplerId'; '>= 0'; '< 1e9'; []};
    fieldsAndBounds(2,:)  = { 'maskIndex'; '>= 0'; '< 2^10'; []};
    fieldsAndBounds(3,:)  = { 'excessPixels'; '>= 0'; '< 1e9'; []};

    nStructures = length(rptsResultsStruct.dynamicRangeTargetDefinitions);
    for j = 1:nStructures
        validate_structure(rptsResultsStruct.dynamicRangeTargetDefinitions(j), ...
            fieldsAndBounds, 'rptsResultsStruct.dynmamicRangeTargetDefinitions');
    end
    clear fieldsAndBounds

    if (debugFlag)
        %----------------------------------------------------------------------
        % check to ensure that all dynamic range target reference pixels are on the CCD
        for j = 1 : length([rptsResultsStruct.dynamicRangeTargetDefinitions])

            [dynamicRows, dynamicColumns] = get_absolute_pixel_indices(rptsResultsStruct.dynamicRangeTargetDefinitions(j), existingMasks);

            validRows = find((dynamicRows(:) >= 0) & (dynamicRows(:) < (nMaskedSmear + nRowsImaging + nVirtualSmear)));
            validColumns = find((dynamicColumns(:) >= 0) & (dynamicColumns(:) < (nLeadingBlack + nColsImaging + nTrailingBlack)));

            if (length(validRows) < length(dynamicRows)) || ((length(validColumns) < length(dynamicColumns)))
                warning('TAD:rpts:validateRptsResults', ...
                    'Warning: reference pixels for dynamic range targets are off the accumulation memory');
            end
        end
    end
end

%--------------------------------------------------------------------------
% second level validation
% validate the structure field backgroundTargetDefinition

% Note the values 2^n are taken from the format (#bits) of the target
% definition described in the FS-GS ICD: 10 bits for mask index,
% and 11 bits for the reference rows and columns

if (~isempty(rptsResultsStruct.backgroundTargetDefinition))
    fieldsAndBounds(1,:)  = { 'keplerId'; '>= 0'; '< 1e9'; []};
    fieldsAndBounds(2,:)  = { 'maskIndex'; '>= 0'; '< 2^10'; []};
    fieldsAndBounds(3,:)  = { 'excessPixels'; '>= 0'; '< 1e9'; []};

    validate_structure(rptsResultsStruct.backgroundTargetDefinition, fieldsAndBounds, ...
        'rptsResultsStruct.backgroundTargetDefinition');
    clear fieldsAndBounds

    %--------------------------------------------------------------------------
    % second level validation
    % validate the structure field backgroundMaskDefinition

    fieldsAndBounds(1,:)  = { 'offsets'; []; []; []};

    validate_structure(rptsResultsStruct.backgroundMaskDefinition, fieldsAndBounds, ...
        'rptsResultsStruct.backgroundMaskDefinition');
    clear fieldsAndBounds
    
    %--------------------------------------------------------------------------
    % third level validation
    % validate the structure field backgroundMaskDefinition.offsets
    % Note the value 2^15 is taken from the format (#bits) of the aperture pattern
    % definition described in the FS-GS ICD
    fieldsAndBounds(1,:)  = { 'row'; '> -2^15'; '< 2^15'; []};
    fieldsAndBounds(2,:)  = { 'column'; '> -2^15'; '< 2^15'; []};

    nStructures = length(rptsResultsStruct.backgroundMaskDefinition);
    for j = 1:nStructures
        validate_structure(rptsResultsStruct.backgroundMaskDefinition.offsets(j), fieldsAndBounds, ...
            'rptsResultsStruct.backgroundMaskDefinition.offsets');
    end
    clear fieldsAndBounds

    if (debugFlag)
        %----------------------------------------------------------------------
        % check to ensure that all background target reference pixels are on the CCD

        [backgroundRows, backgroundColumns] = get_absolute_pixel_indices(rptsResultsStruct.backgroundTargetDefinition, ...
            rptsResultsStruct.backgroundMaskDefinition);

        validRows = find((backgroundRows(:) >= 0) & (backgroundRows(:) < (nMaskedSmear + nRowsImaging + nVirtualSmear)));
        validColumns = find((backgroundColumns(:) >= 0) & (backgroundColumns(:) < (nLeadingBlack + nColsImaging + nTrailingBlack)));

        if (length(validRows) < length(backgroundRows)) || ((length(validColumns) < length(backgroundColumns)))
            warning('TAD:rpts:validateRptsResults', ...
                'Warning: background reference pixels are off the accumulation memory');
        end
    end
end

%--------------------------------------------------------------------------
% second level validation
% validate the structure field blackTargetDefinitions

% Note the values 2^n are taken from the format (#bits) of the target
% definition described in the FS-GS ICD: 10 bits for mask index,
% and 11 bits for the reference rows and columns

if (~isempty(rptsResultsStruct.blackTargetDefinitions))
    fieldsAndBounds(1,:)  = { 'keplerId'; '>= 0'; '< 1e9'; []};
    fieldsAndBounds(2,:)  = { 'maskIndex'; '>= 0'; '< 2^10'; []};
    fieldsAndBounds(3,:)  = { 'excessPixels'; '>= 0'; '< 1e9'; []};

    nStructures = length(rptsResultsStruct.blackTargetDefinitions);
    for j = 1:nStructures
        validate_structure(rptsResultsStruct.blackTargetDefinitions(j), ...
            fieldsAndBounds, 'rptsResultsStruct.blackTargetDefinitions');
    end
    clear fieldsAndBounds

    %--------------------------------------------------------------------------
    % second level validation
    % validate the structure field blackMaskDefinition

    fieldsAndBounds(1,:)  = { 'offsets'; []; []; []};

    validate_structure(rptsResultsStruct.blackMaskDefinition, fieldsAndBounds, ...
        'rptsResultsStruct.blackMaskDefinition');
    clear fieldsAndBounds

    %--------------------------------------------------------------------------
    % third level validation
    % validate the structure field blackMaskDefinition.offsets
    % Note the value 2^15 is taken from the format (#bits) of the aperture pattern
    % definition described in the FS-GS ICD
    fieldsAndBounds(1,:)  = { 'row'; '> -2^15'; '< 2^15'; []};
    fieldsAndBounds(2,:)  = { 'column'; '> -2^15'; '< 2^15'; []};

    nStructures = length(rptsResultsStruct.blackMaskDefinition);
    for j = 1:nStructures
        validate_structure(rptsResultsStruct.blackMaskDefinition.offsets(j), fieldsAndBounds, ...
            'rptsResultsStruct.blackMaskDefinition.offsets');
    end
    clear fieldsAndBounds

    if (debugFlag)
        %----------------------------------------------------------------------
        % check to ensure that all black target definitions are within black valid ranges
        for j = 1 : length([rptsResultsStruct.blackTargetDefinitions])

            [blackRows, blackColumns] = get_absolute_pixel_indices(rptsResultsStruct.blackTargetDefinitions(j), ...
                rptsResultsStruct.blackMaskDefinition);

            % black rows in target definition should equal zero
            % validRows = find((blackRows(:) <= nMaskedblack - 1) | (blackRows(:) >= (nMaskedblack + nRowsImaging))  & (blackRows(:) >= 0));
            validRows = find((blackRows(:) >= 0) & (blackRows(:) < (nMaskedSmear + nRowsImaging + nVirtualSmear)));
            validColumns = find((blackColumns(:) < nLeadingBlack) | (blackColumns(:) >= (nLeadingBlack + nColsImaging)) & (blackColumns(:) >= 0));

            if (length(validRows) < length(blackRows)) || ((length(validColumns) < length(blackColumns)))
                warning('TAD:rpts:validateRptsResults', ...
                    'Warning: black reference pixels are not in valid ranges');
            end

            negativeRows = find(blackRows(:) < 0);
            negativeColumns = find(blackColumns(:) < 0);

            if any(negativeRows) || any(negativeColumns)
                warning('TAD:rpts:validateRptsResults', ...
                    'Warning: black reference row and/or column has a negative value');
            end
        end
    end % if debugFlag
end

%--------------------------------------------------------------------------
% second level validation
% validate the structure field smearTargetDefinitions

% Note the values 2^n are taken from the format (#bits) of the target
% definition described in the FS-GS ICD: 10 bits for mask index,
% and 11 bits for the reference rows and columns

if (~isempty(rptsResultsStruct.smearTargetDefinitions))
    fieldsAndBounds(1,:)  = { 'keplerId'; '>= 0'; '< 1e9'; []};
    fieldsAndBounds(2,:)  = { 'maskIndex'; '>= 0'; '< 2^10'; []};
    fieldsAndBounds(3,:)  = { 'excessPixels'; '>= 0'; '< 1e9'; []};

    nStructures = length(rptsResultsStruct.smearTargetDefinitions);
    for j = 1:nStructures
        validate_structure(rptsResultsStruct.smearTargetDefinitions(j), fieldsAndBounds, ...
            'rptsResultsStruct.smearTargetDefinitions');
    end
    clear fieldsAndBounds

    %--------------------------------------------------------------------------
    % second level validation
    % validate the structure field smearMaskDefinition

    fieldsAndBounds(1,:)  = { 'offsets'; []; []; []};

    validate_structure(rptsResultsStruct.smearMaskDefinition, fieldsAndBounds, ...
        'rptsResultsStruct.smearMaskDefinition');
    clear fieldsAndBounds
    
    %--------------------------------------------------------------------------
    % second level validation
    % validate the structure field smearMaskDefinition.offsets
    % Note the value 2^15 is taken from the format (#bits) of the aperture pattern
    % definition described in the FS-GS ICD
    fieldsAndBounds(1,:)  = { 'row'; '> -2^15'; '< 2^15'; []};
    fieldsAndBounds(2,:)  = { 'column'; '> -2^15'; '< 2^15'; []};

    nStructures = length(rptsResultsStruct.smearMaskDefinition);
    for j = 1:nStructures
        validate_structure(rptsResultsStruct.smearMaskDefinition.offsets(j), fieldsAndBounds, ...
            'rptsResultsStruct.smearMaskDefinition.offsets');
    end
    clear fieldsAndBounds

    if (debugFlag)
        %----------------------------------------------------------------------
        % check to ensure that all smear target definitions are within smear valid ranges
        for j = 1 : length([rptsResultsStruct.smearTargetDefinitions])

            [smearRows, smearColumns] = get_absolute_pixel_indices(rptsResultsStruct.smearTargetDefinitions(j), ...
                rptsResultsStruct.smearMaskDefinition);

            validRows = find((smearRows(:) < nMaskedSmear) | (smearRows(:) >= (nMaskedSmear + nRowsImaging)) & (smearRows(:) >= 0));
            validColumns = find((smearColumns(:) >= 0) & (smearColumns(:) <= (nLeadingBlack + nColsImaging + nTrailingBlack - 1)));

            if (length(validRows) < length(smearRows)) || ((length(validColumns) < length(smearColumns)))
                warning('TAD:rpts:validateRptsResults', ...
                    'Warning: smear reference pixels are not in valid ranges');
            end

            negativeRows = find(smearRows(:) < 0);
            negativeColumns = find(smearColumns(:) < 0);

            if any(negativeRows) || any(negativeColumns)
                warning('TAD:rpts:validateRptsResults', ...
                    'Warning: smear reference row and/or column has a negative value');
            end
        end
    end
end

return