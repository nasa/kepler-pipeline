function self  = test_dv_multiple_planet_loop(self)
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

initialize_soc_variables;
testDataDir = [socTestDataRoot filesep 'dv/unit-tests/multiplePlanetLoop'];
load( fullfile(testDataDir, 'dvDataStruct_14targets.mat') );
load( fullfile(testDataDir, 'dvResultsStruct_14targets.mat') );

messageOut = 'Test failed - The retrieved data and the expected data are not identical!';

% Codes in data_validation.m

display('dv_matlab_controller: instantiating dv data object...');
[dvDataObject] = dvDataClass(dvDataStruct);

[dvDataObject] = convert_dv_inputs_to_1_base(dvDataObject);

useHarmonicFreeCorrectedFlux = dvDataStruct.dvConfigurationStruct.useHarmonicFreeCorrectedFlux;
[normalizedFluxTimeSeriesArray, targetMedianFlux] = perform_dv_flux_normalization(dvDataObject, useHarmonicFreeCorrectedFlux);                                         

[dvResultsStruct_test] = initialize_dv_output_structure(dvDataObject, normalizedFluxTimeSeriesArray);

[dvResultsStruct_test] = create_directories_for_dv_figures(dvDataObject, dvResultsStruct_test);

% Run conduct_additional_planet_search.m

display(' ');
display('Test DV: Multiple Planet Loop');
display(' ');

nTargets = length(dvResultsStruct.targetResultsStruct);
for iTarget = 1:nTargets
   
    nPlanets = length(dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct);
    for jPlanet = 1:nPlanets

        display(' ');
        display(['Test flux time series of target #' num2str(iTarget) ' planet #' num2str(jPlanet)]);
        
        dvResultsStruct_test.targetResultsStruct(iTarget).residualFluxTimeSeries     = ...
            dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(jPlanet).planetCandidate.initialFluxTimeSeries;
        dvResultsStruct_test.targetResultsStruct(iTarget).planetResultsStruct(2:end) = [];
        
        [dvResultsStruct_test, thresholdCrossingEvent] = conduct_additional_planet_search(dvDataObject, dvResultsStruct_test, iTarget);
        
        if isempty( thresholdCrossingEvent )
            assert_equals(1, 0, messageOut);
        end
        
        planetCandidate = dvResultsStruct_test.targetResultsStruct(iTarget).planetResultsStruct(2).planetCandidate;
        
        if planetCandidate.keplerId<=0 || planetCandidate.planetNumber<=0 || ~isfield(planetCandidate, 'initialFluxTimeSeries') || ...
                planetCandidate.trialTransitPulseDuration<=0 || planetCandidate.epochMjd<=0 || planetCandidate.orbitalPeriod<=0 || ...
                planetCandidate.maxSingleEventSigma<=0 || planetCandidate.maxMultipleEventSigma<=0
            assert_equals(1, 0, messageOut);
        end
        
    end

    display(' ');
    display(['Test residual flux time series of target #' num2str(iTarget)]);

    dvResultsStruct_test.targetResultsStruct(iTarget).residualFluxTimeSeries     = dvResultsStruct.targetResultsStruct(iTarget).residualFluxTimeSeries;
    dvResultsStruct_test.targetResultsStruct(iTarget).planetResultsStruct(2:end) = [];
   
    [dvResultsStruct_test, thresholdCrossingEvent] = conduct_additional_planet_search(dvDataObject, dvResultsStruct_test, iTarget);

    if ~isempty( thresholdCrossingEvent )
        assert_equals(1, 0, messageOut);
    end
    
    
end

for iTarget=1:nTargets
    targetName = dvResultsStruct.targetResultsStruct(iTarget).dvFiguresRootDirectory;
    if exist(targetName, 'dir')
        eval(['rmdir(''' targetName ''', ''s'')' ]);
    end
    
end

return
