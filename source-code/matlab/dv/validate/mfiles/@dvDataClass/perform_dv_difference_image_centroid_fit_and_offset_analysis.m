function [differenceImageMotionResults, diagnostics, alertString] = ...
perform_dv_difference_image_centroid_fit_and_offset_analysis(dvDataObject, ...
differenceImageResults, differenceImageMotionResults, allTransitsFit)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [differenceImageMotionResults] = ...
% perform_dv_difference_image_centroid_fit_and_offset_analysis(dvDataObject, ...
% differenceImageResults, differenceImageMotionResults, allTransitsFit)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Perform bootstrap multi-quarter PRF fits to the quarterly out of transit
% and difference images respectively (if the model fit SNR is below a
% specified threshold) to estimate the out of transit and difference image
% centroid positions in sky coordinates. The out of transit centroid marks
% the position of the target; the difference image centroid marks the
% position of the transit source.
%
% Compute the offset between the multi-quarter difference image and out of
% transit image centroids by averaging over the results of the individual
% bootstrap PRF fit trials. Update the centroid and centroid offset fields
% in the difference image motion results structure. Also return a
% bootstrap diagnostics structure containing the multi-quarter fit results
% for each bootstrap trial, and an alert message if the bootstrap is not
% performed or is not successfully completed for some reason. 
%
% Likewise compute the offset between the multi-quarter difference image
% centroid and the KIC reference position for the given target by averaging
% over the results of the individual bootstrap PRF fit trials. Update the
% difference image motion results structure accordingly.
%
% The dvDataObject, differenceImageResults, differenceImageMotionResults
% and allTransitsFit structures and structure arrays are defined in the
% headers of the dv_matlab_controller and validate_dv_inputs functions. The
% module parameter 'singlePrfFitSnrThreshold' which determines whether or
% not the bootstrap multi-quarter PRF fit is performed may be found in the
% differenceImageConfigurationStruct of the dvDataObject.
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


% Define constants.
GAP_VALUE = -1;
DEGREES_PER_HOUR = 360 / 24;
HOURS_PER_DEGREE = 24 / 360;
T_RA_HOURS_DEC_DEGREES = diag([HOURS_PER_DEGREE, 1]);

% Set default values for outputs.
diagnostics = [];
alertString = [];

% Do not perform the bootstrap multi-quarter PRF fit if the all-transits
% model fit failed for the given planet candidate, if the model fit SNR is
% above the specified threshold, if none of the quarterly difference images
% is valid or if there are no PRF models.
singlePrfFitSnrThreshold = ...
    dvDataObject.differenceImageConfigurationStruct.singlePrfFitSnrThreshold;
maxSinglePrfFitFailures = ...
    dvDataObject.differenceImageConfigurationStruct.maxSinglePrfFitFailures;
maxSinglePrfFitTrials = ...
    dvDataObject.differenceImageConfigurationStruct.maxSinglePrfFitTrials;
singlePrfFitForCentroidPositionsEnabled = ...
    dvDataObject.differenceImageConfigurationStruct.singlePrfFitForCentroidPositionsEnabled;
mqOffsetConstantUncertainty = ...
    dvDataObject.differenceImageConfigurationStruct.mqOffsetConstantUncertainty;

prfModels = dvDataObject.prfModels;

modelChiSquare = allTransitsFit.modelChiSquare;
modelFitSnr = allTransitsFit.modelFitSnr;
mjdTimestamps = [differenceImageResults.mjdTimestamp];

if modelChiSquare == GAP_VALUE
    alertString = 'Multi-quarter PRF fitting and offset analysis will not be performed because model fit failed';
    return
elseif modelFitSnr >= singlePrfFitSnrThreshold
    alertString = 'Multi-quarter PRF fitting and offset analysis will not be performed because model fit SNR is above specified threshold';
    return
elseif ~any(mjdTimestamps > 0)
    alertString = 'Multi-quarter PRF fitting and offset analysis will not be performed because there are no valid control or difference images';
    return
elseif isempty(prfModels)
    alertString = 'Multi-quarter PRF fitting and offset analysis will not be performed because there are no PRF models';
    return
end % if

% The conditions have been met for performing the time-consuming bootstrap
% multi-quarter PRF fit. Set up the structures and compute the seeds
% necessary to perform the bootstrap.
nTables = length(differenceImageResults);

controlImageData = repmat(struct( ...
        'values', [], ...
        'uncertainties', [], ...
        'ccdRow', [], ...
        'ccdColumn', [], ...
        'ccdModule', 0, ...
        'ccdOutput', 0, ...
        'mjd', 0, ...
        'targetTableId', 0), [nTables, 1]);
    
isValidControlImage = true([1, nTables]);

for iTable = 1 : nTables
    
    controlImageData(iTable).mjd = mjdTimestamps(iTable);
    controlImageData(iTable).ccdModule = ...
        differenceImageResults(iTable).ccdModule;
    controlImageData(iTable).ccdOutput = ...
        differenceImageResults(iTable).ccdOutput;
    controlImageData(iTable).targetTableId = ...
        differenceImageResults(iTable).targetTableId;
    rows = ...
        [differenceImageResults(iTable).differenceImagePixelStruct.ccdRow]';
    columns = ...
        [differenceImageResults(iTable).differenceImagePixelStruct.ccdColumn]';
    
    fluxArray = ...
        [differenceImageResults(iTable).differenceImagePixelStruct.meanFluxOutOfTransit];
    values = [fluxArray.value]';
    uncertainties = [fluxArray.uncertainty]';
    
    isInvalid = uncertainties == GAP_VALUE;
    rows(isInvalid) = [];
    columns(isInvalid) = [];
    values(isInvalid) = [];
    uncertainties(isInvalid) = [];
    
    controlImageData(iTable).ccdRow = rows;
    controlImageData(iTable).ccdColumn = columns;
    controlImageData(iTable).values = values;
    controlImageData(iTable).uncertainties = uncertainties;
    
    if isempty(values) || isempty(uncertainties)
        isValidControlImage(iTable) = false;
    end % if
    
    clear fluxArray

end % for iTable

differenceImageData = controlImageData;

isValidDifferenceImage = true([1, nTables]);

for iTable = 1 : nTables
    
    rows = ...
        [differenceImageResults(iTable).differenceImagePixelStruct.ccdRow]';
    columns = ...
        [differenceImageResults(iTable).differenceImagePixelStruct.ccdColumn]';
    
    fluxArray = ...
        [differenceImageResults(iTable).differenceImagePixelStruct.meanFluxDifference];
    values = [fluxArray.value]';
    uncertainties = [fluxArray.uncertainty]';
    
    isInvalid = uncertainties == GAP_VALUE;
    rows(isInvalid) = [];
    columns(isInvalid) = [];
    values(isInvalid) = [];
    uncertainties(isInvalid) = [];
    
    differenceImageData(iTable).ccdRow = rows;
    differenceImageData(iTable).ccdColumn = columns;
    differenceImageData(iTable).values = values;
    differenceImageData(iTable).uncertainties = uncertainties;
    
    if isempty(values) || isempty(uncertainties)
        isValidDifferenceImage(iTable) = false;
    end % if
    
    clear fluxArray

end % for iTable

isInvalid = mjdTimestamps == 0 | ...
    ~isValidControlImage | ~isValidDifferenceImage;
controlImageData(isInvalid) = [];
differenceImageData(isInvalid) = [];
differenceImageResults(isInvalid) = [];

if length(controlImageData) < 2
    alertString = 'Multi-quarter PRF fitting and offset analysis will not be performed because there are not at least two quarters with valid images';
    return
end % if

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

prfModuleOutputs = ...
    unique([[prfModels.ccdModule]', [prfModels.ccdOutput]'], 'rows');
imageModuleOutputs = ...
    unique([[controlImageData.ccdModule]', [controlImageData.ccdOutput]'], 'rows');

if any(~ismember(imageModuleOutputs, prfModuleOutputs, 'rows'))
    error('DV:performDvDifferenceImageMqCentroidFitAndOffsetAnalysis', ...
        'PRF for necessary module output is not present in DV inputs');
end % if

nPrfs = sum(ismember(prfModuleOutputs, imageModuleOutputs, 'rows'));
iPrf = 0;

prfStruct = repmat(struct( ...
    'prf', [], ...
    'ccdModule', 0, ...
    'ccdOutput', 0), [nPrfs, 1]);

for iModel = 1 : length(prfModels)
    
    prfModuleOutput = ...
        [prfModels(iModel).ccdModule, prfModels(iModel).ccdOutput];
    
    if ismember(prfModuleOutput, imageModuleOutputs, 'rows')
        
        iPrf = iPrf + 1;
        prfStruct(iPrf).ccdModule = prfModuleOutput(1);
        prfStruct(iPrf).ccdOutput = prfModuleOutput(2);
        
        [tempStruct] = blob_to_struct(prfModels(iModel).blob);
        if isfield(tempStruct, 'c')   % it's a single prf model
            prfModel.polyStruct = tempStruct;
        else
            prfModel = tempStruct;
        end % if / else
        [prfStruct(iPrf).prf] = ...
            prfCollectionClass(prfModel, dvDataObject.fcConstants);
        clear tempStruct prfModel
        
    end % if
    
end % for iModel

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

raDec2PixData = struct( ...
    'motionPolynomialStruct', [dvDataObject.targetTableDataStruct.motionPolyStruct], ...
    'fcConstants', dvDataObject.fcConstants, ...
    'pixelBaseCorrection', 0);

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

if ~isempty(differenceImageResults) && ...
        differenceImageResults(1).kicReferenceCentroid.raHours.uncertainty ~= GAP_VALUE && ...
        differenceImageResults(1).kicReferenceCentroid.decDegrees.uncertainty ~= GAP_VALUE
    referenceRaHours = ...
        differenceImageResults(1).kicReferenceCentroid.raHours.value;
    referenceRaDegrees = referenceRaHours * DEGREES_PER_HOUR;
    referenceDecDegrees = ...
        differenceImageResults(1).kicReferenceCentroid.decDegrees.value;
else
    referenceRaDegrees = [];
    referenceDecDegrees = [];
end % if / else

% Perform the bootstrap multi-quarter PRF fit to the out of transit and
% difference images to estimate the RA/Dec coordinates of the associated
% centroids and the covariance for each.
[centroidStatus, controlCentroidRaDegrees, controlCentroidDecDegrees, ...
    controlCentroidCovariance, differenceCentroidRaDegrees, ...
    differenceCentroidDecDegrees, differenceCentroidCovariance, diagnostics] = ...
	bootstrap_multi_quarter_prf_fit(controlImageData, differenceImageData, ...
    prfStruct, raDec2PixData, referenceRaDegrees, referenceDecDegrees, ...
    maxSinglePrfFitFailures, maxSinglePrfFitTrials, ...
    singlePrfFitForCentroidPositionsEnabled);

% Return if bootstrap failed.
if centroidStatus ~= 0
    alertString = 'Multi-quarter PRF fitting was attempted and failed';
    return
end % if

% Convert to the appropriate units and update the results structure.  
controlCentroidRaHours = controlCentroidRaDegrees * HOURS_PER_DEGREE;
controlCentroidCovariance = T_RA_HOURS_DEC_DEGREES * ...
    controlCentroidCovariance * T_RA_HOURS_DEC_DEGREES';

differenceCentroidRaHours = differenceCentroidRaDegrees * HOURS_PER_DEGREE;
differenceCentroidCovariance = T_RA_HOURS_DEC_DEGREES * ...
    differenceCentroidCovariance * T_RA_HOURS_DEC_DEGREES';

differenceImageMotionResults.mqControlImageCentroid.raHours.value = ...
    controlCentroidRaHours;
differenceImageMotionResults.mqControlImageCentroid.raHours.uncertainty = ...
    sqrt(controlCentroidCovariance(1, 1));
differenceImageMotionResults.mqControlImageCentroid.decDegrees.value = ...
    controlCentroidDecDegrees;
differenceImageMotionResults.mqControlImageCentroid.decDegrees.uncertainty = ...
    sqrt(controlCentroidCovariance(2, 2));

differenceImageMotionResults.mqDifferenceImageCentroid.raHours.value = ...
    differenceCentroidRaHours;
differenceImageMotionResults.mqDifferenceImageCentroid.raHours.uncertainty = ...
    sqrt(differenceCentroidCovariance(1, 1));
differenceImageMotionResults.mqDifferenceImageCentroid.decDegrees.value = ...
    differenceCentroidDecDegrees;
differenceImageMotionResults.mqDifferenceImageCentroid.decDegrees.uncertainty = ...
    sqrt(differenceCentroidCovariance(2, 2));

% Estimate the difference image centroid offsets and associated
% uncertainties with respect to the out of transit centroid and the KIC
% position from the results of the bootstrap PRF trials.
[differenceImageMotionResults] = ...
    compute_bootstrap_prf_fit_centroid_offsets(diagnostics, ...
    referenceRaDegrees, referenceDecDegrees, ...
    differenceImageMotionResults, mqOffsetConstantUncertainty, ...
    singlePrfFitForCentroidPositionsEnabled);

% Return.
return
