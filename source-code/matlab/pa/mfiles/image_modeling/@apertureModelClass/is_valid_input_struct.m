function isValid = is_valid_input_struct( apertureModelInputStruct )
%**************************************************************************
% isValid = is_valid_input_struct( apertureModelInputStruct )
%**************************************************************************
% Validate an apertureModelClass input structure. 
%
% INPUTS
%     apertureModelInputStruct
%
% OUTPUTS
%     isValid : A logical scalar. True if apertureModelInputStruct is valid
%               and false otherwise.
%
% NOTES
%     This function does not validate the configuration struct, since that
%     is done during the validation step in the CSCI matlab controller.
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

    isValid = true;
    
    expectedFields = {'configStruct', 'targetArray', 'midTimestamps', ...
        'catalog', 'prfModelObject', 'motionModelObject', 'debugLevel'};
    
    if ~all(isfield(apertureModelInputStruct, expectedFields))
        isValid = false;
        return;        
    end
    
    % Make sure motion and PRF models exist.
    if isempty(apertureModelInputStruct.motionModelObject) || ...
       isempty(apertureModelInputStruct.motionModelObject.get_motion_polynomials())
        isValid = false;
        return;
    else
        nMotionPolys = numel(apertureModelInputStruct.motionModelObject.get_motion_polynomials());
    end
    
    if isempty(apertureModelInputStruct.prfModelObject)
        isValid = false;
        return;
    end
    
    % Check to see whether RAs and Decs are missing for any targets.
    % Usually this is indicated by NaN values, but for Kepler we also need
    % to make sure RAs and Decs are non-zero. This is because (1) there was
    % a bug in in some versions of the pipeline which caused RA and Dec to
    % be set to zero, and (2) in the Kepler prime mission the field of view
    % did not intersect RA = 0 or Dec = 0.
    targetArray = apertureModelInputStruct.targetArray;
    for iTarget = 1:numel(targetArray)
        if ~isfinite(targetArray.raHours) || ~isfinite(targetArray.decDegrees)
            isValid = false;
            return;
        end
        
        if is_valid_id(targetArray.keplerId, 'kepler') ...
           && (targetArray.raHours == 0 || targetArray.decDegrees == 0)
            isValid = false;            
            return;
        end
    end
    
    
    % Check whether cadence numbers are in agreement for all fields.
    nCadences   = length(targetArray(1).pixelDataStruct(1).values);
    nTimestamps = length(apertureModelInputStruct.midTimestamps);
    if ~isequal(nMotionPolys, nCadences, nTimestamps)
        isValid = false;            
        return;        
    end
end

