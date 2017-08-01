function write_tad_ssr_bytes(ccdObject, tadInputStruct)
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

runParamsObject = ccdObject.runParamsClass;
module = get(runParamsObject, 'moduleNumber');
output = get(runParamsObject, 'outputNumber');
endian = get(runParamsObject, 'endian');

write_target_definition(tadInputStruct.targetDefinitions, module, output, ...
    ccdObject.targetDefinitionSpec, ccdObject.targetDefinitionFilename, endian);
write_mask_definition(tadInputStruct.maskDefinitions, ...
    ccdObject.apertureDefinitionSpec, ccdObject.apertureDefinitionFilename, endian);
write_target_definition(tadInputStruct.backgroundTargetDefinitions, module, output, ...
    ccdObject.targetDefinitionSpec, ccdObject.backgroundTargetDefinitionFilename, endian);
write_mask_definition(tadInputStruct.backgroundMaskDefinitions, ...
    ccdObject.apertureDefinitionSpec, ccdObject.backgroundApertureDefinitionFilename, endian);
write_target_definition(tadInputStruct.refPixelTargetDefinitions, module, output, ...
    ccdObject.targetDefinitionSpec, ccdObject.referencePixelTargetDefinitionFilename, endian);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function write_target_definition(targetDefinitions, module, output, targetDefSpec, filename, endian)

% write out the target definitions as they appear on the Kepler SSR
% implements FS-GS ICD 5.2.4.1

nTargets = length(targetDefinitions);
% the number of bytes is the number of targets plus 1 for the mod/out/# of
% targets leading byte
targetDefinitionBytes = zeros(nTargets + 1, 1, 'uint32');

counter = 1;
% set up the module/output/# of targets leading byte
targetDefinitionBytes(counter) = bitor( ...
    uint32(bitshift(module, targetDefSpec.moduleShift)), ...
    uint32(bitshift(output, targetDefSpec.outputShift)));
targetDefinitionBytes(counter) = bitor(targetDefinitionBytes(counter), ...
    uint32(nTargets));
counter = counter + 1;

% write the actual target definitions, 
% this is still zero-based
for t=1:nTargets % don't overwrite the leading byte
    targetDefinitionBytes(counter) = bitor( ...
        uint32(bitshift(double(targetDefinitions(t).referenceRow), targetDefSpec.rowShift)), ...
        uint32(bitshift(double(targetDefinitions(t).referenceColumn), targetDefSpec.colShift)));
    targetDefinitionBytes(counter) = bitor(targetDefinitionBytes(counter), ...
        uint32(targetDefinitions(t).maskIndex)); 
    
    counter = counter + 1;
end

fid = fopen(filename, 'w', endian);
fwrite(fid, targetDefinitionBytes, 'uint32');
fclose(fid);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function write_mask_definition(maskDefinitions, maskDefSpec, filename, endian)
% write out the aperture (aka mask) definitions as they appear on the Kepler SSR
% fills in all masks, using 0-length masks is all masks are not defined
%
% implements FS-GS ICD 5.2.4.2

maxMaskTableSize = 1024;

nDefinedMasks = length(maskDefinitions);

maskDefinitionBytes = zeros(maxMaskTableSize, 1, 'uint32');

counter = 1;
for m=1:maxMaskTableSize
    if m <= nDefinedMasks
        nOffsets = length(maskDefinitions(m).offsets);
        % set the pattern byte, recalling that the index m needs to be
        % converted from 1-base to 0-base
        maskDefinitionBytes(counter) = bitor( ...
            uint32(bitshift(m - 1, maskDefSpec.patternShift)), uint32(nOffsets));

        counter = counter + 1;
        
        % we have to go through some gymnastics 'cause matlab is not good
        % at manipulating signed ints
        offsets = maskDefinitions(m).offsets;
        % the order of the offsets **MUST** be preserved
        for o=1:nOffsets
            if offsets(o).row >= 0
                rowWord = uint32(offsets(o).row);
            else
                % fake a high-order bit indicating negative
                rowWord = uint32(2^15 - offsets(o).row);
            end
            if offsets(o).column >= 0
                colWord = uint32(offsets(o).column);
            else
                % fake a high-order bit indicating negative
                colWord = uint32(2^15 - offsets(o).column);
            end
            maskDefinitionBytes(counter) = ...
                bitor(uint32(bitshift(rowWord, maskDefSpec.rowShift)), ...
                uint32(colWord));   
            counter = counter + 1;
        end
    else
        % the remaining masks are empty so set their length to 0
        nOffsets = 0;
        % set the pattern byte, recalling that the index m needs to be
        % converted from 1-base to 0-base
        maskDefinitionBytes(counter) = bitor( ...
            uint32(bitshift(m - 1, maskDefSpec.patternShift)), uint32(nOffsets));
        
        counter = counter + 1;
    end
end

fid = fopen(filename, 'w', endian);
fwrite(fid, maskDefinitionBytes, 'uint32');
fclose(fid);
