function self  = test_dv_tps_caller(self)

% This test is intended to be executed in the mlunit context.  For standalone execution
% use the following syntax:
%
%      run(text_test_runner, testTpsCallerClass('test_dv_tps_caller'));
%
%=========================================================================================
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
testDataDir = [socTestDataRoot filesep 'dv/unit-tests/tpsCaller'];
load( fullfile(testDataDir, 'tpsInputStruct_30Aug2009.mat') );
load( fullfile(testDataDir, 'dvDataStruct_tpsCaller.mat') );

tpsKeplerIds     = [];
tpsTransitPulses = [];
for i=1:length(tpsInputStruct_dv.tpsTargets)

    display(' ');
    display(['Run tps_matlab_controller for star #' num2str(i)]);
    display(' ');
    
    tpsInputStruct_1target.tpsModuleParameters                   = orderfields(tpsInputStruct_dv.tpsModuleParameters);
    tpsInputStruct_1target.gapFillParameters                     = orderfields(tpsInputStruct_dv.gapFillParameters);
    tpsInputStruct_1target.harmonicsIdentificationParameters     = orderfields(tpsInputStruct_dv.harmonicsIdentificationParameters);
    tpsInputStruct_1target.rollTimeModel                         = orderfields(tpsInputStruct_dv.rollTimeModel);
    tpsInputStruct_1target.cadenceTimes                          = orderfields(tpsInputStruct_dv.cadenceTimes);
    tpsInputStruct_1target.tpsTargets.keplerId                   = tpsInputStruct_dv.tpsTargets(i).keplerId;
    tpsInputStruct_1target.tpsTargets.diagnostics.keplerMag      = tpsInputStruct_dv.tpsTargets(i).kepMag;
    tpsInputStruct_1target.tpsTargets.diagnostics.validKeplerMag = tpsInputStruct_dv.tpsTargets(i).validKepMag;
    tpsInputStruct_1target.tpsTargets.diagnostics.crowdingMetric = tpsInputStruct_dv.tpsTargets(i).crowdingMetric;
    tpsInputStruct_1target.tpsTargets.fluxValue                  = tpsInputStruct_dv.tpsTargets(i).fluxValue;
    tpsInputStruct_1target.tpsTargets.uncertainty                = tpsInputStruct_dv.tpsTargets(i).uncertainty;
    tpsInputStruct_1target.tpsTargets.gapIndices                 = tpsInputStruct_dv.tpsTargets(i).gapIndices;
    tpsInputStruct_1target.tpsTargets.fillIndices                = tpsInputStruct_dv.tpsTargets(i).fillIndices;
    tpsInputStruct_1target.tpsTargets.outlierIndices             = tpsInputStruct_dv.tpsTargets(i).outlierIndices;
    tpsInputStruct_1target.tpsTargets.discontinuityIndices       = tpsInputStruct_dv.tpsTargets(i).discontinuityIndices;
    
    tpsOutputStruct_dv(i) = tps_matlab_controller(tpsInputStruct_1target);
    
    keplerIds             = [tpsOutputStruct_dv(i).tpsResults.keplerId];
    transitPulses         = [tpsOutputStruct_dv(i).tpsResults.trialTransitPulseInHours];
    
    tpsKeplerIds          = [ tpsKeplerIds;     keplerIds(:)     ];
    tpsTransitPulses      = [ tpsTransitPulses; transitPulses(:) ];
    
end

% Codes in data_validation.m

messageOut = 'Test failed - The retrieved data and the expected data are not identical!';

display('dv_matlab_controller: instantiating dv data object...');
[dvDataObject] = dvDataClass(dvDataStruct);

[dvDataObject] = convert_dv_inputs_to_1_base(dvDataObject);

useHarmonicFreeCorrectedFlux = dvDataStruct.dvConfigurationStruct.useHarmonicFreeCorrectedFlux;
[normalizedFluxTimeSeriesArray, targetMedianFlux] = perform_dv_flux_normalization(dvDataObject, useHarmonicFreeCorrectedFlux);                                         

[dvResultsStruct] = initialize_dv_output_structure(dvDataObject, normalizedFluxTimeSeriesArray);

[dvResultsStruct] = create_directories_for_dv_figures(dvDataObject, dvResultsStruct);

% Run conduct_additional_planet_search.m

nTargets = length(dvResultsStruct.targetResultsStruct);
for iTarget = 1:nTargets
    [dvResultsStruct, thresholdCrossingEvent] = conduct_additional_planet_search(dvDataObject, dvResultsStruct, iTarget);
end

display(' ');
display('Test DV: TPS Caller');

for iTarget = 1:nTargets

    nPlanets = length(dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct);

    if nPlanets==2
        keplerId                = dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(nPlanets).planetCandidate.keplerId;
        transitPulse            = dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(nPlanets).planetCandidate.trialTransitPulseDuration;
        epochMjd                = dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(nPlanets).planetCandidate.epochMjd;
        orbitalPeriod           = dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(nPlanets).planetCandidate.orbitalPeriod;
        maxSingleEventSigma     = dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(nPlanets).planetCandidate.maxSingleEventSigma;
        maxMultipleEventSigma   = dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(nPlanets).planetCandidate.maxMultipleEventSigma;

        index   = find( keplerId==tpsKeplerIds & transitPulse==tpsTransitPulses );
        iStar   = floor((index-1)/3) + 1;
        iResult = mod(index-1,3) + 1;

        display(['test target #' num2str(iTarget) ' (keplerId: ' num2str(keplerId) ')']);
        deltaEpochMjd               = abs( epochMjd              - tpsOutputStruct_dv(iStar).tpsResults(iResult).timeOfFirstTransitInMjd      );
        deltaOrbitalPeriod          = abs( orbitalPeriod         - tpsOutputStruct_dv(iStar).tpsResults(iResult).detectedOrbitalPeriodInDays  );
        deltaMaxSingleEventSigma    = abs( maxSingleEventSigma   - max(tpsOutputStruct_dv(iStar).tpsResults(iResult).sesCombinedToYieldMes )  );
        deltaMaxMultipleEventSigma  = abs( maxMultipleEventSigma - tpsOutputStruct_dv(iStar).tpsResults(iResult).maxMultipleEventStatistic    );

        if ( deltaEpochMjd>eps || deltaOrbitalPeriod>eps || deltaMaxSingleEventSigma>eps || deltaMaxMultipleEventSigma>eps )
            assert_equals(1, 0, messageOut);
        end
    end

end

for iTarget=1:nTargets
    targetName = dvResultsStruct.targetResultsStruct(iTarget).dvFiguresRootDirectory;
    if exist(targetName, 'dir')
        eval(['rmdir(''' targetName ''', ''s'')' ]);
    end
    
end

return
