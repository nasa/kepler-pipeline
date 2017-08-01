function [lcResults, scResults, scSpsdCorrectedFluxObject] = ...
    test_sc(obj, lcCadenceTimes, scInputStruct)
%************************************************************************** 
% [lcResults, scResults, scSpsdCorrectedFluxObject] = 
%     test_sc(obj, lcCadenceTimes, scInputStruct) 
%************************************************************************** 
% Perform SPSD simulation tests on short cadence data. As with long-cadence
% tests, the object contains the long cadence target data struct as a
% property. Overlapping SC monthly time series must be provided as
% arguments to this fucntion.
%
% INPUTS:
%     lcCadenceTimes     : The cadenceTimes struct from the LC PDC input
%                          struct. 
%     scInputStruct      : A struct containing one SC month of cadence
%                          times and target data for the same mod-out and
%                          quarter as the LC data. 
%                          
% OUTPUTS:
%     lcResults          : A struct returned by analyze_sc_results().
%
%     scResults          : A struct returned by analyze_sc_results().
%
%     spsdCorrectedFluxObject :
%                          The spsdCorrectedFluxClass object used for
%                          short-cadence processing. The results contained
%                          in this object can be examined using
%                          spsdResultsAnalysisClass.
%
% NOTES:
%     The object property obj.eventParams.nEvents specifies the number of
%     simulated SPSDs distributed over all targets in the month of SC input
%     (scInputStruct).   
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
    lcInputStruct = struct('cadenceTimes', lcCadenceTimes, ...
                           'targetDataStruct', obj.cleanTargetDataStruct);
    scCadenceTimes = scInputStruct.cadenceTimes;
    
    %----------------------------------------------------------------------
    % Generate Events
    %----------------------------------------------------------------------
    % Determine overlapping kepler IDs and LC cadence indices for each scInputStruct.
    obj.eventParams.keplerIds = intersect([lcInputStruct.targetDataStruct.keplerId], ...
                                          [scInputStruct.targetDataStruct.keplerId]);
    obj.eventParams.cadences = find(...
          lcCadenceTimes.startTimestamps >= scCadenceTimes.startTimestamps(1) ...
        & lcCadenceTimes.endTimestamps   <= scCadenceTimes.endTimestamps(end) );
    events = obj.generate_random_events();
    
    
    %----------------------------------------------------------------------
    % Process LC
    %----------------------------------------------------------------------
    [lcResults, lcSpsdCorrectedFluxObject] = obj.test(events);
        
    % Create blob from LC SPSD output
    spsdBlob = compile_spsd_blob(lcInputStruct, struct(lcSpsdCorrectedFluxObject));
    
    %----------------------------------------------------------------------
    % Convert LC events to SC and instantiate a simulation tester object
    % for the SC data.
    %----------------------------------------------------------------------
    scEvents = [];
    for j = 1:numel(events)
        scEvents = [scEvents, convert_lc_event_to_sc_event(events(j), lcCadenceTimes, scInputStruct)];
    end
    scParams = obj.spsdParams;
    scParams.spsdDetectionConfigurationStruct.quickSpsdEnabled = true;
    scSimulationTesterObject = spsdSimulationTesterClass(scParams, scInputStruct.targetDataStruct, []);

    preLoadedEvents = spsdBlob;
    preLoadedEvents.cadenceStartTimes = scInputStruct.cadenceTimes.startTimestamps;
    preLoadedEvents.cadenceEndTimes   = scInputStruct.cadenceTimes.endTimestamps;
    preLoadedEvents.shortCadenceTimes = scInputStruct.cadenceTimes;

    %----------------------------------------------------------------------
    % Perform the test.
    %----------------------------------------------------------------------
    if ~isempty(scEvents)
        [scResults, scSpsdCorrectedFluxObject] = scSimulationTesterObject.test(scEvents, preLoadedEvents);
    end

end        

% The poorly-chosen parameter recoverySpeed can be thought of as the 
% inverse mean lifetime.
function scEvent = convert_lc_event_to_sc_event(lcEvent, lcCadenceTimes, scInputStruct)
    scCadenceTimes = scInputStruct.cadenceTimes;
    lcDuration = lcCadenceTimes.endTimestamps(lcEvent.cadence) - lcCadenceTimes.startTimestamps(lcEvent.cadence);
    lcStartTime = lcCadenceTimes.startTimestamps(lcEvent.cadence);
    t =  lcStartTime + lcEvent.tDrop * lcDuration;       % Time (mjd) of sensitivity drop 
    
    if ~ismember(lcEvent.keplerId, [scInputStruct.targetDataStruct.keplerId] ) ...   % The event target is not in the set of SC targets.
            || t < min(scCadenceTimes.startTimestamps) ... % The event is out of the SC range.
            || t > max(scCadenceTimes.endTimestamps)       
        scEvent = [];
    else % The event occurs within the short cadence time series.
        avgLcPeriod = mean(diff(lcCadenceTimes.startTimestamps));
        avgScPeriod = mean(diff(scCadenceTimes.startTimestamps));

        scEvent = lcEvent;
        scEvent.recoverySpeed = lcEvent.recoverySpeed * avgScPeriod / avgLcPeriod;
        scEvent.cadence = find(t - scCadenceTimes.startTimestamps > 0, 1, 'last');
        scEvent.tDrop = (t - scCadenceTimes.startTimestamps(scEvent.cadence)) ...
            / (scCadenceTimes.endTimestamps(scEvent.cadence) - scCadenceTimes.startTimestamps(scEvent.cadence));
    end
end

