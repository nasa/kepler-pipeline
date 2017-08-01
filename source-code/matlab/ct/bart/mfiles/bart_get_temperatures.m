function selectedTemperatureStruct = bart_get_temperatures( ffiInfoStruct, temperatureMnemonicPair )
% function selectedTemperatureStruct = bart_get_temperatures(
% ffiInfoStruct, temperatureMnemonics, moduleIndex, outputIndex )
%
% Retrieve temperature measurements for the selected mnemonics using
% timestamps as specified in ffiInfoStruct.
%
% bart_get_temperatures.
%
%   Top Level Input
%
%      ffiInfoStruct: [array struct] time stamps, image type and coadds of the FFIs
% temperatureMnemonics: [cell array] list of temperature mnemonic pairs: value and status.
%
%
%   Second level
%
%   ffiInfoStruct is aa array of structure with the following fields:
%
%                  STARTIME: [double] the start time in MJD
%                  END_TIME: [double] the end time in MJD
%                      NUM_FFI: [int] the number of coadds
%                  DATATYPE: [string] is either 'ffi' or 'long cadence'
%--------------------------------------------------------------------------
%
%   Top Level Output
%
% selectedTemperatureStruct is a struct with the following fields:
%
%    temperatureMean: [double array] mean temperature measurements for each
%                      pair of mnemonics and FFI
%     temperatureStd: [double array] std of temperature measurements for
%                      each pair of mnemonics and FFI
%    temperatureSamples: [int array] number of temperature measurements for
%                      each pair of mnemonics and FFI
% temperatureMnemonics: [cell array] list of temperature mnemonics, e.g.
%                        {'PEDDRV1T', 'PEDACQ4T'}
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

MsgID = 'CT:BART:bart_get_temperatures';

if ( isempty(ffiInfoStruct) || ~isstruct( ffiInfoStruct) )
    error(MsgID, 'Input argument ffiInfoStruct is not a valid struct');
elseif ~all( isfield(ffiInfoStruct, {'STARTIME', 'END_TIME'}) )
    error(MsgID, 'Input argument ffiInfoStruct has invalid fields');
end

% check the temperature mnemonics
if ( isempty(temperatureMnemonicPair) || ~iscell(temperatureMnemonicPair) )
    error(MsgID, 'Input argument temperatureMnemonics is not a valid cell');
else
    % expecting a column vector of mnemonics
    [nMnemonics, nCols] = size( temperatureMnemonicPair);

    if ~( nCols == 2 && nMnemonics > 0 )
        error(MsgID, 'Temperature menmonics error in size');
    else
        temperatureMnemonics = temperatureMnemonicPair(:, 1);
        temperatureStatusMnemonics = temperatureMnemonicPair(:, 2);
    end
end

% validate the temperatureMnemonics: get all 73 mnemonics??

% the number of FFI
nFFI = length(ffiInfoStruct);

oneTemperatureStruct = struct( ...
    'temperatureMean',      [], ...
    'temperatureStd',       [], ...
    'temperatureSamples',   [], ...
    'temperatureMnemonics', [] ...
    );

% the output of temperature measurements
oneTemperatureStruct.temperatureMnemonics = temperatureMnemonics;
oneTemperatureStruc.temperatureMean    = zeros(nMnemonics, 1);
oneTemperatureStruc.temperatureStd     = zeros(nMnemonics, 1);
oneTemperatureStruc.temperatureSamples = zeros(nMnemonics, 1);

selectedTemperatureStruct = repmat(oneTemperatureStruct, nFFI, 1);

for k=1:nFFI
    try
        temperatureValues = retrieve_ancillary_data(temperatureMnemonics, ffiInfoStruct(k).STARTIME, ffiInfoStruct(k).END_TIME);
        temperatureStatus = retrieve_ancillary_data(temperatureStatusMnemonics, ffiInfoStruct(k).STARTIME, ffiInfoStruct(k).END_TIME);
    catch
        %disp(temperatureMnemonics);
        %disp(temperatureStatusMnemonics);
        lastError = lasterror();

        disp(['Error ID: ' lastError.identifier]);
        disp(['Error Msg: ' lastError.message]);
        error('Error with retrieve_ancillary_data()');
    end

    % check invalid measurements
    for t=1:nMnemonics
        % assign 'NaN' to invalid temperature values
        validTemperatureValues = temperatureValues(t).values( temperatureStatus(t).values ) ;

        nValidTemperatureValues = length(validTemperatureValues);
        if ( nValidTemperatureValues > 0 )
            % calculate the mean by excluding the unavailable measurements
            selectedTemperatureStruct(k).temperatureMean(t)    = mean(validTemperatureValues);
            selectedTemperatureStruct(k).temperatureStd(t)     = std(validTemperatureValues);
            selectedTemperatureStruct(k).temperatureSamples(t) = nValidTemperatureValues;
        else
            selectedTemperatureStruct(k).temperatureMean(t)    = NaN;
            selectedTemperatureStruct(k).temperatureStd(t)     = NaN;
            selectedTemperatureStruct(k).temperatureSamples(t) = 0;
            warning(MsgID, ['FITS input ' num2str(k) ' has no temperature measurements for mnemonics ' temperatureMnemonics{t} ]);
        end
    end
end

return