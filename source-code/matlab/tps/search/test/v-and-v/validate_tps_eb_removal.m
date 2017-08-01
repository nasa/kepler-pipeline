function validate_tps_eb_removal(tceStruct, koiDataStruct)
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

EBCatalog = load_eclipsing_binary_catalog();
fprintf('Number of EBs in Catalog: %d\n',length(EBCatalog));
fprintf('Number of EBs in UOW: %d\n',sum(tceStruct.isOnEclipsingBinaryList(:,1)));

tceEBIndicator = tceStruct.isOnEclipsingBinaryList(:,1) & tceStruct.trueTceFlag;
notceEBIndicator = tceStruct.isOnEclipsingBinaryList(:,1) & ~tceStruct.trueTceFlag;
koiIndicator = ismember(tceStruct.keplerId,koiDataStruct.keplerId);

indicator1 = tceEBIndicator & koiIndicator;
indicator2 = tceEBIndicator & ~koiIndicator;
indicator3 = notceEBIndicator & koiIndicator;
indicator4 = notceEBIndicator & ~koiIndicator;

fprintf('Number of EBs that have TCEs and are KOIs: %d\n', sum(indicator1));
fprintf('Number of EBs that have TCEs and are not KOIs: %d\n', sum(indicator2));
fprintf('Number of EBs that have no TCEs and are KOIs: %d\n', sum(indicator3));
fprintf('Number of EBs that have no TCEs and are not KOIs: %d\n', sum(indicator4));

figure;
hold on;
scatter(tceStruct.robustStatistic(indicator1),tceStruct.maxMes(indicator1),'o')
scatter(tceStruct.robustStatistic(indicator2),tceStruct.maxMes(indicator2),'ro')
scatter(tceStruct.robustStatistic(indicator3),tceStruct.maxMes(indicator3),'go')
scatter(tceStruct.robustStatistic(indicator4),tceStruct.maxMes(indicator4),'ko')
refline(1,0)
hold off;
legend('EBs with TCEs that are KOIs','EBs with TCEs that are not KOIs','EBs with no TCEs that are KOIs','EBs with no TCEs that are not KOIs','y=x');
title('Eclipsing Binary RS vs. MES')
ylabel('Robust Statistic');
xlabel('MES');

% now for the EBs that have TCE's and are not KOIs I should check to see if the period
% matches what is in the EB catalog
tceIndex = find(indicator2);
catalogPeriods = -1*ones(length(tceIndex),1);
for i=1:length(catalogPeriods)
    catalogPeriods(i) = EBCatalog(EBCatalog(:,1)==tceStruct.keplerId(tceIndex(i)),3);
end

figure;
scatter(tceStruct.periodDays(indicator2),catalogPeriods)
refline(1,0)
title('Search Period vs. Catalog Period for EBs with TCEs that are not KOIs')
xlabel('Catalog Periods (days)')
ylabel('Search Period (days)')


return