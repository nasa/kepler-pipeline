function dvResultsStruct = roll_back_results_struct_from_failed_fit( dvResultsStruct, ...
    iTarget, iPlanet, oddEvenFlag )
%
% roll_back_results_struct_from_failed_fit -- remove any results information from a planet
% fit which did not complete successfully.
%
% dvResultsStruct = roll_back_results_struct_from_failed_fit( dvResultsStruct, iTarget,
%    iPlanet, oddEvenFlag ) removes any trace of results packaged into dvResultsStruct in
%    targetResultsStruct(iTarget) . planetResultsStruct(iPlanet) .
%    (all/odd/even)TransitsFit.  This prevents a partially-filled results structure from
%    being presented in the event of a fit which has, ultimately, failed.  
%
% The method roll_back_results_struct_from_failed_fit is a private method of the
%    dvDataClass.
%
% Version date:  2009-December-04.
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
% 2009-December-04, PT:
%     roll back expected and observed transit counts for oddEvenFlag == 0.
%
%=========================================================================================

% get the appropriate fit results structure

  planetResultsStruct = ...
      dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet) ;
  nCadences = length( ...
      dvResultsStruct.targetResultsStruct(iTarget).residualFluxTimeSeries.values ) ;
  switch oddEvenFlag
      
      case 0 % all-transits fit
          transitFitStruct = planetResultsStruct.allTransitsFit ;
          
      case 1 % odd-transits fit
          transitFitStruct = planetResultsStruct.oddTransitsFit ;
          
      case 2 % even-transits fit
          transitFitStruct = planetResultsStruct.evenTransitsFit ;
          
      otherwise % error condition
          error( 'dv:rollBackResultsFromFailedFit:oddEvenFlagInvalid', ...
              ['roll_back_results_from_failed_fit:  oddEvenFlag value of ', ...
              num2str(oddEvenFlag),' invalid'] ) ;
          
  end

% clean out the transitFitStruct back to its initial values

  transitFitStruct.fullConvergence = false ;
  transitFitStruct.modelChiSquare = -1 ;
  transitFitStruct.modelFitSnr = -1 ;
  transitFitStruct.robustWeights = zeros(nCadences,1) ;
  transitFitStruct.modelParameters = [] ;
  transitFitStruct.modelParameterCovariance = [] ;
  
% assign the transitFitStruct back onto the dvResultsStruct

  switch oddEvenFlag
      
      case 0
          planetResultsStruct.allTransitsFit = transitFitStruct ;
          
      case 1
          planetResultsStruct.oddTransitsFit = transitFitStruct ;
          
      case 2
          planetResultsStruct.evenTransitsFit = transitFitStruct ;
          
  end
  
% If we're on the all-transits fit, roll back the transit counts

  if oddEvenFlag == 0
      
      planetResultsStruct.planetCandidate.expectedTransitCount = 0 ;
      planetResultsStruct.planetCandidate.observedTransitCount = 0 ;
      
  end
  
  dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet) = ...
      planetResultsStruct ;
  
return

% and that's it!

%
%
%
