function errCount = verify_1d_black_blob_export(varargin)
% function errCount = verify_1d_black_blob_export(varargin)
% 
% This function checks the renamed 1d-black blobs for consistancy between blob contents and filename assuming the exported 1d-black blob
% filename format is (per KSOC-4889), i.e. kplr<YYYYDOYHHMMSS>-q<##>-<mmo>-dr<##>_1dblack.mat. An message is displayed to stdout and the
% errCount is incremented if a blob file is detected with an inconsistancy.
% 
% INPUTS:   varargin    == (optional) 
%                           [string] path to exported blob files. Terminate with separator.
%                           i.e. '/path/to/ksop-2440-export/export-1d-black/'
%                           If path is not specified the tool will search the run directory for blobs matching the filename format.
% OUTPUTS:  errCount    ==  [double] Count of files whose quarter, module or output contents do not match the identifiers in the filename.
%
% This function assumes that /path/to/matlab/common/mfiles is included in the MATLAB path.
% Author: Bruce Clarke, KSOP-2440, KSOC-4924
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

% initialize error count
errCount = 0;

% set pathname, file path and prefix
if nargin > 0
    pathname = varargin{1};
else
    pathname = '';
end

exportFilePrefix = 'kplr';
exportFileSuffix = '_1dblack.mat';

% locate quarter, module and output identifiers in filename
quarterIdx = 20:21;
moduleIdx = 23:24;
outputIdx = 25;

firstCadenceIdx = 1;

% find 1d-black blobs on given path
D = dir([pathname,exportFilePrefix,'*',exportFileSuffix]);
if isempty(D)
    disp('No kplr<YYYYDOYHHMMSS>-q<##>-<mmo>-dr<##>_1dblack.mat files found.');
    return;
end

% check the blob contents against the filename
for i=1:length(D)
    n = D(i).name;
    disp(['Checking ',n,' ...']);
    
    warning off all;
    load([pathname,n]);
    warning on all;
    
    q = str2double(D(i).name(quarterIdx));
    m = str2double(D(i).name(moduleIdx));
    o = str2double(D(i).name(outputIdx));
    Q = convert_from_cadence_to_quarter(inputStruct.cadences(firstCadenceIdx),'LONG');
    M = inputStruct.module;
    O = inputStruct.output;
   
    if m~=M || o~=O || q~=Q
        disp(['---------------- Error - Internal quarter = ',num2str(Q),' module = ',num2str(M),' output = ',num2str(O)]);
        errCount = errCount + 1;
    end
end

