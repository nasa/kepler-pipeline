%% data preparation script
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

addpath /path/to/mfiles
addpath /path/to/mfiles/utility

constants;

fileFolder = '/path/to/FS_TVAC_2D_black_ffi/module_data';

fileInputNameTemplate = 'ffi_200809ABCDEF_set_UV_module_YY.fits';
fileOutputNameTemplate = 'ffi_200809ABCDEF_set_UV.mat';

% These correspond to the date portion of the whole time string without
% year and month.
% fileDates = [131622 140517 140837 ...
%     221634 221807 222305 ...
%     230215 230354 230519 230656 231332 231448 231722 ];

fileDates = [030929 030930 030931 031347 031508 031618 031856 032124 040117];

% number of integrations
%noFFIs = 270;
noFFIs = 1;

imageData= zeros(FFI_ROWS, FFI_COLS, MOD_OUT_NO);

for iFileDate=fileDates

    disp(['Input timestamp: ' num2str(iFileDate', '%06d')]);
    fileInputNameDated_0 = strrep(fileInputNameTemplate, 'ABCDEF', num2str(iFileDate', '%06d') );
    fileOutputNameDated_0 = strrep(fileOutputNameTemplate, 'ABCDEF', num2str(iFileDate', '%06d') );

    for iSet = 1:3
        % get the dated file name
        fileInputNameDated_1 = strrep(fileInputNameDated_0, 'UV', num2str(iSet', '%03d') );
        fileOutputNameDated_1 = strrep(fileOutputNameDated_0, 'UV', num2str(iSet', '%03d') );

        fileInputNameDated = fullfile(fileFolder, fileInputNameDated_1);
        fileOutputNameDated = fullfile(fileFolder, fileOutputNameDated_1);

        % test if file exists ...
        fileInputName = strrep(fileInputNameDated, 'YY', num2str(2, '%02d'));

        if ~( exist(fileInputName, 'file') )
            disp(['End of file list is reached ... breaking: file not found: ' fileInputName]);
            disp('');
            break;
        end

        iChannel = 1;
        for iModule = IDX_MOD_OUTS
            % get module file name
            fileInputName = strrep(fileInputNameDated, 'YY', num2str(iModule, '%02d'));

            % this is fule name
            disp([' file name:' fileInputName]);

            % image contains images from four channels: how are they ordered?
            fitsInfo = fitsinfo(fileInputName);
            imageData(:, :, iChannel: iChannel + 3) = fitsread(fileInputName) / noFFIs;

            % display the four channel images
            figure(1);
            for k = 0:3
                subplot(2, 2, k+1), imagesc( imageData(1:1050, :, iChannel + k) ); colormap jet; colorbar;
            end
            pause(1);

            iChannel = iChannel + 4;
        end

        disp(['Output file name:' fileOutputNameDated]);
        disp(''); % add a blank line

        % save the whole image to a mat file
        %save(fileOutputNameDated, 'imageData');

        % save the whole image to a fits file
        fileOutputNameDatedFits = strrep(fileOutputNameDated, '.mat', '.fits');
        save_image_in_fits(fileOutputNameDatedFits, imageData);
    end
end
clear ImageDate;
