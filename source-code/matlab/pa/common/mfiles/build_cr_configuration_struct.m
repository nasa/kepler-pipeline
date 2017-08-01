function cosmicRayConfigurationStruct = build_cr_configuration_struct()
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function cosmicRayConfigurationStruct = build_cr_configuration_struct()
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% build a default configuration structure to control cosmic ray cleaning
%
% output: cosmic ray configuration structure 
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


% threshold for the identification of cosmic rays as positive outliers, as
% multiple of local standard deviation
% used in clean_cosmic_ray_from_time_series()
cosmicRayConfigurationStruct.threshold = 3.0;
% half-window size used in computing local standard deviation
% used in clean_cosmic_ray_from_time_series()
cosmicRayConfigurationStruct.localSdWindow = 100;
% # of iterations to use in computing local standard deviation
% used in clean_cosmic_ray_from_time_series()
cosmicRayConfigurationStruct.localSdIterations = 3;
% order of polynomial used to estimate local second derivative for partition by
% curvature
% used in clean_cosmic_ray_from_target()
cosmicRayConfigurationStruct.curvaturePartitionOrder = 3;
% half-window of data used to estimate local second derivative for
% partition by curvature
% used in clean_cosmic_ray_from_target()
cosmicRayConfigurationStruct.curvaturePartitionWindow = 5;
% threshold for partition by curvature, where a partition is created if the
% local second derivative (curvature) is smaller than threhold * local
% median
% used in clean_cosmic_ray_from_target()
cosmicRayConfigurationStruct.curvaturePartitionThreshold = 20;
% smallest region or negative curvature to consider for creating a
% partition
% used in clean_cosmic_ray_from_target()
cosmicRayConfigurationStruct.curvaturePartitionSmallestRegion = 5;
% half-window size for detrending
% used in detrend_time_series()
cosmicRayConfigurationStruct.detrendWindow = 40;
% order of polynomial used in detrending when the window is small
% used in detrend_time_series()
cosmicRayConfigurationStruct.smallWindowDetrendOrder = 7;
% order of polynomial used in detrending when the window is large
% used in detrend_time_series()
cosmicRayConfigurationStruct.largeWindowDetrendOrder = 3;
% test threshold for reconstructed time series
% used in clean_cosmic_ray_from_target()
cosmicRayConfigurationStruct.reconstructionThreshold = 1e-6;
% saturation value for pixels - when a pixel value exceeds this threhold it
% is to be considered near saturation and cosmic rays are not removed
% used in clean_cosmic_ray_from_target()
cosmicRayConfigurationStruct.saturationValueThreshold = 3.7e8;
% amount to multiply the standard deviation for when any pixel in the
% aperture is in saturation.  The effect of this multiplier is
% threshold -> threshold*(saturationThresholdMultiplier + 1)
% used in clean_cosmic_ray_from_time_series()
cosmicRayConfigurationStruct.saturationThresholdMultiplier = 1.5;
% order of regression against motion for pixel series detrending
% used in detrend_time_series()
cosmicRayConfigurationStruct.motionDetrendOrder = 3;
% polynomial order to use for gap filling
% used in clean_cosmic_ray_from_time_series()
cosmicRayConfigurationStruct.dataGapFillOrder = 3;


