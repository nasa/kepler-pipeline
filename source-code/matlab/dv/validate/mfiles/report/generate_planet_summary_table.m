function planetSummaryTable = generate_planet_summary_table(planetResultsStruct)
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

warning('off', 'DV:retrieveModelParameter:illegalInput');
warning('off', 'DV:retrieveModelParameter:missingParams');

% Columns.
PLANET_COLUMN = 1;
KOI_ID_COLUMN = 2;
KEPLER_NAME_COLUMN = 3;
KOI_CORRELATION_COLUMN = 4;
DV_PERIOD_COLUMN = 5;
PERIOD_RATIO_COLUMN = 6;
DV_EPOCH_COLUMN = 7;
SEMI_MAJOR_AXIS_COLUMN = 8;
RADIUS_COLUMN = 9;
EQUILIBRIUM_TEMP_COLUMN = 10;
FALSE_ALARM_COLUMN = 11;
EB_COLUMN = 12;
N_COLUMNS = 12;

% Get the shortest orbital period.
nPlanets = length(planetResultsStruct);
orbitalPeriods = Inf(1, nPlanets);
for iPlanet = 1 : nPlanets
    orbitalPeriodStruct = retrieve_model_parameter(planetResultsStruct(iPlanet).allTransitsFit.modelParameters, 'orbitalPeriodDays');
    if (orbitalPeriodStruct.value ~= 0)
        orbitalPeriods(iPlanet) = orbitalPeriodStruct.value;
    end
    
end
shortestPeriod = min(orbitalPeriods);

% Table headings
planetSummaryTable = cell(nPlanets, N_COLUMNS);
row = 0;

% Table body.
for iPlanet = 1 : nPlanets

    row = row + 1;
    planetSummaryTable(row,:) = {'N/A'};
    
    % Planet number.
    planetSummaryTable{row,PLANET_COLUMN} = num2str(iPlanet, '%d');
    
    % KOI and Kepler Name
    if (isempty(planetResultsStruct(iPlanet).koiId))
        planetSummaryTable{row,KOI_ID_COLUMN} = '-';
    else
        planetSummaryTable{row,KOI_ID_COLUMN} = planetResultsStruct(iPlanet).koiId;
    end
    if (isempty(planetResultsStruct(iPlanet).keplerName))
        planetSummaryTable{row,KEPLER_NAME_COLUMN} = '-';
    else
        planetSummaryTable{row,KEPLER_NAME_COLUMN} = planetResultsStruct(iPlanet).keplerName;
    end
    if (planetResultsStruct(iPlanet).koiCorrelation == -1.0)
        planetSummaryTable{row,KOI_CORRELATION_COLUMN} = '-';
    else
        planetSummaryTable{row,KOI_CORRELATION_COLUMN} = num2str(planetResultsStruct(iPlanet).koiCorrelation, '%01.2f');
    end
    
    % DV epoch.
    epochStruct = retrieve_model_parameter(planetResultsStruct(iPlanet).allTransitsFit.modelParameters, 'transitEpochBkjd');
    if (epochStruct.value ~= 0)
        planetSummaryTable{row,DV_EPOCH_COLUMN} = num2str(epochStruct.value, '%1.1f');
    end
    
    % Orbital period and ratio to shortest period.
    orbitalPeriodStruct = retrieve_model_parameter(planetResultsStruct(iPlanet).allTransitsFit.modelParameters, 'orbitalPeriodDays');
    if (orbitalPeriodStruct.value ~= 0)
        planetSummaryTable{row,DV_PERIOD_COLUMN} = num2str(orbitalPeriodStruct.value, '%1.1f');
        planetSummaryTable{row,PERIOD_RATIO_COLUMN} = num2str(orbitalPeriodStruct.value/shortestPeriod, '%1.1f');
    end
    
    % Semi-major axis.
    semiMajorAxisStruct = retrieve_model_parameter(planetResultsStruct(iPlanet).allTransitsFit.modelParameters, 'semiMajorAxisAu');
    if (semiMajorAxisStruct.value ~= 0)
        planetSummaryTable{row, SEMI_MAJOR_AXIS_COLUMN} = num2str(semiMajorAxisStruct.value, '%1.1f');
    end
    
    % Planet radius.
    planetRadiusStruct = retrieve_model_parameter(planetResultsStruct(iPlanet).allTransitsFit.modelParameters, 'planetRadiusEarthRadii');
    if (planetRadiusStruct.value ~= 0)
        planetSummaryTable{row, RADIUS_COLUMN} = num2str(planetRadiusStruct.value, '%1.1f');
    end
    
    % Equilibrium temperature.
    equilibriumTemperatureStruct = retrieve_model_parameter(planetResultsStruct(iPlanet).allTransitsFit.modelParameters, 'equilibriumTempKelvin');
    if (equilibriumTemperatureStruct.value ~= 0)
        planetSummaryTable{row, EQUILIBRIUM_TEMP_COLUMN} = num2str(equilibriumTemperatureStruct.value, '%1.0f');
    end
    
    % False alarm (bootstrap).
    if (planetResultsStruct(iPlanet).planetCandidate.significance >= 0)
        planetSummaryTable{row, FALSE_ALARM_COLUMN} = num2str(planetResultsStruct(iPlanet).planetCandidate.significance, '%1.2e');
    end
    
    % Suspected EB.
    if (planetResultsStruct(iPlanet).planetCandidate.suspectedEclipsingBinary)
        planetSummaryTable{row, EB_COLUMN} = 'true';
    else
        planetSummaryTable{row, EB_COLUMN} = 'false';
    end
    
end

warning('on', 'DV:retrieveModelParameter:missingParams');
warning('on', 'DV:retrieveModelParameter:illegalInput');
