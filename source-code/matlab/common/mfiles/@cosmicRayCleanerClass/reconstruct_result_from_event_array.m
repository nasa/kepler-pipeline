function reconstruct_result_from_event_array(obj, cosmicRayEvents, ...
                                 midCadenceTimes, convertEventsToZeroBased)        
%************************************************************************** 
% function reconstruct_result_from_event_array(obj, cosmicRayEvents, ...
%                                midCadenceTimes, convertEventsToZeroBased)   
%**************************************************************************
% Reconstruct the estimated cosmic ray pixel time series from an event  
% array and add the time series to the targetArray. The timestamps on each
% cosmic ray event struct are the mid-cadence MJDs.
%
% INPUTS
%     cosmicRayEvents  : An array of cosmic ray event structures as found
%                        in the pa_state.mat file.
%     midCadenceTimes  : An array of mid-cadence timestamps (MJD)
%                        corresponding to the time series in obj.
%     convertEventsToZeroBased : Usually this function will be called
%                        offline. This means the paInputStruct used to
%                        build the object has 0-based ccd coordinates. We
%                        will also likely be using the cosmicRayEvents
%                        array found in the pa_state.mat file, which
%                        contains 1-based pixel coordinates. In this case
%                        we want to subtract 1 from the pixel coordinates
%                        in each element of the cosmicRayEvents array, so
%                        convertEventsToZeroBased should be specified as
%                        'true'. If not specified, we assume
%                        cosmicRayEvents is 1-based unless its pixel
%                        coordinates contain zeros, in which case we know
%                        for certain it is already zero-based.
%
% OUTPUTS
%     This function returns no value, but uses the elements of
%     cosmicRayEvents to reconstruct the object property obj.targetArray.
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
    nCadences = length(obj.timestamps);

    if ~exist('convertEventsToZeroBased', 'var') 
        if min([cosmicRayEvents.ccdRow]) == 0 ...
            || min([cosmicRayEvents.ccdColumn]) == 0 
            % We have concluded that ccdRow and ccdColumn MUST be
            % zero-based already. 
            convertEventsToZeroBased = false;
        else % Assume 1-based.
            convertEventsToZeroBased = true;
        end
    end
    
    % We could find the minimum row and col values and decide automatically
    % whether or not to convert. However, there is no guarantee that cosmic
    % rays will be detected in these pixels, though it is *highly* likely
    % if the detector is functioning remotely well.
    if convertEventsToZeroBased
        nEvents = length(cosmicRayEvents);
        ccdRowCellArray = num2cell([cosmicRayEvents.ccdRow] - 1);
        [cosmicRayEvents(1 : nEvents).ccdRow] = ccdRowCellArray{:};

        ccdColumnCellArray = num2cell([cosmicRayEvents.ccdColumn] - 1);
        [cosmicRayEvents(1 : nEvents).ccdColumn] = ccdColumnCellArray{:};      
    end
    
    eventsRowCol = zeros(numel(cosmicRayEvents),2);   
    eventsRowCol(:,1) = [cosmicRayEvents.ccdRow];
    eventsRowCol(:,2) = [cosmicRayEvents.ccdColumn];
        
    for i = 1:numel(obj.targetArray)
        pixelArray = obj.inputArray(i).pixelDataStruct;
        [pixelArray.(obj.CR_SIGNAL_FIELDNAME)] = deal(zeros(nCadences,1));

        apertureRowCol = [pixelArray.ccdRow; pixelArray.ccdColumn]';
        eventsInThisTarget ...
            = cosmicRayEvents( ...
                ismember(eventsRowCol, apertureRowCol, 'rows') ...
              );        
        
        targetEventsRowCol      = zeros(numel(eventsInThisTarget),2);
        targetEventsRowCol(:,1) = [eventsInThisTarget.ccdRow];
        targetEventsRowCol(:,2) = [eventsInThisTarget.ccdColumn];
    
        for j = 1:numel(pixelArray)
            pixelRowCol = [pixelArray(j).ccdRow, pixelArray(j).ccdColumn];
            eventsInthisPixel ...
                = eventsInThisTarget( ...
                    ismember(targetEventsRowCol, pixelRowCol, 'rows') ...
                  );
            if ~isempty(eventsInthisPixel)
                [tfCadence, relativeCadences] ...
                    = ismember([eventsInthisPixel.mjd], midCadenceTimes);
                pixelArray(j).(obj.CR_SIGNAL_FIELDNAME)(relativeCadences) ...
                    = [eventsInthisPixel(tfCadence).delta];
                pixelArray(j).values ...
                    = pixelArray(j).values - pixelArray(j).(obj.CR_SIGNAL_FIELDNAME);
            end
        end
        obj.targetArray(i).pixelDataStruct = pixelArray;
        
        % Set processing status flag to indicate results are available for
        % this target.
        obj.isCleaned(i) = true;
    end
    
end

% The following attempt to further vectorize this function and hopefully
% speed it up was actually slightly slower and significantly less clear
% than the version with an additional FOR loop over pixels (it DOES produce
% the same result):
% -------------------------------------------------------------------------
%     [tfCadence, relativeCadences] ...
%         = ismember([cosmicRayEvents.mjd], midCadenceTimes); 
%     
%     % Trim events outside the valid cadence range.
%     cosmicRayEvents = cosmicRayEvents(tfCadence);
%     relativeCadences = colvec(relativeCadences(tfCadence));
%     
%     eventsRowCol = zeros(numel(cosmicRayEvents),2);   
%     eventsRowCol(:,1) = [cosmicRayEvents.ccdRow];
%     eventsRowCol(:,2) = [cosmicRayEvents.ccdColumn];
% 
%     for i = 1:numel(obj.targetArray)
%         pixelArray = obj.inputArray(i).pixelDataStruct;
%         pixelValueMat = [pixelArray.values];
%         cosmicRaySignalMat = zeros(nCadences, length(pixelArray));
%         
%         apertureRowCol = [pixelArray.ccdRow; pixelArray.ccdColumn]';
%         [isInThisTarget, pixelIndex] ...
%             = ismember(eventsRowCol, apertureRowCol, 'rows');        
%         cosmicRaySignalMat(sub2ind(size(cosmicRaySignalMat), ...
%                            relativeCadences(isInThisTarget), ...
%                            pixelIndex(isInThisTarget))) ...
%             = [cosmicRayEvents(isInThisTarget).delta];
%         
%         cosmicRaySignalCellArray = num2cell(cosmicRaySignalMat, 1);
%         [pixelArray.(obj.CR_SIGNAL_FIELDNAME)] = cosmicRaySignalCellArray{:};
%         correctedValuesCellArray ...
%             = num2cell(pixelValueMat - cosmicRaySignalMat, 1);
%         [pixelArray.values] = correctedValuesCellArray{:};
%         
%         obj.targetArray(i).pixelDataStruct = pixelArray;
%     end

%********************************** EOF ***********************************

