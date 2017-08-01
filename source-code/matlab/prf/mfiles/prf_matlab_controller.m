function prfResultStruct = prf_matlab_controller(prfParameterStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function prfResultStruct = prf_matlab_controller(prfParameterStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% 
% master control function for prf characterization
% the input prfParameterStruct is described in prfCreationClass.m.
% 
%
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

prfParameterStruct = prfInputStruct_convert_to_1_base(prfParameterStruct);

% prfParameterStruct.backgroundPolyStruct = blob_to_struct( ...
%     prfParameterStruct.backgroundBlobsStruct);
% prfParameterStruct.backgroundPolyStruct = poly_blob_series_to_struct( ...
%     prfParameterStruct.backgroundBlobsStruct);
% THE LINE ABOVE NEEDS TO BE CHANGED TO THE FOLLOWING IN ORDER FOR THIS TO
% WORK IN THE PIPELINE:
% prfParameterStruct.backgroundPolyStruct = ...
%     poly_blob_series_to_struct(prfParameterStruct.backgroundBlobsStruct);

backgroundModelBlobSeries = blobSeriesClass( prfParameterStruct.backgroundBlobsStruct ) ;
backgroundPolyStruct = get_struct_for_cadence( backgroundModelBlobSeries, 1 ) ;
prfParameterStruct.backgroundPolyStruct = backgroundPolyStruct.struct ;

debugFlag = prfParameterStruct.prfConfigurationStruct.debugLevel;
reportEnable = prfParameterStruct.prfConfigurationStruct.reportEnable;
durationList = [];
centroids = [] ;
motionBlobFileName = ' ' ;
ccdModule = prfParameterStruct.ccdModule ;
ccdOutput = prfParameterStruct.ccdOutput ;

% set the configuration parameters from the input arrays
% so they are instantiated when the prfCreationObject is created
% for multiple PRFs these will be overridden in fit_prf
ccdChannel = convert_from_module_output(ccdModule, ccdOutput);
prfParameterStruct.ccdChannel = ccdChannel;
prfParameterStruct.prfConfigurationStruct.magnitudeRange(1) ...
    = prfParameterStruct.prfConfigurationStruct.minimumMagnitudePrf1(ccdChannel);
prfParameterStruct.prfConfigurationStruct.magnitudeRange(2) ...
    = prfParameterStruct.prfConfigurationStruct.maximumMagnitudePrf1(ccdChannel);
prfParameterStruct.prfConfigurationStruct.crowdingThreshold ...
    = prfParameterStruct.prfConfigurationStruct.crowdingThresholdPrf1(ccdChannel);
prfParameterStruct.prfConfigurationStruct.contourCutoff ...
    = prfParameterStruct.prfConfigurationStruct.contourCutoffPrf1(ccdChannel);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% convert and save CAL uncertainty blob series
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
prfInputUncertaintiesFileName = 'prf_input_uncertainties.mat';
calUncertaintyBlobsStruct = prfParameterStruct.calUncertaintyBlobsStruct;

if ~isempty(calUncertaintyBlobsStruct.blobIndices)
    
    calUncertaintyObject = blobSeriesClass(calUncertaintyBlobsStruct);
    calUncertaintyGapIndicators = get_gap_indicators(calUncertaintyObject);
    if all(calUncertaintyGapIndicators)
        error('PRF:prfMatlabController:invalidCalUncertaintyBlob', ...
            'Uncertainty blob contains gaps only');
    end

    % find unique blob indices
    calUncertaintyIndices = get_blob_indices(calUncertaintyObject);
    [uniqueBlobIndices, uniqueIndex] = unique(calUncertaintyIndices, 'first');

    % retrieve array of all structs in calBlobSeries
    relativeCadences = (1 : length(calUncertaintyGapIndicators))';
    calStruct = get_struct_for_cadence(calUncertaintyObject, ...
        relativeCadences(uniqueIndex));

    % parse out needed arrays of structures
    calUncertaintiesStruct = [calStruct.struct];                            %#ok<NASGU>
    
else % CAL blob is empty
    
    calUncertaintiesStruct = [];                                            %#ok<NASGU>
    calUncertaintyIndices = [];                                             %#ok<NASGU>
    calUncertaintyGapIndicators = [];                                       %#ok<NASGU>
    uniqueBlobIndices = [];                                                 %#ok<NASGU>
    
end

% save for later use
save('-v7.3', prfInputUncertaintiesFileName, 'calUncertaintiesStruct', ...
    'calUncertaintyIndices', 'calUncertaintyGapIndicators', ...
    'uniqueBlobIndices');

if prfParameterStruct.pouConfigurationStruct.pouEnabled
    
    tic;
    display('prf_matlab_controller: decimating CAL POU blobs...');

    % save the decimated CAL POU blobs as separate variables
    for iBlob = uniqueBlobIndices(:)'

        decimatedCalPou = calUncertaintiesStruct(iBlob);
        varFileName = ['decimatedCalPou',num2str(iBlob),'.mat'];

        % decimated cadence list starts from PRF unit of work first cadence
        currentCalBlobCadences = ...
            (decimatedCalPou.absoluteFirstCadence:decimatedCalPou.absoluteLastCadence)';
        decimatedRelativeIndices = ...
            currentCalBlobCadences(mod(currentCalBlobCadences - ...
            prfParameterStruct.cadenceTimes.cadenceNumbers(1),...
            prfParameterStruct.pouConfigurationStruct.interpDecimation) == 0) - ...
            decimatedCalPou.absoluteFirstCadence + 1;

        decimatedCalPou.calTransformStruct = ...
            put_collateral_covariance(decimatedCalPou.calTransformStruct,...
            decimatedCalPou.compressedData, decimatedRelativeIndices);

        decimatedCalPou.compressedData = [];
        decimatedCalPou.decimatedRelativeIndices = decimatedRelativeIndices;

        % append the decimated struct to a local file
        save( '-v7.3', varFileName, 'decimatedCalPou' );
        clear decimatedCalPou;

    end
    
    duration = toc;

    durationElement = length(durationList);
    durationList(durationElement + 1).time = duration;
    durationList(durationElement + 1).label = 'decimate CAL POU';

    if (debugFlag) 
        display(['decimate CAL POU: ' num2str(duration) ...
            ' seconds = ' num2str(duration/60) ' minutes']);
    end

end

% clean up POU
clear calUncertaintiesStruct calUncertaintyIndices calUncertaintyGapIndicators uniqueBlobIndices;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% create prfClass
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

prfCreationObject = prfCreationClass(prfParameterStruct);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% remove background 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

tic;
prfCreationObject = remove_background_from_targets(prfCreationObject);
duration = toc;

durationElement = length(durationList);
durationList(durationElement + 1).time = duration;
durationList(durationElement + 1).label = 'remove background';

if (debugFlag) 
    display(['remove background: ' num2str(duration) ...
        ' seconds = ' num2str(duration/60) ' minutes']);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% compute the pixel position of all the stars 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

tic;
prfCreationObject = compute_star_positions(prfCreationObject);
duration = toc;

durationElement = length(durationList);
durationList(durationElement + 1).time = duration;
durationList(durationElement + 1).label = 'compute star position';

if (debugFlag) 
    display(['compute star position: ' num2str(duration) ...
        ' seconds = ' num2str(duration/60) ' minutes']);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Compute down-selection and compute PRF:  this is done in
% a loop over regions, in the case where we are required to
% fit multiple PRFs per mod/out
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[prfCreationObject, durationList, prfFitResultsStruct] = fit_prf( prfCreationObject, ...
  durationList, debugFlag ) ;

% unpack the prfFitResults structure

regionFractionVector = prfFitResultsStruct.regionFractionVector ;
nStarsVector         = prfFitResultsStruct.nStarsVector ;
selectedTargetMatrix = prfFitResultsStruct.selectedTargetMatrix ;
prfCollectionStruct  = prfFitResultsStruct.prfCollectionStruct ;
prfStructureVector   = prfFitResultsStruct.prfStructureVector ;
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Diagnostic output
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
% diagnostics include the following:
% => targetStarsStruct (the selectedTarget field is removed to avoid confusion)
% => prfStructureVector
% => the selectedTargetMatrix
% => nStarsVector
% => regionFractionVector

targetStarsStruct = get(prfCreationObject, 'targetStarsStruct');
targetStarsStruct = rmfield(targetStarsStruct,'selectedTarget') ;

save(['prfResultData_m' num2str(prfParameterStruct.ccdModule) ...
    'o' num2str(prfParameterStruct.ccdOutput) '.mat'], 'targetStarsStruct', ...
    'prfStructureVector','selectedTargetMatrix','nStarsVector','regionFractionVector');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% compute the centroids of all the stars 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


tic;
centroids = compute_target_centroids(prfCreationObject, prfCollectionStruct);

duration = toc;

durationElement = length(durationList);
durationList(durationElement + 1).time = duration;
durationList(durationElement + 1).label = 'compute star centroids';

if (debugFlag) 
    display(['compute star centroids: ' num2str(duration) ...
        ' seconds = ' num2str(duration/60) ' minutes']);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% compute the motion polynomials
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

tic;
[motionBlobFileName] = fit_motion_polynomials(prfCreationObject, centroids);
duration = toc;

durationElement = length(durationList);
durationList(durationElement + 1).time = duration;
durationList(durationElement + 1).label = 'fit motion polynomials';

if (debugFlag) 
    display(['fit motion polynomials: ' num2str(duration) ...
        ' seconds = ' num2str(duration/60) ' minutes']);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% check centroid convergence
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

tic;
[centroidsConverged deltaCentroidNorm centroidChangeData] ...
    = check_centroid_convergence(prfCreationObject, centroids);
duration = toc;
save(['centroidChangeData_m' num2str(prfParameterStruct.ccdModule) ...
    'o' num2str(prfParameterStruct.ccdOutput) '.mat'], 'centroidChangeData');

durationElement = length(durationList);
durationList(durationElement + 1).time = duration;
durationList(durationElement + 1).label = 'check centroid convergence';

if (debugFlag) 
    display(['check centroid convergence: ' num2str(duration) ...
        ' seconds = ' num2str(duration/60) ' minutes']);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Pipeline output
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Pipeline output includes the following:
% => the blob of the prfCollectionStruct
% => the duration list

prfBlobFilename = ['prfBlob_',datestr(now,30),'.mat'];
struct_to_blob(prfCollectionStruct, prfBlobFilename);
prfResultStruct.prfCollectionBlobFileName = prfBlobFilename;
prfResultStruct.centroids = centroids;
prfResultStruct.centroidsConverged = centroidsConverged;
prfResultStruct.deltaCentroidNorm = deltaCentroidNorm;
prfResultStruct.motionPolyBlobFileName = motionBlobFileName;
prfResultStruct.durationList = durationList;

% convert output to 0-base
prfResultStruct = prfOutputStruct_convert_to_0_base(prfResultStruct);

if ~reportEnable
    return;
end

% generate the reports, if possible
reportDatenum = now ;

[fullReportFileName, varList] = generate_report_soc('prf', 'prf', 'pdf', ...
    ccdModule, ccdOutput,  ...
    'prfInputStruct',prfParameterStruct, ...
    'prfStructureVector',prfStructureVector, ...
    'targetStarsStruct',targetStarsStruct, ...
    'selectedTargetMatrix',selectedTargetMatrix, ...
    'regionFractionVector',regionFractionVector, ...
    'nStarsVector',nStarsVector, ...
    'prfResultStruct',prfResultStruct) ;

[digestReportFileName, varList] = generate_report_soc('prfDigest', 'prfDigest', 'pdf', ...
    ccdModule, ccdOutput, ...
    'prfInputStruct',prfParameterStruct, ...
    'prfStructureVector',prfStructureVector, ...
    'targetStarsStruct',targetStarsStruct, ...
    'selectedTargetMatrix',selectedTargetMatrix, ...
    'regionFractionVector',regionFractionVector, ...
    'nStarsVector',nStarsVector, ...
    'prfResultStruct',prfResultStruct) ;

prfResultStruct.fullReportFileName = fullReportFileName ;
prfResultStruct.digestReportFileName = digestReportFileName ;
