function [padOutputStruct] = pad_generate_track_trend_reports(padScienceObject, padOutputStruct, nominalPointingStruct, padTempStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [padOutputStruct] = pad_generate_track_trend_reports(padScienceObject, padOutputStruct, nominalPointingStruct, padTempStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This fuction generates track and trend report of time series of delta attitude solution.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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

% Get track and trend parameters from the input PAD science object.
parameters = padScienceObject.padModuleParameters;

% Get the cadence timestamps
cadenceTimestamps    = padScienceObject.cadenceTimes.midTimestamps;
cadenceGapIndicators = padScienceObject.cadenceTimes.gapIndicators;

figure(5)
pad_plot_track_trend_summary(padOutputStruct, 'PAD Track and Trend Report');

caption = sprintf(['Track and trend bound crossings report for PAD.  Color sheme is as follows:\n'...
    '**Green-  No bound crossings over the cadences from the start of the latest contact\n'...
    '**Yellow- Crossed adaptive bounds at least once over the cadences\n'...
    '**Red-    Crossed fixed bounds at least once over the cadences\n'...
    '**Cyan-   No data available\n']);

set(gcf, 'userdata', caption)
format_graphics_for_report(gcf, 1.0, 0.75)
saveas(5, 'pad_track_and_trend_bound_crossings_alert.fig')

attitudeString1 = { 'ra',      'dec',      'roll'      };
attitudeString2 = { 'deltaRa', 'deltaDec', 'deltaRoll' };

figure(11)
tsMetric.gapIndicators = padOutputStruct.attitudeSolution.gapIndicators;
for i=1:3
    subplot(3,1,i)
    tsMetric.values = padOutputStruct.attitudeSolution.(attitudeString1{i}) - nominalPointingStruct.(attitudeString1{i});
    pad_plot_attitude_metrics(tsMetric, padTempStruct, parameters, cadenceTimestamps, cadenceGapIndicators, attitudeString2{i});
    ylabelString= [get(get(gca, 'title'), 'string'), ' (degrees)'];
    title('')
    ylabel(ylabelString)
end


caption =sprintf(['Track and trend time series for delta attitude:\n'...
    '**Blue-  Metric, i.e, delta Ra, delta Dec, delta Roll\n' ...
    '**Green- Smoothed metric\n'...
    '**Red-   Adaptive bounds\n'...
    '**Black- Fixed bounds (if crossed) \n']);

set(11, 'userdata', caption)
format_graphics_for_report(gcf, 1.0, 0.75)
saveas(11, 'pad_track_and_trend_bound_crossings_time_series.fig')

return

