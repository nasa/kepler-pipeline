
% validate_dithered_prf_attitude
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

[q1, q2, q3, q4] = textread('final_delta_quaternion_for_PRF_081120.txt', '%f%f%f%f');
mocQuaternion = [q1 q2 q3 q4];


clc;
cd '/path/to/smb/lv00/data/COMMISSIONING_RESULTS/KARF-C39'
dirNamesStruct = dir;
dirNames = {dirNamesStruct(3:end-1).name};
nPdqRuns = length(dirNames);

nCadences = 121;
pdqQuaternion = zeros(nCadences,4);
pdqDeltaRaDecRoll= zeros(nCadences,3);
pdqAttitudeRaDecRoll= zeros(nCadences,3);

pdqNominalAttitudeRaDecRoll= zeros(nCadences,3);


qCount = 0;


for j = 1:nPdqRuns

    eval(['cd ' dirNames{j}]);

    % go down one level

    innerDirStruct =  dir;
    pdqRunDirName = {innerDirStruct(3:end).name}; % there should be only one

    eval(['cd ' pdqRunDirName{1}]);

    load pdqOutputStruct;


    nCurrentQuaternion = length(pdqOutputStruct.attitudeAdjustments);

    for k = 1:nCurrentQuaternion

        qCount = qCount+1;
        pdqQuaternion(qCount,:) = pdqOutputStruct.attitudeAdjustments(k).quaternion(:);

        pdqDeltaRaDecRoll(qCount,1) = pdqOutputStruct.outputPdqTsData.deltaAttitudeRa.values(k);
        pdqDeltaRaDecRoll(qCount,2) = pdqOutputStruct.outputPdqTsData.deltaAttitudeDec.values(k);
        pdqDeltaRaDecRoll(qCount,3) = pdqOutputStruct.outputPdqTsData.deltaAttitudeRoll.values(k);


        pdqAttitudeRaDecRoll(qCount,1) = pdqOutputStruct.outputPdqTsData.attitudeSolutionRa.values(k);
        pdqAttitudeRaDecRoll(qCount,2) = pdqOutputStruct.outputPdqTsData.attitudeSolutionDec.values(k);
        pdqAttitudeRaDecRoll(qCount,3) = pdqOutputStruct.outputPdqTsData.attitudeSolutionRoll.values(k);
        
        pdqNominalAttitudeRaDecRoll(qCount,1) = pdqOutputStruct.attitudeSolutionUncertaintyStruct(k).nominalPointing(1);
        pdqNominalAttitudeRaDecRoll(qCount,2) = pdqOutputStruct.attitudeSolutionUncertaintyStruct(k).nominalPointing(2);
        pdqNominalAttitudeRaDecRoll(qCount,3) = pdqOutputStruct.attitudeSolutionUncertaintyStruct(k).nominalPointing(3);

    end

    cd ..
    cd ..



end


%%
% [q1, q2, q3, q4] = textread('final_delta_quaternion_for_PRF_081120.txt', '%f%f%f%f');
% mocQuaternion = [q1 q2 q3 q4];
%%
pdqQuaternion = pdqQuaternion(1:nCadences,:);
prfQ = mocQuaternion;
prfQ(:,1:3) = prfQ(:, 1:3)*-1;

scrambleIndex = zeros(nCadences,1);

for j=1:nCadences,

    [v , in] = min(sum( ((prfQ - repmat(pdqQuaternion(j,:),nCadences,1)).^2), 2));
    scrambleIndex(j) = in;

end

%mocQuaternion(scrambleIndex,:)


% prfOldQ = mocOldQuaternion;
% prfOldQ(:,1:3) = prfOldQ(:, 1:3)*-1;
%
% scrambleIndex2 = zeros(nCadences,1);
%
% for j=1:nCadences,
%
%     [v , in] = min(sum( ((prfOldQ - repmat(pdqQuaternion(j,:),nCadences,1)).^2), 2));
%     scrambleIndex2(j) = in;
%
% end
% mocOldQuaternion(scrambleIndex2,:)
%

