function [pdcResultsStruct] = test_presearch_data_conditioning(path, runs)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [pdcResultsStruct] = test_presearch_data_conditioning(path, runs)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This function provides test data to the correct_systematic_error function
% for one or more ETEM runs. The 'path' of the directory containing the local
% ETEM run subdirectories must be specified as an argument. The numbers of the
% run subdirectories must specified by 'runs', e.g. {'80100', '80200'}.
%
% For each ETEM run, the following files must be present in the respective
% run subdirectories: run_params_rundddddd.mat, ktargets_rundddddd.mat,
% Ajit_rundddddd.mat and raw_flux_gcr_rundddddd.dat. If the debug flag is
% set, plots of rms fit error vs. stellar magnitude, mad vs. stellar
% magnitude, and relative flux, fitted flux and cotrended time series will
% be displayed.
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% INPUT:
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
%                        path: [string]  path to local ETEM run subdirectories
%                    runs: [cell array]  number strings of run subdirectories
%
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

debugFlag = 1;

sgPolyOrder = 6;
sgFrameSize = 385;
satSegThreshold = 12.0;
satSegExclusionZone = 180;
robustCotrendFitFlag = false;
madXFactor = 10;
maxGiantTransitDurationInHours = 72;
maxDetrendPolyOrder = 25;
maxArOrderLimit = 25;
maxCorrelationWindowXFactor = 5;
gapFillModeIsAddBackPredictionError = true;
nWaveletTaps = 12;
cadenceType = 'LONG';
cadenceDurationInMinutes = 30;
shortCadencesPerLongCadence = 30;
medianFilterLength = 11;
histogramLength = 20;
histogramCountFraction = 0.95;
outlierScanWindowSize = 144;
outlierThresholdXFactor = 4.0;

SECONDS_PER_DAY = 86400;

global Ajit_Cell;
% global mjdtags;
% global boxtemps;
% global ccdtemps;

origDir = pwd;

pdcModuleParameters.sgPolyOrder = sgPolyOrder;
pdcModuleParameters.sgFrameSize = sgFrameSize;
pdcModuleParameters.satSegThreshold = satSegThreshold;
pdcModuleParameters.satSegExclusionZone = satSegExclusionZone;
pdcModuleParameters.robustCotrendFitFlag = robustCotrendFitFlag;
pdcModuleParameters.madXFactor = madXFactor;
pdcModuleParameters.maxGiantTransitDurationInHours = ...
    maxGiantTransitDurationInHours;
pdcModuleParameters.maxDetrendPolyOrder = maxDetrendPolyOrder;
pdcModuleParameters.maxArOrderLimit = maxArOrderLimit;
pdcModuleParameters.maxCorrelationWindowXFactor = ...
    maxCorrelationWindowXFactor;
pdcModuleParameters.gapFillModeIsAddBackPredictionError = ...
    gapFillModeIsAddBackPredictionError;
pdcModuleParameters.waveletFilterCoeffts = ...
    daubechies_low_pass_scaling_filter(nWaveletTaps);
pdcModuleParameters.cadenceType = cadenceType;
pdcModuleParameters.cadenceDurationInMinutes = cadenceDurationInMinutes;
pdcModuleParameters.shortCadencesPerLongCadence = ...
    shortCadencesPerLongCadence;
pdcModuleParameters.medianFilterLength = medianFilterLength;
pdcModuleParameters.histogramLength = histogramLength;
pdcModuleParameters.histogramCountFraction = histogramCountFraction;
pdcModuleParameters.outlierScanWindowSize = outlierScanWindowSize;
pdcModuleParameters.outlierThresholdXFactor = outlierThresholdXFactor;

for i = 1 : length(runs)
    
    runString = ['run' runs{i}];
    disp([runString ': correcting systematic error (' datestr(clock) ')'])
    runDir = [path '/' runString];
    cd(runDir);

    etemRunParametersFilename = ['run_params_' runString '.mat'];
    load(etemRunParametersFilename);
    ccdModule = run_params.module_number;
    ccdOutput = run_params.output_number;
    
    ktargetsFilename = ['ktargets_' runString '.mat'];
    load(ktargetsFilename, 'ntargets', 'magtargets', 'targetflux');
    
    ajitFilename = ['Ajit_' runString '.mat'];
    load(ajitFilename);
    nCadences = size(Ajit_Cell{3,3}, 1);
    ajit = Ajit_Cell{3, 3};
    dx = ajit(1 : nCadences, 2)/ajit(1, 1);
    dy = ajit(1 : nCadences, 3)/ajit(1, 1);
    clear Ajit_Cell;
    
    mjd = datestr2mjd([run_params.run_start_date ' 00:00:00']);
    %mjd = datestr2mjd('29-SEP-2007 00:00:00'); % for real ancillary test data
    timestamps = mjd + ...
        (0 : nCadences)' * round(run_params.long_cadence_duration) / SECONDS_PER_DAY;
    cadenceStartTimes = timestamps(1 : end - 1);
    cadenceEndTimes = timestamps(2 : end);
    mjdTimestamps = cadenceStartTimes + diff(timestamps) / 2;
    
    ancillaryDataStruct(1).mnemonic = 'DX';
    ancillaryDataStruct(1).timestamps = mjdTimestamps;
    ancillaryDataStruct(1).isAncillaryEngineeringData = false;
    ancillaryDataStruct(1).cotrendPolyOrder = 3;
    ancillaryDataStruct(1).cotrendCrossProductIndices = 2;
    ancillaryDataStruct(1).ancillaryTimeSeries.values = dx;
    ancillaryDataStruct(1).ancillaryTimeSeries.uncertainties = ...
        ones([nCadences, 1]);
    ancillaryDataStruct(1).ancillaryTimeSeries.gapIndicators = ...
        false([nCadences, 1]);
    
    ancillaryDataStruct(2).mnemonic = 'DY';
    ancillaryDataStruct(2).timestamps = mjdTimestamps;
    ancillaryDataStruct(2).isAncillaryEngineeringData = false;
    ancillaryDataStruct(2).cotrendPolyOrder = 3;
    ancillaryDataStruct(2).cotrendCrossProductIndices = 1;
    ancillaryDataStruct(2).ancillaryTimeSeries.values = dy;
    ancillaryDataStruct(2).ancillaryTimeSeries.uncertainties = ...
        ones([nCadences, 1]);
    ancillaryDataStruct(2).ancillaryTimeSeries.gapIndicators = ...
        false([nCadences, 1]);
%{    
    timestamps = mjd + (1/(3*96) : 1/96 : 93)';  % 1 sample per 15 minutes
    ancillaryDataStruct(3).mnemonic = 'lowRateTemp';
    ancillaryDataStruct(3).timestamps = timestamps;
    ancillaryDataStruct(3).isAncillaryEngineeringData = true;
    ancillaryDataStruct(3).cotrendPolyOrder = 1;
    ancillaryDataStruct(3).cotrendCrossProductIndices = [];
    ancillaryDataStruct(3).ancillaryTimeSeries.values = ...
        sin(2 * pi * .02 * timestamps); % period = 50 days
    ancillaryDataStruct(3).ancillaryTimeSeries.uncertainties = ...
        ones([length(timestamps), 1]);
    ancillaryDataStruct(3).ancillaryTimeSeries.gapIndicators = ...
        false([length(timestamps), 1]);
    
    timestamps = mjd + (1/(3*8640) : 1/8640 : 93)';  % 1 sample per 10 seconds
    ancillaryDataStruct(4).mnemonic = 'highRateTemp';
    ancillaryDataStruct(4).timestamps = timestamps;
    ancillaryDataStruct(4).isAncillaryEngineeringData = true;
    ancillaryDataStruct(4).cotrendPolyOrder = 1;
    ancillaryDataStruct(4).cotrendCrossProductIndices = [];
    ancillaryDataStruct(4).ancillaryTimeSeries.values = ...
        sin(2 * pi * .05 * timestamps); % period = 20 days
    ancillaryDataStruct(4).ancillaryTimeSeries.uncertainties = ...
        ones([length(timestamps), 1]);
    ancillaryDataStruct(4).ancillaryTimeSeries.gapIndicators = ...
        false([length(timestamps), 1]);
        
    load('Z:\ball\1000_frame_ff_sp1_sp2_nom_op_ccd.mat');
    timestamps = mjdtags;
    ancillaryDataStruct(5).mnemonic = 'ccdTemp';
    ancillaryDataStruct(5).timestamps = timestamps;
    ancillaryDataStruct(5).isAncillaryEngineeringData = true;
    ancillaryDataStruct(5).cotrendPolyOrder = 1;
    ancillaryDataStruct(5).cotrendCrossProductIndices = [];
    ancillaryDataStruct(5).ancillaryTimeSeries.values = ccdtemps( : , 1);
    ancillaryDataStruct(5).ancillaryTimeSeries.uncertainties = ones([length(timestamps), 1]);
    ancillaryDataStruct(5).ancillaryTimeSeries.dataGapIndicators = false([length(timestamps), 1]);
%}   
    rawFluxFilename = ['raw_flux_gcr_' runString '.dat'];
    fidRawFlux = fopen(rawFluxFilename, 'r', 'ieee-le');
    relativeFlux = fread(fidRawFlux, [ntargets, inf], 'float32');
    relativeFlux = relativeFlux';
    fclose(fidRawFlux);
    
    relativeFluxTimeSeries = struct( ...
        'values', [], ...
        'uncertainties', [], ...
        'gapIndicators', [] );
        
    targetDataStruct = repmat(struct( ...
        'keplerId', [], ...
        'relativeFluxTimeSeries', relativeFluxTimeSeries), [1, ntargets]);
        
    for j = 1 : ntargets
        targetDataStruct(j).keplerId = 1e6 + j;
        targetDataStruct(j).relativeFluxTimeSeries.values = relativeFlux( : , j);
        targetDataStruct(j).relativeFluxTimeSeries.uncertainties = ones([nCadences, 1]);
        targetDataStruct(j).relativeFluxTimeSeries.gapIndicators = false([nCadences, 1]);
    end

    %{
    ancillaryDataStruct(1).ancillaryTimeSeries.values(15 : 25) = 0;
    ancillaryDataStruct(1).ancillaryTimeSeries.values(1001) = 0;
    ancillaryDataStruct(1).ancillaryTimeSeries.values(2000 : 2200) = 0;
    ancillaryDataStruct(1).ancillaryTimeSeries.uncertainties(15 : 25) = 0;
    ancillaryDataStruct(1).ancillaryTimeSeries.uncertainties(1001) = 0;
    ancillaryDataStruct(1).ancillaryTimeSeries.uncertainties(2000 : 2200) = 0;
    ancillaryDataStruct(1).ancillaryTimeSeries.gapIndicators(15 : 25) = true;
    ancillaryDataStruct(1).ancillaryTimeSeries.gapIndicators(1001) = true;
    ancillaryDataStruct(1).ancillaryTimeSeries.gapIndicators(2000 : 2200) = true;
 
    targetDataStruct(2).relativeFluxTimeSeries.values(1000 : 1500) = 0;
    targetDataStruct(2).relativeFluxTimeSeries.uncertainties(1000 : 1500) = 0;
    targetDataStruct(2).relativeFluxTimeSeries.gapIndicators(1000 : 1500) = true;
    targetDataStruct(1002).relativeFluxTimeSeries.values(3000 : 3300) = 0;
    targetDataStruct(1002).relativeFluxTimeSeries.uncertainties(3000 : 3300) = 0;
    targetDataStruct(1002).relativeFluxTimeSeries.gapIndicators(3000 : 3300) = true;
    
    % FOR NOW.
    targetDataStruct(201 : end) = [];
    %}
    
    pdcDataStruct.ccdModule = ccdModule;
    pdcDataStruct.ccdOutput = ccdOutput;
    pdcDataStruct.cadenceStartTimes = cadenceStartTimes;
    pdcDataStruct.cadenceEndTimes = cadenceEndTimes;
    pdcDataStruct.pdcModuleParameters = pdcModuleParameters;
    pdcDataStruct.ancillaryDataStruct = ancillaryDataStruct;
    pdcDataStruct.targetDataStruct = targetDataStruct;
    pdcDataStruct.debugFlag = debugFlag;
    
    [pdcResultsStruct] = pdc_matlab_controller(pdcDataStruct);
    
end % for

cd(origDir);

return
