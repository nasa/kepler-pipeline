function view_raw_and_calibrated_ffi(rawFfiFilename, calFfiFilename, channel, ...
    colormapStr, plotFlag)
%
% function to view a raw and calibrated full frame image (FFI) side by side
% using smart_imagesc which scales the images appropriately
%
% INPUTS:
%
%   rawFfiFilename  filename of raw FFI 
%   calFfiFilename  filename of SOC calibrated FFI
%   channel         [int] CCD channel (index to FFI)
%
% OPTIONAL INPUTS:
%   colormapStr     [string] colormap (default = 'hot')
%   plotFlag        [logical] flag to plot image to file (default = true)
%
%
% OUTPUTS:
% 
%   subplot with raw and calibrated images scaled with smart_imagesc
%   and with linked axes 
%
%--------------------------------------------------------------------------
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

if nargin < 4
    colormapStr = 'hot';
    plotFlag    = true;
end


rawFfi = fitsread(rawFfiFilename, 'image', channel);  % 1070 x 1132
calFfi = fitsread(calFfiFilename, 'image', channel);  % 1070 x 1132


figure;

h1 = subplot(2,1,1);
smart_imagesc(rawFfi, [0 1131], [0 1069], h1)
colormap(colormapStr) 
title(['Original FFI for Channel ' num2str(channel)])
xlabel('CCD Column')
ylabel('CCD Row')

h2 = subplot(2,1,2);
smart_imagesc(calFfi, [0 1131], [0 1069], h2)
colormap(colormapStr) 
title(['Calibrated FFI for Channel ' num2str(channel)])
xlabel('CCD Column')
ylabel('CCD Row')


linkaxes([h1, h2], 'xy')

if plotFlag
    plot_to_file(['raw_and_cal_ffi_image_channel' num2str(channel)], false);
end

return;
