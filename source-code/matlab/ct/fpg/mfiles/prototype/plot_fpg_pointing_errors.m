function plot_fpg_pointing_errors( dPointingDesign, finalPars, fitterArgs, covariance )
%
% PLOT_FPG_POINTING_ERRORS -- produce a graphical representation of the fitted pointing
% errors for non-reference cadences in FPG.
%
% plot_fpg_pointing_errors( dPointingDesign, finalPars, fitterArgs, covariance ) produces 
%    a plot of the pointing errors for non-reference cadences determined by the FPG fit.
%    Two types of plots are produced:  a quiver plot of the errors in (RA,Dec) space, and
%    a plot of the fitted pointing errors and their uncertainties.
%
% Version date:  2008-May-30.
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

% get the initial and final RA, Dec, and Roll parameters

  RAPointer   = fitterArgs.cadenceRAMap(   find(fitterArgs.cadenceRAMap   ~= 0) ) ;
  DecPointer  = fitterArgs.cadenceDecMap(  find(fitterArgs.cadenceDecMap  ~= 0) ) ;
  RollPointer = fitterArgs.cadenceRollMap( find(fitterArgs.cadenceRollMap ~= 0) ) ;
  
  RAInitialValues   = dPointingDesign(1,:) ;
  DecInitialValues  = dPointingDesign(2,:) ;
  RollInitialValues = dPointingDesign(3,:) ;
  
  RAFinalValues   = finalPars(RAPointer) ;
  DecFinalValues  = finalPars(DecPointer) ;
  RollFinalValues = finalPars(RollPointer) ;
  
  [RAScaleFactor,RAPrefix]   = get_engineering_notation_scaling( RAInitialValues  ) ;
  [DecScaleFactor,DecPrefix] = get_engineering_notation_scaling( DecInitialValues ) ;
  
  dRA   = RAFinalValues'   - RAInitialValues ;
  dDec  = DecFinalValues'  - DecInitialValues ;
  dRoll = RollFinalValues' - RollInitialValues ;
 
% start with the quiver plot

  figure ;
  plot(RAScaleFactor*RAInitialValues,DecScaleFactor*DecInitialValues,'o') ;
  hold on
  quiver(RAScaleFactor*RAInitialValues,DecScaleFactor*DecInitialValues, ...
      RAScaleFactor*dRA, DecScaleFactor*dDec) ;
  xlabel(['RA [',RAPrefix,'^{\circ}]']) ;
  ylabel(['Dec [',RAPrefix,'^{\circ}]']) ;
  hold off
  
% now to plot the fitted change in RA, Dec, Roll and the error bars on a separate display

  sigma = sqrt(diag(covariance)) ;
  sigmaRA   = sigma(1:3:length(sigma)) ;
  sigmaDec  = sigma(2:3:length(sigma)) ;
  sigmaRoll = sigma(3:3:length(sigma)) ;
  
  figure ;
  
  subplot(3,2,1) 
  [ScaleFactor,Prefix] = get_engineering_notation_scaling( dRA  ) ;
  errorbar(1:length(dRA),ScaleFactor*dRA,ScaleFactor*sigmaRA,ScaleFactor*sigmaRA,'o') ;
  ylabel(['RA Error [',Prefix,'^{\circ}]']) ;
  
  subplot(3,2,3) 
  [ScaleFactor,Prefix] = get_engineering_notation_scaling( dDec  ) ;
  errorbar(1:length(dDec),ScaleFactor*dDec,ScaleFactor*sigmaDec,ScaleFactor*sigmaDec,'o') ;
  ylabel(['Dec Error [',Prefix,'^{\circ}]']) ;
    
  subplot(3,2,5) 
  [ScaleFactor,Prefix] = get_engineering_notation_scaling( dRoll  ) ;
  errorbar(1:length(dRoll),ScaleFactor*dRoll,ScaleFactor*sigmaRoll,ScaleFactor*sigmaRoll,'o') ;
  ylabel(['Roll Error [',Prefix,'^{\circ}]']) ;
    
  subplot(3,2,2) 
  [ScaleFactor,Prefix] = get_engineering_notation_scaling( sigmaRA  ) ;
  bar(ScaleFactor*sigmaRA) ;
  ylabel(['\sigma_{RA} [',Prefix,'^{\circ}]']) ;
  
  subplot(3,2,4) 
  [ScaleFactor,Prefix] = get_engineering_notation_scaling( sigmaDec  ) ;
  bar(ScaleFactor*sigmaDec) ;
  ylabel(['\sigma_{Dec} [',Prefix,'^{\circ}]']) ;

  subplot(3,2,6) 
  [ScaleFactor,Prefix] = get_engineering_notation_scaling( sigmaRoll  ) ;
  bar(ScaleFactor*sigmaRoll) ;
  ylabel(['\sigma_{Roll} [',Prefix,'^{\circ}]']) ;

