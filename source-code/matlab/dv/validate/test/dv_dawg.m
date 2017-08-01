
% script to DAWG a large set of DV results structures 
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

% set some global definitions

  topDir = '/path/to/pipeline_results/science_q2/TEST-release6.1-tps-dv' ;
  

%%  
  
% define the structure

  dvDawgStruct = [] ; 
  
% get the list of dv directories in the top dir

  dvDirList = dir([topDir, filesep, 'dv-matlab-*']) ;
  
% start the mission
  
  t00 = clock ;
  for iDir = 1:length(dvDirList)
      
      dirName = dvDirList(iDir).name ;
      t0 = clock ;
      disp( [ datestr(t0), '  ', dirName, '  ', num2str(iDir), '  ' ] ) ;
      if exist( fullfile( topDir, dirName, 'dv-outputs-0.mat' ), 'file' )
          load( fullfile( topDir, dirName,  'dv-outputs-0' ) ) ;
      
          newPlanetResults = dv_dawg_kernel( outputsStruct ) ;
      
          dvDawgStruct = [dvDawgStruct ; newPlanetResults(:)] ;
          
          clear outputsStruct ;
          
      end
      
      
  end % loop over directories
  
  disp(' ') ;
  t0 = clock ;
  disp([datestr(t0), '  Done!  ', num2str(length(dvDawgStruct) )]) ;
  
%%
 
% do some more cleanup and some plotting

  clear newPlanetResults dvDirList iDir t0 t00 ;
 
  nFits = length( dvDawgStruct ) ;
  figure ; hist( [dvDawgStruct.transitDepthSigmas], 2*round(sqrt(nFits)) ) ;
  title( 'DV Fit SNR Distribution' ) ;
  xlabel('SNR') ;
  saveas( gcf, 'transit-fit-snr.fig' ) ;
  saveas( gcf, 'transit-fit-snr.png' ) ;
  
  transitDepthSigmas = [dvDawgStruct.transitDepthSigmas] ;
  transitDepthLowResolution = transitDepthSigmas( find( transitDepthSigmas < 10 ) ) ;
  nLowRes = length(transitDepthLowResolution) ;
  
  figure ; hist( transitDepthLowResolution, 2*round(sqrt(nLowRes)) ) ;
  title( 'DV Fit SNR Distribution, SNR <= 10' ) ;
  xlabel('SNR') ;
  saveas( gcf, 'transit-fit-snr-10-or-less.fig' ) ;
  saveas( gcf, 'transit-fit-snr-10-or-less.png' ) ;
  
  
%%

% set the cutoff based on the results of the low-resolution plot

  snrCutoff = 4.5 ;
  goodFits = [dvDawgStruct.transitDepthSigmas] > snrCutoff ;
  nGoodFits = length( find ( goodFits ) ) ;
  
%%  
  
% perform the plots

  dv_dawg_plot_histogram( dvDawgStruct, 'transitDepth', snrCutoff,  ...
      'Transit Depth Distribution', 'Transit Depth [PPM]', ...
      'transit-depth-distribution' ) ;
  
  dv_dawg_plot_histogram( dvDawgStruct, 'transitDepth', snrCutoff, ...
      'Transit Depth Distribution (Transits<=1%)', 'Transit Depth [PPM]', ...
      'transit-depth-distribution-1-percent', 10000, false ) ;
 
  dv_dawg_plot_histogram( dvDawgStruct, 'transitDepth', snrCutoff, ...
      'Transit Depth Distribution (Transits<=0.1%)', 'Transit Depth [PPM]', ...
      'transit-depth-distribution-0p1-percent', 1000, false ) ;
  
  dv_dawg_plot_histogram( dvDawgStruct, 'radiusRatio', snrCutoff, ...
      'Planet / Star Radius Ratio [Earth/Sun == 1]', 'Radius Ratio [Earth/Sun]', ...
      'radius-ratio' ) ;
  
  dv_dawg_plot_histogram( dvDawgStruct, 'prfSignificance', snrCutoff, ...
      'PRF Centroid Significance', 'Significance', ...
      'prf-centroid-test-significance' ) ;
 
  dv_dawg_plot_histogram( dvDawgStruct, 'fluxSignificance', snrCutoff, ...
      'Flux-Weighted Centroid Significance', 'Significance', ...
      'flux-weighted-centroid-test-significance' ) ;

  dv_dawg_plot_histogram( dvDawgStruct, 'depthSignificance', snrCutoff, ...
      'Depth Test Significance', 'Significance', ...
      'depth-test-significance' ) ;

  dv_dawg_plot_histogram( dvDawgStruct, 'epochSignificance', snrCutoff, ...
      'Epoch Test Significance', 'Significance', ...
      'epoch-test-significance' ) ;

  dv_dawg_plot_histogram( dvDawgStruct, 'periodSignificance', snrCutoff, ...
      'Period Test Significance', 'Significance', ...
      'period-test-significance' ) ;

%%

% perform the bootstrap plot

  multipleEventStatistic = [dvDawgStruct.multipleEventStatistic] ;
  falseAlarmRate = [dvDawgStruct.falseAlarmRate] ;
  goodFalseAlarmRate = falseAlarmRate > 0 ;
  nBootstrap = length( find( goodFalseAlarmRate ) ) ;
  nBootStrapGoodSnr = length( find( goodFalseAlarmRate & goodFits ) ) ;
  
  figure ;
  loglog( multipleEventStatistic(goodFalseAlarmRate & ~goodFits), ...
      falseAlarmRate(goodFalseAlarmRate & ~goodFits), 'b.' ) ;
  hold on
  loglog( multipleEventStatistic(goodFalseAlarmRate & goodFits), ...
      falseAlarmRate(goodFalseAlarmRate & goodFits), 'g.' ) ;
  multipleEventStatisticVector = linspace(0,10.5,106) ;
  loglog( multipleEventStatisticVector, 0.5*erfc( multipleEventStatisticVector/sqrt(2) ) , ...
      'r' ) ;
  title( 'TPS Multiple Event Statistic vs. DV Bootstrap False Alarm Rate' ) ;
  xlabel( 'Multiple Event Statistic [\sigma]' ) ;
  ylabel( 'False Alarm Rate' ) ; 
  legend( ['Fit SNR < ', num2str(snrCutoff)], ...
      ['Fit SNR > ', num2str(snrCutoff)], ...
      'Gaussian' ) ;
  saveas( gcf, 'mes-bootstrap-scatter.fig' ) ;
  saveas( gcf, 'mes-bootstrap-scatter.png' ) ;
  