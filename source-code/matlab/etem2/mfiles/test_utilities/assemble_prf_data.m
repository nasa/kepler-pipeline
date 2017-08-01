% script to assemble single-cadence PRF data runs into a single dataset
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

channelStr = 'm14o4';
caseStr = '_rb_xt';
% prfStr = 'z5f5F1';
% inputLocation = ['output/prf_data_' channelStr '_' prfStr];
% outputLocation = ['output/prfData/assembled_' channelStr '_' prfStr];
% inputDirectory = [inputLocation '/run1/run_long_' channelStr 's1'];
% outputDirectory = [outputLocation '/run_long_' channelStr 's1'];

inputLocation = ['output/prf_noise_study/prf_data_' channelStr caseStr];
outputLocation = ['output/prf_noise_study/assembled_' channelStr caseStr];
inputDirectory = [inputLocation '/run1/run_long_' channelStr 's1'];
outputDirectory = [outputLocation '/run_long_' channelStr 's1'];

nCadences = 121;
% load ssrFileStruct, which has various filenames
load([inputDirectory filesep 'ssrFileMap.mat']);

ssrOutputDirectory = [outputDirectory filesep ssrFileStruct.ssrOutputDirectory];
if ~exist(outputDirectory, 'dir')
    mkdir(outputDirectory);
end
if ~exist(ssrOutputDirectory, 'dir')
    mkdir(ssrOutputDirectory);
end
outScienceDataFilename = [ssrOutputDirectory filesep ssrFileStruct.scienceCadenceFilename];
outQuantizedDataFilename = [ssrOutputDirectory filesep ssrFileStruct.quantizedCadenceFilename];
outScienceDataNoCrFilename = [ssrOutputDirectory filesep ssrFileStruct.scienceCadenceNoCrFilename];
outQuantizedDataNoCrFilename = [ssrOutputDirectory filesep ssrFileStruct.quantizedCadenceNoCrFilename];

% copy the prfOffset file
copyfile([inputLocation filesep 'prfOffsetPattern.mat'], outputLocation);

% copy the prototype directory
copyfile([inputDirectory filesep '*'], outputDirectory);

% prepare the motion basis data
load([inputDirectory filesep 'motionBasis.mat']);
assembledMotionBasis = motionBasis1;
for i=1:size(motionGridRow, 1)
    for j=1:size(motionGridCol, 2)
        assembledMotionBasis(i,j).designMatrix = [];
    end
end
assembledMotionGridRow = motionGridRow;
assembledMotionGridCol = motionGridCol;

% assemble the science data
scienceData = [];
quantizedData = [];
scienceNoCrData = [];
quantizedNoCrData = [];
for r=1:nCadences
    location = [inputLocation '/run' num2str(r) '/run_long_' channelStr 's1'];
    ssrInputDirectory = [location filesep ssrFileStruct.ssrOutputDirectory];
    inScienceDataFilename = [ssrInputDirectory filesep ssrFileStruct.scienceCadenceFilename];
    inQuantizedDataFilename = [ssrInputDirectory filesep ssrFileStruct.quantizedCadenceFilename];
    inScienceDataNoCrFilename = [ssrInputDirectory filesep ssrFileStruct.scienceCadenceNoCrFilename];
    inQuantizedDataNoCrFilename = [ssrInputDirectory filesep ssrFileStruct.quantizedCadenceNoCrFilename];
    
    % build up the total science data
    fid = fopen(inScienceDataFilename, 'r', 'ieee-be');
    scienceData = [scienceData fread(fid, 'float32')];
    fclose(fid);
    fid = fopen(inScienceDataNoCrFilename, 'r', 'ieee-be');
    scienceNoCrData = [scienceNoCrData fread(fid, 'float32')];
    fclose(fid);
    fid = fopen(inQuantizedDataFilename, 'r', 'ieee-be');
    quantizedData = [quantizedData fread(fid, 'uint16')];
    fclose(fid);
    fid = fopen(inQuantizedDataNoCrFilename, 'r', 'ieee-be');
    quantizedNoCrData = [quantizedNoCrData fread(fid, 'uint16')];
    fclose(fid);
    
    load([location filesep 'motionBasis.mat']);
    for i=1:size(motionGridRow, 1)
        for j=1:size(motionGridCol, 2)
            assembledMotionBasis(i,j).designMatrix = ...
                [assembledMotionBasis(i,j).designMatrix; motionBasis1(i,j).designMatrix];
        end
    end
end

fid = fopen(outScienceDataFilename, 'w', 'ieee-be');
fwrite(fid, scienceData, 'float32');
fclose(fid);
fid = fopen(outScienceDataNoCrFilename, 'w', 'ieee-be');
fwrite(fid, scienceNoCrData, 'float32');
fclose(fid);
fid = fopen(outQuantizedDataFilename, 'w', 'ieee-be');
fwrite(fid, quantizedData, 'uint16');
fclose(fid);
fid = fopen(outQuantizedDataNoCrFilename, 'w', 'ieee-be');
fwrite(fid, quantizedNoCrData, 'uint16');
fclose(fid);

motionBasis1 = assembledMotionBasis;
motionGridRow = assembledMotionGridRow;
motionGridCol = assembledMotionGridCol;
save([outputDirectory filesep 'motionBasis.mat'], 'motionBasis1', 'motionGridRow', 'motionGridCol');
