function status = make_cadus_wrapper(inputFile,outputFile,numBlocksMax)
% status = make_cadus_wrapper(inputFile,outputFile,numBlocksMax)
% wrapper to call make_cadus on data from an inputFile
% that then writes the resulting cadus to the outputFile.
% inputFile and outputFile are string variables.
% status is 0 if good, -1 otherwise
% numBlocksMax is the maximum number of blocks to read in at a time
% this defaults to 1000
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

status = 0; % good if it stays 0
[fidInput, message] = fopen(inputFile,'r');

% if error opening input file, throw error
if ~isempty(message), 
    status = -1;
    error(message)
end

if nargin<3
    numBlocksMax = 1000;
end

% determine length of file
fseek(fidInput,0,'eof');
nBytesTotal = ftell(fidInput);

frewind(fidInput); % rewind file

vcduLength = 1275-160; % expected length of each vcdu

caduLength = 1279;

nVcduBlocks = nBytesTotal/vcduLength;

% check to see that there are an integral number of vcdus in the input file

if nBytesTotal ~= round(nVcduBlocks)*vcduLength
    error([inputFile,' doesn''t contain an integral number of vcdus'])
end

% open output file
[fidOutput, message] = fopen(outputFile,'w');

% if error opening output file, throw error
if ~isempty(message), 
    status = -1;
    error(message)
end

% now read in data and convert to vcdus

while ~feof(fidInput)

    [vcdus, nBytesIn] = fread(fidInput,[1,vcduLength*numBlocksMax],'uint8=>uint8');

    % make the cadus from the input vcdus
    cadus = make_cadus(vcdus);

    nBytesOut = fwrite(fidOutput, cadus,'uint8');

%   if nBytesOut~= nVcduBlocks*caduLength;
%       status = -1;
%       error('didn''t write out the correct number of bytes')
%   end

end

fclose(fidInput);
fclose(fidOutput);

% done!
