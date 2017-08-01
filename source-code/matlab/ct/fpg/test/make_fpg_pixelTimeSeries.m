function pixelTimeSeries = make_fpg_pixelTimeSeries( starSkyCoordinates, ...
    raDec2PixObject, mjd )
%
% make_fpg_pixelTimeSeries -- construct a pixelTimeSeries structure for FPG from a
% starSkyCoordinates structure.
%
% pixelTimeSeries = make_fpg_pixelTimeSeries( starSkyCoordinates, raDec2PixObject, mjd )
%    returns a pixelTimeSeries-formatted structure from a starSkyCoordinates-formatted
%    structure, using the raDec2PixObject and mjd.  Stellar magnitudes are not taken into
%    account in the resulting time series (ie, all stars have a max value of timeSeries of
%    16, regardless of the actual stellar magnitude).
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
%         support for zero- or one-based raDec2PixClass objects.
%
%=========================================================================================

% pixel time series coordinates are always zero-based, so convert the raDec2PixObject to
% zero-based

  raDec2PixObject = become_zero_based(raDec2PixObject) ;

% construct the pixelTimeSeriesStruct which will be used for each star:

  rowValues = [-2 -1 0 1 2] ; colValues = rowValues ;
  [row,column] = ndgrid(rowValues, colValues) ;
  row = row(:) ; column = column(:) ;
  timeSeries = zeros(5,5) ;
  timeSeries(3,3) = 16 ;
  timeSeries(2,3) = 4 ;
  timeSeries(4,3) = 4 ;
  timeSeries(3,2) = 4 ;
  timeSeries(3,4) = 4 ;
  timeSeries(2,2) = 2 ;
  timeSeries(4,2) = 2 ;
  timeSeries(2,4) = 2 ;
  timeSeries(4,4) = 2 ;
  timeSeries = timeSeries(:) ;
  
  pTSS(25).row = [] ;
  pTSS(25).column = [] ;
  pTSS(25).timeSeries = [] ;
  
  for iPixel = 1:25
      pTSS(iPixel).timeSeries = timeSeries(iPixel) ;
  end
  
% construct the keplerIdTimeSeriesStruct which will be used for each star

  kTSS.keplerId = [] ;
  kTSS.pixelTimeSeriesStruct = [] ;
  
% construct pixelTimeSeries as a structure

  pTS.module = [] ;
  pTS.output = [] ;
  pTS.mjdArray = [] ;
  pTS.keplerIdTimeSeriesStruct = kTSS ;
  
% dimension the return variable properly

  nModOut = length( starSkyCoordinates ) ;
  pixelTimeSeries(nModOut) = pTS ;
  
% loop over mod/outs

  for iModOut = 1:nModOut
      
      pixelTimeSeries(iModOut).module = starSkyCoordinates(iModOut).module ;
      pixelTimeSeries(iModOut).output = starSkyCoordinates(iModOut).output ;
      pixelTimeSeries(iModOut).mjdArray = mjd ;
            
%     get the pixel coordinates for all stars

      [m,o,r,c] = ra_dec_2_pix(raDec2PixObject, starSkyCoordinates(iModOut).ra*15, ...
          starSkyCoordinates(iModOut).dec, mjd) ;
      
%     eliminate any which fell off the mod/out

      badStars1 = find( (m~=starSkyCoordinates(iModOut).module) | ...
          (o~=starSkyCoordinates(iModOut).output) ) ;
      r = round(r) ; c = round(c) ;
      badStars2 = find( r<22 | r > 1041 ) ;
      badStars3 = find( c<14 | c > 1109 ) ;
      badStars = unique([badStars1(:) ; badStars2(:) ; badStars3(:)]) ;
      r(badStars) = [] ; c(badStars) = [] ;
      starSkyCoordinates(iModOut).keplerId(badStars) = [] ;
      
      nStar = length(starSkyCoordinates(iModOut).keplerId) ;
      pixelTimeSeries(iModOut).keplerIdTimeSeriesStruct(nStar) = kTSS ;
      
      keplerIdCell = num2cell(starSkyCoordinates(iModOut).keplerId) ;
      [pixelTimeSeries(iModOut).keplerIdTimeSeriesStruct.keplerId] = keplerIdCell{:} ;
      
%     loop over stars and construct their pixel time series structs
      
      for iStar = 1:nStar
          
          pixelTimeSeries(iModOut).keplerIdTimeSeriesStruct(iStar).pixelTimeSeriesStruct = ...
              pTSS ;
          
          rowStar = num2cell(row + r(iStar)) ; colStar = num2cell(column + c(iStar)) ;
          [pixelTimeSeries(iModOut).keplerIdTimeSeriesStruct(iStar).pixelTimeSeriesStruct.row] = ...
              rowStar{:} ;
          [pixelTimeSeries(iModOut).keplerIdTimeSeriesStruct(iStar).pixelTimeSeriesStruct.column] = ...
              colStar{:} ;
          
      end % loop over stars
      
  end % loop over mod/outs.
  
% and that's it!

%
%
%
