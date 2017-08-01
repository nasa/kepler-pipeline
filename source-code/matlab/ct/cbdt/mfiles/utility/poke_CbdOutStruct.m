%% analysis routine to poke the output data structure from CBD
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

if ( isunix )
    addpath '/path/to/matlab/ct/cbdt/mfiles/utility'
else
    
end

constants;

channelDataStruct = cbdDataOutStruct.channelDataStruct;

numberChannels = length( channelDataStruct);
measured2DBlackChannels = zeros(FFI_ROWS, FFI_COLS, numberChannels);
measured2DBlackOnlyChannels = zeros(FFI_ROWS, FFI_COLS, numberChannels);

for k = 1:numberChannels

    measured2DBlack = channelDataStruct(k).blackData.measured2DBlack;
    measured2DBlackStd = channelDataStruct(k).blackData.measured2DBlackStd;

    measured2DBlackOnly = channelDataStruct(k).blackData.measured2DBlackOnly;
    
    measured2DBlackChannels(:, :, k) = measured2DBlack;
    measured2DBlackOnlyChannels(:, :, k) = measured2DBlackOnly;
    
    % statistics from 5 regions
    regionStatis = channelDataStruct(k).blackData.measured2dBlackRegionStats;

    scienceMean = regionStatis.star.mean;
    scienceStd = regionStatis.star.stdev;

    [module, output] = convert_to_module_output( k );
    figure (10), imagesc( measured2DBlack, [scienceMean - 2 * scienceStd, scienceMean + 2 * scienceStd] ); colorbar;
    title(['2D Black& FGS Measurement for channel: ' num2str(k) ' (' num2str(module) ', ' num2str(output) ')' ]);

    figure (11), imagesc( measured2DBlackOnly, [scienceMean - 2 * scienceStd, scienceMean + 2 * scienceStd] ); colorbar;

    %     figure(12), subplot(1, 2, 1), plot(measured2DBlack(500, :) );
    %     title(['Row 500: ' num2str(k) ]);
    %     subplot(1, 2, 2), plot(measured2DBlack(1:1050, 600) );
    %     title(['Column 600: ' num2str(k) ]);

    pause;
end

disp('Save twoDBlack to fits files?');
pause;

% save to FITS file
save_image_in_fits('TwoDBlackFGS_20080903.fits', measured2DBlackChannels);
save_image_in_fits('TwoDBlackOnly_20080903.fits', measured2DBlackOnlyChannels);

% clear variables and free memory
clear measured2DBlackChannels
clear measured2DBlackOnlyChannels

clear measured2DBlack;
clear measured2DBlackStd;