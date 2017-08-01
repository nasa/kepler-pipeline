function [deemphasisWeightSuperResolution, deemphasisWeight, deemphasisParameter] = ...
    initialize_deemphasis_weights( tpsTarget, deemphasisParameter, tpsModuleParameters, ...
    gapFillParameters, positiveOutlierIndices, dropoutIndices, zeroCrossingIndices )
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% initialize_deemphasis_weights( tpsTarget, tpsModuleParameters,
% dropoutIndices, zeroCrossingIndices)
%
% Function to iniitialize the deemphasisWeights using whatever is available
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

% get needed inputs
superResolutionFactor = tpsModuleParameters.superResolutionFactor;
gapIndices = tpsTarget.gapIndices;
fillIndices = tpsTarget.fillIndices;
outlierIndices = tpsTarget.outlierIndices;
discontinuityIndices = tpsTarget.discontinuityIndices;
deemphasizedPeriodAfterTweakInCadences = tpsModuleParameters.deemphasizePeriodAfterTweakInCadences ;

cadencesPerDay = tpsModuleParameters.cadencesPerDay;
deemphasisPeriodInDays = tpsModuleParameters.deemphasizePeriodAfterSafeModeInDays;
longGapDeemphasisPeriodInCadences = round( cadencesPerDay * deemphasisPeriodInDays ) ;

% make sure these are column vectors
positiveOutlierIndices = positiveOutlierIndices(:);
dropoutIndices = dropoutIndices(:);
zeroCrossingIndices = zeroCrossingIndices(:);

% collect the deemphasized cadences
allFilledIndices = [gapIndices; fillIndices; outlierIndices; positiveOutlierIndices; ...
    zeroCrossingIndices; dropoutIndices];

[deemphasisParameterSuperResolution, deemphasisParameter] = collect_cadences_to_deemphasize( ...
    deemphasisParameter, superResolutionFactor, unique(allFilledIndices), ...
    discontinuityIndices, deemphasizedPeriodAfterTweakInCadences);

[deemphasisParameterSuperResolution, deemphasisParameter] = ...
    update_deemphasis_parameter_for_long_gaps( deemphasisParameter, ...
    longGapDeemphasisPeriodInCadences, gapFillParameters, superResolutionFactor );

% convert from deemphasis parameter to cadence weight, and store same  
deemphasisWeightSuperResolution = convert_deemphasis_parameter_to_weight( deemphasisParameterSuperResolution ) ;
deemphasisWeight = convert_deemphasis_parameter_to_weight( deemphasisParameter ) ; 

return

