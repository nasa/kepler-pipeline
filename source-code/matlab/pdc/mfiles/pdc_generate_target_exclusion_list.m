% function targetDataStruct = pdc_generate_target_exclusion_list( targetDataStruct , excludeTargetLabels )
%
% generates a logical index for targets to exclude from the calculation of the goodness metric
% (and maybe other things later as well)
% the exclusion is based on:
%    targetDataStruct().labels
%    excludeTargetLabels
% a target n is excluded if and only if 
%   ~isempty( intersect(targetDataStruct(n).labels , excludeTargetLabels ) )
%
% note that for targets for which no label was provided (pre 8.0) and which has a keplerId >= 100e6,
% the label LEGACY_CUSTOM is added in pdc_convert_70_data_to_80, and this is always internally in excludeTargetLabels
%
% INPUTs used in targetDataStruct:
%   .labels
% OUTPUTS changed in targetDataStruct:
%   .excludeBasedOnLabels
%
%
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

function targetDataStruct = pdc_generate_target_exclusion_list( targetDataStruct , excludeTargetLabels )

    nTargets = length(targetDataStruct);

    isCustomTargetArray = is_valid_id([targetDataStruct.keplerId], 'custom');

    for i=1:nTargets
        
        % check exclusion list
        targetDataStruct(i).excludeBasedOnLabels = ~isempty( intersect(targetDataStruct(i).labels , excludeTargetLabels ) );
        
        % Always exclude LEGACY_CUSTOM targets
        % this is for cases where labels were not provided in the inputs, but kepId is >= 100e6 (pre 8.0)
        % 100e6 <= keplerId < 200e6 (post K2)
        % Always exclude K2_LEGACY_CUSTOM targets
        % 200e6 <= keplerId < 201e6
        if (any(ismember(targetDataStruct(i).labels,'LEGACY_CUSTOM'))||...
                any(ismember(targetDataStruct(i).labels,'K2_LEGACY_CUSTOM')))
            targetDataStruct(i).excludeBasedOnLabels = true;
        end
        
        % KSOC-4756
        % Exclude all custom targets based on ID range.
        % This should happen for both Kepler and K2
        if (isCustomTargetArray(i))
            targetDataStruct(i).excludeBasedOnLabels = true;
        end
        
    end

    
    
end
