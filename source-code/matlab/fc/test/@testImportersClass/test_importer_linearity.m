function self = test_importer_linearity(self)
%
% function self = test_importer_linearity(self)
%
% Read noise test case for round-trip from java Importer through database, back to matlab.
% Assumes a database that has been cleaned, then seeded with the importers.
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
    EARLY_MJD = 40000;
    LATE_MJD = 80000;

    import gov.nasa.kepler.fc.importer.ImporterLinearity
    importer = ImporterLinearity();
    args = javaArray('java.lang.String', 2);
    args(1) = java.lang.String('rewriteHistory');
    args(2) = java.lang.String('test from test_importer_linearity');
    importer.main(args);
    
    % Get data from file(java) and database(matlab):
    %
    importer_linearitys = importer.parseFile(get_importer_filename('linearity'));

    for ichannel = 1:84
        importer_linearity = importer_linearitys.get(ichannel-1);
        module = importer_linearity.getCcdModule();
        output = importer_linearity.getCcdOutput();

        model_linearity = retrieve_linearity_model(EARLY_MJD, LATE_MJD, module, output);

        assert_equals(importer_linearity.getStartMjd(),      unique(model_linearity.mjds));
        assert_equals(importer_linearity.getCoefficients(),  model_linearity.constants(ichannel).array');
        assert_equals(importer_linearity.getUncertainties(), model_linearity.uncertainties(ichannel).array');
        assert_equals(importer_linearity.getOffsetX(),       model_linearity.offsetXs(ichannel));
        assert_equals(importer_linearity.getScaleX(),        model_linearity.scaleXs(ichannel));
        assert_equals(importer_linearity.getOriginX(),       model_linearity.originXs(ichannel));
        assert_equals(importer_linearity.getMaxDomain(),     model_linearity.maxDomains(ichannel));
    end
return
