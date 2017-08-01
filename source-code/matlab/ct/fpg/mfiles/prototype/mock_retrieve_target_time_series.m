function lcDataStruct = mock_retrieve_target_time_series( modules, outputs, ...
    mjdStart, mjdStop, isLongCadence, isOriginalData, nTargets, raDec2PixObject )
%
% MOCK_RETRIEVE_TARGET_TIME_SERIES -- produce a data structure which mocks up the one
% which will ultimately be produced by the retrieve_target_time_series SBT.
%
% lcDataStruct = mock_retrieve_target_time_series( modules, outputs, mjdStart, mjdStop,
%    isLongCadence, isOriginalData, nTargets ) produces a data structure which is a partial
%    emulation of the structure defined in the retrieve_target_time_series API
%    requirements document.  Arguments modules and outputs are equal-length vectors of
%    module and output numbers; scalar arguments mjdStart, mjdStop, isLongCadence, and
%    isOriginalData are required by the real SBT but are ignored in this mockup; scalar
%    argument nTargets is the # of targets to be generated per mod/out; raDec2PixObject is
%    either a true raDec2PixClass object or else the data structure from which such an
%    object can be generated.
%
% The function loads a canned version of the KIC database and extracts targets from it,
%    converts them to positions on the focal plane, and puts pixels in the region around
%    that position.  The objects are scaled such that the brightest object on the focal
%    plane has a central pixel intensity of 65,535.
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
%     2008-September-19, PT:
%         update raDec2PixClass constructor call.
%     2008-June-06, PT:
%         add keplerId vector to lcDataStruct(iChannel) to improve plotting performance.
%
%=========================================================================================

% detect whether the raDec2Pix object is an object or just a structure; if just a
% structure, convert to an object

  if (~isa(raDec2PixObject,'raDec2PixClass'))
      raDec2PixObject = raDec2PixClass(raDec2PixObject,'zero-based') ;
  end
  
% define the intermediate structure, which holds the information about the targets
% selected for each mod/out

  selectedTargets(length(modules)).mod = modules(end) ;
  selectedTargets(length(modules)).out = outputs(end) ;
  selectedTargets(length(modules)).keplerId  = [] ;
  selectedTargets(length(modules)).RA        = [] ;
  selectedTargets(length(modules)).Dec       = [] ;
  selectedTargets(length(modules)).row       = [] ;
  selectedTargets(length(modules)).col       = [] ;
  selectedTargets(length(modules)).keplerMag = [] ;
  
% load the canned database from disk

  load kics_database ;
  
% define minimum magnitude variable

  magMin = 0 ; magMax = 0 ;
  
% loop over mod/outs

  for iChannel = 1:length(modules)
      iMod = modules(iChannel) ;
      iOut = outputs(iChannel) ;
          
      absoluteChannel = convert_from_module_output( iMod, iOut ) ;
      kicsChannel = kicsDatabase(absoluteChannel) ;
      selectedTargets(iChannel).mod = iMod ;
      selectedTargets(iChannel).out = iOut ;

%     select nTargets targets at random from the KIC, avoiding duplicates

      targetList = select_targets( nTargets, absoluteChannel, kicsChannel ) ;

%     populate the intermediate data structure with data from the KIC; compute the row
%     and column of the centroid of each target; eliminate targets which are too close
%     to the edge or fall on a different mod/out

      selectedTargets(iChannel).keplerId  = kicsChannel.keplerId(targetList) ;
      selectedTargets(iChannel).RA        = kicsChannel.RA(targetList) * 180 / 12 ;
      selectedTargets(iChannel).Dec       = kicsChannel.Dec(targetList)      ;
      selectedTargets(iChannel).keplerMag = kicsChannel.RMag(targetList)     ;

      [m,o,row,col] = ra_dec_2_pix(raDec2PixObject, selectedTargets(iChannel).RA, ...
          selectedTargets(iChannel).Dec, mjdStart) ;

%     round to nearest row/col to simplify plotting issues

      row = round(row) ; col = round(col) ;

      badTargets = find( (m ~= iMod) | (o ~= iOut) | (row < 22) | (row > 1041) ...
          | (col < 14) | (col > 1109) ) ;

      row(badTargets) = [] ; col(badTargets) = [] ;
      selectedTargets(iChannel).keplerId(badTargets)  = [] ;
      selectedTargets(iChannel).RA(badTargets)        = [] ;          
      selectedTargets(iChannel).Dec(badTargets)       = [] ;
      selectedTargets(iChannel).keplerMag(badTargets) = [] ;

      selectedTargets(iChannel).row = row ;
      selectedTargets(iChannel).col = col ;

      if ( (magMin == 0) & (length(selectedTargets(iChannel).keplerMag) > 0) )
          magMin = selectedTargets(iChannel).keplerMag(1) ;
      end
      magMin = min([magMin ; selectedTargets(iChannel).keplerMag]) ;
      magMax = max([magMax ; selectedTargets(iChannel).keplerMag]) ;
          
  end       % end of looping over channels
  
  if (magMin == 0)
      error(' Minimum magnitude of zero in mock_retrieve_target_time_series') ;
  end
  
%   hist(selectedTargets.keplerMag) ;
%   disp(magMin)
%   disp(magMax) 
  
% define the magnitude range -- magnitude is a log scale in which brighter stars have
% lower magnitude values and a difference of 5 in magnitude corresponds to a difference of
% 100 in intensity.  Therefore, for any given star, taking 10^(-mag*2/5) and dividing by
% 10^(-magMin*2/5) will give the brightness of that star relative to the brightest star in
% the focal plane, and multiplying that by the desired max intensity value will give a
% focal plane of stars which are properly scaled.

%  intensityScale = 65535 / 10^(-magMin*2/5) ;

% since making the display directly proportional to flux results in a dull display (since
% I select targets at random and don't leave out the bright stars), I'm going to set the
% intensity to be inversely proportional to the magnitude.  This will result in a narrow
% dynamic range of the display, which is relatively pretty.  This is for prototype
% purposes only, the actual display will depend on what the real data looks like, etc.

  intensityScale = 65535 * magMin ;
  
% define a row, column and pixel intensity map for each target -- the rows and columns go
% from +2 to -2 wrt the central pixel; the intensity of neighboring pixels is 1/4 that of
% the central, and that of the diagonal is 1/8 that of the central.

  [rowMap, colMap] = ndgrid([-2 -1 0 1 2],[-2 -1 0 1 2]) ;
  rowMap = rowMap(:) ; colMap = colMap(:) ;
  
  intensityMap = [0   0   0   0   0 ; ...
                  0  1/8 1/4 1/8  0 ; ...
                  0  1/4  1  1/4  0 ; ...
                  0  1/8 1/4 1/8  0 ; ...
                  0   0   0   0   0] ;
  intensityMap = intensityMap(:) ;
    
% similarly, preallocate the overall data structure

  lcDataStruct(length(modules)).module = [] ;
  lcDataStruct(length(modules)).output = [] ;
  lcDataStruct(length(modules)).keplerIdTimeSeriesStruct = [] ;
  
% Generate the data structure:  loop over mod/outs...

  for iChannel = 1:length(selectedTargets)
      
      lcDataStruct(iChannel).module = modules(iChannel) ;
      lcDataStruct(iChannel).output = outputs(iChannel) ;
      targetsChannel = selectedTargets(iChannel) ;
      
%     pre-allocate the time series structure -- here I eliminate the proposed
%     pixelTimeSeriesStruct and move the pixel data (row, col, timeSeries) to the
%     keplerIdTimeSeriesStruct level.  Keeping the additional level of nesting for the
%     pixelTimeSeriesStruct causes performance problems when loading or otherwise
%     manipulating the data structure and seems to offer no benefits.

      nTargets = length(targetsChannel.keplerId) ;
      kITSS(nTargets).keplerId = [] ;
      kITSS(nTargets).row = [] ;
      kITSS(nTargets).column = [] ;
      kITSS(nTargets).timeSeries = [] ;
      
%     loop over targets ...

      for iTarget = 1:nTargets
          
%         fill in the Kepler IDs, set all row/column values, and scale intensities
          
          kITSS(iTarget).keplerId = targetsChannel.keplerId(iTarget) ;
          rows = rowMap + targetsChannel.row(iTarget) ;
          cols = colMap + targetsChannel.col(iTarget) ;
          mag  = targetsChannel.keplerMag(iTarget) ;
%          scale = intensityScale * 10^(-mag*2/5) ;
          scale = intensityScale / mag ;
          flux = round(intensityMap * scale) ;

%         make the row, column, timeSeries into rows to simplify concatenation later

          kITSS(iTarget).row = rows(:)' ;
          kITSS(iTarget).column = cols(:)' ;
          kITSS(iTarget).timeSeries = flux(:)' ;
          
      end % target loop
      
%     now assign the kITSS structure to the appropriate slot in lcDataStruct
      
      lcDataStruct(iChannel).keplerIdTimeSeriesStruct = kITSS ;
      lcDataStruct(iChannel).keplerId = selectedTargets(iChannel).keplerId ;
      
  end % channel loop
  
% and that's it!

%
%
%
          
%=========================================================================================

% function select_targets -- select nTargets at random from the KIC channel of interest,
% with no duplication

function targetList = select_targets( nTargets, absoluteChannel, kicsChannel ) ;

  nTargetsInDB = length(kicsChannel.RA) ;  
  targetList = [] ;
  
% get a vector of random ints between 1 and nTargetsInDB, eliminating dupes as we go; note
% that at each step we generate 2x as many targets as needed, to reduce the # of
% iterations needed to converge.

  while (length(targetList) < nTargets)
      
      nTargetsNeeded = nTargets - length(targetList) ;
      targetListTrial = 1+floor(nTargetsInDB*rand(2*nTargetsNeeded,1)) ;
      [targetList2,I,J] = unique([targetList ; targetListTrial]) ;
      targetList = targetList2(J) ;

  end
  
% if we wound up with too many targets, truncate

  targetList = targetList(1:nTargets) ;
  
% and that's it!

%
%
%

