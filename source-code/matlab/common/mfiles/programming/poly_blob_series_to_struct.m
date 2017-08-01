function [polyStruct] = ...
poly_blob_series_to_struct(polyBlobSeries, startCadence, endCadence)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [polyStruct] = ...
% poly_blob_series_to_struct(polyBlobSeries, startCadence, endCadence)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Convert series of background or motion blobs to standard background or
% motion polynomial struct array. Set status flag to bad (0) for background
% or row and column polynomials with cadence gaps. Blob type is determined
% from blob itself.
%
% Start and end cadence are optional. If provided, they will be checked for
% consistency with the cadence range in the blob series. If not provided,
% the start and end cadence within the blob series will be used for the
% conversion without validity checking.
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

    
% Check if blob is empty.
if ~isempty(polyBlobSeries) && ~isempty(polyBlobSeries.blobIndices) && ...
        ~isempty(polyBlobSeries.blobFilenames)
    
    % Instantiate a blob series class object.
    polyBlobObject = blobSeriesClass(polyBlobSeries);
    
    % Get the gap indicators and cadence range, and check validity.
    gapIndicators = get_gap_indicators(polyBlobObject);
    nCadences = length(gapIndicators);
    
    if all(gapIndicators)
        error('Common:polyBlobSeriesToStruct:invalidBlobSeries', ...
            'Blob series contains gaps only');
    end
    
    [blobStartCadence, blobEndCadence] = get_cadence_range(polyBlobObject);
    if exist('startCadence', 'var')
        if blobStartCadence ~= startCadence
            error('Common:polyBlobSeriesToStruct:invalidStartCadence', ...
                'Specified start cadence (%d) does not match blob series start cadence (%d)', ...
                startCadence, blobStartCadence);
        end
    else
        startCadence = blobStartCadence;
    end
    if exist('endCadence', 'var')
        if blobEndCadence ~= endCadence
            error('Common:polyBlobSeriesToStruct:invalidEndCadence', ...
                'Specified end cadence (%d) does not match blob series end cadence (%d)', ...
                endCadence, blobEndCadence);
        end
    else
        endCadence = blobEndCadence;
    end
    
    if nCadences ~= endCadence - startCadence + 1
    error('Common:polyBlobSeriesToStruct:cadenceInconsistency', ...
        'Start cadence = %d, End cadence = %d; Number of blob series cadences = %d', ...
        startCadence, endCadence, nCadences)
    end
    
    % Determine the polynomial type (background or motion) from the first
    % available polynomial structure.
    structForCadence = get_struct_for_cadence(polyBlobObject, find(~gapIndicators, 1));
    firstStruct = structForCadence.struct;
    
    if isfield(firstStruct, 'backgroundPoly')
        isBackground = true;
    elseif isfield(firstStruct, 'rowPoly') && isfield(firstStruct, 'colPoly')
        isBackground = false;
    else
        error('Common:polyBlobSeriesToStruct:unsupportedPolyType', ...
            'Polynomial type is unsupported')
    end
    
    ccdModule = firstStruct.module;
    ccdOutput = firstStruct.output;
    
    % Initialize the polynomial struct array.
    nullPoly = make_weighted_poly(2, 0, 1);
    nullPoly.message = 'null polynomial structure';
    
    if isBackground
        
        polyStruct = repmat(struct( ...
            'cadence', 0, ...
            'mjdStartTime', 0, ...
            'mjdMidTime', 0, ...
            'mjdEndTime', 0, ...
            'module', ccdModule, ...
            'output', ccdOutput, ...
            'backgroundPoly', nullPoly, ...
            'backgroundPolyStatus', 0), [1, nCadences]);
    
    else % must be motion poly
        
        polyStruct = repmat(struct( ...
            'cadence', 0, ...
            'mjdStartTime', 0, ...
            'mjdMidTime', 0, ...
            'mjdEndTime', 0, ...
            'module', ccdModule, ...
            'output', ccdOutput, ...
            'rowPoly', nullPoly, ...
            'rowPolyStatus', 0, ...
            'colPoly', nullPoly, ...
            'colPolyStatus', 0), [1, nCadences]);
        
    end % if / else
    
    cadenceCellArray = num2cell(startCadence : endCadence);
    [polyStruct(1 : nCadences).cadence] = cadenceCellArray{:};
   
    
    % Piece together the polynomial struct array cadence by cadence. There
    % is no other way.
    cadence = startCadence;
    
    for iCadence = 1 : nCadences
    
        % Check the gap indicator.
        if ~gapIndicators(iCadence)
            
            % Get the valid poly struct for the given cadence. Continue if
            % that poly struct is empty for some reason.
            structForCadence = get_struct_for_cadence(polyBlobObject, iCadence);
            polyStructForCadence = structForCadence.struct;
            
            if isempty(polyStructForCadence)
                continue;
            end
            
            % Find the element in the poly struct for the given cadence
            % that matches the desired cadence number. Merge this with the
            % poly struct array to be output from this function.
            cadences = [polyStructForCadence.cadence];
            isMatch = (cadence == cadences);
            nMatches = sum(isMatch);
            
            if nMatches == 1
                polyStruct(iCadence) = ...
                    polyStructForCadence(isMatch);
            elseif nMatches > 1
                error('Common:polyBlobSeriesToStruct:invalidPolyStructure', ...
                    'Blob contains multiple elements for cadence %d', ...
                    cadence)
            end  
            
        end % if
        
        % Increment the cadence number.
        cadence = cadence + 1;
        
    end % for
    
else % blob is empty
    
    polyStruct = [];
    
end % if / else

% Return.
return
