function [structs]  = get_weighted_polyval_struct(linearityObject, mjd, module, output)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [structs]  = get_weighted_polyval_struct(linearityObject, mjd, module, output)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% Get a list of linearity structs for a given module/output at a given 
% vector of mjd for this linearityObject.
%
% These structs are the input struct that the function weighted_polyval
% takes to evaluate the linearity polynomial encoded by the struct.  Sample
% code for calling using these results with weighted_polyval:
%
% [structs]  = get_weighted_polyval_struct(linearityObject, mjd, module, output)
% [linCorrectedValues uncertainties] = weighted_polyval(preLinValues, structs(1));
%
% The length of the list is the same as the length of the
% input arg mjd.  Also see get_max_domain to see the maximum domain
% that this polynomial struct is valid for.
%
% The input mjd argument need not be sorted.
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


    if nargin ~= 4
        error('MATLAB:FC:linearityObject:get_weighted_polyval_struct', 'MATLAB:FC:linearityObject:get_weighted_polyval_struct: get_weighted_polyval_struct takes 4 args');
    end
    
    if length(module) ~= 1 || length(output) ~= 1
        error('MATLAB:FC:linearityObject:get_weighted_polyval_struct', 'MATLAB:FC:linearityObject:get_weighted_polyval_struct: module/output should each be single values');        
    end
    
    nTimes = length(mjd);

    % Use library code to validate module/output arguments: the
    % convert_from_module_output routine validates these arguments. 
    %
    channel = convert_from_module_output(module, output); %#ok<NASGU>
    
    [offsetX scaleX originX type maxDomain coefficients] = get_polynomial(linearityObject, mjd, module, output);
    covariance_matrix =  get_covariance_matrix(linearityObject, mjd, module, output);
    
    tmp_structs = struct( ...
            'coeffs', 0, ...
            'covariance', 0, ...
            'order', 0, ...
            'type', 'standard', ...
            'offsetx', 0, ...
            'scalex', 0, ...
            'originx', 0);
    structs = repmat(tmp_structs, 1, nTimes);

    for itime = 1:nTimes
        if nTimes > 1
            order = size(coefficients, 2) - 1;
            structs(itime).coeffs = coefficients(itime, :)';
            structs(itime).covariance = reshape(covariance_matrix(itime, :, :), order+1, order+1);
        else
            order = length(coefficients) - 1;
            structs(itime).coeffs = coefficients(:);
            structs(itime).covariance = reshape(covariance_matrix(:), order+1, order+1);
        end
        structs(itime).order = order;
        structs(itime).offsetx = offsetX(itime);
        structs(itime).scalex = scaleX(itime);
        structs(itime).originx = originX(itime);
    end
return
