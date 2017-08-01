function [theoreticalCompressionEfficiency, achievedCompressionEfficiency] = ...
cal_compression_efficiency(calObject)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [theoreticalCompressionEfficiency, achievedCompressionEfficiency] = ...
% cal_compression_efficiency(calObject)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Interface between cal_matlab_controller and
% compute_compression_efficiency function.
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

% Check if this is the last CAL matlab call.
if calObject.lastCall
    
    % Get required fields from input object.
    fcConstants = calObject.fcConstants;
    spacecraftConfigMap = calObject.spacecraftConfigMap;
    requantTables = calObject.requantTables;
    huffmanTables = calObject.huffmanTables;
    cadenceTimes = calObject.cadenceTimes;
    totalPixels = calObject.totalPixels;
    debugLevel = calObject.debugLevel;
    
    localFilenames = calObject.localFilenames;

    % Instantiate a config map object.
    configMapObject = configMapClass(spacecraftConfigMap);

    % Get the remaining required inputs for computation of the compression
    % efficiency.
    timestamp = cadenceTimes.timestamp;
    cadenceGapIndicators = cadenceTimes.gapIndicators;
    nCadences = length(timestamp);
    
%     % update cadence gaps based on exclude indicators
%     enableExcludeIndicators = calObject.moduleParametersStruct.enableExcludeIndicators;
%     enableExcludePreserve = calObject.moduleParametersStruct.enableExcludePreserve;     
%     if enableExcludeIndicators && enableExcludePreserve
%         excludeIndicators = cadenceTimes.dataAnomalyFlags.excludeIndicators;
%         cadenceGapIndicators = cadenceGapIndicators | excludeIndicators;
%         cadenceTimes.gapIndicators = cadenceGapIndicators;
%     end
 
    requantTableLength = fcConstants.REQUANT_TABLE_LENGTH;
    nRequantBits = ceil(log2(requantTableLength));
    
    baselineIntervals = zeros(size(timestamp));
    baselineIntervals(~cadenceGapIndicators) = ...
        get_number_of_longs_between_baselines(configMapObject, ...
        timestamp(~cadenceGapIndicators));
    
    % Compute the theoretical and achieved compression efficiency on a cadence
    % by cadence basis.
    [theoreticalCompressionEfficiency, achievedCompressionEfficiency] = ...
        compute_compression_efficiency(nRequantBits, requantTables, ...
        huffmanTables, cadenceTimes, baselineIntervals, totalPixels, ...
        nCadences, localFilenames, debugLevel);

else % not the last call
    
    % Set the output structures with empty arrays for the Java interface.
    theoreticalCompressionEfficiency.values = [];
    theoreticalCompressionEfficiency.gapIndicators = [];
    theoreticalCompressionEfficiency.nCodeSymbols = [];
    
    achievedCompressionEfficiency.values = [];
    achievedCompressionEfficiency.gapIndicators = [];
    achievedCompressionEfficiency.nCodeSymbols = [];
    
end % if/else

% Return.
return
