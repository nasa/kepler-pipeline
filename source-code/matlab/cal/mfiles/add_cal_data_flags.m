function [calInputStruct] = add_cal_data_flags(calInputStruct)
%function [calInputStruct] = add_cal_data_flags(calInputStruct)
%
% This function adds a the structure dataFlags containing CAL data flags to the calInputsStruct.
% These data flags are used throughout CAL code.
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


% add 'timestamp' field (legacy field required by some CAL functions)
calInputStruct.cadenceTimes.timestamp = calInputStruct.cadenceTimes.midTimestamps;

% extract cadence type string, blackAlgorithm and lastValidKeplerMjd
cadenceType = calInputStruct.cadenceType;
blackAlgorithm = calInputStruct.moduleParametersStruct.blackAlgorithm;
lastValidKeplerMjd = calInputStruct.fcConstants.KEPLER_END_OF_MISSION_MJD;


%--------------------------------------------------------------------------
% create flags to determine which data types (LC, SC, or FFI) are processed
% in this invocation
%--------------------------------------------------------------------------
if (strcmpi(cadenceType, 'long'))
    
    processLongCadence  = true;
    processShortCadence = false;
    processFFI          = false;
    
elseif (strcmpi(cadenceType, 'short'))
    
    processLongCadence  = false;
    processShortCadence = true;
    processFFI          = false;
    
elseif (strcmpi(cadenceType, 'ffi'))
    
    processLongCadence  = true;
    processShortCadence = false;
    processFFI          = true;
end


%--------------------------------------------------------------------------
% create flags to determine which pixel types are available in this
% invocation
%--------------------------------------------------------------------------
isAvailableBlackPix         = ~isempty(calInputStruct.blackPixels);
isAvailableMaskedBlackPix   = ~isempty(calInputStruct.maskedBlackPixels);
isAvailableVirtualBlackPix  = ~isempty(calInputStruct.virtualBlackPixels);
isAvailableMaskedSmearPix   = ~isempty(calInputStruct.maskedSmearPixels);
isAvailableVirtualSmearPix  = ~isempty(calInputStruct.virtualSmearPixels);

isAvailableTargetAndBkgPix  = ~isempty(calInputStruct.targetAndBkgPixels);
isAvailableTwoDBlackIds     = ~isempty(calInputStruct.twoDBlackIds);
isAvailableLdeUndershootIds = ~isempty(calInputStruct.ldeUndershootIds);

isAvailableFfiPix           = ~isempty(calInputStruct.ffis);

isAvailableTwoDCollateral   = ~isempty([calInputStruct.twoDCollateral.blackStruct.pixels]) || ...
    ~isempty([calInputStruct.twoDCollateral.maskedSmearStruct.pixels]) || ...
    ~isempty([calInputStruct.twoDCollateral.virtualSmearStruct.pixels]);


%--------------------------------------------------------------------------
% Add flags to determine which 2D black and 1D black fits should be used based on
% the module parameter blackAlgorithm. Both polynomialOneDBlack and exponentialOneDBlack
% algorithms refer to the method used to fit the 1D black and assume static 2D black
% correction has already been done (dynamic2DBlackEnabled  = false). The dynablack
% algorithm uses dynamic 2D black correction for all pixels and no separate 1D black
% correction is needed. The 1D black fit is already included in the dynamic black correction.
%--------------------------------------------------------------------------
switch blackAlgorithm
    case 'polynomialOneDBlack'
        performExpLc1DblackFit = false;
        performExpSc1DblackFit = false;
        dynamic2DBlackEnabled  = false;
    case 'exponentialOneDBlack'        
        performExpLc1DblackFit = true && processLongCadence;
        performExpSc1DblackFit = true && processShortCadence;
        dynamic2DBlackEnabled  = false;
    case 'dynablack'
        performExpLc1DblackFit = false;
        performExpSc1DblackFit = false;
        dynamic2DBlackEnabled  = true;
    otherwise
        err = MException('','Invalid blackAlgorithm "%s".', blackAlgorithm);
        throw(err);
end


%--------------------------------------------------------------------------
% collect flags in dataFlags structure
%--------------------------------------------------------------------------
calInputStruct.dataFlags.cadenceType                 = cadenceType;
calInputStruct.dataFlags.processLongCadence          = processLongCadence;
calInputStruct.dataFlags.processShortCadence         = processShortCadence;
calInputStruct.dataFlags.processFFI                  = processFFI;

calInputStruct.dataFlags.isAvailableBlackPix         = isAvailableBlackPix;
calInputStruct.dataFlags.isAvailableMaskedBlackPix   = isAvailableMaskedBlackPix;
calInputStruct.dataFlags.isAvailableVirtualBlackPix  = isAvailableVirtualBlackPix;
calInputStruct.dataFlags.isAvailableMaskedSmearPix   = isAvailableMaskedSmearPix;
calInputStruct.dataFlags.isAvailableVirtualSmearPix  = isAvailableVirtualSmearPix;
calInputStruct.dataFlags.isAvailableTargetAndBkgPix  = isAvailableTargetAndBkgPix;
calInputStruct.dataFlags.isAvailableTwoDBlackIds     = isAvailableTwoDBlackIds;
calInputStruct.dataFlags.isAvailableLdeUndershootIds = isAvailableLdeUndershootIds;
calInputStruct.dataFlags.isAvailableFfiPix           = isAvailableFfiPix;
calInputStruct.dataFlags.isAvailableTwoDCollateral   = isAvailableTwoDCollateral;

calInputStruct.dataFlags.dynamic2DBlackEnabled       = dynamic2DBlackEnabled;
calInputStruct.dataFlags.performExpLc1DblackFit      = performExpLc1DblackFit; 
calInputStruct.dataFlags.performExpSc1DblackFit      = performExpSc1DblackFit;

% set K2 UOW boolean by checking first ungapped midTimestamp against KEPLER_END_OF_MISSION_MJD
firstUngappedIndex = find(~calInputStruct.cadenceTimes.gapIndicators, 1, 'first');
if ~isempty(firstUngappedIndex)
    calInputStruct.dataFlags.isK2UnitOfWork = calInputStruct.cadenceTimes.midTimestamps(firstUngappedIndex) > lastValidKeplerMjd;
else
    display('Gap indicators set for all cadences. Setting isK2UnitOfWork = false as default.');
    calInputStruct.dataFlags.isK2UnitOfWork = false;
end

return;
