% function [outputsStructInjected] = pdc_stellar_preservation_test (inputsStruct, signalType, signalAmplitude, debugRun)
%
% This system test will examine how well PDC preserves stellar variability by injecting known signals into PDC
% and examine how well they are preserved.
%
% Note that when this function is called in an OPS run the run is simply a normal pdc_matlab_controller run but with pdc_matlab_controller replaced with
% pdc_stellar_preservation_test. So, this function must accept the optional duaghter dispatching arguments.
%
% Inputs: 
%   inputsStruct    -- [struct] PDC input Structure from task file (uneditied)
%   pdc_main_string -- not used (for PDC daughter dispatching)       
%   subTaskString   -- not used (for PDC daughter dispatching)             
%   signalType      -- [char Optional] Type of signal to inject (see pdcStellarPreserveClass.inject_signals)
%                                       default: 'sineAmplitudeStudy'
%   signalAmplitude -- [float Optional] Amplitude of injected signal, relative to target std of flux
%                                       default: 1.0
%   debugRun        -- [logical Optional] If true then PDC never called, just tests internal functionality
%                                       default: false
% Outputs:
%   stellarPreserveObject -- [stellarPreserveClass] Contains all processed information and functionality, SAVED TO FILE
%                                                   See pdcStellarPreserveClass.m.
%   outputsStructInjected -- [outputsStruct] the outputsStruct from the injected run (so that the post-PDC processor does not complain when this is run by ops.
%
%*************************************************************************************************************
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

function [outputsStructInjected] = pdc_stellar_preservation_test (inputsStruct, varargin)

global StellPreserveMemUsage;
StellPreserveMemUsage = memoryUsageClass('Stellar Preservation test Memory Usage'); % memUSage is a global object handle

display('***************************************************************************************');
display('This function will perform a stellar preservation study on PDC');
display('It will run full PDC twice and so will take a long time');
display('BE SURE YOU ARE IN A GOOD DIRECTORY SINCE FILES WILL BE SAVED TO THE CURRENT DIRECTORY');
display('***************************************************************************************');

% Create object setup inputsStruct and diagnosticStruct
stellarPreserveObject = pdcStellarPreserveClass(inputsStruct);

StellPreserveMemUsage.add('After substantiating stellarPreserveObject');

% Default Parameters
stellarPreserveObject.debugRun = false;
stellarPreserveObject.signalType = 'sineAmplitudeStudy';

% default for medianFlux
%stellarPreserveObject.signalAmplitude = 0.001; % NOT used for amplitudeStudy
% Default for stdFlux
stellarPreserveObject.signalAmplitude = 1.0; % NOT used for amplitudeStudy

% Optional parameters 
if (~isempty(varargin))
    % Remove the first two optional argument (which are for daughter dispatching)
    varargin = varargin(3:end);
    for iVar = 1 : length(varargin)
        if (islogical(varargin{iVar}))
            stellarPreserveObject.debugRun = varargin{iVar};
        elseif (ischar(varargin{iVar}))
            stellarPreserveObject.signalType = varargin{iVar};
        elseif (isnumeric(varargin{iVar}))
            stellarPreserveObject.signalAmplitude = varargin{iVar};
        end
    end
end

%************
% Call original PDC run
% Do not do this if testing with simple signal injection
if (~stellarPreserveObject.debugRun)
    stellarPreserveObject.run_original_pdc();
end
StellPreserveMemUsage.add('After Original Run');

%************
% Inject signals
stellarPreserveObject.inject_signals ();
StellPreserveMemUsage.add('After injecting signals');

%************
% Call injected signal PDC run
% Do not do this if testing with simple signal injection
if (~stellarPreserveObject.debugRun)
    stellarPreserveObject.run_injected_pdc();
end
StellPreserveMemUsage.add('After Injected Run');

%************
% Post analysis
stellarPreserveObject.compute_post_data ();
StellPreserveMemUsage.add('After computing post data');

%************
% Perform analysis
doSaveFigure = true;


if (any(strcmp(stellarPreserveObject.signalType, {'sineAmplitudeStudy', 'quietSineAmplitudeStudy', 'simulatedStellarAmplitudeStudy'})))
    % For Amplitude Study
    stellarPreserveObject.generate_amplitude_study_plot(doSaveFigure)
end

if (any(strcmp(stellarPreserveObject.signalType, {'simulateStellarOscillator', 'sineWave', 'quietSineWave', 'halfSineWave', 'quarterSineWave', 'halfSineHalfWGN'})))
    % This is for sine wave sigals
    stellarPreserveObject.generate_1D_corruption_plots(doSaveFigure);
end

if (any(strcmp(stellarPreserveObject.signalType, {'WGN', 'halfWGN', 'quarterWGN', 'halfSineHalfWGN'})))
    % This is for WGN signals
    stellarPreserveObject.perform_net_PSD_analysis(doSaveFigure);
   %stellarPreserveObject.perform_std_analysis(doSaveFigure);
end

if (any(strcmp(stellarPreserveObject.signalType, {'SOHO'})))
    % Same signal injected into all targets so just direct comparison of preservation between targets
    stellarPreserveObject.perform_soho_data_analysis(doSaveFigure);
end
StellPreserveMemUsage.add('After generating figures');

%************
% Save and clean up

% Save the data object for posterity
intelligent_save ('stellarPreserveObject', 'stellarPreserveObject');

StellPreserveMemUsage.add('end');

% plot memory usage
%StellPreserveMemUsage.plot_memory_usage;

if (~stellarPreserveObject.debugRun)
    outputsStructInjected = stellarPreserveObject.outputsStructInjected;
else
    outputsStructInjected = [];
end

% Delete all uneccessary PDC files (they can take up A LOT of space)
delete ('cbv_blob.mat')
delete ('mapResultsStruct*')
delete ('outputsStruct*')
delete ('spsdCorrectedFlux*')
delete ('pdc-outputs-0.mat')
delete ('no_BS_waveletDenoiseObject.mat')
delete ('pdc_blob.mat')
delete ('pdcDebugStruct.mat')
delete ('Coarse_waveletDenoiseObject.mat')
delete ('spikeBasisVectors.mat')
delete ('spikeCoefficients.mat')
delete ('spsdBlob.mat')
delete ('spsdOutput.mat')
if (exist('goodness_metric_plots', 'dir'))
    rmdir ('goodness_metric_plots*', 's')
end
if (exist('map_plots', 'dir'))
    rmdir ('map_plots', 's')
end
    
disp('Stellar Preservation Test completed successfully');
