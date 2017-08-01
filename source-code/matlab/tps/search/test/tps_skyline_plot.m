%**************************************************************************
% function [xData, yData, quarters] = tps_skyline_plot( tceStruct, tpsInputsStruct, varargin)
%
% Generate a TPS "skyline plot".
%
% INPUTS
%     tceStruct             A TPS TCE struct constructed from the
%                           tpsDawgStruct. The following fields are used:
%
%                           keplerId
%                           pulseDurations
%                           epochKjd
%                           periodDays
%                           isPlanetACandidate
%                           maxMesPulseNumber
%                           maxSes
%
%     tpsInputsStruct       An arbitrary input struct from the same task as
%                           tceStruct.
%
%     All remaining inputs are optional attribute/value pairs. Valid
%     attributes and values are: 
%    
%     Attribute             Value
%     ---------             -----
%     'label'               A string to display in the subtitle (e.g., 
%                           'SOC 9.3, ksop-2166').
%     'periodLowerBoundDays' Only events with periods greater than this
%                           value will be included in the histogram
%                           (default = 0).  
%     'applySes2MesVeto'    If true, plot apply the max SES / max MES veto
%                           (default = false). 
%     'selectedKeplerIds'   [integer array(nTaregets)] lis of specific KeplerIds to use
%                           (default = use all TCEs tceStruct)
%
% OUTPUTS
%     xData                 An N-length array containing the histogram bin
%                           centers (time in KJD).
%     yData                 An N-length array containing the number of
%                           events in each bin. 
%     quarters              An N-length array indicating which quarter each
%                           data point in xData and yData belongs to. Gaps
%                           are indicated by values of -1. 
% NOTES
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
function [xData, yData, quarters] = tps_skyline_plot( tceStruct, tpsInputsStruct, varargin)

    TOTAL_NUM_QUARTERS   = 18;
    QUARTER_MARKER_COLOR = [0 0 0];    
    QUARTER_MARKER_ALPHA = 1;
    GAP_MARKER_COLOR     = [0.8 0.8 0.8];
    GAP_MARKER_ALPHA     = 0.2;
    
    dynamicallyUpdateFlag = false;
    useCINFlag            = false;

    %----------------------------------------------------------------------
    % Parse and validate arguments.
    %----------------------------------------------------------------------
    parser = inputParser;
    parser.addRequired('tceStruct',                     @(s)isstruct(s) || isempty(s)       );
    parser.addRequired('tpsInputsStruct',               @(s)isstruct(s) || isempty(s)       );
    parser.addParamValue('label',                   '', @(s)ischar(s)  || iscellstr(s)      );
    parser.addParamValue('periodLowerBoundDays',     0, @(x)isnumeric(x) && length(x) == 1  );
    parser.addParamValue('applySes2MesVeto',     false, @(x)islogical(x) && length(x) == 1  );
    parser.addParamValue('selectedKeplerIds',       [], @(x)isnumeric(x) && ~isempty(x)  );
    parser.parse(tceStruct, tpsInputsStruct, varargin{:});
    
    label                = parser.Results.label;
    periodLowerBoundDays = parser.Results.periodLowerBoundDays;
    applySes2MesVeto     = parser.Results.applySes2MesVeto;
    selectedKeplerIds    = parser.Results.selectedKeplerIds;
    
    %----------------------------------------------------------------------
    % Create the skyline plot.
    %----------------------------------------------------------------------
    if (exist('selectedKeplerIds','var') && ~isempty(selectedKeplerIds))
        targetIndicator = ismember(tceStruct.keplerId, selectedKeplerIds) & logical(tceStruct.isPlanetACandidate);
    else
        targetIndicator = logical(tceStruct.isPlanetACandidate);
    end


    targetIndicator = targetIndicator & tceStruct.periodDays > periodLowerBoundDays;
    
    if applySes2MesVeto
        veto = (tceStruct.maxSes ./ tceStruct.maxMes) > 0.9 & tceStruct.periodDays > 90;
        targetIndicator = targetIndicator & ~veto;
    end
    
    % Construct title and subtitle.
    subtitleStr = '(';
    if ~isempty(label)
        subtitleStr = [subtitleStr, label, ', '];
    end
    subtitleStr = [subtitleStr, sprintf('period > %0.1f days', periodLowerBoundDays)];
    if applySes2MesVeto
        subtitleStr = [subtitleStr, ', maxSes/maxMes > 0.9'];
    end
    subtitleStr = strcat(subtitleStr, ')');
    titleStr = {'Histogram of Cadences Contributing to MES', subtitleStr};
    
    [xData, yData] = construct_cadence_histogram(tceStruct, tpsInputsStruct, ...
        dynamicallyUpdateFlag, targetIndicator, useCINFlag, titleStr);

    %----------------------------------------------------------------------
    % Mark gaps and quarter boundaries.
    %----------------------------------------------------------------------
    midTimeStamps = tpsInputsStruct.cadenceTimes.midTimestamps;
    gapIndicators = tpsInputsStruct.cadenceTimes.gapIndicators;
    midTimeStamps(gapIndicators) = interp1( find(~gapIndicators), ...
        midTimeStamps(~gapIndicators), find(gapIndicators), 'linear', 'extrap');    
    kjd           = midTimeStamps - kjd_offset_from_mjd;
    quarters      = tpsInputsStruct.cadenceTimes.quarters;

    validQuarters = unique(quarters(quarters >= 0));
    quarterStartTimesKjd = nan(TOTAL_NUM_QUARTERS,1);
    for q = rowvec(validQuarters)
        idx = find(quarters == q, 1, 'first');
        if ~isempty(idx)
            quarterStartTimesKjd(q+1) = kjd(idx);
        end
    end
    
    mark_cadences(gca, kjd(gapIndicators), ...
        GAP_MARKER_COLOR, GAP_MARKER_ALPHA);
    
    mark_cadences(gca, quarterStartTimesKjd, ...
        QUARTER_MARKER_COLOR, QUARTER_MARKER_ALPHA);
    
    % Label quarters.
    y = ylim;
    ypos = y(2); 
    for q = rowvec(validQuarters)
        text(quarterStartTimesKjd(q+1), ypos, sprintf('Q%d', q), ...
            'HorizontalAlignment', 'left', 'VerticalAlignment', 'top', ...
            'fontsize', 12, 'fontweight', 'bold');
    end
    
end

%**************************************************************************  
% p = mark_cadences(h, cadences, color, alpha)
%**************************************************************************  
% 
% INPUTS:
%     h             : An axes handle or [] to use current axes.
%     cadences      : List of relative cadences (indices) to mark.
%     color         : A 3-element vector
%**************************************************************************        
function p = mark_cadences(h, cadences, color, alpha)

    if ~any(cadences)
        return
    end

    if ~ishandle(h)
        h = gca;
    end
        
    if ~exist('color','var')
        color = [0.7 0.7 0.7];
    end

    if ~exist('alpha','var')
        alpha = 0.2;
    end
    
    axes(h);
    
    original_hold_state = ishold(h);
    if original_hold_state == false
        hold on
    end
    
    nCadences = length(cadences);
    xCoords = repmat(cadences(:)',4,1) + repmat([-0.5; 0.5; 0.5; - 0.5], 1, nCadences);
    xCoords = reshape(xCoords, 4*nCadences, 1);
    ylimits = get(h,'ylim');
    yCoords = repmat([ylimits(1); ylimits(1); ylimits(2); ylimits(2)], nCadences, 1);
    
    verts  = [xCoords, yCoords];
    nVerts = length(verts);
    nRect  = fix(nVerts/4);
    faces  = reshape([1:nVerts]', 4, nRect)';
    
    p = patch('Faces',faces,'Vertices',verts,'FaceColor',color,'facealpha',alpha,'linestyle','none');
    
    if original_hold_state == false
        hold off
    end
end


%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function outlierStruct = construct_cadence_histogram(tceStruct, ...
%     inputsStruct, targetIndicator)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% Inputs:
%        1) tceStruct:  The tceStruct constructed from the tpsDawgStruct
%        2) inputsStruct:  A dummy TPS input from the run
%        3) dynamicallyUpdateFlag: boolean to specify whether the plot
%        should be dynamically updated.  It takes longer to plot if
%        dynamically updating.
%        4) targetIndicator: A logical vector equal in length to
%        tceStruct.keplerId that tells which targets to use for the
%        construction of the cadence histogram - typically this would be
%        all the TCE's or a set of false alarms.
%        5) useCINFlag: if true, the x-axis will be CIN.  If false, it will
%        be in KJD.
%
% Outputs:
%         outlierStruct: A struct that contains information for the points
%         above various sigma cuts such as the associated kepler Id's, the
%         number of targets contributing, the number of points above x
%         sigma, and the outlier cadence numbers.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function [xData, yData, cadencesToOutput, numMaxMesAtCadences] ...
    = construct_cadence_histogram(tceStruct, inputsStruct, ...
    dynamicallyUpdateFlag, targetIndicator, useCINFlag, titleStr)

    if ~exist('titleStr', 'var')
        titleStr = 'Histogram of Cadences Contributing to MES';
    end
    
    pipelineDurations = tceStruct.pulseDurations;
    numTces = sum(targetIndicator);

    epochs = tceStruct.epochKjd(targetIndicator);
    periods = tceStruct.periodDays(targetIndicator);
    pulseNumbers = tceStruct.maxMesPulseNumber(targetIndicator);
    gapIndicators  = inputsStruct.cadenceTimes.gapIndicators ;
    midTimeStamps = inputsStruct.cadenceTimes.midTimestamps;

    % interpolate across gaps
    midTimeStamps(gapIndicators) = interp1( find(~gapIndicators), ...
        midTimeStamps(~gapIndicators), find(gapIndicators), 'linear', 'extrap');
    midTimeStamps = midTimeStamps - kjd_offset_from_mjd;
    cadenceNumbers = inputsStruct.cadenceTimes.cadenceNumbers;
    numCadences = length(cadenceNumbers);

    numMaxMesAtCadences = zeros(numCadences,1);
    figure

    for i = 1:numTces
        if(periods(i) > 0)

            duration=pipelineDurations(pulseNumbers(i))/24;
            phase = mod((midTimeStamps-epochs(i))/periods(i), 1);
            inTransitPhases = duration/periods(i);
            phasesInTransit = (phase <= inTransitPhases) | (phase > (1-inTransitPhases));
        else
            phasesInTransit = abs(midTimeStamps-epochs(i)) < (0.5*duration);
        end

        numMaxMesAtCadences = numMaxMesAtCadences + phasesInTransit;

        % update plot if we are dynamically plotting
        if dynamicallyUpdateFlag
            if useCINFlag
                semilogy(cadenceNumbers, numMaxMesAtCadences, '.')
            else
                semilogy(midTimeStamps,numMaxMesAtCadences,'.')
            end
            drawnow
        end
    end

    if useCINFlag
        semilogy(cadenceNumbers, numMaxMesAtCadences, '.')
        cadencesToOutput = cadenceNumbers;
    else
        semilogy(midTimeStamps,numMaxMesAtCadences,'.')
        cadencesToOutput = midTimeStamps;
    end
    drawnow

    % highlight cadences above the average

    medianNumber = median(numMaxMesAtCadences);
    stdNumber = std(numMaxMesAtCadences);

    xData = midTimeStamps;
    yData = numMaxMesAtCadences;

    hold on
    if useCINFlag
        plot(cadenceNumbers(abs(numMaxMesAtCadences-medianNumber) > 2*stdNumber), ...
            numMaxMesAtCadences(abs(numMaxMesAtCadences-medianNumber) > 2*stdNumber), 'g.')
        plot(cadenceNumbers(abs(numMaxMesAtCadences-medianNumber) > 3*stdNumber), ...
            numMaxMesAtCadences(abs(numMaxMesAtCadences-medianNumber) > 3*stdNumber), 'r.')
        xlabel('Time (CIN)')
    else
        plot(midTimeStamps(abs(numMaxMesAtCadences-medianNumber) > 2*stdNumber), ...
            numMaxMesAtCadences(abs(numMaxMesAtCadences-medianNumber) > 2*stdNumber), 'g.')
        plot(midTimeStamps(abs(numMaxMesAtCadences-medianNumber) > 3*stdNumber), ...
            numMaxMesAtCadences(abs(numMaxMesAtCadences-medianNumber) > 3*stdNumber), 'r.')
        xlabel('Time (KJD)')
    end 

    ylabel('Counts')
    title(titleStr)
    legend('All points', 'Outliers > 2sigma', 'Outliers > 3sigma')
    grid on
    hold off
end

%********************************** EOF ***********************************
