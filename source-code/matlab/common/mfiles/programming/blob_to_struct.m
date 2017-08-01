function [outputStruct, gapList] = blob_to_struct(blobStruct, startCadence, endCadence)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [outputStruct, gapList] = blob_to_struct(blobStruct, startCadence,
%   endCadence)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% convert an array of blob structures to an output structure array
%
% input:
%   blobStruct(), a structure array with the following fields
%       .startCadence, .endCadence start and end cadence for each blob in the
%           array
%       .blob() 1D array of class uint8
%   startCadence the beginning cadence number of the time period of
%       interest from which to extract structures
%   endCadence the end cadence number of the time period of
%       interest from which to extract structures
%
% output: 
%   outputStruct, an array of structures
%   gapList, array containing indices in outputStruct for which the
%       structure is invalid
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

    % blobStruct may be a single blob (not a struct) and the only argument
    if ~isstruct(blobStruct) && nargin == 1
        outputStruct = open_blob(blobStruct);
    else
        numBlobs = length(blobStruct);

        % initialize the output structure;
        outputStruct = [];

        for thisBlob = 1:numBlobs
            inputStruct = open_blob(blobStruct(thisBlob).blob);

            % get the structure size so we can do appropriate concatanation
            structSize = size(inputStruct);
            % if the output struct is empty initialize it to an array with the
            % right shape and range of cadences
            if isempty(outputStruct)
                numOutputCadences = endCadence - startCadence + 1;
                if structSize(1) == 1
                    outputStruct = repmat(inputStruct(1), 1, numOutputCadences);
                    invalidIndices = ones(1, numOutputCadences); %initialize everything to invalid
                else
                    outputStruct = repmat(inputStruct(1), numOutputCadences, 1);
                    invalidIndices = ones(numOutputCadences, 1); %initialize everything to invalid
                end
            end
            % check to make sure size is consistent sith outputStruct
            if ~isempty(outputStruct)
                if (structSize(1) == 1 && size(outputStruct, 1) ~= 1) ...
                        || (structSize(2) == 1 && size(outputStruct, 2) ~= 1)
                    error('blob_to_struct:bad_shape', 'blobs not consistent shapes');
                end
            end

            % pull out the cadence range of interest
            if (blobStruct(thisBlob).endCadence >= startCadence) && ...
                    (blobStruct(thisBlob).startCadence <= endCadence)
                % this blob is somewhere in desired range
                % compute the start index
                if blobStruct(thisBlob).startCadence < startCadence
                    localStart = startCadence - blobStruct(thisBlob).startCadence + 1;
                else
                    localStart = 1;
                end
                % compute the end index
                if blobStruct(thisBlob).endCadence < endCadence
                    localEnd = length(inputStruct);
                else
                    localEnd = length(inputStruct) - (blobStruct(thisBlob).endCadence - endCadence);
                end

                % now insert the local cadences into the appropriate slots of
                % the output struct
                globalStart = blobStruct(thisBlob).startCadence - startCadence + 1;
                if globalStart < 1
                    globalStart = 1;
                end
                globalEnd = globalStart + length(inputStruct(localStart:localEnd)) - 1;

                outputStruct(globalStart:globalEnd) = inputStruct(localStart:localEnd);
                % mark valid entries as valid
                invalidIndices(globalStart:globalEnd) = 0;        
            end
            % construct list of invalid indices as gaps
            gapList = find(invalidIndices == 1);

            % have to do the following 'cause an empty result of find can have a
            % spurious size
            if isempty(gapList)
                gapList = [];
            end
        end
    end
end


function outputStruct = open_blob(blob)
    % open a .mat file to write as a stream of uint8
    fid = fopen('tempFile.mat', 'w');
    fwrite(fid, blob, 'uint8');
    fclose(fid);

    % read the blob file.  The contents is a structure array called
    % "inputStruct"
    load tempFile.mat;
    outputStruct = inputStruct;
    
    % delete the temporary file
    delete tempFile.mat;
end
