function resultStruct = test_reconstruct_result_from_event_array(paInputStruct, plotResults)
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

    if ~exist('plotResults', 'var')
        plotResults = false;
    end
    
    if ~isempty(paInputStruct.targetStarDataStruct) 
        pixelDataStructArray = [paInputStruct.targetStarDataStruct.pixelDataStruct]; 
    elseif ~isempty(paInputStruct.backgroundDataStruct)
        pixelDataStructArray = paInputStruct.backgroundDataStruct;         
    else
        error('paInputStruct contains no background or stellar target data!');
    end
    
    ccdRows              = [pixelDataStructArray.ccdRow]';
    ccdColumns           = [pixelDataStructArray.ccdColumn]';
    targetValues         = [pixelDataStructArray.values];
    timestamps           = paInputStruct.cadenceTimes.midTimestamps;
    gaps                 = any([pixelDataStructArray.gapIndicators], 2);
    
    % Instantiate object, clean, return matrices, and construct event
    % array.
    crcObj1 = cosmicRayResultsAnalysisClass(paInputStruct, '');
    [correctedFluxMat, eventIndicatorMat] = ...
        crcObj1.get_corrected_flux_and_event_indicator_matrices();
    [cosmicRayEvents] = create_cosmic_ray_events_list(targetValues, ...
        eventIndicatorMat, correctedFluxMat, ...
        ccdRows, ccdColumns, timestamps);    

    % Instantiate second object and reconstruct results from event array.
    crcObj2 = cosmicRayResultsAnalysisClass(paInputStruct, '');
    crcObj2.reconstruct_result_from_event_array(cosmicRayEvents, timestamps);
    
    % Compare the original results with the reconstructed results.
    correctedFluxMat2 = crcObj2.get_corrected_flux_and_event_indicator_matrices();
    resultStruct.absFluxDifference = sum(sum(abs(correctedFluxMat2(~gaps,:) - correctedFluxMat(~gaps,:))));
    
    if plotResults
        cosmicRayResultsAnalysisClass.compare_target_flux_results(crcObj1, crcObj2);
    end
end

