function self = test_sggen(self)
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
    inputStruct.raDec2PixModel = retrieve_ra_dec_2_pix_model();
	inputStruct.mjds = 55001:55050;
                                   
    raInc = 0.01;
    decInc = 0.01;
    nStars = 10;
    for ii = 1:nStars
        inputStruct.stars(ii) = struct('keplerId', 1001+ii, ...
                                        'ra', (300+ii*raInc)/15, ...
                                       'dec', 45+ii*decInc);

    end

    outputStruct = sggen_matlab_controller(inputStruct);

    assert(isfield(outputStruct, 'stars'));
    assert_equals(length(outputStruct.stars), nStars);
    
    fieldList = {'keplerId', 'ra', 'dec', 'ccdModules', 'ccdOutputs', 'ccdRows', 'ccdColumns'};
    assert_equals(sum(isfield(outputStruct.stars, fieldList)), length(fieldList));

    for ii = 1:nStars
        assert_equals(length(outputStruct.stars(ii).ccdModules), length(outputStruct.stars(ii).ccdOutputs));
        assert_equals(length(outputStruct.stars(ii).ccdModules), length(outputStruct.stars(ii).ccdRows));
        assert_equals(length(outputStruct.stars(ii).ccdModules), length(outputStruct.stars(ii).ccdColumns));

        assert_equals(unique(outputStruct.stars(ii).ccdModules), 10);
        assert_equals(unique(outputStruct.stars(ii).ccdOutputs),  3);

        allMods = [outputStruct.stars(ii).ccdModules];
        allOuts = [outputStruct.stars(ii).ccdOutputs];
        allRows = [outputStruct.stars(ii).ccdRows];
        allCols = [outputStruct.stars(ii).ccdColumns];

        assert(unique(allMods) == 10);
        assert(unique(allOuts) ==  3);

        assert(all(allRows >  720));
        assert(all(allRows <  809));
        assert(all(allCols > 1034));
        assert(all(allCols < 1109));
    end
    
return
