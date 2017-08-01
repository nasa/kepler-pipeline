function fpgFitClassObject = fpgFitClass(fpgFitClassArgument)
%
% fpgFitClass -- constructor for the fpgFitClass.
%
% fpgFitClassObject = fpgFitClass(fpgFitClassArgument) is the constructor for the
%    fpgFitClass Matlab class, used by the Focal Plane Geometry tool.  The argument
%    fpgFitClassArgument can be either an fpgFitClass object, in which case this object is
%    returned unchanged as the LHS argument; or it can be a data structure with the
%    fpgFitClass members as its fields.  NOTE:  the fpgFitClass constructor does not do
%    any field checking; it is assumed that fpgFitClass will be called by the fpgDataClass
%    method fpg_data_reformat, which knows better than to call fpgDataClass with
%    inadequate fields in its data structure argument.
%
% Version date:  2008-April-23.
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
%     2009-April-23, PT:
%         add support for pincushion parameter.
%     2008-December-18, PT:
%         fix typo -- parValueCovariance, not ParValueCovariance -- which was causing the
%         fit covariance matrix to get wiped out on instantiation if it was supplied in
%         fpgFitClassArgument (how embarrassing).
%     2008-September-19, PT:
%         make raDec2PixObject one-based.
%     2008-July-18, PT:
%         add support for user-specified pointing for reference cadence.
%     2008-July-03, PT:
%         add capability to return blank object if nargin == 0 (useful for instantiating a
%         vector of fpgFitClass objects).
%
%=========================================================================================

% start with a list of fields in the order we ultimately want them in:

  fpgFitClassMembers = {'raDec2PixObject','mjd','geometryParMap','fitGeometryFlag',...
      'plateScaleParMap','cadenceRAMap','cadenceDecMap','cadenceRollMap',...
      'pointingRefCadence','pincushionScaleFactor','nConstraintPoints','constraintPoints', ...
      'ccdsForPointingConstraint','constraintPointCovariance','initialParValues', ...
      'finalParValues','parValueCovariance','raDecModOut','robustWeights','chisq',...
      'ndof','fitterOptions'} ;
  
% if no input argument, get a blank structure with the correct fields

  if (nargin == 0)
      fpgFitClassArgument = get_blank_fpgFitClass_structure( fpgFitClassMembers ) ;
      blankStructure = true ;
  else
      blankStructure = false ;
  end

% if the argument is a structure, use it to instantiate the class

  if (isa(fpgFitClassArgument,'struct'))
      
%     Now, if we just created this structure in the lines above, then we don't want or
%     need to do all this examination of the fields; so do the checkout below only for a
%     structure passed by the caller

      if (~blankStructure)
      
%         if the fields which are related to the results of the fit are missing, add them
%         to the structure before instantiating

          if (~isfield(fpgFitClassArgument,'finalParValues'))
              fpgFitClassArgument.finalParValues = [] ;
          end
          if (~isfield(fpgFitClassArgument,'parValueCovariance'))
              fpgFitClassArgument.parValueCovariance = [] ;
          end
          if (~isfield(fpgFitClassArgument,'robustWeights'))
              fpgFitClassArgument.robustWeights = [] ;
          end
          if (~isfield(fpgFitClassArgument,'chisq'))
              fpgFitClassArgument.chisq = [] ;
          end
          if (~isfield(fpgFitClassArgument,'ndof'))
              fpgFitClassArgument.ndof = [] ;
          end

%         set the value of the fitGeometryFlag -- if any geometry parameters are included
%         in the fit, then the fitGeometryFlag must be set true, otherwise false

          if (length(find(fpgFitClassArgument.geometryParMap ~= 0)) ~= 0)
              fpgFitClassArgument.fitGeometryFlag = 1 ;
          else
              fpgFitClassArgument.fitGeometryFlag = 0 ;
          end
      
%         Matlab sometimes has the nasty habit of transforming raDec2PixClass objects back
%         to structs.  If it has done so on the one in fpgFitClassObject, transform it
%         back.

          if (isa(fpgFitClassArgument.raDec2PixObject,'struct'))
              fpgFitClassArgument.raDec2PixObject = raDec2PixClass(...
                  fpgFitClassArgument.raDec2PixObject, 'one-based') ;
          end
      
%         put the fields into the correct order

          fpgFitClassArgument = orderfields(fpgFitClassArgument,fpgFitClassMembers) ;
          
      end % blankStructure conditional
      
%     instantiate the object

      fpgFitClassObject = class(fpgFitClassArgument,'fpgFitClass') ;

% if the argument is already an fpgFitClass object, return it as the return value
      
  elseif (isa(fpgFitClassArgument,'fpgFitClass'))      
      fpgFitClassObject = fpgFitClassArgument ;

  end
  
% and that's it!

%
%
%

%=========================================================================================

% function to return a structure with the fields of the fpgFitClass, but no values
      
function fpgFitClassArgument = get_blank_fpgFitClass_structure( fpgFitClassMembers ) 

% loop over the member names and add them as blank fields to the argument

  for iMember = 1:length(fpgFitClassMembers)
      fpgFitClassArgument.(fpgFitClassMembers{iMember}) = [] ;
  end
  
% and that's it!

%
%
%