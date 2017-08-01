function tcat_matlab_controller(runDir, fitsFile)
%__________________________________________________________________________
% function [xTalkOutputStruct, parallelXtalkPixelStruct,...
% frameTransferXtalkPixelStruct] = tcat_matlab_controller(runDir, fitsFile)
%__________________________________________________________________________
%
% Synopsis:
% _________
%
% This function is the entry point into Temperature Coefficients Analysis
% Tool (TCAT) software. This function invokes several other functions to
% meet the following requirements levied on TCAT:
%
% 53.TCAT.1
% TCAT shall accept the MATLAB output from the multiple mod/outs produced
% by BART runs as input.
%
% 53.TCAT.2
% For each type of FGS crosstalk pixel and each mod/out, TCAT shall display
% means and variances of the thermal coefficients produced by BART.
%
% 53.TCAT.3
% For each type of FGS crosstalk pixel and each mod/out, TCAT shall display
% the RMS and residuals from the fits produced by BART.
%
% 53.TCAT.4
% For each type of FGS crosstalk pixel and each mod/out, TCAT shall save
% means and variances of the thermal coefficients produced by BART.
%
% 53.TCAT.5
% For each type of FGS crosstalk pixel and each mod/out, TCAT shall save
% the RMS and residuals from the fits produced by BART.
%
% _________
% Inputs:
% _________
%
% 1. Directory name (where the outputs from the multiple mod/outs produced
%     by BART run reside)
% 2. Clock state mask fits file name (clock state mask image clearly
%    delineates the parallel and frame transfer cross talk pixels).
%
% _________
% Outputs:
% _________
%
% The following output structures are saved to tcatResults.mat
% -------------------------------------------------------------------------
% 1. xTalkOutputStruct (created from the clock state mask fits file)
% -------------------------------------------------------------------------
%
%    xTalkOutputStruct contains the following fields:
%            fgsXtalkIndexImage: [1070x1132 double]
%     numberOfFgsParallelPixels: 32
%        fgsParallelPixelValues: [32x1 double]
%        numberOfFgsFramePixels: 16
%           fgsFramePixelValues: [16x1 double]
%
% -------------------------------------------------------------------------
% 2. parallelXtalkPixelStruct
% -------------------------------------------------------------------------
%
%    This structure contains details about each parallel cross talk pixel
%    type and is an array of 32 (as there are currently 32 distinct
%    parallel cross talk pixel types) structures.
%
%     32x1 struct array with fields:
%         pixelType
%         number
%         valueInXtalkImage
%         rows
%         columns
%         weightedRMSresidual
%         fittedThermalCoefficients1
%         fittedThermalCoefficients2
%         linearIndex
%
%     parallelXtalkPixelStruct(1)
%                          pixelType: 'ParallelTransferCrossTalk'
%                             number: 1
%                  valueInXtalkImage: 32
%                               rows: [2033x1 double]
%                            columns: [2033x1 double]
%                weightedRMSresidual: [84x2033 double]
%         fittedThermalCoefficients1: [84x2033 double]
%         fittedThermalCoefficients2: [84x2033 double]
%                        linearIndex: [2033x1 double]
%
% -------------------------------------------------------------------------
% 3. frameTransferXtalkPixelStruct
% -------------------------------------------------------------------------
%
%    This structure contains details about each frame cross talk pixel
%    type and is an array of 16 (as there are currently 16 distinct
%    frame cross talk pixel types) structures.
%
%     16x1 struct array with fields:
%         pixeltype
%         number
%         valueInXtalkImage
%         rows
%         columns
%         weightedRMSresidual
%         fittedThermalCoefficients1
%         fittedThermalCoefficients2
%         linearIndex
%
%     frameTransferXtalkPixelStruct(1)
%                          pixeltype: 'FrameTransferCrossTalk'
%                             number: 1
%                  valueInXtalkImage: 16
%                               rows: [2058x1 double]
%                            columns: [2058x1 double]
%                weightedRMSresidual: [84x2058 double]
%         fittedThermalCoefficients1: [84x2058 double]
%         fittedThermalCoefficients2: [84x2058 double]
%                        linearIndex: [2058x1 double]
%
% -------------------------------------------------------------------------
% In addition to the above, the following four directories are created
% under the present working directory
% -------------------------------------------------------------------------
%
% 1. residuals_plot_focal_plane
% 2. residuals_plot_module_output
% 3. thermal_coefficients_plot_focal_plane
% 4. thermal_coefficients_plot_module_output
%
% All the four directories contain plots (.jpg as well as .fig) of a
% specific type.
%
% -------------------------------------------------------------------------
% 1. residuals_plot_focal_plane - contains the following types of plots
% -------------------------------------------------------------------------
%
%     Type 1: A stack of mean removed histograms (3D plots) of weighted
%             RMS residuals of fit (from BART) for a given pixel type
%             (could be 1 of 32 parallel transfer cross talk pixels or 1 of
%             16 frame transfer cross talk pixels) across all available
%             (max 84) modouts So a total of 32 + 16 = 48 such plots are
%             plotted.
%
%             x axis - 'Module/Output'
%             y axis - 'Scatter around mean'
%             z axis - 'Pixel count'
%
%     Type 2: Plots of mean of residuals for parallel/frame transfer pixels
%             (3D plot and a superposed plot where each curve is offset by
%             1 in the y-axis) a total of 4 plots
%
%             x axis - 'Module/Output'
%             y axis - 'FGS Parallel Transfer Crosstalk Pixel Type' or
%                       'Frame Transfer Crosstalk Pixel Type'
%             z axis - 'Mean of weighted RMS residual'
%
%     Type 3: Plots of rms of residuals for parallel/frame transfer pixels
%             (3D plot and a superposed plot where each curve is offset by
%             1 in the y-axis) a total of 4 plots
%
%             x axis - 'Module/Output'
%             y axis - 'FGS Parallel Transfer Crosstalk Pixel Type' or
%                       'Frame Transfer Crosstalk Pixel Type'
%             z axis - 'RMS of weighted RMS residual'
%
% -------------------------------------------------------------------------
% 2. residuals_plot_module_output - contain the following types of plots
% -------------------------------------------------------------------------
%
%     Type 1: A stack of mean removed histograms (3D plots) of weighted RMS
%             residuals of fit (from BART) for all parallel/frame transfer
%             cross talk pixel types (1 through 32/ 1 through 16) for one
%             modout. Each figure contains parallel/frame transfer cross
%             talk pixels of all types plotted for one modout. There is a
%             total of 84 (or however many mod/outs are available) such plots
%             for parallel cross talk and 84 plots for frame transfer
%             crosstalk pixels
%
%             x axis - 'Parallel Crosstalk Pixel Type' or 'Frame Transfer
%                       Crosstalk Pixel Type'
%             y axis - 'Scatter around mean'
%             z axis - 'Pixel count'
%
%     Type 2: Plots of mean of residuals for parallel/frame transfer pixels
%             (3D plot and a superposed plot where each curve is offset from
%             the rest) a total of 4 plots
%
%             x axis - 'FGS Parallel Transfer Crosstalk Pixel Type'  or
%                      'Frame Transfer Crosstalk Pixel Type'
%             y axis - 'Module/Output'
%             z axis - 'Mean of weighted RMS residual'
%
%     Type 3: Plots of rms of residuals for parallel/frame transfer pixels
%             (3D plot and a superposed plot where each curve is offset from
%             the rest) a total of 4 plots
%
%             x axis - 'FGS Parallel Transfer Crosstalk Pixel Type'
%             y axis - 'Module/Output'
%             z axis - 'RMS of weighted RMS residual'
%
%
% -------------------------------------------------------------------------
% 3. thermal_coefficients_plot_focal_plane - contains the following types
% -------------------------------------------------------------------------
%     Type 1: A stack of mean removed histograms (3D plots) of thermal
%             coefficients (1 and 2) of fit (from BART) for a given pixel
%             type (could be 1 of 32 parallel transfer cross talk pixels or
%             1 of 16 frame transfer cross talk pixels) across all
%             available (max 84) modouts So a total of 32 + 16 = 48 such
%             plots are plotted.
%
%             x axis - 'Module/Output'
%             y axis - 'Scatter around mean'
%             z axis - 'Pixel count'
%
%     Type 2: Plots of mean of thermal coefficients (1 and 2) for
%             parallel/frame transfer pixels (3D plot and a superposed plot
%             where each curve is offset by 1 in the y-axis) a total of 4
%             plots
%
%             x axis - 'Module/Output'
%             y axis - 'FGS Parallel Transfer Crosstalk Pixel Type' or
%                       'Frame Transfer Crosstalk Pixel Type'
%             z axis - 'Mean of Thermal Coefficient 1'  or
%                      'Mean of Thermal Coefficient 2'
%
%     Type 3: Plots of rms of thermal coefficients (1 and 2) for
%             parallel/frame transfer pixels (3D plot and a superposed plot
%             where each curve is offset by 1 in the y-axis) a total of 4
%             plots
%
%             x axis - 'Module/Output'
%             y axis - 'FGS Parallel Transfer Crosstalk Pixel Type' or
%                       'Frame Transfer Crosstalk Pixel Type'
%             z axis - 'Std of Thermal Coefficient 1'  or
%                      'Std of Thermal Coefficient 2'
%
%
% -------------------------------------------------------------------------
% 4. thermal_coefficients_plot_module_output - contain the following types
% -------------------------------------------------------------------------
%     Type 1: A stack of mean removed histograms (3D plots) ofthermal
%             coefficients (1 and 2) of fit (from BART) for all
%             parallel/frame transfer cross talk pixel types (1 through 32/
%             1 through 16) for one modout. Each figure contains
%             parallel/frame transfer cross talk pixels of all types
%             plotted for one modout. There is a total of 84 (or however
%             many mod/outs are available) such plots for parallel cross
%             talk and 84 plots for frame transfer crosstalk pixels
%
%             x axis - 'Parallel Crosstalk Pixel Type' or 'Frame Transfer
%                       Crosstalk Pixel Type'
%             y axis - 'Scatter around mean'
%             z axis - 'Pixel count'
%
%     Type 2: Plots of mean of thermal coefficients (1 and 2) for
%             parallel/frame transfer pixels (3D plot and a superposed plot
%             where each curve is offset from the rest) a total of 4 plots
%
%             x axis - 'FGS Parallel Transfer Crosstalk Pixel Type'  or
%                      'Frame Transfer Crosstalk Pixel Type'
%             y axis - 'Module/Output'
%             z axis - 'Mean of Thermal Coefficient 1'  or
%                      'Mean of Thermal Coefficient 2'
%
%     Type 3: Plots of rms of thermal coefficients (1 and 2) for
%             parallel/frame transfer pixels (3D plot and a superposed plot
%             where each curve is offset from the rest) a total of 4 plots
%
%             x axis - 'FGS Parallel Transfer Crosstalk Pixel Type'
%             y axis - 'Module/Output'
%             z axis - 'Std of Thermal Coefficient 1'  or
%                      'Std of Thermal Coefficient 2'
%
%
%__________________________________________________________________________
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


%______________________________________________________________________
% Step 1: Prepare tcatInputDataStruct
%______________________________________________________________________

tcatInputDataStruct.runDir = runDir;

[pathstr, fitsFileName,  ext] = fileparts(fitsFile);

tcatInputDataStruct.xTalkFitsFileName = [fitsFileName  ext];


fprintf('\n\nTCAT: Getting fcConstants from the Java Class...\n\n');
% get fcConstantsStruct
tcatInputDataStruct.fcConstantsStruct = convert_fc_constants_java_2_struct();

tcatInputDataStruct = get_region_of_interest_from_user(tcatInputDataStruct);

%______________________________________________________________________
% Step 2: Check for the existence of directories, .mat file, validate
% fcConstantsStruct
%______________________________________________________________________

fprintf('TCAT: Checking for the existence of input directory, model/diagnostics .mat file...\n\n');

tcatInputDataStruct = validate_tcat_input_struct(tcatInputDataStruct);



% tcatInputDataStruct =
%
%                bartModelDir: 'model'
%          bartDiagnosticsDir: 'diagnostics'
%           xTalkFitsFileName: 'clock_state_mask_KADN-26205_20081218.fits'
%           fcConstantsStruct: [1x1 struct]
%              modelFileNames: {84x1 cell}
%          modelFileAvailable: [84x1 logical]
%         diagnosticFileNames: {84x1 cell}
%     diagnosticFileAvailable: [84x1 logical]


%______________________________________________________________________
% Step 3: Read cross talk image delivered as a fits file and is checked
% into svn along with TCAT scripts
%______________________________________________________________________

fprintf('TCAT: Reading crosstalk fits file ...\n\n');
xTalkOutputStruct  = read_crosstalk_fits_file(tcatInputDataStruct.xTalkFitsFileName);


%______________________________________________________________________
% Step 4: Extract parallel and frame transfer cross talk pixels in the
% visible CCD
%______________________________________________________________________

fprintf('TCAT: Extracting parallel transfer and frame transfer crosstalk pixel co-ordinates ...\n\n');
[parallelXtalkPixelStruct, frameTransferXtalkPixelStruct]  = ...
    extract_crosstalk_pixel_coordinates(tcatInputDataStruct, xTalkOutputStruct);


fprintf('TCAT: Saving  tcatInputDataStruct,  xTalkOutputStruct, \n')
fprintf('              parallelXtalkPixelStruct, frameTransferXtalkPixelStruct\n');
fprintf('to tcatResults.mat....\n\n');
save tcatResults.mat tcatInputDataStruct xTalkOutputStruct parallelXtalkPixelStruct frameTransferXtalkPixelStruct;

fprintf('TCAT: Begin plotting ....\n\n');
fprintf('NOTE: nanmean, nanstd are used to be robust against NaNs in the data.....\n\n');

%______________________________________________________________________
% Focal plane type plots
%
% Type 1: A stack of mean removed histograms (3D plots) for parallel/frame transfer pixels
%         plots histograms of weighted RMS residuals of fit (from BART) for a given
%         pixel type (could be 1 of 32 parallel transfer cross talk pixels or 1of
%         16 frame transfer cross talk pixels) across all available (max 84) modouts
%         So a total of 32 + 16 = 48 such plots are plotted.
%
%         x axis - 'Module/Output'
%         y axis - 'Scatter around mean'
%         z axis - 'Pixel count'
%
% Type 2: Plots of mean of residuals/thermal coefficients for parallel/frame transfer pixels
%         (3D plot and a superposed plot where each curve is offset from
%         the rest) a total of 4 plots
%
%         x axis - 'Module/Output'
%         y axis - 'FGS Parallel Transfer Crosstalk Pixel Type' or 'Frame Transfer Crosstalk Pixel Type'
%         z axis - 'Mean of weighted RMS residual' or  'Mean of Thermal
%                   Coefficient 1' or  'Mean of Thermal Coefficient 2'
%
% Type 3: Plots of rms of residuals/thermal coefficients for parallel/frame transfer pixels
%         (3D plot and a superposed plot where each curve is offset from
%         the rest) a total of 4 plots
%
%         x axis - 'Module/Output'
%         y axis - 'FGS Parallel Transfer Crosstalk Pixel Type' or 'Frame Transfer Crosstalk Pixel Type'
%         z axis - 'RMS of weighted RMS residual' or  'Std of Thermal
%                   Coefficient 1' or 'Std of Thermal Coefficient 2'
%______________________________________________________________________

fprintf('TCAT: Plotting histograms of residuals of fit for each crosstalk pixel type  across the focal plane.....\n\n');
fprintf('NOTE: The superposed or stacked mean/rms plots are offset by 4*maximum std in mean/rms.....\n\n');
tcatInputDataStruct.stackedPlotsOffsetFactor = 4; % 4 sigma separation factor

plot_hist_of_residuals_for_pixel_type_across_focal_plane(tcatInputDataStruct, xTalkOutputStruct, ...
    parallelXtalkPixelStruct, frameTransferXtalkPixelStruct);

fprintf('TCAT: Plotting histograms of fitted coefficients for each crosstalk pixel type across the focal plane.....\n\n');
fprintf('NOTE: The superposed or stacked mean/std plots are NOT offset by 4*maximum std in mean/rms.....\n\n');

tcatInputDataStruct.stackedPlotsOffsetFactor = 0; % superposed plots not offset from each other
plot_hist_of_coeffts_for_pixel_type_across_focal_plane(tcatInputDataStruct, xTalkOutputStruct, ...
    parallelXtalkPixelStruct, frameTransferXtalkPixelStruct);


%______________________________________________________________________
% Mod/Out type plots
%
% Type 1: A stack of mean removed histograms (3D plots) for parallel/frame transfer pixels
%         plots histograms of weighted RMS residuals of fit (from BART) for for
%         all parallel/frame transfer cross talk pixel types (1 through 32/
%         1 through 16) for one modout. Each figure contains parallel/frame
%         transfer cross talk pixels of all types plotted for one modout.
%         There is a total of 84 (or whatever mod/outs are available) such
%         plots for parallel cross talk and 84 plots for frame transfer
%         crosstalk pixels (
%
%         x axis - 'Parallel Crosstalk Pixel Type' or 'Frame Transfer Crosstalk Pixel Type'
%         y axis - 'Scatter around mean'
%         z axis - 'Pixel count'
%
% Type 2: Plots of mean of residuals/thermal coefficients for parallel/frame transfer pixels
%         (3D plot and a superposed plot where each curve is offset from
%         the rest) a total of 4 plots
%
%         x axis - 'FGS Parallel Transfer Crosstalk Pixel Type'  or 'Frame Transfer Crosstalk Pixel Type'
%         y axis - 'Module/Output'
%         z axis - 'Mean of weighted RMS residual' or  'Mean of Thermal
%                   Coefficient 1' or  'Mean of Thermal Coefficient 2'
%
% Type 3: Plots of rms of residuals/thermal coefficients for parallel/frame transfer pixels
%         (3D plot and a superposed plot where each curve is offset from
%         the rest) a total of 4 plots
%
%         x axis - 'FGS Parallel Transfer Crosstalk Pixel Type'
%         y axis - 'Module/Output'
%         z axis - 'RMS of weighted RMS residual' or  'Std of Thermal
%                   Coefficient 1' or 'Std of Thermal Coefficient 2'
%______________________________________________________________________




fprintf('TCAT: Plotting histograms of residuals of fit for all crosstalk pixel types  across each mod/out.....\n\n');
fprintf('NOTE: The superposed or stacked mean/rms plots are offset by 4*maximum std in mean/rms.....\n\n');

tcatInputDataStruct.stackedPlotsOffsetFactor = 4; % 4 sigma separation factor
plot_hist_of_residuals_for_all_pixel_types_in_one_modout(tcatInputDataStruct, xTalkOutputStruct, ...
    parallelXtalkPixelStruct, frameTransferXtalkPixelStruct);


fprintf('TCAT: Plotting histograms of fitted coefficients for all crosstalk pixel types for each mod/out.....\n\n');
fprintf('NOTE: The superposed or stacked mean/std plots are NOT offset by 4*maximum std in mean/rms.....\n\n');

tcatInputDataStruct.stackedPlotsOffsetFactor = 0; % superposed plots not offset from each other
plot_hist_of_coeffts_for_all_pixel_types_in_one_modout(tcatInputDataStruct, xTalkOutputStruct, ...
    parallelXtalkPixelStruct, frameTransferXtalkPixelStruct);

return
