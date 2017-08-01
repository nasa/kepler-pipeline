function Z = produce_dawg_background_summary( pathName, channelList, quarter )
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

background_fig_filenames = {'extreme_outliers_3D.fig',...
                            'extreme_outliers_median_over_cadences.fig',...
                            'mean_fitted_background_3D.fig',...
                            'mean_fitted_background_line.fig',...
                            'mad_background_residual_3D.fig',...
                            'mad_background_residual_median_over_cadences.fig',...
                            'median_background_residual_3D.fig',...
                            'median_background_residual_median_over_cadences.fig',...
                            'mad_background_pixel_uncertainty_3D.fig',...
                            'mad_background_pixel_uncertainty_median_over_cadences.fig',...
                            'median_background_pixel_uncertainty_3D.fig',...
                            'median_background_pixel_uncertainty_median_over_cadences.fig',...
                            'fitted_mean_background_image.fig',...
                            'fitted_mean_background_diff_from_median_image.fig',...
                            'median_background_residual_image.fig',...
                            'mad_background_residual'};
                            



% default does all channels if PA_taskMappingFilename is also specified 
% if PA_taskMappingFilename is not specified, do all channels (directories)
% under pathname
if ~exist('channelList', 'var')
    channelList = 1:84;
end

% If a quarter was not specified, passing an empty array to get_group_dir()
% will cause it to default to the earliest available quarter under
% 'pathName'.
if ~exist('quarter', 'var')
    quarter = [];
end

Z = collect_dawg_background_metrics( pathName, channelList, quarter );

close all;
plot_dawg_background_metrics( Z );

% save plots to local directory
for i=1:length(background_fig_filenames)
    figure(i);
    saveas(gcf,background_fig_filenames{i},'fig');
end