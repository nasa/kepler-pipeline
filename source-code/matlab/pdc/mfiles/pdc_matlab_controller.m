%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%% function [pdcOutputsStruct] = pdc_matlab_controller(pdcInputStruct, pdc_main_string, subTaskString, uberDiagnosticStruct)
%
% This function forms the MATLAB side of the science interface for presearch
% data conditioning (PDC). The function receives input mainly via the pdcInputStruct
% structure however other optional input arguments can also be passed.
%
% Due to memory leaks in Matlab a daughter-dispatching framework had been implemented in PDC. When run on the cluster or NAS PDC is run via an executable called
% pdc_main. So, the only function available to call is pdc_main. So, there are now two extra variables passed to pdc_main which are in turn passed to
% pdc_matlab_controller: <pdc_main_string> and <subTaskString>. These direct PDC on what sub-pdc tasks to run via the dispacther.
% The added complexity of the daughter dispatching hasresulted in this function no longer being easy to read sequentially.
% NOTE: dispatching is turned off since it has been found not to improve memory usage by enough to be worth the extra complexity.
%
% A typical run of PDC without any dispatching or debuggin is called simply with 
%   outputsStruct = pdc_matlab_controller (inputsStruct)
%
%***
% pdc_matlab_controller first determines if we are running in daughter dispatcher mode based on <pdc_main_string> and <subTaskString>. If daughter dispatching
% is not being used then the actual executed code fpr PDC being on line begining witht he comment "This is the mother process".
% PDC first displays what PDC version and data is being run so the user knows right away if the run is correct. Then, it
% calls the contructor for the pdcInputClass which also validates the fields of the input structure. 
%
% Throughout the running of PDC memoryUsageClass is used to track memory usage using the global object <memUsage>.
%
% If pdcInputStruct.pdcModuleParameters.mapEnabled is true then
% The presearch_data_conditioning method is invoked on the new pdcInputObject in order to perform PDC-MAP:
%
%      Correct systematic errors in relative flux time series by a Maximum A Posteriori (MAP) fit of the flux time
%      series based on correlations of the flux times series within a given mod.out.
%       See presearch_data_conditioning.m for details and a breakdown of all the steps.
%
% Otherwise, the older method can be performed (PDC-LS)
%   NOTE: THIS CODE IS NOT MAINTAINED, MAY NOT RUN
%   The older PDC systematic error correction method based on a blind least squares fit.
%    See /release70/@pdcDataClass/presearch_data_conditioning_70.m
%
%***
% See pdc_create_output_struct for details of the returned pdcOutputsStruct.
%
% PDC will also save a large number of diagnostic .mat files and .fig figures to the task file directory.
%
% A description of PDC can be found in the follwing papers:
%
% Stumpe, M. C., Smith, J. C., Catanzarite, J. H., et al. 2014, “Kepler Presearch Data Conditioning I - Architecture and Algorithms for Error Correction in
% Kepler Light Curves”,  Publications of the Astronomical Society of the Pacific, 126, 100
% 
% Smith, J. C., Stumpe, C., Cleve, J. E. V., et al. 2012, “Kepler Presearch Data Conditioning II - A Bayesian Approach to Systematic Error Correction of Kepler
% Data”, Publications of the Astronomical Society of the Pacific, 124, 1000
%
% Stumpe, M. C., Smith, J. C., Cleve, J. E. V., et al. 2012, “Multiscale Systematic Error Correction via Wavelet-Based Bandsplitting in Kepler
% Data”,Publications of the Astronomical Society of the Pacific, 124, 985
%
% Jeffery Kolodziejczak and Robert L. Morris 2012, "Methods for Detection and Correction of Sudden Pixel Sensitivity Drops”, Kepler Design Note number 26304
%
% And also in the Kepler Data Processing Handbook.
%
% The Blue, Green and Yellow boxes referenced in thsi code are from the PDC flow chart in the above documents.
% 
%***
% For K2 a parameter <thisIsK2Data> identifies if we ar erunning on K2 data. If so then Run the K2 specifric options. See the follweing paper for a description
% of the K2 specific modifications:
%
% Van Cleve, Jeffrey et al., 2016 "That's How We Roll: The NASA K2 Mission Science Products and Their Performance Metrics”, Publications of the Astronomical
% Society of the Pacific, to be published
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% INPUT: 
%   pdcInputStruct          -- [struct] see ./inputs/pdcInputClass.m for details
%   pdc_main_string         -- [string OPTIONAL] path to pdc_main executable
%   subTaskString           -- [string OPTIONAL] The PDC subtask to perform
%   uberDiagnosticStruct    -- [struct OPTIONAL] Used for testing and debuging, non-pipeline runs
%                                   see pdc_populate_diagnosticinputstruct.m for details
%
% OUTPUT: 
%   pdcOutputStruct         -- [struct] see ./pdc_create_output_struct.m for details
%%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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
function [pdcOutputsStruct] = pdc_matlab_controller(pdcInputStruct, varargin)

% Keep track of PDC memory usage, see memoryUsageClass.m
global memUsage;

% isdeployed is a global parameter set by OPS. It's true if this is being called in OPS processing (so, on clusters or NAS).
if(isdeployed)
    % NOTE: dispatching is turned off since it has been found not to improve memory usage by enough to be worth the extra complexity
    % Keeping code in here just in case we want to revisit this.
    dispatchingEnabled = false;
   %dispatchingEnabled = true;
else
    dispatchingEnabled = false; % No daughter dispatching
end

if (length(varargin)>=2 && isdeployed)
    % This is a daughter dispatcher run using a matlab executable
    pdc_main_string = varargin{1};
    subTaskString   = varargin{2};
    if (strcmp('forceNoDispatching', subTaskString))
        % This is a deployed run but turn off dispatching for testing purposes
        dispatchingEnabled = false;
        % Need to reset subTaskString to [] so that daughterDispatcher knows we are in the mother
        subTaskString = [];
    end
    % If subTaskString == [] then we are in the mother process
    daughterDispatcher = pdcDaughterDispatcherClass(dispatchingEnabled, subTaskString, 'MATLABEXECUTABLE', pdc_main_string);
elseif (length(varargin)>=2)
    % This is a daughter dispatcher run using a matlab session
    pdc_main_string = [];
    subTaskString   = varargin{2};
    if (strcmp('debugDispatcherRun', subTaskString))
        % This is a mother process but turn on dispatching for testing purposes
        dispatchingEnabled = true;
        % Need to reset subTaskString to [] so that daughterDispatcher knows we are in the mother
        subTaskString = [];
    end
    % If subTaskString == [] then we are in the mother process
    daughterDispatcher = pdcDaughterDispatcherClass(dispatchingEnabled, subTaskString, 'MATLAB', pdc_main_string);
else
    % Run everything in this Matlab session
    pdc_main_string = [];
    subTaskString   = [];
    daughterDispatcher = pdcDaughterDispatcherClass(dispatchingEnabled, [], 'MATLAB', pdc_main_string);
end

if (length(varargin)==3)
    uberDiagnosticStruct = varargin{3};
else
    uberDiagnosticStruct = struct('pdcDiagnosticStruct','','mapDiagnosticStruct','','spsdDiagnosticStruct','');
end

if (dispatchingEnabled)
    error ('Daughter Dispatching is turned off and will not currently work! See Jeff Smith if you want this turned on.');
end

% Since PDC can spawn daughters we need to check here if this is the mother process or a daughter

if (daughterDispatcher.isInDaughter)
    % All daughters are from presearch_data_conditioning but handled in dispatcherInDaughter
    pdcDispatchWrapperClass.dispatch_in_daughter_wrapper(daughterDispatcher);

    % If we are in a daughter then pdc_matlab_controller should return an empty set so that pdc_main knows not to save pdcOutputsStruct
    % The returned arguments from the daughter are saved in a file
    pdcOutputsStruct = [];
else
    % This is the mother process
    % Or, for a non-daughter dispatching run (DEFAULT)

    %***
    % Right at start display what we are running on so there is no waiting to confirm we are running on the correct data
    if (isfield(pdcInputStruct.fcConstants, 'KEPLER_END_OF_MISSION_MJD') && ...
            pdcInputStruct.cadenceTimes.midTimestamps(find(~pdcInputStruct.cadenceTimes.gapIndicators,1))  > pdcInputStruct.fcConstants.KEPLER_END_OF_MISSION_MJD)
        % This is K2 data
        thisIsK2Data = true;
    else
        thisIsK2Data = false;
    end
    if (~isfield(pdcInputStruct, 'quarter') || ~isfield(pdcInputStruct, 'month'))
        if (isdeployed)
            quarter = NaN;
            month = NaN;
        else
            if (thisIsK2Data)
                quarter = NaN;
                month = NaN;
            else
                % convert_from_cadence_to_quarter is not available in OPS runs
                quarter = convert_from_cadence_to_quarter (pdcInputStruct.startCadence, pdcInputStruct.cadenceType);
            end
            % quarter is the integer part
            quarter = quarter - rem(quarter,1);
            % month is the decimal part, if zero then this is LC full quarter data
            month = rem(quarter,1);
        end
    else
        quarter = pdcInputStruct.quarter;
        month   = pdcInputStruct.month;
    end
    if (~isfield(pdcInputStruct, 'ccdModule') || ~isfield(pdcInputStruct, 'ccdOutput'))
        % This is the "new" multi-channel enabled PDC inputs
        if (length(pdcInputStruct.channelDataStruct) > 1)
            % multi-channel run so pist all mod.outs
            ccdModule = unique([pdcInputStruct.channelDataStruct.ccdModule]);
            ccdOutput = unique([pdcInputStruct.channelDataStruct.ccdOutput]);
            nTargets = 0;
            for iChannel = 1 : length(pdcInputStruct.channelDataStruct)
                nTargets = nTargets + length(pdcInputStruct.channelDataStruct(iChannel).targetDataStruct);
            end
        else
            % Single channel run so only need to display one mod.out
            ccdModule = pdcInputStruct.channelDataStruct(1).ccdModule;
            ccdOutput = pdcInputStruct.channelDataStruct(1).ccdOutput;
            nTargets = length(pdcInputStruct.channelDataStruct.targetDataStruct);
        end
    else
        ccdModule = pdcInputStruct.ccdModule;
        ccdOutput = pdcInputStruct.ccdOutput;
        nTargets = length(pdcInputStruct.targetDataStruct);
    end
    %***

    if (thisIsK2Data)
        disp(['Doing PDC version ', num2str(pdcInputClass.pdc_version), ' for ', int2str(nTargets), ...
            ' targets and ', int2str(length(pdcInputStruct.cadenceTimes.midTimestamps)), ...
            ' cadences on module(s) ', int2str(ccdModule), ' and output(s) ', int2str(ccdOutput), ...
            ' for K2 data']);
    elseif (isnan(quarter) || isnan(month))
        disp(['Doing PDC version ', num2str(pdcInputClass.pdc_version), ' for ', int2str(nTargets), ...
            ' targets and ', int2str(length(pdcInputStruct.cadenceTimes.midTimestamps)), ...
            ' cadences on module(s) ', int2str(ccdModule), ' and output(s) ', int2str(ccdOutput)]);
    else
        disp(['Doing PDC version ', num2str(pdcInputClass.pdc_version), ' for ', int2str(nTargets), ...
            ' targets and ', int2str(length(pdcInputStruct.cadenceTimes.midTimestamps)), ...
            ' cadences on module(s) ', int2str(ccdModule), ' and output(s) ', int2str(ccdOutput), ...
            ' for quarter ', num2str(quarter) ' and month ', num2str(month)]);
    end

    % memUSage is a global object handle
    memUsage = memoryUsageClass(['Overall PDC Memory Usage; ', int2str(nTargets), ' targets and ', ...
                int2str(length(pdcInputStruct.cadenceTimes.midTimestamps)), ' cadences.' ]);

    % Check for the presence of expected fields in the input structure, check 
    % whether each parameter is within the appropriate range, and create
    % pdcInputClass object.
    validateInputTime = tic;
    display('Validating input fields...');
    pdcInputObject = pdcInputClass(pdcInputStruct);

    memUsage.add('After substantiating pdcInputObject');
    
    duration = toc(validateInputTime);
    display(['Input fields validated and pdc Input object created: ' num2str(duration) ...
        ' seconds = '  num2str(duration/60) ' minutes']);

    %--------------------------------------------------------------------------
    % Run PDC for the given module output. 
    % Uses the MAP approach if flag mapEnabled is true
    % Otherwise uses old (release 7.0) code based on least square-fit
    fullPDCRunTime = tic;
    %
    % note that pdcInputStruct is used here, not pdcInputObject !!
    %
    if ( (isfield(pdcInputStruct.pdcModuleParameters,'mapEnabled')) ...
         && (pdcInputStruct.pdcModuleParameters.mapEnabled))
        % use new PDC
        [ pdcOutputsStruct ] = presearch_data_conditioning(pdcInputObject, uberDiagnosticStruct);
        memUsage.add('After presearch_data_conditioning');
    
    else
        % use old PDC
        error('The old pre-8.0 PDC is no longer supported');
        disp('invoking PDC 7.0');
        disp('WARNING: This code is not actively maintained. There are no guarantees it will run to completion!');
        if (isempty( strfind(path, 'release70')))
            error('The old release70 functions do not appear to be in the path');
        end
        % The old PDC uses the old pdcDataClass
        pdcDataObject = pdcDataClass(pdcInputStruct);
        [ pdcOutputsStruct ] = presearch_data_conditioning_70(pdcDataObject);
    end
    
    % Save the outputsStruct if this is not deployed. 
    % This way there is no need to save it manually after PDC is run!
    if (~isdeployed)
        outputsStruct = pdcOutputsStruct;
        intelligent_save('pdc-outputs-0.mat', 'outputsStruct');
        clear outputsStruct;
    end

    duration = toc(fullPDCRunTime);
    display(['Presearch data conditioning total run time: ' num2str(duration) ...
    ' seconds; '  num2str(duration/60) ' minutes; ' ]);

    memUsage.add('end');

    % plot memory usage
    memUsage.plot_memory_usage;

    disp('PDC completed successfully.');
end

return
