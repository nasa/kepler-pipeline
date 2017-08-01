function retVal = get( prfCollectionObject, memberName, row, column )
%
% get -- retrieve the value of a member of a prfCollectionClass object
% 
% retVal = get( prfCollectionObject, memberName ) returns the value of the named member of
%    the prfCollectionClass object.  If memberName is not a valid member of the
%    prfCollectionClass, get attempts to use the get method of the embedded prfClass
%    objecct (the center object in the case in which there are multiple PRFs embedded).
%
% retVal = get( prfCollectionObject, prfClassMemberName, row, column ) returns the member
%    in prfClassMemberName for the prfClass object obtained by interpolating the
%    prfCollectionClass object to the specified location.
%
% retVal = get( prfCollectionObject, '?' ) or retVal = get( prfCollectionObject, 'help' ) 
%    returns the list of valid prfCollectionClass member names.
%
% retVal = get( prfCollectionObject, '*' ) returns a data structure with all of the 
%    members as its fields.  For the encapsulated prfClass objects, the coefficientMatrix
%    is returned as a sub-field.
%
% Version date:  2008-October-21.
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
%     2008-October-21, PT:
%         add capability to use the get method on the embedded prfClass object.
%     2008-September-24, PT:
%         switch from getting prfClass object polyStruct member (which is no longer stored
%         in the prfClass) to getting the coefficientMatrix member. 
%
%=========================================================================================

% handle the case of a '?' or 'help' first

  validMemberNames = fieldnames(prfCollectionObject) ;
  if ( (strcmp(memberName,'?')) || (strcmpi(memberName,'help')) )
      retVal = validMemberNames ;
      
% now handle the case of a "give me everything" request

  elseif ( strcmp(memberName,'*') )
      retVal = struct(prfCollectionObject) ;
      retVal.prfCornerObject = [] ;
      retVal.prfCenterObject = [] ;
      for iCorner = 1:5
          retVal.prfCornerObject(iCorner).coefficientMatrix = ...
              get(prfCollectionObject.prfCornerObject(iCorner),'coefficientMatrix') ;
      end
      retVal.prfCenterObject.coefficientMatrix = get(prfCollectionObject.prfCenterObject,...
          'coefficientMatrix') ;
  
  else

%     individual field belonging to either the prfCollectionClass or the underlying
%     prfClass object; if the latter, use the prfClass get method.  
      
      memberNumber = strmatch( memberName, validMemberNames, 'exact' ) ;
      if (isempty(memberNumber))
          
          if (nargin == 4)
              prfObject = get_interpolated_prf(prfCollectionObject,row,column,1)
			  keyboard
          elseif (prfCollectionObject.interpolateFlag == 0)
              prfObject = prfCollectionObject.prfCenterObject ;
          else
              prfObject = prfCollectionObject.prfCenterObject ;
              warning('prf:prfCollectionClass:get:usingCenterPrf' , ...
                  'prfCollectionClass:get: using center prfClass object for get request') ;
          end
          retVal = get(prfObject,memberName) ;
          
%           if (interpolateFlag == 0)
%               retVal = get(prfCollectionObject.prfCenterObject, memberName) ;
%           else
%               error('prf:prfCollectionClass:get:badFieldName', ...
%                   'prfCollectionClass get method:  invalid field name') ;
%           end
          
      else
          
          retVal = prfCollectionObject.(validMemberNames{memberNumber}) ;
          
      end
      
  end
