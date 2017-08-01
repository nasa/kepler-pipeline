function [targetStarStruct, backgroundStruct, smearStruct, leadingBlackStruct] ...
    = build_time_series(locationStr, run, etemFileType, nCadences, nStars, iStarIndex)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function apseries = build_time_series(locationStr, run, etemFileType,
%   nCadences)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% usage example:
% [targetStarStruct, backgroundStruct, smearStruct, leadingBlackStruct] ...
%   = build_time_series('/path/to/ETEM/Results/', 100, 'long_cadence_q_black_gcr_');
%
% builds pixel time series structures for test data from a specified etem
% run
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

% inputs:
%   locationStr: string with trailing / giving the fully qualified location of the
%       directory containing the runxxx directory with the desired data
%   run: ID # of the desired ETEM run
%   etemFileType: body of the name of the ETEM output .dat file containing
%       the desired data type, e.g. 'long_cadence_q_black_gcr_'
%   nCadences: # of cadences to use for this data set
%   nStars: # of stars containing injected science (optional, set to empty if not used)
%   iStarIndex: indices of desired stars (optional, if both nStars and
%   iStarIndex are set, then iStarIndex takes precedence)
%
% outputs:
%   targetStarStruct struct array containing all data for each target star
%       with the following fields:
%       .referenceRow, .referenceColumn reference row and column for this
%           target's aperture
%       .pixelTimeSeriesStruct struct array giving the pixel time series data
%           with the following fields:
%           .timeSeries time series of pixel flux data
%           .uncertainties time series of pixel flux uncertainties
%           .pixelIndex index of this pixel in target aperture
%           .target target index for target that contains this pixel
%           .row, .column row, column of pixel
%           .isInOptimalAperture flag that when true indicates this pixel is in
%               the target's optimal aperture
%   backgroundStruct struct array containing data for each background
%       target with the following fields:
%       .pixelIndex index of this pixel in target aperture
%       .timeSeries time series of pixel flux data
%       .uncertainties time series of pixel flux uncertainties
%       .row, .column row, column of pixel
%   smearStruct struct array containing smear data across columns
%       containing the following fields:
%       .column column for this smear data
%       .virtualSmearTimeSeries time series of this column's virtual smear
%       .maskedSmearTimeSeries time series of this column's masked smear
%   leadingBlackStruct struct array containing leading black data across rows
%       containing the following fields:
%       .row row for this black data
%       .leadingBlackTimeSeries time series of this row's leading black
%

% load various required things from the etem output
runStr = ['run' num2str(run)];
loadStr = [locationStr runStr  '/Ajit_' runStr];
load(loadStr, 'nout');
loadStr = [locationStr runStr  '/ktargets_' runStr];
load(loadStr, 'ntargets', 'itargets', 'jtargets');
loadStr = [locationStr runStr  '/bad_pixel_' runStr];
load(loadStr, 'kstarpix');
loadStr = [locationStr runStr  '/optaps_' runStr];
load(loadStr, 'aps', 'ibackpix', 'jbackpix');
loadStr = [locationStr runStr  '/run_params_' runStr];
load(loadStr);

% consturct the filename for the input location and file type
etemLongCadenceFileName = [locationStr runStr '/' etemFileType runStr '.dat'];

nStarPix = length(kstarpix);
nBackPix = length(ibackpix);
nSmearColumns = run_params.CCCD2;
nBlackRows = run_params.RCCD2;

% parameters to support pixel uncertainty model
% all parameters are in electrons
gain = run_params.electrons_per_ADU;
dark = run_params.dark;
integrationTime = run_params.int_time;
exposuresPerLongCadence = run_params.exp_per_long_cadence;
readNoise = run_params.read_noise;
backgroundFlux = run_params.background_star_signal;

% open and read in necessary index arrays from bad_pixel_file

% open long_cadence_black_smear_back file for read
fid_in = fopen(etemLongCadenceFileName,'r','ieee-le');


if(~exist('nCadences', 'var'))
    nCadences = nout;
elseif nCadences > nout
    nCadences = nout;
elseif nCadences == -1 % for convenience, so calling function can force nout cadences
    % without having different syntax
    nCadences = nout;
end

if( (~exist('nStars', 'var'))  && (~exist('iStarIndex', 'var')) )
    nStars = ntargets;
    indexCollected = (1:nStars);
    % randomly draw nStars out of ntargets or choose stars with signatures on
    % them + the rest
else ( (exist('nStars', 'var'))  && (exist('iStarIndex', 'var')) )
    if ( ~isempty(iStarIndex) && isempty(find(iStarIndex < 0, 1, 'first')) )
        nStars = length(iStarIndex);
        indexCollected = sort(iStarIndex);

    elseif( isempty(nStars) || nStars == -1)
        nStars = ntargets;
        indexCollected = (1:nStars);
    elseif ( nStars ~= -1 && ~isempty(nStars) )

        injectScienceLoadString = [locationStr runStr  '/inject_science_' runStr  ];
        load(injectScienceLoadString);


        indexE = cat(1,Transiting_Earths.index);
        indexJ = cat(1,Transiting_Jupiters.index);
        indexS = cat(1,Transiting_Stars.index);
        indexR = cat(1, ReflectedLightSignatures.index);
        indexSaturated  =  (1:10)';

        indexCollected = unique([indexE; indexJ; indexS; indexR; indexSaturated]);

        if (length(indexCollected) < nStars)
            remainingStars = setxor(1:ntargets, indexCollected);
            remainingStars = remainingStars';
            chosenIndex = fix(linspace(1,length(remainingStars), nStars-length(indexCollected)));
            indexCollected = sort([indexCollected; remainingStars(chosenIndex)]);
        end;

    end
end

nAps = sum(aps); % number of pixels in each aperture
apSize = size(aps, 1); % probably 121 = 11 x 11
if apSize ~= 11*11
    error('apSize not 11*11 !!');
end


h = waitbar(0,'Reading Pixel Data');


if(length(indexCollected) > nStars)
    indexCollected = indexCollected(1:nStars);
end;

nStars = length(indexCollected);

targetStarStruct = repmat(struct('referenceRow', [], 'referenceColumn', [], ...
     'pixelTimeSeriesStruct', struct( 'row', [], 'column', [], 'isInOptimalAperture', true,'timeSeries', [], 'uncertainties', [],  'gapList', [] )), nStars,1);

tic
% Initialize the targetStarStruct
for target = 1:nStars
    targetStarStruct(target).referenceRow = itargets(indexCollected(target)); % these are the unaberrated target row and column!
    targetStarStruct(target).referenceColumn = jtargets(indexCollected(target));
    for pixel = 1:nAps(indexCollected(target))
        targetStarStruct(target).pixelTimeSeriesStruct(pixel).timeSeries = zeros(nCadences, 1);
    end
    % compute the reference row and column by going through the aps array
    % and taking offset to each non-zero pixel in order.  Assumes the order
    % in which the pixels are placed in the data is the same
    pixel = 1;
    for apEntry = 1:apSize
        if aps(apEntry, indexCollected(target))
            % computation of the reference row and column assume the target
            % reference row and pixel are in the center row and column of the
            % aperture = aps(centerApPix,:);
            [row, column] = ind2sub([11, 11], apEntry);
            targetStarStruct(target).pixelTimeSeriesStruct(pixel).row = ...
                targetStarStruct(target).referenceRow + row - 6;
            targetStarStruct(target).pixelTimeSeriesStruct(pixel).column = ...
                targetStarStruct(target).referenceColumn + column - 6;
            targetStarStruct(target).pixelTimeSeriesStruct(pixel).isInOptimalAperture = 1;
            pixel = pixel+1;
        end
    end
    if pixel - 1 ~= nAps(indexCollected(target))
        error('pixels processed in aperture not same as size of non-zero pixels in ap');
    end
end



backgroundStruct = repmat(struct('pixelIndex', [], 'row', [], 'column', [], 'timeSeries', []), nBackPix, 1);

% Initialize the backgroundStruct
for backPixel = 1:nBackPix
    backgroundStruct(backPixel).pixelIndex = backPixel;
    backgroundStruct(backPixel).row = ibackpix(backPixel);
    backgroundStruct(backPixel).column = jbackpix(backPixel);
    backgroundStruct(backPixel).timeSeries = zeros(nCadences, 1);
end



smearStruct = repmat(struct('column', [], 'maskedSmearTimeSeries', [], 'virtualSmearTimeSeries', []), nSmearColumns, 1);

% Initialize the smearStruct
for smearColumn = 1:nSmearColumns
    smearStruct(smearColumn).column = smearColumn;
    smearStruct(smearColumn).maskedSmearTimeSeries = zeros(nCadences, 1);
    smearStruct(smearColumn).virtualSmearTimeSeries = zeros(nCadences, 1);
end



leadingBlackStruct = repmat(struct('row', [], 'leadingBlackTimeSeries', []), nBlackRows, 1);
% Initialize the smearStruct
for blackRow = 1:nBlackRows
    leadingBlackStruct(blackRow).row = blackRow;
    leadingBlackStruct(blackRow).leadingBlackTimeSeries = zeros(nCadences, 1);
end

% initialize temporary variable flj
starPixels = zeros( nStarPix, 1, 'single' );
backPixels = zeros( nBackPix, 1, 'single' );
maskedSmearPixels = zeros( nSmearColumns, 1, 'single' );
virtualSmearPixels = zeros( nSmearColumns, 1, 'single' );
leadingBlackPixels = zeros( nBlackRows, 1, 'single' );

% now fill in the data values from the input .dat file
for cadence = 1:nCadences
    % read in pixel values for current long cadence block
    starPixels = fread( fid_in, [nStarPix,1], 'float32' );
    backPixels = fread( fid_in, [nBackPix,1], 'float32' );
    maskedSmearPixels = fread( fid_in, [nSmearColumns,1], 'float32' );
    virtualSmearPixels = fread( fid_in, [nSmearColumns,1], 'float32' );
    leadingBlackPixels = fread( fid_in, [nBlackRows,1], 'float32' );

    if numel(starPixels) == 0
        display('zero starPixels')
    end
    if numel(backPixels) == 0
        display('zero backPixels')
    end
    if numel(maskedSmearPixels) == 0
        display('zero maskedSmearPixels')
    end
    if numel(virtualSmearPixels) == 0
        display('zero virtualSmearPixels')
    end
    if numel(leadingBlackPixels) == 0
        display('zero leadingBlackPixels')
    end

    for target = 1:nStars

        %        starPixCount = 1; % pointer into star pixel data for the current pixel
        starPixCount = sum(nAps(1:indexCollected(target)-1))+1; % pointer into star pixel data for the current pixel

        for pixel=1:nAps(indexCollected(target))
            targetStarStruct(target).pixelTimeSeriesStruct(pixel).timeSeries(cadence) ...
                = gain*starPixels(starPixCount); % convert to electrons
            starPixCount = starPixCount + 1;
        end
    end

    for backPixel = 1:nBackPix
        backgroundStruct(backPixel).timeSeries(cadence) = gain*backPixels(backPixel);
    end

    for smearColumn = 1:nSmearColumns
        smearStruct(smearColumn).maskedSmearTimeSeries(cadence) = gain*maskedSmearPixels(smearColumn);
        smearStruct(smearColumn).virtualSmearTimeSeries(cadence) = gain*virtualSmearPixels(smearColumn);
    end

    for blackRow = 1:nBlackRows
        leadingBlackStruct(blackRow).leadingBlackTimeSeries(cadence) = gain*leadingBlackPixels(blackRow);
    end


    if ~mod(cadence, 10),
        tt=toc;
        waitbar(cadence/nCadences,h,['building time series -- Elapsed Time ',sprintf('%0.2f',tt)]);
    end

end
fclose(fid_in);
close(h);

% add modeled pixel uncertainties
skyNoise = backgroundFlux*integrationTime*exposuresPerLongCadence;
totalReadNoise = readNoise/sqrt(exposuresPerLongCadence);

for target = 1:nStars
    for pixel=1:nAps(indexCollected(target))
        targetStarStruct(target).pixelTimeSeriesStruct(pixel).uncertainties ...
            = sqrt(targetStarStruct(target).pixelTimeSeriesStruct(pixel).timeSeries ...
            + skyNoise + power(totalReadNoise, 2));
    end
end
for backPixel = 1:nBackPix
    backgroundStruct(backPixel).uncertainties ...
        = sqrt(backgroundStruct(backPixel).timeSeries ...
        + skyNoise + power(totalReadNoise, 2));
end


filename = ['timeSeries_' runStr '.mat'];
save(filename, 'targetStarStruct', 'backgroundStruct', 'smearStruct', 'leadingBlackStruct');

