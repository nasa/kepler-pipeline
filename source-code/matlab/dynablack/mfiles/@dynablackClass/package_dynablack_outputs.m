function dynablackResultsStruct = package_dynablack_outputs(dynablackObject, dynablackResultsStruct)
% function dynablackResultsStruct = package_dynablack_outputs(dynablackObject, dynablackResultsStruct)
%
% This dynablackClass method packages the Dynablack output from the MATLAB controller. It performs checks on the fit residuals compared to
% limits set by dynablack module parameters and determines fit validity. If the fit is valid then 'bestCoefficients' is determined, either
% 'regress' or 'robust', and set in dynablackResultsStruct. RBA results (B2a_results) and monitor results (B2c_monitors) are parsed from
% dynablackResultsStruct and saved in separate files in the task file directory. The rollingBandArtifactFlagsStruct is set using the RBA
% results and attached to the dynablackResultsStruct. Redundant fields are removed from dynablackResultsStruct and it is returned.
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


% if invalid uow just return incoming dynablackResultsStruct with default values
if ~dynablackObject.validUow
    return;
end


% check rms residuals of dynablack fit for all pixels over full dynablack unit of work 
blackResidualsThresholdDnPerRead = dynablackResultsStruct.dynablackModuleParameters.blackResidualsThresholdDnPerRead;
blackResidualsStdDevThresholdDnPerRead = dynablackResultsStruct.dynablackModuleParameters.blackResidualsStdDevThresholdDnPerRead;
numBlackPixelsAboveThreshold = dynablackResultsStruct.dynablackModuleParameters.numBlackPixelsAboveThreshold;
dynablackReadsPerCadence = dynablackResultsStruct.A2ModelDump.Constants.readsPerLongCadence;
a1ResidRegress = dynablackResultsStruct.A1_fit_residInfo.LC.fitpix_xLC.regress_resid;
a1ResidRobust  = dynablackResultsStruct.A1_fit_residInfo.LC.fitpix_xLC.robust_resid;

% trailing collateral pixels occupy the last nCollatRows pixels in both the robust and regress models
collatRows  = dynablackResultsStruct.A1ModelDump.ROI.trailingCollat.Rows;
nCollatRows = length(collatRows);
robustResidualsPerRead  = a1ResidRobust(:,end-nCollatRows+1:end)./dynablackReadsPerCadence;
regressResidualsPerRead = a1ResidRegress(:,end-nCollatRows+1:end)./dynablackReadsPerCadence;

% rms over pixels and cadences gives an estimate of the mean bias of the fit - sanity check
robustRms  = sqrt(nanmean(nanmean(robustResidualsPerRead.^2)));
regressRms = sqrt(nanmean(nanmean(regressResidualsPerRead.^2)));

% std over cadences per pixel gives an estimate of the variation by pixel
stdDnPerReadRobust  = nanstd(robustResidualsPerRead);
stdDnPerReadRegress = nanstd(regressResidualsPerRead);
rmsStdRobust  = sqrt(nanmean(stdDnPerReadRobust.^2));
rmsStdRegress = sqrt(nanmean(stdDnPerReadRegress.^2));
regressStdOverThreshold = numel(find(stdDnPerReadRegress > blackResidualsStdDevThresholdDnPerRead));
robustStdOverThreshold  = numel(find(stdDnPerReadRobust > blackResidualsStdDevThresholdDnPerRead));

% sanity check on rms fit residuals
regressRmsHigh = regressRms > blackResidualsThresholdDnPerRead;
robustRmsHigh  = robustRms > blackResidualsThresholdDnPerRead;

% check on variations of fit residuals
regressSdHigh = regressStdOverThreshold > numBlackPixelsAboveThreshold;
robustSdHigh  = robustStdOverThreshold > numBlackPixelsAboveThreshold;
regressInvald = regressRmsHigh || regressSdHigh;
robustInvalid = robustRmsHigh || robustSdHigh;

% check validity of A1 fit
% defaults are set when dynablackResultsStruct is initialized
% validDynablackFit = true (except for mod 3, Q4)
% bestCoefficients = 'robust'
if regressInvald && robustInvalid
    dynablackResultsStruct.validDynablackFit = false;
    dynablackResultsStruct.bestCoefficients = [];      
elseif regressInvald    
    % check robust fit
    if ~robustSdHigh && ~robustRmsHigh
        % defaults are already correct
    end    
elseif robustInvalid    
    % check regress fit
    if ~regressSdHigh && ~regressRmsHigh
        dynablackResultsStruct.bestCoefficients = 'regress';
    else
        dynablackResultsStruct.validDynablackFit = false;
        dynablackResultsStruct.bestCoefficients = [];
    end    
else    
    % determine best fit type
    if regressStdOverThreshold < robustStdOverThreshold
        % fewest points over threshold
        dynablackResultsStruct.bestCoefficients = 'regress';
    elseif regressStdOverThreshold == 0 && robustStdOverThreshold == 0
        % lowest on average std
        if rmsStdRegress < rmsStdRobust
            dynablackResultsStruct.bestCoefficients = 'regress';
        end
    end    
end


% get local filenames from dynablack object
monitorFilename = dynablackObject.monitorFilename;
rollingBandFilename = dynablackObject.rollingBandFilename;

% get RBA durations
durations = dynablackObject.rbaFlagConfigurationStruct.testPulseDurations;
nDurations = length(durations);

% save monitor info
inputStruct = dynablackResultsStruct.B2c_monitors;                                  %#ok<NASGU>
% write the file
intelligent_save(monitorFilename,'inputStruct');

% save rolling band info
inputStruct = dynablackResultsStruct.B2a_results;                                   %#ok<NASGU>
% write the file
intelligent_save(rollingBandFilename,'inputStruct');

% extract rolling band struct array from results struct
rbaStructArray = dynablackResultsStruct.rollingBandArtifactFlagsStruct;

% update rollingBandArtifactFlagsStruct for each pulse duration
for iDuration = 1:nDurations
    
    % extract RBA results from fitter
    rows = dynablackResultsStruct.B2a_results(iDuration).RBA.rowList;
    cadenceIdx = dynablackResultsStruct.B2a_results(iDuration).RBA.relCadenceList;
    flags = dynablackResultsStruct.B2a_results(iDuration).flagsRollingBands;                       % nDynablackRows x nDynablackCadences
    variationLevel = dynablackResultsStruct.B2a_results(iDuration).variationLevel;
    duration = dynablackResultsStruct.B2a_results(iDuration).testPulseDurationLc;
    
    % get array indices for this pulse duration
    logicalIdx = [rbaStructArray.testPulseDurationLc] == duration;
    rowIdx = find(logicalIdx);
    nRows = numel(rowIdx);        % length(rbaStructArray);

    % Flag defintion (from flag_RBA.m)
    % bit 0: 1->scene dependent row
    % bit 1: 1->possible rolling band detected
    % bits 2-3: 0-> level at 1-2 * threshold
    %           1-> level at 2-3 * threshold
    %           2-> level at 3-4 * threshold
    %           3-> level at > 4 * threshold

    % update rolling band struct for all fitted rows
    for iRow = 1:nRows    
        % index if row was fit for rba 
        row = find(rows == rbaStructArray(rowIdx(iRow)).row,1,'first');
        if ~isempty(row)
            rbaStructArray(rowIdx(iRow)).flags.values(cadenceIdx) = flags(row,:)';                      % update RBA flags for cadences fit
            rbaStructArray(rowIdx(iRow)).flags.gapIndicators(cadenceIdx) = false;                       % reset RBA gaps for cadences fit
            rbaStructArray(rowIdx(iRow)).variationLevel.values(cadenceIdx) = variationLevel(row,:)';    % update variation levels for cadences fit
            rbaStructArray(rowIdx(iRow)).variationLevel.gapIndicators(cadenceIdx) = false;              % reset variation level gaps for cadences fit
        end
    end
end

% load updated struct into outputs
dynablackResultsStruct.rollingBandArtifactFlagsStruct = rbaStructArray;

% remove redundant fields from resultsStruct before returning
redundantFields = {'B2c_monitors','B2a_results'};                
dynablackResultsStruct = rmfield( dynablackResultsStruct, redundantFields);

return;
                
