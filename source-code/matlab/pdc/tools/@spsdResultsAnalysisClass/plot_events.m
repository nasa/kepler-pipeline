%==========================================================================
% function notes = plot_events(obj, eventArr, groundTruthTds, figureHandle, interactiveFlag)
%==========================================================================
% Interactively review results of spsdCorrectedFluxClass
% 
% INPUTS:
%     eventArr       : An array of SPSD event structures, containing at 
%                      least the following fields:
%
%                          eventStruct
%                          |-.keplerid
%                          |-.cadence
%                          :
%
%     groundTruthTds : [OPTIONAL] A targetDataStruct containing ground truth flux
%                      values.
%
%     figureHandle   : [integer OPTIONAL] if present then use this figure handle for plotting
%
%     interactiveFlag : [OPTIONAL] if present and false then do not run interactive mode (notes and zooming, etc...)
%                       If not doing interactive then only the SPSDs for one target should be passed (i.e. length(eventArr) == 1) and a simple pause is between
%                       each SPSD plot
%                       default is TRUE
%
% OUTPUTS: 
%     notes          : An array of SPSD event structures, with annotation
%                      added in the form of a comments field.
%
%                          eventStruct
%                          |-.keplerid
%                          |-.cadence
%                          |-.comments
%                          :
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

%function notes = plot_events(obj, eventArr, groundTruthTds, figureHandle, interactiveFlag)
function notes = plot_events(obj, eventArr, varargin)

    % Constants
    WINDOW_SIZE = 601;
    SD_PRECISION = 2; % Significant digits in displayed sensititivity drop (subtitle).
    DEFAULT_LINE_WIDTH = 2.0;
    SPSD_LINE_WIDTH = 2;
    SPSD_LINE_COLOR = 'black';
    CORRECTION_LINE_COLOR = 'magenta';
    UNCORRECTED_FLUX_LABEL = 'Uncorrected Flux'; %'SPSD Input Flux'
    CORRECTED_FLUX_LABEL   = 'Corrected Flux';   %'SPSD Output Flux'
    Y_DATA_OFFEST_PERCENT = 0; % Apply an offset (percent of plotted y-range) to the corrected flux and ground truth
    
    correctionAvailable = false;
    groundTruthAvailable = false;
    overlayCorrection = true;       % Overlay the (negated) additive correction on the input time series.
    zoomFactor = 2.0;
    doInteractive = true;   % have a manual pause between plots and allow for interactive zooming and saving notes
    notes = [];
    
    tds = obj.inputTargetDataStruct;
    nCadences = length(tds(1).values);
    
    if (nargin >= 3 && ~isempty(varargin{1}))
        groundTruthTds = varargin{1};
        groundTruthAvailable = true;
    end
    
    if (nargin >= 4 && ~isempty(varargin{2}))
        figureHandle = varargin{2};
    end

    if (nargin >= 5 && ~isempty(varargin{3}))
        doInteractive = varargin{3};
    end

    %----------------------------------------------------------------------
    % Loop over all events.
    %----------------------------------------------------------------------
    if (doInteractive)
        fprintf('---------------------------------------------------------------------------\n');
        fprintf(['Commands: \n  q = quit | c = comment on current event | b = previous event \n' ...
                 '  r = reverse direction | s = change step size | z = change zoom \n' ...
                 '  RETURN = next event without comment\n']);
        fprintf('---------------------------------------------------------------------------\n');
    end

    if (exist('figureHandle', 'var'))
        figure(figureHandle);
    else
        figureHandle = figure;
    end

    i = 1;
    step = 1;
    while (i > 0 && i <= length(eventArr))

        % reclaim the correct figure
        figure(figureHandle);

        if isfield(eventArr(i), 'keplerId')
            kepId = eventArr(i).keplerId;
            targetInd = find([tds.keplerId] == kepId);
        elseif isfield(eventArr(i), 'index')
            targetInd = eventArr(i).index;            
            kepId = tds(targetInd).keplerId;
        else
            fprintf('Invalid event struct.');
            break
        end
        
        spsd = eventArr(i).cadence;
        fprintf('\n----------\n');
        display(['Plotting event ', num2str(i), ' of ', num2str(length(eventArr))]);
        fprintf('Target index = %d | Kepler ID = %d | SPSD cadence = %d\n', targetInd, kepId, spsd);
        if isfield(eventArr(i), 'comment')
            fprintf('Comments about this event: %s\n', eventArr(i).comment);
        end
        
        %------------------------------------------------------------------
        % Get raw and corrected flux, if a correction is available.
        % Corrections are assumed to be additive. That is, 
        %     correctedFlux = inputFlux + correction
        %------------------------------------------------------------------
        inputFlux = tds(targetInd).values;
        if isfield(eventArr(i), 'correction')
            correctionAvailable = true;
            correctedFlux = inputFlux + eventArr(i).correction;
        end 

        %------------------------------------------------------------------
        % Determine plotting ranges
        %------------------------------------------------------------------
        xRange = [max(1, spsd - floor(zoomFactor*WINDOW_SIZE/2)), min(nCadences, spsd + floor(zoomFactor*WINDOW_SIZE/2))];
        xRangeInd = [xRange(1):xRange(2)];
        
        validFluxInd = xRangeInd(~tds(targetInd).gapIndicators(xRangeInd));
        if correctionAvailable
            yRange = [ min( [inputFlux(validFluxInd); correctedFlux(validFluxInd)] ), ...
                       max( [inputFlux(validFluxInd); correctedFlux(validFluxInd)] ) ];       
        else
            yRange = [ min( inputFlux(validFluxInd) ), max( inputFlux(validFluxInd) ) ]; 
        end
        halfRange = (yRange(2) -  yRange(1) )/2;
        yCenter   = yRange(1) + halfRange;
        yRange    = [yCenter - zoomFactor*halfRange, yCenter + zoomFactor*halfRange];
        
        %------------------------------------------------------------------
        % Generate the plot
        %------------------------------------------------------------------
        offset = (Y_DATA_OFFEST_PERCENT/100) * (yRange(2)-yRange(1));
        
        hold off
        
        % Plot input flux
        h = plot(inputFlux, 'b', 'LineWidth', DEFAULT_LINE_WIDTH);
        legendLabels = {UNCORRECTED_FLUX_LABEL};
        axis([xRange yRange]);
        grid on
        hold on

        % Plot ground truth flux, if provided.
        if groundTruthAvailable
            plot(groundTruthTds(targetInd).values + offset, 'k', 'LineWidth', DEFAULT_LINE_WIDTH);
            legendLabels(end+1) = {'Ground Truth'};
        end
        
        % Plot corrected flux and overlay the correction by shifting it up
        % to the level of the signal.
        if correctionAvailable    
            plot(correctedFlux + 2*offset, 'r', 'LineWidth', DEFAULT_LINE_WIDTH);
            legendLabels(end+1) = {CORRECTED_FLUX_LABEL};
            
            if overlayCorrection
                lastZeroCorrectionCadence = find(eventArr(i).correction == 0, 1, 'last');
                lastZeroCorrectionFluxValue = inputFlux(lastZeroCorrectionCadence);
                xModel = lastZeroCorrectionCadence + 1:length(eventArr(i).correction);
                yModel = lastZeroCorrectionFluxValue - eventArr(i).correction(lastZeroCorrectionCadence + 1:end);
                plot(xModel, lastZeroCorrectionFluxValue*ones(length(xModel),1), CORRECTION_LINE_COLOR, 'LineWidth', SPSD_LINE_WIDTH, 'LineStyle','--');
                plot(xModel, yModel, CORRECTION_LINE_COLOR, 'LineWidth', SPSD_LINE_WIDTH, 'LineStyle','-');
                legendLabels(end+1:end+2) = {'Correction Zero Point', 'Correction'};
            end
        end
            
        % Mark the location of the SPSD cadence.
        line([spsd spsd],[yRange(1) yRange(2)],'LineStyle','--', ...
            'Color', SPSD_LINE_COLOR, 'LineWidth', SPSD_LINE_WIDTH);
        legendLabels(end+1) = {'SPSD cadence'};
        
        legend(legendLabels, 'Location', 'SouthWest');

        
        if isfield(eventArr(i), 'deltaSensitivity')
            subtitle = ['(estimated sensitivity drop = ', num2str(100*eventArr(i).deltaSensitivity, SD_PRECISION), ' %)'];
        else
            subtitle = '(sensitivity drop unavailable)';
        end
        
        title({['Target = ', num2str(targetInd), ';  KID = ', ... 
            num2str(kepId), ';  Cadence = ', num2str(spsd) ]; subtitle });
        xlabel('Cadence','fontsize',12);
        ylabel('Flux (e-/cadence)','fontsize',12);

        if (doInteractive)
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
                case {'z','Z'} % Change the zoom factor
                    fprintf('Current zoom factor = %d\n', zoomFactor);
                    zoomFactor = str2num(input('Enter new zoom factor: ', 's'));
                case {'q','Q'} % QUIT
                    break
                otherwise
                    i = i + step;
            end
        else
            i = i + step;
            % If no interactive mode then just do a simple pause between SPSDs ( only if there is another SPSD to plot
            if ((i > 0 && i <= length(eventArr)))
                disp('Another SPSD for this target is ready to be plotted...');
                pause;
            end
        end

    end

end

