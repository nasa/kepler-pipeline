function planetResultsStruct = check_planet_model_parameter_validity( planetResultsStruct, ...
    unitOfWorkStart, unitOfWorkEnd, oddEvenFlag )
%
% check_planet_model_parameter_validity -- check to make sure that certain parameters of a
% planet model are reasonable
%
% planetResultsStruct = check_planet_model_parameter_validity( planetResultsStruct, 
%    unitOfWorkStart, unitOfWorkEnd, oddEvenFlag ) checks to see that the epoch,
%    duration, and period of a transit model are valid.  In the event that the duration or
%    the period are not valid, an error is thrown.  If the epoch falls outside the unit of
%    work, it will be corrected to lie within the unit of work if possible.
%
% Version date:  2011-May-14.
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
%    2012-May-14, JL:
%        return when the field 'modelParameters' is empty
%    2011-Dec-20, JL:
%        comment out adjustment of transit epoch
%    2010-May-05, PT:
%        convert from transitEpochMjd to transitEpochBkjd.
%
%=========================================================================================

% get the desired model parameters out of the struct, based on the oddEvenFlag

  switch oddEvenFlag
      
      case 0
          modelParameters = planetResultsStruct.allTransitsFit.modelParameters ;
      case 1
          modelParameters = planetResultsStruct.oddTransitsFit.modelParameters ;
      case 2
          modelParameters = planetResultsStruct.evenTransitsFit.modelParameters ;
          
  end

  if isempty(modelParameters)
      return;
  end
  
% default to an assumption of valid parameters

  parametersValid = true ;

% define the duration of the unit of work

  unitOfWorkDuration = unitOfWorkEnd - unitOfWorkStart ;
  
% Our checks are on the observable parameters Epoch, Duration, and Period.  Start with the
% period, which must be positive and less than or equal to the UOW

  modelNames = {modelParameters.name} ;
  periodIndex = find( strcmp( 'orbitalPeriodDays', modelNames ) ) ;
  periodValue = modelParameters( periodIndex ).value ;
  
  if periodValue <= 0 || periodValue > unitOfWorkDuration
      parametersValid = false ;
      disp( [ 'Invalid period fit value of ', num2str(periodValue), ' days'] ) ;
  end
  
% The duration of the transit must also be greater than zero and less than or equal to the
% UOW

  durationIndex = find( strcmp( 'transitDurationHours', modelNames ) ) ;
  durationValue = modelParameters( durationIndex ).value ;
  durationValue = durationValue * get_unit_conversion( 'hour2day' ) ;
  
  if durationValue <= 0 || durationValue > unitOfWorkDuration
      parametersValid = false ;
      display( [ 'Invalid duration fit value of ', ...
          num2str( durationValue * get_unit_conversion( 'day2hour' ) ), ' hours'] ) ;
  end
  
% The epoch is more complicated.  If the epoch is outside of the unit of work, its value
% should be adjusted by the value of the period until it is within the unit of work, if
% such an adjustment is possible.  
  
  epochIndex = find( strcmp( 'transitEpochBkjd', modelNames ) ) ;
  epochValue = modelParameters( epochIndex ).value ;
  
%   if ( epochValue < unitOfWorkStart || epochValue > unitOfWorkEnd ) && ...
%           parametersValid 
%       
%        periodsBeforeUowStart = (unitOfWorkStart - epochValue) / periodValue ;
%        epochValue = epochValue + periodValue * ceil( periodsBeforeUowStart ) ;
%        modelParameters( epochIndex ).value = epochValue ;
%            
%        
%   end 
  
  if ( ~parametersValid )
      error( 'dv:checkPlanetModelParameterValidity:invalidParameters', ...
          'check_planet_model_parameter_validity:  invalid parameters detected' ) ;
  end

% put the model parameters back in the struct, based on the oddEvenFlag

  switch oddEvenFlag
      
      case 0
          planetResultsStruct.allTransitsFit.modelParameters = modelParameters ;
      case 1
          planetResultsStruct.oddTransitsFit.modelParameters = modelParameters ;
      case 2
          planetResultsStruct.evenTransitsFit.modelParameters = modelParameters ;
          
  end
  
return

% and that's it!

%
%
%


  
