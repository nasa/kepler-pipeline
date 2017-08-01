function cdq_display_averages(cdqInputStruct, cdqOutputStruct, cdqTemporaryStruct)
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function cdq_display_averages(cdqInputStruct, cdqOutputStruct, cdqTemporaryStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% This function displays averages of RMS and thermal coefficient values produced by BART for each column
% of leading and trailing black and each row of virtual and masked smear data for each mod/out. 
%
% It also displays the histograms of the leading/trailing black columns and masked/virtual smear rows.
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
%  Inputs:
%
%    cdqInputStruct is a structure containing the following fields: 
%
%                         bartOutputDir [string]        A string defining the directory of bart outputs.  
%                     fcConstantsStruct [struct]        Focal plane constants.
%                          channelArray [double array]  Array of channels to be processed.
%           chargeInjectionPixelRemoved [logical]       Flag indicating charge injection pixels are/aren't removed when it is true/false.
%                        modelFileNames [cell array]    Model file names for each module/outputs.
%                    modelFileAvailable [logical array] Flag indicating the availability of model file for each module/outputs.
%                   daignosticFileNames [cell array]    Diagnostic file names for each module/outputs.
%               diagnosticFileAvailable [logical array] Flag indicating the availability of diagnostic file for each module/outputs.
%
%
%    cdqOutputStruct is a structure containing following fields:
%
%                               meanRms [struct array]  Mean values of RMS of fit residuals. One struct for each module/output.
%            meanThermalModelLinearTerm [struct array]  Mean values of thermal model linear terms. One struct for each module/output.
%          meanThermalModelConstantTerm [struct array]  Mean values of thermal model constant terms. One struct for each module/output.
%
%    cdqOutputStruct.meanRms(1)
%    cdqOutputStruct.meanThermalModelLinearTerm(1)
%    cdqOutputStruct.meanThermalModelConstantTerm(1)  are structures containing the following fieds:
%
%                           leadingBlack [12x1 double]  Mean values of leading  balck columns.
%                          trailingBlack [20x1 double]  Mean values of trailing balck columns.
%                            maskedSmear [20x1 double]  Mean values of masked  smear rows.
%                           virtualSmear [26x1 double]  Mean values of virtual smear rows.
%
%
%    cdqTemporaryStruct is a structure containing following fields:
%
%                           residualRms [struct array]  Mean removed residauls of RMS.                         One struct for each module/output.
%        residualThermalModelLinearTerm [struct array]  Mean removed residauls of Thermal Model Linear   Term. One struct for each module/output.
%      residualThermalModelConstantTerm [struct array]  Mean removed residauls of Thermal Model Constant Term. One struct for each module/output.
%                        maxResidualRms [struct array]  Maximum values      of mean removed residauls of RMS.  One struct for each module/output.
%                        minResidualRms [struct array]  Minimum values      of mean removed residauls of RMS.  One struct for each module/output.
%                        stdResidualRms [struct array]  Standard deviations of mean removed residauls of RMS.  One struct for each module/output.
%     maxResidualThermalModelLinearTerm [struct array]  Maximum values      of mean removed residauls of Thermal Model Linear   Term. One struct for each module/output.
%     minResidualThermalModelLinearTerm [struct array]  Minimum values      of mean removed residauls of Thermal Model Linear   Term. One struct for each module/output.
%     stdResidualThermalModelLinearTerm [struct array]  Standard deviations of mean removed residauls of Thermal Model Linear   Term. One struct for each module/output.
%   maxResidualThermalModelConstantTerm [struct array]  Maximum values      of mean removed residauls of Thermal Model Constant Term. One struct for each module/output.
%   minResidualThermalModelConstantTerm [struct array]  Minimum values      of mean removed residauls of Thermal Model Constant Term. One struct for each module/output.
%   stdResidualThermalModelConstantTerm [struct array]  Standard deviations of mean removed residauls of Thermal Model Constant Term. One struct for each module/output.
%
%    cdqTemporaryStruct.residualRms(1)
%    cdqTemporaryStruct.residualThermalModelLinearTerm(1)
%    cdqTemporaryStruct.residualThermalModelConstantTerm(1) are structures containing the following fieds:
%
%                        leadingBlack [1070x12 double]  Mean removed residuals for leading  black pixels. 
%                       trailingBlack [1070x20 double]  Mean removed residuals for trailing black pixels.
%                         maskedSmear [1100x20 double]  Mean removed residuals for masked   smear pixels.
%                        virtualSmear [1100x26 double]  Mean removed residuals for virtual  smear pixels.
%      
%    cdqTemporaryStruct.maxResidualRms(1)
%    cdqTemporaryStruct.minResidualRms(1)
%    cdqTemporaryStruct.stdResidualRms(1)
%    cdqTemporaryStruct.maxResidualThermalModelLinearTerm(1)
%    cdqTemporaryStruct.minResidualThermalModelLinearTerm(1)
%    cdqTemporaryStruct.stdResidualThermalModelLinearTerm(1)
%    cdqTemporaryStruct.maxResidualThermalModelConstantTerm(1)
%    cdqTemporaryStruct.minResidualThermalModelConstantTerm(1)
%    cdqTemporaryStruct.stdResidualThermalModelConstantTerm(1) are structures containing the following fieds:
% 
%                           leadingBlack [12x1 double]  Maximum values/minimum values/standard deviations of mean removed residuals for leading  black pixels.
%                          trailingBlack [20x1 double]  Maximum values/minimum values/standard deviations of mean removed residuals for trailing black pixels.
%                            maskedSmear [20x1 double]  Maximum values/minimum values/standard deviations of mean removed residuals for masked   smear pixels.
%                           virtualSmear [26x1 double]  Maximum values/minimum values/standard deviations of mean removed residuals for virtual  smear pixels.
% 
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% 
% Output plots:
% 
% The following tree of directories is also automatically generated under the directory
% where the user is running cdq_matlab_controller to the save the plots of each data type
% (RMS, thermal model linear/constant term) and collateral type (leading/trailing black,
% masked/virtual smear):
%
%       rms_plots
%                                           leading_black
%                                                           focal_plane
%                                                           one_mod_out
%                                           trailing_black
%                                                           focal_plane
%                                                           one_mod_out
%                                           masked_smear
%                                                           focal_plane
%                                                           one_mod_out
%                                           virtual_smear
%                                                           focal_plane
%                                                           one_mod_out
%       thermal_model_linear_term_plots
%                                           leading_black
%                                                           focal_plane
%                                                           one_mod_out
%                                           trailing_black
%                                                           focal_plane
%                                                           one_mod_out
%                                           masked_smear
%                                                           focal_plane
%                                                           one_mod_out
%                                           virtual_smear
%                                                           focal_plane
%                                                           one_mod_out
%       thermal_model_constant_term_plots
%                                           leading_black
%                                                           focal_plane
%                                                           one_mod_out
%                                           trailing_black
%                                                           focal_plane
%                                                           one_mod_out
%                                           masked_smear
%                                                           focal_plane
%                                                           one_mod_out
%                                           virtual_smear
%                                                           focal_plane
%                                                           one_mod_out
%
% The following plots are included in the 'focal_plane' directory of each data type and collateral type:
% 
%       3D plot of mean values
%           x axis - module/outputs
%           y axis - leading/trailing black columns or masked/virtual smear rows
%           z axis - mean values
%       2D plot of mean values (superposed with    offset)
%           x axis - module/outputs
%           y axis - mean values
%       2D plot of mean values (superposed without offset)
%           x axis - module/outputs
%           y axis - mean values
%       Histogram plots, one for each leading/trailing black column or masked/virtual smear row
%           x axis - module/outputs
%           y axis - scatter around mean values
%           z axis - pixel count
%
% The following plots are included in the 'one_mod_out' directory of each data type and collateral type:
% 
%       3D plot of mean values
%           x axis - leading/trailing black columns or masked/virtual smear rows
%           y axis - module/outputs
%           z axis - mean values
%       2D plot of mean values (superposed with    offset)
%           x axis - leading/trailing black columns or masked/virtual smear rows 
%           y axis - mean values
%       2D plot of mean values (superposed without offset)
%           x axis - leading/trailing black columns or masked/virtual smear rows
%           y axis - mean values
%       Histogram plots, one for each module/output
%           x axis - leading/trailing black columns or masked/virtual smear rows
%           y axis - scatter around mean values
%           z axis - pixel count
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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


%__________________________________________________________________________
% preliminaries
%__________________________________________________________________________

nModOuts = cdqInputStruct.fcConstantsStruct.MODULE_OUTPUTS;

leadingBlackStart  = cdqInputStruct.fcConstantsStruct.LEADING_BLACK_START  + 1;
trailingBlackStart = cdqInputStruct.fcConstantsStruct.TRAILING_BLACK_START + 1;
maskedSmearStart   = cdqInputStruct.fcConstantsStruct.MASKED_SMEAR_START   + 1;
virtualSmearStart  = cdqInputStruct.fcConstantsStruct.VIRTUAL_SMEAR_START  + 1;

nLeadingBlack      = cdqInputStruct.fcConstantsStruct.nLeadingBlack;
nTrailingBlack     = cdqInputStruct.fcConstantsStruct.nTrailingBlack;
nMaskedSmear       = cdqInputStruct.fcConstantsStruct.nMaskedSmear;
nVirtualSmear      = cdqInputStruct.fcConstantsStruct.nVirtualSmear;

nBins = 50;



% Plots of RMS 
[meanMatrix, barGraphDataFocalPlane, xBinLocationsFocalPlane, barGraphDataOneModOut, xBinLocationsOneModOut] = ...
    cdq_plot_data(cdqInputStruct, cdqOutputStruct, cdqTemporaryStruct, 'Rms',                       'leadingBlack',  nBins, nLeadingBlack,  leadingBlackStart,  nModOuts);
cdqGraphDataStruct.rms.leadingBlack.meanMatrix               = meanMatrix;
cdqGraphDataStruct.rms.leadingBlack.barGraphDataFocalPlane   = barGraphDataFocalPlane;
cdqGraphDataStruct.rms.leadingBlack.xBinLocationsFocalPlane  = xBinLocationsFocalPlane;
cdqGraphDataStruct.rms.leadingBlack.barGraphDataOneModOut    = barGraphDataOneModOut;
cdqGraphDataStruct.rms.leadingBlack.xBinLocationsOneModOut   = xBinLocationsOneModOut;

[meanMatrix, barGraphDataFocalPlane, xBinLocationsFocalPlane, barGraphDataOneModOut, xBinLocationsOneModOut] = ...
    cdq_plot_data(cdqInputStruct, cdqOutputStruct, cdqTemporaryStruct, 'Rms',                       'trailingBlack', nBins, nTrailingBlack, trailingBlackStart, nModOuts);
cdqGraphDataStruct.rms.trailingBlack.meanMatrix              = meanMatrix;
cdqGraphDataStruct.rms.trailingBlack.barGraphDataFocalPlane  = barGraphDataFocalPlane;
cdqGraphDataStruct.rms.trailingBlack.xBinLocationsFocalPlane = xBinLocationsFocalPlane;
cdqGraphDataStruct.rms.trailingBlack.barGraphDataOneModOut   = barGraphDataOneModOut;
cdqGraphDataStruct.rms.trailingBlack.xBinLocationsOneModOut  = xBinLocationsOneModOut;

[meanMatrix, barGraphDataFocalPlane, xBinLocationsFocalPlane, barGraphDataOneModOut, xBinLocationsOneModOut] = ...
    cdq_plot_data(cdqInputStruct, cdqOutputStruct, cdqTemporaryStruct, 'Rms',                       'maskedSmear',   nBins, nMaskedSmear,   maskedSmearStart,   nModOuts);
cdqGraphDataStruct.rms.maskedSmear.meanMatrix                = meanMatrix;
cdqGraphDataStruct.rms.maskedSmear.barGraphDataFocalPlane    = barGraphDataFocalPlane;
cdqGraphDataStruct.rms.maskedSmear.xBinLocationsFocalPlane   = xBinLocationsFocalPlane;
cdqGraphDataStruct.rms.maskedSmear.barGraphDataOneModOut     = barGraphDataOneModOut;
cdqGraphDataStruct.rms.maskedSmear.xBinLocationsOneModOut    = xBinLocationsOneModOut;

[meanMatrix, barGraphDataFocalPlane, xBinLocationsFocalPlane, barGraphDataOneModOut, xBinLocationsOneModOut] = ...
    cdq_plot_data(cdqInputStruct, cdqOutputStruct, cdqTemporaryStruct, 'Rms',                       'virtualSmear',  nBins, nVirtualSmear,  virtualSmearStart,  nModOuts);
cdqGraphDataStruct.rms.virtualSmear.meanMatrix               = meanMatrix;
cdqGraphDataStruct.rms.virtualSmear.barGraphDataFocalPlane   = barGraphDataFocalPlane;
cdqGraphDataStruct.rms.virtualSmear.xBinLocationsFocalPlane  = xBinLocationsFocalPlane;
cdqGraphDataStruct.rms.virtualSmear.barGraphDataOneModOut    = barGraphDataOneModOut;
cdqGraphDataStruct.rms.virtualSmear.xBinLocationsOneModOut   = xBinLocationsOneModOut;


% Plots of Thermal Model Linear Term
[meanMatrix, barGraphDataFocalPlane, xBinLocationsFocalPlane, barGraphDataOneModOut, xBinLocationsOneModOut] = ...
    cdq_plot_data(cdqInputStruct, cdqOutputStruct, cdqTemporaryStruct, 'ThermalModelLinearTerm',    'leadingBlack',  nBins, nLeadingBlack,  leadingBlackStart,  nModOuts);
cdqGraphDataStruct.thermalModelLinearTerm.leadingBlack.meanMatrix               = meanMatrix;
cdqGraphDataStruct.thermalModelLinearTerm.leadingBlack.barGraphDataFocalPlane   = barGraphDataFocalPlane;
cdqGraphDataStruct.thermalModelLinearTerm.leadingBlack.xBinLocationsFocalPlane  = xBinLocationsFocalPlane;
cdqGraphDataStruct.thermalModelLinearTerm.leadingBlack.barGraphDataOneModOut    = barGraphDataOneModOut;
cdqGraphDataStruct.thermalModelLinearTerm.leadingBlack.xBinLocationsOneModOut   = xBinLocationsOneModOut;

[meanMatrix, barGraphDataFocalPlane, xBinLocationsFocalPlane, barGraphDataOneModOut, xBinLocationsOneModOut] = ...
    cdq_plot_data(cdqInputStruct, cdqOutputStruct, cdqTemporaryStruct, 'ThermalModelLinearTerm',    'trailingBlack', nBins, nTrailingBlack, trailingBlackStart, nModOuts);
cdqGraphDataStruct.thermalModelLinearTerm.trailingBlack.meanMatrix              = meanMatrix;
cdqGraphDataStruct.thermalModelLinearTerm.trailingBlack.barGraphDataFocalPlane  = barGraphDataFocalPlane;
cdqGraphDataStruct.thermalModelLinearTerm.trailingBlack.xBinLocationsFocalPlane = xBinLocationsFocalPlane;
cdqGraphDataStruct.thermalModelLinearTerm.trailingBlack.barGraphDataOneModOut   = barGraphDataOneModOut;
cdqGraphDataStruct.thermalModelLinearTerm.trailingBlack.xBinLocationsOneModOut  = xBinLocationsOneModOut;

[meanMatrix, barGraphDataFocalPlane, xBinLocationsFocalPlane, barGraphDataOneModOut, xBinLocationsOneModOut] = ...
    cdq_plot_data(cdqInputStruct, cdqOutputStruct, cdqTemporaryStruct, 'ThermalModelLinearTerm',    'maskedSmear',   nBins, nMaskedSmear,   maskedSmearStart,   nModOuts);
cdqGraphDataStruct.thermalModelLinearTerm.maskedSmear.meanMatrix                = meanMatrix;
cdqGraphDataStruct.thermalModelLinearTerm.maskedSmear.barGraphDataFocalPlane    = barGraphDataFocalPlane;
cdqGraphDataStruct.thermalModelLinearTerm.maskedSmear.xBinLocationsFocalPlane   = xBinLocationsFocalPlane;
cdqGraphDataStruct.thermalModelLinearTerm.maskedSmear.barGraphDataOneModOut     = barGraphDataOneModOut;
cdqGraphDataStruct.thermalModelLinearTerm.maskedSmear.xBinLocationsOneModOut    = xBinLocationsOneModOut;

[meanMatrix, barGraphDataFocalPlane, xBinLocationsFocalPlane, barGraphDataOneModOut, xBinLocationsOneModOut] = ...
    cdq_plot_data(cdqInputStruct, cdqOutputStruct, cdqTemporaryStruct, 'ThermalModelLinearTerm',    'virtualSmear',  nBins, nVirtualSmear,  virtualSmearStart,  nModOuts);
cdqGraphDataStruct.thermalModelLinearTerm.virtualSmear.meanMatrix               = meanMatrix;
cdqGraphDataStruct.thermalModelLinearTerm.virtualSmear.barGraphDataFocalPlane   = barGraphDataFocalPlane;
cdqGraphDataStruct.thermalModelLinearTerm.virtualSmear.xBinLocationsFocalPlane  = xBinLocationsFocalPlane;
cdqGraphDataStruct.thermalModelLinearTerm.virtualSmear.barGraphDataOneModOut    = barGraphDataOneModOut;
cdqGraphDataStruct.thermalModelLinearTerm.virtualSmear.xBinLocationsOneModOut   = xBinLocationsOneModOut;


% Plots of Thermal Model Constant Term
[meanMatrix, barGraphDataFocalPlane, xBinLocationsFocalPlane, barGraphDataOneModOut, xBinLocationsOneModOut] = ...
    cdq_plot_data(cdqInputStruct, cdqOutputStruct, cdqTemporaryStruct, 'ThermalModelConstantTerm',  'leadingBlack',  nBins, nLeadingBlack,  leadingBlackStart,  nModOuts);
cdqGraphDataStruct.thermalModelConstantTerm.leadingBlack.meanMatrix               = meanMatrix;
cdqGraphDataStruct.thermalModelConstantTerm.leadingBlack.barGraphDataFocalPlane   = barGraphDataFocalPlane;
cdqGraphDataStruct.thermalModelConstantTerm.leadingBlack.xBinLocationsFocalPlane  = xBinLocationsFocalPlane;
cdqGraphDataStruct.thermalModelConstantTerm.leadingBlack.barGraphDataOneModOut    = barGraphDataOneModOut;
cdqGraphDataStruct.thermalModelConstantTerm.leadingBlack.xBinLocationsOneModOut   = xBinLocationsOneModOut;

[meanMatrix, barGraphDataFocalPlane, xBinLocationsFocalPlane, barGraphDataOneModOut, xBinLocationsOneModOut] = ...
    cdq_plot_data(cdqInputStruct, cdqOutputStruct, cdqTemporaryStruct, 'ThermalModelConstantTerm',  'trailingBlack', nBins, nTrailingBlack, trailingBlackStart, nModOuts);
cdqGraphDataStruct.thermalModelConstantTerm.trailingBlack.meanMatrix              = meanMatrix;
cdqGraphDataStruct.thermalModelConstantTerm.trailingBlack.barGraphDataFocalPlane  = barGraphDataFocalPlane;
cdqGraphDataStruct.thermalModelConstantTerm.trailingBlack.xBinLocationsFocalPlane = xBinLocationsFocalPlane;
cdqGraphDataStruct.thermalModelConstantTerm.trailingBlack.barGraphDataOneModOut   = barGraphDataOneModOut;
cdqGraphDataStruct.thermalModelConstantTerm.trailingBlack.xBinLocationsOneModOut  = xBinLocationsOneModOut;

[meanMatrix, barGraphDataFocalPlane, xBinLocationsFocalPlane, barGraphDataOneModOut, xBinLocationsOneModOut] = ...
    cdq_plot_data(cdqInputStruct, cdqOutputStruct, cdqTemporaryStruct, 'ThermalModelConstantTerm',  'maskedSmear',   nBins, nMaskedSmear, maskedSmearStart,     nModOuts);
cdqGraphDataStruct.thermalModelConstantTerm.maskedSmear.meanMatrix                = meanMatrix;
cdqGraphDataStruct.thermalModelConstantTerm.maskedSmear.barGraphDataFocalPlane    = barGraphDataFocalPlane;
cdqGraphDataStruct.thermalModelConstantTerm.maskedSmear.xBinLocationsFocalPlane   = xBinLocationsFocalPlane;
cdqGraphDataStruct.thermalModelConstantTerm.maskedSmear.barGraphDataOneModOut     = barGraphDataOneModOut;
cdqGraphDataStruct.thermalModelConstantTerm.maskedSmear.xBinLocationsOneModOut    = xBinLocationsOneModOut;

[meanMatrix, barGraphDataFocalPlane, xBinLocationsFocalPlane, barGraphDataOneModOut, xBinLocationsOneModOut] = ...
    cdq_plot_data(cdqInputStruct, cdqOutputStruct, cdqTemporaryStruct, 'ThermalModelConstantTerm',  'virtualSmear',  nBins, nVirtualSmear,  virtualSmearStart,  nModOuts);
cdqGraphDataStruct.thermalModelConstantTerm.virtualSmear.meanMatrix               = meanMatrix;
cdqGraphDataStruct.thermalModelConstantTerm.virtualSmear.barGraphDataFocalPlane   = barGraphDataFocalPlane;
cdqGraphDataStruct.thermalModelConstantTerm.virtualSmear.xBinLocationsFocalPlane  = xBinLocationsFocalPlane;
cdqGraphDataStruct.thermalModelConstantTerm.virtualSmear.barGraphDataOneModOut    = barGraphDataOneModOut;
cdqGraphDataStruct.thermalModelConstantTerm.virtualSmear.xBinLocationsOneModOut   = xBinLocationsOneModOut;

graphFilename   = 'cdq_graph_data_struct.mat';
eval(['save ' graphFilename ' cdqGraphDataStruct']);

return


function [meanMatrix, barGraphDataFocalPlane, xBinLocationsFocalPlane, barGraphDataOneModOut, xBinLocationsOneModOut] = ...
    cdq_plot_data(cdqInputStruct, cdqOutputStruct, cdqTemporaryStruct, dataType, collateralType, nBins, nRowsOrCols, rowOrColStart, nModOuts)

switch dataType
    case 'Rms'
        dataTypeString  = 'RMS';
        dirNameStr1     = 'rms_plots';
        unitString      = 'DN/integration';
    case 'ThermalModelLinearTerm'
        dataTypeString  = 'Thermal Model Linear Term';
        dirNameStr1     = 'thermal_model_linear_term_plots';
        unitString      = 'DN/integration/C';
    case 'ThermalModelConstantTerm'
        dataTypeString  = 'Thermal Model Constant Term';
        dirNameStr1     = 'thermal_model_constant_term_plots';
        unitString      = 'DN/integration';
    otherwise
        error('CDQ:displayAverages','No valid data type!');
end

switch collateralType
    case 'leadingBlack'
        collateralTypeString = 'Leading Black Column';
        dirNameStr2 = 'leading_black';
    case 'trailingBlack'
        collateralTypeString = 'Trailing Black Column';
        dirNameStr2 = 'trailing_black';
    case 'maskedSmear'
        collateralTypeString = 'Masked Smear Row';
        dirNameStr2 = 'masked_smear';
    case 'virtualSmear'
        collateralTypeString = 'Virtual Smear Row';
        dirNameStr2 = 'virtual_smear';
    otherwise
        error('No valid collateral type!');
end

if(~exist(dirNameStr1, 'dir'))
    eval(['mkdir ' dirNameStr1]);
end
eval(['cd ' dirNameStr1]);

if(~exist(dirNameStr2, 'dir'))
    eval(['mkdir ' dirNameStr2]);
end
eval(['cd ' dirNameStr2]);

eval(['meanMatrix = [cdqOutputStruct.mean' dataType '.' collateralType '];']);
[barGraphDataFocalPlane, xBinLocationsFocalPlane, barGraphDataOneModOut, xBinLocationsOneModOut] = ...
    cdq_generate_bar_graph_data(cdqTemporaryStruct, dataType, collateralType,  nBins, nRowsOrCols,  nModOuts);
cdq_generate_plots_focal_plane(meanMatrix, barGraphDataFocalPlane, xBinLocationsFocalPlane, ...
    nRowsOrCols, rowOrColStart, nModOuts, dataTypeString, collateralTypeString, unitString);
cdq_generate_plots_one_mod_out(meanMatrix, barGraphDataOneModOut,  xBinLocationsOneModOut,  ...
    nRowsOrCols, rowOrColStart, nModOuts, dataTypeString, collateralTypeString, unitString, cdqInputStruct);

dirNameStr = 'focal_plane';
if(~exist(dirNameStr, 'dir'))
    eval(['mkdir ' dirNameStr]);
end
sourceFileStr = '*_Focal_Plane*.*';
eval(['movefile '''  sourceFileStr '''  ' dirNameStr ' ' '''f''']);

dirNameStr = 'one_mod_out';
if(~exist(dirNameStr, 'dir'))
    eval(['mkdir ' dirNameStr]);
end
sourceFileStr = '*_ModOut*.*';
eval(['movefile '''  sourceFileStr '''  ' dirNameStr ' ' '''f''']);

eval('cd ../..');

return


function [barGraphDataFocalPlane, xBinLocationsFocalPlane, barGraphDataOneModOut, xBinLocationsOneModOut] = ...
    cdq_generate_bar_graph_data(cdqTemporaryStruct, dataType, collateralType, nBins, nRowsOrCols, nModOuts)

eval(['stdMatrix = [cdqTemporaryStruct.stdResidual' dataType '.' collateralType '];']);

xBinLocations           = linspace(-1, 1, nBins)';
xBinLocationsFocalPlane = repmat(xBinLocations, 1, nRowsOrCols);
barGraphDataFocalPlane  = NaN( length(xBinLocations), nRowsOrCols, nModOuts);
xBinLocationsOneModOut  = repmat(xBinLocations, 1, nModOuts   );
barGraphDataOneModOut   = NaN( length(xBinLocations), nRowsOrCols, nModOuts);

maxStd = max(stdMatrix, [], 2);
for i = 1:nRowsOrCols

    if ( isfinite(maxStd(i)) )
        
        xBinLocationsFocalPlane(:,i) = linspace(-maxStd(i), maxStd(i), nBins)';
        
        for j = 1:nModOuts
            
            eval(['histData = cdqTemporaryStruct.residual' dataType '(' num2str(j) ').' collateralType '(:,' num2str(i) ');']);
            barGraphDataFocalPlane(:,i,j) = histc(histData, xBinLocationsFocalPlane(:,i));

        end
        
    end

end

maxStd = max(stdMatrix, [], 1);
for j = 1:nModOuts

    if ( isfinite(maxStd(j)) )
        
        xBinLocationsOneModOut(:,j) = linspace(-maxStd(j), maxStd(j), nBins)';
        
        for i = 1:nRowsOrCols
            
            eval(['histData = cdqTemporaryStruct.residual' dataType '(' num2str(j) ').' collateralType '(:,' num2str(i) ');']);
            barGraphDataOneModOut(:,i,j) = histc(histData, xBinLocationsOneModOut(:,j));
            
        end
        
    end

end

return



function cdq_generate_plots_focal_plane(meanMatrix, barGraphDataFocalPlane, xBinLocationsFocalPlane, ...
    nRowsOrCols, rowOrColStart, nModOuts, dataTypeString, collateralTypeString, unitString)

paperOrientationFlag = true;
includeTimeFlag      = false;
printJpgFlag         = true;

tickStr = cell(nModOuts,1);
[modules, outputs] = convert_to_module_output(1:nModOuts);
for j = 1:nModOuts
    tickStr(j) = {['[' num2str(modules(j)) ', ' num2str(outputs(j)) ']']};
end

stdArray = zeros(nRowsOrCols,1);
for i = 1:nRowsOrCols
    cleanedIndex = isfinite( meanMatrix(i,:) );
    stdArray(i)  = std( meanMatrix(i,cleanedIndex) );
end
maxStd = max(stdArray);


% --------------------------------------------
% Plots of histograms across the focal plane
% --------------------------------------------

for i = 1:nRowsOrCols

    figure;

    h = bar3(xBinLocationsFocalPlane(:,i), squeeze(barGraphDataFocalPlane(:,i,:)),  'detached');

    colormap cool
    colorbar
    shading interp
    for ih = 1:length(h)
        zdata = get(h(ih),'Zdata');
        set(h(ih),'Cdata',zdata)
        set(h,'EdgeColor','k')
    end

    set(gca, 'fontsize', 16);
    xlabel('Module/Output');
    zlabel('Pixel count');
    ylabel('Scatter around mean');

    titleStr = ['Histogram of ' dataTypeString ' for ' collateralTypeString ' ' num2str(i-1+rowOrColStart) ' across the Focal Plane'];
    title(titleStr);

    set(gca, 'xtick',      1:4:nModOuts);
    set(gca, 'xticklabel', tickStr(1:4:nModOuts));

    plot_to_file(titleStr, paperOrientationFlag, includeTimeFlag, printJpgFlag);

    close all;

end

% --------------------------------------------
% 3D plot of mean values
% --------------------------------------------

colorSpec = color_specification(nRowsOrCols);

for i = 1:nRowsOrCols
    
    plot3([1:nModOuts], i*ones(1,nModOuts), meanMatrix(i,:), 'p-', 'color', colorSpec(i,:),'LineWidth', 1);

    hold on;

end


view([-3.5, 66]);
set(gca, 'fontsize', 16);

xlabel('Module/Output');
ylabel([collateralTypeString ' (offset:' num2str(rowOrColStart-1) ')']);
zlabel(['Mean of ' dataTypeString '(' unitString ')']);
grid on;

titleStr = ['Mean of ' dataTypeString ' for All ' collateralTypeString 's across the Focal Plane'];
title(titleStr);

set(gca, 'xtick',      1:4:nModOuts);
set(gca, 'xticklabel', tickStr(1:4:nModOuts));

plot_to_file(titleStr, paperOrientationFlag, includeTimeFlag, printJpgFlag);

close all;

% % --------------------------------------------
% % 3D plot of mean values: bar3
% % --------------------------------------------
% 
% h = bar3(meanMatrix, 'detached');
% 
% colormap cool
% colorbar
% shading interp
% for ih = 1:length(h)
%     zdata = get(h(ih),'Zdata');
%     set(h(ih),'Cdata',zdata)
%     set(h,'EdgeColor','k')
% end
% 
% view([-3.5, 66]);
% set(gca, 'fontsize', 16);
% 
% xlabel('Module/Output');
% ylabel([collateralTypeString ' (offset:' num2str(rowOrColStart-1) ')']);
% zlabel(['Mean of ' dataTypeString '(' unitString ')']);
% grid on;
% 
% titleStr = ['Mean of ' dataTypeString ' for All ' collateralTypeString 's across the Focal Plane Bar3'];
% title(titleStr);
% 
% set(gca, 'xtick',      1:4:nModOuts);
% set(gca, 'xticklabel', tickStr(1:4:nModOuts));
% 
% plot_to_file(titleStr, paperOrientationFlag, includeTimeFlag, printJpgFlag);
% 
% close all;

% --------------------------------------------
% 2D plot of mean values: superposed with offset
% --------------------------------------------

for i = 1:nRowsOrCols

    plot(meanMatrix(i,:)+(i-1)*4*maxStd, 'p-', 'color', colorSpec(i,:), 'LineWidth', 1);

    cleanedIndex = find( isfinite( meanMatrix(i,:) ) );
    if ( ~isempty(cleanedIndex) )
        text(nModOuts+1, meanMatrix(i,cleanedIndex(end))+(i-1)*4*maxStd, num2str(i));
    end

    hold on;

end

xRange = xlim;
xlim([xRange(1) xRange(2)+2]);

set(gca, 'fontsize', 16);
xlabel('Module/Output');
ylabel(['Mean of ' dataTypeString '(' unitString ')']);

titleStr = ['Mean of ' dataTypeString ' for ' collateralTypeString 's across the Focal Plane Superposed with Offset'];
title(titleStr);

set(gca, 'xtick',      1:4:nModOuts);
set(gca, 'xticklabel', tickStr(1:4:nModOuts));

plot_to_file(titleStr, paperOrientationFlag, includeTimeFlag, printJpgFlag);

close all;

% --------------------------------------------
% 2D plot of mean values: superposed without offset
% --------------------------------------------

for i = 1:nRowsOrCols

    plot(meanMatrix(i,:), 'p-', 'color', colorSpec(i,:), 'LineWidth', 1);

    cleanedIndex = find( isfinite( meanMatrix(i,:) ) );
    if ( ~isempty(cleanedIndex) )
        text(nModOuts+1, meanMatrix(i,cleanedIndex(end)), num2str(i));
    end

    hold on;

end

xRange = xlim;
xlim([xRange(1) xRange(2)+2]);

set(gca, 'fontsize', 16);
xlabel('Module/Output');
ylabel(['Mean of ' dataTypeString '(' unitString ')']);

titleStr = ['Mean of ' dataTypeString ' for ' collateralTypeString 's across the Focal Plane Superposed without Offset'];
title(titleStr);

set(gca, 'xtick',      1:4:nModOuts);
set(gca, 'xticklabel', tickStr(1:4:nModOuts));

plot_to_file(titleStr, paperOrientationFlag, includeTimeFlag, printJpgFlag);

close all;

return


function cdq_generate_plots_one_mod_out(meanMatrix, barGraphDataOneModOut, xBinLocationsOneModOut, ...
    nRowsOrCols, rowOrColStart, nModOuts, dataTypeString, collateralTypeString, unitString, cdqInputStruct)

paperOrientationFlag = true;
includeTimeFlag      = false;
printJpgFlag         = true;

tickStr = cell(nModOuts,1);
[modules, outputs] = convert_to_module_output(1:nModOuts);
for j = 1:nModOuts
    tickStr(j) = {['[' num2str(modules(j)) ', ' num2str(outputs(j)) ']']};
end

stdArray = zeros(nModOuts,1);
for j = 1:nModOuts
    cleanedIndex = isfinite( meanMatrix(:,j) );
    stdArray(j)  = std( meanMatrix(cleanedIndex,j) );
end
maxStd = max(stdArray);

% --------------------------------------------
% Plots of histograms across each module/output
% --------------------------------------------

for j = 1:length(cdqInputStruct.channelArray)
    
    iChannel = cdqInputStruct.channelArray(j);

    if ( ~cdqInputStruct.modelFileAvailable(iChannel) || ~cdqInputStruct.diagnosticFileAvailable(iChannel) )
        continue;
    end
    
    [mod, out] = convert_to_module_output(iChannel);

    figure;

    h = bar3(xBinLocationsOneModOut(:,iChannel), squeeze(barGraphDataOneModOut(:,:,iChannel)),  'detached');

    colormap cool
    colorbar
    shading interp
    for ih = 1:length(h)
        zdata = get(h(ih),'Zdata');
        set(h(ih),'Cdata',zdata)
        set(h,'EdgeColor','k')
    end

    set(gca, 'fontsize', 16);
    xlabel([collateralTypeString ' (offset:' num2str(rowOrColStart-1) ')']);
    zlabel('Pixel count');
    ylabel('Scatter around mean');

    titleStr = ['Histogram of ' dataTypeString ' for ' collateralTypeString 's in ModOut ' num2str(mod) '-' num2str(out)];
    title(titleStr);

    plot_to_file(titleStr, paperOrientationFlag, includeTimeFlag, printJpgFlag);

    close all;

end

% --------------------------------------------
% 3D plot of mean values
% --------------------------------------------

colorSpec = color_specification(length(cdqInputStruct.channelArray));

for j = 1:length(cdqInputStruct.channelArray)
    
    iChannel = cdqInputStruct.channelArray(j);

    plot3([1:nRowsOrCols]', iChannel*ones(nRowsOrCols,1), meanMatrix(:,iChannel), 'p-', 'color', colorSpec(j,:),'LineWidth', 1);

    hold on;

end


view([-3.5, 66]);
set(gca, 'fontsize', 16);

xlabel([collateralTypeString ' (offset:' num2str(rowOrColStart-1) ')']);
ylabel('Module/Output');
zlabel(['Mean of ' dataTypeString '(' unitString ')']);
grid on;

set(gca, 'ytick',      1:4:nModOuts);
set(gca, 'yticklabel', tickStr(1:4:nModOuts));

titleStr = ['Mean of ' dataTypeString ' for All ' collateralTypeString 's across each ModOut'];
title(titleStr);

plot_to_file(titleStr, paperOrientationFlag, includeTimeFlag, printJpgFlag);

close all;

% --------------------------------------------
% 2D plot of mean values: superposed with offset
% --------------------------------------------

for j = 1:length(cdqInputStruct.channelArray)

    iChannel = cdqInputStruct.channelArray(j);

    [mod, out] = convert_to_module_output(iChannel);

    plot(meanMatrix(:,iChannel)+(j-1)*4*maxStd, 'p-', 'color', colorSpec(j,:), 'LineWidth', 1);

    cleanedIndex = find( isfinite( meanMatrix(:,iChannel) ) );
    if ( ~isempty(cleanedIndex) )
        text(nRowsOrCols+1, meanMatrix(cleanedIndex(end),iChannel)+(j-1)*4*maxStd, ['(' num2str(mod) ',' num2str(out) ')']);
    end

    hold on;

end

xRange = xlim;
xlim([xRange(1) xRange(2)+2]);

set(gca, 'fontsize', 16);
xlabel([collateralTypeString ' (offset:' num2str(rowOrColStart-1) ')']);
ylabel(['Mean of ' dataTypeString '(' unitString ')']);

titleStr = ['Mean of ' dataTypeString ' for ' collateralTypeString 's across each ModOut Superposed with Offset'];
title(titleStr);

plot_to_file(titleStr, paperOrientationFlag, includeTimeFlag, printJpgFlag);

close all;

% --------------------------------------------
% 2D plot of mean values: superposed without offset 
% --------------------------------------------

for j = 1:length(cdqInputStruct.channelArray)

    iChannel = cdqInputStruct.channelArray(j);

    [mod, out] = convert_to_module_output(iChannel);

    plot(meanMatrix(:,iChannel), 'p-', 'color', colorSpec(j,:), 'LineWidth', 1);

    cleanedIndex = find( isfinite( meanMatrix(:,iChannel) ) );
    if ( ~isempty(cleanedIndex) )
        text(nRowsOrCols+1, meanMatrix(cleanedIndex(end),iChannel), ['(' num2str(mod) ',' num2str(out) ')']);
    end

    hold on;

end

xRange = xlim;
xlim([xRange(1) xRange(2)+2]);

set(gca, 'fontsize', 16);
xlabel([collateralTypeString ' (offset:' num2str(rowOrColStart-1) ')']);
ylabel(['Mean of ' dataTypeString '(' unitString ')']);

titleStr = ['Mean of ' dataTypeString ' for ' collateralTypeString 's across each ModOut Superposed without Offset'];
title(titleStr);

plot_to_file(titleStr, paperOrientationFlag, includeTimeFlag, printJpgFlag);

close all;

return


function colorSpec = color_specification(nColor)

colorSpec = zeros(nColor,3); % R, G, B colors

shuffleOrder = randperm(nColor);
shuffleOrder = shuffleOrder(:);
colorSpec(shuffleOrder,1) = linspace(0.001, 1, nColor);

shuffleOrder = randperm(nColor);
shuffleOrder = shuffleOrder(:);
colorSpec(shuffleOrder,2) = linspace(0.001, 1, nColor);

shuffleOrder = randperm(nColor);
shuffleOrder = shuffleOrder(:);
colorSpec(shuffleOrder,3) = linspace(0.001, 1, nColor);

return
