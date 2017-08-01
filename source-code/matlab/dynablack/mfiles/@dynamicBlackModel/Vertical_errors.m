function errDN = Vertical_errors(obj, row_list, lc_list)
%
% function errDN = Vertical_errors(obj, row_list, lc_list)
%
% Vertical_errors (multiple pixel & LC case)
% Method for DynamicBlackModel objects for calculating error in vertical component of black level
% 
% ARGUMENTS
% 
% * Function returns:
% * --> |errDN  -| estimates row-dependent component of black-level error in DN/read for the given set of arguments.
%
% * Function arguments:
% * --> |obj         -| DynamicBlackModel object being estimated. 
% * --> |row_list    -| which rows.
% * --> |lc_list     -| which LCs.
%
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

% We fit nominally 6 rows 2,3,4,5,9,10
% Note coadd normalization for the collater black is contained in sub matrices
% for the fit so we will *not* include that normalization while retrieving (evaluating)
% the models
% 
% fclcModel.rows.Matrix   = [ones(1,fclcModel.rows.Datum_count); ...
%                            allpix_const; ...
%                            allpix_linear; ...
%                            allpix_long_time_scale; ...
%                            allpix_exprow; ...
%                            leading_const; ...
%                            leading_long_time_scale; ...
%                            leading_exprow; ...
%                            maskedSmearRow_const; ...
%                            maskedSmearRow_linear];


if nargin > 0
    
    removeStatic2DBlack = obj.removeStatic2DBlack;
    longTimeConstant = obj.longTimeConstant;
    thermalRowOffset = obj.thermalRowOffset;
    maxMaskedSmearRow = obj.maxMaskedSmearRow;
    minScienceRow = maxMaskedSmearRow + 1;
    correlationMatrix = obj.verticalCorrelationMatrix;
    
    row_count = length(row_list);
    lc_count = length(lc_list);
    errDN = zeros(row_count,lc_count);
    
    for row_ID = 1:row_count
        row = row_list(row_ID);
        notMaskedSmear = double(row > maxMaskedSmearRow);

        if removeStatic2DBlack
            longTimeScale = notMaskedSmear.*exp(-(row - minScienceRow)./longTimeConstant).*ones(lc_count,1);
        else
            longTimeScale = notMaskedSmear.*log(row/thermalRowOffset + 1).*ones(lc_count,1);
        end

        predictors = [notMaskedSmear.*ones(lc_count,1) ...
                      notMaskedSmear.*row.*ones(lc_count,1) ...
                      longTimeScale ...
                      notMaskedSmear.*exp(-(row - minScienceRow)./obj.Vertical_parameters.estimates(obj.Predictors,1,lc_list)') ...
                      (1-notMaskedSmear).*ones(lc_count,1) ...
                      (1-notMaskedSmear).*row.*ones(lc_count,1)];     
        
        coefficientErrors = obj.Vertical_errorParams.estimates(obj.Predictors,2:(size(predictors,2)+1),lc_list)';
        
        errTerms = predictors.*coefficientErrors;
        var = sum((errTerms*correlationMatrix).*errTerms,2);
        errDN(row_ID,1:lc_count) = sqrt(var);
    end
end
