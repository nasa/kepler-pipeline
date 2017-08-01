function moduleStruct = dg_gang_downsampled_outputs(downSampledStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% moduleStruct = dg_gang_downsampled_outputs(downSampledStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% 
% dg_gang_downsampled_outputs takes the downSampledStruct of 84 star images
% and orients outputs so that pixel 0,0 is in the outer corner, then
% inserts the appropriate downsampled gaps for the CCD gap (78 pix), and 
% maskedSmear (20 pix).
%
% Finally, it orients them according to Figure 5.2.3-3 of the GS-FS ICD
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% INPUT: 
%           downSampledStruct, a struct with 21 entries with the following fields-
%
%               module : [int] CCD module number
%                output: [int] CCD output number
%             binFactor: [int] the default or user specified binFactor
%  binnedStarImage: [array single]: downsampled star image
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% OUTPUTS: 
%          moduleStruct, a struct with 21 entries with the following fields-
%
%               module: [int] module number
%              fpCoord: vector[z y] focal plane coordintes of the bottom 
%                       left output at pixel 0,12 of the module
%            binFactor: [int] bin factor of the input binnedStarImage
%          moduleImage: [single] image with 4 outputs put together in the
%               correct orientation with gaps filled in and correct
%               rotation
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% preallocate output structure
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
moduleStruct = repmat(struct('module', 0, 'output', 0, 'fpCoord', [0 0],...
    'binFactor', 0, 'moduleImage',[],...
    'outputLabel',[], 'moduleLabel', []), 1,21);

% determine bin factor of the input image
[binRow binCol] = size(downSampledStruct(1).binnedStarImage);
binFactor = floor(1024/binRow); % actual rows = 1024

% size of CCD gap between outputs 1/2 and 3/4 = 78 pixels, bin these
binGap = floor(78/binFactor);


% actual size of masked smear = 20  pix 
binMaskSmear = floor(20/binFactor);

% determine row and col size of ganged module using module 2 - output 1 as a model
totRow = 2*binMaskSmear + binGap + 2*binRow;
totCol=  2*binCol;

% preallocate and make into single
gangedModule = single(NaN(totRow, totCol));
outputLabel = uint8(zeros(totRow, totCol));


 nMod = 1;
 for mod = [2:4, 6:20, 22:24]

     for out = 1:4

         channel = convert_from_module_output(mod, out);
         image = downSampledStruct(channel).binnedStarImage;
         output = downSampledStruct(channel).output;
         module = downSampledStruct(channel).module;
         switch output
             case  1
                 flippedImage = image;
                 gangedModule(1 + binMaskSmear: binRow + binMaskSmear, 1:binCol) = flippedImage;
                 outputLabel(1 + binMaskSmear: binRow + binMaskSmear, 1:binCol) = output;
         
             case 2
                 flippedImage = fliplr(image);
                 gangedModule(1 + binMaskSmear: binRow + binMaskSmear, 1+binCol:end) = flippedImage;
                 outputLabel(1 + binMaskSmear: binRow + binMaskSmear, 1+binCol:end) = output;
             case  3
                 flippedImage  = flipud(fliplr(image));
                 gangedModule( 1+ binRow + binMaskSmear+binGap:end-binMaskSmear, 1+binCol:end) = flippedImage;
                 outputLabel( 1+ binRow + binMaskSmear+binGap:end-binMaskSmear, 1+binCol:end) = output;
             case 4
                 flippedImage = flipud(image);
                 gangedModule( 1+ binRow + binMaskSmear+binGap:end-binMaskSmear, 1:binCol) = flippedImage;
                 outputLabel( 1+ binRow + binMaskSmear+binGap:end-binMaskSmear, 1:binCol) = output;
         end
     end
     
     
     
 % below is the orientation of the modules in the focal plane:   
 modOrientation = [0, 0, 0 ,...
     3, 0, 0, 1, 1,...
     3, 3, 3, 1, 1,...
     3, 3, 2, 2, 1,...
     2, 2, 2];
 
% interger by which to multiply 90 deg rotation
rot = modOrientation(nMod);

% rotate the module
rotatedModule = rot90(gangedModule, rot);
rotatedOuputLabel =rot90(outputLabel, rot);
[ rot_row rot_col] =size(rotatedOuputLabel);
rotatedModuleLabel = uint8(mod*ones(rot_row, rot_col));


% bottom left output number is rot + 1
bottomLeftOutput = rot + 1;

% use PT's fp mapper
[fpZ, fpY] = morc_to_focal_plane_coords(module, bottomLeftOutput, 0, 12, 'one-based');

% put info into structure
moduleStruct(nMod).moduleImage = rotatedModule;
moduleStruct(nMod).module = module;
moduleStruct(nMod).output =  output;
moduleStruct(nMod).fpCoord = [fpZ, fpY];
moduleStruct(nMod).binFactor= binFactor;
moduleStruct(nMod).outputLabel = rotatedOuputLabel;
moduleStruct(nMod).moduleLabel = rotatedModuleLabel;

% increment nMod
nMod = nMod +1;
    
end