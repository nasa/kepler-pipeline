function [paResultsStruct] = ...
identify_argabrightening_cadences_and_fill_background_polys( ...
paDataObject, paResultsStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [paResultsStruct] = ...
% identify_argabrightening_cadences_and_fill_background_polys( ...
% paDataObject, paResultsStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This function is called for short cadence if the processing state is
% MOTION_BACKGROUND_BLOBS.
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
    paFileStruct            = paDataObject.paFileStruct;
    paStateFileName         = paFileStruct.paStateFileName;

    % Get fields from input structure.
    backgroundPolyStruct    = paDataObject.backgroundPolyStruct;
    configMapObject         = configMapClass(paDataObject.spacecraftConfigMap);

    % Get some flags.
    paConfigurationStruct   = paDataObject.paConfigurationStruct;
    debugLevel              = paConfigurationStruct.debugLevel;                                             %#ok<NASGU>


    % Get some configurations.
    argabrighteningConfigurationStruct  = paDataObject.argabrighteningConfigurationStruct;
    mitigationEnabled       = argabrighteningConfigurationStruct.mitigationEnabled;

    targetStarDataStruct    = paDataObject.targetStarDataStruct;

    cadenceTimes            = paDataObject.cadenceTimes;
    cadenceNumbers          = cadenceTimes.cadenceNumbers;

    % Identify the Argabrightening cadences if the data are short cadence
    % and this is the first call. Gap the long and short cadence target
    % data for all Argabrightening cadences (in all invocations) if
    % enabled.
    if mitigationEnabled

        tic
        display('process_target_pixels: identifying argabrightening cadences...');
        pixelDataStructArray = [targetStarDataStruct.pixelDataStruct];
        pixelValues = [pixelDataStructArray.values];
        pixelGapIndicators = [pixelDataStructArray.gapIndicators];
        inOptimalAperture = [pixelDataStructArray.inOptimalAperture]';
        clear pixelDataStructArray

        [isArgaCadence, argaCadences, argaStatistics] = ...
            identify_argabrightening_cadences(pixelValues( : , ~inOptimalAperture), ...
            pixelGapIndicators( : , ~inOptimalAperture), cadenceNumbers, ...
            argabrighteningConfigurationStruct);                                               %#ok<NASGU>
        nArgaCadences = length(argaCadences);
        save(paStateFileName, 'isArgaCadence', 'argaCadences', ...
                'argaStatistics', '-append');

        if nArgaCadences > 0
            [paResultsStruct.alerts] = add_alert(paResultsStruct.alerts, 'warning', ...
                ['Flux, centroids and metrics will be gapped for ', num2str(nArgaCadences), ...
                ' Argabrightening cadence(s)']);
            disp(paResultsStruct.alerts(end).message);
        end % if

        duration = toc;
        display(['Argabrightening cadences identified: ' num2str(duration) ...
            ' seconds = '  num2str(duration/60) ' minutes']);

    end % if


    % For short cadence processing, on the first invocation gap fill and
    % update the background polynomial struct in paDataObject and in
    % pa_state.mat. The long cadence background polynomials are attached to
    % the paDataObject as read from the background blob on the first
    % invocation only. For long cadence processing, the background
    % polynomials are already gap filled and saved to the pa_state file
    % after background polynomial fitting. The file pa_background.mat
    % contains the original (un-gap filled) polynomials which are what get
    % saved to the background polynomial blob.
    [backgroundPolyStruct] = ...
        fill_background_polynomial_struct_array(backgroundPolyStruct, ...
        configMapObject, cadenceTimes, 'SHORT');
    save(paStateFileName, 'backgroundPolyStruct', '-append');


% Return.
return
