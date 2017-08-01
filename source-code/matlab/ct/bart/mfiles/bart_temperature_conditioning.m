function averagedTemperatures = bart_temperature_conditioning( selectedTemperatureStruct )
% function averagedTemperatures = bart_temperature_conditioning(
% selectedTemperatureStruct )
%
% Combine multiple temperature measurements from different mnemonics by
% averaging
%
%   Top Level Input
%
% selectedTemperatureStruct is an array of struct with the following fields:
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
%--------------------------------------------------------------------------
%
%   Top Level Output
%
%    averageTemperatures: [double array] mean temperature measurements of
%                     selected mnemnoics for each FFI
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

MsgID = 'CT:BART:bart_temperature_conditioning';

if ( nargin == 0 )
    error(MsgID, 'No valid input');
elseif ( isempty(selectedTemperatureStruct) || ~isstruct( selectedTemperatureStruct ) )
    error(MsgID, 'Input is not a struct or empty');
elseif ~all( isfield(selectedTemperatureStruct, {'temperatureMean', 'temperatureMnemonics'} ) )
    error(MsgID, 'Input struct has non existence fields');

end

% get the number of FFIs
nFFI = length( selectedTemperatureStruct );
averagedTemperatures = zeros(nFFI, 1);
for k=1:nFFI
    if isempty(selectedTemperatureStruct(k).temperatureMean) || ...
            isempty(selectedTemperatureStruct(k).temperatureMnemonics)
        error(MsgID, 'Input struct has empty fields');
    else
        nTemperatureTypes = size( selectedTemperatureStruct(k).temperatureMnemonics, 1 );
        [nRow, nTemperatureValues] = size( selectedTemperatureStruct(k).temperatureMean);

        if ( nTemperatureTypes >= 1 && nTemperatureTypes == nTemperatureValues && nRow == 1)
            % compute the mean across all mnemonics: Nan is preserved
            averagedTemperatures(k) = mean( [ selectedTemperatureStruct(k).temperatureMean ], 2);
        else
            error(MsgID, 'Incorrect temperature measurements or types!');
        end
    end
end

return