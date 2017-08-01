function maskDefinitionTableStruct = get_mask_definitions(location, type)
% return the mask definition (aka aperture) table appropriate to the type
% 
% type: optional argument, defaults to 'targets'.  Legal types are:
% 'targets', 'target', 'reference', which return the target mask definition
% table, and 'background' which returns the background mask definition
% table.
%
% maskDefinitionTableStruct is a 1 x nmasks structure array each containing
% the 1 x npixels structure array offsets.  Each offsets contains the
% fields .row and .column, giving the row and column offsets of that pixel
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

load([location filesep 'ssrFileMap.mat']);
ssrOutputDirectory = [location filesep ssrFileStruct.ssrOutputDirectory];
rowShift = ssrFileStruct.apertureDefinitionSpec.rowShift;

maxMaskTableSize = 1024;

if nargin < 2
    type = 'targets';
end

switch type
    case 'targets'
        filename = ssrFileStruct.apertureDefinitionFilename;
    case 'target'
        filename = ssrFileStruct.apertureDefinitionFilename;
    case 'reference'
        filename = ssrFileStruct.apertureDefinitionFilename;
    case 'background'
        filename = ssrFileStruct.backgroundApertureDefinitionFilename;
    otherwise
        error([type ' is not a legal value']);
end

fid = fopen([ssrOutputDirectory filesep filename], 'r', 'ieee-be');
if fid == -1
	maskDefinitionTableStruct = [];
    return;
end;

maskDefinitionTableStruct = repmat(struct('offsets', []), 1, maxMaskTableSize);
for m=1:maxMaskTableSize
    % get the mask ID data
    maskIdWord = fread(fid, 1, 'uint32');
    % the number of offsets is 15 bits 0-14
    nOffsets = bitand(maskIdWord, bin2dec('111111111111111'));
    if nOffsets > 0
        % get the offsets
        offsetWords = fread(fid, nOffsets, 'uint32');
        % unpack the offsets
        maskDefinitionTableStruct(m).offsets ...
            = repmat(struct('row', 0, 'column', 0), 1, nOffsets);
        % the order of the offsets **MUST** be preserved
        for o=1:nOffsets
            % we have to go through some gymnastics 'cause matlab is not good
            % at manipulating signed ints
            
            % the row data is 16 bits 16-31 (counting from 0)
            val = bitand(bitshift(offsetWords(o), -rowShift), bin2dec('1111111111111111'));
            if val > 2^15
                val = 2^15 - val;
            end
            maskDefinitionTableStruct(m).offsets(o).row = val;

            % the colum data is 16 bits 0-15
            val = bitand(offsetWords(o), bin2dec('1111111111111111'));
            if val > 2^15
                val = 2^15 - val;
            end
            maskDefinitionTableStruct(m).offsets(o).column = val;
        end
    end
end

fclose(fid);
