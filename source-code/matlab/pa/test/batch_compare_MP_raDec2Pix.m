function resultsStructArray = batch_compare_MP_raDec2Pix(pathName, quarter, spiceFilesPath)

% Obtain a list of symbolic links to all valid group (channel) directories.
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
taskDirNamePattern = sprintf('pa-*-q%02d-*', quarter);
symlinkDir = 'uow';
D = dir( fullfile(pathName, symlinkDir, taskDirNamePattern) );
D = D([D.isdir]); % Prune non-directories.

% Obtain a list of task file directories and prune any empty entries due to
% missing channels.
taskDirCellArray = get_group_dir('PA', [1:84]', 'rootPath', pathName, 'quarter', quarter);
emptyIndicators = strcmp('',taskDirCellArray);
taskDirCellArray(emptyIndicators) = [];
nChannels = numel(taskDirCellArray);

% build output struct
dimResult = struct('index',[],...
                    'residual',[],...
                    'modes',[],...
                    'madFromFirstMode',[],...
                    'maxDevFromFirstMode',[],...
                    'binSize',[],...
                    'polyOrder',[]);
                
resultsStructArray = repmat(struct('ccdModule',[],...
                                    'ccdOutput',[],...
                                    'row',dimResult,...
                                    'col',dimResult), nChannels, 1);


for iChannel=1:nChannels
    resultsStructArray(iChannel) = ...
        compare_MP_to_raDec2Pix(taskDirCellArray{iChannel}, spiceFilesPath, false);
    disp(['Module ',num2str(resultsStructArray(iChannel).ccdModule), ...
         ' Output ',num2str(resultsStructArray(iChannel).ccdOutput), ...
         ' done...']);
end
