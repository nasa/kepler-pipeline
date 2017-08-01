% collect_keplerId_from_pa_runs.m
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


paDirStruct = dir('pa-matlab-*');
paDir = {paDirStruct.name}';

paInputMatStruct = repmat(struct('paInputMatFile', '', 'startCount', [], 'endCount', []), 12,1);

paKeplerIdStruct = repmat(struct('keplerId', zeros(5000,1), 'ccdModule', -1, 'ccdOutput', -1, 'paRunDir', '', 'paInputMatStruct', paInputMatStruct), 84,1);

for iDir  = 1:length(paDir)
    
    fprintf('processing %s\n', paDir{iDir});

    eval(['cd ' paDir{iDir}]);

    starCount = 0;

    % many pa-inputs-x.mat
    paInputsDirStruct = dir('pa-inputs*.mat');

    paInputMatList = {paInputsDirStruct.name}';

    for iMatFile = 1:length(paInputMatList)

        eval(['load ' paInputMatList{iMatFile}]);
        
        fprintf('loading %s\n', paInputMatList{iMatFile});
        
        ccdModule = inputsStruct.ccdModule;
        ccdOutput = inputsStruct.ccdOutput;
        
        modOut = convert_from_module_output(ccdModule, ccdOutput);
        
        paKeplerIdStruct(modOut).ccdModule = ccdModule;
        paKeplerIdStruct(modOut).ccdOutput = ccdOutput;
        paKeplerIdStruct(modOut).paRunDir = paDir{iDir};

        paKeplerIdStruct(modOut).paInputMatStruct(iMatFile).paInputMatFile = paInputMatList{iMatFile};
        
        if(~isempty(inputsStruct.targetStarDataStruct))

            
            
            keplerId = cat(1,inputsStruct.targetStarDataStruct.keplerId);
            
            nStars = length(keplerId);
            
            paKeplerIdStruct(modOut).keplerId(starCount+1: starCount+nStars) = keplerId;
            
            paKeplerIdStruct(modOut).paInputMatStruct(iMatFile).startCount = starCount+1;
            paKeplerIdStruct(modOut).paInputMatStruct(iMatFile).endCount = starCount+nStars;
            
            starCount = starCount+nStars;
            

        end
    end
    paKeplerIdStruct(modOut).keplerId(starCount+1: end) = [];
    
    cd ..;

end