function transitInjectionResultsStruct = collect_transit_injection_results( ...
    targetStruct, tpsResults )
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function transitInjectionResultsStruct = collect_transit_injection_results
%     ( targetStruct, tpsResults, cadenceTimes, planetInformationStruct )
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Description:
% 
%
% Inputs:
%   
%
% Outputs:
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

% initialize

transitInjectionResultsStruct = struct('keplerId', [], 'elapsedTime', [], ...
    'log10SurfaceGravity', [], 'log10Metallicity', [], 'effectiveTemp', [], 'stellarRadiusInSolarRadii', [], ...
    'dataSpanInCadences', [], 'dutyCycle', [], ...
    'rmsCdpp', [], 'maxMes', [], 'numSesInMes', [], 'epochKjd', [], 'periodDays', [], 'trialTransitPulseInHours', [], ...
    'isPlanetACandidate', [], 'robustStatistic', [], 'fitSinglePulse', [], ...
    'fittedDepth', [], 'fittedDepthChi', [], 'zCompSum', [], ...
    'thresholdForDesiredPfa', [], 'chiSquare2', [], 'chiSquareGof', [], 'chiSquareDof2', [], ...
    'chiSquareGofDof', [], 'corrSum000', [], 'corrSum001', [], 'corrSum010', [], ...
    'corrSum011', [], 'corrSum100', [], 'corrSum101', [], 'corrSum110', [], ...
    'corrSum111', [], 'normSum000', [], 'normSum001', [], 'normSum010', [], ...
    'normSum011', [], 'normSum100', [], 'normSum101', [], 'normSum110', [], ...
    'normSum111', [], 'transitModelMatch', [], ...
    'injectedPeriodDays', [], 'planetRadiusInEarthRadii', [], 'impactParameter', [], ...
    'injectedEpochKjd', [], 'semiMajorAxisAu', [], 'injectedDurationInHours', [], 'injectedDepthPpm', [], ...
    'inclinationDegrees', [], 'equilibriumTempKelvin', []);

if ( isempty(targetStruct) && isempty(tpsResults) && ...
        isempty(elapsedTime) && isempty(planetInformationStruct) )
    % just return the initialized struct
    return;
end

% record all the values in reduced precision to save space

% first collect scalars
transitInjectionResultsStruct.keplerId = int32( targetStruct.keplerId );
transitInjectionResultsStruct.log10SurfaceGravity = single( targetStruct.log10SurfaceGravity );
transitInjectionResultsStruct.log10Metallicity = single( targetStruct.log10Metallicity );
transitInjectionResultsStruct.effectiveTemp = single( targetStruct.effectiveTemp );
transitInjectionResultsStruct.stellarRadiusInSolarRadii = single( targetStruct.radius );
transitInjectionResultsStruct.dataSpanInCadences = single( targetStruct.dataSpanInCadences );
transitInjectionResultsStruct.dutyCycle = single( targetStruct.dutyCycle );

% then collect vectors
transitInjectionResultsStruct.elapsedTime = single( [tpsResults.elapsedTime] );
transitInjectionResultsStruct.rmsCdpp = single( [tpsResults.rmsCdpp] );
transitInjectionResultsStruct.maxMes = single( [tpsResults.maxMultipleEventStatistic] );

nTargets = length(tpsResults);

for i=1:nTargets
    sesCombinedToYieldMes = tpsResults(i).sesCombinedToYieldMes ;
    if ~isempty( sesCombinedToYieldMes )
        transitInjectionResultsStruct.numSesInMes(i) = single( length( ...
            sesCombinedToYieldMes(sesCombinedToYieldMes ~= 0) ) ) ;
    end
end

% search returned values
transitInjectionResultsStruct.epochKjd = single([tpsResults.timeOfFirstTransitInMjd] - kjd_offset_from_mjd);
transitInjectionResultsStruct.periodDays = single( [tpsResults.detectedOrbitalPeriodInDays] );
transitInjectionResultsStruct.trialTransitPulseInHours = single( [tpsResults.trialTransitPulseInHours] );
transitInjectionResultsStruct.isPlanetACandidate = [tpsResults.isPlanetACandidate];
transitInjectionResultsStruct.robustStatistic = single( [tpsResults.robustStatistic] );
transitInjectionResultsStruct.fitSinglePulse = [tpsResults.fitSinglePulse];
transitInjectionResultsStruct.thresholdForDesiredPfa = single( [tpsResults.thresholdForDesiredPfa] );
transitInjectionResultsStruct.fittedDepth = single( [tpsResults.fittedDepth] );
transitInjectionResultsStruct.fittedDepthChi = single( [tpsResults.fittedDepthChi] );
transitInjectionResultsStruct.zCompSum = single( [tpsResults.zCompSum] );
transitInjectionResultsStruct.chiSquare2 = single( [tpsResults.chiSquare2] );
transitInjectionResultsStruct.chiSquareGof = single( [tpsResults.chiSquareGof] );
transitInjectionResultsStruct.chiSquareDof2 = single( [tpsResults.chiSquareDof2] );
transitInjectionResultsStruct.chiSquareGofDof = single( [tpsResults.chiSquareGofDof] );
transitInjectionResultsStruct.corrSum000 = single( [tpsResults.corrSum000] );
transitInjectionResultsStruct.corrSum001 = single( [tpsResults.corrSum001] );
transitInjectionResultsStruct.corrSum010 = single( [tpsResults.corrSum010] );
transitInjectionResultsStruct.corrSum011 = single( [tpsResults.corrSum011] );
transitInjectionResultsStruct.corrSum100 = single( [tpsResults.corrSum100] );
transitInjectionResultsStruct.corrSum101 = single( [tpsResults.corrSum101] );
transitInjectionResultsStruct.corrSum110 = single( [tpsResults.corrSum110] );
transitInjectionResultsStruct.corrSum111 = single( [tpsResults.corrSum111] );
transitInjectionResultsStruct.normSum000 = single( [tpsResults.normSum000] );
transitInjectionResultsStruct.normSum001 = single( [tpsResults.normSum001] );
transitInjectionResultsStruct.normSum010 = single( [tpsResults.normSum010] );
transitInjectionResultsStruct.normSum011 = single( [tpsResults.normSum011] );
transitInjectionResultsStruct.normSum100 = single( [tpsResults.normSum100] );
transitInjectionResultsStruct.normSum101 = single( [tpsResults.normSum101] );
transitInjectionResultsStruct.normSum110 = single( [tpsResults.normSum110] );
transitInjectionResultsStruct.normSum111 = single( [tpsResults.normSum111] );
transitInjectionResultsStruct.transitModelMatch = single( [tpsResults.transitModelMatch] );

% planet injection parameters
transitInjectionResultsStruct.injectedPeriodDays = single( [tpsResults.injectedPeriodDays] );
transitInjectionResultsStruct.planetRadiusInEarthRadii = single( [tpsResults.planetRadiusInEarthRadii] );
transitInjectionResultsStruct.impactParameter = single( [tpsResults.impactParameter] );
transitInjectionResultsStruct.injectedEpochKjd = single( [tpsResults.injectedEpochKjd] );
transitInjectionResultsStruct.semiMajorAxisAu = single( [tpsResults.semiMajorAxisAu] );
transitInjectionResultsStruct.injectedDurationInHours = single( [tpsResults.injectedDurationHours] );
transitInjectionResultsStruct.injectedDepthPpm = single( [tpsResults.injectedDepthPpm] );
transitInjectionResultsStruct.inclinationDegrees = single( [tpsResults.inclinationDegrees] );
transitInjectionResultsStruct.equilibriumTempKelvin = single( [tpsResults.equilibriumTempKelvin] );

return