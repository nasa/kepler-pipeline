%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function [flux_time_series, x_centroid_time_series, y_centroid_time_series] = ...
%     compute_flux_from_photometric_aperture(pixel_file_name, aps, wts,
%     run_params, raw_flux_filename)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Function Name:  compute_flux_from_photometric_aperture.m
%
% Modification History - This is managed by CVS.
%
% Software level: Prototype Code
%
% Description:
%         This function performs a simple aperture photometry for each
%         target by summing the weighted pixel values and produces a flux
%         time series and computes centroid time series as well.
%
% Inputs:
%         pixel file name - name of the file containing the long cadence data
%              corrected for black level, smear and background.
%         aps is 121xN definition of the 11x11 apertures for each star
%         wts is 121xN set of pixel weights for use in preferentially
%              summing flux (wts values indicate the average fraction of flux
%              in the pixel from that target star)
%         runparams - a data structure containing the input parameters
%              values for the ETEM run that generated the pixel time series
%
% Outputs:
%         flux_time_series - the weighted sum of the pixel values in the photometric aperture
%               of each star
%         x_centroid_time_series, y_centroid_time_series - center of mass time series for the pixel
%               values in the photometric aperture
%
% Author: J. Jenkins, calc_opt_flux_from_file.m, ETEM_1p0 version
% H.Chandrasekaran - 10/11/2005
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
function  [flux_time_series, x_centroid_time_series, y_centroid_time_series] = ...
    compute_flux_from_photometric_aperture(pixel_file_name, aps, wts,  run_params, raw_flux_filename)


% RCCD2 = number of rows on full-frame CCD
% CCCD2 = number of columns on full-frame CCD

RCCD2 = run_params.RCCD2;
CCCD2 = run_params.CCCD2;

b = run_params.filenames.bad_pixel_filename;
bad_pixel_file = ' ';
while(~isempty(b))
    [bad_pixel_file b] = strtok(b,'/');
end;

load(bad_pixel_file, 'kstarpix', 'kbackpix2' );


% kstarpix = indices of star pixels
% kbackpix = indices of background pixels
n_starpix = length(kstarpix);
n_backpix = length(kbackpix2);

ntargets = size(aps,2);


% open long_cadence_black_smear_back file for read
fid_in = fopen(pixel_file_name,'r','ieee-le');

% open output file
if(nargin < 5)
    raw_flux_filename = [pixel_file_name 'raw_flux.dat'];
end;
fid_out = fopen(raw_flux_filename,'w','ieee-le');

% determine number of long cadences by finding filesize in bytes & dividing
% by all that is in the file for each long cadence; pixels, background &
% collateral data consisting of leading black, and masked & virtual smear
fseek(fid_in,0,'eof');
nbytes = ftell(fid_in);
frewind(fid_in);
n_long_cadences = floor(nbytes/4/(n_starpix + n_backpix + RCCD2 + 2*CCCD2));

% set up skip count so that only target star pixels are read in and the background, smear and black
% pixels are skipped.
skipcount = (n_backpix + RCCD2 + 2*CCCD2)*4;

% initialize outputs
if nargout >= 1
    flux_time_series = zeros(n_long_cadences, ntargets);
    x_centroid_time_series = zeros(n_long_cadences, ntargets);
    y_centroid_time_series = zeros(n_long_cadences, ntargets);
    [istarpix, jstarpix] = ind2sub([RCCD2 CCCD2], kstarpix);
end

% number of pixels in each aperture
naps = sum(aps);

% initialize temporary variable weighted_flux
weighted_flux = zeros( 1, ntargets, 'single' );
starpixels = zeros( n_starpix, 1, 'single' );

% Read in results one image at a time, summing pixel values to obtain
% fluxes

tstart = clock;
tnow = clock;

h = cantwaitbar(0, tstart, 'Reading Corrected Pixel Data');

for j = 1:n_long_cadences

    % read in pixel values for current long cadence block (for one timestep
    % for all stars)
    starpixels    = fread(fid_in, [n_starpix,1], 'float32' );
    fseek(fid_in, skipcount, 0);

    i1 = 0;
    for i = 1:ntargets
        ii = i1 + (1:naps(i));
        idx = find(wts(:,i) > 0);
        weighted_flux(i) = sum((starpixels(ii)).*wts(idx,i));

        % return the center of mass centroid
        if nargout > 1
            x_centroid_time_series(j, i) = istarpix(ii)' * starpixels(ii) / weighted_flux(i);
            y_centroid_time_series(j, i) = jstarpix(ii)' * starpixels(ii) / weighted_flux(i);
        end

        i1 = i1 + naps(i);

    end

    %      matrix fl
    %      <------- ntargets ---------->
    %      ^
    %      |
    %      t
    %      i
    %      m
    %      e
    %      |
    %      v

    flux_time_series(j,:) = weighted_flux;

    fwrite(fid_out, weighted_flux, 'float32');

    if etime(clock,tnow) > 1
        tnow = clock;
        cantwaitbar(j/n_long_cadences, tstart, h, 'Calculating Flux');
    end
end

close(h)

fclose(fid_in);

fclose(fid_out);



return
