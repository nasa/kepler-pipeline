% remove_first_n_cadences_from_pdq_inputs.m
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

% inputsStruct =
%       pipelineInstanceId: 110
%         pdqConfiguration: [1x1 struct]
%              fcConstants: [1x1 struct]
%               configMaps: [1x4 struct]
%             cadenceTimes: [9x1 double]
%                gainModel: [1x1 struct]
%           readNoiseModel: [1x1 struct]
%           raDec2PixModel: [1x1 struct]
%          undershootModel: [1x1 struct]
%        prfModelFilenames: {1x84 cell}
%          twoDBlackModels: [1x84 struct]
%          flatFieldModels: [1x84 struct]
%            requantTables: [1x1 struct]
%           inputPdqTsData: [1x1 struct]
%        stellarPdqTargets: [1x318 struct]
%     backgroundPdqTargets: [1x84 struct]
%     collateralPdqTargets: [1x1260 struct]
% inputsStruct.cadenceTimes
% ans =
%           55001.2512154873
%           55002.0276921977
%              55002.2728953
%           55003.2537080069
%           55004.2345207204
%           55005.2153333798
%           55006.1961459919
%           55007.1769586513
%           55008.1577713649
% inputsStruct.stellarPdqTargets(1)
% ans =
%                  ccdModule: 2
%                  ccdOutput: 1
%                     labels: {'PDQ_STELLAR'}
%            referencePixels: [1x110 struct]
%                   keplerId: 3233908
%                    raHours: 19.4099753
%                 decDegrees: 38.38802
%                  keplerMag: 11.8420000076294
%     fluxFractionInAperture: 0.963857455867073
% inputsStruct.stellarPdqTargets(1).referencePixels(1)
% ans =
%                     row: 736
%                  column: 965
%     isInOptimalAperture: 0
%              timeSeries: [9x1 double]
%           gapIndicators: [9x1 logical]

 function pdqInputStruct = remove_first_n_cadences_from_pdq_inputs(inputsStruct, cadencesToRemove)
 
 % removes the specified cadences from pdq inputs
 % assumes no history of metrics


nStars = length(inputsStruct.stellarPdqTargets);

for jStar = 1:nStars

    nReferencePixels = length(inputsStruct.stellarPdqTargets(jStar).referencePixels);

    for kPixel = 1:nReferencePixels


        inputsStruct.stellarPdqTargets(jStar).referencePixels(kPixel).timeSeries(cadencesToRemove) = [];

        inputsStruct.stellarPdqTargets(jStar).referencePixels(kPixel).gapIndicators(cadencesToRemove) = [];

    end



end


nBkgdStars = length(inputsStruct.backgroundPdqTargets);

for jStar = 1:nBkgdStars

    nReferencePixels = length(inputsStruct.backgroundPdqTargets(jStar).referencePixels);

    for kPixel = 1:nReferencePixels


        inputsStruct.backgroundPdqTargets(jStar).referencePixels(kPixel).timeSeries(cadencesToRemove) = [];

        inputsStruct.backgroundPdqTargets(jStar).referencePixels(kPixel).gapIndicators(cadencesToRemove) = [];

    end



end


nCollTargets = length(inputsStruct.collateralPdqTargets);

for jStar = 1:nCollTargets

    nReferencePixels = length(inputsStruct.collateralPdqTargets(jStar).referencePixels);

    for kPixel = 1:nReferencePixels


        inputsStruct.collateralPdqTargets(jStar).referencePixels(kPixel).timeSeries(cadencesToRemove) = [];

        inputsStruct.collateralPdqTargets(jStar).referencePixels(kPixel).gapIndicators(cadencesToRemove) = [];

    end



end


inputsStruct.cadenceTimes(cadencesToRemove) = [];
pdqInputStruct = inputsStruct;



