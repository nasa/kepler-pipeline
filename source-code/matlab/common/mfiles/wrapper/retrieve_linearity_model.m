 function linearityData = retrieve_linearity_model(mjdStart, mjdEnd, module, output)
% linearityData = retrieve_linearity_model(mjdStart, mjdEnd, module, output)
% 
% Returns a matlab LinearityData object that contains data necessary to
% determine the linearity for any time between mjdStart and mjdEnd for
% a given mod/out.
% 
% The linearity correction polynomials in this data set are a series of 
% coefficients for a 5th order polynomial describing the multiplicative
% scale factor to correct linearity for the 84 Kepler module/outputs.
% The polynomial should be evaluated using the SOC code weighted_polyval.m
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

    if nargin ~= 4
        error('Matlab:wrapper:retrieve_linearity_model', 'retrieve_linearity_model must be called with 4 args');
    end
    
    channel = convert_from_module_output(module, output);
    
    import gov.nasa.kepler.fc.LinearityModel;
    import gov.nasa.kepler.fc.linearity.LinearityOperations;
    
    ops = LinearityOperations();
    
    linearityData = struct(  ...
        'mjds',          [], ...
        'constants',     [], ...
        'uncertainties', [], ...
        'offsetXs',      [], ...
        'scaleXs',       [], ...
        'originXs',      [], ...
        'types',         [], ...
        'xIndices',      [], ...
        'maxDomains',    []);
    
    linearityModel = ops.retrieveLinearityModel(module, output, mjdStart, mjdEnd);

    linearityData.mjds     = linearityModel.getMjds();
    linearityData.offsetXs = linearityModel.getOffsetXs();
    linearityData.scaleXs  = linearityModel.getScaleXs();
    linearityData.originXs = linearityModel.getOriginXs();

    type = char(linearityModel.getTypes());
    typeLength = length(type);

    linearityData.xIndices   = linearityModel.getXIndices();
    linearityData.maxDomains = linearityModel.getMaxDomains();

    constants = linearityModel.getConstants();
    uncertainties = linearityModel.getUncertainties();
    for iElement = 1:(size(constants, 1))
        linearityData.constants(iElement).array = constants(iElement,:);
        linearityData.uncertainties(iElement).array = uncertainties(iElement,:);
    end

    linearityData.mjds = linearityData.mjds';
    linearityData.offsetXs = linearityData.offsetXs';
    linearityData.scaleXs = linearityData.scaleXs';
    linearityData.originXs = linearityData.originXs';
    linearityData.xIndices = linearityData.xIndices';
    linearityData.maxDomains = linearityData.maxDomains';

    import gov.nasa.kepler.hibernate.fc.HistoryModelName
    linearityData.fcModelMetadata = get_model_metadata(linearityModel.getFcModelMetadata);

    import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
    dbInstance = DatabaseServiceFactory.getInstance();
    dbInstance.clear();
SandboxTools.close;
return
