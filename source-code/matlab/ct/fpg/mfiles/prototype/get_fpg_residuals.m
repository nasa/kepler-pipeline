function [dRow,dCol,dRadius,dAngle] = get_fpg_residuals( constraintPoints, fitterArgs, ...
                   parameters, covariance ) 
%
% GET_FPG_RESIDUALS -- get the residuals from focal plane geometry alignment, organized by
% module and output
%
% [dRow, dCol, dRadius, dAngle] = get_fpg_residuals( constraintPoints, fitterArgs,
%    parameters] returns the fit residuals obtained from FPG, using the focal plane
%    geometry parameters stored in the parameters argument.  The return variables are
%    organized as data structures, with fields mod, out, and residuals:
%    dRow(iChannel).mod is the module #, dRow(iChannel).out is the output number, and
%    dRow(iChannel).residuals is the residuals vector for channel # iChannel.
%
% [...] = get_fpg_residuals( ..., covariance ) normalizes the residuals to the estimated
%    error on each point.
%
% Version date:  2008-may-27.
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
%    2008-may-27, PT:
%        separate unscramble_morc into a separate function with a new name, so that other
%        graphics routines can use it if necessary.
%
%=========================================================================================

% dimension the arguments based on the Kepler geometry parameters

  import gov.nasa.kepler.common.FcConstants ;
  nChannels = FcConstants.nModules * FcConstants.nOutputsPerModule ;

  dRow(nChannels).mod = 0 ;
  dRow(nChannels).out = 0 ;
  dRow(nChannels).residuals = [] ;
  
  dCol = dRow ;
  dRadius = dRow ;
  dAngle = dRow ;
  
% compute the residuals (this is the easy part!)

  modelValues = fpg_model_function( parameters, fitterArgs ) ;
  residuals = constraintPoints - modelValues ;
  if (nargin == 4)
      sigma2Vector = diag(covariance) ;
  end
  
% get pointers which show which of the residuals are rows, and which are columns ; while
% we're at it, get the module and output of each data point

  [mod, out, rowPointer, colPointer] = unscramble_fpg_constraint_points( fitterArgs ) ;
  
% loop over channels

  for iChannel = 1:nChannels
      
%     convert the channel # to module and output

      [thisMod, thisOut] = convert_to_module_output( iChannel ) ;
      dRow(iChannel).mod = thisMod ;
      dRow(iChannel).out = thisOut ;
      dCol(iChannel).mod = thisMod ;
      dCol(iChannel).out = thisOut ;
      dRadius(iChannel).mod = thisMod ;
      dRadius(iChannel).out = thisOut ;
      dAngle(iChannel).mod = thisMod ;
      dAngle(iChannel).out = thisOut ;
      
%     find all the points which are on that mod/out

      points = find( (mod == thisMod) & (out == thisOut) ) ;
      rowPoints = rowPointer(points) ; 
      colPoints = colPointer(points) ;
      
%     populate the row and column residuals

      dRow(iChannel).residuals = residuals(rowPoints) ;
      dCol(iChannel).residuals = residuals(colPoints) ;
      
%     populate the radius and angle residuals -- this requires converting each row and
%     column into radius and angle, which in turn means that we first need to convert each
%     row and column to be centered at the center of the mod/out rather than the readout.
%     TODO:  figure out if these are the correct offsets to use!

      rowActual = constraintPoints(rowPoints) - 512 ;
      rowModel  = modelValues(rowPoints) - 512 ;
      colActual = constraintPoints(colPoints) - 556 ;
      colModel  = modelValues(colPoints) - 556 ;

      [angleActual, radiusActual] = cart2pol(rowActual, colActual) ;
      [angleModel,  radiusModel]  = cart2pol(rowModel,  colModel ) ;
      
      dRadius(iChannel).residuals = radiusActual - radiusModel ;
      dAngle(iChannel).residuals  = angleActual - angleModel ;
      
%     now for normalizing by the errors, if so desired.  The rows and columns are easy...

      if (nargin == 4)
          
          dRow(iChannel).residuals = dRow(iChannel).residuals ...
              ./ sqrt(sigma2Vector(rowPoints)) ;
          dCol(iChannel).residuals = dCol(iChannel).residuals ...
              ./ sqrt(sigma2Vector(colPoints)) ;
          
%         ... the angle and the radius, not so much ...

          radiusNonZero = find(radiusActual ~= 0) ;
          radiusZero    = find(radiusActual == 0) ;
          sigmaRadiusTimesRadiusSquared =rowActual.^2 ...
                                        .* sigma2Vector(rowPoints) ...
                                        + colActual.^2 ...
                                        .* sigma2Vector(colPoints) ;
          
%         if the radius is zero, estimate sigmaRadius as the quadrature sum of the row and
%         column uncertainty

          sigmaRadius = constraintPoints(rowPoints).^2 ...
                      + constraintPoints(colPoints).^2     ;
                  
%         If the radius is not zero, compute the sigRadius from the vector of (radius *
%         sigRadius).^2

          sigmaRadius(radiusNonZero) = sigmaRadiusTimesRadiusSquared(radiusNonZero) ...
                                     ./ radiusActual(radiusNonZero).^2 ;
          sigmaRadius = sqrt(sigmaRadius) ;                       
                              
          dRadius(iChannel).residuals = dRadius(iChannel).residuals ./ sigmaRadius ;
                                 
%         the angle uncertainty is even more fun -- if the radius is exactly zero, then
%         the angle and angle uncertainty are both zero, so the residual normalized by
%         uncertainty can be regarded as zero as well

          sigmaAngle = sqrt(sigmaRadiusTimesRadiusSquared) ;
          sigmaAngle(radiusNonZero) = sigmaAngle(radiusNonZero) ...
                                    ./ radiusActual(radiusNonZero).^2 ;
          dAngle(iChannel).residuals(radiusNonZero) ...
              = dAngle(iChannel).residuals(radiusNonZero) ...
              ./ sigmaAngle(radiusNonZero) ;
          
      else 
          
%         now, if we are not normalizing, then the angle must now be converted to degrees
%         from radians

          dAngle(iChannel).residuals = dAngle(iChannel).residuals * 180 / pi ;
          
      end % normalized residuals condition
      
  end % loop over mod/outs

  
  
% and that's it!

%
%
%

%=========================================================================================
