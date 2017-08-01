function pixelStruct = retrieve_pixel_time_series_uncalibrated_by_keplerid(keplerIds, startMjd, endMjd, getLongCadence, getCollateralAndBackground)
%
% function pixelStruct = retrieve_pixel_time_series_uncalibrated_by_keplerid(keplerIds, startMjd, endMjd)
% or
% function pixelStruct = retrieve_pixel_time_series_uncalibrated_by_keplerid(keplerIds, startMjd, endMjd, getLongCadence)
% or
% function pixelStruct = retrieve_pixel_time_series_uncalibrated_by_keplerid(keplerIds, startMjd, endMjd, getLongCadence, getCollateralAndBackground)
%
% The long/short cadence target time series extractor retrieves the raw time
% series of the long or short cadence target data for a specified vector of
% kepler IDs in a given time interval.
%
% Coordinate System Note:
%   Since this wrapper is presenting data from java, the row and column
%   coordinates given here are zero-based (i.e., the pixel nearest to the
%   readout node has coordinates row=0, column=0.
%
% INPUTS:
%   keplerIds               A list of the desired keplerIds.  One or more
%                           must be specified.
%
%   startMjd               The MJD of the start of the desired time interval.  
%
%   endMjd                 The MJD of the end of the desired time interval. 
%
%   getLongCadence         If 1, long cadence data is retrieved, if 0, short calibrated data is received.
%
%   getCollateralAndBackground If 1, collateral and background data is retreived.  If 0, collateral and background data is skipped.  Defaults to 0.
%
%
% OUTPUTS:
%
%     pixel_timeSeriesStruct:
%            mjdArray(nMjd)
%            isLongCadence
%            isOriginalData
%            keplerIdTimeSeriesStruct(nTarget) -- target structure, with fields:
%                  keplerId
%                  ccdModule
%                  ccdOutput
%                  row(nPixel)
%                  column(nPixel)
%                  isInOptimalAperture(nPixel)
%                  timeSeries(nMjd,nPixel)
%                  uncertainties(nMjd,nPixel)
%                  gapIndicators(nMjd,nPixel)
%            collateralAndBackground(nModOut) -- a struct array containing the collateral and background info for each channel that a kepler ID was requested on 
%                ccdModule -- the CCD module of this collateral/background data 
%                ccdOutput -- the CCD output of this collateral/background data
%                collateralData -- a vector of the collateral data for this module/output
%                backgroundPixelData -- a vector of the collateral background pixel data for this module/output
%
%
% 
% Copyright 2017 United States Government as represented by the
% Administrator of the National Aeronautics and Space Administration.
% All Rights Reserved.
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

    % Set defaults for the optional parameters that were not specified:
    %
    switch nargin
        case 3
            getLongCadence = 1;
            getCollateralAndBackground = 0;
        case 4
            getCollateralAndBackground = 0;
        case 5
            ; %#ok<NOSEM> % do nothing -- nominal case.
        otherwise
            error('Matlab:SBT:retrieve_pixel_time_series_calibrated_by_keplerid', 'Bad number of arguments.  See helptext.');
    end
    pixelStruct = retrieve_pixel_time_series_by_keplerid_work(keplerIds, startMjd, endMjd, getLongCadence, 0, getCollateralAndBackground);
return
