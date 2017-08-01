function [reportFileName] = ffi_binary_diff(ffi1, ffi2)
% FFI_BINARY_DIFF performs diff on binary portions of two Kepler FFIs
% [reportFileName] = ffi_binary_diff(ffi1, ff12)
% Reads in the two FFIs whose full-path names are given in ffi1 & ffi2 and
% performs a channel by channel reporting any difference to the screen and
% to a summary file.
% Inputs:
%   ffi1, ffi2: strings containing full-path name of the two Kepler FFIs to
%       be compared
%
% Outputs:
%   reportFileName: string containing the name of the output report file,
%       written to the current directory, all reporting is also sent to 
%       stderr. File name format is:
%           ffi_diff_kplrYYYYdoyHHMMSS_ffi-orig.txt (where the date string
%           and remaining file name comes from ffi1)
%
% 
% Copyright 2017 United States Government as represented by the
% Administrator of the National Aeronautics and Space Administration.
% All Rights Reserved.
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

NCHANNELS = 84; % number of channels in FFI

% create output report file
[pathStr,ffiName] = fileparts(ffi1);
reportFileName = ['ffi_diff_',ffiName,'.txt'];

outFid = fopen(reportFileName,'w');
stdout = 1; % file ID for standard ouput
stderr = 2; % file ID for standard error

fidsForOutput = [stdout,outFid];
nouts = length(fidsForOutput);


% write header portion of report file
for i=1:nouts
    fprintf(fidsForOutput(i),'FFI FITS binary diff results - %s\n',datestr(now));
    fprintf(fidsForOutput(i),'ffi1: %s\n',ffi1);
    fprintf(fidsForOutput(i),'ffi2: %s\n',ffi2);
    fprintf(fidsForOutput(i),'\n');
end



% check to see if input FFI files exist
if ~exist(ffi1,'file')
        fprintf(outFid,'Error: input ffi: %s does not exist\n',ffi1);
        error(['FFI_BINARY_DIFF: input ffi: ',ffi1,' does not exist']);
end
if ~exist(ffi2,'file')
        fprintf(outFid,'Error: input ffi: %s does not exist\n',ffi2);
        error(['FFI_BINARY_DIFF: input ffi: ',ffi2,' does not exist']);
end
    
% set counter to keep track of channels that differ
nDifferentChannels=0;

for ch = 1:NCHANNELS
    im1 = fitsread(ffi1,'Image',ch);
    im2 = fitsread(ffi2,'Image',ch);
    if (any(im1(:)-im2(:))) % check if there are any non-zero elements in the difference
            warnString = ['FFI_BINARY_DIFF: FFIs differ in channel ',int2str(ch)];
            fprintf(outFid,'%s\n',warnString);
            warning(warnString);
            nDifferentChannels = nDifferentChannels + 1;
    end
    
    
end

% write summary information, including total number of differing channels
for i=1:nouts
    if nDifferentChannels==0
        fprintf(fidsForOutput(i),'binary portions of all channels are identical\n');
    else
        fprintf(fidsForOutput(i),'binary portions of FFIs differ for %d channels\n',nDifferentChannels);
    end
end

fclose(outFid);

    