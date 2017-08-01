function self = test_fold_periods( self )
%
% test_fold_periods -- unit test of fold_periods mexfile function
%
% This unit test exercises the following functionality of the fold_periods mexfile:
%
% ==> Given a known input, the mexfile produces the expected folded outputs, including the
%     expected maximum and minimum values and phase lags for each
% ==> If a region of the correlation and normalization vector are each set to zero, the
%     folder correctly ignores those values in constructing the folded multiple event
%     statistics.
%
% This unit test is intended for use in an mlunit context.  For standalone execution, use
% the following syntax:
%
% This test is intended to operate in the mlunit context.  For standalone execution, use
% the following syntax:
%
%      run(text_test_runner, testTpsClass('test_fold_periods'));
%
% Version date:  2010-October-21.
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
%   2010-October-21, PT:
%       in 2010b, the message from fold_periods has the string 'Error using ==> 
%       fold_periods' prepended to the error message thrown by the mexfile.  As a result,
%       the assert_equals on the error message is changed to an mlunit_assert looking at
%       whether the index of a strfind on the original message text is empty or not.
%
%=========================================================================================

  disp(' ... testing fold_periods mexfile function ... ') ;

% First step is to construct the correlation and normalization time series.  For
% fold_periods, the normalization time series is actually the square of the time series
% which is produced by the CDPP calculator.  In the interest of simplicity, we'll use a
% normalization time series which represents a uniform 20 PPM CDPP

  normalizationTimeSeries = 1/20e-6 * ones(4400,1) ;

% in the first test, we'll use a correlation time series which is all zeros except where
% our expected nonzero values are
  
  correlationTimeSeries = zeros(4400,1) ;
  
% Now we want positive triangular events at the places where the transit occurred, and
% negative ones where any microlensing occurs.  The triangle should be 13 cadences wide.

  unitTriangle = [(1/7):(1/7):1 (6/7):(-1/7):(1/7)] ; unitTriangle = unitTriangle(:) ;
  
  correlationTimeSeries(494:506) = correlationTimeSeries(494:506) + 4*50000*unitTriangle ;
  correlationTimeSeries(1494:1506) = correlationTimeSeries(1494:1506) + 4*50000*unitTriangle ;
  correlationTimeSeries(2494:2506) = correlationTimeSeries(2494:2506) + 4*50000*unitTriangle ;
  correlationTimeSeries(3494:3506) = correlationTimeSeries(3494:3506) + 4*50000*unitTriangle ;
  
  correlationTimeSeries(694:706) = correlationTimeSeries(694:706) - 5 * 50000 * unitTriangle ;
  correlationTimeSeries(2694:2706) = correlationTimeSeries(2694:2706) - 5 * 50000 * unitTriangle ;
  
  
% possible periods can go from 49 cadences, which is 1 day in Kepler units, to the full
% length of the time series

  possiblePeriodsInCadences = 49:4400 ; 
  possiblePeriodsInCadences = possiblePeriodsInCadences(:) ;
  nPeriods = length(possiblePeriodsInCadences) ;
  
% let the lag step be 1 cadence

  deltaLagInCadences = 1 ;
  minSesCount = 2 ;
  
% do the call

  [maxStatistic, minStatistic, phaseLagMax, phaseLagMin] = fold_periods( ...
      possiblePeriodsInCadences, correlationTimeSeries, ...
      normalizationTimeSeries, deltaLagInCadences, minSesCount ) ;
  
% start with a basic check of the dimensions of the returned vectors

  mlunit_assert( isvector( maxStatistic ) && isvector( minStatistic ) && ...
      isvector( phaseLagMax ) && isvector( phaseLagMin ) && ...
      length( maxStatistic ) == nPeriods && length( minStatistic ) == nPeriods && ...
      length( phaseLagMax ) == nPeriods && length( phaseLagMin ) == nPeriods, ...
      'Return args from fold_periods have incorrect dimensions!' )
  
% There should be a peak at 8, 3 peaks at 8 / sqrt(2), and 1 peak at 8 / sqrt(3):  make
% sure that all of them appeared and that they were at the expected locations

  [maxValue, maxIndex] = max(maxStatistic) ;
  mlunit_assert( abs( maxValue - 8 ) < 1e-6, ...
      'maxStatistic value incorrect in simple folding test!' ) ;
  assert_equals( maxIndex, 952, ...
      'maxStatistic index incorrect in simple folding test!' ) ;
  
  twoTransitLocations = find( abs(maxStatistic - 8/sqrt(2)) < 1e-6 ) ;
  assert_equals( twoTransitLocations(:), [452 ; 1952 ; 2952], ...
      'Secondary peak locations incorrect in simple folding test!' ) ;

  overfoldingLocation = find( abs(maxStatistic - 8/sqrt(3)) < 1e-6 ) ;
  assert_equals( overfoldingLocation, 1452, ...
      'Overfolded peak location incorrect in simple folding test!' ) ;
  
% Now look at the lags estimated by the folding; note that the lags are true lags, so a
% lag of 0 means that cadence 1 is the first one in the peak (ie, the lag is off by 1 wrt
% the cadences in any given peak)

  peakLags = phaseLagMax([maxIndex ; twoTransitLocations ; overfoldingLocation]) ;
  peakLags = [peakLags] ;
  mlunit_assert( all( peakLags == 499 ), ...
      'Peak lags not as expected in simple folding test!' ) ;
  
% Now look at the minima of the folding process:  there should be a peak at a folding of
% 2000 cadences and another at a folding of 1000 cadences (which folds the 2 troughs onto
% each other and also folds 2 empty cadences on top of them)

  [minValue, minIndex] = min(minStatistic) ;
  mlunit_assert( abs( minValue + 10/sqrt(2) ) < 1e-6, ...
      'minStatistic value incorrect in simple folding test!' ) ;
  assert_equals( minIndex, 1952, ...
      'minStatistic index incorrect in simple folding test!' ) ;
  
  overfoldingLocation = find( abs(minStatistic + 5) < 1e-6, 1, 'first' ) ;
  assert_equals( overfoldingLocation, 952, ...
      'Overfolded trough location incorrect in simple folding test!' ) ;
  
  troughLags = phaseLagMin( [minIndex ; overfoldingLocation] ) ;
  mlunit_assert( all( troughLags == 699 ), ...
      'Trough lags not as expected in simple folding test!' ) ;
  
% Reduce the first peak to 1% of its current height and see whether the calculation
% proceeds correctly.  Amongst other things, this test determines whether the combination
% of the single event statistics is done as simple quadrature (wrong) or detection
% statistics quadrature (right).

  correlationTimeSeries(494:506) = correlationTimeSeries(494:506) * 0.01 ;
  [maxStatistic, minStatistic, phaseLagMax, phaseLagMin] = fold_periods( ...
      possiblePeriodsInCadences, correlationTimeSeries, ...
      normalizationTimeSeries, deltaLagInCadences, minSesCount ) ;

  [maxValue,maxIndex] = max( maxStatistic ) ;
  mlunit_assert( abs( maxValue - 6.02 ) < 1e-6, ...
      'Max MES not as expected for reduced-peak test!' ) ;
  assert_equals( maxIndex, 952, ...
      'Location of max MES not as expected for reduced-peak test!' ) ;

  assert_equals( phaseLagMax(maxIndex), 499, ...
      'Phase lag of max MES not as expected for reduced-peak test!' ) ;
  
% Replace the region around the first peak with zeros in both correlation and
% normalization time series.  This should cause the folder to treat those cadences as
% gapped and construct the maximum using just the ungapped peaks.  The lag is still
% recorded as being at the gapped location.
  
  correlationTimeSeries(490:510) = 0 ;
  normalizationTimeSeries(490:510) = 0 ;
  
  [maxStatistic, minStatistic, phaseLagMax, phaseLagMin] = fold_periods( ...
      possiblePeriodsInCadences, correlationTimeSeries, ...
      normalizationTimeSeries, deltaLagInCadences, minSesCount ) ;

  [maxValue,maxIndex] = max( maxStatistic ) ;
  mlunit_assert( abs( maxValue - 12/sqrt(3) ) < 1e-6, ...
      'Max MES not as expected for gapped-peak test!' ) ;
  assert_equals( maxIndex, 952, ...
      'Location of max MES not as expected for gapped-peak test!' ) ;

  assert_equals( phaseLagMax(maxIndex), 499, ...
      'Phase lag of max MES not as expected for gapped-peak test!' ) ;
  
% test for the error-throws which are required

  p1 = [] ; p2 = [] ; p3 = [] ; p4 = [] ; p5 = [] ;
  lasterror('reset') ;
  try
      caughtInputsError = false ;
      [o1,o2,o3,o4] = fold_periods(p1,p2,p3,p4) ;
  catch
      lastError = lasterror ;
      mlunit_assert( ~isempty( strfind( lastError.message, 'Five inputs required.' ) ), ...
          'Wrong type of error thrown!' ) ;
      caughtInputsError = true ;
  end
  if ~caughtInputsError
      mlunit_assert( false, 'Failed to catch error condition on inputs!' ) ;
  end
  lasterror('reset') ;
  try
      caughtInputsError = false ;
      [o1,o2,o3] = fold_periods(p1,p2,p3,p4,p5) ;
  catch
      lastError = lasterror ;
      mlunit_assert( ~isempty( strfind( lastError.message, 'Four outputs required.' ) ), ...
          'Wrong type of error thrown!' ) ;
      caughtOutputsError = true ;
  end
  if ~caughtOutputsError
      mlunit_assert( false, 'Failed to catch error condition on outputs!' ) ;
  end
    
  disp('') ;
return  