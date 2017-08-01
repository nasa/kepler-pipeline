function output_covar  = get_covariance_matrix(linearityObject, mjd, module, output)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function covariance  = get_covariance_matrix(linearityObject, mjd, module, output)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Get the linearity covariance matrix for a given module/output at a given mjd for this linearityObject
%
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
    isModOutSpecified = 6 == nargin;

    if isModOutSpecified && length(module) ~= length(output) && length(rows) ~= length(columns)
        error('Matlab:FC:Linearity::get_linearity needs equal-length module, output, row, and column arguments');
    end
    
    indexBefore = find(mjd <  min(linearityObject.mjds));
    indexAfter  = find(mjd >  max(linearityObject.mjds));
    indexIn     = find(mjd >= min(linearityObject.mjds) & mjd <= max(linearityObject.mjds));
    
    nTimesInModel =  size(linearityObject.uncertainties, 1);
    
    if ~isempty(indexBefore)
        for iIndex=1:length(indexBefore)
            covariance(iIndex, :) = squeeze(linearityObject.uncertainties(1, :, :));
        end
    end
    
    if ~isempty(indexAfter)
        for iIndex=1:length(indexAfter)
            covariance(iIndex, :) = linearityObject.uncertainties(end, :, :);
        end
    end
    
    if ~isempty(indexIn)
        if nTimesInModel > 1
            covariance(indexIn, :) = interp1(linearityObject.mjds, linearityObject.uncertainties,  mjd);
        elseif 1 == nTimesInModel
            covariance(indexIn, :) = linearityObject.uncertainties;
        else
            error('MATLAB:FC:linearityClass:get_covariance_matrix', 'Linearity Object contains < 1 times-- error');
        end
    end

% %     covariance = squeeze(reshape(covariance, 84, size(covariance, 2)/84));
%     channel = convert_from_module_output(module, output);
%     covariance = covariance(:, channel, :);
    covariance = squeeze(covariance);
    
    
    % Check for covariance trouble
    %
    for ii = 1:length(mjd)
        tmp_covar = covariance(ii,:);
        tmp_covar_size = sqrt(numel(tmp_covar));
        tmp_covar = reshape(tmp_covar, tmp_covar_size, tmp_covar_size);
        output_covar(ii,:,:) = tmp_covar;
%        [Trow,errFlagRow] = factor_covariance_matrix(tmp_covar)
 %       if errFlagRow < 0
  %          % not a valid covariance matrix.
   %         error('PDQ:centroidMetric:InvalidCcentroidRowCovMat', 'Covariance matrix must be positive definite or positive semidefinite.');
    %    end
    end
%     output_covar = squeeze(output_covar);
return
