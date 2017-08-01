function self = test_verify_nonlinear_fields(self)
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
    inputsStruct = arffi_wcs_get_fake_inputs_struct();
    sipWcs = ffi_wcs_nonlinear(inputsStruct);

    expectedFields = {
        'ra'
        'dec'
        'referenceCcdColumn'
        'referenceCcdRow'
        'maxDistortionA'
        'maxDistortionB'
        'rotationAndScale'
        'forwardPolynomial'
        'inversePolynomial' };
    assert(all(isfield(sipWcs, expectedFields)));
    
    % Verify the rotation and scale has the right size and values:
    %
    assert(isnumeric([sipWcs.rotationAndScale.array]));
    assert(length([sipWcs.rotationAndScale.array]) == 4);
    assert(eps > sum([sipWcs.rotationAndScale.array] - [-0.000934918631800371     -0.000588145580948889     -0.000588500512130365      0.000935182247888339]));

    correctReferenceColumn = 533;
    correctReferenceRow = 521;
    correctRa = 291.889744239982; 
    correctDec = 44.3252544373;
    smallValue = 1e-10;

    % Check that the coordinates are correct:
    %
    assert(sipWcs.referenceCcdColumn == correctReferenceColumn);
    assert(sipWcs.referenceCcdRow == correctReferenceRow);
    
    assert(sipWcs.ra - correctRa < smallValue);
    assert(sipWcs.dec - correctDec < smallValue);
    
    assert(sipWcs.maxDistortionA - 0.327514578245314 < smallValue);
    assert(sipWcs.maxDistortionB - 0.335194564280982 < smallValue);

    
    % Check that the fields are consistent across the four polys:
    %
    faFields = fields(sipWcs.forwardPolynomial.a.polynomial);
    assert(isequal(faFields, fields(sipWcs.forwardPolynomial.b.polynomial)));
    assert(isequal(faFields, fields(sipWcs.inversePolynomial.a.polynomial)));
    assert(isequal(faFields, fields(sipWcs.inversePolynomial.b.polynomial)));

    % Verify the coefficient lists are the same length for the forward and 
    % inverse polys:
    %
    assert_equals(length(sipWcs.forwardPolynomial.a.polynomial), length(sipWcs.forwardPolynomial.b.polynomial));
    assert_equals(length(sipWcs.inversePolynomial.a.polynomial), length(sipWcs.inversePolynomial.b.polynomial));

    % Verify the keyword names are the right format and the right fields
    % exist:
    %
    polyNames = {'forwardPolynomial' 'inversePolynomial'};
    otherNames = {'a' 'b'};
    keywordConcatRegexp = '(\d_\d)+';

    for polyNameLoop = polyNames
        polyName = polyNameLoop{1};

        assert(all(isfield(sipWcs.(polyName), otherNames)));
        
        for otherNameLoop = otherNames
            otherName = otherNameLoop{1};
            
            assert(isfield(sipWcs.(polyName).(otherName), 'polynomial'));
            
            assert(isnumeric([sipWcs.(polyName).(otherName).polynomial.value]));
            assert(ischar([sipWcs.(polyName).(otherName).polynomial.keyword]));
            
            keywords = [sipWcs.(polyName).(otherName).polynomial.keyword];
            isKeywordsCorrect = ~isempty(regexp(keywords, keywordConcatRegexp, 'once'));
            assert(isKeywordsCorrect);
        end
    end
    
return

