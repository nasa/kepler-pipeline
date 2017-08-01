function prefixStrings = plot_fpg_fit_results( geometryParMap, parValues, covariance )
%
% PLOT_FPG_FIT_RESULTS -- plot the results of a focal plane geometry fit.
%
% prefixStrings = plot_fpg_fit_results( fitterArgs, parValues, covariance ) produces a 
%    standardized plot of the results of the FPG fit.  The parValues are plotted with
%    error bars from the covariance matrix; parameters which are missing from the fit are
%    shown with red dots. The error bar sizes are also plotted in a separate set of bar
%    plots, since otherwise the error bars can be too small to be seen on the scale of the
%    plot.  The plotted data is converted via engineering notation, and the resulting
%    prefix strings are returned in the prefixStrings cell array.
%
% See also:  plot_321_angle_changes plot_fpg_dRow_dCol_dAngle.
%
% Version date:  2008-july-14.
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
%     2008-july-14, PT:
%          extend to vector lengths other than 126.
%     2008-july-09, PT:
%          created this function by copying function used in FPG prototype.
%
%=========================================================================================

  prefixStrings = cell(3,2) ;

% the order of the parameters in parValues is [CCD1Par1 ; CCD1Par2 ; CCD3Par3 ; CCD2Par1 ;
% etc.].  Set up indexing which extracts all the Par1's, all the Par2's, and all the
% Par3's.

  nParTotal = length(geometryParMap) ;

  indx1 = 1:3:nParTotal ; indx2 = 2:3:nParTotal ; indx3 = 3:3:nParTotal ;
  
% The parValues vector includes only the parameters which were fitted, but we want to have
% "slots" for all the values (including unfitted ones).  Set that up now.

  parValuesForPlotting = zeros(nParTotal,1) ;
  sigma2 = zeros(nParTotal,1) ;
  
  sigmaVector = diag(covariance) ; 
  
% figure out which of the parameters were fitted by examining the geometry map in
% fitterArgs
  
  nonZeroIndices = find(geometryParMap ~= 0) ;
  nonZeroValues = geometryParMap(nonZeroIndices) ;
  
% put the values in parValues and sigmaVector into the correct slots in
% parValuesForPlotting and sigma2

  parValuesForPlotting(nonZeroIndices) = parValues(nonZeroValues) ;
  sigma2(nonZeroIndices) = sigmaVector(nonZeroValues) ;
  
% produce the left side plots -- errorbar plots of the parameter values -- and return the
% prefix strings for the plots

  subplot(3,2,1) ;
  prefixStrings{1,1} = plot_result_value(parValuesForPlotting,sigma2,indx1) ;
  subplot(3,2,3) ;
  prefixStrings{2,1} = plot_result_value(parValuesForPlotting,sigma2,indx2) ;
  subplot(3,2,5) ;
  prefixStrings{3,1} = plot_result_value(parValuesForPlotting,sigma2,indx3) ;
  
% produce the right side plots -- bar chart of the error bar sizes -- and return the
% prefix strings for the plots

  subplot(3,2,2) ; 
  prefixStrings{1,2} = plot_result_uncertainty(sigma2,indx1) ;  
  subplot(3,2,4) ;
  prefixStrings{2,2} = plot_result_uncertainty(sigma2,indx2) ;  
  subplot(3,2,6) ;
  prefixStrings{3,2} = plot_result_uncertainty(sigma2,indx3) ;

% and that's it!

%
%
%

%=========================================================================================

% function which plots the values of the results, with error bars for fitted values and
% red dots where a missing fit point should be.

function prefixString = plot_result_value(parValues,sigma2,indx)

% first plot the parameters which were included in the fit:

  yAxis = parValues(indx) ; sigma = sqrt(sigma2(indx)) ;
  xAxis = 1:length(yAxis) ;

% first plot the parameters which were included in the fit, signified by nonzero 
% covariance:
  
  parsInFit = find(sigma ~= 0) ;
  
% find the scaling required to get into engineering notation

  [scaleFactor,prefixString] = get_engineering_notation_scaling( yAxis(parsInFit) ) ;
  yAxis = yAxis * scaleFactor ;
  sigma = sigma * scaleFactor ;
  
% do the plot
  
  errorbar(xAxis(parsInFit),yAxis(parsInFit),sigma(parsInFit),sigma(parsInFit),'o') ;
  
% now do the ones which were excluded as red dots

  parsOutOfFit = find(sigma == 0) ;
  hold on;
  plot(xAxis(parsOutOfFit),yAxis(parsOutOfFit),'r.') ;
  hold off ;

% and that's it!

%
%
%

%=========================================================================================

% function which produces a bar chart of the uncertainties in the FPG fit parameters

function prefixString = plot_result_uncertainty( sigma2, indx )

  yAxis = sqrt(sigma2(indx)) ;
  parsInFit = find(yAxis ~= 0) ;
  xAxis = 1:length(yAxis) ;

% find the scaling required to get into engineering notation

  [scaleFactor,prefixString] = get_engineering_notation_scaling( yAxis(parsInFit) ) ;
  yAxis = yAxis * scaleFactor ;

% make a bar graph of the uncertainties

  bar(xAxis(parsInFit),yAxis(parsInFit)) ;
  
% and that's it!

%
%
%

