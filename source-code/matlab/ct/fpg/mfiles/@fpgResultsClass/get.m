function val = get( fpgResultsObject, memberName )
%
% GET -- obtain the value of a member of an fpgResultsClass object.
%
% val = get(fpgResultsObject,memberName) will return the value of the fpgResultsClass 
%    member memberName from the fpgResultsClass object fpgResultsObject, including members
%    which are present due to inheritance from the fpgFitClass. If memberName is not the
%    name of a member of the fpgResultsClass, either ordinary or through inheritance from
%    fpgFitClass, an error will occur.
%
% val = get(fpgResultsObject,'*') returns a structure with all of the fpgResultsClass 
%    members.  The members which are inherited from the fpgFitClass will be sub-fields in
%    the fpgFitClass field.
%
% list = get(fpgResultsObject,'?') returns a list of valid fpgResultsClass members.  This 
%    is synonymous with list = get(fpgResultsObject,'help').
%
% Version date:  2008-july-08.
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

% Modification history:
%
%=========================================================================================

% handle the case of a '?' or 'help' first

  validMemberNames = fieldnames(fpgResultsObject) ;
  validMemberNamesInherited = get(fpgResultsObject.fpgFitClass,'?') ;
  if ( (strcmp(memberName,'?')) || (strcmpi(memberName,'help')) )
      val = [validMemberNames ; validMemberNamesInherited] ;
      
% now handle the case of a "give me everything" request

  elseif ( strcmp(memberName,'*') )
      val = struct(fpgResultsObject) ;
      val.fpgFitClass = get(fpgResultsObject.fpgFitClass,'*') ;
      
% now handle the case of a particular field name

  else
      
      memberNumber = strmatch( memberName, validMemberNames, 'exact' ) ;
      memberNumberInherited = strmatch( memberName, validMemberNamesInherited, 'exact' ) ;
      if (  isempty(memberNumber) && isempty(memberNumberInherited) )
          
          error('fpg:fpgResultsClass:get:badFieldName', ...
              'fpgResultsClass get method:  invalid field name') ;
          
      else
          if (~isempty(memberNumber))
              val = fpgResultsObject.(validMemberNames{memberNumber}) ;
          else
              val = get(fpgResultsObject.fpgFitClass,memberName) ;
          end
          
      end
      
  end