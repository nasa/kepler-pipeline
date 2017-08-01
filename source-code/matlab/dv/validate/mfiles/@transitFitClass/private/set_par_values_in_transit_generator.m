function transitGeneratorObject = set_par_values_in_transit_generator( ...
    transitGeneratorObject, fitType, parameterMapStruct, parameterArray )
%
% set_par_values_in_transit_generator -- private function of transitFitClass.  Inserts
% parameter values into a transitGeneratorClass object according to a parameter map, and
% returns the updated transitGeneratorClass object.
%
% transitGeneratorObject = set_par_values_in_transit_generator( transitGeneratorObject,
%    fitType, parameterMapStruct, parameterArray ).
%
% Version date:  2010-Dec-01.
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

% Modfication History:
%
%    2010-Dec-01, JL:
%        fix a bug related to parameterMapStruct, which may be a struct array
%    2010-October-28, JL:
%        do not calculate star radius when geometric transit model is used. 
%    2010-April-28, PT:
%        changes in support of transitGeneratorCollectionClass.
%    2009-September-16, PT:
%        add and make use of fitType argument.
%    2009-August-18, PT:
%        support for varying the semi-major axis and the orbital period independently.
%    2009-August-17, PT:
%        convert negative-signed quantities to positive ones if any are present.
%    2009-May-27, PT:
%        update to match improved overall design.
%
%=========================================================================================

% extract the planet model from the existing object

  planetModel   = get( transitGeneratorObject, 'planetModel' ) ;
  oldOrbitalPeriodDays = [planetModel.orbitalPeriodDays] ;
  
% insert the parameters from the array into their requried locations
  
  for iObject = 1:length( planetModel )
    parameterList = fieldnames( parameterMapStruct(iObject) ) ;
    for iField = 1:length(parameterList)
      parameterPointer = ...
          parameterMapStruct(iObject).(parameterList{iField}) ;
      if (parameterPointer ~= 0)
          planetModel(iObject).(parameterList{iField}) = ...
              abs(parameterArray(parameterPointer)) ;
      end
    end 
  end
  
% In the case of fitType 1 objects, the parameter vector contains a mix of physical and
% observable parameters, and we cannot change such a mix in one call to the
% transitGeneratorClass get.  In the case of fitType 2 objects, the period is fixed so
% when we vary the semi-major axis the star radius has to change to recover the original
% period.  We handle both these cases by using Kepler's 3rd law to find the required
% star radius (note that the function will do nothing for fitType 0 objects).
  
% Note:
% When geometric transit model is not used, fitType is set to 0/1/2
% When geometric transit model is     used, fitType is set to 11/12/13/14

  if all( fitType<10 )  
      planetModel = set_star_radius_via_kepler_3( transitGeneratorObject, planetModel, ...
          oldOrbitalPeriodDays, fitType ) ;
  end
  
  transitGeneratorObject = set( transitGeneratorObject, 'planetModel', planetModel ) ;
  
return