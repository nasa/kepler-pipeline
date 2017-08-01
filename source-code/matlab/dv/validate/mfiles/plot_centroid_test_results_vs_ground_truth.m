function [allKeplerIds, idxL, idxS] = plot_centroid_test_results_vs_ground_truth(L, S)
% function [allKeplerIds, idxL, idxS] = plot_centroid_test_results_vs_ground_truth(L, S)
%
% This function supports SOC 6.1 DV Verification and Validation.
% 
% Plot the background binary source location from ETEM ground truth against
% the background source location of a centroid transit signature from the
% DV results.
%
% INPUTS:
%         L                 = output structure from get_background_binary_location_from_ground_truth
%         S                 = output structure from get_background_binary_source_offsets_from_dv_results
% OUTPUTS:
%         allKeplerIds      = sorted list of all kepler IDs in L and S
%         idxL              = index into allKeplerIds for each element of L
%         idxS              = index into allKeplerIds for each element of S
%
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

% hard coded constants
planetPlotOffset = 0.01;
expectedmaxOffset = 20;


% get common x-axis (index by Kepler ID)
allKeplerIds = sort( union( [L.keplerId], [S.keplerId] ) );
[tfL, idxL]  = ismember([L.keplerId],allKeplerIds);
[tfS, idxS]  = ismember([S.keplerId],allKeplerIds);
idxL = idxL(tfL);
idxS = idxS(tfS);


% % sort on minimum fw & prf significance
% minSig = zeros(length(idxS),1);
% for i=1:length(minSig)
%     minSig(i) = min([ [S(idxS).significanceFW] , [S(idxS).significancePRF] ]);
% end
% [ydummmy, sortedIdx] = sort(minSig);
% 
% idxS = idxS(sortedIdx);


% set up figure
figure;
ax(1) = subplot(3,1,1);
title('Background Binary Offsets - Blue==ground truth, Red==flux weighted centroids, Black==prf centroids - 1-sigma error bars');
hold on;

% ----------------- % plot row ground truth

% plot all ground truth offsets - each integer index corresponds to a
% single keplerId

if(length(L) > 1 || ~isempty(L.offsetRow) )
    plot(idxL,[L.offsetRow],'o');
    hold on;
end

% ----------------- % plot row results

% plot the dv centroid test results background source offset w/error bars
% for each planet
for i=1:length(idxS)
    
    nPlanets = length(S(i).sourceRowOffsetFW);

    % loop over planets
    for j=1:nPlanets

        if( S(i).sourceRowOffsetUncFW(j) ~= -1 )
            % plot w/errorbars
            E = errorbar( idxS(i)+planetPlotOffset*j,S(i).sourceRowOffsetFW(j),S(i).sourceRowOffsetUncFW(j),'rx');
            hold on;
            % remove "T" on errorbars
            C = get(E,'Children');
            xdata = get(C(2),'Xdata');
            ydata = get(C(2),'Ydata');
            set(C(2),'Xdata',xdata(1:2));
            set(C(2),'Ydata',ydata(1:2));
        end

        if( S(i).sourceRowOffsetUncPRF(j) ~= -1 )
            % plot w/errorbars
            E = errorbar( idxS(i)-planetPlotOffset*j,S(i).sourceRowOffsetPRF(j),S(i).sourceRowOffsetUncPRF(j),'kx');
            hold on;
            % remove "T" on errorbars
            C = get(E,'Children');
            xdata = get(C(2),'Xdata');
            ydata = get(C(2),'Ydata');
            set(C(2),'Xdata',xdata(1:2));
            set(C(2),'Ydata',ydata(1:2));
        end
    end
end

grid;
ylabel('Row Offset (pixels)');
hold off;




% ----------------- % plot column ground truth
ax(2) = subplot(3,1,2);

% plot all avaiable background source offsets from dv output
if(length(L) > 1 || ~isempty(L.offsetRow) )
    plot(idxL,[L.offsetCol],'o');
    hold on;
end


% ----------------- % plot column results

% plot the dv centroid test results background source offset w/error bars for each planet
for i=1:length(idxS)

    nPlanets = length(S(i).sourceColOffsetFW);

    % loop over planets
    for j=1:nPlanets

        if( S(i).sourceColOffsetUncFW(j) ~= -1 )
            % plot w/errorbars
            E = errorbar( idxS(i)+planetPlotOffset*j,S(i).sourceColOffsetFW(j),S(i).sourceColOffsetUncFW(j),'rx');
            hold on;
            % remove "T" on errorbars
            C = get(E,'Children');
            xdata = get(C(2),'Xdata');
            ydata = get(C(2),'Ydata');
            set(C(2),'Xdata',xdata(1:2));
            set(C(2),'Ydata',ydata(1:2));
        end

        if( S(i).sourceColOffsetUncPRF(j) ~= -1 )
            % plot w/errorbars
            E = errorbar( idxS(i)-planetPlotOffset*j,S(i).sourceColOffsetPRF(j),S(i).sourceColOffsetUncPRF(j),'kx');
            hold on;
            % remove "T" on errorbars
            C = get(E,'Children');
            xdata = get(C(2),'Xdata');
            ydata = get(C(2),'Ydata');
            set(C(2),'Xdata',xdata(1:2));
            set(C(2),'Ydata',ydata(1:2));
        end            

    end
end
grid;
ylabel('Column Offset (pixels)');
hold off;


% ----------------- % plot centroid motion statistic significance

fwSig = [S(idxS).significanceFW];
prfSig = [S(idxS).significancePRF];

fwX = zeros(length(fwSig),1);
prfX = zeros(length(prfSig),1);

indexX = 0;
for i=1:length(idxS)
    
    nPlanets = length(S(idxS(i)).sourceColOffsetFW);
    
    for j=1:nPlanets        
        indexX = indexX + 1;        
        fwX(indexX) = idxS(idxS(i))+planetPlotOffset*j;
        prfX(indexX) = idxS(idxS(i))-planetPlotOffset*j;
    end
    
end
        
% find valid indices
fwValid = fwSig >= 0;
prfValid = prfSig >= 0;
        
    
% plot the results
ax(3) = subplot(3,1,3);
semilogy( fwX(fwValid),fwSig(fwValid)+realmin,'r.');
hold on;
semilogy( prfX(prfValid),prfSig(prfValid)+realmin,'k.');


grid;
ylabel('significance');
title('1==centroids and flux probably not correlated, 0==centroids and flux might be correlated');
xlabel('target index');
hold off;

% set up axes
linkaxes(ax,'x');
subplot(3,1,1);
aa = axis;
axis([aa(1) aa(2) -expectedmaxOffset expectedmaxOffset]);
subplot(3,1,2);
aa = axis;
axis([aa(1) aa(2) -expectedmaxOffset expectedmaxOffset]);





