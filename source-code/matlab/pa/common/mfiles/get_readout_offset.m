function [readoutOffsetDays nSlice] = get_readout_offset(configMap, ccdModule, fcConstants)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [readoutOffsetDays nSlice] = get_readout_offset(configMap, ccdModule, fcConstants)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Obtains the readout offset time according to ccd module number.  
% The readout offset is calculated as follows: 
%
%               2.5*(FGSFRPER) + 6*(FGSFRPER)*(5 - nSlice) 
%
% where FGSFRPER is the FGS frame period in milliseconds and nSlice is the
% slice number or readout sequence as defined in FPAReadoutSequence.pdf.
%
% ReadoutOffsetDays is in unit of days to preserve compatibility 
% with barycentric corrections.
%
%  NOTE: readoutOffsetDays is a positive number, with highest magnitude for
%  the time slices that get read first.  For exaple offset_for_slice 1 >
%  offset_for_slice 2 >... offset_for_slice 5.
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

MILLISECOND_TO_SECOND = 1/1000;
SECOND_TO_DAY = get_unit_conversion('sec2day');

% Instantiate configMapObject and get fgs frame period
% Consistency check done in the getter
configMapObject = configMapClass(configMap);
FGSFRPER = get_fgs_frame_period(configMapObject);

% Find the time slice for the given ccdModule
switch true
    
    case ~isempty(find(fcConstants.signalProcessingOrderTimeSlice1 == ccdModule, 1))
        
        nSlice = 1;
        
    case ~isempty(find(fcConstants.signalProcessingOrderTimeSlice2 == ccdModule, 1))
        
        nSlice = 2;
        
    case ~isempty(find(fcConstants.signalProcessingOrderTimeSlice3 == ccdModule, 1))
        
        nSlice = 3;
        
    case ~isempty(find(fcConstants.signalProcessingOrderTimeSlice4 == ccdModule, 1))
        
        nSlice = 4;
        
    case ~isempty(find(fcConstants.signalProcessingOrderTimeSlice5 == ccdModule, 1))
        
        nSlice = 5;
        
    otherwise
        
        error('Invalid ccd Module')
end

readoutOffsetDays = ...
    (2.5*(FGSFRPER) + 6*(FGSFRPER).*(5-nSlice))*MILLISECOND_TO_SECOND*SECOND_TO_DAY;



return
