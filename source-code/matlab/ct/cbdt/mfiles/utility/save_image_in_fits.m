function save_image_in_fits(outputFitsFileName, imageData, fitsFileExample)
% function save_image_in_fits(outputFitsFileName, imageData)
% Save 84 channels image data a single FITS fiel with
% real header.
% Originally written by Hayley Wu;
% Modified into function by Gary Zhang;
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

% get image data dimension
rows = size(imageData, 1);
cols = size(imageData, 2);
frames = size(imageData, 3);

% constants
FFI_COLS = 1132;
FFI_ROWS = 1070;
FFI_CHANNELS = 84;

if ~(rows == FFI_ROWS && cols == FFI_COLS)
    error('Error: FFI dimension is not (1070, 1132)!');
end

if ~( frames == FFI_CHANNELS )
    error('Error: Number of FFIs is less than 84');
end

if ( nargin <= 2 )
    % make a copy of the example file
    if ( isunix )
        fitsFileExample = '/path/to/mfiles/test_case_generation/kplrDDD_ffi.fits';
    elseif ( ispc )
        fitsFileExample = 'C:\path\to\matlab\ct\cbdt\mfiles\test_case_generationkplrDDD_ffi.fits';
    else
        error('Example FITS file not found!');
    end
end

% read the FITS header
fid   = fopen(fitsFileExample, 'r', 'b');
info  = fitsinfo(fitsFileExample);
fclose(fid);

string = ['cp -f ' fitsFileExample ' ' outputFitsFileName ];
system(string);

fid = fopen( outputFitsFileName, 'r+', 'b');
if ( fid == -1 )
    error('Error in opening file');
end

% locate the start of the first image data pixel
for iChannel =1:FFI_CHANNELS

    ffiImage = imageData(:, :, iChannel);

    % move the file pointer to the next data block
    status = fseek(fid, info.Image(iChannel).Offset, 'bof');
    if ~( status == 0 )
        error('Error fseek() failed.');
    end

    % This transpose is important; otherwise columns will be converted into
    % rows.
    ffiImage = single( ffiImage' );

    % write the new image data to the current location
    count = fwrite(fid, ffiImage(:), 'float');

    if ~( count == cols * rows )
        error(['Error: writing data to file failed. ' num2str(count) ]);
    end

end

fclose(fid);

return
