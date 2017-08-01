function result = run_cal_in_batch_NAS_style(varargin)
%
% function result = run_cal_in_batch_NAS_style(varargin)
%
% Run CAL on invocation 0 through invocation n and write calOutputStructs
% to .mat files in the current working directory. Assumes input files are
% named '(inputPrefix)(n).mat' and contain a single variable,
% inputsStruct. Output files will contain a single variable, outputsStruct.
% 
% This script is based on run_cal_in_batch but implements the NAS style subtask directory
% structure. At the beginning all the cal-inputs-#.mat files must sit in the top level
% directory. The st-# subtask directory structure is created and the cal-inputs-#.mat
% files are moved into their corresponding directories and renamed 'cal-inputs-0.mat'.
% We then loop through invocations making the current working directory the appropriate
% st-# subtask directory prior to calling the cal_matlab_controller. We return to the top
% level directory at the end of the script.
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

result = true;

inputPrefix = 'cal-inputs-';
outputPrefix = 'cal-outputs-';
subTaskPrefix = 'st-';

if nargin ~= 0
   nInvocations = varargin{1};
else
    D = dir([subTaskPrefix,'*']);
    nInvocations = length(D) - 1;
end



topLevel = pwd;

for n=0:nInvocations
    nS = num2str(n);
    if ~exist([topLevel,filesep,subTaskPrefix,nS],'dir')
        mkdir([subTaskPrefix,nS]);
    end
    if exist([topLevel,filesep,inputPrefix,nS,'.mat'],'file')
        movefile([topLevel,filesep,inputPrefix,nS,'.mat'],[topLevel,filesep,subTaskPrefix,nS,filesep,inputPrefix,'0.mat']);
    end
    cd([topLevel,filesep,subTaskPrefix,nS]);       
    disp(['Doing invocation ',nS,'...']);
    load([inputPrefix,'0.mat']);
    outputsStruct = cal_matlab_controller(inputsStruct);                                    %#ok<NASGU>
    save([outputPrefix,'0.mat'],'outputsStruct');
    cd(topLevel);
end
    
