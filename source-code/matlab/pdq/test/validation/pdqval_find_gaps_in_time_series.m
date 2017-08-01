function gaps = pdqval_find_gaps_in_time_series(pdqInputStruct, module, output)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function gaps = pdqval_find_gaps_in_time_series(pdqInputStruct, module, output)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Finds and reports gapped cadences in a pdqInputStruct
%
% ARGUMENTS:
%     module    If specified, search only time series from this module. If
%               equal to -1, process all modules.
%     output    If specified, search only time series from this output. If
%               equal to -1, process all outputs.
%
% OUTPUT:
%     gaps      An N x 6 matrix in which each row indicates the location 
%               of a gap in the reference pixel data. Columns consist of
%               integers having the following meanings:
%
%       [module, output, target_type, target_index, pixel_index, gap_index]   
%            
%               and target types are 1=stellar, 2 = background, 3=black
%               4=smear
%
% Notes:
%     Since the various target types are not necessarily mutually exclusive
%     (a pixel may belong to both a stellar target and a background target)
%     there may be multiple entries for the same gap, differing only in 
%     target type.
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
ALL = -1;
targetFields = [ {'stellarPdqTargets'}; {'backgroundPdqTargets'}; {'collateralPdqTargets'} ];
targetTypes = [ {'PDQ_STELLAR'}; {'PDQ_BACKGROUND'}; {'PDQ_BLACK_COLLATERAL'}; {'PDQ_SMEAR_COLLATERAL'} ];

if nargin < 3
    output = ALL;
end
if nargin < 2
    module = ALL;
end

gaps = [];
for i=1:numel(targetFields)
    targs = pdqInputStruct.(targetFields{i});
    nTargets = numel( targs );
    
    for j=1:nTargets
        if ((targs(j).ccdModule == module) || module == ALL) ...
                && ((targs(j).ccdOutput == output) || output == ALL) 
            label = targs(j).labels; % If more than one label, take the first one
            type = find(strcmp(label, targetTypes));
            
            pix = targs(j).referencePixels;
            nPixels = numel( pix );
            for k=1:nPixels
                gapIndices = find(pix(k).gapIndicators);
                if ~isempty( gapIndices )
                    for n = 1:numel(gapIndices)
                        gaps = [gaps; [targs(j).ccdModule targs(j).ccdOutput type j k gapIndices(n) ]];
                    end
                end
            end
        end
    end
end

return