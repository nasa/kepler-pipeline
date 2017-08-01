%function groundTruthStruct = collect_tps_ground_truth_from_etem_runs(outputsStruct, etemRunDir)
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

etemRunDir = '/path/to/6.1-release-testing/etem/q2/etem/';


tpsDirStruct = dir('tps-matlab-*');
tpsDir = {tpsDirStruct.name}';

for iDir  = 1:length(tpsDir)

    eval(['cd ' tpsDir{iDir}]);
    pwd;
    load tps-inputs-0.mat;
    
    outputsStruct = read_TpsOutputs('tps-outputs-0.bin');


    keplerId = cat(1,outputsStruct.tpsResults.keplerId);
    keplerId = unique(keplerId);

    % associate an ETEM run with the target kepler ID
    nStars = length(keplerId);
    groundTruthStruct = repmat(struct('keplerId', [], 'module', [], 'output', [], 'etemRunDir', '', 'targetList', []),nStars,1);

    currentDir = pwd;

    eval(['cd ' etemRunDir]); % change into etem run dir

    diagnostics = cat(1,inputsStruct.tpsTargets.diagnostics);
    m = cat(1,diagnostics.ccdModule);
    o = cat(1,diagnostics.ccdOutput);
    mo = convert_from_module_output(m,o);


    if(length(unique(mo)) > 1)

        error('TPS:collectGroundTruth', ...
            'collect_tps_ground_truth_from_etem_runs: Need to look at mor ethan one etem run directory as there are multiple modouts in this unit of work ');
    end

    m = m(1);
    o = o(1);
    mo = mo(1);

    runDir = ['run_long_m' num2str(m(1)) 'o' num2str(o(1)) 's1'];


    runDirExistsFlag = exist(runDir, 'dir');


    eval(['cd ' runDir]);

    load scienceTargetList;

    etemRunKeplerId = cat(1, targetList.keplerId);
    backgroundBinaryTargetId = cat(1,backgroundBinaryList.targetKeplerId);

    for j=1:nStars

        crossIndex = find(etemRunKeplerId == keplerId(j));

        if(~isempty(crossIndex))
            j
            groundTruthStruct(j).keplerId =  keplerId(j);
            groundTruthStruct(j).module =  m;
            groundTruthStruct(j).output =  o;
            groundTruthStruct(j).etemRunDir =  runDir;
            groundTruthStruct(j).targetList =  targetList(crossIndex);

            [commonId, index1] = intersect(backgroundBinaryTargetId,keplerId(j));
            if(~isempty(commonId))
                groundTruthStruct(j).hasBgBinary  = true;
                groundTruthStruct(j).bgBinaryInfo  = backgroundBinaryList(index1);
            else
                groundTruthStruct(j).hasBgBinary  = false;
                groundTruthStruct(j).bgBinaryInfo  = [];

            end

        end


    end

    eval(['cd ' currentDir]); % change into etem run dir


    eval(['save ' ['groundTruthStruct_m' num2str(m) '_o' num2str(o) '_mo' num2str(mo) '.mat '] 'groundTruthStruct ', 'backgroundBinaryList ', 'targetScienceProperties']);
    cd ..

end

return
