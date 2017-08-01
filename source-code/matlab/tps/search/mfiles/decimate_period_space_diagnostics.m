function [decimatedMeanMesEstimate, decimatedValidPhaseSpaceFraction, ...
    decimatedPeriodsInCadences] = decimate_period_space_diagnostics( ...
    meanMesEstimate, validPhaseSpaceFraction, possiblePeriodsInCadences, ...
    nCadences, decimationFactor )
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function decimate_period_space_diagnostics( meanMesEstimate, validPhaseSpaceFraction, ...
%    tpsModuleParameters, tpsResults )
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Description:
% This function defines and gathers all the information that needs added to
% the dawg struct. It can pull any info from both the targetStruct and the
% tps results struct.
%
% Inputs: 
%         meanMesEstimate - the vector of mesEstimates averaged over phase
%             for each period
%         validPhaseSpaceFraction - the vector of fraction of valid phase
%             space for each period
%         possiblePeriodsInCadences - the search periods in superRes
%         nCadences - The length of the original flux
%         decimationFactor - self explanatory
%
% Outputs: 
%         decimatedMeanMesEstimate - decimated meanMesEstimate vector
%         decimatedValidPhaseSpaceFraction - decimated validPhaseSpaceFrac
%         decimatedPeriodsInCadences - decimated possiblerPeriodsInCadences
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

% if the length of the input vectors is less than half nCadences then dont
% worry about decimating
if ( length(meanMesEstimate) < 0.5 * nCadences  || decimationFactor <= 1)
    decimatedMeanMesEstimate = meanMesEstimate;
    decimatedValidPhaseSpaceFraction = validPhaseSpaceFraction;
    decimatedPeriodsInCadences = possiblePeriodsInCadences;
    return;
end

% check lengths are the same
if ~isequal( length(meanMesEstimate), length(validPhaseSpaceFraction), ...
        length(possiblePeriodsInCadences) )
    error('tps:decimatePeriodSpaceDiagnostics:vectorLengthsNotEqual', ...
        'Input vectors have different lenght!');
end

% Just sample period uniformly
periodSamples = linspace( min(possiblePeriodsInCadences), ...
    max(possiblePeriodsInCadences), round(length(possiblePeriodsInCadences) / ...
    decimationFactor) );
periodSamples = periodSamples(:);

% find the indices of the nearest periods
periodIndices = knnsearch( possiblePeriodsInCadences, periodSamples );
periodIndices = unique(periodIndices);

% decimate
decimatedMeanMesEstimate = meanMesEstimate( periodIndices );
decimatedValidPhaseSpaceFraction = validPhaseSpaceFraction( periodIndices );
decimatedPeriodsInCadences = possiblePeriodsInCadences( periodIndices );

return