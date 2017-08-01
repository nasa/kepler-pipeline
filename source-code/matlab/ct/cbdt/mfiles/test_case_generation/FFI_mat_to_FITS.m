% script to combine individual modout data into a single FITS fiel with
% real header.
% Originally written by Hayley Wu, modified by Gary Zhang
%
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

% extract the FITS header binary data block
fid             = fopen('kplrDDD_ffi.fits', 'r', 'b');
info            = fitsinfo('kplrDDD_ffi.fits');
fclose(fid);

% top level directory

topDirRoot    = '/path/to/cbd_test_cases/';

topSubDir = {'slope_+0.00_xtalk_-0.25','slope_+0.00_xtalk_+0.25', ...
             'slope_-0.20_xtalk_+0.00','slope_-0.20_xtalk_-0.25', ...
             'slope_+0.20_xtalk_+0.00','slope_+0.20_xtalk_-0.25','slope_+0.20_xtalk_+0.25' };

% topSubDir = {'slope_+0.00_xtalk_+0.00','slope_+0.00_xtalk_-0.25','slope_+0.00_xtalk_+0.25', ...
%              'slope_-0.20_xtalk_+0.00','slope_-0.20_xtalk_-0.25','slope_-0.20_xtalk_+0.25', ...
%              'slope_+0.20_xtalk_+0.00','slope_+0.20_xtalk_-0.25','slope_+0.20_xtalk_+0.25' };
         
% templated directory and file names
modoutDir       = 'run_long_mMMoOOs1';
fileName        = 'ccdDarkImage_XX.mat';

for k = 1:length(topSubDir)
    dataFolderName = char( topSubDir(k) );
    topDirectory = fullfile(topDirRoot, dataFolderName);

    for fileIndex = 1:24

        disp( strcat('FITS File Index: ', num2str(fileIndex) ) );

        fitsFileName    = strcat(dataFolderName,num2str(fileIndex, '_%02d'), '.fits');
        cbdDataFITSFile = fullfile(topDirRoot, fitsFileName);

        % make a copy of the example file
        string = ['cp -f kplrDDD_ffi.fits ' cbdDataFITSFile ];
        system(string);

        fid             = fopen( cbdDataFITSFile, 'r+', 'b');
        if ( fid == -1 )
            error('Error in opening file');
        end

        fileNameNow = strrep(fileName, 'XX', num2str(fileIndex, '%1d'));

        for channelIndex = 1:84

            disp( strcat('Channel Index: ', num2str(channelIndex) ) );
            % channel index
            [modIndex, outIndex] = convert_to_module_output(channelIndex);

            modoutDirNow1    = strrep(modoutDir, 'MM', num2str(modIndex, '%2d'));
            modoutDirNow     = strrep(modoutDirNow1, 'OO', num2str(outIndex, '%2d'));

            % load mat file
            matFileName = strcat(topDirectory, '/', modoutDirNow, '/', fileNameNow);
            string = ['load ' matFileName];
            eval(string);
            temp = single(eval('ccdImage'))';
            ffiImage = temp(:);

            offset = info.Image(channelIndex).Offset;
            status = fseek(fid, offset, 'bof');
            count = fwrite(fid, ffiImage, 'float');
        end

        fclose(fid);
    end
end