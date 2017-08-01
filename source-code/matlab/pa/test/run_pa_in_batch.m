function result = run_pa_in_batch(taskFileDirectory, spiceFileDirectory, varargin)
%
% function result = run_pa_in_batch(taskFileDirectory, spiceFileDirectory, varargin)
%
% Run PA on all invocations in taskFileDirectory inorder write paOutputStructs to .mat files in the current working directory
% under the code base pointed to by socCodeRoot and socDistRoot. Assumes input files are named '(inputPrefix)(n).mat' and
% they contain a single variable, inputsStruct. Output files will contain a single variable, outputsStruct.
% Any blobs needed must be in run directory.
% INPUT:
% taskFileDirectory     = full path to task file directory containing pa-inputs-#.mat files
% spiceFileDirectory    = full path to spice file directory containing ephemeris files
% varargin              = {1} == socCodeRoot: full path to checked out branch of code under test
%                       = {2} == socDistRoot: full path to dist directory for code under test
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

stateFilename = 'pa_state.mat';
inputPrefix   = 'pa-inputs-';
outputPrefix  = 'pa-outputs-';


% save current environment variables
oldSocCodeRoot = getenv('SOC_CODE_ROOT');
oldSocDistRoot = getenv('SOC_DIST_ROOT');

% save current path
oldPath = matlabpath;


% point to code indicated by variable inputs socCodeRoot and socDistRoot
if nargin > 2    
    if ~nargin == 4
        error('Must have pointers to SOC_CODE_ROOT and SOC_DIST_ROOT');
    else        
        % reinitialize path
        path(pathdef);        

        % point to new code
        setenv('SOC_CODE_ROOT',varargin{1});
        setenv('SOC_DIST_ROOT',varargin{2});
        
        % generate new path
        startup;
    end
end
        

% find the number of invocations
s = load([taskFileDirectory,filesep,stateFilename],'nInvocations');

for n = 0:s.nInvocations - 1
    
    % load inputs
    nS = num2str(n);    
    disp(['Doing invocation ',nS,'...']);
    load([taskFileDirectory,filesep,inputPrefix,nS,'.mat']);
    
    
%     % do any inputsStruct conversions here    
%     % convert to 7.0
%     inputsStruct = pa_convert_62_data_to_70(inputsStruct);
    
    % adjust the inputsStruct so the spice files can be found
    inputsStruct.raDec2PixModel.spiceFileDir = spiceFileDirectory;    
    
    % run PA and save outputs in cwd
    outputsStruct = pa_matlab_controller(inputsStruct);                        %#ok<NASGU>
    save([outputPrefix,nS,'.mat'],'outputsStruct');
end


% retore envornment variables
setenv('SOC_CODE_ROOT',oldSocCodeRoot);
setenv('SOC_DIST_ROOT',oldSocDistRoot);

% restore old path
path(oldPath);
    
