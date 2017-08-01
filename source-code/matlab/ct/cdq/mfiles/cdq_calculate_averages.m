function [cdqOutputStruct, cdqTemporaryStruct] = cdq_calculate_averages(cdqInputStruct)
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [cdqOutputStruct, cdqTemporaryStruct] = cdq_calculate_averages(cdqInputStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% This function calculates averages of RMS and thermal coefficient values produced by BART
% for each column of leading and trailing black and each row of virtual and masked smear data
% for each mod/out. 
%
% It also calculates the mean subtracted residuals and the corresponding statistics, 
% which will be used to generate the histogram plots later.
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
%  Input:
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
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
%  Outputs:
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
%    cdqOutputStruct and cdqTemporartStruct are automatically saved in cdq_output_struct.mat and cdq_temporary_struct.mat
%    respectively under the directory where the user is running cdq_matlab-controller.
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


nModOuts                = cdqInputStruct.fcConstantsStruct.MODULE_OUTPUTS;
ccdRows                 = cdqInputStruct.fcConstantsStruct.CCD_ROWS;

nLeadingBlack           = cdqInputStruct.fcConstantsStruct.nLeadingBlack;
nTrailingBlack          = cdqInputStruct.fcConstantsStruct.nTrailingBlack;
nMaskedSmear            = cdqInputStruct.fcConstantsStruct.nMaskedSmear;
nVirtualSmear           = cdqInputStruct.fcConstantsStruct.nVirtualSmear;

leadingBlackStart       = cdqInputStruct.fcConstantsStruct.LEADING_BLACK_START  + 1;
leadingBlackEnd         = cdqInputStruct.fcConstantsStruct.LEADING_BLACK_END    + 1;

trailingBlackStart      = cdqInputStruct.fcConstantsStruct.TRAILING_BLACK_START + 1;
% trailingBlackEnd        = cdqInputStruct.fcConstantsStruct.TRAILING_BLACK_END   + 1;

maskedSmearStart        = cdqInputStruct.fcConstantsStruct.MASKED_SMEAR_START   + 1;
% maskedSmearEnd          = cdqInputStruct.fcConstantsStruct.MASKED_SMEAR_END     + 1;

virtualSmearStart       = cdqInputStruct.fcConstantsStruct.VIRTUAL_SMEAR_START  + 1;
% virtualSmearEnd         = cdqInputStruct.fcConstantsStruct.VIRTUAL_SMEAR_END    + 1;

chargeInjectionRowStart = cdqInputStruct.fcConstantsStruct.CHARGE_INJECTION_ROW_START + 1;
chargeInjectionRowEnd   = cdqInputStruct.fcConstantsStruct.CHARGE_INJECTION_ROW_END   + 1;

blackRow           = 1:ccdRows;
smearColumn        = (leadingBlackEnd+1):(trailingBlackStart-1); 

nBlackRow          = length(blackRow);
nSmearColumn       = length(smearColumn);

chargeInjectionRows = chargeInjectionRowStart:chargeInjectionRowEnd;

vectorStruct.leadingBlack   = NaN(nLeadingBlack,  1);
vectorStruct.trailingBlack  = NaN(nTrailingBlack, 1);
vectorStruct.maskedSmear    = NaN(nMaskedSmear,   1);
vectorStruct.virtualSmear   = NaN(nVirtualSmear,  1);

matrixStruct.leadingBlack   = NaN(nBlackRow,    nLeadingBlack );
matrixStruct.trailingBlack  = NaN(nBlackRow,    nTrailingBlack);
matrixStruct.maskedSmear    = NaN(nSmearColumn, nMaskedSmear  );
matrixStruct.virtualSmear   = NaN(nSmearColumn, nVirtualSmear );

cdqOutputStruct.meanRms                                 = repmat(vectorStruct, nModOuts, 1);
cdqOutputStruct.meanThermalModelLinearTerm              = repmat(vectorStruct, nModOuts, 1);
cdqOutputStruct.meanThermalModelConstantTerm            = repmat(vectorStruct, nModOuts, 1);

cdqTemporaryStruct.residualRms                          = repmat(matrixStruct, nModOuts, 1);
cdqTemporaryStruct.residualThermalModelLinearTerm       = repmat(matrixStruct, nModOuts, 1);
cdqTemporaryStruct.residualThermalModelConstantTerm     = repmat(matrixStruct, nModOuts, 1);

cdqTemporaryStruct.maxResidualRms                       = repmat(vectorStruct, nModOuts, 1);
cdqTemporaryStruct.minResidualRms                       = repmat(vectorStruct, nModOuts, 1);
cdqTemporaryStruct.stdResidualRms                       = repmat(vectorStruct, nModOuts, 1);

cdqTemporaryStruct.maxResidualThermalModelLinearTerm    = repmat(vectorStruct, nModOuts, 1);
cdqTemporaryStruct.minResidualThermalModelLinearTerm    = repmat(vectorStruct, nModOuts, 1);
cdqTemporaryStruct.stdResidualThermalModelLinearTerm    = repmat(vectorStruct, nModOuts, 1);
 
cdqTemporaryStruct.maxResidualThermalModelConstantTerm  = repmat(vectorStruct, nModOuts, 1);
cdqTemporaryStruct.minResidualThermalModelConstantTerm  = repmat(vectorStruct, nModOuts, 1);
cdqTemporaryStruct.stdResidualThermalModelConstantTerm  = repmat(vectorStruct, nModOuts, 1);

for i = 1:length(cdqInputStruct.channelArray)

    iChannel    = cdqInputStruct.channelArray(i);
    
    if ( ~cdqInputStruct.modelFileAvailable(iChannel) || ~cdqInputStruct.diagnosticFileAvailable(iChannel) )
        continue;
    end
    
    modelFileName       = cdqInputStruct.modelFileNames{iChannel};
    diagnosticsFileName = cdqInputStruct.diagnosticFileNames{iChannel};
    
    eval(['load ' modelFileName       ' bartOutputModelStruct'      ]);
    eval(['load ' diagnosticsFileName ' bartDiagnosticsWeightStruct']);

    [mod, out]  = convert_to_module_output(iChannel);
    if ( exist('bartOutputModelStruct', 'var')~=1 || exist('bartDiagnosticsWeightStruct', 'var')~=1 )
        display(['Input files of module ' num2str(mod) ' output ' num2str(out) ' do not include correct variables']);
        continue;
    end

    for j = 1:nLeadingBlack
        
        col = j + leadingBlackStart - 1;

        vBuf = squeeze( bartDiagnosticsWeightStruct.weightedRmsResiduals(blackRow,col) );
        [cdqOutputStruct, cdqTemporaryStruct] = calculate_mean_and_residual(vBuf, cdqOutputStruct, cdqTemporaryStruct, ...
            'Rms',                      'leadingBlack',  iChannel, j);
        
        vBuf = squeeze( bartOutputModelStruct.modelCoefficients(1,blackRow,col) );
        [cdqOutputStruct, cdqTemporaryStruct] = calculate_mean_and_residual(vBuf, cdqOutputStruct, cdqTemporaryStruct, ...
            'ThermalModelLinearTerm',   'leadingBlack',  iChannel, j);

        vBuf = squeeze( bartOutputModelStruct.modelCoefficients(2,blackRow,col) );
        [cdqOutputStruct, cdqTemporaryStruct] = calculate_mean_and_residual(vBuf, cdqOutputStruct, cdqTemporaryStruct, ...
            'ThermalModelConstantTerm', 'leadingBlack',  iChannel, j);
  
    end
    
    for j = 1:nTrailingBlack
        
        col = j + trailingBlackStart - 1;
        
        vBuf = squeeze( bartDiagnosticsWeightStruct.weightedRmsResiduals(blackRow,col) );
        [cdqOutputStruct, cdqTemporaryStruct] = calculate_mean_and_residual(vBuf, cdqOutputStruct, cdqTemporaryStruct, ...
            'Rms',                      'trailingBlack', iChannel, j);
        
        vBuf = squeeze( bartOutputModelStruct.modelCoefficients(1,blackRow,col) );
        [cdqOutputStruct, cdqTemporaryStruct] = calculate_mean_and_residual(vBuf, cdqOutputStruct, cdqTemporaryStruct, ...
            'ThermalModelLinearTerm',   'trailingBlack', iChannel, j);

        vBuf = squeeze( bartOutputModelStruct.modelCoefficients(2,blackRow,col) );
        [cdqOutputStruct, cdqTemporaryStruct] = calculate_mean_and_residual(vBuf, cdqOutputStruct, cdqTemporaryStruct, ...
            'ThermalModelConstantTerm', 'trailingBlack', iChannel, j);

    end

    for j = 1:nMaskedSmear
        
        row = j + maskedSmearStart - 1;
        
        vBuf = squeeze( bartDiagnosticsWeightStruct.weightedRmsResiduals(row,smearColumn) );
        [cdqOutputStruct, cdqTemporaryStruct] = calculate_mean_and_residual(vBuf, cdqOutputStruct, cdqTemporaryStruct, ...
            'Rms',                      'maskedSmear',   iChannel, j);
        
        vBuf = squeeze( bartOutputModelStruct.modelCoefficients(1,row,smearColumn) );
        [cdqOutputStruct, cdqTemporaryStruct] = calculate_mean_and_residual(vBuf, cdqOutputStruct, cdqTemporaryStruct, ...
            'ThermalModelLinearTerm',   'maskedSmear',   iChannel, j);

        vBuf = squeeze( bartOutputModelStruct.modelCoefficients(2,row,smearColumn) );
        [cdqOutputStruct, cdqTemporaryStruct] = calculate_mean_and_residual(vBuf, cdqOutputStruct, cdqTemporaryStruct, ...
            'ThermalModelConstantTerm', 'maskedSmear',   iChannel, j);

    end

    for j = 1:nVirtualSmear
        
        row = j + virtualSmearStart - 1;
        
        % Outputs of charge injection rows in virtual smear region remain to be NaNs if the chargeInjectionPixelRemoved flag is true.
        if ( ~cdqInputStruct.chargeInjectionPixelRemoved || ~ismember(row, chargeInjectionRows) )

            vBuf = squeeze( bartDiagnosticsWeightStruct.weightedRmsResiduals(row,smearColumn) );
            [cdqOutputStruct, cdqTemporaryStruct] = calculate_mean_and_residual(vBuf, cdqOutputStruct, cdqTemporaryStruct, ...
            'Rms',                      'virtualSmear',  iChannel, j);
        
            vBuf = squeeze( bartOutputModelStruct.modelCoefficients(1,row,smearColumn) );
            [cdqOutputStruct, cdqTemporaryStruct] = calculate_mean_and_residual(vBuf, cdqOutputStruct, cdqTemporaryStruct, ...
            'ThermalModelLinearTerm',   'virtualSmear',  iChannel, j);

            vBuf = squeeze( bartOutputModelStruct.modelCoefficients(2,row,smearColumn) );
            [cdqOutputStruct, cdqTemporaryStruct] = calculate_mean_and_residual(vBuf, cdqOutputStruct, cdqTemporaryStruct, ...
            'ThermalModelConstantTerm', 'virtualSmear',  iChannel, j);

        end
    
    end

    clear bartOutputModelStruct bartDiagnosticsWeightStruct;

end

return


function [cdqOutputStruct, cdqTemporaryStruct] = calculate_mean_and_residual(vector, cdqOutputStruct, cdqTemporaryStruct, metricName, fieldName, iChannel, index)
    
    vector = vector(:);
    cleanedIndex  = ~isnan(vector);
    vectorCleaned = vector(cleanedIndex);
    
    meanValue           = trimmean(vectorCleaned, 10, 1);
    vecResidual         = vector - meanValue;
    vecResidualCleaned  = vectorCleaned  - meanValue;

    maxResidual = max( vecResidualCleaned );
    minResidual = min( vecResidualCleaned );
    stdResidual = std( vecResidualCleaned );
    
    eval(['cdqOutputStruct.mean'           metricName '(' num2str(iChannel) ').' fieldName '('   num2str(index) ') = meanValue;'  ]);
    eval(['cdqTemporaryStruct.residual'    metricName '(' num2str(iChannel) ').' fieldName '(:,' num2str(index) ') = vecResidual;']);
    eval(['cdqTemporaryStruct.maxResidual' metricName '(' num2str(iChannel) ').' fieldName '('   num2str(index) ') = maxResidual;']);
    eval(['cdqTemporaryStruct.minResidual' metricName '(' num2str(iChannel) ').' fieldName '('   num2str(index) ') = minResidual;']);
    eval(['cdqTemporaryStruct.stdResidual' metricName '(' num2str(iChannel) ').' fieldName '('   num2str(index) ') = stdResidual;']);

return


