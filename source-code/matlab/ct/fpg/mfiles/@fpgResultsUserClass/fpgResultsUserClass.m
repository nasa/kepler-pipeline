function fpgResultsUserObject = fpgResultsUserClass( fpgResultsArgument )
%
% fpgResultsUserClass -- constructor for fpgResultsUserClass objects.
%
% fpgResultsUserObject = fpgResultsUserClass( fpgResultsArgument ) returns an object of
%    the fpgResultsUserClass.  The fpgResultsUserClass inherits all of its members and all
%    but one of its methods from the fpgResultsClass; the fpgResultsArgument can be an
%    fpgResultsClass object, an fpgResultsUserClass object, or a data structure obtained
%    via the fpgResultsClass / fpgResultsUserClass get method.
%
% Version date:  2008-July-25.
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
%     2008-July-25, PT:
%          support for structures derived from fpgResultsClass and fpgResultsUserClass
%          objects -- now that FOV plotting information is only in the UserClass,
%          additional logic is necessary.
%
%=========================================================================================

% get the class of the argument

  argumentClass = class(fpgResultsArgument) ;

% do different things depending on whether it's an fpgResultsUserClass object or not

  if (strcmp(argumentClass,'fpgResultsUserClass'))
      fpgResultsUserObject = fpgResultsArgument ;
  
  else

%     if we've gotten here, then we have to instantiate an fpgResultsObject and then
%     instantiate the fpgResultsUserClass object with the additional fields related to FOV
%     plotting

%     prepare data slots for the FOV plotting information

      s.pixelTimeSeries = [] ;
      s.starSkyCoordinates = [] ;
      s.minMagnitude = [] ;
      s.maxMagnitude = [] ;

      if (strcmp(argumentClass,'fpgResultsClass'))
      
          fpgResultsObject = fpgResultsClass( fpgResultsArgument ) ;
      
      elseif (strcmp(argumentClass,'struct'))
      
%         if it's a structure, it can be two types of structure:  it can be a structure
%         from a get(fpgResultsClass) call, or one from a get(fpgResultsUserClass) call.
%         If it's the latter, there will be the 4 fields related to FOV plotting and an
%         fpgResultsClass field with an fpgResultsClass structure in it.

          if (isfield(fpgResultsArgument,'fpgResultsClass'))

              s = rmfield(fpgResultsArgument,'fpgResultsClass') ;
              fpgResultsObject = fpgResultsClass(fpgResultsArgument.fpgResultsClass) ;

          else % structure from fpgResultsClass getter

              fpgResultsObject = fpgResultsClass(fpgResultsArgument) ;

          end % fpgResultsUserClass vs fpgResultsClass struct conditional
          
      end % struct vs fpgResultsClass object conditional
      
%     at this point, we have an fpgResultsObject and a structure with the FOV plotting
%     information in it; so instantiate now!

      fpgResultsUserObject = class(s, 'fpgResultsUserClass', fpgResultsObject ) ;
      
  end
  
% and that's it!

%
%
%