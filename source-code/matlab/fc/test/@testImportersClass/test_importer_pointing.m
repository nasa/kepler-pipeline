function self = test_importer_pointing(self)
%
% function self = test_importer_pointing(self)
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

    import gov.nasa.kepler.fc.importer.ImporterPointing
    importer = ImporterPointing();
    args = javaArray('java.lang.String', 2);
    args(1) = java.lang.String('rewriteHistory');
    args(2) = java.lang.String('test from test_importer_pointing');
    importer.main(args);

    % Get data from file(java) and database(matlab):
    %
    importer_pointings = importer.parseFile(get_importer_filename('pointing'));
    model_pointings = retrieve_pointing_model();

    % Check size:
    %
    assert_equals(length(model_pointings.mjds), importer_pointings.size());
    

    for ipointing = 1:importer_pointings.size()
        % Check times:
        %
        importer_mjd = importer_pointings.get(ipointing-1).getMjd;
        model_mjd  = model_pointings.mjds(ipointing);
        assert_equals(importer_mjd, model_mjd);
        
        % check declination:
        %
        importer_dec = importer_pointings.get(ipointing-1).getDeclination;
        model_dec  = model_pointings.declinations(ipointing);
        assert_equals(importer_dec, model_dec);
        
        % check ra:
        %
        importer_ra = importer_pointings.get(ipointing-1).getRa;
        model_ra  = model_pointings.ras(ipointing);
        assert_equals(importer_ra, model_ra);
        
        % check roll:
        %
        importer_roll = importer_pointings.get(ipointing-1).getRoll;
        model_roll  = model_pointings.rolls(ipointing);
        assert_equals(importer_roll, model_roll);        
    end
    

return
