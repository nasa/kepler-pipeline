

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


amaLimits = [2467, 2550];
rootDir = '/path/to/ort3-tad-bin-files';
directories = dir(rootDir);
directories([1 2]) = []; % kill off '.' and '..'

tadMap = repmat(struct('amaDir', []), 84);
for d = 1:length(directories)
    % find the ama long cadence directories
    disp(directories(d).name);
    amaSubDir = dir([rootDir filesep directories(d).name filesep 'ama-matlab-121-*']);
    for amaD = 1:length(amaSubDir)
        amaIdNum = sscanf(amaSubDir(amaD).name, 'ama-matlab-121-%d');
        if amaIdNum >= amaLimits(1) && amaIdNum <= amaLimits(2)
            disp(amaSubDir(amaD).name);
            dirHead = [rootDir filesep directories(d).name filesep amaSubDir(amaD).name];
            amaIs = read_AmaInputs([dirHead filesep 'ama-inputs-0.bin']);
            amaOs = read_AmaOutputs([dirHead filesep 'ama-outputs-0.bin']);
            targetDefs = amaOs.targetDefinitions;
            nTargets = length(targetDefs);
            nMaskPix = zeros(length(targetDefs), 1);
            for t=1:nTargets
                maskDef = amaIs.maskDefinitions(targetDefs(t).maskIndex+1);
                nMaskPix(t) = length([maskDef.offsets.row]);
            end

            channel = convert_from_module_output(amaIs.module, amaIs.output);
            tadMap(channel).module = amaIs.module;
            tadMap(channel).output = amaIs.output;
            tadMap(channel).amaDir = dirHead;
            tadMap(channel).usedMasks ...
                = [amaOs.targetDefinitions.maskIndex];
            tadMap(channel).nMaskPix = nMaskPix;
            tadMap(channel).totalPixelCount = sum(nMaskPix);
            tadMap(channel).averagePixelsPerTarget ...
                = sum(nMaskPix)/length(nMaskPix);
            
        end
    end
    maskDefinitions = amaIs.maskDefinitions;
end

% 
% for d = 1:length(directories)
%     % get the coa data.  All coa sub-directories are long cadence
%     coaSubDir = dir([rootDir filesep directories(d).name filesep 'coa-matlab-121-*']);
%     for coaD = 1:length(coaSubDir)
%         coaIdNum = sscanf(coaSubDir(coaD).name, 'coa-matlab-121-%d');
%         disp(coaSubDir(coaD).name);
%         dirHead = [rootDir filesep directories(d).name filesep coaSubDir(coaD).name];
%         coaIs = read_CoaInputs([dirHead filesep 'coa-inputs-0.bin']);
%         coaOs = read_CoaOutputs([dirHead filesep 'coa-outputs-0.bin']);
% 
%         channel = convert_from_module_output(coaIs.module, coaIs.output);
%         tadMap(channel).coaDir = dirHead;
%         tadMap(channel).completeOutputImage ...
%             = struct_to_array2D(coaOs.completeOutputImage);
%     end
    
% end
