function plot_log_events(obj, eventArr)
% Generate mosaics of injected SPSDs
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

    NROWS = 2;
    NCOLS = 3;
    WINDOW_HALF_WIDTH = 96;
    LINE_WIDTH = 1;
    TITLE_FONTSIZE = 12;
    TITLE_WEIGHT = 'bold';
    
    nTiles = NROWS * NCOLS;
    nSpsds = numel(eventArr);
    
    simulatedTargetDataStruct = obj.inject_events( eventArr );
    nCadences = length(simulatedTargetDataStruct(1).values);
    
    figure
    for i = 1:numel(eventArr)
        windowIndices = max(1, eventArr(i).cadence - WINDOW_HALF_WIDTH) : min(eventArr(i).cadence + WINDOW_HALF_WIDTH, nCadences);
        targetIndex = find([simulatedTargetDataStruct.keplerId] == eventArr(i).keplerId);

        % Plot time series window
        ha(1) = subplot(2, 2, 1);
        plot(windowIndices, simulatedTargetDataStruct(targetIndex).values(windowIndices),'LineWidth', LINE_WIDTH);
        title('r(t)', 'fontsize', TITLE_FONTSIZE, 'FontWeight', TITLE_WEIGHT);

        % Plot log time series window
        ha(2) = subplot(2, 2, 2);
        plot(windowIndices, log(simulatedTargetDataStruct(targetIndex).values(windowIndices)),'LineWidth', LINE_WIDTH);
        title('log r(t)', 'fontsize', TITLE_FONTSIZE, 'FontWeight', TITLE_WEIGHT);
        
        % Plot log signal
        ha(3) = subplot(2, 2, 3);
        sensitivityProfile = obj.create_spsd_profile( eventArr(i).dropSize, ...
            eventArr(i).tDrop, eventArr(i).recoveryFraction, ...
            eventArr(i).recoverySpeed);

        envelope = ones(size(windowIndices));
        offset = find(windowIndices == eventArr(i).cadence);
        envelope  = [ ones( offset - 1, 1); ...
                  sensitivityProfile];
        lengthDiff = length(windowIndices) - length(envelope);
        if lengthDiff > 0
            envelope = [envelope; sensitivityProfile(end)*ones(lengthDiff,1)];
        else
            envelope = envelope(1:length(windowIndices));
        end
        plot(windowIndices, log(envelope),'LineWidth', LINE_WIDTH);
        title('log s(t)', 'fontsize', TITLE_FONTSIZE, 'FontWeight', TITLE_WEIGHT);
        
        % Plot log noise
        ha(4) = subplot(2, 2, 4);
        plot(windowIndices, log(obj.cleanTargetDataStruct(targetIndex).values(windowIndices)),'LineWidth', LINE_WIDTH);
        title('log n(t)', 'fontsize', TITLE_FONTSIZE, 'FontWeight', TITLE_WEIGHT);

        linkaxes(ha,'x');

        pause
    end

end