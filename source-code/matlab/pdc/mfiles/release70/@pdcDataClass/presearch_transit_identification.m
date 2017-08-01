function [rawFluxRmsUncertainties, correctedFluxSigma, fluxRatio, ...
isValidTarget, keplerMags] = ...
presearch_transit_identification(pdcDataObject, pdcResultsStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [rawFluxRmsUncertainties, correctedFluxSigma, fluxRatio, ...
% isValidTarget, keplerMags] = ...
% presearch_transit_identification(pdcDataObject, pdcResultsStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Identify corrected flux time series with fluctuations larger than
% expected based on statistics only. Save these to a matlab file. Also
% return the raw flux RMS uncertainties, standard deviation of corrected
% flux time series and flux ratio for all targets.
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

% Set output file name and constant.
PRESEARCH_TRANSIT_FILENAME = 'pdc_pti.mat';
RATIO_THRESHOLD = 4.0;

% Get required fields and structures from PDC data object and results
% structure.
ccdModule = pdcDataObject.ccdModule;                                                        %#ok<NASGU>
ccdOutput = pdcDataObject.ccdOutput;                                                        %#ok<NASGU>
cadenceType = pdcDataObject.cadenceType;                                                    %#ok<NASGU>
startCadence = pdcDataObject.startCadence;                                                  %#ok<NASGU>
endCadence = pdcDataObject.endCadence;                                                      %#ok<NASGU>

targetDataStruct = pdcDataObject.targetDataStruct;
rawFluxUncertainties = [targetDataStruct.uncertainties];
rawFluxGapIndicators = [targetDataStruct.gapIndicators];
keplerMags = [targetDataStruct.keplerMag]';                                                 %#ok<NASGU>

targetResultsStruct = pdcResultsStruct.targetResultsStruct;
correctedFluxTimeSeriesArray = [targetResultsStruct.correctedFluxTimeSeries];
correctedFluxValues = [correctedFluxTimeSeriesArray.values];
correctedFluxGapIndicators = [correctedFluxTimeSeriesArray.gapIndicators];

% Compute the RMS uncertainties for the input raw flux time series for each
% target.
rawFluxUncertainties(rawFluxGapIndicators) = NaN;
rawFluxRmsUncertainties = sqrt(nanmean(rawFluxUncertainties .^ 2)');

% Compute the standard deviation of the corrected flux time series for each
% target.
correctedFluxValues(correctedFluxGapIndicators) = NaN;
correctedFluxSigma = nanstd(correctedFluxValues)';

% Identify the targets with large fluctuations in corrected flux.
isValidTarget = isfinite(rawFluxRmsUncertainties) & isfinite(correctedFluxSigma);

warning off all
fluxRatio = correctedFluxSigma ./ rawFluxRmsUncertainties;
warning on all

isOverThreshold = fluxRatio > RATIO_THRESHOLD & isValidTarget;

% Save the raw and corrected flux for all targets with large fluctuations
% in corrected flux.
if any(isOverThreshold)
    overThresholdTargetDataStruct = targetDataStruct(isOverThreshold);                      %#ok<NASGU>
    overThresholdTargetResultsStruct = targetResultsStruct(isOverThreshold);                %#ok<NASGU>
    intelligent_save(PRESEARCH_TRANSIT_FILENAME, 'ccdModule', 'ccdOutput', 'cadenceType', ...
        'startCadence', 'endCadence', 'overThresholdTargetDataStruct', ...
        'overThresholdTargetResultsStruct', '-v7');
end % if

% Return
return

