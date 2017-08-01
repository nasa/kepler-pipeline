function inputsStruct = tip_convert_90_data_to_91(inputsStruct)
%
% function inputsStruct = tip_convert_90_data_to_91(inputsStruct)
%
% This function converts a SOC 9.0 TIP inputsStruct to one used in the SOC
% 9.1 build.
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


TIP_OUTPUT_FILENAME = 'transit-injection-parameters.txt';
EPOCH_ZERO_TIME = kjd_offset_from_mjd + 65;                             % 07-Mar-2009 12:00:00 Z

% update simulation config struct
if isfield(inputsStruct, 'simulatedTransitsConfigurationStruct')
    
    simulatedTransitsConfigurationStruct = inputsStruct.simulatedTransitsConfigurationStruct;
    
    % move output filename to sim configuration
    if isfield(simulatedTransitsConfigurationStruct, 'parameterOutputFilename')
        TIP_OUTPUT_FILENAME = simulatedTransitsConfigurationStruct.parameterOutputFilename;
        simulatedTransitsConfigurationStruct = rmfield(simulatedTransitsConfigurationStruct,'parameterOutputFilename');
    end
    
    if ~isfield(inputsStruct,'parameterOutputFilename')
        inputsStruct.parameterOutputFilename = TIP_OUTPUT_FILENAME;
    end    

    % base kepler time for epochs
    if ~isfield(simulatedTransitsConfigurationStruct, 'epochZeroTimeMjd')
        simulatedTransitsConfigurationStruct.epochZeroTimeMjd = EPOCH_ZERO_TIME;
    end
    
    % add random seed by clock enable
    if ~isfield(simulatedTransitsConfigurationStruct, 'randomSeedFromClockEnabled')
        simulatedTransitsConfigurationStruct.randomSeedFromClockEnabled = true;
    end
    
    % add random seed by skygroup list
    if ~isfield(simulatedTransitsConfigurationStruct, 'randomSeedBySkygroup')
        simulatedTransitsConfigurationStruct.randomSeedBySkygroup = (1 : 84)';
    end
    
    inputsStruct.simulatedTransitsConfigurationStruct = simulatedTransitsConfigurationStruct;
end

