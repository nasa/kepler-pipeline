function [discontinuityAnalysisStructArray, nDiscontinuitiesByModOut, ...
nTargetsWithDiscontinuitiesByModOut, nTargetsWithUncorrectedDiscontinuitiesByModOut] = ...
collect_discontinuity_results(startCadenceNumbers)

% Collect the discontinuity results for all available module outputs. The
% startCadenceNumbers are optional, to be specified if there are task files
% for more than one unit of work in the given quarter.
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

N_MOD_OUTS = 84;

if ~exist('startCadenceNumbers', 'var')
    startCadenceNumbers = [];
end

nUow = max(1, length(startCadenceNumbers));

discontinuityAnalysisStructArray = repmat(struct( ...
    'taskDir', '', ...
    'ccdModule', 0, ...
    'ccdOutput', 0, ...
    'modOutIndex', 0, ...
    'nTargets', 1, ...
    'discontinuities', [], ...
    'nDiscontinuities', 0, ...
    'nTargetsWithDiscontinuities', 0, ...
    'discontinuityTargetList', [], ...
    'nTargetsWithUncorrectedDiscontinuities', 0, ...
    'uncorrectedDiscontinuityTargetList', []), [nUow, N_MOD_OUTS]);

d = dir('pdc-matlab-*');
for name = {d.name}
    disp(char(name));
    cd(char(name))
    [discontinuityAnalysisStruct, uowIndex] = ...
        collect_discontinuity_results_by_mod_out(char(name), startCadenceNumbers);
    if ~isempty(discontinuityAnalysisStruct)
        index = discontinuityAnalysisStruct.modOutIndex;
        discontinuityAnalysisStructArray(uowIndex, index) = ...
            discontinuityAnalysisStruct;
    end
    cd ..
end % for name

% nDiscontinuitiesByModOut = ...
%     [discontinuityAnalysisStructArray.nDiscontinuities]';
% nTargetsWithDiscontinuitiesByModOut = ...
%     [discontinuityAnalysisStructArray.nTargetsWithDiscontinuities]';
% nTargetsWithUncorrectedDiscontinuitiesByModOut = ...
%     [discontinuityAnalysisStructArray.nTargetsWithUncorrectedDiscontinuities]';
% 
% hold off
% plot(nDiscontinuitiesByModOut, '.-b')
% title('Number of Discontinuities By Module Output')
% pause
% 
% plot(nTargetsWithDiscontinuitiesByModOut, '.-b')
% title('Number of Targets with Discontinuities By Module Output')
% pause
% 
% plot(nTargetsWithUncorrectedDiscontinuitiesByModOut, '.-b')
% title('Number of Targets with Uncorrected Discontinuities By Module Output')

nTargetsByModOut = ...
    reshape([discontinuityAnalysisStructArray.nTargets], nUow, N_MOD_OUTS)';
nDiscontinuitiesByModOut = ...
    reshape([discontinuityAnalysisStructArray.nDiscontinuities], nUow, N_MOD_OUTS)';
nTargetsWithDiscontinuitiesByModOut = ...
    reshape([discontinuityAnalysisStructArray.nTargetsWithDiscontinuities], nUow, N_MOD_OUTS)';
nTargetsWithUncorrectedDiscontinuitiesByModOut = ...
    reshape([discontinuityAnalysisStructArray.nTargetsWithUncorrectedDiscontinuities], nUow, N_MOD_OUTS)';

hold off
for i = 1 : nUow
    subplot(nUow, 1, i)
    plot(nTargetsWithDiscontinuitiesByModOut(:,i) ./ nTargetsByModOut(:,i) , '.-b')
    title(['Fraction of Targets with Discontinuities By Module Output -- UOW', num2str(i)])
    xlabel('Channel')
    ylabel('Fraction')
end

return
