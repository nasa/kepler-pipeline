classdef spsdSimulationTesterClass < handle
%************************************************************************** 
% classdef spsdSimulationTesterClass < handle
%************************************************************************** 
% Given a manually cleaned (all targets with visible SPSDs removed) PDC
% targetDataStruct, perform simulation tests, analyze performance, and plot
% results.
%
% METHODS:
%
%     spsdSimulationTesterClass( params, targetDataStruct, rowVectors )
%     spsdSimulationTesterClass( spsdCorrectedFluxObject )
%
%         Construct a spsdSimulationTesterClass object.
% 
%     results = test(eventArr)
%
%         Perform a single simulation test. Insert 100 random SPSDs into
%         the targetDataStruct, run the SPSD detector, and report
%         performance.
%
%     resultsArr = test_n(nTrials)
%
%         Perform n simulation tests. Report results of each test in a
%         structure array.
%
%     plot_stats(resultsArr)
%
%         Create plots of detection and correction performance using ALL
%         test results in resultsArr.
%
% USAGE:
%
%************************************************************************** 
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
    %% ----------------------------- Data ---------------------------------
    properties (Constant)
        LOCALIZATION_TOLERANCE = 3;
    end

    properties (GetAccess = 'public', SetAccess = 'public')
        cleanTargetDataStruct = [];
        mapBasisVectors       = [];
        
        eventParams           = [];
        spsdParams            = [];
    end
    
    %% ------------------------- Public Methods ---------------------------
    methods 
        
        %**
        % Constructor
        function obj = spsdSimulationTesterClass( params, targetDataStruct, rowVectors )
            
            if isa(params, 'spsdCorrectedFluxClass')
                [params, targetDataStruct, rowVectors] = spsdCorrectedFluxClass.object_to_constructor_args(params);
            end
            
            if exist('rowVectors', 'var') && ~isempty(rowVectors)
                obj.mapBasisVectors = rowVectors;
            end
            
            obj.spsdParams.pdcModuleParameters = params.pdcModuleParameters;
            obj.spsdParams.spsdDetectorConfigurationStruct = ...
                params.spsdDetectorConfigurationStruct;
            obj.spsdParams.spsdDetectionConfigurationStruct = ...
                params.spsdDetectionConfigurationStruct;
            obj.spsdParams.spsdRemovalConfigurationStruct = ...
                params.spsdRemovalConfigurationStruct;
  
            if ~isfield(obj.spsdParams.spsdDetectionConfigurationStruct, 'excludeWindowHalfWidth')
                obj.spsdParams.spsdDetectionConfigurationStruct.excludeWindowHalfWidth = 4;
            end
            
            obj.cleanTargetDataStruct = targetDataStruct;     
            obj.eventParams = obj.get_default_event_param_struct();
        end
        
        
        %**
        % test()
        function [results, spsdCorrectedFluxObject] = test(obj, eventArr, preLoadedEvents)
            
            % If specific events have been provided, use them. Otherwise
            % generate random events.
            if ~exist('eventArr', 'var')
                eventArr = obj.generate_random_events();
            end
                
            simulatedTargetDataStruct = obj.inject_events( eventArr );
            
            if exist('preLoadedEvents', 'var') % Short Cadence
                spsdCorrectedFluxObject = spsdCorrectedFluxClass( ...
                    obj.spsdParams, simulatedTargetDataStruct, obj.mapBasisVectors, preLoadedEvents);
                results = obj.analyze_sc_results(spsdCorrectedFluxObject.get_results(), eventArr); 
            else                               % Long Cadence
                spsdCorrectedFluxObject = spsdCorrectedFluxClass( ...
                    obj.spsdParams, simulatedTargetDataStruct, obj.mapBasisVectors);
                results = obj.analyze_lc_results(spsdCorrectedFluxObject.get_results(), eventArr); 
            end
                        
        end        
        
        
        %**
        % test_n()
        function resultsArr = test_n(obj, nTrials)
            for i = 1:nTrials
                fprintf('Processing trial %d of %d ...\n', i, nTrials);
                resultsArr(i) = obj.test();
            end
        end
        
        %**
        % test_sc()
        [lcResults, scResults, scSpsdCorrectedFluxObject] = test_sc(obj, lcCadenceTimes, scInputStruct);
        
        %**
        % test_n_sc()
        function [lcResultsArr, scResultsArr] = test_n_sc(obj, nTrials, lcCadenceTimes, scInputStruct)
            for i = 1:nTrials
                fprintf('Processing trial %d of %d ...\n', i, nTrials);
                [lcResultsArr(i), scResultsArr(i)] = obj.test_sc(lcCadenceTimes, scInputStruct);
            end
        end
        
        %**
        % test_80vv()
        resultsAnalysis = test_80vv(obj, sensitivityDropsPpm)
        
        %**
        % plot_80vv()
        plot_80vv(obj, resultsAnalysis, manualAvgDrop, manualProbHit, manualProbFa);
        
        %**
        % set_event_params()
        function set_event_params(obj, paramStruct)
            obj.eventParams = paramStruct;
        end

        %**
        % Useful for obtaining a valid struct that can be modified and
        % passed to the constructor.
        function paramStruct = get_default_event_param_struct(obj)
            paramStruct = struct( ...
                'nEvents',          100, ...
                'keplerIds',        [obj.cleanTargetDataStruct.keplerId], ...
                'cadences',         [1:length(obj.cleanTargetDataStruct(1).values)], ...
                'dropSize',         [0.0001 0.005], ...
                'tDrop',            [0 1], ...
                'recoveryFraction', [0.2 0.5], ...
                'recoverySpeed',    [0.3 0.8] ...
                );
        end

        
        %**
        % Externally defined methods.
        eventArr = generate_random_events(obj);
        modifiedTarget = inject_event( obj, target, eventArr );
        snr = calculate_spsd_snr( obj, event );
        snr = calculate_instantaneous_spsd_snr( obj, event ); 
        results = concatinate_test_results( obj, resultsArr );
        performanceStatsStruct = assess_performance(obj, resultsStruct);
        
        % Plotting methods
        plot_stats(obj, resultsAnalysisArr);
        plot_event_mosaic(obj, eventArr);
        plot_log_events(obj, eventArr);
    end
    
    %% ------------------------- Private Methods --------------------------
    methods (Access = 'public')
        simulatedTargetDataStruct = inject_events(obj, eventArr);
        resultsAnalysis = analyze_lc_results(obj, spsdResultsStruct, eventArr);  
        resultsAnalysis = analyze_sc_results(obj, spsdResultsStruct, eventArr);  
        profile  = create_spsd_profile(obj, d, tDrop, r, tc);
        outTarget = inject_sensitivity_feature(obj, inTarget, sensitivityProfile, cadence);
    end
    
    
    %% ------------------------- Static Methods ---------------------------
    methods (Static)
                 
        plot_sc_localization_and_correction_performance(scResultsAnalysisArr);

        %**
        % Useful for obtaining a valid struct that can be modified and
        % passed to the constructor.
        function paramStruct = get_default_test_param_struct()
            paramStruct = struct( ...
                );
        end

    end  
    
    
end


