%% analyse each 84-channel FITS data
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

fileNameTemplate = 'ffi_200809XXXXXX_set_YYY.fits';
fileFolder = '/path/to/FS_TVAC_2D_black_ffi/module_data';

maxPixelArray = zeros(1, 84);
minPixelArray = zeros(1, 84);
medPixelArray = zeros(1, 84);

numFFIs = 270;
border = 20;

% fileDates = [131622 140517 140837 ...
%     221634 221807 222305 ...
%     230215 230354 230519 230656 231332 231448 231722 ];

fileDates = [030929 030930 030931 031347 031508 031618 031856 032124 040117];

for date = fileDates

    fileName_0 = strrep(fileNameTemplate, 'XXXXXX', num2str(date, '%06d'));

    for set=1:3
        fileName_1 = strrep(fileName_0, 'YYY', num2str(set, '%03d'));
        fileName = fullfile(fileFolder, fileName_1);
        
        disp(fileName);

        if ~( exist(fileName, 'file'))
            disp('End of File List');
            break;
        end
        
        for k=1:84
            % reach one FFI from each channel
            img = fitsread(fileName, 'Image', k) / numFFIs;

            % remove the virtual smear enjection line
            img=img(border:1070 - border, border:1132 - border);

            maxPixelArray(k) = max(img(:));
            minPixelArray(k) = min(img(:));
            medPixelArray(k) = median(img(:));

            disp(['Channel: ' num2str(k) ', [' num2str(minPixelArray(k), '%8.2f') ',' num2str(medPixelArray(k), '%8.2f') ',' num2str(maxPixelArray(k), '%8.2f') ']' ] );
            figure(1), imagesc( img ); colorbar; title(num2str(k));

        end

        medAll = median( medPixelArray );

        figure(10), plot(1:84, maxPixelArray, '-rx', 1:84, minPixelArray, '-b+', 1:84, medPixelArray, '-gO');
        axis([1 84 medAll - 100 medAll + 100]); grid; title( fileName );

        figName = strrep(fileName, '.fits', '.fig');
        saveas(gcf,  figName);
    end
end