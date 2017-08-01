function [dvResultsStruct, thresholdCrossingEvent, tpsResults, varargout] = conduct_additional_planet_search(dvDataObject, dvResultsStruct, iTarget, tpsTaskTimeoutSecs)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [dvResultsStruct, thresholdCrossingEvent, tpsResults] = conduct_additional_planet_search(dvDataObject, dvResultsStruct, iTarget, tpsTaskTimeoutSecs)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Conduct additional planet search for the given target by calling TPS.
% The inputs to TPS (flux time series values, uncertainties, gapIndices, etc.) are retrieved from the residual time series structure
% of the given target data structure in dvResultsStruct.
% Upon return, the singleEventStatistics structure of the given target is updated with the corresponding TPS outputs if there is a 
% threshold crossing event (TCE).
% If the multiple planet search is not enabled or the planet candidate limit has been reached, the returned 
% thresholdCrossingEvent structure is empty.
% If there is no TCE, the returned thresholdCrossingEvent structure is empty, and there is no other update in dvResultsStruct.
% If there is a TCE, one item is added to structure array planetResultsStruct of the given target. The returned thresholdCrossingEvent
% structure and the planetCandidate structure within the new item of planetResultsStruct are updated with the TCE information from the 
% TPS outputs.
%
% Version date:  2015-Aug-20.
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

% Modification History:
%    2015-Aug-20, JT
%        populate single event statistics only if call to TPS from DV does
%        not return TCE; these are null event statistics
%    2013-April-11, jcat
%        call conduct_additional_planet_search with tpsInputStruct as last output argument
%        and pass tpsInputStruct as an output argument
%
%    2013-March-05, JL:
%        add input 'tpsTaskTimeoutSecs'
%    2011_July-05, JL:
%        make changes in the conditions to add a planet so that the output struct 'thresholdCrossingEvent' 
%        of call_tps_from_dv may be empty
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% Get fields from the input structure
dvConfigurationStruct = dvDataObject.dvConfigurationStruct;
multiplePlanetSearchEnabled = ...
    dvConfigurationStruct.multiplePlanetSearchEnabled;
maxCandidatesPerTarget = dvConfigurationStruct.maxCandidatesPerTarget;
externalTcesEnabled = dvConfigurationStruct.externalTcesEnabled;

% Get planet number and Kepler ID
planetNumber = length(dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct);
keplerId = dvDataObject.targetStruct(iTarget).keplerId;

% Get the number of TCEs in the event that external TCEs are enabled.
nTces = length(dvDataObject.targetStruct(iTarget).thresholdCrossingEvent);

% fill any gaps in the data which were introduced by either the planet fitter or the
% eclipsing binary detector

residualFluxTimeSeries  = ...
    dvResultsStruct.targetResultsStruct(iTarget).residualFluxTimeSeries ;
timeSeriesWithGaps      = residualFluxTimeSeries.values ;
uncertaintiesWithGaps   = residualFluxTimeSeries.uncertainties ;
gapFillParametersStruct = dvDataObject.gapFillConfigurationStruct ;
debugLevel              = dvDataObject.dvConfigurationStruct.debugLevel ;
gapIndicators           = residualFluxTimeSeries.gapIndicators ;
filledIndicesOld        = residualFluxTimeSeries.filledIndices ;
indexOfAstroEvents      = 0 ;

filledIndices = find(gapIndicators) ;

% fill gaps if there are any, otherwise skip

if ~isempty(filledIndices)
    
    [timeSeriesWithGapsFilled, indexOfAstroEvents, gapIndicators, ...
        uncertaintiesWithGapsFilled, fittedTrend] = fill_short_gaps(timeSeriesWithGaps, ...
        gapIndicators, indexOfAstroEvents, debugLevel, ...
        gapFillParametersStruct, uncertaintiesWithGaps ) ;

    if any(gapIndicators)

        % fill outlier indicators to prevent them from entering long fill

        outlierIndicators = false( size(gapIndicators) ) ;
        outlierIndicators(indexOfAstroEvents) = true ;

        timeSeriesWithOutliersFilled = fill_short_gaps(timeSeriesWithGaps, ...
            outlierIndicators, find(gapIndicators), debugLevel, gapFillParametersStruct, ...
            uncertaintiesWithGapsFilled, fittedTrend ) ;

        % fill long gaps

        timeSeriesWithLongGapsFilled = fill_missing_quarters_via_reflection( ...
            timeSeriesWithOutliersFilled, gapIndicators, [], ...
            gapFillParametersStruct ) ;

        % put back outliers

        timeSeriesWithLongGapsFilled(outlierIndicators) = ...
            timeSeriesWithGapsFilled(outlierIndicators) ;
        timeSeriesWithGapsFilled = timeSeriesWithLongGapsFilled ;   

        uncertaintiesWithGapsFilled(gapIndicators) = -1 ;
        gapIndicators = false(size(gapIndicators)) ;
    end
else
    timeSeriesWithGapsFilled = timeSeriesWithGaps ;
    uncertaintiesWithGapsFilled = uncertaintiesWithGaps ;
    filledIndices = filledIndicesOld ;
end


residualFluxTimeSeries.values        = timeSeriesWithGapsFilled ;
residualFluxTimeSeries.uncertainties = uncertaintiesWithGapsFilled ;
residualFluxTimeSeries.gapIndicators = gapIndicators ;
residualFluxTimeSeries.filledIndices = sort(unique( [filledIndicesOld ; filledIndices] ) ) ;

dvResultsStruct.targetResultsStruct(iTarget).residualFluxTimeSeries = ...
    residualFluxTimeSeries ;

% Call TPS if external TCEs are not enabled. If external TCEs are enabled
% then get the next external TCE if there is one
display(' ');
display(['DV: Conduct additional planet search for target #' num2str(iTarget) ' (keplerId: ' num2str(keplerId) ')'] );
display(['TPS task timeout is set to ' num2str(tpsTaskTimeoutSecs) ' seconds']);
display(' ');
    
if ~externalTcesEnabled
    
    % Call TPS
    [potentialThresholdCrossingEvent, singleEventStatistics, tpsResults, tpsInputStruct] = ...
        call_tps_from_dv(dvDataObject, dvResultsStruct, iTarget, tpsTaskTimeoutSecs) ;
    
    % Pass tpsInputStruct as an output argument
    if(nargout == 4)
        varargout{1} = tpsInputStruct;
    end

    % Update singleEventStatistics structure in dvResultsStruct if there is
    % no TCE (otherwise they do not represent null statistics for
    % computation of the bootstrap)
    if isempty(potentialThresholdCrossingEvent)
        dvResultsStruct.targetResultsStruct(iTarget).singleEventStatistics = ...
            singleEventStatistics ;
    end
    
elseif externalTcesEnabled && planetNumber < nTces
    
    % Get next external TCE
    potentialThresholdCrossingEvent = ...
        dvDataObject.targetStruct(iTarget).thresholdCrossingEvent(planetNumber + 1) ;
    tpsResults = [] ;
    
    if nargout == 4
        varargout{1} = [];
    end
    
else
    
    % Set structures to empty
    potentialThresholdCrossingEvent = [] ;
    tpsResults = [] ;
    
    if nargout == 4
        varargout{1} = [];
    end
    
end

% Add alert if limit on number of planets is reached AND one additional threshold crossing event is reported by TPS
if multiplePlanetSearchEnabled && planetNumber>=maxCandidatesPerTarget && ~isempty( potentialThresholdCrossingEvent )
    dvResultsStruct = add_dv_alert(dvResultsStruct, 'conductAdditionalPlanetSearch', 'warning', ...
        'Limit on number of planets is reached AND one additional threshold crossing event is reported by TPS', iTarget, keplerId);
    disp(dvResultsStruct.alerts(end).message);
end

thresholdCrossingEvent = [];

if multiplePlanetSearchEnabled && planetNumber<maxCandidatesPerTarget && ~isempty( potentialThresholdCrossingEvent )
    
    display('Threshold crossing event observed in TPS output. Length of structure array planetResultsStruct increased by 1 ...');
    
    % If there is a TCE, add one item in struct array planetResultsStruct
    newPlanetNumber = planetNumber + 1;

    create_per_planet_figure_directories(dvDataObject, ...
         dvResultsStruct.targetResultsStruct(iTarget).dvFiguresRootDirectory, ...
         newPlanetNumber);

    % Update fields of thresholdCrossingEvent structure with TCE information from TPS outputs
    thresholdCrossingEvent = potentialThresholdCrossingEvent ;
    
    % Set default values to the fields of new item of planetResultsStruct
    dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(newPlanetNumber) = ...
        initialize_planet_results_structure( dvDataObject, keplerId, newPlanetNumber, ...
        thresholdCrossingEvent, ...
        dvResultsStruct.targetResultsStruct(iTarget).residualFluxTimeSeries );

end

return

