function  pagOutputStruct = pag_generate_output_time_series(pagScienceObject, pagOutputStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function  pagOutputStruct = pag_generate_output_time_series(pagScienceObject, pagOutputStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This function calculates the time series metrics of theoreticalCompressionEfficiency
% and achievedCompressionEfficiency of the full focal plane, which are stored in
% outputTsData struct of pagOutputStruct.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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

nCadences = length(pagScienceObject.cadenceTimes.midTimestamps);

theoreticalCeArray = [pagScienceObject.inputTsData.theoreticalCompressionEfficiency];
achievedCeArray    = [pagScienceObject.inputTsData.achievedCompressionEfficiency];

pagOutputStruct.outputTsData.theoreticalCompressionEfficiency = calculate_weighted_average(theoreticalCeArray, nCadences);
pagOutputStruct.outputTsData.achievedCompressionEfficiency    = calculate_weighted_average(achievedCeArray,    nCadences);

return


function averageTs = calculate_weighted_average(metricTsArray, nCadences)

% Convert data in float/logical arraies of a struc array to matrices
valuesMatrix        = [metricTsArray.values];
gapIndicatorsMatrix = [metricTsArray.gapIndicators];
nCodeSymbolsMatrix  = [metricTsArray.nCodeSymbols];

% Initialize the output structure
averageTs.values        = -1*ones(nCadences, 1);
averageTs.gapIndicators = true(nCadences, 1);

% Loop of all long cadences
for iCadence=1:nCadences
    
    % Only process the data whose gap indicators are false
    index = find(gapIndicatorsMatrix(iCadence, :)==false);
    if ( ~isempty(index) )
        
        % number of code symbols for each module/output is used as weights in weighted averaging
        nCodeSymbols   = nCodeSymbolsMatrix(iCadence, index);
        nCodeSymbols   = nCodeSymbols(:);
        sumCodeSymbols = sum(nCodeSymbols);

        if ( sumCodeSymbols~=0 )

            % Retrieve the valid data
            validValues = valuesMatrix(iCadence, index);
            validValues = validValues(:);

            % Calculate the weighted average of valid data and set gap indicator to false
            averageTs.values(iCadence)        = nCodeSymbols'*validValues/sumCodeSymbols;
            averageTs.gapIndicators(iCadence) = false;

        end

    end

end

return