function [bartModel, bartDiagnostics] = bart_linear_fitter( pixelData, temperature, T0 )
%
% bart_linear_fitter -- perform robust linear fit of pixel response to temperature
%
% [bartModel, bartDiagnostics] = bart_linear_fitter( pixelData, temperature, T0 ) performs
%    a linear fit of pixel response to temperature for the pixel data in ffiData.  Inputs
%    are structured as follows:
%
%    pixelData(nImages,nRows,nCols) -- data values in DN/read.
%
%    temperature:  nImages vector of temperatures in degrees Centigrade.
%
%    T0:  reference temperature of the fit in degrees Centigrade.
%
% The pixel data is fitted to a model which is linear in temperature, ie, 
%
%   pixelData(iImage,iRow,iCol) = c1(iRow,iCol) * (temperature(iImage)-T0)
%                               + c0(iRow,iCol).
%
% Outputs are structured as follows:
%
%    bartModel:  struct with fields
%       T0:  reference temperature of the fit in degrees Centigrade.
%       modelCoefficients(2,nRow,nCol) -- fit coefficients for the image pixels.  
%          modelCoefficients(1,:,:) -- temp-linear component of fit in DN/read/degC.
%          modelCoefficients(2,:,:) -- DC component of fit in DN/read.
%       covarianceMatrix(3,nRow,nCol) -- covariance of the fit for the image pixels.
%          covarianceMatrix(1,:,:) -- linear component of covariance in (DN/read/degc)^2.
%          covarianceMatrix(2,:,:) -- cross-term of covariance in (DN/read)^2/degC.
%          covarianceMatrix(3,:,:) -- DC component of covariance in (DN/read)^2.
%
%    bartDiagnostics:  struct with fields
%       fitResiduals(nImages,nRow,nCol) -- fit residuals
%       fitWeights(nImages,nRow,nCol) -- weights assigned by robust fitter
%       weightedRmsResiduals(nRow,nCol) -- RMS residuals, weighted according to fit
%                                          weights
%       weightSum(nRow,nCol) -- sum of weights assigned to each pixel's data.
%
% Version date:  2009-January-30.
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
%    2009-January-30, PT:
%        add waitbar.
%    2009-January-27, PT:
%        when breaking up big patterns, only break up the ones which are "good" (ie,
%        pixels have > 1 good value).
%
%=========================================================================================

% If we attempt to fit too many pixels at one time, Matlab starts demanding virtual memory
% and performance craters.  To prevent this, we will establish a maximum allowed number of
% pixels per chunk, and break up chunks (patterns) which have too many pixels in them.
% The maximum number of pixels per chunk is:

  maxPixelsPerChunk = 4.0e05 ; % ie, about 1/3 of a mod/out worth of pixels

% extract relevant dimensions from structures

  nImages = size(pixelData,1) ; 
  nRows   = size(pixelData,2) ;
  nCols   = size(pixelData,3) ;
  nPixels = nRows * nCols ;
  
% organize pixel data into a 2-D array, with nImages rows and nRow x nCol columns

  pixelDataAllFfi = reshape(pixelData,nImages,nPixels) ;
  
% convert the temperatures to temperature offsets by subtracting T0.  While we're at it,
% make sure that temperature is a column vector, which is what the fitter requires.

  temperature = temperature(:) - T0 ;
  
% find missing temperatures (these are filled with NaNs), and replace the corresponding
% pixels with gap markers so that the image is not used in the fit at all.

  missingTempIndex = find(isnan(temperature)) ;
  pixelDataAllFfi(missingTempIndex,:) = -1 ;
  
% find all of the good data in pixelData -- here we assume that bad data was set to -1 in
% the original FFIs, so it should still be < 0 now (if the actual bad data indicator
% changes during design, this code block must change).

  goodData = (pixelDataAllFfi > 0) ;
  
% find all of the patterns of good vs bad data in the goodData matrix, and identify each
% pixel's pattern

  [goodPixelPattern,indxNotNeeded,goodPixelPatternIndex] = unique(goodData','rows') ;
  goodPixelPattern = goodPixelPattern' ;
  nPatterns = size(goodPixelPattern,2) ;
  
% identify patterns that correspond to un-fittable pixels (0 or 1 good data points); mark
% the pixels with those patterns as goodPixelPatternIndex == 0 so that they never get
% fitted

  nPoints = sum(goodPixelPattern) ;
  badPatterns = find(nPoints < 2) ;
  pointsWithBadPatterns = find(ismember(goodPixelPatternIndex,badPatterns)==1) ;
  goodPixelPatternIndex(pointsWithBadPatterns) = 0 ;
  
% break up any patterns which contain more pixels than the max chunk size

  patternsTooBig = true ; % so we go through the loop at least once
  while patternsTooBig
      
      [biggestPattern,mostPixels] = ...
          mode( goodPixelPatternIndex(find(goodPixelPatternIndex~=0)) ) ;
      if (mostPixels > maxPixelsPerChunk)
          
          pixelIndexThisPattern = find(goodPixelPatternIndex == biggestPattern) ;
          nChunks = ceil(mostPixels / maxPixelsPerChunk) ;
          
%         loop over the new chunks -- note that we can leave some of the pixels which are
%         in the pattern in their original pattern, and only have to move some of them to
%         the new pattern
          
          for iChunk = 2:nChunks
              
%             add a new pattern onto the end of the patterns array, which duplicates the
%             one we are splitting up
              
              iPattern = nPatterns+iChunk-1 ;
              goodPixelPattern(:,iPattern) = goodPixelPattern(:,biggestPattern) ;
              
%             find the pixels which go into the new pattern and change their assigned
%             pattern in the goodPixelPatternIndex
              
              newPatternStart = floor(mostPixels * (iChunk-1)/nChunks) + 1 ;
              newPatternEnd   = floor(mostPixels * iChunk/nChunks) ;
              pixelsInNewPattern = pixelIndexThisPattern(newPatternStart:newPatternEnd) ;
              goodPixelPatternIndex(pixelsInNewPattern) = iPattern ;
              
          end
          
%         increment the number of patterns 
          
          nPatterns = nPatterns + nChunks - 1 ;
          
      else % in this case, no excessively-popular patterns, so set exit criterion
          
          patternsTooBig = false ;
          
      end
      
  end % while statement on patternsTooBig
          
  disp(['bart_linear_fitter:  total number of patterns: ',num2str(nPatterns)]) ;
  disp(['bart_linear_fitter:  total number of bad patterns:  ',...
      num2str(length(badPatterns))]) ;
  disp(['bart_linear_fitter:  total number of bad pixels:  ',...
      num2str(length(pointsWithBadPatterns))]) ;
  
% dimension arrays to catch the results; default the model coefficients and covariance
% matrix to NaN, so that any which are not filled default to NaN (easier than going
% through afterwards and trying to figure out which values were not set).  Similarly,
% default the fit residuals and weighted RMS residuals to NaN.

  modelCoefficients = nan(2,nPixels) ;
  covarianceMatrix = nan(3,nPixels) ;
  fitWeights = zeros(nImages,nPixels) ;
  fitResiduals = nan(nImages,nPixels) ;
  weightedRmsResiduals = nan(1,nPixels) ;
  weightSum = zeros(1,nPixels) ;
  
%=========================================================================================
%
% F I T T E R
%
%=========================================================================================

% display the waitbar

  waitbarHandle = waitbar(0) ;

% loop over the patterns which have enough data in them for fitting

  for iPattern = 1:nPatterns
      
      waitbar(iPattern/nPatterns,waitbarHandle, ...
          ['fitter:  on pattern ',num2str(iPattern),' of ',num2str(nPatterns)]) ;
      
%     find the pixels and temperatures corresponding to this pattern

      pixelIndexThisPattern = find(goodPixelPatternIndex == iPattern) ;
      goodImages = find(goodPixelPattern(:,iPattern) == 1) ;
      tempsThisPattern = temperature( goodImages ) ;
      nTempsThisPattern = length(tempsThisPattern) ;
      
%     Perform the vectorized fit if there are enough good temperatures (ie, if this is not
%     a bad pattern) 

      if (nTempsThisPattern > 1)

          [polyCoeffs, statStruct] = parallel_robust_linear_fit( tempsThisPattern, ...
              pixelDataAllFfi(goodImages,pixelIndexThisPattern), 0 ) ;
%          bar(statStruct.iterconv) ;
      
%         extract the coefficients, weights, and covariances from the return into the results

          modelCoefficients(1,pixelIndexThisPattern) = polyCoeffs(1,:) ;
          modelCoefficients(2,pixelIndexThisPattern) = polyCoeffs(2,:) ;
          fitWeights(goodImages,pixelIndexThisPattern) = statStruct.w ;
          covarianceMatrix(1,pixelIndexThisPattern) = statStruct.covb(1,1,:) ;
          covarianceMatrix(2,pixelIndexThisPattern) = statStruct.covb(1,2,:) ;
          covarianceMatrix(3,pixelIndexThisPattern) = statStruct.covb(2,2,:) ;
      
%         extract the fit residuals

          fitResiduals(goodImages,pixelIndexThisPattern) = statStruct.resid ;
      
%         compute weighted residuals and take their RMS 
      
          weightedRmsResiduals(pixelIndexThisPattern) = ...
              std(statStruct.w.*statStruct.resid,1) ;
      
%         compute weight sum

          weightSum(pixelIndexThisPattern) = sum(statStruct.w,1) ;

          clear weights covariances polyCoeffs 
          clear pixelIndexThisPattern nPixelsThisPattern goodImages 
          clear tempsThisPattern nTempsThisPattern 
      
      end % conditional on sufficient good temps this pattern
      
  end % loop over patterns
  
  close(waitbarHandle) ;
  
%=========================================================================================
%
% C O N S T R U C T   O U T P U T S
%
%=========================================================================================

% put the relevant fields into the relevant structures, and reshape them

  bartModel.T0                = T0 ;
  bartModel.modelCoefficients = reshape(modelCoefficients,[2 nRows nCols]) ;
  bartModel.covarianceMatrix  = reshape(covarianceMatrix,[3 nRows nCols]) ;
  
  bartDiagnostics.fitResiduals         = reshape(fitResiduals,[nImages nRows nCols]) ;
  bartDiagnostics.fitWeights           = reshape(fitWeights,[nImages nRows nCols]) ;
  bartDiagnostics.weightedRmsResiduals = reshape(weightedRmsResiduals,[nRows nCols]) ;
  bartDiagnostics.weightSum            = reshape(weightSum,[nRows nCols]) ;
  
return

% and that's it!

%
%
%
