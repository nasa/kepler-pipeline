function targetArray = fill_missing_target_ra_dec( targetArray, ...
    motionPolyStruct, fcConstants, processingK2Data )
%**************************************************************************
% function targetArray = fill_missing_target_ra_dec( targetArray, ...
%    motionPolyStruct, fcConstants, processingK2Data )
%**************************************************************************
% Handle custom targets with missing RA and/or Dec by using the aperture
% centroid in place of the target centroid. Only custom targets can have
% NaN values for keplerMag, raHours and decDegrees (see
% validate_pa_inputs.m).
%
% NOTES
%     When processing Kepler prime data, RA and Dec values of zero are
%     considered "missing" since they are outside the FOV. There was a
%     Java-side bug in certain pre-9.3 releases whereby RA and Dec fields
%     were populated with zeros.
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
    ra  = [targetArray.raHours];
    dec = [targetArray.decDegrees];
    
    % Note that, when processing Kepler prime data, RA and Dec values of
    % zero are considered "missing" since they are outside the FOV. There
    % was a Java-side bug in certain pre-9.3 releases whereby RA and Dec
    % fields were populated with zeros.     
    if processingK2Data
        % This data set contains K2 data.
        missingRaDecIndices = find(~isfinite(ra) | ~isfinite(dec));
    else
        % This data is from the Kepler primary mission.
        missingRaDecIndices = find(~isfinite(ra) | ~isfinite(dec) | ra <= 0 | dec <=0);
    end
    
    covarianceRowCol = zeros(2); % Dummy argument for invert_motion_polynomial
    for k = 1:length(missingRaDecIndices)
        ind = missingRaDecIndices(k);
        meanRow = mean([targetArray(ind).pixelDataStruct.ccdRow]);
        meanCol = mean([targetArray(ind).pixelDataStruct.ccdColumn]);
        [raDegrees, decDegrees] ...
            = invert_motion_polynomial(meanRow, ...
                                       meanCol, ...
                                       motionPolyStruct(1), ...
                                       covarianceRowCol, ...
                                       fcConstants); 
        targetArray(ind).raHours    = raDegrees * 24/360;
        targetArray(ind).decDegrees = decDegrees;
    end
end
        
%********************************** EOF ***********************************