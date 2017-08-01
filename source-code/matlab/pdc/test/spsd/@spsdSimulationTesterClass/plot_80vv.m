function plot_80vv(obj, resultsAnalysis, manualAvgDrop, manualProbHit, manualProbFa) 
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
    LEGEND_FONTSIZE = 12;
    LINE_WIDTH = 2;
    SIMULATED_MARKER_SIZE = 6;
    MANUAL_MARKER_SIZE = 16;
    
    pHit = zeros(numel(resultsAnalysis),1);
    pFA  = zeros(numel(resultsAnalysis),1);

    %----------------------------------------------------------------------
    % 
    %----------------------------------------------------------------------
    sensitivityDropsPpm = zeros(numel(resultsAnalysis),1);
    for i = 1:numel(resultsAnalysis)        
        % Convert fractional sensitivity drop to partsper-million.
        sensitivityDropsPpm(i) = 1e6 * resultsAnalysis(i).simulatedEvents(1).dropSize;
        pHit(i) = resultsAnalysis(i).performance.Phit;
        pFA(i)  = resultsAnalysis(i).performance.Pfa;
    end
        
    %----------------------------------------------------------------------
    % Generate performance plot
    %----------------------------------------------------------------------
    pHit(1) = max(pHit(1), 0.000001); % Make non-zero for log plotting.
    fpRateLimit = obj.spsdParams.spsdDetectionConfigurationStruct.falsePositiveRateLimit;
    
    hold off
    loglog(sensitivityDropsPpm, pHit,'b*-', 'MarkerSize', SIMULATED_MARKER_SIZE, 'LineWidth', LINE_WIDTH);
    grid on
    hold on
    legendStrArray = {'Simulation P(hit)'};

    if exist('manualProbHit','var') && exist('manualAvgDrop','var')
        loglog(1e6 * manualAvgDrop, manualProbHit, 'bx', 'MarkerSize', MANUAL_MARKER_SIZE, 'LineWidth', LINE_WIDTH);
        legendStrArray(end+1) = {'manually estimated P(hit)'};
    end
    
    loglog(sensitivityDropsPpm, pFA, 'r*-', 'MarkerSize', SIMULATED_MARKER_SIZE, 'LineWidth', LINE_WIDTH);
    legendStrArray(end+1) = {'Simulation P(false alarm)'};
    
    if exist('manualProbFa','var')
        line([sensitivityDropsPpm(1) sensitivityDropsPpm(end)],[manualProbFa manualProbFa],'LineStyle','--', 'Color', 'r', 'LineWidth', LINE_WIDTH);
        legendStrArray(end+1) = {'manually estimated P(false alarm)'};
    end
    
    line([sensitivityDropsPpm(1) sensitivityDropsPpm(end)],[fpRateLimit fpRateLimit],'LineStyle','--', 'Color', 'k', 'LineWidth', LINE_WIDTH);
    legendStrArray(end+1) = {'false alarm rate limit'}

    axis([1e2 2e4 1e-5 1]);
    title({'\bf\fontsize{12}Estimated hit and false alarm probabilities vs. sensitivity drop'; 'Mod.out 13.1'});
    xlabel('Sensitivity Drop (ppm)','fontsize',12);
    ylabel('Est. Probability','fontsize',12);
    legend(legendStrArray, 'Location', 'Best', 'fontsize', LEGEND_FONTSIZE);

end