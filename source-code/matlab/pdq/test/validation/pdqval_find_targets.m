function matchingTargets = pdqval_find_targets(pdqInputStruct, labels, module, output, mode)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function targets = pdqval_find_targets(pdqInputStruct, labels, module, output, mode)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Finds and reports targets in a pdqInputStruct
%
% Inputs:
%
%     pdqInputStruct
%
%     labels    A string or cell array, usually containing one or more of
%               the following labels: 
%
%               PDQ_STELLAR
%               PDQ_BACKGROUND
%               PDQ_BLACK_COLLATERAL
%               PDQ_SMEAR_COLLATERAL
%               PDQ_DYNAMIC_RANGE
%
%               If empty or unspecified, all targets are considered a match.
%
%     module    If specified, search only time series from this module. If
%               empty, process all modules.
%
%     output    If specified, search only time series from this output. If
%               empty, process all outputs.
%
%     mode      If false, negate the sense of the matching on the specified
%               module outputs. Return a list of targets whose labels do
%               not match any of those specified. (default = true)
%
%
% Outputs:
%
%     targets   An N x 6 matrix in which each row indicates the location 
%               of a target in the input struct. Columns consist of
%               integers having the following meanings:
%
%                     [module, output, target_type, target_index]   
%            
%               and target types are 1=stellar, 2 = background,
%               3=collateral
%
% Notes:
%     Since the various target types are not necessarily mutually exclusive
%     (a pixel may belong to both a stellar target and a background target)
%     there may be multiple entries for the same gap, differing only in 
%     target type.
%
%     If any of a target's labels match any of the labels in the parameter 
%     'labels', the target is considered a match. 
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
    FIND_MATCHING = true;
    ALL = -1;
    targetFields = [ {'stellarPdqTargets'}; {'backgroundPdqTargets'}; ...
                     {'collateralPdqTargets'} ];

    if ~exist('labels','var')
        labels = {};
    end

    if ~exist('module','var') || isempty(module)
        module = ALL;
    end

    if ~exist('output','var') || isempty(output)
        output = ALL;
    end
    
    if ~exist('mode','var') || isempty(mode)
        mode = FIND_MATCHING;
    end

    matchingTargets = [];
    allTargets      = [];
    for i=1:numel(targetFields)
        targs = pdqInputStruct.(targetFields{i});
        nTargets = numel( targs );

        for j=1:nTargets
            if ((targs(j).ccdModule == module) || module == ALL) ...
                    && ((targs(j).ccdOutput == output) || output == ALL) 
                if isempty(labels) || any(ismember(targs(j).labels, labels));
                    matchingTargets = [matchingTargets; [targs(j).ccdModule targs(j).ccdOutput i j ]];
                end
                
                if mode ~= FIND_MATCHING
                    allTargets = [allTargets; [targs(j).ccdModule targs(j).ccdOutput i j ]];
                end
            end
        end
    end
    
    if mode ~= FIND_MATCHING
        retainIndicators = ~ismember(allTargets, matchingTargets, 'rows');
        matchingTargets = allTargets(retainIndicators, :);
    end

end
