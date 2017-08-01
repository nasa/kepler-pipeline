function newPlanetResults = dv_dawg_kernel( outputsStruct )
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
  planetCandidate = [planetResultsStruct.planetCandidate] ;

  allTransitsFit = [planetResultsStruct.allTransitsFit] ;
  chisq = [allTransitsFit.modelChiSquare] ;
  nFits = length( find( chisq > 0 ) ) ;
  allTransitsFit = allTransitsFit(chisq>0) ;
  if (nFits > 0)
      modelParameters = [allTransitsFit.modelParameters] ;
      modelParameters = reshape(modelParameters,12,nFits) ;
      value = reshape([modelParameters.value],size(modelParameters)) ;
      sigma = reshape([modelParameters.uncertainty],size(modelParameters)) ;
      radiusRatio = value(4,:) ./ value(7,:) ;
      transitDepthSigmas = value(10,:) ./ sigma(10,:) ;
      transitDepth = value(10,:) ;
  else
      transitDepth = [] ;
      radiusRatio = [] ;
      transitDepthSigmas = [] ;
  end
  goodFitsIndices = find( chisq > 0 ) ;  

  centroidResults = [planetResultsStruct.centroidResults] ;
  prfCentroid = [centroidResults.prfMotionResults] ;
  prfCentroid = [prfCentroid.motionDetectionStatistic] ;
  prfSignificance = [prfCentroid.significance] ;
  fluxCentroid = [centroidResults.fluxWeightedMotionResults] ;
  fluxCentroid = [fluxCentroid.motionDetectionStatistic] ;
  fluxSignificance = [fluxCentroid.significance] ;
  
  prfSignificance = prfSignificance( goodFitsIndices ) ;
  fluxSignificance = fluxSignificance( goodFitsIndices ) ;
  

  binaryDiscrimination = [planetResultsStruct.binaryDiscriminationResults] ;
  depthTest = [binaryDiscrimination.oddEvenTransitDepthComparisonStatistic] ;
  depthSignificance = [depthTest.significance] ;
  epochTest = [binaryDiscrimination.oddEvenTransitEpochComparisonStatistic] ;
  epochSignificance = [epochTest.significance] ;
  shorterPeriodTest = [binaryDiscrimination.shorterPeriodComparisonStatistic] ;
  shorterPeriodSignificance = [shorterPeriodTest.significance] ; 
  
  depthSignificance = depthSignificance( goodFitsIndices ) ;
  epochSignificance = epochSignificance( goodFitsIndices ) ;
  shorterPeriodSignificance = shorterPeriodSignificance( goodFitsIndices ) ;
  
  multipleEventStatistic = [planetCandidate.maxMultipleEventSigma] ;
  falseAlarmRate = [planetCandidate.significance] ;
  
  falseAlarmRate = falseAlarmRate( goodFitsIndices ) ;
  multipleEventStatistic = multipleEventStatistic( goodFitsIndices ) ;

% collect results and repackage as an ntuple

  resultsMatrix = [transitDepth(:) transitDepthSigmas(:) radiusRatio(:) ...
      prfSignificance(:) fluxSignificance(:) depthSignificance(:) epochSignificance(:) ...
      shorterPeriodSignificance(:) multipleEventStatistic(:) falseAlarmRate(:)] ;
  
  resultsCell = mat2cell( resultsMatrix, ...
      ones(size(resultsMatrix,1),1) , ones(size(resultsMatrix,2),1) ) ;
  newPlanetResults = cell2struct( resultsCell, ...
      {'transitDepth', 'transitDepthSigmas', 'radiusRatio', 'prfSignificance', ...
      'fluxSignificance', 'depthSignificance', 'epochSignificance', ...
      'periodSignificance', 'multipleEventStatistic', 'falseAlarmRate'}, 2 ) ;
  
  
return
