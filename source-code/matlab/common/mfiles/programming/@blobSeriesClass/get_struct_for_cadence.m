function blobStruct = get_struct_for_cadence( blobSeriesObject, cadences )
%
% get_struct_for_cadence -- get the deblobbed data structure associated with particular
%    cadences out of a blobSeriesClass object.
%
% blobStruct = get_struct_for_cadence( blobSeriesObject, cadences ) returns the deblobbed
%    data structures associated with cadence numbers in vector argument cadences.  The
%    return is an array of structures, blobStruct, with one field, struct, which contains
%    the returned data structures.  The vector cadences must be integer-valued, with all
%    values between 1 and get_cadence_count(blobSeriesObject).  For gapped cadences,
%    blobStruct(iCadence).struct == logical false.
%
% See also:  blobSeriesClass, get_cadence_count.
%
% Version date:  2008-September-07.
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
%     2008-September-07, PT:
%         force iCadence loops to be row-vectors.
%
%=========================================================================================

% Are the cadences in range?

  if (~isvector(cadences))
      error('programming:getStructForCadences:cadencesArgumentNotVector', ...
          'get_struct_for_cadence:  cadences argument must be a vector') ;
  end
  if ( any(cadences < 1) || any(cadences > length(blobSeriesObject.blobIndices)) )
      error('programming:getStructForCadence:cadencesArgumentRange', ...
          'get_struct_for_cadence:  cadences argument out of range') ;
  end
  if (any(cadences~=round(cadences)))
      error('programming:getStructForCadences:cadencesArgumentNotIntValued', ...
          'get_struct_for_cadence:  cadences argument must be integer-valued') ;
  end
  
% define the return structure and while we're at it dimension it

  nCadences = length(cadences) ;
  blobStruct(nCadences).struct = [] ;
  
% find the gapped and ungapped cadences

  gapIndicators = blobSeriesObject.gapIndicators(cadences) ;
  gappedCadences = find(gapIndicators) ;
  ungappedCadences = find(~gapIndicators) ;
  blobIndices = blobSeriesObject.blobIndices ;
  
% fill in the values 

  for iCadence = gappedCadences(:)'
      blobStruct(iCadence).struct = false ;
  end
  
  for iCadence = ungappedCadences(:)'
      blobStruct(iCadence).struct = ...
          blobSeriesObject.blobStruct(blobIndices(cadences(iCadence))).struct ;
  end
  
% and that's it!

%
%
%

  