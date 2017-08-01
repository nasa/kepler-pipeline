function notes = plot_targets(obj, targets, groundTruthTds )
%==========================================================================
% function notes = plot_events(obj, groundTruthTds )
%==========================================================================
% Interactively review results of spsdCorrectedFluxClass. Plot all events
% detected for a given target.
% 
% INPUTS:
%     targets        : An array of kepler IDs:
%     groundTruthTds : A targetDataStruct containing ground truth flux
%                      values.
%
% OUTPUTS: 
%     notes          : An array of structures, with annotation
%                      added in the form of a comments field.
%
%                      annotationStruct
%                       |-.keplerId
%                       |-.spsdCadences
%                       |-.rejectedCadences
%                       |-.noncandidateCadences
%                       |-.comment
%
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

    % Constants
    DEFAULT_LINE_WIDTH = 2.0;
    SPSD_LINE_WIDTH = 2;
    REJECTED_LINE_WIDTH = 2;
    NONCANDIDATE_LINE_WIDTH = 1;
    SPSD_LINE_COLOR = 'black';
    CORRECTION_LINE_COLOR = 'magenta';
    UNCORRECTED_FLUX_LABEL = 'Uncorrected Flux'; %'SPSD Input Flux'
    CORRECTED_FLUX_LABEL   = 'Corrected Flux';   %'SPSD Output Flux'
    Y_DATA_OFFEST_PERCENT = 0; % Apply an offset (percent of plotted y-range) to the corrected flux and ground truth
    
    spsdMap = [[0, 0, 0]; colormap(lines(20))]; % Set the first color to black.
    
    correctionAvailable = false;
    groundTruthAvailable = false;
    notes = [];
    
    tds = obj.inputTargetDataStruct;
    nCadences = length(tds(1).values);
    
    if ~exist('targets', 'var')
        targets = [tds.keplerId];
    end
    
    if exist('groundTruthTds', 'var')
        groundTruthAvailable = true;
    end
    
    %----------------------------------------------------------------------
    % Get lists of events.
    %----------------------------------------------------------------------
    detectedEvents = obj.get_detected_events();
    rejectedEvents = obj.get_rejected_candidates();
    noncandidateEvents = obj.get_noncandidates();
  
    %----------------------------------------------------------------------
    % Loop over all targets.
    %----------------------------------------------------------------------
    fprintf('---------------------------------------------------------------------------\n');
    fprintf(['Commands: \n  q = quit | c = comment on current event | b = previous event \n' ...
             '  r = reverse direction | s = change step size | \n' ...
             '  RETURN = next event without comment\n']);
    fprintf('---------------------------------------------------------------------------\n');

    i = 1;
    step = 1;
    while i > 0 && i <= length(targets) 

        kepId = targets(i);
        targetInd = find([tds.keplerId] == kepId);
        if isempty(targetInd)
            continue;
        end

        detectedInThisTarget = detectedEvents([detectedEvents.keplerId] == kepId);
        
        % This code is here for backward compatability. Future versions
        % should identify targets by Kepler ID. Identifcation by index is
        % flawed, since the indices for rejected and non-cadidate targets
        % are only valid for the first iteration. Detected indices are
        % valid, however.
        if isfield('rejectedEvents', 'keplerId')
            rejectedInThisTarget = rejectedEvents([rejectedEvents.keplerId] == kepId);
            noncandInThisTarget = noncandidateEvents([noncandidateEvents.keplerId] == kepId);
        else
            rejectedInThisTarget = rejectedEvents([rejectedEvents.index] == targetInd);
            noncandInThisTarget = noncandidateEvents([noncandidateEvents.index] == targetInd);
        end
        
        fprintf('\n----------\n');
        fprintf('Target index = %d | Kepler ID = %d\n', targetInd, kepId);
        
        %------------------------------------------------------------------
        % Get raw and corrected flux, if a correction is available.
        % Corrections are assumed to be additive. That is, 
        %     correctedFlux = inputFlux + correction
        %------------------------------------------------------------------
        inputFlux = tds(targetInd).values;
        if ~isempty(detectedInThisTarget)
            correctionAvailable = true;
            results = obj.get_results;
            cumulativeCorrection = results.spsds.targets(find([results.spsds.targets.index] == targetInd)).cumulativeCorrection;
            correctedFlux = inputFlux + cumulativeCorrection;
        else
            correctionAvailable = false;
        end 

        %------------------------------------------------------------------
        % Determine plotting ranges
        %------------------------------------------------------------------
        xRange = [1, nCadences];
        cadences = [xRange(1):xRange(2)];
        
        validFluxInd = cadences(~tds(targetInd).gapIndicators(cadences));
        if correctionAvailable
            yRange = [ min( [inputFlux(validFluxInd); correctedFlux(validFluxInd)] ), ...
                       max( [inputFlux(validFluxInd); correctedFlux(validFluxInd)] ) ];       
        else
            yRange = [ min( inputFlux(validFluxInd) ), max( inputFlux(validFluxInd) ) ]; 
        end
        
        %------------------------------------------------------------------
        % Plot
        % 1) The input target flux
        % 2) The corrected target flux
        % 3) Each detected event, annotated (iteration, )
        % 4) Each rejected event, annotated (iteration, )
        % 5) Each noncandidate event, annotated (iteration, )
        %------------------------------------------------------------------
        figure(1)
        hold off
        
        % Plot input flux
        h = plot(cadences, inputFlux(cadences), 'b', 'LineWidth', DEFAULT_LINE_WIDTH);
        legendLabels = {UNCORRECTED_FLUX_LABEL};
        axis([xRange yRange]);
        grid on
        hold on

        % Plot ground truth flux, if provided.
        if groundTruthAvailable
            plot(cadences, groundTruthTds(targetInd).values(cadences), 'k', 'LineWidth', DEFAULT_LINE_WIDTH);
            legendLabels(end+1) = {'Ground Truth'};
        end
        
        % Plot corrected flux.
        if correctionAvailable    
            plot(cadences, correctedFlux(cadences), 'r', 'LineWidth', DEFAULT_LINE_WIDTH);
            legendLabels(end+1) = {CORRECTED_FLUX_LABEL};
        end
        
      
        % Plot each detected SPSD.
        for j = 1:numel(detectedInThisTarget)
            spsdCadence = detectedInThisTarget(j).cadence;
            iteration   = detectedInThisTarget(j).iteration;
            color = spsdMap(iteration,:);
            plot([spsdCadence spsdCadence],[yRange(1) yRange(2)],'LineStyle','--', ...
                'Color', color, 'LineWidth', SPSD_LINE_WIDTH);
            legendLabels(end+1) = {['SPSD, iteration ', num2str(iteration)]};
        end
        
        % Plot each rejected candidate.
        for j = 1:numel(rejectedInThisTarget)
            spsdCadence = rejectedInThisTarget(j).cadence;
            iteration   = rejectedInThisTarget(j).iteration;
            color = spsdMap(iteration,:);
            plot([spsdCadence spsdCadence],[yRange(1) inputFlux(spsdCadence)],'LineStyle','-.', ...
                'Color', color, 'LineWidth', REJECTED_LINE_WIDTH);
            legendLabels(end+1) = {['rejected, iteration ', num2str(iteration)]};
        end
        
        % Plot each non-candidate.
        for j = 1:numel(noncandInThisTarget)
            spsdCadence = noncandInThisTarget(j).cadence;
            iteration   = noncandInThisTarget(j).iteration;
            color = spsdMap(iteration,:);
            plot([spsdCadence spsdCadence],[yRange(1) inputFlux(spsdCadence)],'LineStyle','-.', ...
                'Color', color, 'LineWidth', NONCANDIDATE_LINE_WIDTH);
            legendLabels(end+1) = {['noncandidate, iteration ', num2str(iteration)]};
        end

        
        % Label the plot
        legend(legendLabels, 'Location', 'SouthWest');        
        title({['Target = ', num2str(targetInd), ';  KID = ', ... 
            num2str(kepId)]});
        xlabel('Cadence','fontsize',12);
        ylabel('Flux (e-/cadence)','fontsize',12);

        %------------------------------------------------------------------
        % Get user input
        %------------------------------------------------------------------
        reply = [];
        reply = input('Command [continue]: ', 's');

        switch reply
            case {'c','C'} % Comment on the current target
                eventStruct = eventArr(i);
                eventStruct.comment  = input('Enter comment: ', 's');
                notes = [notes; eventStruct];
                i = i + step;
            case {'b','B'} % Go back one target
                i = max(1, i - 1);
            case {'r','R'} % Reverse direction
                step = -step;
            case {'s','S'} % Change step size
                fprintf('Current step size = %d\n', step);
                step = fix(str2num(input('Enter new stepsize: ', 's')));
            case {'q','Q'} % QUIT
                break
            otherwise
                i = i + step;
        end

    end

end

