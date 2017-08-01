function [inputsStruct outputsStruct] = mat_to_bin(moduleName, matFileDir, matFileId)
% function [inputsStruct outputsStruct] = mat_to_bin(moduleName, matFileDir, matFileId)
%
% This function converts the specified input and output .mat files
% to .bin files.  This is useful in cases where bin files were not copied, and the bin 
% files were deleted from the worker machines, and the infrastructure validation tools 
% must be run.
%
% This function must be run using the same branch & revision of the code
% that was used to generate the .mat files.
%
% The matFileDir and matFieldId arguments are optional. Defaults are:
%  matFileDir: '.'
%  matFileId: '0'
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

if(nargin < 1)
    error('USAGE: mat_to_bin(moduleName, [matFileDir, matFileId])');
end

dir = '.';
id = '0';

if(nargin > 1)
    dir = matFileDir;
end

if(nargin > 2)
    id = matFileId;
end

if(~exist(dir, 'dir'))
    error(['Specified directory does not exist: ' dir]);
end

lowerCaseModuleName = lower(moduleName);
camelCaseModuleName = camelCase(moduleName);

%%
% Inputs

inputsMatFileName = [ dir filesep lowerCaseModuleName '-inputs-' id '.mat' ];
inputsReadExpr = [ 'inputsStruct = load(inputsMatFileName);' ];

disp([ 'Reading inputs file: ' inputsReadExpr ]);

if(exist(inputsMatFileName,'file'))
    eval(inputsReadExpr);

    inputsBinFileName = [ dir filesep lowerCaseModuleName '-inputs-' id '.bin' ];
    disp([ 'Saving inputs file as a .bin: ' inputsBinFileName]);
    
    inputsWriteExpr = [ 'write_' camelCaseModuleName 'Inputs(inputsBinFileName, inputsStruct.inputsStruct);' ];
    eval(inputsWriteExpr);
else
    warning('PI:NoMatFileFound', ['No .mat file found: ' inputsMatFileName]); 
end

%%
% Outputs

outputsMatFileName = [ dir filesep lowerCaseModuleName '-outputs-' id '.mat' ];
outputsReadExpr = [ 'outputsStruct = load(outputsMatFileName);' ];

disp([ 'Reading outputs file: ' outputsReadExpr ]);

if(exist(outputsMatFileName,'file'))
    eval(outputsReadExpr);
    
    outputsBinFileName = [ dir filesep lowerCaseModuleName '-outputs-' id '.bin' ];
    disp([ 'Saving outputs file as a .bin: ' outputsBinFileName]);

    outputsWriteExpr = [ 'write_' camelCaseModuleName 'Outputs(outputsBinFileName, outputsStruct.outputsStruct);' ];
    eval(outputsWriteExpr);
else
    warning('PI:NoMatFileFound', ['No .mat file found: ' outputsMatFileName]); 
end

return;

function camel = camelCase(original)
camel = original;
for i = 1:length(camel)
    if(i == 1)
        camel(i) = upper(camel(i));
    else
        camel(i) = lower(camel(i));
    end
end

