function backgroundPolys = debug_retrieve_background_polynomials(ccdModule, ccdOutput, startCadence, endCadence)
%function backgroundPolys = debug_retrieve_background_polynomials(ccdModule, ccdOutput, startCadence, endCadence)
% 
% Retrieve the background polynomials for the specified mod/out and cadence
% range.
%
% Inputs
%   ccdModule             The module number
%   ccdOutput             The output number
%   startCadence          The starting cadence number.  The cadence range
%                         may span multiple quarters
%   endCadence            The ending cadence number.  The cadence range
%                         may span multiple quarters
% Outputs
%   blobIndices: [numCadencesx1 double]            Index into blobs (see
%                                                  below) indicating which
%                                                  blob should be used for
%                                                  a given cadence.
%   gapIndicators: [numCadencesx1 double]          Gap indicators for each
%                                                  cadence
%   startCadence                                   Start cadence (same as
%                                                  input arg)
%   endCadence                                     End cadence (same as 
%                                                  input arg)
%   blobs: 1xN struct array with fields:           Array of blobs that
%                                                  cover (possibly
%                                                  overlapping) the
%                                                  requested cadence range.
%     startCadence                                 Start cadence for this
%                                                  blob
%     endCadence                                   End cadence for this
%                                                  blob
%     blob: [Nx1 uint8]                            Raw bytes that make up
%                                                  the blob
%   reconstitutedBlobs: [1xnumCadences struct]     Return value from
%                                                  blob_to_struct
%   reconstitutedBlobsGapList: [1xN double]        Return value from
%                                                  blob_to_struct
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



import gov.nasa.kepler.systest.sbt.SbtRetrieveBlobSeries;

matPathJava = SbtRetrieveBlobSeries.retrieveBlobSeries(ccdModule, ccdOutput, startCadence,...
    endCadence, 'BACKGROUND');

matPath = matPathJava.toCharArray()';

disp('Loading .mat file...');
backgroundPolys = load(matPath, 's');
backgroundPolys = backgroundPolys.s;

[outputStruct gapList] = blob_to_struct(backgroundPolys.blobs,... 
    backgroundPolys.startCadence, backgroundPolys.endCadence);

backgroundPolys.reconstitutedBlobs = outputStruct;
backgroundPolys.reconstitutedBlobsGapList = gapList;

disp('...DONE Loading .mat file');


