function outputStruct = ffi_barycentric_correction(inputsStruct)
%
% outputStruct = ar_ffi_barycentric_correction_matlab_controller(inputStruct)
%
% INPUTS:
%     inpustStruct: A struct containing fields:
%         debugFlag                 A boolean flag to signal debug
%         ccdModule                 The CCD module for this unit of work
%         ccdOutput                 The CCD output for this unit of work.
%         configMaps                A PA configMap struct 
%         fcConstants               An FcConstants object
%         raDec2PixModel            A RaDec2Pix model
%         ffiBarycentricCorrectionInputs struct
%             perform          logical. When true this computation should be peformed.
%             referenceMjd     The MJD that the FFI was taken at.
%             ccdRow           The center row of the FFI.
%             ccdColumn        The center column of the FFI.
%
% OUTPUTS:
%       outputStruct struct.
%             keplerId                  int. This is just a place holder to make this type match the Java type.
%             barycentricTimeOffsets     The barycentric time offset vector
%                                       for this target.  This should be a length of 1 or 0.
%             barycentricGapIndicator   A gap indicator vector for the time offsets.   This should be a length of 1 or 0.
%             raDecimalHours            The ra of reference coordinate, in hours.
%             decDecimalDegrees         The dec of reference coordinate, in degrees.
%
% DESCRIPTION:
%     The controller generates the barycentric correction value for an FFI at the time it was taken.
% 
% Copyright 2017 United States Government as represented by the
% Administrator of the National Aeronautics and Space Administration.
% All Rights Reserved.
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
bcInputs = inputsStruct.ffiBarycentricCorrectionInputs;
if ~ bcInputs.perform 
    outputStruct.keplerId = -1;
    outputStruct.barycentricTimeOffsets = zeros(0);
    outputStruct.barycentricGapIndicator = zeros(0);
    outputStruct.raDecimalHours = 0;
    outputStruct.decDecimalDegrees = 0;
else
    
    % Get the ra/dec at that MJD:
    %
    raDec2PixObject = raDec2PixClass(inputsStruct.raDec2PixModel, 'one-based');
    [ra dec] = pix_2_ra_dec(raDec2PixObject, ...
                               inputsStruct.ccdModule, inputsStruct.ccdOutput, ....
                               bcInputs.ccdRow+1, bcInputs.ccdColumn+1, ...
                               bcInputs.referenceMjd); % input struct row/col are zero-based
    
    baryResults = ar_compute_barycentric_offset_for_ffi(inputsStruct.configMaps, inputsStruct.ccdModule, inputsStruct.fcConstants, ...
                                                        ra, dec, bcInputs.referenceMjd, raDec2PixObject);
    % TODO:  not sure what dimension baryResults.values is going to be. 
    outputStruct.barycentricTimeOffsets = baryResults.barycentricTimeOffset.values;
    outputStruct.barycentricGapIndicator = zeros(1);
    outputStruct.raDecimalHours = ra * 24.0 / 360.0;
    outputStruct.decDecimalDegrees = dec;
    outputStruct.keplerId = -1; % needed by the Java side object
end % ~ bcInputs.perform
return

function baryResults = ar_compute_barycentric_offset_for_ffi(configMaps, ccdModule, fcConstants, ra, dec, mjdTimestamp, raDec2PixObject)
    
    % Get the readout offset for the ccdModule
    %
    readoutOffset = get_readout_offset(configMaps, ccdModule, fcConstants);


    % Get the barycentric offset for this FFI's time:
    %
    [barycentricTimestamps] = kepler_time_to_barycentric(raDec2PixObject, ra, dec, mjdTimestamp - readoutOffset);
    values = barycentricTimestamps(:) - mjdTimestamp;
    baryResults.barycentricTimeOffset.values = values;
return
