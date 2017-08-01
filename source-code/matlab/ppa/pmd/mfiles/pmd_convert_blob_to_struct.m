function pmdInputStruct = pmd_convert_blob_to_struct(pmdInputStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function pmdInputStruct = pmd_convert_blob_to_struct(pmdInputStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This function coverts the fields backgroundBlobs and motionBlobs into
% backgroundPolyStruct and motionPolyStruct in pmdInputStruct.
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

% detrermine the number of long cadences
nCadences            = length(pmdInputStruct.cadenceTimes.midTimestamps);

% Initialize the background polynomial struture
emptyBackgroundPoly = struct( ...
    'cadence',              -1, ...
    'mjdStartTime',         -1, ...
    'mjdMidTime',           -1, ...
    'mjdEndTime',           -1, ...
    'module',               -1, ...
    'output',               -1, ...
    'backgroundPoly',       [], ...
    'backgroundPolyStatus', 0 );
backgroundPolyStruct = repmat(emptyBackgroundPoly, 1, nCadences);

% Initialize the motion polynomial struture
emptyMotionPoly = struct( ...
    'cadence',              -1, ...
    'mjdStartTime',         -1, ...
    'mjdMidTime',           -1, ...
    'mjdEndTime',           -1, ...
    'module',               -1, ...
    'output',               -1, ...
    'rowPoly',              [], ...
    'rowPolyStatus',        0,  ...
    'colPoly',              [], ...
    'colPolyStatus',        0 );
motionPolyStruct     = repmat(emptyMotionPoly, 1, nCadences);

% Convert backgroundBlobs to  backgroundPolyStruct
if any(~pmdInputStruct.backgroundBlobs.gapIndicators)
    pmdInputStruct.backgroundPolyStruct = poly_blob_series_to_struct( pmdInputStruct.backgroundBlobs );
else
    pmdInputStruct.backgroundPolyStruct = backgroundPolyStruct;
end

% Convert motionBlobs to  motionPolyStruct
if any(~pmdInputStruct.motionBlobs.gapIndicators)
    pmdInputStruct.motionPolyStruct     = poly_blob_series_to_struct( pmdInputStruct.motionBlobs );
else
    pmdInputStruct.motionPolyStruct     = motionPolyStruct;
end

pmdInputStruct = rmfield(pmdInputStruct, {'backgroundBlobs', 'motionBlobs'});

return