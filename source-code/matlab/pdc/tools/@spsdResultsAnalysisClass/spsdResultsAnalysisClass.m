%==========================================================================
% spsdResultsAnalysisClass
%==========================================================================
% A class to facilitate plotting results of SPSD detection. 
%
% DATA
%     This class is derived from spsdCorrectedFluxClass and has the same
%     set of properties.
%
%
% METHODS
%     spsdResultsAnalysisClass(spsdCorrectedFluxObject)
%
%     eventArr = get_detected_events(iterations)
%         Return a list of detected SPSD events as a struct array. See
%         example below for more detail.
%
%     eventArr = get_rejected_candidates(iterations)
%
%     eventArr = get_noncandidates(iterations)
%
%     notes = plot_events(eventArr, groundTruthTds);
%         Interactively plot, examine, and annotate a set of events
%         contained in a struct array. A valid event structure must have, 
%         at a minimum, the following fields:
%
%             eventStruct
%                 .keplerId OR index 
%                 .cadence
%         
%         If other fields, such as a correction vector, are present, they
%         will be used. If a targetDataStruct containing ground truth is
%         provided, its flux values will be displayed as well.
%
%     notes = plot_detected()
%         Call plot_events with all detected SPSDs as arguments.
%
%     notes = plot_rejected()
%         Call plot_events with all rejected SPSD candidates as arguments.
%
%     notes = plot_noncandidates()
%         Call plot_events with all events that did not survive the 
%         candidate vetting process.
%
%
%
% EXAMPLE USAGE:
%
%     Refer to the following example to use this class for analyzing PDC
%     results.
%
%     Load the results file and construct a spsdResultsAnalysisClass
%     object:
%
%         >> cd pdc-matlab-5041-197141/
%         >> load spsdCorrectedFluxObject_1.mat
%         >> cfo = spsdCorrectedFluxClass.loadobj(spsdCorrectedFluxObject)
%         >> sra = spsdResultsAnalysisClass(cfo)
%
%     Plot all detected SPSDs and return a list of selected annotated
%     events: 
%
%         >> annotated = sra.plot_detected()
%
%     Review and perhaps re-annotate the events in the annotated list:
%
%         >> newAnnotated = sra.plot_events(annotated)
%
%     Examine only SPSDs detected in the 2nd and 4th detection iterations:
%
%         >> annotatedDetected_2_4 = sra.plot_events( sra.get_detected_events([2 4]) )
%
%     Examine events that were rejected as SPSDs during iteration 1:
%
%         >> annotatedRejected_1 = sra.plot_events( sra.get_rejected_events(1) )
%
%     Examine all events that were considered invalid as candidates (i.e.,
%     did not make it to the final decision round):
%
%         >> annotatedNonCand = sra.plot_noncandidates()
%
%
%
% INTERACTIVE EXAMINATION
%
%     The plotting functions are interactive. For each event you will be
%     asked whether or not you want to annotate and save it. The set of
%     valid responses and their meanings is given below (case is ignored):  
%
%         y      : Annotate the current event and add it to the list of
%                  interesting events.
%         n      : Do not annotate the current event or add it to the list.
%                  Plot the next event.
%         RETURN : Plot the next event
%         b      : Plot the previous event
%         q      : Quit interactive plotting 
% 
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
classdef spsdResultsAnalysisClass < spsdCorrectedFluxClass
    
    methods
        
        %**
        % Constructor
        function obj = spsdResultsAnalysisClass(spsdCorrectedFluxObject)
            
            if nargin < 1
                spsdCorrectedFluxObject = spsdCorrectedFluxClass();
            end
            
            % Copy the input object's property values, excluding constant
            % and abstract properties.
            p = properties(spsdCorrectedFluxClass);
            for i = 1:numel(p)
                propertyAttr = findprop(spsdCorrectedFluxObject, p{i});
                if ~propertyAttr.Constant && ~propertyAttr.Abstract

                    % An older object's properties may be a subset of
                    % the properties listed in the current class
                    % definition.  
                    if any(ismember( ...
                        properties(spsdCorrectedFluxObject), p{i})) 
                        obj.(p{i}) = spsdCorrectedFluxObject.(p{i});
                    end
                end
            end
            
        end
        
        %**
        % Retrieve an array containing detected SPSD events. If the 
        % specific iteration isn't specified, all events are returned in a
        % single array. Returns a 1xN struct array.
        function eventArr = get_detected_events(obj, iterations)
            
            if ~exist('iterations','var')
                iterations = [1:obj.detectionParamsStruct.maxDetectionIterations];
            end
            eventStruct = struct('keplerId', [], 'index', [], 'cadence', [], 'iteration',[], 'correction',[]);
            eventArr = [];

            results = obj.get_results();
            
            for i = iterations % For each of the specified iterations
                for j = 1:results.spsds.count % Loop over "dirty" targets.
                    if results.spsds.targets(j).spsdCount >= i
                        spsdEvent            = eventStruct;
                        spsdEvent.index      = results.spsds.targets(j).index;
                        spsdEvent.keplerId   = results.spsds.targets(j).keplerId;
                        spsdEvent.iteration  = i;
                        spsdEvent.cadence    = results.spsds.targets(j).spsdEvents(i).spsdCadence;
                        spsdEvent.correction = results.spsds.targets(j).spsdEvents(i).correction;
                        
                        % Estimate sensitivity drop as the max absolute
                        % correction over the median flux before the step.
                        estStepHeight = max(abs(spsdEvent.correction));
                        preStepRange = max(1, spsdEvent.cadence-4):max(1, spsdEvent.cadence-1);
                        medianPreStepFlux = median(obj.inputTargetDataStruct(spsdEvent.index).values(preStepRange));
                        spsdEvent.deltaSensitivity = estStepHeight / medianPreStepFlux;
                        
                        eventArr = [eventArr, spsdEvent];
                    end
                end
            end

        end
        
        %**
        % Retrieve an array of rejected candidates. If the specific
        % iterations aren't specified, all rejected candidates are returned
        % in a single array. Returns a 1xN struct array.
        function eventArr = get_rejected_candidates(obj, iterations)
            if ~exist('iterations','var')
                iterations = [1:obj.detectionParamsStruct.maxDetectionIterations];
            end
            
            eventArr = [];
            if isfield(obj.debugObject.data, 'rejectedCandidates')
                for i = iterations
                    name = strcat('iter',num2str(i));
                    if isfield(obj.debugObject.data.rejectedCandidates, name)
                        e = obj.debugObject.data.rejectedCandidates.(name);
                        if ~isempty(fieldnames(e))
                            for j = 1:numel(e)
                                e(j).iteration = i;
                            end
                            eventArr = [eventArr(:)', e];
                        end
                    end
                end
            end
        end
        
        
        %**
        % Retrieve an array of potential candidates that did not pass the
        % vetting process. If the specific iterations aren't specified, all
        % non-candidates are returned in a single array. Returns a 1xN 
        % struct array.
        function eventArr = get_noncandidates(obj, iterations)
            if ~exist('iterations','var')
                iterations = [1:obj.detectionParamsStruct.maxDetectionIterations];
            end
            
            eventArr = [];
            if isfield(obj.debugObject.data, 'nonCandidateEvents')
                for i = iterations
                    name = strcat('iter',num2str(i));
                    if isfield(obj.debugObject.data.nonCandidateEvents, name)
                        e = obj.debugObject.data.nonCandidateEvents.(name);
                        if ~isempty(fieldnames(e))
                            for j = 1:numel(e)
                                e(j).iteration = i;
                            end
                            eventArr = [eventArr(:)', e];
                        end
                    end
                end
            end
        end
        
        
        %**
        % INTERFACE
        % Plot each event in eventArr. Return an annotated array of events
        % to which the user added comments. If a ground truth
        % targetDataStruct is provided, plot ground truth along with the
        % rest.
        notes = plot_events(obj, eventArr, varargin);

        %**
        % Plot all detected SPSDs.
        function notes = plot_detected(obj, groundTruthTds)
            if exist('groundTruthTds', 'var')
                notes = obj.plot_events(obj.get_detected_events(), groundTruthTds);
            else
                notes = obj.plot_events(obj.get_detected_events());
            end
        end

        
        %**
        % Plot all rejected SPSDs.
        function notes = plot_rejected(obj)
            notes = obj.plot_events(obj.get_rejected_candidates());
        end
        
        
        %**
        % Plot all non-candidates.
        function notes = plot_noncandidates(obj)
            notes = obj.plot_events(obj.get_noncandidates());
        end
        
        %**
        % INTERFACE
        % Plot each target in targetArr. Return an annotated array of
        % targets to which the user added comments. If a ground truth
        % targetDataStruct is provided, plot ground truth along with the
        % rest.
        notes = plot_targets(obj, targets, groundTruthTds);

    end
    
end

