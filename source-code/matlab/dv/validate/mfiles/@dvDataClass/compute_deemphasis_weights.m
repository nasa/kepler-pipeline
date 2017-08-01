function deemphasisWeights = compute_deemphasis_weights(dvDataObject, whitenedFluxTimeSeries, outlierIndices, discontinuityIndices)
%
% compute_deemphasis_weights -- compute deemphasis weights from indicators of safe mode, earth pointing and attitude tweak. 
%
% Version date:  2013-April-04.
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
%
%    2013-April-04, JL:
%       Initial release.
%
%=========================================================================================

% Set default output

cadenceTimeStamps = dvDataObject.dvCadenceTimes.midTimestamps;
nCadences         = length(cadenceTimeStamps);
deemphasisWeights = ones(nCadences, 1);

% Retrieve deemphasis period after safe mode and attitude tweak

deemphasizePeriodAfterSafeModeInDays     = dvDataObject.tpsConfigurationStruct.deemphasizePeriodAfterSafeModeInDays;
cadencesPerDay                           = 1/median(diff(cadenceTimeStamps));
deemphasizePeriodAfterSafeModeInCadences = round( cadencesPerDay * deemphasizePeriodAfterSafeModeInDays );
deemphasizePeriodAfterTweakInCadences    = dvDataObject.tpsConfigurationStruct.deemphasizePeriodAfterTweakInCadences;
    
% Retrieve indaicators of safe mode, earth point and attitude tweak
    
dataAnomalyIndicators   = dvDataObject.dvCadenceTimes.dataAnomalyFlags;
safeModeIndicators      = dataAnomalyIndicators.safeModeIndicators;
earthPointIndicators    = dataAnomalyIndicators.earthPointIndicators;
attitudeTweakIndicators = dataAnomalyIndicators.attitudeTweakIndicators ;
    
% Set deemphasis parameter for safe mode, earth pointing and attitude tweak by calling the TPS method

deemphasisParameterSafeMode      = set_deemphasis_parameter( find_datagap_locations( safeModeIndicators ),      deemphasizePeriodAfterSafeModeInCadences, nCadences );
deemphasisParameterEarthPoint    = set_deemphasis_parameter( find_datagap_locations( earthPointIndicators ),    deemphasizePeriodAfterSafeModeInCadences, nCadences );
deemphasisParameterAttitudeTweak = set_deemphasis_parameter( find_datagap_locations( attitudeTweakIndicators ), deemphasizePeriodAfterTweakInCadences,    nCadences );

% Determine deemphasis parameter

deemphasisParameter = min( [deemphasisParameterAttitudeTweak deemphasisParameterEarthPoint deemphasisParameterSafeMode ], [],  2 );

% Add gappedIndices, filledIndices, outlierIndices, discontinuityIndices in deemphasis parameter

gappedIndices = find(whitenedFluxTimeSeries.gapIndicators);
filledIndices = whitenedFluxTimeSeries.filledIndices;
[~, deemphasisParameter] = collect_cadences_to_deemphasize(deemphasisParameter, 1, [ gappedIndices(:); filledIndices(:); outlierIndices(:) ], ...
    discontinuityIndices, deemphasizePeriodAfterTweakInCadences) ;

% Compute deemphasis weights from the deemphasis parameter

deemphasisWeights   = convert_deemphasis_parameter_to_weight(deemphasisParameter);
deemphasisWeights   = deemphasisWeights(:);

