function figureHandle = plot_fpg_residuals_quiver( fpgResultsObject, useInitial )
%
% plot_fpg_residuals_quiver -- fpgResultsClass method which plots the fit residuals,
% either before or after fitting, as a quiver plot.
%
% figureHandle = plot_fpg_residuals_quiver( fpgResultsObject ) plots the post-fitting
%    residuals as a quiver plot.
%
% figureHandle = plot_fpg_residuals_quiver( fpgResultsObject, useInitial ) plots either
%    the post-fitting or the pre-fitting residuals as a quiver plot; if useInitial is
%    true, the pre-fitting values are used, while if it is false the post-fitting values
%    are used.
%
% Version date:  2008-September-19.
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
%     2008-September-19:
%         update morc_to_focal_plane_coords call.
%
%=========================================================================================

% set useInitial if it is absent (set to false)

  if (nargin == 1)
      useInitial = false ;
  end
  
% get the initial or final parameter model to use  
  
  if (useInitial)
      parameters = get(fpgResultsObject.fpgFitClass,'initialParValues') ;
  else
      parameters = get(fpgResultsObject.fpgFitClass,'finalParValues') ;
  end
  
% get the residuals vector

  modelValues = model_function( fpgResultsObject.fpgFitClass, parameters ) ;
  constraintPoints = get(fpgResultsObject.fpgFitClass, 'constraintPoints') ;
  residuals = constraintPoints - modelValues ;
  
% eliminate all except the residuals and constraint point values on the reference cadence

  raDecModOut = get(fpgResultsObject.fpgFitClass, 'raDecModOut') ;
  nConstraintsRefCadence = size(raDecModOut(1).matrix,1) ;
  residuals = residuals(1:2*nConstraintsRefCadence) ;
  constraintPoints = constraintPoints(1:2*nConstraintsRefCadence) ;
  
% convert the constraint point and residual information into row, column (or dRow,
% dColumn); reverse the sign of the residuals, since we want the quivers to point in the
% direction the CCDs need to move, relative to their positions in the model

  row  =  constraintPoints(1:nConstraintsRefCadence) ;
  col  =  constraintPoints(nConstraintsRefCadence+1:2*nConstraintsRefCadence) ;
  dRow = -residuals(1:nConstraintsRefCadence) ;
  dCol = -residuals(nConstraintsRefCadence+1:2*nConstraintsRefCadence) ;
  
% get module and output information out of raDecModOut

  mod = raDecModOut(1).matrix(:,3) ;
  out = raDecModOut(1).matrix(:,4) ;
  
% convert the information to coordinates and quivers in the FOV coordinate system
  
  [Z,Y]   = morc_to_focal_plane_coords( mod, out, row, col, 'one-based' ) ;
  [dZ,dY] = morc_to_focal_plane_coords( mod, out, dRow, dCol, 'one-based', 1 ) ;
  
% we need to add scale information to the plot:  we'll do this by adding a quiver in a
% location where there are no CCDs, which is equal to the longest quiver in the display

  maxQuiverLength = max(sqrt(dZ.^2 + dY.^2)) ;
  
  [scaleFactor,prefixString] = get_engineering_notation_scaling( maxQuiverLength ) ;
  
  Z = [Z(:) ; 5000] ;
  Y = [Y(:) ; 5000] ;
  dZ = [dZ(:) ; 0] ;
  dY = [dY(:) ; maxQuiverLength] ;
  
% plot the quiver plot

  figure ;
  draw_ccd(1:42) ;
  hold on
  quiver(Z,Y,dZ,dY) ;

  hold off ;
  
  scaleMsg = [' = ',num2str(maxQuiverLength*scaleFactor,2),' ',prefixString,'pixels'] ;
  text(5000,6000,'Scale:') ;
  text(5100,5500,scaleMsg) ;
  
% add a title

  if (useInitial)
      title('FPG Fit Residuals Quiver -- BEFORE Fitting') ;
  else
      title('FPG Fit Residuals Quiver -- AFTER Fitting') ;
  end

  figureHandle = gcf ; 
  
% and that's it!

%
%
%

