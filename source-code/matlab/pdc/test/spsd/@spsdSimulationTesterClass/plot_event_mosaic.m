function plot_event_mosaic(obj, eventArr)
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
    for i = 1:floor(nSpsds/nTiles)
        for j = 1:nTiles
            n = i*nTiles + j;

            if n <= nSpsds
                subplot(NROWS, NCOLS, j);
                windowIndices = max(1, eventArr(n).cadence - WINDOW_HALF_WIDTH) : min(eventArr(n).cadence + WINDOW_HALF_WIDTH, nCadences);
                targetIndex = find([simulatedTargetDataStruct.keplerId] == eventArr(n).keplerId);
                plot(windowIndices, simulatedTargetDataStruct(targetIndex).values(windowIndices),'LineWidth', LINE_WIDTH);

                subtitle = [];
                if isfield(eventArr, 'snr')
                    titleStr = ['SNR = ', num2str(eventArr(n).snr, 3)];
                else
                    titleStr = ['Kepler ID = ', num2str(eventArr(n).keplerId)];
                end
                title(titleStr, 'fontsize', TITLE_FONTSIZE, 'FontWeight', TITLE_WEIGHT);
            end
        end
        pause
    end
end