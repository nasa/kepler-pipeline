%% generate_ghost_diagnostic_table
%
% ghostDiagnosticTable = generate_ghost_diagnostic_table(planetResultsStruct)
%
%% INPUTS
%
%   *planetResultsStruct:* [struct] the planet results
%
%% OUTPUTS
%
%   *ghostDiagnosticTable:* [cell array]  ghost diagnostic table
%%
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
function ghostDiagnosticTable = generate_ghost_diagnostic_table(planetResultsStruct)

mes = sprintf('%1.1f', planetResultsStruct.planetCandidate.maxMultipleEventSigma);

modelFitSnr = 'N/A';
if (planetResultsStruct.allTransitsFit.modelChiSquare ~= -1)
    modelFitSnr = sprintf('%1.1f', planetResultsStruct.allTransitsFit.modelFitSnr);
end

statistic = planetResultsStruct.ghostDiagnosticResults.coreApertureCorrelationStatistic;
coreApertureCorrelationStatisticValue = '';
coreApertureCorrelationStatisticSignificance = '';
if (statistic.significance ~= -1)
    coreApertureCorrelationStatisticValue = sprintf('%1.4e', statistic.value);
    coreApertureCorrelationStatisticSignificance = sprintf('%1.2f', 100*statistic.significance);
end

statistic = planetResultsStruct.ghostDiagnosticResults.haloApertureCorrelationStatistic;
haloApertureCorrelationStatisticValue = '';
haloApertureCorrelationStatisticSignificance = '';
if (statistic.significance ~= -1)
    haloApertureCorrelationStatisticValue = sprintf('%1.4e', statistic.value);
    haloApertureCorrelationStatisticSignificance = sprintf('%1.2f', 100*statistic.significance);
end

numerator = planetResultsStruct.ghostDiagnosticResults.coreApertureCorrelationStatistic;
denominator = planetResultsStruct.ghostDiagnosticResults.haloApertureCorrelationStatistic;
% The default value, if the ratio can't be calculated
ratioValue = '';
% The unvarying value
ratioSignificance = '';
% Both significances must be defined and the demoninator must be nonzero
if ((numerator.significance ~= -1) && ...
    (denominator.significance ~= -1) && ...
    (denominator.value ~= 0))
    ratioValue = sprintf('%1.4e', (numerator.value / denominator.value));
end

% Result / Value / Significance (%)
ghostDiagnosticTable = {...
    'Maximum MES', mes, '';...
    'SNR', modelFitSnr, ''; ...
    'Core Aperture Statistic', coreApertureCorrelationStatisticValue, coreApertureCorrelationStatisticSignificance; ...
    'Halo Aperture Statistic', haloApertureCorrelationStatisticValue, haloApertureCorrelationStatisticSignificance; ...
    'Ratio of Core/Halo Aperture Statistics', ratioValue, ratioSignificance; ...
    };
