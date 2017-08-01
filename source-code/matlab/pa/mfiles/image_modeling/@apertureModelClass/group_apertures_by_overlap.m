function [groupsByKepId, groupsByIndex] = group_apertures_by_overlap(targetArray)
%**************************************************************************
% Return cell arrays containing connected groups of overlapping masks.
%
% INPUTS
%     targetArray
%
% OUTPUTS
%     groupsByKepId : A cell array, each element containing an array of
%                     kepler IDs whose masks form a contiguous overlapping
%                     group. 
%     groupsByIndex : A cell array, each element containing an array of
%                     target indices whose masks form a contiguous 
%                     overlapping group. 
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
    nTargets    = length(targetArray);
    targetMasks = cell(nTargets,1);
    keplerIds   = [targetArray.keplerId]';
    
    % Extract masks for each target.
    for iTarget = 1:nTargets
        r = [targetArray(iTarget).pixelDataStruct.ccdRow];
        c = [targetArray(iTarget).pixelDataStruct.ccdColumn];
        mask = complex(r, c);
        targetMasks{iTarget} = mask;
    end
    
    % Construct a connectivity graph.
    %
    % overlapMat is an upper triangular nTargets-by-nTargets logical matrix
    % whose values indicate overlap (or lack thereof) between pairs of
    % targets. A value of 'true' at overlapMat(i,j) indicates the pixel
    % masks of targetArray(i) and targetArray(j) contain at least one pixel
    % in common. Note that all values on the main diagonal and below are
    % logical zeros. 
    fh = @(x, y)(~isempty(intersect(x, y)));
    overlapMat = ...
        cellfun(fh, repmat(targetMasks,[1, nTargets]), ...
                    repmat(targetMasks,[1, nTargets])', ...
                    'UniformOutput', true);
    overlapMat = triu(overlapMat, 0); % Return the upper triangular matrix 
                                      % excluding the main diagonal.                
                
    % Find connected components in the connectivity graph.
    membership = graph_connected_components(overlapMat);
    
    % Construct output arrays of target indices and Kepler Ids for each
    % group.
    groupLabels   = unique(membership);
    nGroups       = length(groupLabels);
    groupsByIndex = cell(nGroups, 1);
    groupsByKepId = cell(nGroups, 1);
    
    for iGroup = 1:nGroups
        groupsByIndex{iGroup} = find(membership == groupLabels(iGroup));
        groupsByKepId{iGroup} = keplerIds(groupsByIndex{iGroup});
    end
   
end


function [labels rts] = graph_connected_components(C)
%**************************************************************************
% THIS FUNCTION OBTAINED FROM
% http://www.mathworks.com/matlabcentral/fileexchange/33877-find-graph-conected-components/content/zz_test_graph_connected_components_picture.m
%**************************************************************************
% C - connection matrix
% labels =[1 1 1 2 2 3 3 ...]  lenght(labels)=L, label for each vertex
% labels(i) is order number of connected component, i is vertex number
% rts - roots, numbers of started vertex in each component
%**************************************************************************
    L=size(C,1); % number of vertex

    % Breadth-first search:
    labels=zeros(1,L); % all vertex unexplored at the begining
    rts=[];
    ccc=0; % connected components counter
    while true
        ind=find(labels==0);
        if ~isempty(ind)
            fue=ind(1); % first unexplored vertex
            rts=[rts fue];
            list=[fue];
            ccc=ccc+1;
            labels(fue)=ccc;
            while true
                list_new=[];
                for lc=1:length(list)
                    p=list(lc); % point
                    cp=find(C(p,:)); % points connected to p
                    cp1=cp(labels(cp)==0); % get only unexplored vertecies
                    labels(cp1)=ccc;
                    list_new=[list_new cp1];
                end
                list=list_new;
                if isempty(list)
                    break;
                end
            end
        else
            break;
        end
    end
end
%********************************* EOF ************************************