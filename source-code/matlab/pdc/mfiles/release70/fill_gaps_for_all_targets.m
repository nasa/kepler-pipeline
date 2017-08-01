%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%% function [filledFluxTimeSeries] = fill_gaps_for_all_targets(targetFluxTimeSeries, pdcModuleParameters, ...
%                                           gapFillParametersStruct, eventStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Fill both short and long gaps in the flux time series for each target.
% The gaps may be the result of missing data in the PDC input flux time
% series, or from the identification of outliers. Short data gaps are
% filled based on autoregressive (AR) modeling techniques. Long data gaps
% are filled with wavelet transform based techniques after reflecting
% available samples from both sides into the gap.
%%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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

function [filledFluxTimeSeries] = fill_gaps_for_all_targets(targetFluxTimeSeries, pdcModuleParameters, ...
                                        gapFillParametersStruct, eventStruct)

% Set the power of two length flag to false for gap filling. It is neither
% necessary nor desired to extend the target flux time series.
POWER_OF_TWO_LENGTH_FLAG = false;

% Get the debug level.
debugLevel = pdcModuleParameters.debugLevel;

% Initialize the output structure.
nTargets = length(targetFluxTimeSeries);

filledFluxTimeSeries = repmat(struct( ...
    'values', [], ...
    'uncertainties', [], ...
    'gapIndicators', [], ...
    'filledIndices', [] ), [1, nTargets]);

% Fill all gaps for each target and populate the output struct array.
for iTarget = 1 : nTargets

    targetFlux = targetFluxTimeSeries(iTarget).values;
    targetFluxUncertainties = targetFluxTimeSeries(iTarget).uncertainties;
    targetFluxDataGapIndicators = targetFluxTimeSeries(iTarget).gapIndicators;
    
    % if no un-gapped cadences then skip
    if (~any(~targetFluxDataGapIndicators))
        filledFluxTimeSeries(iTarget).values = targetFlux;
        filledFluxTimeSeries(iTarget).uncertainties = targetFluxUncertainties;
        filledFluxTimeSeries(iTarget).gapIndicators = targetFluxDataGapIndicators;
        filledFluxTimeSeries(iTarget).filledIndices = [];
        continue;
    end

    if exist('eventStruct', 'var') && ~isempty(eventStruct)
        indexOfAstroEvents = eventStruct(iTarget).indexOfAstroEvents;
    else
        indexOfAstroEvents = 0;
    end % if / else
    
    [filledFlux, filledIndices, gapIndicators, masterIndexOfAstroEvents, ...
        filledFluxUncertainties] = pdc_fill_data_gaps(targetFlux, ...
        targetFluxDataGapIndicators, indexOfAstroEvents, ...
        targetFluxUncertainties, gapFillParametersStruct, ...
        POWER_OF_TWO_LENGTH_FLAG, debugLevel);
    
    filledFluxTimeSeries(iTarget).values = filledFlux;
    filledFluxTimeSeries(iTarget).uncertainties = filledFluxUncertainties;
    filledFluxTimeSeries(iTarget).gapIndicators = gapIndicators;
    filledFluxTimeSeries(iTarget).filledIndices = filledIndices;
    
end % for iTarget

% Return.
return
