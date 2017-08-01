function table = prepare_for_fitsread(ffiName)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% table = prepare_for_fitsread
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% 
% prepare_for_fitsread looks for the arrangement of modules and outputs of
% the fits file and outputs this arrangement in channelTable
%
%
% see fitsread_check_modout.m for complementary usage and downstream use
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% INPUTS:        
%
%               ffiName:[string] name of the ffi fitsfile
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% OUTPUTS: 
%
%            table: [array int] of the real arrangement for 
%                   channel, module, and outputs for the input
%                   file
%
%
%                                   the table looks like this -
%
%                                         channel   mod     out
%                                       |   1   |   2   |   1   |
%                                       |   2   |   2   |   2   |
%                                       |   3   |   2   |   3   |
%                                       |   4   |   2   |   4   |
%                                           ...
%
%
%                if any module or output info missing table will look like:
%
%                                         channel   mod     out
%                                       |   1   |   0   |   1   |
%                                       |   2   |   2   |   0   |
%                                       |   3   |   2   |   3   |
%                                       |   4   |   0   |   0   |
%
%
%            dataType: [string] orignal datatype of image,
%                           most likely single
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% check inputs, if invalid, error out
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
if exist(ffiName, 'file') ~= 2
    error('file not in search path or does not exist')
end



[pathstr, name, ext] = fileparts(ffiName);
if ~strcmp(ext, '.fits')
    error('specified file is not fits format')
end



% read in fits information and check image portion exists
% also check datatype to preserve precision of image
info = fitsinfo(ffiName);
if ~isfield(info, 'Image')
    error('fits file without image extension')
end
numImage = length(info.Image);



% create table for channel, output, and module
table = zeros(numImage, 3);
% begin populating the "real" channel, module, and output table
for frame = 1:numImage
    table(frame, 1) = frame;

    indxModule = strmatch('MODULE',info.Image(frame).Keywords(:,1), 'exact');
    if isempty(indxModule) % MODULE not found in Image header
        actualModule = 0;
    else
        actualModule = info.Image(frame).Keywords{indxModule,2};
        if isempty(actualModule) % MODULE header exist but field is blank
            actualModule = 0;
        end

    end

    indxOutput =  strmatch('OUTPUT', info.Image(frame).Keywords(:,1), 'exact');
    if isempty(indxOutput) % OUTPUT not found in Image header
        actualOutput = 0;
    else
        actualOutput = info.Image(frame).Keywords{indxOutput,2};
        if isempty(actualOutput) % OUTPUT header exist but field is blank
            actualOutput = 0;
        end
    end

    table(frame, 2) = actualModule;
    table(frame, 3) = actualOutput;
end

