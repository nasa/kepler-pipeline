function transitNumber = identify_transit_cadences( transitObject, cadenceTimes, ...
    transitBufferFactor )
%
% identify_transit_cadences -- identify the transits which are in-transit in a
% transitGeneratorCollectionClass object
%
% transitNumber = identify_transit_cadences( transitObject, cadenceTimes,
%    transitBufferFactor) returns a vector equal in dimension to cadenceTimes which shows
%    which transit each cadence corresponds to (or zero for cadences which are out of
%    transit).  The transitBufferFactor allows a region which is larger than the pure
%    transit to be included (ie, transitBufferFactor == 1 finds a region which is 3
%    transits wide and centered on the transit epoch of each transit).
%
% Version date:  2010-April-26.
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

% we actually need to do slightly different things for each value of oddEvenFlag

  switch transitObject.oddEvenFlag
      
      case 0 % simple single-object case
          
          transitNumber = identify_transit_cadences( ...
              transitObject.transitGeneratorObjectVector, cadenceTimes, ...
              transitBufferFactor ) ;
          
      case 1 % odd-even fitting -- we need to find the correct transits in each object 
             % and merge them
             
          transitNumber = zeros( size( cadenceTimes ) ) ;
          
          transitNumber1 = identify_transit_cadences( ...
              transitObject.transitGeneratorObjectVector(1), cadenceTimes, ...
              transitBufferFactor ) ;
          oddTransitCadences = find( mod(transitNumber1,2) == 1 ) ;
          transitNumber(oddTransitCadences) = transitNumber1(oddTransitCadences) ;

          transitNumber2 = identify_transit_cadences( ...
              transitObject.transitGeneratorObjectVector(2), cadenceTimes, ...
              transitBufferFactor ) ;
          evenTransitCadences = find( mod(transitNumber2,2) == 0 & transitNumber2 > 0 ) ;
          transitNumber(evenTransitCadences) = transitNumber2(evenTransitCadences) ;
          
      case 2 % individual-transits fitting -- somewhat more complicated!
          
          transitNumber = zeros( size( cadenceTimes ) ) ;
          
          for iObject = 1:length( transitObject.transitGeneratorObjectVector )
              transitCadences = find_transit_cadences( transitObject, iObject, ...
                  iObject, transitBufferFactor ) ;
              transitNumber(transitCadences) = iObject ;
          end
          
  end % switch statement
  
return

% and that's it!

%
%
%
