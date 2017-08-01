function motionPolyStruct = ...
    get_interp_motion_polys_and_write_uninterp_motion_blob( ...
        motionPolyStruct, paMotionFileName, cadenceTimes, cadenceType)
%************************************************************************** 
% function motionPolyStruct = ...
%     get_interp_motion_polys_and_write_uninterp_motion_blob( ...
%         motionPolyStruct, paMotionFileName, cadenceTimes, cadenceType)
%************************************************************************** 
% This function attempts to do two things: (1) interpolate across any
% gapped cadences in the input motionPolyStruct, and (2) write the
% un-interpolated motionPolyStruct to the output blob file. If the blob
% file already exists it is not overwritten. If the input motionPolyStruct
% is empty or not valid an empty array ([]) is returned and the blob file
% is not written.
%
% INPUT
%     motionPolyStruct : Considered a 'valid' motion polynomial array if it 
%                        is non-empty and satisfied the following criteria:
%                        (1) It contains more than one non-gapped cadence.
%                        (2) It consists of a single non-gapped cadence.
%
%     paMotionFileName : The name of the motion blob file to be written if
%                        a valid motionPolyStruct is provided.
%     cadenceTimes     : A timestamp struct (e.g.,
%                        paDataObject.cadenceTimes) 
%     cadenceType      : 'LONG' or 'SHORT'
%                        
% OUPUT
%     motionPolyStruct : An interpolated motion poly struct array if the
%                        input motionPolyStruct is valid. An empty array
%                        ([]) otherwise.
% 
% NOTES
%   - An empty motionPolyStruct in the paDataObject or pa_state.mat file
%     indicates that motion polynomials should be computed when possible.
%************************************************************************** 
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
    
    % Only write the output blob if it doesn't already exist and if there
    % is a valid motion polynomial struct to be written.
    if ~exist(paMotionFileName, 'file') && ~isempty(motionPolyStruct)
        motionPolyGapIndicators = ~logical([motionPolyStruct.rowPolyStatus]');
        nPolynomials = length(motionPolyGapIndicators);
        
        isValidMotionPolyStruct = sum(~motionPolyGapIndicators) > 1 || ...
            (sum(~motionPolyGapIndicators) == 1  && nPolynomials == 1);
        if isValidMotionPolyStruct
            struct_to_blob(motionPolyStruct, paMotionFileName);
        else
            motionPolyStruct = [];
        end
    end
    
    % Interpolate across gaps in motionPolyStruct. Interpolation requires
    % valid MP structures on at least two cadences. In the special case of
    % one cadence and one valid MP struct, do nothing.
    if ~isempty(motionPolyStruct)        
        motionPolyGapIndicators = ...
            ~logical([motionPolyStruct.rowPolyStatus]');
        if any(motionPolyGapIndicators) % We already verified above that, 
                                        % if there's more than one cadence, 
                                        % there are at least two valid MP 
                                        % structs.
            [motionPolyStruct] = ...
                interpolate_motion_polynomials(motionPolyStruct, ...
                cadenceTimes, strcmpi(cadenceType, 'LONG'));
        end
    end

end

