function targetDataStruct = get_target_data_from_lc( lcData )
%
% GET_TARGET_DATA_FROM_LC -- extract the target data from a long-cadence dataset.
%
% targetDataStruct = get_target_data_from_lc( lcData ) takes a file of long cadence data in
%    the format returned by the time series extractor tool and returns a data structure
%    with the following fields:
%
%      keplerID
%      module
%      output
%      row
%      column
%      intensity
%      totalIntensity
%
%    Each field is a column vector of length nPixel, where nPixel is the total # of data
%    pixels in the original data structure.  The totalIntensity is the sum of the
%    intensity values for all pixels associated with the given keplerId.
%
% See also:  retrieve_target_time_series.
%
% Version date:  2008-June-05.
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
%     2008-june-05, PT:
%         change to loop over existing channels of lcData, not necessarily over all
%         channels possible.  Elimination of pixelTimeSeriesStruct level of nesting.
%
%=========================================================================================

% determine the total number of pixels in the data structure

  nPixel = 0 ;
  for iChannel = 1:length(lcData)
      for iTarget = 1:length(lcData(iChannel).keplerIdTimeSeriesStruct)
          t = lcData(iChannel).keplerIdTimeSeriesStruct(iTarget) ;
          nPixel = nPixel + length(t.timeSeries) ;
      end
  end
  
% allocate the variables

  module         = zeros(nPixel,1) ;
  output         = zeros(nPixel,1) ;
  row            = zeros(nPixel,1) ;
  column         = zeros(nPixel,1) ;
  keplerId       = zeros(nPixel,1) ;
  intensity      = zeros(nPixel,1) ;
  totalIntensity = zeros(nPixel,1) ;
  
% repeat the loop, computing total intensity and filling in the data vectors

  pixelsFilled = 0 ;
  for iChannel = 1:length(lcData)
      mod = lcData(iChannel).module ;
      out = lcData(iChannel).output ;
      for iTarget = 1:length(lcData(iChannel).keplerIdTimeSeriesStruct)
          t = lcData(iChannel).keplerIdTimeSeriesStruct(iTarget) ;
          targetId = t.keplerId ;
%          nPixel = length(t.pixelTimeSeriesStruct) ;
%          targetIntensity = 0 ;
%          for iPixel = 1:nPixel
%               row(pixelsFilled+iPixel) = t.pixelTimeSeriesStruct(iPixel).row ;
%               column(pixelsFilled+iPixel) = t.pixelTimeSeriesStruct(iPixel).column ;
%               pixelIntensity = t.pixelTimeSeriesStruct(iPixel).timeSeries(1) ;
%               targetIntensity = targetIntensity + pixelIntensity ;
%               intensity(pixelsFilled+iPixel) = pixelIntensity ;
%           end
          nPixel = length(t.timeSeries) ;
          pixelStart = pixelsFilled+1 ;
          pixelStop  = pixelsFilled+nPixel ;
          row(pixelStart:pixelStop) = t.row ;
          column(pixelStart:pixelStop) = t.column ;
          intensity(pixelStart:pixelStop) = t.timeSeries ;
          module(pixelStart:pixelStop) = mod ;
          output(pixelStart:pixelStop) = out ;
          keplerId(pixelStart:pixelStop) = targetId ;
          totalIntensity(pixelStart:pixelStop) = sum(t.timeSeries) ;
          pixelsFilled = pixelsFilled + nPixel ;
      end
  end
  
% assign the target data vectors as fields of the returned data structure

  targetDataStruct.keplerId = keplerId ;
  targetDataStruct.module = module ;
  targetDataStruct.output = output ;
  targetDataStruct.row = row ;
  targetDataStruct.column = column ;
  targetDataStruct.intensity = intensity ;
  targetDataStruct.totalIntensity = totalIntensity ;
  