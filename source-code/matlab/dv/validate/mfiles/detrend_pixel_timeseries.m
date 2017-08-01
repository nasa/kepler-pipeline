function [detrendedPixelsTimeseries] = detrend_pixel_timeseries(conditionedAncillaryDataArray,...
                                                                    targetDataStruct,...
                                                                    detrendParamStruct,...
                                                                    dataAnomalyIndicators)
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

% function [detrendedPixelsTimeseries] = detrend_pixel_timeseries(conditionedAncillaryDataArray,...
%                                                                     targetDataStruct,...
%                                                                     detrendParamStruct,...
%                                                                     dataAnomalyIndicators)
% 
% Extract the pixel time series from the targetDataStruct, detrend them
% against ancillary data (including DVA) according to the flags in
% dataAnomalyIndicators and the parameters in detrendParamStruct and return
% the array of detrendedPixelsTimeseries.


% correct_systematic_error expects input of an array of target flux time
% series which must include keplerMag. We will make the array of pixel
% timeseries look like an array of very dim target flux timeseries.
% e.g.
% fakeTargetFluxTimeseries = repmat(struct( 'values', [], ...
%                                           'uncertainties', [], ...
%                                           'gapIndicators', [], ...
%                                           'keplerMag', 20),...
%                                           1, nPixels);
% Note: fake targets are dim -- keplerMag = 20

% Make the pixel time series look like a target flux time series
pixelDataFileName = targetDataStruct.pixelDataFileName;
[pixelDataStruct, status, path, name, ext] = ...
    file_to_struct(pixelDataFileName, 'pixelDataStruct');                                   %#ok<ASGLU>
if ~status
    error('dv:detrendPixelTimeseries:unknownDataFileType', ...
        'unknown pixel data file type (%s%s)', ...
        name, ext);
end % if
calibratedTimeSeries = [pixelDataStruct.calibratedTimeSeries];
[calibratedTimeSeries.keplerMag] = deal(20);
clear pixelDataStruct

% Remove harmonics from all of the (repackaged) pixel time series prior to
% detrending. COMMENT OUT FOR NOW UNTIL HARMONIC IDENTIFICATION IS
% PERFORMED JOINTLY WITH SYSTEMATIC ERROR CORRECTION (POST-7.0).
targetTableId = targetDataStruct.targetTableId;

% targetTableIds = [conditionedAncillaryDataArray.targetTableId];
% iTable = find(targetTableId == targetTableIds);
% 
% startCadenceRelative = ...
%     conditionedAncillaryDataArray(iTable).startCadenceRelative;
% endCadenceRelative = ...
%     conditionedAncillaryDataArray(iTable).endCadenceRelative;
% cadenceRangeForTimeSeries = startCadenceRelative : endCadenceRelative;
% 
% coarsePdcConfigurationStruct = ...
%     detrendParamStruct.coarsePdcConfigurationStruct;
% coarsePdcConfigurationStruct.ccdModule = targetDataStruct.ccdModule;
% coarsePdcConfigurationStruct.ccdOutput = targetDataStruct.ccdOutput;
% coarsePdcConfigurationStruct.cadenceTimes = ...
%     trim_dv_cadence_times(coarsePdcConfigurationStruct.cadenceTimes, ...
%     cadenceRangeForTimeSeries);
% cadenceType = 'LONG';
% identifyAllTargetsAsVariable = true;
% 
% [harmonicTimeSeries, calibratedTimeSeries] = ...
%     pdc_identify_and_remove_phase_shifting_harmonics_from_all_targets( ...
%     calibratedTimeSeries, coarsePdcConfigurationStruct, cadenceType, ...
%     identifyAllTargetsAsVariable);
%
% ALTERNATIVE HARMONIC REMOVAL WITHOUT PRIOR COARSE SYSTEMATIC ERROR
% CORRECTION.
% gapFillConfigurationStruct = ...
%     detrendParamStruct.gapFillConfigurationStruct;
% coarsePdcConfigurationStruct = ...
%     detrendParamStruct.coarsePdcConfigurationStruct;
% harmonicsIdentificationConfigurationStruct = ...
%     coarsePdcConfigurationStruct.harmonicsIdentificationConfigurationStruct;
%
% for iPixel = 1 : length(calibratedTimeSeries)
%     [calibratedTimeSeries(iPixel).values, harmonicTimeSeries, indexOfGiantTransits, ...
%         harmonicModelStruct, medianFlux] = ...
%         identify_and_remove_phase_shifting_harmonics(calibratedTimeSeries(iPixel).values, ...
%         calibratedTimeSeries(iPixel).gapIndicators, gapFillConfigurationStruct, ...
%         harmonicsIdentificationConfigurationStruct, true, iPixel, true);
%     calibratedTimeSeries(iPixel).values = ...
%         calibratedTimeSeries(iPixel).values + medianFlux;
%     calibratedTimeSeries(iPixel).values(calibratedTimeSeries(iPixel).gapIndicators) = 0;
%     close all
% end % for iPixel

% Detrend all time series at once
restoreMeanFlag = false;

detrendedPixelsTimeseries = ...
    correct_systematic_error_for_target_table(targetTableId, ...
                                conditionedAncillaryDataArray,...
                                calibratedTimeSeries, ...
                                detrendParamStruct.ancillaryDesignMatrixConfigurationStruct, ...
                                detrendParamStruct.pdcConfigurationStruct,...
                                detrendParamStruct.saturationSegmentConfigurationStruct,...
                                detrendParamStruct.gapFillConfigurationStruct, ...
                                restoreMeanFlag, ...
                                dataAnomalyIndicators);
