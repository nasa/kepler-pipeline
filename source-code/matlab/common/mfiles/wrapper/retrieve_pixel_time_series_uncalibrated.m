function timeSeriesStruct = retrieve_pixel_time_series_uncalibrated(modules, outputs, startMjd, endMjd, getLongCadence)
%
% The long/short cadence pixel time series extractor retrieves the original or
% uncalibrated pixel time series of the long or short cadence target data for a
% specified mod/out for a given time interval.
%
% timeSeriesStruct = retrieve_pixel_time_series_uncalibrated(modules, outputs, startMjd, endMjd)
% or
% timeSeriesStruct = retrieve_pixel_time_series_uncalibrated(modules, outputs, startMjd, endMjd, getLongCadence)
%
% Coordinate System Note:
%   Since this wrapper is presenting data from java, the row and column
%   coordinates given here are zero-based (i.e., the pixel nearest to the
%   readout node has coordinates row=0, column=0.
%
% INPUTS:
%   modules                 A list of the desired modules.  All are returned
%                           if this is not specified.  Must be the same length as 'outputs' if
%                           specified.
%
%   outputs                 A list of the desired outputs.  All are returned
%                           if this is not specified.  Must be the same length as 'modules' if
%                           specified.
%
%   startMjd               The MJD of the start of the desired time
%                           interval.  
%
%   endMjd                 The MJD of the end of the desired time interval. 
%
%   getLongCadence        Optional flag.  If 1, long cadence data is retrieved,
%                           if 0, short data is received.  Defaults to 1.
%
% OUTPUTS:
%
%     pixel_timeSeriesStruct(nModOut):
%            module
%            output
%            mjdArray(nMjd)
%            isLongCadence
%            isOriginalData
%            backgroundData
%            collateralData
%            keplerIdTimeSeriesStruct(nTarget) -- target structure, with fields:
%                  keplerId
%                  row(nPixel)
%                  column(nPixel)
%                  isInOptimalAperture(nPixel)
%                  timeSeries(nMjd,nPixel)
%                  uncertainties(nMjd,nPixel)
%                  gapIndicators(nMjd,nPixel)
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

    % Parse args:
    %
    if nargin < 4 || nargin > 5
        error('MATLAB:SBT:wrapper:retrieve_pixel_time_series', ...
            'Wrong number of arguments, see help text.')
    end

    % Default getLongCadence to 1:
    %
    if nargin == 4
        getLongCadence = 1;
    end

    import gov.nasa.kepler.systest.sbt.SandboxTools;
    try
        timeSeriesStruct = retrieve_pixel_time_series_work(modules, outputs, startMjd, endMjd, getLongCadence, 0);
        SandboxTools.close;
    catch
        SandboxTools.close;
        rethrow(lasterror);
    end
return
