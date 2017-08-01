
%% form FGS mask taking input from three text FGS pixel location files
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
data_directory      = 'C:\path\to\CBD_Data';
fgs_frame_file      = 'frame_pixels_20080826.txt';
fgs_parallel_file   = 'parallel_pixels_20080826.txt';
fgs_serial_file     = 'serial_pixels_20080826.txt';

% extract the FGS pixel locations
[fgs_frame_row, fgs_frame_col]          = textread( fullfile(data_directory, fgs_frame_file), '%u %u');
[fgs_parallel_row, fgs_parallel_col]    = textread( fullfile(data_directory, fgs_parallel_file), '%u %u');
[fgs_serial_row, fgs_serial_col]        = textread( fullfile(data_directory, fgs_serial_file), '%u %u');

% get the length of the lists
len_frame = length( fgs_frame_row);
len_parallel = length( fgs_parallel_row);
len_serial = length( fgs_serial_row);

FFI_ROWS = 1070;
FFI_COLS = 1132;
LABEL_FRAME = 1;
LABEL_PARALLEL = 2;
LABEL_SERIAL = 4;
fgs_mask = uint8( zeros(FFI_ROWS, FFI_COLS) );

for k=1:len_frame
    fgs_mask(fgs_frame_row(k) + 1, fgs_frame_col(k) + 1) = LABEL_FRAME;
end
for k=1:len_parallel
    fgs_mask(fgs_parallel_row(k) + 1, fgs_parallel_col(k) + 1) = LABEL_PARALLEL;
end
for k=1:len_serial
     fgs_mask(fgs_serial_row(k) + 1, fgs_serial_col(k) + 1) = LABEL_SERIAL;
end

xtalkImage = fgs_mask;
save('cross_talk_map.mat', 'xtalkImage');

figure, imagesc(fgs_mask, [LABEL_FRAME, LABEL_SERIAL] ); colorbar; title('FGS mask with three labels');
