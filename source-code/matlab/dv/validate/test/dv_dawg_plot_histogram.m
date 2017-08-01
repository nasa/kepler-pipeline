function dv_dawg_plot_histogram( dvDawgStruct, fieldName, snrCutoff, ...
    topTitle, xLabel, filenameBase, upperLimit, showOverflow )
%
% dv_dawg_plot_histogram( dvDawgStruct, fieldName, snrCutoff )
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

  if exist( 'filenameBase', 'var' )
      filenameFig = [filenameBase,'.fig'] ;
      filenamePng = [filenameBase,'.png'] ;
  else
      filenameFig = '' ;
      filenamePng = '' ;
  end

  if ~exist( 'showOverflow', 'var' ) || isempty( showOverflow )
      showOverflow = true ;
  end

% get the field of interest out of the ntuple, and the SNR vector

  plotValues = [ dvDawgStruct.(fieldName) ] ;
  snr = [ dvDawgStruct.transitDepthSigmas ] ;
  
% plot the upper plot, which histograms all good values

  goodPlotValues = plotValues( plotValues >= 0 ) ;
  
  figure ; subplot(2,1,1) 
  if exist( 'upperLimit', 'var') && ~isempty( upperLimit )
      if ~showOverflow
          goodPlotValues = goodPlotValues( goodPlotValues <= upperLimit ) ;
      end
      hist( goodPlotValues, get_bin_centers( goodPlotValues, upperLimit ) ) ;
      yLimit = get( gca, 'ylim' ) ;
      axis([0 upperLimit yLimit(1) yLimit(2)]) ;
  else
      hist( goodPlotValues, 2 * round( sqrt( length( goodPlotValues ) ) ) ) ;
  end
  title( {topTitle, 'All Successful Fits'} ) ;
  
% now plot the ones which correspond to good SNR

  reallyGoodPlotValues = plotValues( plotValues >= 0 & snr >= snrCutoff ) ;
  subplot(2,1,2) ;
  if exist( 'upperLimit', 'var') && ~isempty( upperLimit )
      if ~showOverflow
          reallyGoodPlotValues = reallyGoodPlotValues( reallyGoodPlotValues <= upperLimit ) ;
      end
      hist( reallyGoodPlotValues, get_bin_centers( reallyGoodPlotValues, upperLimit ) ) ;
      yLimit = get( gca, 'ylim' ) ;
      axis([0 upperLimit yLimit(1) yLimit(2)]) ;
  else
      hist( reallyGoodPlotValues, 2 * round( sqrt( length( reallyGoodPlotValues ) ) ) ) ;
  end
  title( ['All Fits With SNR > ', num2str(snrCutoff)] ) ;
  xlabel( xLabel ) ;
  
% save the figure if so desired

  if ~isempty( filenameFig )
      saveas( gcf, filenameFig ) ;
  end
  if ~isempty( filenamePng )
      saveas( gcf, filenamePng ) ;
  end

return

%=========================================================================================

% bin center location subfunction

function binCenterVector = get_bin_centers( dataVector, upperLimit )

  nBins = 2*round(sqrt(length(dataVector))) ;
  lowerLimit = 0 ;
  binEdges = linspace( lowerLimit, upperLimit, nBins+1 ) ;
  binWidth = binEdges(2) - binEdges(1) ;
  binCenterVector = binEdges + binWidth/2 ;
  binCenterVector = binCenterVector(1:nBins) ;
  
return