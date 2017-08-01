% locate_pdc_run_for_tps_target.m
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

% isPlanet = cat(1,tpsOutputStructHiRes.tpsResults.isPlanetACandidate);
% planetIndex = find(isPlanet);
% keplerId = cat(1,tpsOutputStructHiRes.tpsResults.keplerId);
% %keplerId = keplerId(planetIndex);
% keplerId = unique(keplerId);

% associate an ETEM run with the target kepler ID
clc;
% nStarsWithPlanets = length(keplerId);
% groundTruthStruct = repmat(struct('keplerId', [], 'module', [], 'output', [], 'etemRunDir', '', 'targetList', []),nStarsWithPlanets,1);

pdcDirStruct = dir('pdc-matlab-*');
pdcDir = {pdcDirStruct.name}';


pdcKeplerIdStruct = repmat(struct('keplerId', [], 'ccdModule', -1, 'ccdOutput', -1, 'pdcRunDir', ''), 84,1);

for iDir  = 1:length(pdcDir)

    eval(['cd ' pdcDir{iDir}]);
    load pdc-inputs-0.mat;
    
    ccdModule = inputsStruct.ccdModule;
    ccdOutput = inputsStruct.ccdOutput;

    modOut = convert_from_module_output(ccdModule, ccdOutput);

    pdcKeplerIdStruct(modOut).ccdModule = ccdModule;
    pdcKeplerIdStruct(modOut).ccdOutput = ccdOutput;
    pdcKeplerIdStruct(modOut).pdcRunDir = pdcDir{iDir};
    
    
    keplerId = cat(1,inputsStruct.targetDataStruct.keplerId);
    pdcKeplerIdStruct(modOut).keplerId = keplerId;
    
    cd ..;
    
    
end

%reqId = 7583208;for j=1:84; if(~isempty(intersect(pdcKeplerIdStruct(j).keplerId, reqId))), disp(j), break, end;end