function result = run_pa_in_batch_NAS_style(spiceFileDirectory, nInvocations, varargin)
%
% function result = run_pa_in_batch_NAS_style(spiceFileDirectory, nInvocations, varargin)
%
% Run PA on all invocations in subtask directories under current working directory. Create these subtask directories and 
% move the inputs files if necessary. Assumes input files are named '(inputPrefix)(n).mat' and
% they contain a single variable, inputsStruct. Output files will contain a single variable, outputsStruct.
% Any blobs needed must be in run directory.
% INPUT:
% spiceFileDirectory    = full path to spice file directory containing ephemeris files
% nInvocations          = number of invocations to run
% varargin              = {1} = nCadences, {2} = startCadence
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

% initialize result
result = true;

% get optional arguments
if nargin > 2
    nCadences = varargin{1};
    if nargin > 3
        startCadence = varargin{2};
    else
        startCadence = 1;
    end
end
    

inputPrefix = 'pa-inputs-';
outputPrefix = 'pa-outputs-';
subTaskPrefix = 'st-';


topLevel = pwd;

for n = 0:nInvocations
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
    
    % adjust the inputsStruct so the spice files can be found
    inputsStruct.raDec2PixModel.spiceFileDir = spiceFileDirectory;
    
%     % update keplerMag if necessary
%     if ~isempty(inputsStruct.targetStarDataStruct)
%         idx = find([inputsStruct.targetStarDataStruct.keplerMag]>=30);
%         if ~isempty(idx)
%             for i = idx(:)'
%                 inputsStruct.targetStarDataStruct(i).keplerMag = 29;
%             end
%         end
%     end
    
    % run subset of cadences
    if exist('nCadences','var') && exist('startCadence','var')
        inputsStruct = get_subset_of_pa_inputs(inputsStruct, nCadences, startCadence);  
    end
        
%     % load local background pixels
%     if n == 0
%         p = load('../local_background.mat');
%         inputsStruct.backgroundDataStruct = p.backgroundDataStruct;
%     end
    
%     % set local background parameters
%     inputsStruct.backgroundConfigurationStruct.enableLocalBackgroundCorrection = true;
%     inputsStruct.backgroundConfigurationStruct.localBackgroundPixelPercentile = 7;

%     % set motion polynomial fitting parameters
%     inputsStruct.motionConfigurationStruct.aicOrderSelectionEnabled = false;
%     inputsStruct.motionConfigurationStruct.rowFitOrder = 2;
%     inputsStruct.motionConfigurationStruct.columnFitOrder = 2;
%     inputsStruct.motionConfigurationStruct.fitMinPoints = 6;
%     inputsStruct.motionConfigurationStruct.centroidBiasRemovalIterations = 1;

%     % set background polynomial fitting parameters
%     inputsStruct.backgroundConfigurationStruct.aicOrderSelectionEnabled = true;
%     inputsStruct.backgroundConfigurationStruct.fitOrder = 4;
    
%     % enable simulation
%     inputsStruct.transitInjectionParametersFileName = 'kplr2013207210442-05_tip.txt';
%     inputsStruct.paConfigurationStruct.simulatedTransitsEnabled = true;
    
    if n == 0
        % fix blobs
        cadenceNumbers = inputsStruct.cadenceTimes.cadenceNumbers;
        nCadences = length(cadenceNumbers);
        % motion
        inputsStruct.motionBlobs.blobIndices = zeros(nCadences,1);
        inputsStruct.motionBlobs.gapIndicators = false(nCadences,1);
%         inputsStruct.motionBlobs.blobFilenames = {'motionBlob.mat'};
        inputsStruct.motionBlobs.startCadence = cadenceNumbers(startCadence);
        inputsStruct.motionBlobs.endCadence = cadenceNumbers(startCadence + nCadences - 1);

        % background
        inputsStruct.backgroundBlobs.blobIndices = zeros(nCadences,1);
        inputsStruct.backgroundBlobs.gapIndicators = false(nCadences,1);
%         inputsStruct.backgroundBlobs.blobFilenames = {'backgroundBlob.mat'};
        inputsStruct.backgroundBlobs.startCadence = cadenceNumbers(startCadence);
        inputsStruct.backgroundBlobs.endCadence = cadenceNumbers(startCadence + nCadences - 1);
    end
    
    
% %   turn pou on/off
%     inputsStruct.pouConfigurationStruct.pouEnabled = true;
    
%     % adjust pou chunking
%     inputsStruct.pouConfigurationStruct.pixelChunkSize = 2500;
%     
    % turn off prf centroiding
    inputsStruct.paConfigurationStruct.ppaTargetPrfCentroidingEnabled = false;
    inputsStruct.paConfigurationStruct.targetPrfCentroidingEnabled = false;
    
%      % turn off cosmic ray cleaning
%     inputsStruct.paConfigurationStruct.cosmicRayCleaningEnabled = true;   
    
    
%     % set lastCall on last invocation
%     if n == nInvocations
%         inputsStruct.lastCall = true;
%     end    
    
    % run PA and save outputs in cwd
    outputsStruct = pa_matlab_controller(inputsStruct);                        %#ok<NASGU>    
    save([outputPrefix,'0.mat'],'outputsStruct');
    
    cd(topLevel);
end

