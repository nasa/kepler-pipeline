function val = get( fpgResultsUserObject, memberName )
%
% GET -- obtain the value of a member of an fpgResultsUserClass object.
%
% val = get(fpgResultsUserObject,memberName) will return the value of the 
%    fpgResultsUserClass member memberName from the fpgResultsUserClass object
%    fpgResultsUserObject, including members which are present due to inheritance from the
%    fpgFitClass. If memberName is not the name of a member of the fpgResultsUserClass,
%    either ordinary or through inheritance from fpgFitClass, an error will occur.
%
% val = get(fpgResultsUserObject,'*') returns a structure with all of the 
%    fpgResultsUserClass members.  The members which are inherited from the fpgFitClass
%    will be sub-fields in the fpgFitClass field.
%
% list = get(fpgResultsUserObject,'?') returns a list of valid fpgResultsUserClass 
%    members.  This is synonymous with list = get(fpgResultsUserObject,'help').
%
% Version date:  2008-july-25.
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
%     2008-July-25, PT:
%         handle get of FOV plotting information members properly.
%
%=========================================================================================

% handle the case of a '?' or 'help' first

  validMemberNames = fieldnames(fpgResultsUserObject) ;
  validMemberNamesInherited = get(fpgResultsUserObject.fpgResultsClass,'?') ;
  if ( (strcmp(memberName,'?')) || (strcmpi(memberName,'help')) )
      val = [validMemberNames ; validMemberNamesInherited] ;
      
% now handle the case of a "give me everything" request

  elseif ( strcmp(memberName,'*') )
      val = struct(fpgResultsUserObject) ;
      val.fpgResultsClass = get(fpgResultsUserObject.fpgResultsClass,'*') ;
      
% now handle the case of a particular field name

  else
      
      memberNumber = strmatch( memberName, validMemberNames, 'exact' ) ;
      memberNumberInherited = strmatch( memberName, validMemberNamesInherited, 'exact' ) ;
      if (  isempty(memberNumber) && isempty(memberNumberInherited) )
          
          error('fpg:fpgResultsUserClass:get:badFieldName', ...
              'fpgResultsUserClass get method:  invalid field name') ;
          
      else
          if (~isempty(memberNumber))
              val = fpgResultsUserObject.(validMemberNames{memberNumber}) ;
          else
              val = get(fpgResultsUserObject.fpgResultsClass,memberName) ;
          end
          
      end
      
  end
%
%
%