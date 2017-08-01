function [vsmearRanges msmearRanges] = extract_smear_ranges_from_coa_images(dirLocation)
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

if(~exist('dirLocation', 'var'))
if ispc
    dirLocation =  '\path\to\java\tad\coa-outputs-all-mod-outs-with-image\';

else
    dirLocation =  '/path/to/java/tad/coa-outputs-all-mod-outs-with-image/';
end
end
fileNamesStruct = dir([dirLocation 'coa-outputs*.bin']);
fileNames = {fileNamesStruct.name}';

nModOuts = length(fileNames);

vsmearRanges = zeros(84,2);
msmearRanges = zeros(84,2);


% note - this set of coa images did not have black added to them 
% but future runs will have black 2d added and subject to fixed offset and
% mean black table related changes

for j = 1:nModOuts

    j
    
    % extract the module, output info from filename
    
    % kind of hardcoded extraction
    currentFileName = fileNames{j};
    
    ccdOutput = str2double(currentFileName(end-4));
    ccdModule = str2double(currentFileName(end-7:end-6));
    
    moduleIndex = convert_from_module_output(ccdModule,ccdOutput);

    
    coaImageFileName = [dirLocation fileNames{j}];
    s = read_CoaOutputs(coaImageFileName);
    outputImage = struct_to_array2D(s.completeOutputImage);
    imagesc(outputImage);
    
    
    % the units are in photo electrons
    % to convert to DN, take into account the nonlinearity of the readout
    % amplifiers and the gain model 
    % talk to Jon/ Doug
    msmearRanges(moduleIndex,1) = max(max(outputImage(1:20, 13:1112)));
    msmearRanges(moduleIndex,2) = min(min(outputImage(1:20, 13:1112)));
    
    
    vsmearRanges(moduleIndex,1) = max(max(outputImage(1045:1070, 13:1112)));
    vsmearRanges(moduleIndex,2) = min(min(outputImage(1045:1070, 13:1112)));
    
    
   [msmearRanges(moduleIndex,1) msmearRanges(moduleIndex,2)]
    
    
   [vsmearRanges(moduleIndex,1)  vsmearRanges(moduleIndex,2)]
    
    
end

return
