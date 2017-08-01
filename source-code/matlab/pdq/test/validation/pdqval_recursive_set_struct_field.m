function [files, status] = pdqval_recursive_set_struct_field(filename, FQfield, fieldVal, directory)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [files, status] = pdqval_recursive_set_struct_field(filename, FQfield, fieldVal, directory)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
% Walk the sub-tree of the current working directory (or of the specified
% directory) and set the spacecraft ephemeris filename in any PDQ input
% files found. 
%
% Inputs:
%
%     filename  : A string containing the name of the Matlab file
%                 containing the struct of interest (e.g.,
%                 'pdq-inputs-0.mat') 
%
%     FQfield   : A string containing the fully qualified field name of the
%                 field whose value you wish to modify (e.g.,
%                 inputsStruct.raDec2PixModel.spiceSpacecraftEphemerisFilename).
%
%     fieldVal  : A string containing the value to which FQfield should be
%                 set (e.g., 'spk_2011117000000_2011119161803_kplr.bsp').
%
%     directory : If specified, perform the operation on the sub-tree of
%                 this directory. If not specified, start at the current
%                 working directory.
%
% Outputs:
%
%     files     : A cell array of strings giving the absolute paths of the
%                 files modified.
%
%     status    : A vector indicating whether the operation was successful
%                 (true) or not (false) for each file
%
% Dependencies:
%     Uses the UNIX 'find' utility to obtain a list of directories to
%     process.
%
% RLM, 5/4/2011
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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
if ~exist('directory', 'var')
    directory = pwd;
end

command = ['/bin/bash -c ''find ',directory,' -name ', filename, ' -print'''];
[returnVal, fileStr] = system(command);

files = {''};

nFiles = 0;
if returnVal == 0
    while true
        [filename, fileStr] = strtok(fileStr);
        if isempty(filename), break; end
        nFiles = nFiles + 1;
        files(nFiles) = {filename};
    end
else
    status = false;
    Warning(['Failure locating files ', filename, ' in directory ', directory]);
    return
end

status = [];  
for k = 1:nFiles
    try
        S = load(files{k});
        command = ['S.' FQfield ' = ''' fieldVal ''';' ];
        eval(command);
        command = ['save ' files{k} ' -struct S'];
        eval(command);
        status(k) = true;
    catch
        status(k) = false;
    end
end

return 