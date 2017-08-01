function targets = debug_retrieve_target_data_demo(targets)
%
% Copyright 2017 United States Government as represented by the
% Administrator of the National Aeronautics and Space Administration.
% All Rights Reserved.
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

if(nargin == 0)
    tic;
    targets = debug_retrieve_target_data([10666592 5780885],565,7318,'LONG','one-based');
    toc;
end;

%%
for i = 1:length(targets.targets)
    subplot(2,1,1);
    plot(find(~targets.targets(i).fluxGroups(1).rawFluxTimeSeries.gapIndicators),...
        targets.targets(i).fluxGroups(1).rawFluxTimeSeries.values(~targets.targets(i).fluxGroups(1).rawFluxTimeSeries.gapIndicators), '.-b');
    hold on;
    plot(find(~targets.targets(i).fluxGroups(1).correctedFluxTimeSeries.gapIndicators),...
        targets.targets(i).fluxGroups(1).correctedFluxTimeSeries.values(~targets.targets(i).fluxGroups(1).correctedFluxTimeSeries.gapIndicators),'.-r');
    title(['Flux for Kepler ID: ' num2str(targets.targets(i).keplerId)]);
    legend('Raw Flux','Corrected Flux','Location','SouthEast');
    hold off;

    subplot(2,1,2);
    centroidGaps = targets.targets(i).fluxGroups(1).fluxWeightedCentroids.rowTimeSeries.gapIndicators;
    
    plot(targets.targets(i).fluxGroups(1).fluxWeightedCentroids.columnTimeSeries.values(~centroidGaps),...
        targets.targets(i).fluxGroups(1).fluxWeightedCentroids.rowTimeSeries.values(~centroidGaps), '.-');
    hold on;
    first = find(~centroidGaps,1);
    plot(targets.targets(i).fluxGroups(1).fluxWeightedCentroids.columnTimeSeries.values(first),...
        targets.targets(i).fluxGroups(1).fluxWeightedCentroids.rowTimeSeries.values(first), 'or');
    hold off;
    title(['Centroid Track for Kepler ID: ' num2str(targets.targets(i).keplerId)]);
    %legend('Raw Flux','Corrected Flux','Location','SouthEast');
    pause;
end;

