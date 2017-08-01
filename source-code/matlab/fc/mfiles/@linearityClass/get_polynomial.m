function [offsetX scaleX originX type maxDomain coefficients]  = get_polynomial(linearityObject, mjd, module, output)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [offsetX scaleX originX type maxDomain coefficients]  = get_polynomial(linearityObject, mjd, module, output)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% get the linearity polynomial for a given module/output at a given mjd vector of
% mjd for this linearityObject
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
    isModOutSpecified = 4 == nargin;

    if isModOutSpecified && length(module) ~= length(output) && length(rows) ~= length(columns)
        error('Matlab:FC:Linearity::get_linearity needs equal-length module, output, row, and column arguments');
    end

    % Validate mod/out args with convert_from_module_output
    %
    channel = convert_from_module_output(module, output);

    
    indexBefore = find(mjd <  min(linearityObject.mjds));
    indexAfter  = find(mjd >  max(linearityObject.mjds));
    indexIn     = find(mjd >= min(linearityObject.mjds) & mjd <= max(linearityObject.mjds));

    nTimesInModel =  size(linearityObject.constants, 1);
%     coefficients = zeros(nTimesInModel, 1, 6);
                
    if ~isempty(indexBefore)
        coefficients(indexBefore, :, :) = squeeze(linearityObject.constants(1, :, :));
        if nTimesInModel > 1
            offsetX(indexBefore, :)      = linearityObject.offsetXs(  1,:);
            scaleX(indexBefore, :)       = linearityObject.scaleXs(   1,:);
            originX(indexBefore, :)      = linearityObject.originXs(  1,:);
            type(indexBefore, :, :)      = 'standard'; %linearityObject.types(     1,:);
            %xIndex(indexBefore, :)       = linearityObject.xIndices(  1,:);
            maxDomain(indexBefore, :)    = linearityObject.maxDomains(1,:);
        else
            offsetX(indexBefore, :)      = linearityObject.offsetXs(  :);
            scaleX(indexBefore, :)       = linearityObject.scaleXs(   :);
            originX(indexBefore, :)      = linearityObject.originXs(  :);
            type(indexBefore, :, :)      = 'standard'; %linearityObject.types(     :);
            %xIndex(indexBefore, :)       = linearityObject.xIndices(  :);
            maxDomain(indexBefore, :)    = linearityObject.maxDomains(:);
        end
    end
    
    if ~isempty(indexAfter)
        for iIndex = 1:length(indexAfter)
            coefficients(indexAfter(iIndex), :, :) = squeeze(linearityObject.constants(end, :, :));
            if nTimesInModel > 1
                offsetX(indexAfter(iIndex), :)      = linearityObject.offsetXs(  end,:);
                scaleX(indexAfter(iIndex), :)       = linearityObject.scaleXs(   end,:);
                originX(indexAfter(iIndex), :)      = linearityObject.originXs(  end,:);
                type(indexAfter(iIndex), :, :)      = 'standard';
                %xIndex(indexAfter(iIndex), :)       = linearityObject.xIndices(  end,:);
                maxDomain(indexAfter(iIndex), :)    = linearityObject.maxDomains(end,:);
            else
                offsetX(indexAfter(iIndex), :)      = linearityObject.offsetXs(  :);
                scaleX(indexAfter(iIndex), :)       = linearityObject.scaleXs(   :);
                originX(indexAfter(iIndex), :)      = linearityObject.originXs(  :);
                type(indexAfter(iIndex), :, :)      = linearityObject.types(     :);
                %xIndex(indexAfter(iIndex), :)       = linearityObject.xIndices(  :);
                maxDomain(indexAfter(iIndex), :)    = linearityObject.maxDomains(:);
            end
        end
    end
    
    if ~isempty(indexIn)
%         for ichannel = 1:84
            if nTimesInModel > 1
                coefficients(indexIn, :, :) = interp1(linearityObject.mjds, linearityObject.constants,  mjd);
                offsetX(indexIn)            = interp1(linearityObject.mjds, linearityObject.offsetXs,   mjd);
                scaleX(indexIn)             = interp1(linearityObject.mjds, linearityObject.scaleXs,    mjd);
                originX(indexIn)            = interp1(linearityObject.mjds, linearityObject.originXs,   mjd);
                for ii = 1:length(indexIn)
                    type(indexIn(ii), :)    = 'standard'; %linearityObject.types;
                end
                %xIndex(indexIn)             = interp1(linearityObject.mjds, linearityObject.xIndices,   mjd);
                maxDomain(indexIn)          = interp1(linearityObject.mjds, linearityObject.maxDomains, mjd);
            elseif 1 == nTimesInModel
                coefficients(indexIn, :, :) = linearityObject.constants;
                offsetX(indexIn, :)            = linearityObject.offsetXs(:);
                scaleX(indexIn, :)             = linearityObject.scaleXs(:);
                originX(indexIn, :)            = linearityObject.originXs(:);
                type(indexIn, :, :)            = 'standard'; %linearityObject.types(:);
                %xIndex(indexIn, :)             = linearityObject.xIndices(:);
                maxDomain(indexIn, :)          = linearityObject.maxDomains(:);
            else
                error('MATLAB:FC:linearityClass:get_polynomial', 'Linearity Object contains < 1 times-- error');
            end
%         end
    end

%     coefficients = coefficients(:, channel, :);
    coefficients = squeeze(coefficients);


%     offsetX   = offsetX(:, channel);
%     scaleX    = scaleX( :, channel);
%     originX   = originX(:, channel);
%     type      = type(:, channel);
%     %xIndex    = xIndex(:, channel);
%     maxDomain = maxDomain(:, channel);

return
