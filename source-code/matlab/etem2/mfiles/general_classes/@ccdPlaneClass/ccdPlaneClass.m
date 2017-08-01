function ccdPlaneObject = ccdPlaneClass(ccdPlaneData, runParamsObject)

% instantiate the psf class specified in the psfObjectData field
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
nPsfs = length(ccdPlaneData.psfObjectData);
for p=1:nPsfs
	classString = ...
    	['ccdPlaneData.psfObject(p) = ' ...
    	ccdPlaneData.psfObjectData(p).className ...
    	'(ccdPlaneData.psfObjectData(p), runParamsObject);'];
	classString
	eval(classString);
	clear classString;
end
ccdPlaneData.psfObjectData = [];

% instantiate the motion class list specified in the motionDataList field
if ~isempty(ccdPlaneData.motionDataList)
    for i=1:length(ccdPlaneData.motionDataList)
        classString = ...
            ['ccdPlaneData.motionObjectList(i) = ' ...
            ccdPlaneData.motionDataList(i).className ...
            '(ccdPlaneData.motionDataList(i), runParamsObject);'];
        classString
        eval(classString);
        clear classString;
    end
else
    ccdPlaneData.motionObjectList = [];
end
ccdPlaneData.motionDataList = [];

% instantiate the star selection class list specified in the
% starSelectorData field
classString = ...
    ['ccdPlaneData.starSelectorObject = ' ...
    ccdPlaneData.starSelectorData.className ...
    '(ccdPlaneData.starSelectorData, runParamsObject);'];
classString
eval(classString);
clear classString;
ccdPlaneData.starSelectorData = [];

ccdPlaneData.psf = [];
% ccdPlaneData.prf = [];
ccdPlaneData.motionBasis = [];
% ccdPlaneData.psfMeshCols = [];
% ccdPlaneData.psfMeshRows = [];
ccdPlaneData.prfDesignMatrix = [];
ccdPlaneData.prfSolutionMatrix = [];
% ccdPlaneData.prfPolyCoeffs = [];
ccdPlaneData.catalogData = [];
ccdPlaneData.targetList = [];
ccdPlaneData.targetStruct = [];
ccdPlaneData.allTargetImageIndices = [];
ccdPlaneData.targetImageIndices = [];
ccdPlaneData.selectedKicIdIndex = [];

% create the various output filenames
outputDirectory = get(runParamsObject, 'outputDirectory');
ccdPlaneData.prfPolyFilename = [outputDirectory filesep 'prfPoly.mat'];
ccdPlaneData.motionBasisFilename = [outputDirectory filesep 'motionBasis.mat'];
ccdPlaneData.ccdPlaneImageFilename = [outputDirectory filesep 'ccdPlaneImage.mat'];
ccdPlaneData.visiblePixelPolyFilename = [outputDirectory filesep ...
    'visiblePixelPoly' num2str(ccdPlaneData.planeNumber) '.dat'];
ccdPlaneData.ccdPixelPolyFilename = [outputDirectory filesep ...
    'ccdPixelPoly' num2str(ccdPlaneData.planeNumber) '.dat'];
ccdPlaneData.ccdPixelEffectPolyFilename = [outputDirectory filesep ...
    'ccdPixelEffectPoly' num2str(ccdPlaneData.planeNumber) '.dat'];
ccdPlaneData.ccdTimeSeriesFilename = [outputDirectory filesep ...
    'ccdTimeSeries' num2str(ccdPlaneData.planeNumber) '.dat'];
ccdPlaneData.targetPolyFilename = [outputDirectory filesep ...
    'targetPoly' num2str(ccdPlaneData.planeNumber) '.dat'];

ccdPlaneObject = class(ccdPlaneData, 'ccdPlaneClass', runParamsObject);
