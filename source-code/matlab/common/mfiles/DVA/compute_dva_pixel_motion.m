function [timestamps, meanDvaPixelMotion] = ...
compute_dva_pixel_motion(raDec2PixModel, mjd0, nDays, plotsEnabled)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [timestamps, meanDvaPixelMotion] = ...
% compute_dva_pixel_motion(raDec2PixModel, mjd0, nDays, plotsEnabled)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Set up a reference star on each of four module outputs near the FGS
% sensors, and determine the path of each reference star over the time
% period specified by the base MJD (mjd0) and the number of days following
% (nDays). The path of each reference target is based on nominal pointing
% of the photometer, and is elliptical due to DVA. Compute the ratio of
% the absolute change in pixel location to change in time on daily
% intervals. Then compute and return the mean DVA pixel motion taken over
% the four reference stars, along with the associated MJD timestamps.
%
% Generate and save plots to .fig files if plotsEnabled is true.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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

% Set plotsEnabled to false if it was not specified.
if ~exist('plotsEnabled', 'var')
    plotsEnabled = false;
end

% Instantiate a raDec2Pix object.
raDec2PixObject = raDec2PixClass(raDec2PixModel, 'one-based');

% Set up four reference stars.
modules = [9 7 17 19]';
outputs = [4 4  4  4]';
rows = 5 * [1 1 1 1]';
cols = 5 * [1 1 1 1]';

% Get the sky coordinates of the reference stars at the base MJD.
[raRefStars, decRefStars] = ...
    pix_2_ra_dec(raDec2PixObject, modules, outputs, rows, cols, mjd0);

% Set vectors of input and output timestamps, and initialize arrays of
% predicted reference locations. Note that DVA is computed at the midpoints
% of the input dates.
mjds = mjd0 + (0 : nDays)';
timestamps = (mjds(1 : end-1) + mjds(2 : end)) / 2;

nRefStars = length(raRefStars);
predRows = zeros([nRefStars, nDays+1]);
predCols = zeros([nRefStars, nDays+1]);

% Determine the path of the reference stars across their respective module
% outputs over the desired time period.
for i = 1 : nDays+1
    [module, output, predRows( : , i) predCols( : , i)] = ...
        ra_dec_2_pix(raDec2PixObject, raRefStars, decRefStars, mjds(i));
end

% Transpose the arrays of predicted reference star positions so that each
% array column is a row or column time series for a given star.
predRows = predRows';
predCols = predCols';

% Plot and save the reference star trajectories.
if plotsEnabled
    close all
    plot(predCols, predRows)
    hold on
    for iDay = 1 : 30 : nDays+1
        plot(predCols(iDay, : ), predRows(iDay, : ), 'og')
    end
    plot(predCols(1, : ), predRows(1, : ), 'or')
    hold off
    title('Reference Star Trajectories Due to DVA')
    xlabel('Column Coordinate')
    ylabel('Row Coordinate')
    grid
    plot_to_file('ref_star_trajectories')
end % if

% Take the first differences of the star trajectories over the desired time
% period. Then compute the magnitude of the ratio of change in position to
% change in time on a daily basis.
delPredRows = diff(predRows);
delPredCols = diff(predCols);
dvaPixelMotion = sqrt(delPredRows .^ 2 + delPredCols .^ 2) / 1;

if plotsEnabled
    plot(timestamps - mjd0, dvaPixelMotion);
    title('Absolute Rate of Change in Reference Star Positions Due to DVA')
    xlabel(['Days Past MJD ', num2str(mjd0)])
    ylabel('Absolute Pixel Motion (pixels/day)')
    v = axis;
    v(3) = 0;
    v(4) = 3e-3;
    axis(v);
    grid
    plot_to_file('ref_star_dva_pixel_motion')
end % if

% Compute the mean ratio of change in position to change in time over all
% targets on a daily basis.
meanDvaPixelMotion = mean(dvaPixelMotion, 2);

if plotsEnabled
    plot(timestamps - mjd0, meanDvaPixelMotion);
    title('Mean Absolute Rate of Change in Reference Star Positions Due to DVA')
    xlabel(['Days Past MJD ', num2str(mjd0)])
    ylabel('Absolute Pixel Motion (pixels/day)')
    axis(v);
    grid
    plot_to_file('mean_ref_star_dva_pixel_motion')
end % if

% Return
return

