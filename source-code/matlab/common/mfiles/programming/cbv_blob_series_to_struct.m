function [cbvStruct, gapIndicators] = ...
cbv_blob_series_to_struct(cbvBlobSeries, startCadence, endCadence)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [cbvStruct, gapIndicators] = ...
% cbv_blob_series_to_struct(cbvBlobSeries, startCadence, endCadence)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Convert cotrending basis vector (CBV) series of blobs for a given module
% output and quarter to a standard CBV structure. Also return the gap
% indicators for the given CBV blob series.
%
% Start and end cadence are optional. If provided, they will be checked for
% consistency with the cadence range in the blob series.
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
if ~isempty(cbvBlobSeries) && ~isempty(cbvBlobSeries.blobIndices) && ...
        ~isempty(cbvBlobSeries.blobFilenames)
    
    % Instantiate a blob series class object.
    cbvBlobObject = blobSeriesClass(cbvBlobSeries);
    
    % Get the gap indicators and cadence range, and check validity.
    gapIndicators = get_gap_indicators(cbvBlobObject);
    nCadences = length(gapIndicators);
    
    if all(gapIndicators)
        error('Common:cbvBlobSeriesToStruct:invalidBlobSeries', ...
            'Blob series contains gaps only');
    end % if
    
    [blobStartCadence, blobEndCadence] = get_cadence_range(cbvBlobObject);
    if exist('startCadence', 'var')
        if blobStartCadence ~= startCadence
            error('Common:cbvBlobSeriesToStruct:invalidStartCadence', ...
                'Specified start cadence (%d) does not match blob series start cadence (%d)', ...
                startCadence, blobStartCadence);
        end % if
    else
        startCadence = blobStartCadence;
    end % if / else
    if exist('endCadence', 'var')
        if blobEndCadence ~= endCadence
            error('Common:cbvBlobSeriesToStruct:invalidEndCadence', ...
                'Specified end cadence (%d) does not match blob series end cadence (%d)', ...
                endCadence, blobEndCadence);
        end % if
    else
        endCadence = blobEndCadence;
    end % if / else
    
    if nCadences ~= endCadence - startCadence + 1
        error('Common:cbvBlobSeriesToStruct:cadenceInconsistency', ...
            'Start cadence = %d, End cadence = %d; Number of blob series cadences = %d', ...
            startCadence, endCadence, nCadences)
    end % if
    
    % Convert the CBV blob to a structure.
    structForCadence = ...
        get_struct_for_cadence(cbvBlobObject, find(~gapIndicators, 1));
    cbvStruct = structForCadence.struct;
    
else % blob is empty
    
    cbvStruct = [];
    gapIndicators = [];
    
end % if / else

% Return.
return
