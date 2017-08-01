function show_prf_iteration_results(location, type, channel)
% function show_prf_iteration_results(location, type, channel)
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

if nargin < 3
    nChannels = 1:84;
else
    nChannels = channel;
end

for c=nChannels
    switch(type)
        case 'all'
            open([location '/prfs_contour_channel_' num2str(c) '.fig']);
            set(gcf, 'Position', [1681 26 1920 1072]);
            open([location '/centroid_convergence_channel_' num2str(c) '.fig']);
            set(gcf, 'Position', [725   522   890   950]);
            open([location '/source_prf_contour_channel_' num2str(c) '.fig']);
            set(gcf, 'Position', [1   522   700   700]);
%             open([location '/delta_centroid_component_channel_' num2str(c) '.fig']);
%             set(gcf, 'Position', [1753         325        1831         773]);

        case 'prfs'
            open([location '/prfs_channel_' num2str(c) '.fig']);
            
        case 'contour'
            open([location '/prfs_contour_channel_' num2str(c) '.fig']);
            
        case 'convergence'
            open([location '/centroid_convergence_channel_' num2str(c) '.fig']);

        case 'deltaCentroid'
            open([location '/delta_centroid_component_channel_' num2str(c) '.fig']);
            set(gcf, 'Position', [1753          53        1831        1045]);

        case 'asBuilt'
            open([location '/source_prf_contour_channel_' num2str(c) '.fig']);

        otherwise
            disp(['dont know that one']);
    end
    if length(nChannels) > 1
        pause;
        close('all');
    end
end

