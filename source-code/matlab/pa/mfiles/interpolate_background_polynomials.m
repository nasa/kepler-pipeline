function [backgroundPolyStruct] = ...
interpolate_background_polynomials(backgroundPolyStruct, cadenceTimes, ...
processLongCadence)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [backgroundPolyStruct] = ...
% interpolate_background_polynomials(backgroundPolyStruct, cadenceTimes, ...
% processLongCadence)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Interpolate the (long cadence) background polynomials for missing long
% cadences, or to short cadence times. Assume that the interpolation is for
% long cadence data if the [optional] process long cadence flag is omitted.
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


% Get the cadence numbers.
cadenceNumbers = cadenceTimes.cadenceNumbers;
nCadences = length(cadenceNumbers);

backgroundPolyGapIndicators = ...
    ~logical([backgroundPolyStruct.backgroundPolyStatus]');

% Check whether processing long or short cadences.
if ~exist('processLongCadence', 'var')
    processLongCadence = true;
end

if processLongCadence
    
    % For long cadence data only need to interpolate background polynomials if
    % they are not available for one or more cadences.
    if any(backgroundPolyGapIndicators)
        
        % Interpolate the background polynomials and associated covariances.
        % The covariance interpolation is not a simple linear one.
        [backgroundStruct, cadenceTimes] = ...
            interpolate_polynomials([backgroundPolyStruct.backgroundPoly], ...
            backgroundPolyGapIndicators, cadenceTimes);
        
        % Update the background polynomial superstructure with the interpolated
        % background polynomials and necessary metadata.   
        startTimestamps = cadenceTimes.startTimestamps;
        midTimestamps = cadenceTimes.midTimestamps;
        endTimestamps = cadenceTimes.endTimestamps;
        
        timestampCellArray = ...
            num2cell(startTimestamps(backgroundPolyGapIndicators));
        [backgroundPolyStruct(backgroundPolyGapIndicators).mjdStartTime] = ...
            timestampCellArray{ : };
        
        timestampCellArray = ...
            num2cell(midTimestamps(backgroundPolyGapIndicators));
        [backgroundPolyStruct(backgroundPolyGapIndicators).mjdMidTime] = ...
            timestampCellArray{ : };
        
        timestampCellArray = ...
            num2cell(endTimestamps(backgroundPolyGapIndicators));
        [backgroundPolyStruct(backgroundPolyGapIndicators).mjdEndTime] = ...
            timestampCellArray{ : };
        
        backgroundCellArray = ...
            num2cell(backgroundStruct(backgroundPolyGapIndicators));
        [backgroundPolyStruct(backgroundPolyGapIndicators).backgroundPoly] = ...
            backgroundCellArray{ : };
        
        statusCellArray = num2cell(ones(size(backgroundPolyGapIndicators)));
        [backgroundPolyStruct(backgroundPolyGapIndicators).backgroundPolyStatus] = ...
            statusCellArray{ : };
        
    end % if
    
else % must be short cadence data
    
    % For short cadence data must interpolate if any background polynomials are
    % not available or if the length of the background polynomial structure is
    % less than the number of cadences.
    if any(backgroundPolyGapIndicators) || ...
            length(backgroundPolyStruct) < nCadences
        
        % Interpolate the row and column polynomials and associated
        % covariances. The covariance interpolation is not a simple linear
        % one.
        [backgroundStruct, cadenceTimes] = ...
            interpolate_polynomials([backgroundPolyStruct.backgroundPoly], ...
            backgroundPolyGapIndicators, cadenceTimes, ...
            [backgroundPolyStruct.mjdMidTime]');
        
        firstValidStruct = find(~backgroundPolyGapIndicators, 1);
        module = backgroundPolyStruct(firstValidStruct).module;
        output = backgroundPolyStruct(firstValidStruct).output;
        
        clear backgroundPolyStruct
        
        % Update the background polynomial superstructure with the interpolated
        % background polynomials and metadata.
        cadenceCellArray = num2cell(cadenceNumbers);
        [backgroundPolyStruct(1 : nCadences).cadence] = ...
            cadenceCellArray{ : };
        
        startTimestamps = cadenceTimes.startTimestamps;
        midTimestamps = cadenceTimes.midTimestamps;
        endTimestamps = cadenceTimes.endTimestamps;
        
        timestampCellArray = num2cell(startTimestamps);
        [backgroundPolyStruct(1 : nCadences).mjdStartTime] = ...
            timestampCellArray{ : };
        
        timestampCellArray = num2cell(midTimestamps);
        [backgroundPolyStruct(1 : nCadences).mjdMidTime] = ...
            timestampCellArray{ : };
        
        timestampCellArray = num2cell(endTimestamps);
        [backgroundPolyStruct(1 : nCadences).mjdEndTime] = ...
            timestampCellArray{ : };
        
        moduleCellArray = ...
            num2cell(repmat(module, [nCadences, 1]));
        [backgroundPolyStruct(1 : nCadences).module] = ...
            moduleCellArray{ : };
        
        outputCellArray = ...
            num2cell(repmat(output, [nCadences, 1]));
        [backgroundPolyStruct(1 : nCadences).output] = ...
            outputCellArray{ : };
        
        backgroundCellArray = num2cell(backgroundStruct);
        [backgroundPolyStruct(1 : nCadences).backgroundPoly] = ...
            backgroundCellArray{ : };
        
        statusCellArray = num2cell(ones(size(midTimestamps)));
        [backgroundPolyStruct(1 : nCadences).backgroundPolyStatus] = ...
            statusCellArray{ : };
        
    end % if
    
end % if / else

% Return.
return
