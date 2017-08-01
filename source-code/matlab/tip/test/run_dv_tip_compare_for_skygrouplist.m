function run_dv_tip_compare_for_skygrouplist( dvRootPath, tipRootPath, skygrouplist, produceMapStruct, inputStruct )
% function run_dv_tip_compare_for_skygrouplist( dvRootPath, tipRootPath, skygrouplist, produceMapStruct, inputStruct )
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


if ~exist([dvRootPath,'task-file-map.mat'],'file') || produceMapStruct
    disp('Producing DV task file map ...');
    mapOut = produce_matlab_taskfile_map( dvRootPath, 'dv' );
    save([dvRootPath,'task-file-map.mat'],'mapOut');
else
    disp('Loading DV task file map ...');
    disp([dvRootPath,'task-file-map.mat']);
    load([dvRootPath,'task-file-map.mat']);        
end

for skygroup = rowvec(skygrouplist)
    
    % assume there is at most one subdirectory under root for each skygroup
    idx = find([mapOut.skyGroupId]==skygroup);
    
    if ~isempty(idx)
        
        % build dv pathname list
        dvPathName = cell(length(idx),1);
        for i = 1:length(idx)
            dvPathName{i} = [mapOut(idx(i)).taskFileFullPath,'dvOutputMatrixSkygroup.mat'];
        end
        inputStruct.dvPathName = {dvPathName};
        
        % build tip pathname - try both zero padded and unpadded filename
        D = dir([tipRootPath,'*-',num2str(skygroup,'%02i'),'_tip.txt']);
        if isempty(D)
            D = dir([tipRootPath,'*-',num2str(skygroup),'_tip.txt']);
        end
        inputStruct.tipPathName = [tipRootPath,D.name];
        
        % build expected mes pathname
        if exist(['expected-mes-for-skygroup-',num2str(skygroup,'%02i'),'.mat'],'file')
            % use padded filename if it exists
            inputStruct.expectedMesPathName = ['expected-mes-for-skygroup-',num2str(skygroup,'%02i'),'.mat'];
        else
            % otherwise use unpadded
            inputStruct.expectedMesPathName = ['expected-mes-for-skygroup-',num2str(skygroup),'.mat'];
        end
        
        % don't save figs
        inputStruct.saveFiguresAsJpegs = false;
        
        % compare
        [tipData, dvData] = compare_tip_and_dv_output( inputStruct ); %#ok<NASGU,ASGLU>
        
        % save output for skygroup
        disp(['Saving dv-tip-compare-skygroup-',num2str(skygroup,'%02i'),'.mat .... ']);
        save(['dv-tip-compare-skygroup-',num2str(skygroup,'%02i'),'.mat'], 'dvData', 'tipData', 'inputStruct');
        close all
    end
end

