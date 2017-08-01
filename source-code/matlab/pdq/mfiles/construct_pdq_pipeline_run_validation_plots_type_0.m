function construct_pdq_pipeline_run_validation_plots_type_0(pdqOutputStruct, newCadenceIndex, modOutsProcessed, fcConstantsStruct)

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% construct_pdq_pipeline_run_validation_plots_type_0.m
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
close all;

grayBoxStr = 'Gray box => modout not processed / valid metric unavailable';
%-----------------------------------------------------
% black levels
%-----------------------------------------------------
blackLevels  = cat(1,pdqOutputStruct.outputPdqTsData.pdqModuleOutputTsData.blackLevels); % an array of structs 1x84

pdqMetricStruct.metric = blackLevels;

pdqMetricStruct.name = 'black levels';
pdqMetricStruct.units = 'ADU';
pdqMetricStruct.titleStr = {'Mean black level variation over the focal plane (in ADU)';grayBoxStr};

plot_pdq_metric_on_focal_plane(pdqMetricStruct, newCadenceIndex, modOutsProcessed);

%-----------------------------------------------------
% smear levels
%-----------------------------------------------------
smearLevels  = [pdqOutputStruct.outputPdqTsData.pdqModuleOutputTsData.smearLevels]; % an array of structs 1x84

pdqMetricStruct.metric = smearLevels;

pdqMetricStruct.name = 'smear levels';
pdqMetricStruct.units = 'photoelectrons';
pdqMetricStruct.titleStr = {'Mean smear level variation over the focal plane (in photoelectrons)';grayBoxStr};

plot_pdq_metric_on_focal_plane(pdqMetricStruct, newCadenceIndex, modOutsProcessed);


%-----------------------------------------------------
% dark currents
%-----------------------------------------------------

darkCurrents  = [pdqOutputStruct.outputPdqTsData.pdqModuleOutputTsData.darkCurrents]; % an array of structs 1x84


pdqMetricStruct.metric = darkCurrents;


pdqMetricStruct.name = 'dark currents';
pdqMetricStruct.units = 'photoelectrons/sec/exposure';
pdqMetricStruct.titleStr = {'Mean dark current level variation over the focal plane (in photoelectrons per sec per exposure)';grayBoxStr};

plot_pdq_metric_on_focal_plane(pdqMetricStruct, newCadenceIndex, modOutsProcessed);


%-----------------------------------------------------
% backgroundLevels
%-----------------------------------------------------

backgroundLevels  = [pdqOutputStruct.outputPdqTsData.pdqModuleOutputTsData.backgroundLevels]; % an array of structs 1x84

pdqMetricStruct.metric = backgroundLevels;


pdqMetricStruct.name = 'background levels';
pdqMetricStruct.units = 'photoelectrons';
pdqMetricStruct.titleStr = {'Mean background level variation over the focal plane (in photoelectrons)';grayBoxStr};

plot_pdq_metric_on_focal_plane(pdqMetricStruct, newCadenceIndex, modOutsProcessed);

%-----------------------------------------------------
% dynamicRanges
%-----------------------------------------------------

dynamicRanges  = [pdqOutputStruct.outputPdqTsData.pdqModuleOutputTsData.dynamicRanges]; % an array of structs 1x84

pdqMetricStruct.metric = dynamicRanges;


pdqMetricStruct.name = 'dynamic ranges';
pdqMetricStruct.units = 'ADU';
pdqMetricStruct.titleStr = {'Mean dynamic range variation over the focal plane (in ADU)';grayBoxStr};

spChainStruct = get_signal_processing_chain_info(fcConstantsStruct);

plot_pdq_signal_processing_chain_metric_on_focal_plane(pdqMetricStruct, modOutsProcessed, newCadenceIndex, spChainStruct, fcConstantsStruct);

%-----------------------------------------------------
% meanFluxes
%-----------------------------------------------------

meanFluxes  = [pdqOutputStruct.outputPdqTsData.pdqModuleOutputTsData.meanFluxes]; % an array of structs 1x84


pdqMetricStruct.metric = meanFluxes;

pdqMetricStruct.name = 'flux metric';
pdqMetricStruct.units = 'unitless ratio';
pdqMetricStruct.titleStr = {'Mean brightness metric variation over the focal plane (in unitless ratio)';grayBoxStr};

plot_pdq_metric_on_focal_plane(pdqMetricStruct, newCadenceIndex, modOutsProcessed);

%-----------------------------------------------------
% centroidsMeanRows
%-----------------------------------------------------

centroidsMeanRows  = [pdqOutputStruct.outputPdqTsData.pdqModuleOutputTsData.centroidsMeanRows]; % an array of structs 1x84


pdqMetricStruct.metric = centroidsMeanRows;

pdqMetricStruct.name = 'centroids mean rows';
pdqMetricStruct.units = 'pixels';
pdqMetricStruct.titleStr = {'Mean centroid row metric variation over the focal plane (in pixels)';grayBoxStr};

plot_pdq_metric_on_focal_plane(pdqMetricStruct, newCadenceIndex, modOutsProcessed);

%-----------------------------------------------------
% centroidsMeanCols
%-----------------------------------------------------

centroidsMeanCols  = [pdqOutputStruct.outputPdqTsData.pdqModuleOutputTsData.centroidsMeanCols]; % an array of structs 1x84


pdqMetricStruct.metric = centroidsMeanCols;

pdqMetricStruct.name = 'centroids mean columns';
pdqMetricStruct.units = 'pixels';
pdqMetricStruct.titleStr = {'Mean centroid column metric variation over the focal plane (in pixels)';grayBoxStr};

plot_pdq_metric_on_focal_plane(pdqMetricStruct, newCadenceIndex, modOutsProcessed);
%-----------------------------------------------------
% encircledEnergies
%-----------------------------------------------------

encircledEnergies  = [pdqOutputStruct.outputPdqTsData.pdqModuleOutputTsData.encircledEnergies]; % an array of structs 1x84


pdqMetricStruct.metric = encircledEnergies;

pdqMetricStruct.name = 'encircled energy';
pdqMetricStruct.units = 'pixels';
pdqMetricStruct.titleStr = {'Mean encircled energy variation over the focal plane (in pixels)';grayBoxStr};

plot_pdq_metric_on_focal_plane(pdqMetricStruct, newCadenceIndex, modOutsProcessed);


%-----------------------------------------------------
% plateScales
%-----------------------------------------------------

plateScales  = [pdqOutputStruct.outputPdqTsData.pdqModuleOutputTsData.plateScales]; % an array of structs 1x84

pdqMetricStruct.metric = plateScales;


pdqMetricStruct.name = 'plate scale';
pdqMetricStruct.units = 'pixels/arcsec';
pdqMetricStruct.titleStr = {'Mean plate scale metric variation over the focal plane';grayBoxStr};
pdqMetricStruct.fileNameStr = 'Mean plate scale metric variation over the focal plane';

plot_pdq_metric_on_focal_plane(pdqMetricStruct, newCadenceIndex, modOutsProcessed);

return


