function fitStruct = detrend_time_series(timeSeries, row, column, ...
    motionPolyStruct, cosmicRayConfigurationStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function fitStruct = detrend_time_series(timeSeries, row, column, ...
%     motionPolyStruct, cosmicRayConfigurationStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% Remove a trend from the input time series.  This trend contains both a
% regression against mostion when input motionPolyStruct is not empty and
% a local polynomial fit of the data.
%
% inputs: 
%   timeSeries() # of cadences x 1 array containing pixel brightness
%       time series.  Gaps are assumed to have been filled
%   row, column row and column of this pixel in CCD module output coordinates
%   motionPolyStruct(): possibly empty # of cadences array of structures,
%       one for each cadence, containing at least the following fields:
%       .rowCoeff, .columnCoeff: structures describing the row and column
%           motion across the module output as returned by
%           weighted_polyfit2d()
%   cosmicRayConfigurationStruct: structure containing various
%       configuration values as returned by build_cr_configuration_struct()
%
% output: 
%   fitStruct structure containing results of the detrend polynomial fits,
%       returned for diagnostic purposes, which contains the following
%       fields:
%       .trend(): size of timeSeries array containing the trends removed from
%           timeSeries
%       .residual(): size of timeSeries array containing the residual
%           remaining after the trend is removed from timeSeries
%
%   See also BUILD_CR_CONFIGURATION_STRUCT WEIGHTED_POLYFIT2D,
%   WEIGHTED_POLYVAL2D, FAST_LOCAL_POLYFIT
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

% get parameters we use from the configuration structure
preferredWindow = cosmicRayConfigurationStruct.detrendWindow; 
smallWindowDetrendOrder = cosmicRayConfigurationStruct.smallWindowDetrendOrder; 
largeWindowDetrendOrder = cosmicRayConfigurationStruct.largeWindowDetrendOrder; 
motionDetrendOrder = cosmicRayConfigurationStruct.motionDetrendOrder; 

% get the # of cadences in this time series
nCadences = length(timeSeries);

% do the actual detrending
if nCadences <= preferredWindow
    % if nCadences is smaller than the window size (so we cannot do a good job
    % regressing against motion) do a simple polynomial fit to the entire
    % time series 
    
    % use the matlab polyfit with mean and standard deviation data
    if length(timeSeries) < smallWindowDetrendOrder + 1
        order = length(timeSeries) - 1;
    else
        order = smallWindowDetrendOrder;
    end
    [p, s, mu] = polyfit((1:length(timeSeries))', timeSeries, order);
    % compute the trend by evaluating the polynomial at every point of the
    % time series
    fitStruct.trend = polyval(p, (1:length(timeSeries))', s, mu);
    % compute the residual by removing the trend
    fitStruct.residual = timeSeries - fitStruct.trend;
else
    % timeSeries is large enough to do local polynomial fits at each point
    if ~isempty(motionPolyStruct)
        % we have motion data so first regress against row and column motion
        
        % start by creating a time series of motion at this row, column
        rm = weighted_polyval2d(row, column, [motionPolyStruct.rowCoeff])';
        cm = weighted_polyval2d(row, column, [motionPolyStruct.columnCoeff])';

        % regress against the motion
        % get the mean of the time series to subtract before the regression
        meanTimeSeries = mean(timeSeries);
        % do the actual regression, getting the design matrix for reuse
        [pixelMotionStruct, pixelMotionDesignMatrix] = weighted_polyfit2d( ...
            rm, cm, (timeSeries - meanTimeSeries), 1, motionDetrendOrder);
        % compute the trend at the same points as the regression and put
        % back the time series mean
        motionTrend = weighted_polyval2d(rm, cm, pixelMotionStruct, ...
            pixelMotionDesignMatrix) + meanTimeSeries;
    else
        % if motion is not available there is no motion trend
        motionTrend = 0;
    end
    % compute the residual of the  motion trend
    motionResidual = timeSeries - motionTrend;
    
    % now detrend the motion residual against local variations in time with
    % the fast local polynomial (which cannot be weighted)
    fitTrend = fast_local_polyfit(motionResidual, largeWindowDetrendOrder, ...
        preferredWindow, 1)';
    % compute the residual of both types of regression
    fitStruct.residual = timeSeries - motionTrend - fitTrend;
    % compute the trend combining both types of regression
    fitStruct.trend = motionTrend + fitTrend;
end

