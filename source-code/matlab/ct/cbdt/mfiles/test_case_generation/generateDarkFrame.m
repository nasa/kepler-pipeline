function [ffiFrame]=generateDarkFrame(texp,numCoadds,dark,readNoise,gain, black2D)
% function[ffiFrame]=generateDarkFrame(texp,numCoadds,dark,readNoise,gain)
% generates mock-up cover-on Kepler FFI (one CCD output)
% Inputs
%   texp: exposure time [sec], scalar
%   numCoadds: number of coadds, scalar {1 coadd default}
%           note: a read-out time of 0.51895 sec is added to texp, so the
%           total integration time is numCoadds*(texp+0.51895) sec
%   dark: dark current [e-/sec], scalar  {3.57 e-/s default}
%   readNoise: [e-/read], scalar {25 e-/read default}
%   gain: [e-/ADU], scalar {88 e-/ADU default}
%
% Outputs
%   ffiFrame: image + collateral data for a singe CCD module/output [ADU]
%
% See KEPLER.DFM.FPA.015 "Science CCD Image Output Fomrat" for description
% of CCD regions and signals
% Written by Doug Caldwell 11 Apr 2006
% Version: maintained in CVS
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


% set default values if inputs aren't set
if ~exist('texp', 'var')
    texp = 0; % seconds
end

if ~exist('numCoadds','var')
    numCoadds = 1;
end

if ~exist('dark','var')
    dark = 3.57; % e-/pixel/sec
end

if ~exist('readNoise','var')
    readNoise = 25.0;  % e-/pixel/read
end

if ~exist('gain','var')
    gain = 88; % e-/ADU
end

% load CCD fomatting and timing parameters (script sets parameter variables)
CCDFormatParams;

if ~exist('black2D','var')
    black2D = blackLevel; % use default constant black
else
    % check size
    [rowsBlack2D, colsBlack2D ] = size( black2D );
    rowsBlack2DExpected = maskSmearSize + scienceImRowSize + virtualSmearSize;
    colsBlack2DExpected = leadBlackSize + scienceImColSize + trailBlackSize;
    if ( rowsBlack2D ~= rowsBlack2DExpected || colsBlack2D ~= colsBlack2DExpected )
        error('Incorrect number of rows or columns from input 2D black!');
    end
end
%<><><><><> no parameters below here <><><><><>%

% construct image array indices
leadBlackRows = 1:(maskSmearSize + scienceImRowSize + virtualSmearSize);
leadBlackCols = 1:leadBlackSize;

trailBlackRows = 1:(maskSmearSize + scienceImRowSize + virtualSmearSize);
trailBlackCols = (leadBlackSize + scienceImColSize + 1):(leadBlackSize + scienceImColSize + trailBlackSize);

maskSmearRows = 1:maskSmearSize;
maskSmearCols = (leadBlackSize+1):(leadBlackSize+scienceImColSize);

virtualSmearRows = (maskSmearSize + scienceImRowSize + 1):(maskSmearSize + scienceImRowSize + virtualSmearSize);
virtualSmearCols = (leadBlackSize+1):(leadBlackSize+scienceImColSize);

scienceImRows = (maskSmearSize+1):(maskSmearSize + scienceImRowSize);
scienceImCols = (leadBlackSize+1):(leadBlackSize+scienceImColSize);

% set up blank array
ffiFrame = zeros(maskSmearSize + scienceImRowSize + virtualSmearSize, ...
    leadBlackSize + scienceImColSize + trailBlackSize);

% determine read noise to all pixels
sigmaBlack = readNoise/gain;  % read noise in ADU/pixel/read

% loop over co-adds
for i = 1:numCoadds

    % add exposure dark to image pixels, and masked smear pixels
    darkCurrent = dark*texp/gain;
    ffiFrame(maskSmearRows,maskSmearCols) = ffiFrame(maskSmearRows,maskSmearCols) + darkCurrent;
    ffiFrame(scienceImRows,scienceImCols) = ffiFrame(scienceImRows,scienceImCols) + darkCurrent;

    % add parallel readout dark to image, masked smear, virtual smear
    parallelDark  = dark*tReadOut/gain;
    ffiFrame(maskSmearRows,maskSmearCols) = ffiFrame(maskSmearRows,maskSmearCols) + parallelDark;
    ffiFrame(scienceImRows,scienceImCols) = ffiFrame(scienceImRows,scienceImCols) + parallelDark;
    ffiFrame(virtualSmearRows,virtualSmearCols) = ffiFrame(virtualSmearRows,virtualSmearCols) + parallelDark;

    % add transfer dark to leading black, image, masked smear, virtual smear
    transferDark  = dark*tTransfer/gain;
    ffiFrame(leadBlackRows,leadBlackCols) = ffiFrame(leadBlackRows,leadBlackCols) + transferDark;
    ffiFrame(maskSmearRows,maskSmearCols) = ffiFrame(maskSmearRows,maskSmearCols) + transferDark;
    ffiFrame(scienceImRows,scienceImCols) = ffiFrame(scienceImRows,scienceImCols) + transferDark;
    ffiFrame(virtualSmearRows,virtualSmearCols) = ffiFrame(virtualSmearRows,virtualSmearCols) + transferDark;

    % add serial dark to everything
    serialDark = dark*tSerialReadOut/gain;
    ffiFrame = ffiFrame + serialDark;
    % ffiFrame(leadBlackRows,leadBlackCols) = ffiFrame(leadBlackRows,leadBlackCols) + serialDark;
    % ffiFrame(maskSmearRows,maskSmearCols) = ffiFrame(maskSmearRows,maskSmearCols) + serialDark;
    % ffiFrame(scienceImRows,scienceImCols) = ffiFrame(scienceImRows,scienceImCols) + serialDark;
    % ffiFrame(virtualSmearRows,virtualSmearCols) = ffiFrame(virtualSmearRows,virtualSmearCols) + serialDark;
    % ffiFrame(trailBlackRows,trailBlackCols) = ffiFrame(trailBlackRows,trailBlackCols) + serialDark;

    if ( false )
    % add shot noise to everything
    chargedPixels = ffiFrame;
    shotNoise = (sqrt(chargedPixels*gain)/gain) .* randn(size(chargedPixels));
    ffiFrame = ffiFrame + shotNoise;
    % chargedPixels = ffiFrame(trailBlackRows,[maskSmearCols,trailBlackCols]);
    % shotNoise = (sqrt(chargedPixels*gain)/gain) .* randn(size(chargedPixels));
    % ffiFrame(trailBlackRows,[maskSmearCols,trailBlackCols]) = ffiFrame(trailBlackRows,[maskSmearCols,trailBlackCols]) + shotNoise;
    end
    
    % add black level + read noise to all pixels
    % ffiFrame = ffiFrame + blackLevel + sigmaBlack*randn(size(ffiFrame));
    ffiFrame = ffiFrame + black2D + sigmaBlack*randn(size(ffiFrame));    

end % loop over coadds
return


