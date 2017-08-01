function self = test_dates(self)
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
    display('linearity dates');

    [modules_list outputs_list] = fc_test_get_modules_outputs_all();
    for ichannel = 1:length(modules_list)
        module = modules_list(ichannel);
        output = outputs_list(ichannel);
        mod = module;
        out = output;

        runStart = datestr2mjd('30-Mar-2012 17:29:36.8448');
        runEnd = runStart + 1;
        linearityModel = retrieve_linearity_model(runStart, runEnd, mod, out);
        linearityObject = linearityClass(linearityModel);

        [x s o t m c] = get_polynomial(linearityObject, runStart-1, mod, out);
        [x s o t m c] = get_polynomial(linearityObject, runStart, mod, out);
        [x s o t m c] = get_polynomial(linearityObject, runStart:0.1:runEnd, mod, out);
        [x s o t m c] = get_polynomial(linearityObject, runEnd+1, mod, out);

        [covar] = get_covariance_matrix(linearityObject, runStart-1, mod, out);
        [covar] = get_covariance_matrix(linearityObject, runStart, mod, out);
        [covar] = get_covariance_matrix(linearityObject, runStart:0.1:runEnd, mod, out);
        [covar] = get_covariance_matrix(linearityObject, runEnd+1, mod, out);
        
        % TODO: add more checks here:
        
        % Tests for squareness of return and correct size of coeffs/covar:
        assert_equals(size(c,2), size(covar, 2));
        assert_equals(size(c,2), size(covar, 3));
    end
return
