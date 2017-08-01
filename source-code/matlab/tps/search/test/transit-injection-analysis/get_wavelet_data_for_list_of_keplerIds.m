% get_wavelet_data_for_list_of_keplerIds.m
% Given an input list of keplerIds, for each target, it creates a local folder KIC-xxxxxx 
% (in a local top directory specified by the user), then copies the whitener results file into this local folder. 
% The whitener results file is called tps-wavelet-object.mat, and it contains 
% the wavelet coefficient timeseries for each scale for each quarter in a struct called outputStruct.waveletStructArray.waveletObject. 
%==========================================================================
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
clear all

% Base dir
baseDir = '/path/to/matlab/tps/search/test/transit-injection-analysis/';

% Archive wavelet coefficients from taskfile dir
archiveWaveletResults = logical(input('Archive wavelet coefficients from taskfile directory-- 0 or 1? '));

% Directory containing the generate-tps-inputs.mat file
% For each keplerId in keplerIdList -- to get the associated subtask directory
% containing the wavelet data results: subtract one from the corresponding index. 
% matFileDir = '/path/to/ksoc-5052-tps-inputs-whitener-objects/';
matFileDir = '/path/to/ksoc-5052-tps-inputs-whitener-objects/';

% Directory containing all the temp_*.tar files.
nfsWhitenerObjectsDir = '/path/to/ksoc-5052-tps-inputs-whitener-objects/tps-matlab-2016180/tps-matlab-2016180-0/';

% Choose data set to process
runId = input('runId -- A for KSOC-5007 shallow test run 1, B for KSOC-5006 all target shallow run part1: ','s');
switch runId
    
    case 'A'
        
        % KSOC-5007 shallow test run 1
        injectionStructFile = 'tps-injection-struct-2016159-0.mat';
        
        % Local directory for storing wavelet coefficient data
        localWaveletCoeffDir = strcat('/codesaver/work/transit_injection/wavelet_coefficients/','KSOC-5007/');
        if(~exist(localWaveletCoeffDir,'dir'))
            mkdir(localWaveletCoeffDir)
        end
        
        % Results directory for KSOC-5007 test run with 98 stars
        nfsDir = '/path/to/transitInjections/KSOC-5007/Shallow_FLTI_Test_1_with_100_stars/tps-matlab-2016159/tps-matlab-2016159-0/';
        
    case 'B'
        
        % KSOC-5006 All target shallow FLTI part 1
        injectionStructFile = 'tps-injection-struct.mat' ; 
        
        % Local directory for storing wavelet coefficient data
        localWaveletCoeffDir = '/path/to/FLTI/KSOC-5006-shallow-full-run-part1/wavelet_coefficients/';
        if(~exist(localWaveletCoeffDir,'dir'))
            mkdir(localWaveletCoeffDir)
        end
        
        % Results directory for KSOC-5006 shallow run part 1
        nfsDir = '/path/to/transitInjections/KSOC-5006/Full_Shallow_FLTI_Run_part_1_7200_stars/tps-matlab-2016190/';
        
 end % switch

        
% Get a unique list of keplerIds
% Load the injection struct
load(strcat(nfsDir,injectionStructFile))
selectedKeplerIdList = unique(tpsInjectionStruct.keplerId);

% Load the generate-tps-inputs.mat file
load(strcat(matFileDir,'generate-tps-inputs.mat'))

% Match the selected keplerIds
[~, ~, indsB] = intersect(selectedKeplerIdList, keplerIdList);

% Determine the corresponding subtask directories
% Subtract 1 from index of each selected target to convert to zero-based
% indexing of st-* directories
stNumbers = indsB - 1;

% Now determine which archive contains the wavelet coeffs for each selected
% target

% Bruce Clarke's final run to produce wavelet coefficients (KSOC-5060)
% extracted all the data from tar files, so don't need the
% code to map stNumbers to .tar archive for each target (below).
% Tar archives are organized as follows:
% temp_1.tar st-0 to st-999
% temp_2.tar st-1000 to st-1999, etc

% Each st- directory has tps-inputs-0.mat and tps-wavelet-object.mat
% tarIndex = ceil(stNumbers/1000);
% Add correction: if stNumbers is a nonzero multiple of 1000, increment the tarIndex by 1
% selectIdx = mod(stNumbers,1000) == 0 & stNumbers>0;
% tarIndex(selectIdx) = tarIndex(selectIdx) + 1;

waveletDestinationPath = cell(length(selectedKeplerIdList),1);
if(archiveWaveletResults)
    for iTarget = 1:length(selectedKeplerIdList)
        
        % Progress
        if(mod(iTarget,10)==0)
            fprintf('Copying wavelet data for target %d of %d to local archive ...\n',iTarget,length(selectedKeplerIdList));
        end
        
        % Create destination directory for wavelet file
        % waveletDestinationDir = strcat(localWaveletCoeffDir,['st-',num2str(stNumbers(iTarget))],'/');
        waveletDestinationDir = strcat(localWaveletCoeffDir,['KIC-',num2str(selectedKeplerIdList(iTarget))],'/');
        if(~exist(waveletDestinationDir,'dir'))
            mkdir(waveletDestinationDir);
        end
        
        % Source file path
        % Name of the wavelet coefficients file for this target, relative to the
        % localWaveletCoeffDir
        waveletSourceFileName = strcat(['st-',num2str(stNumbers(iTarget))],'/tps-wavelet-object.mat');
        waveletSourcePath = strcat(nfsWhitenerObjectsDir,waveletSourceFileName);
        
        % Destination file path
        waveletDestinationPath{iTarget} = strcat(waveletDestinationDir,'tps-wavelet-object.mat');
        % Name of the tar archive for this target
        % tarArchive = strcat(nfsWhitenerObjectsDir,'temp_',num2str(tarIndex(iTarget)),'.tar');
        % tarArchive = strcat(nfsWhitenerObjectsDir,'st-',num2str(stNumbers(iTarget)));
        
        % Build and execute the unix command to extract the wavelet file into the destination directory
        % command = sprintf('tar xvf  %s -C %s %s',tarArchive,localWaveletCoeffDir,waveletSourceFileName);
        % [status,cmdout] = unix(command,'-echo');
        
        % Copy the wavelet source file into the local directory
        copyfile( waveletSourceFilePath, waveletDestinationPath{iTarget});
        
    end
end

%==========================================================================
% Check that keplerIds match!

% Indicator showing whether wavelet coefficients for matching keplerId
% exists
checkKeplerId = false(length(selectedKeplerIdList),1);
for iTarget = 1:length(selectedKeplerIdList)
    
    % Construct the wavelet destination directory
    % waveletDestinationDir = strcat(localWaveletCoeffDir,['/st-',num2str(stNumbers(iTarget))]);
    
    % Load the wavelet coeff file
    % if(exist(strcat(waveletDestinationDir,'/tps-wavelet-object.mat'),'file'))
    % if(exist(waveletDestinationPath,'file'))
        
        % Load
        % load(strcat(waveletDestinationDir,'/tps-wavelet-object.mat'));
        load(waveletDestinationPath{iTarget});
        
        % Check that the keplerId matches
        % fprintf('Selected keplerId %d, archive keplerId %d\n',selectedKeplerIdList(iTarget),outputsStruct.keplerId)
        
        checkKeplerId(iTarget) = selectedKeplerIdList(iTarget) == outputsStruct.keplerId;
    % end
    
end

% Report number of keplerId matches
fprintf('There were %d keplerId matches out of %d targets\n',sum(checkKeplerId),length(selectedKeplerIdList))




