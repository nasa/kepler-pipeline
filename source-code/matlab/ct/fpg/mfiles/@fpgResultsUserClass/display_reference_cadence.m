function [fpgResultsUserObject, fovPlotHandle] = display_reference_cadence( ...
    fpgResultsUserObject, minMagnitudePlot, maxMagnitudePlot )
%
% display_reference_cadence -- plot the reference cadence pixels and the predicted star
% positions after an FPG fit.
%
% [fpgResultsUserObject, fovPlotHandle] = display_reference_cadence( fpgResultsUserObject,
%    minMagnitudePlot, maxMagnitudePlot ) displays the pixels of the reference cadence,
%    and overlays the expected star positions before the FPG fit (red dots) and after the
%    fit (blue dots).  The stars plotted are the stars within the range of stellar
%    magnitudes desired, and only the pixels associated with these stars will be
%    displayed.  In the process the fpgResultsUserClass object used for the plot will be
%    updated, if necessary, with the range of star positions needed for the plot.
%
% Version date:  2008-September-23.
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
%     2008-September-23, PT:
%         support gapIndicators to indicate missing data in plot.
%     2008-September-19, PT:
%         changes in support of one-based coordinate system.
%
%=========================================================================================

% use the retriever functions to put the star and pixel data into the object, if they are
% not there already

  fpgResultsUserObject = retrieve_star_information_from_catalog( fpgResultsUserObject, ...
      minMagnitudePlot, maxMagnitudePlot ) ;
  
  fpgResultsUserObject = retrieve_pixels_from_cadence( fpgResultsUserObject ) ;
  
% extract the subset of stars which are within the requested magnitude range

  starSkyCoordinates = reduce_mag_range( fpgResultsUserObject.starSkyCoordinates, ...
      minMagnitudePlot, maxMagnitudePlot ) ;
  
% draw the focal plane

  figure 
  draw_ccd(1:42) ;
  fovPlotHandle = gcf ;
  hold on
  
% get "before" and "after" raDec2PixClass objects

  fpgFitObject = get(fpgResultsUserObject,'fpgFitClass') ;
  fpgFitObject = set_raDec2Pix_geometry(fpgFitObject,0) ;
  raDec2PixBefore = get(fpgFitObject,'raDec2PixObject') ;
  fpgFitObject = set_raDec2Pix_geometry(fpgFitObject,1) ;
  raDec2PixAfter = get(fpgFitObject,'raDec2PixObject') ;
  
% get the pointing of the reference cadence

  pointingRefCadence = get(fpgFitObject,'pointingRefCadence') ;
  raRefCadence = pointingRefCadence(1) ;
  decRefCadence = pointingRefCadence(2) ;
  rollRefCadence = pointingRefCadence(3) ;
  
% get the list of mod/outs which should be plotted based on which CCDs have fitted focal
% plane parameters

  geometryParMap = get(fpgFitObject,'geometryParMap') ;
  fcConstants = get(fpgResultsUserObject,'fcConstants') ;
  nCcds = fcConstants.nModules * 2 ;
  ccdRotationIndex = 3:3:3*nCcds ;
  ccdRotationPointer = geometryParMap(ccdRotationIndex) ;
  fittedCcds = find(ccdRotationPointer ~= 0) ;
  fittedModOuts = sort([fittedCcds(:)*2 ; fittedCcds(:)*2-1]) ;
  fittedModOuts = fittedModOuts(:)' ;
  
% get the MJD for the reference cadence

  mjd = get(fpgFitObject,'mjd') ; mjd = mjd(1) ;
  
% loop over the mod/outs which have had their CCDs fitted

  for iModOut = fittedModOuts
      
%     Find the stars that are in both the starSkyCoordinates and the pixelTimeSeries for
%     this mod/out via their Kepler ID #'s

      keplerIdPixelTimeSeries = [...
          fpgResultsUserObject.pixelTimeSeries(iModOut).keplerIdTimeSeriesStruct.keplerId] ;
      keplerIdStarSkyCoords = starSkyCoordinates(iModOut).keplerId ;
      
      [keplerIDs,indexStars,indexPixels] = intersect(keplerIdStarSkyCoords, ...
                                                       keplerIdPixelTimeSeries    ) ;
                                                   
%     find the correct cadence in the time series

      cadence = find(fpgResultsUserObject.pixelTimeSeries(iModOut).mjdArray == mjd) ;
      
%     image the pixels associated with the targets of interest

      display_extracted_time_series(fpgResultsUserObject.pixelTimeSeries(iModOut).module, ...
                                    fpgResultsUserObject.pixelTimeSeries(iModOut).output, ...
          fpgResultsUserObject.pixelTimeSeries(iModOut).keplerIdTimeSeriesStruct(indexPixels), ...
          cadence, fcConstants ) ;
      
%    now for the stars:  we need to get their RA and Dec values

      ra = starSkyCoordinates(iModOut).ra(indexStars) * 180 / 12 ;
      dec = starSkyCoordinates(iModOut).dec(indexStars)  ;

%    now convert to MORC coordinates, both before and after

     [modBefore, outBefore, rowBefore, colBefore] = ra_dec_2_pix_absolute( raDec2PixBefore, ...
         ra, dec, mjd, raRefCadence, decRefCadence, rollRefCadence ) ;
     [modAfter,  outAfter,  rowAfter,  colAfter ] = ra_dec_2_pix_absolute( raDec2PixAfter, ...
         ra, dec, mjd, raRefCadence, decRefCadence, rollRefCadence ) ;
     
%     convert to focal plane coordinates

      [zpBefore,ypBefore] = morc_to_focal_plane_coords( modBefore, outBefore, ...
          rowBefore, colBefore, 'one-based' ) ;
      [zpAfter, ypAfter ] = morc_to_focal_plane_coords( modAfter,  outAfter,  ...
          rowAfter,  colAfter, 'one-based'  ) ;
      
%     and plot those points!

      plot(zpBefore, ypBefore, 'r.') ;
      plot(zpAfter , ypAfter , 'b.') ;
      
  end % loop over mod/outs with fitted geometry
  
  hold off
  
% and that's it!

%
%
%

%=========================================================================================

% function which produces the image of the LC pixels on each CCD

function display_extracted_time_series( module, output, timeSeriesStruct, cadence, ...
    fcConstants )

% get the rows, columns, time series, gapIndicators into separate variables

  row = [timeSeriesStruct.row] ; row = row(:) ;
  column = [timeSeriesStruct.column] ; column = column(:) ;
  timeSeries = [timeSeriesStruct.timeSeries] ;
  gapIndicators = [timeSeriesStruct.gapIndicators] ;
  
% now we need to extract the correct cadence from the time series.  
%
% The arrangement of timeSeries is as follows:
%
%     [target1cadence1 target2cadence1 ... targetNcadence1 ; ...
%      target1cadence2 target2cadence2 ... targetNcadence2 ; ...
%               ...
%      target1cadenceM target2cadenceM ... targetNcadenceM] ;
%
% We need to extract the target pixel values for the correct cadence.

  timeSeries = timeSeries(cadence,:) ;
  gapIndicators = gapIndicators(cadence,:) ;
  
% reduce the data to the ungapped portion of the data

  goodDataIndex = find(gapIndicators == 0) ;
  
  row = row(goodDataIndex) ; 
  column = column(goodDataIndex) ;
  timeSeries = timeSeries(goodDataIndex) ;
  
% The statement below is used to produce a sparse double precision imageData matrix for
% the display.  This has proven to be a huge resource hog, and since absolute visual
% fidelity of the display is not a requirement, we are now using much less memory
% intensive uint8 data to represent the pixels on the FOV.
%
% % construct a sparse matrix with the pixel data in it, offsetting the rows and columns so
% % that row 20 (first illuminated row) becomes row 1 in the matrix and column 12 (first
% % real column) becomes column 1 in the matrix.
% 
%   imageData = sparse(row-fcConstants.MASKED_SMEAR_END,...
%                      column-fcConstants.LEADING_BLACK_END,...
%                      timeSeries,...
%                      fcConstants.nRowsImaging,...
%                      fcConstants.nColsImaging                   ) ;

% convert the time series image to 8-bit unsigned integer representation and construct the
% imageData matrix

  timeSeries8 = uint8(round(timeSeries/max(timeSeries)*255)) ;
  
  imageData = zeros(fcConstants.nRowsImaging, fcConstants.nColsImaging, 'uint8') ;
  imageDataIndices = sub2ind(size(imageData), ...
      row-fcConstants.MASKED_SMEAR_END, ...
      column-fcConstants.LEADING_BLACK_END ) ;
  imageData(imageDataIndices) = timeSeries8 ;

% if the output # is even, flip the image left-right to correct for the fact that the
% even-numbered outputs have a column coordinate system which is the opposite of the
% odd-numbered outputs

  if ( mod(output,2) == 0 )
      imageData = fliplr(imageData) ;
  end

% Find the orientation of this CCD in the focal plane and use it to rotate the image to
% the correct orientation

  imageData = rot90( imageData,get_ccd_orientation( module, output ) ) ;
  
% find the positions of the corners in z', y' space (ie, FOV coordinates), and the min and
% max; since the time series coordinates are zero-based, we use zero-based arithmetic here
% as well

  rowCorner1 = fcConstants.MASKED_SMEAR_END + 1 ;
  rowCorner2 = fcConstants.VIRTUAL_SMEAR_START - 1 ;
  colCorner1 = fcConstants.LEADING_BLACK_END + 1 ;
  colCorner2 = fcConstants.TRAILING_BLACK_START - 1 ;
  rowCorner = [rowCorner1 rowCorner1 rowCorner2 rowCorner2] ;
  colCorner = [colCorner1 colCorner2 colCorner2 colCorner1] ;
  [zLim,yLim] = morc_to_focal_plane_coords([module module module module], ....
      [output output output output], rowCorner, colCorner, 'zero-based') ;
  zmin = min(zLim) ; zmax = max(zLim) ;
  ymin = min(yLim) ; ymax = max(yLim) ;

% display the image in the requested location on the focal plane display  
  
  colormap gray
  imagesc([zmin zmax],[ymin ymax],imageData) ;
  
% and that's it!

%
%
%

