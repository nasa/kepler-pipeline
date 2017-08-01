function dynablackFitStruct = collapse_dynablack_fit_array(dynablackFitStructArray, startTime, endTime)
% function dynablackFitStruct = collapse_dynablack_fit_array(dynablackFitStructArray, startTime, endTime)
%
% This function selects a single element out of the array of dynablackFitStruct as retrieved from the
% dynablackBlobs to produce a single structure which is most representative of the unit of work based on the
% start and end mjd. If dynablackFitStructArray = [], dynablackFitStruct = [] is returned.
%
% INPUT:    dynablackFitStructArray = [1xm] array of structure called 'struct'
%                                           Each element struct contains the following fields:
%                                                 ccdModule: 2
%                                                 ccdOutput: 1
%                                              cadenceTimes: [1x1 struct]
%                                     dynablackBlobFilename: 'dynablack_blob.mat'
%                                            meanBlackTable: [84x1 double]
%                                            A1_fit_results: [1x1 struct]
%                                          A1_fit_residInfo: [1x1 struct]
%                                               A1ModelDump: [1x1 struct]
%                                            A2_fit_results: [1x1 struct]
%                                          A2_fit_residInfo: [1x1 struct]
%                                               A2ModelDump: [1x1 struct]
%                                           B1a_fit_results: [1x1 struct]
%                                         B1a_fit_residInfo: [1x1 struct]
%                                              B1aModelDump: [1x1 struct]
%                                           B1b_fit_results: [1x1 struct]
%                                         B1b_fit_residInfo: [1x1 struct]
%                                              B1bModelDump: [1x1 struct]
%           startTime               = mjd of start of first cadence in UOW
%           endTime                 = mjd of end of last cadence in UOW
%
% OUTPUT:   dynablackFitStruct      single element of dynablackFitStruct which represents the entire unit of work
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



% check trivial case of empty input struct
if( isempty(dynablackFitStructArray) )
    dynablackFitStruct = [];
    return;
end

% parse array of structures
if( ~isfield(dynablackFitStructArray,'struct') )
    error('Fieldname struct missing in structure returned from get_struct_for_cadence. Cannot collapse dynablack blob.');
else
    dynablackFitStructArray = [dynablackFitStructArray.struct];
end
    
% single element array requires no collapsing
nElements = length(dynablackFitStructArray);
if nElements == 1
    dynablackFitStruct = dynablackFitStructArray;
    return;
end

% determine coverage of UOW for each element
coverage = zeros(nElements,1);
for iElement = 1:nElements
    startMjdCovered = max(dynablackFitStructArray(iElement).cadenceTimes.startTimestamps(1), startTime);
    endMjdCovered = min(dynablackFitStructArray(iElement).cadenceTimes.endTimestamps(end), endTime);    
    coverage(iElement) = (endMjdCovered - startMjdCovered) / (endTime - startTime);
end

% select element which covers the largest part of the UOW
[maxCoverage, maxElement] = max(coverage);                                                                                                 %#ok<ASGLU>
dynablackFitStruct = dynablackFitStructArray(maxElement);
