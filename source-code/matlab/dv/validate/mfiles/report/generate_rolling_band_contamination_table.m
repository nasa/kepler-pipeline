%% generate_rolling_band_contamination_table
%
% [rollingBandContaminationTable, transitCountsString, transitFractionTotalString] = generate_rolling_band_contamination_table(rollingBandContaminationHistogram)
%
%% INPUTS
%
%   *rollingBandContaminationHistogram:* [struct] the rolling band
%   contamination histogram
%
%% OUTPUTS
%
%   *rollingBandContaminationTable:* [cell array]  rolling band contamination table
%   *transitCountsString:* [string] the total number of contaminated transits
%   *transitFractionTotalString:* [string] the sum of the fractions; should be
%   1.0, or N/A if none of the fractions are available
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
function [rollingBandContaminationTable, transitCountsString, transitFractionTotalString] = generate_rolling_band_contamination_table(rollingBandContaminationHistogram)

rowCount = length(rollingBandContaminationHistogram.severityLevels);
if (length(rollingBandContaminationHistogram.transitCounts) ~= rowCount ...
        || length(rollingBandContaminationHistogram.transitFractions) ~= rowCount)
    warning('DV:generate_rolling_band_contamination_table:unequalArrayLengths', ...
        'Rolling band contamination histogram arrays have unequal lengths');
    return;
end

rollingBandContaminationTable = cell(rowCount, 3);
transitCounts = 0;
transitFractionTotal = 0;
validTransitFractionTotal = false;
for iRow = 1:rowCount
    rollingBandContaminationTable(iRow,:) = create_row(rollingBandContaminationHistogram, iRow);
    transitCounts = transitCounts + rollingBandContaminationHistogram.transitCounts(iRow);
    if (rollingBandContaminationHistogram.transitFractions(iRow) ~= -1)
        validTransitFractionTotal = true;
        transitFractionTotal = transitFractionTotal + rollingBandContaminationHistogram.transitFractions(iRow);
    end
end

transitCountsString = sprintf('%d', transitCounts);
if (validTransitFractionTotal)
    transitFractionTotalString = sprintf('%1.2f', transitFractionTotal);
else
    transitFractionTotalString = 'N/A';
end
end

%% create_row
function row = create_row(rollingBandContaminationHistogram, iRow)

severityLevel = sprintf('%d', rollingBandContaminationHistogram.severityLevels(iRow));
transitCount = sprintf('%d', rollingBandContaminationHistogram.transitCounts(iRow));

transitFraction = 'N/A';
if (rollingBandContaminationHistogram.transitFractions(iRow) ~= -1)
    transitFraction = sprintf('%1.2f', rollingBandContaminationHistogram.transitFractions(iRow));
end

row = {...
    severityLevel, ...
    transitCount, ...
    transitFraction ...
    };
end
