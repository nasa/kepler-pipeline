function self = test_importer_invalid_pixels(self)
%
% function self = test_importer_invalid_pixels(self)
%
% Invalid pixel test case for round-trip from java Importer through database,
% back to matlab.  Assumes a database that has been cleaned
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
    import gov.nasa.kepler.fc.importer.ImporterInvalidPixels
    importer = ImporterInvalidPixels();
    args = javaArray('java.lang.String', 2);
    args(1) = java.lang.String('rewriteHistory');
    args(2) = java.lang.String('test from test_importer_pixels');
    importer.main(args);
    
    % Get data from file(java) and database(matlab):
    %
    importer_invalid_pixels = importer.parseFile(get_importer_filename('invalid-pixels'));


    for ipix = 1:importer_invalid_pixels.size()
        pix = importer_invalid_pixels.get(ipix-1);
        db_pixels = retrieve_invalid_pixels_model(pix.getCcdModule(), pix.getCcdOutput(), pix.getStartTime(), pix.getEndTime(), pix.getType());

        pix_match_sum = 0;
        for idb = 1:length(db_pixels.pixels)
            db_pix = db_pixels.pixels(idb);
            pix_match_sum = pix_match_sum + (pix.getCcdRow() == db_pix.getCcdRow() && ...
                                             pix.getCcdColumn() == db_pix.getCcdColumn() && ...
                                             pix.getPixelValue() == db_pix.getPixelValue());
        end

        assert(pix_match_sum > 0);
    end

return
