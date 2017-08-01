function [paDataObject, paResultsStruct] = ...
process_background_pixels(paDataObject, paResultsStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [paResultsStruct, backgroundPolyStruct] = ...
% process_background_pixels(paDataObject, paResultsStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This method is called only for long cadence data processing, and then
% only on the first call to PA. All background pixel time series will be
% provided in the input data object. If cosmic ray cleaning is enabled then
% cosmic rays are identified and removed from the background pixel time
% series. In this case, the background cosmic ray events are saved to the
% PA state file and also to the PA results structure.
%
% Two dimensional background polynomials are fit to the (cleaned)
% background pixels on a cadence by cadence basis. These polynomials will
% later be used for subtraction of background estimates from both long and
% short cadence pixel time series. The background polynomial structure is
% saved to the background polynomial file and also returned by this method.
% The PA results structure is updated with the background polynomial file
% name.
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


% Get file names.
paFileStruct = paDataObject.paFileStruct;
paStateFileName = paFileStruct.paStateFileName;

% Get fields from input structure.
paConfigurationStruct = paDataObject.paConfigurationStruct;
cosmicRayCleaningEnabled = paConfigurationStruct.cosmicRayCleaningEnabled;
simulatedTransitsEnabled = paConfigurationStruct.simulatedTransitsEnabled;
debugLevel = paConfigurationStruct.debugLevel;                                              %#ok<NASGU>

argabrighteningConfigurationStruct = ...
    paDataObject.argabrighteningConfigurationStruct;
mitigationEnabled = argabrighteningConfigurationStruct.mitigationEnabled;

backgroundDataStruct = paDataObject.backgroundDataStruct;

cadenceTimes = paDataObject.cadenceTimes;
cadenceNumbers = cadenceTimes.cadenceNumbers;

% Identify the Argabrightnening cadences, gap the associated background
% pixels and save the Arga cadences. Also populate the PA results structure
% with the indices of the Arga cadences.
if mitigationEnabled
    
    tic
    display('process_background_pixels: identifying argabrightening cadences...');
    pixelValues = [backgroundDataStruct.values];
    pixelGapIndicators = [backgroundDataStruct.gapIndicators];
    [isArgaCadence, argaCadences, argaStatistics] = ...
        identify_argabrightening_cadences(pixelValues, pixelGapIndicators, ...
        cadenceNumbers, argabrighteningConfigurationStruct);                               %#ok<NASGU>
    nArgaCadences = length(argaCadences);
    save(paStateFileName, 'isArgaCadence', 'argaCadences', ...
            'argaStatistics', '-append');
        
    if nArgaCadences > 0
        
        [paResultsStruct.alerts] = add_alert(paResultsStruct.alerts, 'warning', ...
            ['flux, centroids and metrics will be gapped for ', num2str(nArgaCadences), ...
            ' argabrightening cadence(s)']);
        disp(paResultsStruct.alerts(end).message);
        
        for iPixel = 1 : length(backgroundDataStruct)
            backgroundDataStruct(iPixel).values(isArgaCadence) = 0;
            backgroundDataStruct(iPixel).uncertainties(isArgaCadence) = 0;
            backgroundDataStruct(iPixel).gapIndicators(isArgaCadence) = true;
        end % for iPixel
        
    end % if
    
    paDataObject.backgroundDataStruct = backgroundDataStruct;
    paResultsStruct.argabrighteningIndices = find(isArgaCadence);
    duration = toc;
    display(['Argabrightening cadences identified: ' num2str(duration) ...
        ' seconds = '  num2str(duration/60) ' minutes']);
    
end % if

% Clean cosmic rays from the background pixels if CR cleaning is enabled.
% No need to clean pixel for simulated transit processing since the
% background polynomial fit is provided as an input blob.
if cosmicRayCleaningEnabled && ~simulatedTransitsEnabled
    
    % Clean cosmic rays from background data. Save cleaned data to PA data
    % object. Write events to PA state file so that metrics can be computed
    % later. Copy events to PA results structure.
    tic
    display('process_background_pixels: cleaning background cosmic rays...');
    [paDataObject, paResultsStruct] = ...
        clean_background_cosmic_rays(paDataObject, paResultsStruct);
    duration = toc;
    display(['Background cosmic rays cleaned: ' num2str(duration) ...
        ' seconds = '  num2str(duration/60) ' minutes']);

end

% Fit the background polynomials.
if ~simulatedTransitsEnabled
    tic
    display('process_background_pixels: fitting background polynomials...');
    [paResultsStruct] = ...
        fit_background(paDataObject, paResultsStruct);
    duration = toc;
    display(['Background polynomials computed: ' num2str(duration) ...
        ' seconds = '  num2str(duration/60) ' minutes']);
end
    
% Return
return
