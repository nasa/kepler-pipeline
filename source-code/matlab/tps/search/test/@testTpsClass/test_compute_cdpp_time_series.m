function self = test_compute_cdpp_time_series( self )
%
% test_compute_cdpp_time_series -- unit test for tpsClass method compute_cdpp_time_series
%
% This unit test exercises the following functionality of the method:
%
% ==> The correlation, normalization, and CDPP time series are approximately correct in
%     the following cases for the desired trial transit pulse lengths
%     --> White noise
%     --> Pink noise (white noise + random walk)
%     --> Pink noise + phase-shifting harmonic
%     --> Pink noise + phase-shifting harmonic + small transit
% ==> The harmonic time series, detrended time series, and uncertainty time series are 
%     correctly returned in the TPS results
% ==> The size of the super-resolution time series is correct in all cases.
%
% This test is intended to operate in the mlunit context.  For standalone execution, use
% the following syntax:
%
%      run(text_test_runner, testTpsClass('test_compute_cdpp_time_series'));
%
% Version date:  2010-October-12.
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
%    2010-October-12, PT:
%        removing uncertainty time series from test (didn't need it after all).
%    2010-October-05, PT:
%        update to include test of uncertainty time series capture.
%    2010-October-01, PT:
%        update to match new signature of compute_cdpp_time_series -- harmonic time series
%        are now passed as arguments rather than computed internally.  Removed test cases
%        in which phase-shifting harmonics are used (since these are now taken out in a
%        quarterStitchingClass method rather than in compute_cdpp_time_series).  Change
%        values for pink noise calculation, since the full pre-conditioning of time series
%        is no longer performed in the cdpp method.
%    2010-July-15, PT:
%        update expected parameter ranges based on more detailed studies.
%
%=========================================================================================

  disp(' ... testing CDPP computation ... ') ;

  
% set the test data path and retrieve the tps-full struct for instantiation

  tpsDataFile = 'tps-full-struct-for-instantiation' ;
  tpsDataStructName = 'tpsInputStruct' ;
  tps_testing_initialization ;

% set the random number generator to the correct value

  s = RandStream('mcg16807','Seed',10) ;
  RandStream.setDefaultStream(s) ;

% construct the necessary flux time series

  timeSeriesLength = length( tpsInputStruct.cadenceTimes.startTimestamps ) ;
  
  [whiteNoise,randomWalk,harmonicSine,harmonicCosine,transit] = ...
      generate_tps_test_time_series( timeSeriesLength, harmonicPeriodCadences, ...
      finalPhaseShiftRadians, transitEpochCadence, transitPeriodCadences, ...
      transitDurationCadences ) ;
  
  tpsTargets = tpsInputStruct.tpsTargets ;
  tpsInputStruct.tpsModuleParameters.performQuarterStitching = true ;
  
  tpsTargets.fluxValue = 50e-6 * whiteNoise ;
  tpsTargets.fluxValue = tpsTargets.fluxValue - median(tpsTargets.fluxValue) ;
  tpsInputStruct.tpsTargets(1) = tpsTargets ;
  
  tpsTargets.fluxValue = 50e-6 * whiteNoise + 25e-6 * randomWalk ;
  tpsTargets.fluxValue = tpsTargets.fluxValue - median(tpsTargets.fluxValue) ;
  tpsInputStruct.tpsTargets(2) = tpsTargets ;
  
  tpsTargets.fluxValue = 50e-6 * whiteNoise + 25e-6 * randomWalk + ...
      200e-6 * transit ;
  tpsTargets.fluxValue = tpsTargets.fluxValue - median(tpsTargets.fluxValue) ;
  tpsInputStruct.tpsTargets(3) = tpsTargets ;
  
  nTargets = length( tpsInputStruct.tpsTargets ) ;
  nPulses = length(tpsInputStruct.tpsModuleParameters.requiredTrialTransitPulseInHours);
  
% validate the input struct to get the extra fields added in

  tpsInputStruct = validate_tps_input_structure( tpsInputStruct ) ;

% instantiate the object and put it through the CDPP computer

  tpsObject = tpsClass( tpsInputStruct ) ;
  
% do quarter stitching with performQuarterStitching flag set to false to 
% get needed fields but do not do the quarter stitching because it's effect
% on CDPP should be checked in a separate unit test
 
  [tpsObject, harmonicTimeSeries, fittedTrend] = perform_quarter_stitching( tpsObject ) ;

% do CDPP calculation

%  harmonicTimeSeries = randn( timeSeriesLength, nTargets ) ;
  [cdppResults, alerts] = compute_cdpp_time_series( tpsObject, harmonicTimeSeries, ...
      fittedTrend ) ;
  
% OK, for the first thing, the alerts should be empty

  mlunit_assert( isempty( alerts ), 'Alerts struct not empty!' ) ;
  
% next, reshape the cdppResults so that each target has a column of its own

  cdppResults = reshape( cdppResults, nTargets, nPulses ) ;
  cdppResults = cdppResults' ;
  
% Now we go column by column, and within that we loop by pulse lengths, checking the
% following parameters:
%
% ==> rmsCdpp value
% ==> median and MAD of CDPP time series
% ==> median and MAD of correlation and normalization time series
% ==> trial transit pulse value
% ==> presence or absence of harmonicTimeSeries and detrendedFluxTimeSeries arrays
% ==> dimensions of all arrays, including the high-resolution time series
% ==> Approximate values of single event statistics (max, min, mean)
%
% Unfortunately for code readability, doing this requires that we use a 3-dimensional cell
% array.  The array is nTargets x nPulseLengths x nParValues.  The par values we will
% have in the table are min and max values of each of:
%
%     rmsCdpp
%     median( cdpp time series ) 
%     mad( cdpp time series )
%     median( correlation time series )
%     mad( correlation time series )
%     median( normalization time series )
%     mad( normalization time series )
%     max single event statistic
%     min single event statistic
%     mean of single event statistics
%

  parValueExpected = cell(nPulses,nTargets,21) ;
  
% set the expected parameter values and tolerate a 1% deviation (r47979) 
% can use the script provided below to generate these limits

  parValueExpected(1,1,:) = ...
      { 'white-noise-3-hr', 19.0000, 20.0000, 19.0, 20.0, ...
 			 0.82, 0.86, -2700, -2200, ...
 			 35000, 40000, 51750, 52250, ...
 			 2200, 2300, 3.5, 4, ...
 			 -3.7, -3.4, -0.06, 0.06 } ;
  parValueExpected(2,1,:) = ...
      { 'white-noise-6-hr', 13.7, 14.0, 13.8, 14.2, ...
 			 0.35, 0.38, -6700, -6200, ...
 			 50000, 52500, 70000, 73000, ...
 			 1800,1900, 3, 3.5, ...
 			 -3.5, -3.4, -0.09, 0.09 } ;
  parValueExpected(3,1,:) = ...
      { 'white-noise-12-hr', 9.5, 9.8, 9.5, 9.9, ...
 			 0.16, 0.19, -14000, -13500, ...
 			 77000, 78000, 100000, 104000, ...
 			 1800,1900, 3.2, 3.7, ...
 			 -3.8, -3.4, -0.11, 0.11 } ;
  
  parValueExpected(1,2,:) = ...
      { 'pink-noise-3-hr', 36.5, 37.0, 36, 36.5, ...
 			 1.8, 2.2, 100, 150, ...
 			 18000, 18500, 27250, 27750, ...
 			 1400, 1500, 3.75, 4.25, ...
 			 -3.9, -3.8, -0.015, 0.015 } ;
  parValueExpected(2,2,:) = ...
      { 'pink-noise-6-hr', 36.0, 36.5, 35.8, 36.2, ...
 			 1.34, 1.38, -250, -200, ...
 			 18000, 18500, 27500, 28000, ...
 			 1000, 1100, 3.25, 3.75, ...
 			 -3.85, -3.7, -0.025, 0.025 } ;
  parValueExpected(3,2,:) = ...
      { 'pink-noise-12-hr', 35.2, 35.7, 35.6, 36.0, ...
 			 0.9, 0.95, 650, 700, ...
 			 18750, 19250, 27750, 28250, ...
 			 700, 750, 3.75, 4.25, ...
 			 -4.2, -3.8, -0.06, 0.06 } ;
    
  parValueExpected(1,3,:) = ...
      { 'small-transit-3-hr', 37.2, 37.7, 36.7, 37, ...
 			 2.5, 3, -170, -120, ...
 			 17750, 18250, 26750, 27250, ...
 			 1925, 1975, 5.4, 5.5, ...
 			 -3.9, -3.8, -0.02, 0.02 } ;
  parValueExpected(2,3,:) = ...
      { 'small-transit-6-hr', 36.5, 37.0, 36.3, 36.7, ...
 			 1.3, 1.7, -350, -300, ...
 			 18000, 18500, 27250, 27750, ...
 			 1100, 1150, 3.6, 3.7, ...
 			 -3.6, -3.4, -0.03, 0.03 } ;
  parValueExpected(3,3,:) = ...
      { 'small-transit-12-hr', 35.8, 36.2, 36.1, 36.5, ...
 			 0.9, 1.1, 600, 650, ...
 			 18750, 19250, 27250, 27750, ...
 			 725, 775, 4.0, 4.2, ...
 			 -4.1, -3.9, -0.05, 0.05 } ;
      
% Note that failure of these asserts can be due to the cdpp calculator, 
% the whitener, or the flux extension
        
  for iTarget = 1:nTargets
      
      for iTrial = 1:nPulses
                    
          mlunit_assert( ...
              cdppResults(iTrial,iTarget).rmsCdpp >= parValueExpected{iTrial,iTarget,2} && ...
              cdppResults(iTrial,iTarget).rmsCdpp <= parValueExpected{iTrial,iTarget,3} , ...
              [parValueExpected{iTrial,iTarget,1},' rmsCdpp value not as expected!'] ) ;
          mlunit_assert( ...
              median(cdppResults(iTrial,iTarget).cdppTimeSeries) >= ...
                 parValueExpected{iTrial,iTarget,4} && ...
              median(cdppResults(iTrial,iTarget).cdppTimeSeries) <= ...
                 parValueExpected{iTrial,iTarget,5} , ...
              [parValueExpected{iTrial,iTarget,1}, ...
              ' cdppTimeSeries median not as expected!'] ) ;
%           mlunit_assert( ...
%               mad(cdppResults(iTrial,iTarget).cdppTimeSeries,1) >= ...
%                  parValueExpected{iTrial,iTarget,6} && ...
%               mad(cdppResults(iTrial,iTarget).cdppTimeSeries,1) <= ...
%                  parValueExpected{iTrial,iTarget,7} , ...
%               [parValueExpected{iTrial,iTarget,1}, ...
%               ' cdppTimeSeries MAD not as expected!'] ) ;
%           mlunit_assert( ...
%               median(cdppResults(iTrial,iTarget).correlationTimeSeries) >= ...
%                  parValueExpected{iTrial,iTarget,8} && ...
%               median(cdppResults(iTrial,iTarget).correlationTimeSeries) <= ...
%                  parValueExpected{iTrial,iTarget,9} , ...
%               [parValueExpected{iTrial,iTarget,1}, ...
%               ' correlationTimeSeries median not as expected!'] ) ;
%           mlunit_assert( ...
%               mad(cdppResults(iTrial,iTarget).correlationTimeSeries,1) >= ...
%                  parValueExpected{iTrial,iTarget,10} && ...
%               mad(cdppResults(iTrial,iTarget).correlationTimeSeries,1) <= ...
%                  parValueExpected{iTrial,iTarget,11} , ...
%               [parValueExpected{iTrial,iTarget,1}, ...
%               ' correlationTimeSeries MAD not as expected!'] ) ;
          mlunit_assert( ...
              median(cdppResults(iTrial,iTarget).normalizationTimeSeries) >= ...
                 parValueExpected{iTrial,iTarget,12} && ...
              median(cdppResults(iTrial,iTarget).normalizationTimeSeries) <= ...
                 parValueExpected{iTrial,iTarget,13} , ...
              [parValueExpected{iTrial,iTarget,1}, ...
              ' normalizationTimeSeries median not as expected!'] ) ;
%           mlunit_assert( ...
%               mad(cdppResults(iTrial,iTarget).normalizationTimeSeries,1) >= ...
%                  parValueExpected{iTrial,iTarget,14} && ...
%               mad(cdppResults(iTrial,iTarget).normalizationTimeSeries,1) <= ...
%                  parValueExpected{iTrial,iTarget,15} , ...
%               [parValueExpected{iTrial,iTarget,1}, ...
%               ' normalizationTimeSeries MAD not as expected!'] ) ;
          mlunit_assert( ...
              cdppResults(iTrial,iTarget).maxSingleEventStatistic >= ...
                 parValueExpected{iTrial,iTarget,16} && ...
              cdppResults(iTrial,iTarget).maxSingleEventStatistic <= ...
                 parValueExpected{iTrial,iTarget,17} , ...
              [parValueExpected{iTrial,iTarget,1}, ...
              ' maxSingleEventStatistic not as expected!'] ) ;
          mlunit_assert( ...
              cdppResults(iTrial,iTarget).minSingleEventStatistic >= ...
                 parValueExpected{iTrial,iTarget,18} && ...
              cdppResults(iTrial,iTarget).minSingleEventStatistic <= ...
                 parValueExpected{iTrial,iTarget,19} , ...
              [parValueExpected{iTrial,iTarget,1}, ...
              ' minSingleEventStatistic not as expected!'] ) ;
          mlunit_assert( ...
              cdppResults(iTrial,iTarget).meanSingleEventStatistic >= ...
                 parValueExpected{iTrial,iTarget,20} && ...
              cdppResults(iTrial,iTarget).meanSingleEventStatistic <= ...
                 parValueExpected{iTrial,iTarget,21} , ...
              [parValueExpected{iTrial,iTarget,1}, ...
              ' meanSingleEventStatistic not as expected!'] ) ;
          
%         look to see if the harmonic time series and detrended flux time series are as
%         expected in terms of size, and shape
          
          if (iTrial == 1)    
              
              assert_equals( size(cdppResults(iTrial,iTarget).harmonicTimeSeries), ...
                  [4354 1], [parValueExpected{iTrial,iTarget,1}, ...
                  ' harmonic time series has incorrect dimensions!'] ) ;
              assert_equals( size(cdppResults(iTrial,iTarget).detrendedFluxTimeSeries), ...
                  [4354 1], [parValueExpected{iTrial,iTarget,1}, ...
                  ' detrended flux time series has incorrect dimensions!'] ) ;
              assert_equals( cdppResults(iTrial,iTarget).harmonicTimeSeries, ...
                  harmonicTimeSeries(:,iTarget), [parValueExpected{iTrial,iTarget,1}, ...
                  ' harmonic time series has incorrect values!'] ) ;
              
              
          else

              mlunit_assert( isempty(cdppResults(iTrial,iTarget).harmonicTimeSeries), ...
                  [parValueExpected{iTrial,iTarget,1}, ...
                  ' harmonic time series is not empty!'] ) ;
              mlunit_assert( isempty(cdppResults(iTrial,iTarget).detrendedFluxTimeSeries), ...
                  [parValueExpected{iTrial,iTarget,1}, ...
                  ' detrended flux time series is not empty!'] ) ;
              
          end
          
%         check dimensions of the super-resolution time series

          assert_equals( ...
              size( cdppResults(iTrial,iTarget).correlationTimeSeriesHiRes ), ...
              [13062 1], [parValueExpected{iTrial,iTarget,1}, ...
              ' super-resolution correlation time series has incorrect dimension!'] ) ;
          assert_equals( ...
              size( cdppResults(iTrial,iTarget).normalizationTimeSeriesHiRes ), ...
              [13062 1], [parValueExpected{iTrial,iTarget,1}, ...
              ' super-resolution normalization time series has incorrect dimension!'] ) ;
          
      end
      
  end
  
% finally check the trial pulse lengths -- this is probably superfluous, since if the
% trial pulse length order is wrong then all the numerical results will be misplaced and
% the test will fail, but it doesn't hurt to check

  assert_equals( [cdppResults.trialTransitPulseInHours], [3 6 12 3 6 12 3 6 12], ...
      'Trial transit pulse fields have incorrect values!' ) ;
  
% Now turn on the algorithmic spacing in trial transit duration space and
% check that the D values are correct and that they include the required
% trial transit pulses.  Also check that the dimensionality of the results
% struct is correct

  tpsInputStruct.tpsModuleParameters.minTrialTransitPulseInHours=1.5;
  tpsInputStruct.tpsModuleParameters.maxTrialTransitPulseInHours=12;
  tpsInputStruct.tpsModuleParameters.searchTrialTransitPulseDurationStepControlFactor=0.3;
  tpsInputStruct.tpsTargets=tpsInputStruct.tpsTargets(1:2);
  trialTransitDurationVect=compute_trial_transit_durations(tpsInputStruct.tpsModuleParameters);
  
% validate the input struct to get the extra fields added in

  tpsInputStruct = validate_tps_input_structure( tpsInputStruct ) ;

% instantiate the object and put it through the CDPP computer

  tpsObject = tpsClass( tpsInputStruct ) ;
  
% do quarter stitching with performQuarterStitching flag set to false to 
% get needed fields but do not do the quarter stitching 
 
  [tpsObject, harmonicTimeSeries, fittedTrend] = perform_quarter_stitching( tpsObject ) ;
  
  [cdppResults, alerts] = compute_cdpp_time_series( tpsObject, harmonicTimeSeries, fittedTrend ) ;
  
  returnedTransitPulses=unique([cdppResults.trialTransitPulseInHours]);
  
  assert_equals( trialTransitDurationVect, returnedTransitPulses', ...
      'Searched trial transit pulses don''t match expected!' ) ;
  
  assert_equals(sum(ismember(returnedTransitPulses,tpsInputStruct.tpsModuleParameters.requiredTrialTransitPulseInHours)), ...
      length(tpsInputStruct.tpsModuleParameters.requiredTrialTransitPulseInHours), ...
      'Some required transit pulses did not get searched over!' );
  
  assert_equals(size(cdppResults,1), size(tpsInputStruct.tpsTargets,2) * length(returnedTransitPulses), ...
      'cdppResults doesnt have the correct dimensionality' );
 
  disp('') ;
  
return  


% determine appropriate limits
% format long g ;
% limitsArray = zeros(nTargets,nPulses,20);
% percentFactor = 0.01;
% for iTarget=1:nTargets
%     for iTrial=1:nPulses
%         limitsArray(iTarget,iTrial,1)=cdppResults(iTrial,iTarget).rmsCdpp*(1-percentFactor);
%         limitsArray(iTarget,iTrial,2)=cdppResults(iTrial,iTarget).rmsCdpp*(1+percentFactor);
%         if(median(cdppResults(iTrial,iTarget).cdppTimeSeries) < 0)
%             limitsArray(iTarget,iTrial,3)=median(cdppResults(iTrial,iTarget).cdppTimeSeries)*(1+percentFactor);
%             limitsArray(iTarget,iTrial,4)=median(cdppResults(iTrial,iTarget).cdppTimeSeries)*(1-percentFactor);
%         else
%             limitsArray(iTarget,iTrial,3)=median(cdppResults(iTrial,iTarget).cdppTimeSeries)*(1-percentFactor);
%             limitsArray(iTarget,iTrial,4)=median(cdppResults(iTrial,iTarget).cdppTimeSeries)*(1+percentFactor);
%         end
%         limitsArray(iTarget,iTrial,5)=mad(cdppResults(iTrial,iTarget).cdppTimeSeries,1)*(1-percentFactor);       
%         limitsArray(iTarget,iTrial,6)=mad(cdppResults(iTrial,iTarget).cdppTimeSeries,1)*(1+percentFactor);
%         if(median(cdppResults(iTrial,iTarget).correlationTimeSeries)<0)
%             limitsArray(iTarget,iTrial,7)=median(cdppResults(iTrial,iTarget).correlationTimeSeries)*(1+percentFactor);
%             limitsArray(iTarget,iTrial,8)=median(cdppResults(iTrial,iTarget).correlationTimeSeries)*(1-percentFactor);
%         else
%             limitsArray(iTarget,iTrial,7)=median(cdppResults(iTrial,iTarget).correlationTimeSeries)*(1-percentFactor);
%             limitsArray(iTarget,iTrial,8)=median(cdppResults(iTrial,iTarget).correlationTimeSeries)*(1+percentFactor);
%         end
%         limitsArray(iTarget,iTrial,9)=mad(cdppResults(iTrial,iTarget).correlationTimeSeries,1)*(1-percentFactor);
%         limitsArray(iTarget,iTrial,10)=mad(cdppResults(iTrial,iTarget).correlationTimeSeries,1)*(1+percentFactor);
%         if(median(cdppResults(iTrial,iTarget).normalizationTimeSeries)<0)
%             limitsArray(iTarget,iTrial,11)=median(cdppResults(iTrial,iTarget).normalizationTimeSeries)*(1+percentFactor);
%             limitsArray(iTarget,iTrial,12)=median(cdppResults(iTrial,iTarget).normalizationTimeSeries)*(1-percentFactor);
%         else
%             limitsArray(iTarget,iTrial,11)=median(cdppResults(iTrial,iTarget).normalizationTimeSeries)*(1-percentFactor);
%             limitsArray(iTarget,iTrial,12)=median(cdppResults(iTrial,iTarget).normalizationTimeSeries)*(1+percentFactor);
%         end
%         limitsArray(iTarget,iTrial,13)=mad(cdppResults(iTrial,iTarget).normalizationTimeSeries,1)*(1-percentFactor);
%         limitsArray(iTarget,iTrial,14)=mad(cdppResults(iTrial,iTarget).normalizationTimeSeries,1)*(1+percentFactor);
%         limitsArray(iTarget,iTrial,15)=cdppResults(iTrial,iTarget).maxSingleEventStatistic*(1-percentFactor);
%         limitsArray(iTarget,iTrial,16)=cdppResults(iTrial,iTarget).maxSingleEventStatistic*(1+percentFactor);
%         limitsArray(iTarget,iTrial,17)=cdppResults(iTrial,iTarget).minSingleEventStatistic*(1+percentFactor);
%         limitsArray(iTarget,iTrial,18)=cdppResults(iTrial,iTarget).minSingleEventStatistic*(1-percentFactor);
%         if(cdppResults(iTrial,iTarget).meanSingleEventStatistic<0)
%             limitsArray(iTarget,iTrial,19)=cdppResults(iTrial,iTarget).meanSingleEventStatistic*(1+percentFactor);
%             limitsArray(iTarget,iTrial,20)=cdppResults(iTrial,iTarget).meanSingleEventStatistic*(1-percentFactor);
%         else
%             limitsArray(iTarget,iTrial,19)=cdppResults(iTrial,iTarget).meanSingleEventStatistic*(1-percentFactor);
%             limitsArray(iTarget,iTrial,20)=cdppResults(iTrial,iTarget).meanSingleEventStatistic*(1+percentFactor);
%         end
%         
%         fprintf('%g, %g, %g, %g, ...\n \t\t\t %g, %g, %g, %g, ...\n \t\t\t %g, %g, %g, %g, ...\n \t\t\t %g, %g, %g, %g, ...\n \t\t\t %g, %g, %g, %g } ;\n', ...
%             limitsArray(iTarget,iTrial,1),limitsArray(iTarget,iTrial,2),limitsArray(iTarget,iTrial,3),limitsArray(iTarget,iTrial,4), ...
%             limitsArray(iTarget,iTrial,5),limitsArray(iTarget,iTrial,6),limitsArray(iTarget,iTrial,7),limitsArray(iTarget,iTrial,8), ...
%             limitsArray(iTarget,iTrial,9),limitsArray(iTarget,iTrial,10),limitsArray(iTarget,iTrial,11),limitsArray(iTarget,iTrial,12), ...
%             limitsArray(iTarget,iTrial,13),limitsArray(iTarget,iTrial,14),limitsArray(iTarget,iTrial,15),limitsArray(iTarget,iTrial,16), ...
%             limitsArray(iTarget,iTrial,17),limitsArray(iTarget,iTrial,18),limitsArray(iTarget,iTrial,19),limitsArray(iTarget,iTrial,20));
%     end
% end