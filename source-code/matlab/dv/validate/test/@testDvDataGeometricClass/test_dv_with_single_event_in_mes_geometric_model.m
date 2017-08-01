function self = test_dv_with_single_event_in_mes_geometric_model( self )
%
% test_dv_with_single_event_in_mes_geometric_model -- this is a unit test of the DV validation and fitting algorithms for cases in which the flux time series contains
% a single large single event statistic which results in a significant (but spurious) multiple event statistic.
%
% This test exercises the following functionality:
%
% ==> The data structure is passed through the validation phase even though both targets have a period of -1 from TPS
% ==> Both bad periods are detected in the fitter and the appropriate alerts are raised
% ==> No fitting is performed on either target.
%
% This test is intended to be executed in the mlunit context.  For standalone execution use the following syntax:
%
%      run(text_test_runner, testDvDataGeometricClass('test_dv_with_single_event_in_mes_geometric_model'));
%
% Version date:  2011-May-05.
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
%    2011-May-05, JL:
%        update in support of DV 7.0.
%
%=========================================================================================

  disp(' ');
  disp('... testing DV with targets where MES contains a single SES with geometric transit model ... ');
  disp(' ');
  
  dvDataFilename = 'planet-search-test-data';
  testDvDataGeometricClass_fitter_initialization;
  
% first, make sure that the orbital period from TPS is set to -1, and set the MES / SES ratio test to zero (otherwise the MES / SES alert will be triggered,
% rather than the orbital period alert)

  dvDataStruct.targetStruct.thresholdCrossingEvent.orbitalPeriod   = -1;
  dvDataStruct.planetFitConfigurationStruct.minEventStatisticRatio =  0;
  dvDataObject = dvDataClass(dvDataStruct);
  
% create the directories for the figures to be shoved into

  dvResultsStruct = create_directories_for_dv_figures( dvDataObject, dvResultsStructBeforeFit );

% then, make sure that there is a single SES in the target's flux time series, so that the DV-TPS call will also result in an orbital period of -1
  
  fluxValues = dvResultsStructBeforeFit.targetResultsStruct.residualFluxTimeSeries.values;
  
  fluxval           = 1 + 50e-6 * randn(size(fluxValues));
  fluxval(495:506)  = fluxval(495:506) - 0.01;
  fluxval           = fluxval * 1e7;
  
  dvResultsStructBeforeFit.targetResultsStruct.residualFluxTimeSeries.values = fluxval; 
  
% run the method perform_iterative_whitening_and_model_fitting

  refTime = clock;  
  dvResultsStruct = perform_dv_planet_search_and_model_fitting( dvDataObject, dvResultsStructBeforeFit, ...
      normalizedFluxTimeSeriesWithHarmonicsArray, normalizedFluxTimeSeriesHarmonicsFreeArray, refTime );
  
% Check allTransitFit struct and alert message

  allTransitsFit = dvResultsStruct.targetResultsStruct.planetResultsStruct.allTransitsFit;
  noPlanetFit =                isequal( allTransitsFit.modelChiSquare, -1 );
  noPlanetFit = noPlanetFit && isequal( allTransitsFit.modelDegreesOfFreedom, -1 );
  noPlanetFit = noPlanetFit && isequal( allTransitsFit.robustWeights, zeros(size(fluxValues)) );
  noPlanetFit = noPlanetFit && isempty( allTransitsFit.modelParameters );
  noPlanetFit = noPlanetFit && isempty( allTransitsFit.modelParameterCovariance );
  
  mlunit_assert( noPlanetFit, 'all transits fit was performed!' );
  mlunit_assert( ~isempty( strfind( dvResultsStruct.alerts(1).message, 'Threshold Crossing Event orbital period < 0' ) ), 'Alert not properly issued!' );
  
return

% and that's it!
