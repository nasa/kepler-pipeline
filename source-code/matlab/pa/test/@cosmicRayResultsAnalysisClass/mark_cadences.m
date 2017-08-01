function p = mark_cadences(h, cadences, color, alpha)
%**************************************************************************  
% p = mark_cadences(h, cadences, color, alpha)
%**************************************************************************  
% 
% INPUTS:
%     h             : An axes handle or [] to use current axes.
%     cadences      : List of relative cadences (indices) to mark.
%     color         : A 3-element vector
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
    if ~any(cadences)
        return
    end

    if ~ishandle(h)
        h = gca;
    end
        
    if ~exist('color','var')
        color = [0.7 0.7 0.7];
    end

    if ~exist('alpha','var')
        alpha = 0.2;
    end
    
    axes(h);
    
    original_hold_state = ishold(h);
    if original_hold_state == false
        hold on
    end
    
    nCadences = length(cadences);
    xCoords = repmat(cadences(:)',4,1) + repmat([-0.5; 0.5; 0.5; - 0.5], 1, nCadences);
    xCoords = reshape(xCoords, 4*nCadences, 1);
    ylimits = get(h,'ylim');
    yCoords = repmat([ylimits(1); ylimits(1); ylimits(2); ylimits(2)], nCadences, 1);
    
    verts  = [xCoords, yCoords];
    nVerts = length(verts);
    nRect  = fix(nVerts/4);
    faces  = reshape([1:nVerts]', 4, nRect)';
    
    p = patch('Faces',faces,'Vertices',verts,'FaceColor',color,'facealpha',alpha,'linestyle','none');
    
%     xCoords = [cadences(:)-0.5, cadences(:)+0.5, cadences(:)+0.5, cadences(:)-0.5];
%     ylimits = get(h,'ylim');
%     yCoords = repmat([ylimits(1) ylimits(1) ylimits(2) ylimits(2)], [size(xCoords,1), 1]);
%     
%     a_ = fill(xCoords',yCoords',color, 'facealpha', alpha);
%     set(a_,'facecolor',color,'edgecolor', color,'linestyle','none');
    
    if original_hold_state == false
        hold off
    end
end