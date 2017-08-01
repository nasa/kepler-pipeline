function pixelData = retrieve_pixel_model(module, output, mjdStart, mjdEnd, type)
% function pixelData = retrieve_pixel_model(module, output, mjdStart, mjdEnd, type)
% 
% Returns a matlab PixelData object that contains data necessary to determine
% the pixel for any time between mjdStart and mjdEnd.
%
% The data are the pixel values in electrons/DN.
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
    import gov.nasa.kepler.systest.sbt.SandboxTools;
    SandboxTools.displayDatabaseConfig;

    import gov.nasa.kepler.fc.PixelModel;
    import gov.nasa.kepler.fc.invalidpixels.PixelOperations;

    ops = PixelOperations();

    if nargin == 4
        pixelModel = ops.retrievePixelModel(module, output, mjdStart, mjdEnd);
    elseif nargin == 5
        pixelModel = ops.retrievePixelModel(module, output, mjdStart, mjdEnd, type);
    else
        error('retrieve_pixel_model must be called with 4 or 6 args');
    end

    % Extract non-string fields:
    %
    pixelData.ccdModules  = pixelModel.getCcdModules();
    pixelData.ccdOutputs  = pixelModel.getCcdOutputs();
    pixelData.ccdRows     = pixelModel.getCcdRows();
    pixelData.ccdColumns  = pixelModel.getCcdColumns();
    pixelData.startTimes  = pixelModel.getStartTimes();
    pixelData.endTimes    = pixelModel.getEndTimes();
    pixelData.pixelValues = pixelModel.getPixelValues();

    % Extract "types", a string field:
    %
    types = pixelModel.getTypes();
    for it = 1:length(types)
        pixelData.types{it} = char(types(it));
    end

    import gov.nasa.kepler.hibernate.fc.HistoryModelName
    pixelData.fcModelMetadata = get_model_metadata(pixelModel.getFcModelMetadata);
       
    import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
    dbInstance = DatabaseServiceFactory.getInstance();
    dbInstance.clear();
SandboxTools.close;
return
