function newPlanetResults = dv_data_miner_kernel( outputsStruct, dirName, ...
    centroidSignificanceCutoff, transitDepthSignificanceCutoff, ...
    transitEpochSignificanceCutoff, orbitalPeriodSignificanceCutoff, ...
    transitDepthCutoffSigmas )
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

  planetResultsStruct = [outputsStruct.targetResultsStruct.planetResultsStruct] ;
  keplerIdTargetList = [outputsStruct.targetResultsStruct.keplerId] ;
  keplerIdPlanetList = [planetResultsStruct.keplerId] ;
  [tf,targetNumber] = ismember(keplerIdPlanetList, keplerIdTargetList) ;
  planetNumber = [planetResultsStruct.planetNumber] ;

  allTransitsFit = [planetResultsStruct.allTransitsFit] ;
  chisq = [allTransitsFit.modelChiSquare] ;
  nFits = length( find( chisq > 0 ) ) ;
  allTransitsFit = allTransitsFit(chisq>0) ;
  if (nFits > 0)
      modelParameters = [allTransitsFit.modelParameters] ;
      modelParameters = reshape(modelParameters,size(modelParameters,2)/nFits,nFits) ;
      value = reshape([modelParameters.value],size(modelParameters)) ;
      sigma = reshape([modelParameters.uncertainty],size(modelParameters)) ;
      radiusRatio = value(4,:) ./ value(7,:) ;
      transitDepthSigmas = value(10,:) ./ sigma(10,:) ;
  else
      radiusRatio = [] ;
      transitDepthSigmas = [] ;
  end
  radiusRatio2 = zeros(size(chisq)) ;
  radiusRatio2(chisq > 0) = radiusRatio ;
  radiusRatio = radiusRatio2 ;
  transitDepthSigmas2 = zeros(size(chisq)) ;
  transitDepthSigmas2(chisq > 0) = transitDepthSigmas ;
  transitDepthSigmas = transitDepthSigmas2 ;

  centroidResults = [planetResultsStruct.centroidResults] ;
  prfCentroid = [centroidResults.prfMotionResults] ;
  prfCentroid = [prfCentroid.motionDetectionStatistic] ;
  prfSignificance = [prfCentroid.significance] ;
  fluxCentroid = [centroidResults.fluxWeightedMotionResults] ;
  fluxCentroid = [fluxCentroid.motionDetectionStatistic] ;
  fluxSignificance = [fluxCentroid.significance] ;

  binaryDiscrimination = [planetResultsStruct.binaryDiscriminationResults] ;
  depthTest = [binaryDiscrimination.oddEvenTransitDepthComparisonStatistic] ;
  depthSignificance = [depthTest.significance] ;
  epochTest = [binaryDiscrimination.oddEvenTransitEpochComparisonStatistic] ;
  epochSignificance = [epochTest.significance] ;
  shorterPeriodTest = [binaryDiscrimination.shorterPeriodComparisonStatistic] ;
  shorterPeriodSignificance = [shorterPeriodTest.significance] ;
  longerPeriodTest = [binaryDiscrimination.longerPeriodComparisonStatistic] ;
  longerPeriodSignificance = [longerPeriodTest.significance] ;

% now for the tests:  note that the short and long period tests are not
% performed if there is only one planet candidate;  also, note that the PRF
% centroid test has to accept the case in which the PRF centroids weren't
% used due to absence.

  fitOk = (radiusRatio > 0) ;
  prfOk = (prfSignificance > centroidSignificanceCutoff) | ...
      (prfSignificance < 0) ;
  fluxOk = (fluxSignificance > centroidSignificanceCutoff) ;
  depthOk = (depthSignificance > transitDepthSignificanceCutoff) ;
  depthRatioOk = (transitDepthSigmas > transitDepthCutoffSigmas) ;
  epochOk = (epochSignificance > transitEpochSignificanceCutoff) ;
  shortOk = (shorterPeriodSignificance > orbitalPeriodSignificanceCutoff) | ...
      (shorterPeriodSignificance < 0) ;
  longOk  = (longerPeriodSignificance > orbitalPeriodSignificanceCutoff) | ...
      (longerPeriodSignificance < 0) ;

  allOk = fitOk & prfOk & fluxOk & depthOk & depthRatioOk & epochOk & shortOk & longOk ;

% collect results and repackage 
  
  target = targetNumber(allOk) ;
  planet = planetNumber(allOk) ;
  keplerId = keplerIdPlanetList(allOk) ;
  radiusRatio = radiusRatio(allOk) ;
  directory = { dirName } ; directory = repmat( directory, 1, length(radiusRatio) ) ;

  numericResults = [target(:)' ; planet(:)' ; keplerId(:)' ; radiusRatio(:)'] ;
  cellResults = mat2cell( numericResults, [1 1 1 1], ones(length(target),1)  ) ;
  cellResults = [directory ; cellResults] ;

  newPlanetResults = cell2struct( cellResults, ...
      {'directory', 'target', 'planet', 'keplerId', 'radiusRatio'}, 1 ) ;
      
return
