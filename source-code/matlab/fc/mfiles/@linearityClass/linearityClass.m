
function linearityObject = linearityClass(linearityData, interpolation_method)
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
    if nargin < 2
        linearityData.interpolation_method = 'linear';
    else
        linearityData.interpolation_method = interpolation_method;
    end
    linearityObject = class(linearityData, 'linearityClass');

    % This loop is unavoidable b/c of the constants(i).array(j) 
    % structure of the constants structure in the linearityData
    %
    for iChannel = 1:size(linearityData.constants, 1)
        for iTime = 1:size(linearityData.constants, 2)
            linearity(iTime, iChannel, :)     = linearityData.constants(iChannel, iTime).array;
            uncertainties(iTime, iChannel, :) = linearityData.uncertainties(iChannel, iTime).array;
        end
    end
    
    % Data integrity check:
    %
    fc_mjd_check(linearityData.mjds);
    fc_nonimage_data_check(linearity);
    fc_nonimage_data_check(uncertainties);
    fc_nonimage_data_check(linearityData.offsetXs);
    fc_nonimage_data_check(linearityData.scaleXs);
    fc_nonimage_data_check(linearityData.originXs);   
    %fc_nonimage_data_check(linearityData.types);
    fc_nonimage_data_check(linearityData.xIndices);
    fc_nonimage_data_check(linearityData.maxDomains);

    linearityObject.constants = linearity;
    linearityObject.uncertainties = uncertainties;

    linearityObject.mjds = linearityData.mjds;
    linearityObject.offsetXs = linearityData.offsetXs;
    linearityObject.scaleXs = linearityData.scaleXs;
    linearityObject.originXs = linearityData.originXs;
    linearityObject.types = linearityData.types;
    linearityObject.xIndices = linearityData.xIndices;
    linearityObject.maxDomains = linearityData.maxDomains;
return

