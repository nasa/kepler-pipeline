function undershootData = retrieve_undershoot_model(mjdStart, mjdEnd)
% function undershootData = retrieve_undershoot_model(mjdStart, mjdEnd)
% or
% function undershootData = retrieve_undershoot_model()
% 
% Returns a matlab UndershootData object that contains data necessary to determine
% the undershoot for any time between mjdStart and mjdEnd, or any time, if no arguments are given.
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

    import gov.nasa.kepler.fc.UndershootModel;
    import gov.nasa.kepler.fc.undershoot.UndershootOperations;

    undershootData = struct(...
        'mjds',      [], ...
        'constants', [], ...
        'uncertainty', []);

    ops = UndershootOperations();
    if nargin == 2
        undershootModel = ops.retrieveUndershootModel(mjdStart, mjdEnd);
    elseif nargin == 0
        undershootModel = ops.retrieveMostRecentUndershootModel();
    end

    undershootData.mjds = undershootModel.getMjds();

    if isempty(undershootData.mjds)
        error('retrieve_undershoot_model: No undershoot model found in database');
    end
    
    constants = undershootModel.getConstants();
    uncertainty = undershootModel.getUncertainty();
    for iTime = 1:(size(constants, 1))
        for iChannel = 1:(size(constants, 2))
            undershootData.constants(  iTime).array(iChannel).array = squeeze(constants(  iTime, iChannel, :));
            undershootData.uncertainty(iTime).array(iChannel).array = squeeze(uncertainty(iTime, iChannel, :));
        end
    end

    import gov.nasa.kepler.hibernate.fc.HistoryModelName
    undershootData.fcModelMetadata = get_model_metadata(undershootModel.getFcModelMetadata);
    
    import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
    dbInstance = DatabaseServiceFactory.getInstance();
    dbInstance.clear();

SandboxTools.close;
return
