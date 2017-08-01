function amaParameterStruct = setup_valid_ama_test_struct()
% construct a valid input structure for amaClass
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

maskDefinitions(1).offsets = struct(...
    'row', {-3    -3    -3    -3    -3    -3    -3    -2    -2},...
    'column', {-3    -2    -1     0     1     2     3    -5    -4});
maskDefinitions(2).offsets = struct(...
    'row', {-1    -1     0     0     0     0     0},...
    'column', {0     1    -3    -2    -1     0     1});
maskDefinitions(3).offsets = struct(...
    'row', {0     0     0     0     0     0     0     0     0},...
    'column', {-4    -3    -2    -1     0     1     2     3     4});
amaParameterStruct.maskDefinitions = maskDefinitions;

apertureStructs(1) = struct('keplerId', 11164256, ...
    'referenceRow', 481, 'referenceColumn', 882, 'badPixelCount', 0);
apertureStructs(2) = struct('keplerId', 11293088, ...
    'referenceRow', 69, 'referenceColumn', 52, 'badPixelCount', 0);
apertureStructs(3) = struct('keplerId', 11412201, ...
    'referenceRow', 1042, 'referenceColumn', 1111, 'badPixelCount', 0);
apertureStructs(1).offsets = struct(...
    'row', {-1    -1     0     0     0     0     1     1     1     1     2},...
    'column', {0     1    -1     0     1     2    -1     0     1     2     0});
apertureStructs(2).offsets = struct(...
    'row', {-1    -1    -1     0     0     0     1     1     1},...
    'column', {-1     0     1    -1     0     1    -1     0     1});
apertureStructs(3).offsets = struct(...
    'row', {-2    -1    -1     0     0     0     1     1},...
    'column', {1     0     1    -1     0     1     0     1});
amaParameterStruct.apertureStructs = apertureStructs;

amaParameterStruct.debugFlag = 0;

amaParameterStruct.moduleDescriptionStruct.nRowPix = 1024;
amaParameterStruct.moduleDescriptionStruct.nColPix = 1100;
amaParameterStruct.moduleDescriptionStruct.leadingBlack = 12;
amaParameterStruct.moduleDescriptionStruct.trailingBlack = 20;
amaParameterStruct.moduleDescriptionStruct.virtualSmear = 26;
amaParameterStruct.moduleDescriptionStruct.maskedSmear = 20;


