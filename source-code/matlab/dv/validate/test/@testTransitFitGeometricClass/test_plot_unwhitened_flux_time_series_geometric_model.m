function self = test_plot_unwhitened_flux_time_series_geometric_model( self )
%
% test_plot_unwhitened_flux_time_series_geometric_model -- unit test for the plot_unwhitened_flux_time_series and plot_unwhitened_zoomed_flux_time_series methods
% of transitFitClass with geometric transit model
% 
%
% This unit test exercises the following functionality of the method:
%
% ==> Basic functionality -- can plot the full time series
% ==> When nTransitsZoom > # of transits, the resulting plot is the same as the full time series plot
% ==> When nTransitsZoom < # of transits, the resulting plot is zoomed on the end of the time series.
%
% This test is intended to be executed in the mlunit context.  For standalone execution use the following syntax:
%
%      run(text_test_runner, testTransitFitClass('test_plot_unwhitened_flux_time_series_geometric_model'));
%
% Version date:  2011-April-20.
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
%    2011-April-20, JL:
%        update to support DV 7.0
%
%=========================================================================================

  disp(' ');
  disp('... testing unwhitened flux time series plotting with geometric transit model ... ');
  disp(' ');
  
  testTransitFitGeometricClass_initialization;
  
% create a folder to put the subfolders into

  testDirName = ['test-', datestr(now,30)];
  mkdir( pwd, testDirName );
  testDir = fullfile(pwd, testDirName);
  
  keplerId = 12345678;
  iPlanet  = 1;
  
% create the necessary subfolders

  planetSearchDirName = ['planet-', num2str(iPlanet, '%02d'), filesep, 'planet-search-and-model-fitting-results'];
  mkdir( testDir, planetSearchDirName );
  planetSearchDir = fullfile(testDir, planetSearchDirName);
  
  allTransitsDirName = 'all-transits-fit';
  mkdir( planetSearchDir, allTransitsDirName );
  allTransitsDir = fullfile( planetSearchDir, allTransitsDirName );
  oddEvenFilename = '-all-' ;

  load(fullfile(testDataDir,'target-table-data-struct'));
  load(fullfile(testDataDir,'cadence-numbers'));

% basic plot

  plotHandle = plot_unwhitened_flux_time_series( transitFitObject1, targetFluxTimeSeries, targetTableDataStruct, cadenceNumbers, allTransitsDir, keplerId, iPlanet, oddEvenFilename);
  pause( 5 );
  close( plotHandle );
  
  disp(' ');
  disp('... testing unwhitened zoomed flux time series plotting with geometric transit model ... ');
  disp(' ');

% plot with large value of nTransitZoom 

  plotHandle = plot_unwhitened_zoomed_flux_time_series( transitFitObject1, targetFluxTimeSeries, 100 );
  pause( 5 );
  close( plotHandle );
  
% plot with small value of nTransitZoom 

  plotHandle = plot_unwhitened_zoomed_flux_time_series( transitFitObject1, targetFluxTimeSeries, 2   );
  pause( 5 );
  close( plotHandle );

  disp( ' ' );
  
return

% and that's it!

