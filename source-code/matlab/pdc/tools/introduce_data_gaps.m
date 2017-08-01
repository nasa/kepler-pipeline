function dataGapsIndicator = introduce_data_gaps(scenarioString, nCadences, constantsStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function dataGapsIndicator = introduce_data_gaps(scenarioString, nCadences)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Description: This function generates data gaps for three different
% scenarios.
% (1) For the 'best' scenario:
%       (a) data gaps of one day occur for every monthly contact and
%           quarterly roll. These are the only gaps in the data.
%
% (2) For the 'nominal' scenario:
%       (a) data gaps of one day occur for every monthly contact and
%           quarterly roll.
%       (b) data gaps sprinkled over the entire cadence range according to
%           two different poisson processes as there are more gaps in the
%           last month than in all the previous months.
%           [ The reason behind this is, that every month two 52 minutes
%           time slot is allotted toward downlinking data missed in the
%           previous month. Thus at any contact, only the current contact's
%           data is expected to contain 6% data gaps and the previous
%           months' data are expected to contain < .05% data gaps.]
% (3) For the 'worst' scenario:
%       (a) data gaps of one day occur for every monthly contact and
%           quarterly roll.
%       (b) data gaps representing 'safe mode' events lasting 8 days (one
%           or more events - a maximum of 6 for a 4 year period)
%       (c) a few data gaps sprinkled over the entire cadence range according to
%           two different poisson processes: there are more gaps in the
%           last month than in all the previous months.
%           [ The reason behind this is, that every month two 52 minutes
%           time slot is allotted toward downlinking data missed in the
%           previous month. Thus at any contact, only the current contact's
%           data is expected to contain 6% data gaps and the previous
%           months' data are expected to contain < .05% data gaps.]
%
% Inputs:
%       1.  'scenarioString' - a string that can take one of the three
%       values 'best', 'nominal', and 'worst'
%       2.  'nCadences' - number of cadences. First cadence will indicate
%       the beginning of a contact.
%       3. constantsStruct -
%         constantsStruct.totalFractionalLoss = 0.09 (indicating 91%
%         overall data completeness requirement)
%         constantsStruct.nCadencePerDay = 48 (48 samples per day, 30 minute
%         long cadence)
%         constantsStruct.daysInAMonth = 30 (30 days in a month)
%         constantsStruct.safeModeDuration = 8 (safe mode lasting 8 days)
%         constantsStruct.maxSafeModes = 6  (max. number of safemodes)
%         constantsStruct.missionDurationMonths = 48 (4 years)
%         constantsStruct.nominalFractionalLoss = 0.005 (applicable to all
%         the previous contacts)
%         constantsStruct.defaultFractionalLoss = 0.05; (applicable to
%         current month under 'worst' case scenario)%
% Output:
%        1.  dataGapsIndicator - a logical array with 1's indicating data
%        gaps
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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

% overall data completeness requirement is 91%, 3% goes toward monthly/quarterly data gaps
% 6% for safemode events (a maximum of 6, 2 for margin)  + other data gaps


if((~exist('constantsStruct', 'var')) || isempty(constantsStruct))
    constantsStruct.totalFractionalLoss = 0.09;
    constantsStruct.nCadencePerDay = 48; % 48 samples per day
    constantsStruct.daysInAMonth = 30; % 30 days in a month
    constantsStruct.safeModeDuration = 8; % safe mode lasting 8 days
    constantsStruct.maxSafeModes = 6; % max. number of safemodes
    constantsStruct.missionDurationMonths = 48;
    constantsStruct.nominalFractionalLoss = 0.0025;
    constantsStruct.defaultFractionalLoss = 0.05;
end

cadenceNumbers = (1:nCadences)';
switch lower(scenarioString)

    case 'best'

        dataGapsIndicator  = create_monthly_quarterly_gaps(cadenceNumbers, constantsStruct);

    case 'nominal'

        rollAndContactGapsIndicator  = create_monthly_quarterly_gaps(cadenceNumbers, constantsStruct);

        cadencesAvailable = cadenceNumbers(~rollAndContactGapsIndicator);
        percentageGapFraction = (constantsStruct.totalFractionalLoss*nCadences - sum(rollAndContactGapsIndicator))/nCadences;

        % number of available cadences < length(cadenceNumbers);
        sprinkledGapsIndicator = sprinkle_data_gaps(percentageGapFraction, cadencesAvailable, nCadences, constantsStruct);

        dataGapsIndicator = rollAndContactGapsIndicator | sprinkledGapsIndicator;

    case 'worst'

        [rollAndContactGapsIndicator, nContacts]  = create_monthly_quarterly_gaps(cadenceNumbers, constantsStruct);

        % how many safemodes? as many as there could be accomodated
        nSafeModes = min(nContacts/3, (constantsStruct.maxSafeModes*constantsStruct.missionDurationMonths)/nContacts);
        nSafeModes = fix(nSafeModes);

        safeModeGapsIndicator  = create_safemode_gaps(nSafeModes,cadenceNumbers, constantsStruct);

        % shrink the cadences to what is available after monthly/quarterly
        % gaps and safemode gaps

        gapsSoFar = rollAndContactGapsIndicator | safeModeGapsIndicator;
        cadencesAvailable = cadenceNumbers(~gapsSoFar);

        percentageGapFraction = (constantsStruct.totalFractionalLoss*nCadences - sum(gapsSoFar))/nCadences;

        percentageGapFraction = max(percentageGapFraction, constantsStruct.defaultFractionalLoss); % incase it is negative

        sprinkledGapsIndicator = sprinkle_data_gaps(percentageGapFraction, cadencesAvailable, nCadences, constantsStruct);

        dataGapsIndicator = gapsSoFar | sprinkledGapsIndicator;

    otherwise
        error('Unknown method.')
end

return;

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function gapIndicator = create_safemode_gaps(nSafeModes,cadenceNumbers, constantsStruct)

nCadences =   length(cadenceNumbers);
gapIndicator = false(nCadences,1);

nCadencePerDay = constantsStruct.nCadencePerDay; % 48 samples per day
daysInAMonth = constantsStruct.daysInAMonth; % 30 days in a month
safeModeDuration = constantsStruct.safeModeDuration; % safe mode lasting 8 days

% place one safemode gap per month in a random manner
contactedMonths = unique(fix(cadenceNumbers/(daysInAMonth*nCadencePerDay)));
nContacts = length(contactedMonths) - 1;

monthsChosenForSafemode = unidrnd(nContacts, nSafeModes, 1);% may return duplicates
monthsChosenForSafemode = sort(monthsChosenForSafemode - 1);
while(length(unique(monthsChosenForSafemode) ) ~= nSafeModes)
    monthsChosenForSafemode = unidrnd(nContacts, nSafeModes, 1); % safemode can occur during the first month
    monthsChosenForSafemode = sort(monthsChosenForSafemode - 1);
end
% locate one safemode anywhere inside a month
for j = 1:nSafeModes

    firstCadenceOfMonth = monthsChosenForSafemode(j)*daysInAMonth*nCadencePerDay+1;

    safeModeGapBegin = firstCadenceOfMonth + unidrnd((daysInAMonth-safeModeDuration)*nCadencePerDay,1,1);
    safeModeGapEnd = safeModeGapBegin + safeModeDuration*nCadencePerDay -1;

    gapIndicator(safeModeGapBegin:safeModeGapEnd) = true;
end;


return;

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function [gapIndicator, nContacts] = create_monthly_quarterly_gaps(cadenceNumbers, constantsStruct)

nCadencePerDay = constantsStruct.nCadencePerDay; % 48 samples per day
daysInAMonth = constantsStruct.daysInAMonth; % 30 days in a month


nCadences =   length(cadenceNumbers);
gapIndicator = false(nCadences,1);
contactedMonths = unique(fix(cadenceNumbers/(daysInAMonth*nCadencePerDay)));
nContacts = length(contactedMonths) - 1;
% ignore the first contact
for j = 2:nContacts
    startCadence = contactedMonths(j)*daysInAMonth*nCadencePerDay+1;
    endCadence = startCadence + nCadencePerDay - 1;
    gapIndicator(startCadence:endCadence) = true;
end;
return;


%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function gapIndicator = sprinkle_data_gaps(percentageFraction, cadenceNumbers, nCadences, constantsStruct )

nCadencePerDay = constantsStruct.nCadencePerDay; % 48 samples per day
daysInAMonth = constantsStruct.daysInAMonth; % 30 days in a month
nominalFractionalLoss = constantsStruct.nominalFractionalLoss;

dataLostDays =  unique(fix(cadenceNumbers./nCadencePerDay));
lostCadencesPerDay = zeros(length(dataLostDays),1);

gapIndicator = false(nCadences,1); % original length

contactedMonths = fix(cadenceNumbers/(daysInAMonth*nCadencePerDay));
nContacts = length(unique(contactedMonths)) - 1;

% data loss should be mailnly confined to the current month as the previous
% months would have had two chances to downlink missing data


endIndex = 0;
for  j = 1:nContacts

    iCadences = find(contactedMonths == j-1);

    nDays = length(find((dataLostDays >= (j-1)*daysInAMonth) & (dataLostDays < j*daysInAMonth)));

    startIndex = endIndex+1;
    endIndex = startIndex +nDays-1;

    % j~= nContacts is applicable to previous contacts; most of the lost
    % data are recovered the following contact during the 2 chances while
    % getting current contact's data
    % j == nContacts, where most of the data loss is confined  to the current contact
    if(j~= nContacts)
        meanCadenceLossRate = (length(iCadences)*nominalFractionalLoss)/nDays;
        lostCadencesPerDay(startIndex:endIndex) = poissrnd(meanCadenceLossRate,1, nDays);
    else
        meanCadenceLossRate = (length(iCadences)*percentageFraction)/nDays;
        lostCadencesPerDay(startIndex:endIndex) = poissrnd(meanCadenceLossRate,1, nDays);
    end;


end;
% place them as a group of cadences lost within a day
% events are uniformly distributed within a day - but here group them in
% successive cadences to mimic multi-cadence data loss

dataLostDaysIndex = find(lostCadencesPerDay > 0);
dataLostDays =  dataLostDays(dataLostDaysIndex);

for j = 1:length(dataLostDays)

    gapSize = lostCadencesPerDay(dataLostDaysIndex(j));

    if(gapSize == 1)
        gapLocation = unidrnd(nCadencePerDay,1,1); % locate one sample gap within a day
        gapLocation = gapLocation + dataLostDays(j)*nCadencePerDay; % apply to the correct day
        gapIndicator(gapLocation) = 1;
    else
        gapLocation = unidrnd(nCadencePerDay,gapSize,1); % an array now
        % group them as one large gap these gaps will not be consecutive,
        % so make one big gap spanning  consecutive cadences

        gapLocation =  (1:gapSize)' + fix(median(gapLocation));
        if(max(gapLocation) > nCadencePerDay)
            gapLocation = gapLocation - (max(gapLocation) - nCadencePerDay);
        end;

        gapLocation = gapLocation + dataLostDays(j)*nCadencePerDay;
        gapIndicator(gapLocation) = true;

    end;
end;
return;
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
