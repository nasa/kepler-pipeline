function plot_fpg_residuals_quiver( fitterArgs, constraintPoints, modelPars )
%
% PLOT_FPG_RESIDUALS_QUIVER -- plot the residuals from an FPG fit as a quiver plot.
%
% plot_fpg_residuals_quiver( fitterArgs, constraintPoints, modelPars ) plots the fit
%    residuals over the full FOV.  The reference cadence is used for the plot.
%
% Version date:  2008-May-29.
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
%     2008-May-29, PT:
%         restructured to plot the full 42-ccd quiver plot in Z'-Y' space.
%
%=========================================================================================

% get the residuals vectors

  [dRow, dCol, dRadius, dAngle] = get_fpg_residuals( constraintPoints, fitterArgs, modelPars ) ;
  
% use the unscramble_fpg_constraint_points function to determine the mod, out, and cadence
% of each constraint point

  [mod, out, rowPointer, colPointer, cadence] = unscramble_fpg_constraint_points( fitterArgs ) ;
  
% find the data points in constraintPoints which are on the correct cadence for the plot,
% based on the outputs of the unscramble function

  pointsOnCadence1 = find(cadence == 1) ;
  
% get the mod, out, row, column for points on the desired cadence

  mod = mod(pointsOnCadence1) ;
  out = out(pointsOnCadence1) ;
  row = constraintPoints(rowPointer(pointsOnCadence1)) ;
  col = constraintPoints(colPointer(pointsOnCadence1)) ;
                
% get the appropriate residuals from the residuals structures.  The residuals structures
% don't include cadence information, but the reference cadence is first in these
% structures, and the returns from the unscramble function allow us to figure out how many
% points in each mod/out on cadence 1, so that we can go to each mod/out of interest and
% get the first N points, once we know N.  A further refinement is that, since residual =
% constraint value - model value, we want to reverse the sign of the residuals for the
% quiver plot.  

  rowQuiver = [] ; colQuiver = [] ;
  iChannel = 0 ;
  for iMod = [2:4,6:20,22:24]
      for iOut = 1:4
          iChannel = iChannel + 1 ;
          nPoints = length(find(mod==iMod & out == iOut)) ;
          rowQuiver = [rowQuiver ; -dRow(iChannel).residuals(1:nPoints)] ;
          colQuiver = [colQuiver ; -dCol(iChannel).residuals(1:nPoints)] ;
      end
  end
  
% convert the row and column constraint points, row and column residuals to Z and Y, dZ
% and dY

  [Z,Y]   = morc_to_focal_plane_coords( mod, out, row, col ) ;
  [dZ,dY] = morc_to_focal_plane_coords( mod, out, rowQuiver, colQuiver, 1 ) ;
  
% and now, without further ado, display the quiver plot

  figure ;
  draw_ccd(1:42) ;
  hold on
  quiver(Z,Y,dZ,dY) ;

  hold off ;

  return
  
%=========================================================================================
%=========================================================================================
%=========================================================================================



function plot_fpg_residuals_quiver_orig( fitterArgs, constraintPoints, modelPars, ccdNum )

% get the residuals vectors

  [dRow, dCol, dRadius, dAngle] = get_fpg_residuals( constraintPoints, fitterArgs, modelPars ) ;
  
% use the unscramble_fpg_constraint_points function to determine the mod, out, and cadence
% of each constraint point

  [mod, out, rowPointer, colPointer, cadence] = unscramble_fpg_constraint_points( fitterArgs ) ;
  
% get the mod and out #'s which correspond to the desired CCD number -- we do this in a
% somewhat indirect way, by converting the CCD # to the corresponding 2 channel numbers on
% the CCD, and then using convert_to_module_output.

  channels = [2*ccdNum-1 ; 2*ccdNum ;] ;
  [userMod, userOut] = convert_to_module_output( channels ) ;

% find the data points in constraintPoints which are on the correct mod, out, and cadence
% for the plot, based on the outputs of the unscramble function

  points1 = find( (mod == userMod(1)) & (out == userOut(1)) & cadence == 1 ) ;
  points2 = find( (mod == userMod(2)) & (out == userOut(2)) & cadence == 1 ) ;
  
% get the appropriate values from constraintPoint -- these are the points on the CCD.  In
% the case of the column values, convert them to the CCD coordinate system from the
% mod/out coordinate system.

  rowConstraintPoints = [constraintPoints(rowPointer(points1)) ; ...
                         constraintPoints(rowPointer(points2))] ;
  colConstraintPoints = [convert_to_ccd_column(out(points1),...
      constraintPoints(colPointer(points1))) ; ...
                         convert_to_ccd_column(out(points2),...
      constraintPoints(colPointer(points2))) ] ;
                     
% get the appropriate residuals from the residuals structures.  The residuals structures
% don't include cadence information, but the reference cadence is first in these
% structures, and the returns from the unscramble function allow us to figure out how many
% points in each mod/out on cadence 1, so that we can go to each mod/out of interest and
% get the first N points, once we know N.  A further refinement is that, since residual =
% constraint value - model value, we want to reverse the sign of the residuals for the
% quiver plot.  A final refinement is that the columns on the 2nd channel of the CCD have
% the opposite sign as on the mod/out, so we need to reverse the sign of the column
% residuals on channel 2 twice!

  nPoints1 = length(points1) ; nPoints2 = length(points2) ;
  
  rowQuiver = [ -dRow(channels(1)).residuals(1:nPoints1) ; ...
                -dRow(channels(2)).residuals(1:nPoints2) ] ;
  colQuiver = [ -dCol(channels(1)).residuals(1:nPoints1) ; ...
                 dCol(channels(2)).residuals(1:nPoints2) ] ;
             
% and now, without further ado, display the quiver plot

  figure ;
  quiver(colConstraintPoints,rowConstraintPoints,colQuiver,rowQuiver) ;

% as an aid to the people, draw a box showing the CCD perimeter and the dividing line
% between the two mod/outs

  hold on
  cornerRows = [0 ; 0 ; 1043 ; 1043] ; cornerCols = [0 ; 2225 ; 2225 ; 0] ;
  k = convhull(cornerCols,cornerRows) ;
  plot(cornerCols(k),cornerRows(k),'k--') ;
  plot([1112.5 1112.5],[0 1043],'k--') ;
  plot(colConstraintPoints,rowConstraintPoints,'o') ;
  title(['Sample Residuals Quiver Plot -- CCD ',num2str(ccdNum)]) ;
  xlabel('columns') ; ylabel('rows') ;
  hold off ;