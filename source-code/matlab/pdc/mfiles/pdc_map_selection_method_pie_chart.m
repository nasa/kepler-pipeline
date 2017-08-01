%************************************************************************************************************* 
% function [figureHandle] = pdc_map_selection_method_pie_chart (pdcOutputsStruct, doSaveFigure)
%
% Creates a Pie Chart of the proportion of targets for each MAP selection method
%
% For Kepler data the selection is just {'multiScaleMap' 'regularMap'}.
% However, For K2 there are four options: {'noFit' 'robut' 'MAP' 'msMAP'}
%
% Inputs:
%   pdcOutputsStruct    -- [pdcOutputsStruct] a stnadard PDC outputs Struct (saved to task directory
%   doSaveFigure        -- [logical] If true then save a file in the current direct entitled 'map_selection_method_pie_chart.fig'
%
% Outputs:
%   noFitArray          -- [logical array(nTargets)] Logical array of targets where No Fit was chosen
%   robustArray         -- [logical array(nTargets)]
%   mapArray            -- [logical array(nTargets)]
%   msMapArray          -- [logical array(nTargets)]
%************************************************************************************************************* 
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

function [noFitArray, robustArray, mapArray, msMapArray] = pdc_map_selection_method_pie_chart (pdcOutputsStruct, doSaveFigure)

    nTargets = length(pdcOutputsStruct.targetResultsStruct);

    nNoFit  = 0;
    nRobust = 0;
    nMAP    = 0;
    nmsMAP  = 0;
    nQuickMAP = 0;

    noFitArray  = false(nTargets,1);
    robustArray = false(nTargets,1);
    mapArray    = false(nTargets,1);
    msMapArray  = false(nTargets,1);
    quickMapArray  = false(nTargets,1);

    for iTarget = 1 : nTargets

        switch (pdcOutputsStruct.targetResultsStruct(iTarget).pdcProcessingStruct.pdcMethod)
        case 'noFit'
            nNoFit = nNoFit + 1;
            noFitArray(iTarget) = true;
        case 'robust'
            nRobust = nRobust + 1;
            robustArray(iTarget) = true; 
        case {'regularMap' 'MAP'}
            nMAP = nMAP + 1;
            mapArray(iTarget) = true;    
        case {'multiScaleMap' 'msMAP'}
            nmsMAP = nmsMAP + 1;
            msMapArray(iTarget) = true;  
        case 'quickMap'
            nQuickMAP = nQuickMAP + 1;
            quickMapArray(iTarget) = true;
        otherwise
            % nothing to log
        end
    end

    nNoFit  = nNoFit / nTargets * 100;
    nRobust = nRobust / nTargets * 100;
    nMAP    = nMAP / nTargets * 100;
    nmsMAP  = nmsMAP / nTargets * 100;
    nQuickMAP  = nQuickMAP / nTargets * 100;

    pieFig = figure;
    pie([nNoFit nRobust nMAP nmsMAP nQuickMAP], ...
        {['No Fit: ', num2str(nNoFit), ' %'], ['Robust: ', num2str(nRobust,3), ' %'], ['MAP: ', num2str(nMAP,3), ' %'], ...
            ['msMAP; ', num2str(nmsMAP,3), ' %'], ['quickMAP; ', num2str(nQuickMAP,3), ' %']});
    title('The Chosen PDC Fit');

    if (doSaveFigure)
        saveas (pieFig, 'map_selection_method_pie_chart.fig');
    end

end

