function self = test_determine_convergence( self )
%
% test_determine_convergence -- unit test for determine_convergence method of
% transitFitClass
%
% This unit test exercises the following functionality in determine_convergence:
%
% ==> When only 1 transitFitClass object is passed as an argument, the method returns
%     false
% ==> When all fitted values of 2 transitFitClass arguments are within the specified
%     tolerance, the method returns true
% ==> when any fitted values are outside the tolerance, the method returns false.
%
% This test is intended to be executed in the mlunit context.  For standalone execution
% use the following syntax:
%
%      run(text_test_runner, testTransitFitClass('test_determine_convergence'));
%
% Version date:  2009-September-23.
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
%=========================================================================================

  disp('... testing transitFitClass convergence determination ... ')
  
  testTransitFitClass_initialization ;
  
% test 1:  does the convergence method do the right thing when given only 1
% transitFitClass object?

  convergenceTolerance = 0.01 ;
  isConverged = determine_convergence( transitFitObject1, [], convergenceTolerance ) ;
  mlunit_assert( ~isConverged, ...
      'convergence found with only 1 transitFitClass object!' ) ;
  
% test 2:  when all of the parameters agree to within errors, does the method signal
% convergence?  To determine this, construct a transitFitClass object which has its final
% par values perturbed from those in the fitted object according to the covariance matrix
% of the fitted object and the convergence tolerance

  transitFitStruct1 = get( transitFitObject1, '*' ) ;
  uncorrelatedNoise = convergenceTolerance / 10 * ...
      rand( size( transitFitStruct1.finalParValues ) ) ;
  correlatedNoise = chol( transitFitStruct1.parValueCovariance, 'lower' ) * ...
      uncorrelatedNoise ;
  transitFitStruct1.finalParValues = transitFitStruct1.finalParValues + ...
      correlatedNoise ;
  transitFitObject2 = transitFitClass( transitFitStruct1, 1 ) ;
  
  isConverged = determine_convergence( transitFitObject1, transitFitObject2, ...
      convergenceTolerance ) ;
  mlunit_assert( isConverged, ...
      'convergence not signaled for fit objects which agree to within tolerance!' ) ;
  
% test 3:  when 1 parameter is out of tolerance, does the method signal failure to
% converge?

  uncorrelatedNoise = [2*convergenceTolerance ; 0 ; 0 ; 0] ;
  correlatedNoise = chol( transitFitStruct1.parValueCovariance, 'lower' ) * ...
      uncorrelatedNoise ;
  transitFitStruct1.finalParValues = transitFitStruct1.finalParValues + ...
      correlatedNoise ;
  transitFitObject3 = transitFitClass( transitFitStruct1, 1 ) ;
  
  isConverged = determine_convergence( transitFitObject1, transitFitObject3, ...
      convergenceTolerance ) ;
  mlunit_assert( ~isConverged, ...
      'convergence signaled when objects disagree at level of convergence tolerance!' ) ;
  
  disp(' ') ;
  
return

% and that's it!

%
%
%
