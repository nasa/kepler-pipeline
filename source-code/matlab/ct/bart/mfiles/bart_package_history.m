function bartHistoryStruct = bart_package_history(module, output, ...
   fitsFilenamesCell, ffiInfoStruct, temperature, dateGenerated, SWVersion, temperatureMnemonicsCell)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function bartHistoryStruct = bart_package_history(module, output, ...
%  cellFitsFilenames, structFfiInfo, temperature, dateGenerated, SWVersion)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% packs the bart processing history into a structure called
% bartHistoryStruct
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%  INPUT:
%
%                     module: [int] the ccd module
%                     output: [int] the ccd output
%              ffiInfoStruct: [struct] with the following fields -
%
%                               .STARTIME
%                               .END_TIME
%                               .NUM_FFI
%                               .DATA_TYPE
%                               .COMPLETENESS    
%
%          fitsFilenamesCell: [cell] with the ffi filenames in strings
%              dateGenerated: [string] in zulu time
%                  SWVersion: [string] the BART version number
%   temperatureMnemonicsCell: [cell] with the temperature mnemonics
%           
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% OUTPUT:
%
%          bartHistoryStruct: [struct] with the following fields -
%                               .module [int] the ccd module
%                               .output [int] the ccd output
%                               .midTime [struct] with fields .UTC and .MJD
%                               .fitsFilenames [cell] the filenames
%                               .temperature [double] avg temp for ea/ ffi
%                               .SWVersion [string] software version
%                               .dateGenerated [string] date the bart
%                                     model/diagnostics was generated
%           
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

% check number of input argumnets
if nargin ~= 8
    error('CT:BART:bart_package_history', '7 inputs required for making BART history')
end

% validate each input
% check valid module
if ~(any(module == [2:4, 6:20, 22:24])) && numel(module)~=1
    error('CT:BART:bart_package_history', 'invalid module')
end

% check valid output
if ~(any(output == 1:4)) && numel(module)~=1
    error('CT:BART:bart_package_history', 'invalid output')
end

% check fitsFileNamesCell are cell
if ~iscell(fitsFilenamesCell) 
    error('CT:BART:bart_package_history', 'filenames must be in cell format')
end

% check ffiInfoStruct
if ~isstruct(ffiInfoStruct)
    error('CT:BART:bart_package_history', 'ffiInfo must be a structure')
end

% check temperature
if ~isnumeric(temperature) && numel(temperature)~=1
    error('CT:BART:bart_package_history', 'invalid temperature')
end

% check dateGenerated
if ~ischar(dateGenerated)
    error('CT:BART:bart_package_history', 'time and date stamp must be string')
end

% check SW version
if ~ischar(SWVersion)
    error('CT:BART:bart_package_history', 'SW version must be string')
end


% create structure
bartHistoryStruct = struct('module', [], 'output', [], 'midTime', struct('UTC',{{}}, 'MJD', []), 'fitsFilenames', {{}},...
    'ffiInfo', [], 'temperatureMnemonics', {{}}, 'temperature', [], 'SWVersion', '', 'dateGenerated', '');




% get midpoint time in MJD

nFFI = length(ffiInfoStruct);

midMjd = zeros(nFFI,1);
for j = 1:nFFI    
midMjd(j,1) = (ffiInfoStruct(j).STARTIME + ffiInfoStruct(j).END_TIME)/2;
end
midUtc = mjd_to_utc(midMjd);

% assign inputs into structure
bartHistoryStruct.module = module;
bartHistoryStruct.output = output;
bartHistoryStruct.midTime.UTC = midUtc;
bartHistoryStruct.midTime.MJD = midMjd;
bartHistoryStruct.fitsFilenames = fitsFilenamesCell; 
bartHistoryStruct.ffiInfo = ffiInfoStruct;
bartHistoryStruct.temperatureMnemonics = temperatureMnemonicsCell;
bartHistoryStruct.temperature = temperature;
bartHistoryStruct.SWVersion = SWVersion;
bartHistoryStruct.dateGenerated = dateGenerated;

return
