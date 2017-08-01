function [prfSourceData prfRbData prfRbFastData, baselineData] = load_noise_test_data()
% script to analyze prf noise test results
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

arrayResolution = 200;

% fcConstants = convert_fc_constants_java_2_struct();
% load the baseline
load (['prfResultData_m14o4_source.mat']);
baselineData.object = prfClass(prfStructureVector.prfPolyStructure.polyCoeffStruct);
baselineData.prfArray = make_array(baselineData.object, arrayResolution);

prfSourceData = load_prfs('source', baselineData);
prfRbData = load_prfs('rb_xt', baselineData);
prfRbFastData = load_prfs('rb_xt_fast', baselineData);

function prfData = load_prfs(typeString, baselineData)
load (['prfResultData_m14o4_' typeString '.mat']);
prfData.object = prfClass(prfStructureVector.prfPolyStructure.polyCoeffStruct);

load (['prfResultData_m14o4_' typeString '_5.mat']);
for i=1:5
	prfData.component(i).object = prfClass(prfStructureVector(i).prfPolyStructure.polyCoeffStruct);
end

% compute variation within the 5 prfs, using the 5th (center) prf as the standard
arrayResolution = size(baselineData.prfArray, 1);
prfData.prfArray = make_array(prfData.object, arrayResolution);
prfData.diffArray = prfData.prfArray - baselineData.prfArray;
prfData.normDiff = norm(prfData.diffArray(:)/max(baselineData.prfArray(:)));
prfData.maxDiff = max(abs(prfData.diffArray(:)/max(baselineData.prfArray(:))));
for i=1:5
	prfData.component(i).prfArray = make_array(prfData.component(i).object, arrayResolution);
	prfData.component(i).diffArray = prfData.component(i).prfArray - baselineData.prfArray;
	prfData.component(i).normDiff = norm(prfData.component(i).diffArray(:)/max(baselineData.prfArray(:)));
	prfData.component(i).maxDiff = max(abs(prfData.component(i).diffArray(:)/max(baselineData.prfArray(:))));
end
