function [scatterHandle, fitValueHandle] = plot_fpg_pointing( fpgResultsObject )
%
% plot_fpg_pointing -- plot the fitted pointings of cadences used in FPG fitting.
% 
% [scatterHandle, fitValueHandle] = plot_fpg_pointing( fpgResultsObject ) returns the
%    figure handles for the scatter plot and fitted values plot of the pointing of the
%    cadences used in FPG fitting.  The pointing of the reference cadence is shown as a
%    red dot at (0,0,0).
%
% Version date:  2008-july-31.
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
%    2008-July-31, PT:
%        support for fit of the attitude on the reference cadence.
%    2008-July-23, PT:
%        bugfix to get the correct units on the second plot.
%
%=========================================================================================

  scatterHandle = [] ;
  fitValueHandle = [] ;
  
% if there was only one cadence, and we did not fit its pointing, we can simply exit now!

  fpgFitObject = get(fpgResultsObject,'fpgFitClass') ;
  raDecModOut = get(fpgFitObject,'raDecModOut') ;
  ccdsForPointingConstraint = get(fpgFitObject,'ccdsForPointingConstraint') ;
  if (isempty(ccdsForPointingConstraint))
      fitPointingRefCadence = false ;
  else
      fitPointingRefCadence = true ;
  end
  
  if ( (length(raDecModOut) == 1) && (~fitPointingRefCadence) )
      return ;
  end

% get the parameter maps, thence the parameters

  raMap = get(fpgFitObject,'cadenceRAMap') ;
  decMap = get(fpgFitObject,'cadenceDecMap') ;
  rollMap = get(fpgFitObject,'cadenceRollMap') ;
  raMap = raMap(find(raMap ~= 0)) ; decMap = decMap(find(decMap ~= 0)) ;
  rollMap = rollMap(find(rollMap~=0)) ;
  
  finalParValues = get(fpgFitObject,'finalParValues') ;
  parValueCovariance = get(fpgFitObject,'parValueCovariance') ;
  
  ra = finalParValues(raMap) ;
  dec = finalParValues(decMap) ;
  roll = finalParValues(rollMap) ;
  
% plot the parameters as a scatter plot 
  
  figure ; plot(ra*3600,dec*3600,'o') ;
  
% if the reference cadence pointing wasn't fitted, put it in as a red dot at (0,0)  
  
  if (~fitPointingRefCadence)
      hold on
      plot(0,0,'r.') ;
      hold off
  end
  
% finish the plot  
  
  scatterHandle = gcf ;
  xlabel('RA [arcsec]') ;
  ylabel('Dec [arcsec]') ;
  title('Fitted Pointings of FPG Cadences') ;
  
% to use plot_fpg_fit_results, we need to format the data:  put the data in the format 
%     [ra1 ; dec1 ; roll1 ; ra2 ; dec2 ; roll2 ; etc]
% and get the covariance matrix as well.  Also, we need a parameter map, and that map
% may need to include unfitted parameter slots for the reference cadence.
  
  figure ;  
  pointing = [3600*ra(:)' ; 3600*dec(:)' ; roll(:)'] ;
  pointing = pointing(:) ;
  pointingMinIndex = min(raMap) ; pointingMaxIndex = max(rollMap) ;
  pointingCovariance = diag(parValueCovariance(pointingMinIndex:pointingMaxIndex, ...
                                                    pointingMinIndex:pointingMaxIndex)) ;
  raMap = raMap - pointingMinIndex + 1 ;
  decMap = decMap - pointingMinIndex + 1 ;
  pointingCovariance(raMap) = pointingCovariance(raMap) * 3600 * 3600 ;
  pointingCovariance(decMap) = pointingCovariance(decMap) * 3600 * 3600 ;
  pointingCovariance = diag(pointingCovariance) ;
  
  pointingParMap = 1:length(pointing) ;
  
% if the ref cadence pointing was not fitted, put in zeroed-out slots for it in the map  
  
  if ( ~fitPointingRefCadence )
     pointingParMap = [0 ; 0 ; 0 ; pointingParMap(:)] ;
  end
  
  prefixStrings = plot_fpg_fit_results( pointingParMap, pointing , pointingCovariance ) ;
  
% apply labels where appropriate

  subplot(3,2,1) 
  title('FPG Cadence Pointing Fits')
  ylabel(['RA [',prefixStrings{1,1},'arcsec]']) ;
  subplot(3,2,3) 
  ylabel(['Dec [',prefixStrings{2,1},'arcsec]']) ;
  subplot(3,2,5) 
  ylabel(['Roll [',prefixStrings{3,1},'{\bf{DEGREES}}]']) ;
  xlabel('Cadence #') ;
  
  subplot(3,2,2)
  title('FPG Cadence Pointing Fits')
  ylabel(['RA [',prefixStrings{1,2},'arcsec]']) ;
  subplot(3,2,4) 
  ylabel(['Dec [',prefixStrings{2,2},'arcsec]']) ;
  subplot(3,2,6) 
  ylabel(['Roll [',prefixStrings{3,2},'{\bf{DEGREES}}]']) ;
  xlabel('Cadence #') ;

  fitValueHandle = gcf ;  
  
% and that's it!

%
%
%
  
