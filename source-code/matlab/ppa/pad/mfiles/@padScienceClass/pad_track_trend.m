function [padOutputStruct, padTempStruct] = pad_track_trend(padScienceObject, padOutputStruct, nominalPointingStruct, padTempStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [padOutputStruct, padTempStruct] = pad_track_trend(padScienceObject, padOutputStruct, nominalPointingStruct, padTempStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This function perform track and trend analysis on delta attitude solution.
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

% Set module and output to -1, since the metric time series are for all module/outputs
ccdModule = -1;
ccdOutput = -1;

% Open a new figure window for track and trend of delta attitude solution
if (parameters.plottingEnabled)
   figure_h = figure; %#ok<NASGU>
end

    % Create the deltaRa report
    tsMetric.values        = padOutputStruct.attitudeSolution.ra - nominalPointingStruct.ra;
    tsMetric.gapIndicators = padOutputStruct.attitudeSolution.gapIndicators;
    [padOutputStruct, padTempStruct] = pad_track_trend_attitude_metrics( ...
        tsMetric, padOutputStruct, padTempStruct, parameters, cadenceTimestamps, cadenceGapIndicators, ccdModule, ccdOutput, 'deltaRa'  );
    if exist('figure_h','var')
        ylabelString= [get(get(gca, 'ylabel'), 'string'), ' (degrees)'];
        ylabel(ylabelString)
        format_graphics_for_report(gcf, 1.0, 0.75)
        saveas(gcf, 'pad_track_and_trend_reconstructed_attitude_delta_ra.fig')
    end

    % Create the deltaDec report
    tsMetric.values        = padOutputStruct.attitudeSolution.dec - nominalPointingStruct.dec;
    tsMetric.gapIndicators = padOutputStruct.attitudeSolution.gapIndicators;
    [padOutputStruct, padTempStruct] = pad_track_trend_attitude_metrics( ...
        tsMetric, padOutputStruct, padTempStruct, parameters, cadenceTimestamps, cadenceGapIndicators, ccdModule, ccdOutput, 'deltaDec' );  
    if exist('figure_h','var')
        ylabelString= [get(get(gca, 'ylabel'), 'string'), ' (degrees)'];
        ylabel(ylabelString)
        format_graphics_for_report(gcf,  1.0, 0.75)
        saveas(gcf, 'pad_track_and_trend_reconstructed_attitude_delta_dec.fig')
    end

    % Create the deltaRoll report    
    tsMetric.values        = padOutputStruct.attitudeSolution.roll - nominalPointingStruct.roll;
    tsMetric.gapIndicators = padOutputStruct.attitudeSolution.gapIndicators;
    [padOutputStruct, padTempStruct] = pad_track_trend_attitude_metrics( ...
        tsMetric, padOutputStruct, padTempStruct, parameters, cadenceTimestamps, cadenceGapIndicators, ccdModule, ccdOutput, 'deltaRoll');
    if exist('figure_h','var')
        ylabelString= [get(get(gca, 'ylabel'), 'string'), ' (degrees)'];
        ylabel(ylabelString)
        format_graphics_for_report(gcf, 1.0, 0.75)
        saveas(gcf, 'pad_track_and_trend_reconstructed_attitude_delta_roll.fig')
    end

return
