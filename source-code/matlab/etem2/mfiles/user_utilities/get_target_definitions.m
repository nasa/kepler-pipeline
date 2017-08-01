function targetDefinitionStruct = get_target_definitions(location, type)
% function targetDefinitions = get_target_definitions(location, type)
%
% the optional type argument may have the values 'targets' or 'target' or 'background' or 'reference'
%
% CAUTION CAUTION CAUTION
% .maskIndex is returned in 1-based indexing but .referenceRow and
% .referenceColumn are in 0-based indexing. Fix of this bug delayed to avoid
% breaking working code.
% CAUTION CAUTION CAUTION
%
% returns the target definitions for the specified etem2 run as a structure array with
% fields
%   targetDefinitionStruct().referenceRow (in 0 - based indexing!!!!)
%   targetDefinitionStruct().referenceColumn (in 0 - based indexing!!!!)
%   targetDefinitionStruct().maskIndex (in 1 - based indexing!!!!)
%
% all returned fields are 1-based
% implements FS-GS ICD 5.2.4.1
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

% get the file produced by every etem2 run that gives location and byte
% specifications
load([location filesep 'ssrFileMap.mat']);
ssrOutputDirectory = [location filesep ssrFileStruct.ssrOutputDirectory];
rowShift = ssrFileStruct.targetDefinitionSpec.rowShift;
colShift = ssrFileStruct.targetDefinitionSpec.colShift;

if nargin < 2
    type = 'targets';
end

switch type
    case 'targets'
        filename = ssrFileStruct.targetDefinitionFilename;
    case 'target'
        filename = ssrFileStruct.targetDefinitionFilename;
    case 'background'
        filename = ssrFileStruct.backgroundTargetDefinitionFilename;
    case 'reference'
        filename = ssrFileStruct.referencePixelTargetDefinitionFilename;
    otherwise
        error([type ' is not a legal value']);
end
    
fid = fopen([ssrOutputDirectory filesep filename], 'r', 'ieee-be');
if fid == -1
	targetDefinitionStruct = [];
    return;
end;

configWord = fread(fid, 1, 'uint32');

% mask off the first 14 bits to get the number of targets
nTargets = bitand(configWord, bin2dec('11111111111111'));

% read all the target definition bytes
targetDefBytes = fread(fid, nTargets, 'uint32');

fclose(fid);

% unpack the fields
targetDefinitionStruct = repmat(struct('referenceRow', 0, 'referenceColumn', 0, ...
    'maskIndex', 0), 1, nTargets);

for t=1:nTargets
    % maskId is the first 10 bits
    targetDefinitionStruct(t).maskIndex = bitand(targetDefBytes(t), bin2dec('1111111111')) + 1;
    % row is 11 bits at positions 10 - 20 (counting from 0)
    targetDefinitionStruct(t).referenceRow = bitand(bitshift(targetDefBytes(t), ...
        -rowShift), bin2dec('11111111111'));
    % column is 11 bits at positions 21-31 (counting from 0)
    targetDefinitionStruct(t).referenceColumn = bitand(bitshift(targetDefBytes(t), ...
        -colShift), bin2dec('11111111111'));
end
