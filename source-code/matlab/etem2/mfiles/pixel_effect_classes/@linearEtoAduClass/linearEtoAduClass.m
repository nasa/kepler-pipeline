function linearEtoAObject = linearEtoAduClass(linearEtoAData, runParamsObject)
% function linearEtoAObject = linearEtoAClass(linearEtoAData, runParamsObject)
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

if isempty(linearEtoAData.spatialQeVariation)
    linearEtoAData.spatialQeVariation = 1;
end

if ~isempty(linearEtoAData.timeQeModulationData)
    classString = ...
        ['linearEtoAData.timeQeModulationObject = ' ...
        linearEtoAData.timeQeModulationData.className ...
        '(linearEtoAData.timeQeModulationData, runParamsObject);'];
    classString
    eval(classString);
    clear classString;
else
    linearEtoAData.timeQeModulationObject = [];
end

if linearEtoAData.maxElectronsPerExposure == -1
	nonlinearEtoAObject = nonlinearEtoAduClass(linearEtoAData.nonLinearEtoAData, runParamsObject);
	linearEtoAData.maxElectronsPerExposure = get(nonlinearEtoAObject, 'maxElectronsPerExposure');
	linearEtoAData.maxDnPerExposure = get(nonlinearEtoAObject, 'maxDnPerExposure');
else
	linearEtoAData.maxDnPerExposure = -1;
end

% if electronsPerADU = -1 get the linear gain data from the fc model
if linearEtoAData.electronsPerADU == -1
    module = get(runParamsObject, 'moduleNumber');
    output = get(runParamsObject, 'outputNumber');
    runStartMjd = datestr2mjd(get(runParamsObject, 'runStartDate'));
    runEndMjd = runStartMjd + get(runParamsObject, 'runDurationDays');
    gainObject = gainClass(retrieve_gain_model(runStartMjd, runEndMjd));
    linearEtoAData.electronsPerADU = get_gain(gainObject, runStartMjd, module, output);

    linearityObject = linearityClass(retrieve_linearity_model(runStartMjd, runEndMjd, module, output));
	if linearEtoAData.maxDnPerExposure == -1
    	linearEtoAData.maxDnPerExposure = double(get_max_domain(linearityObject, runStartMjd, module, output));
	end
else
	if linearEtoAData.maxDnPerExposure == -1
    	linearEtoAData.maxDnPerExposure = ...
        	linearEtoAData.maxElectronsPerExposure/linearEtoAData.electronsPerADU;
	end
end

disp(['maxElectronsPerExposure = ' num2str(linearEtoAData.maxElectronsPerExposure)]);
linearEtoAObject = class(linearEtoAData, 'linearEtoAduClass', runParamsObject);

