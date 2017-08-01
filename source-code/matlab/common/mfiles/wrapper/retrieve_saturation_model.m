function saturationModel = retrieve_saturation_model(seasons, ccdModules, ccdOutputs)
% saturationModel= retrieve_saturation_model(seasons, ccdModules, ccdOutputs)
% or
% saturationModel= retrieve_saturation_model()
%     (running retrieve_saturation_model with no arguments can take a long time, as it retrieves all saturation data)
%
% Returns a matlab saturationData object that contains the
% saturation information for the season/module/output specified.
%
% Inputs:
%     seasons:     A vector of seasons.  Each element must be between 0 and
%                  3, inclusive.  The vectors seasons, ccdModules, and ccdOutputs 
%                  must have the same length.
%     ccdModules:  A vector of CCD modules (2-4, 6-20, 22-24).The vectors seasons, ccdModules, and ccdOutputs 
%                  must have the same length.
%     ccdOutputs:  A vector of CCD outputs (1-4).The vectors seasons, ccdModules, and ccdOutputs 
%                  must have the same length.
% 
% If not inputs are given, every season/module/output combination is retrieve, with sequence:
%         season0/mod2/out1
%         season0/mod2/out2
%         season0/mod2/out3
%         season0/mod2/out4
%         season0/mod3/out1
%         ...
%         season1/mod2/out1
%         season1/mod2/out2
%         ...
%         season3/mod24/out4
% Running in this mode can take a long time, as it retrieves every saturation record from the database.
%
%
% Outputs:
%    saturationModel: a vector of structs.  The vector is the same length
%                     as seasons/ccdModules/ccdOutputs.  The fields of the 
%                     structs are:
%
%       .season            The season that this struct's data comes from.
%       .channel           The Kepler CCD channel of this struct's data.
%       .fcModelMetadata   The FC model's metadata (SVN info, DB
%                          configuration info etc)
%       .stars             The saturated targets for the current
%                          season/module/output.  This is a vector of structs, one element per target, with each struct having fields:
%
%             .keplerId        The Kepler ID of this target
%
%             .saturatedColumns   A vector of structs containing the pixel
%                                 specification for saturated pixels for this
%                                 target.  Each struct has fields:
%                 
%                     columnAddress  The (zero-based) column address of the saturated pixels
%                     rowStart       The (zero-based) minimum row of the saturated pixels
%                     rowEnd         The (zero-based) maximum row of the saturated pixels
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


    switch nargin 
        case 3 
            % This function also validates the mod/out values:
            %
            channels = convert_from_module_output(ccdModules, ccdOutputs);
        case 0
            seasons = [repmat(0, 1, 84) repmat(1, 1, 84) repmat(2, 1, 84) repmat(3, 1, 84)];
            channels = [1:84 1:84 1:84 1:84];
        otherwise
            error('SBT:retrieve_saturation_model', 'This tool requires three args.  See helptext.');
    end

    if length(seasons) ~= length(channels)
        error('SBT:retrieve_saturation_model', 'season, ccdModules, and ccdOutputs must have the same length');
    end
    
    import gov.nasa.kepler.systest.sbt.SandboxTools;
    SandboxTools.displayDatabaseConfig;

    % Retrieve a SDF object for each channel/season pair
    import gov.nasa.kepler.systest.sbt.SbtRetrieveSaturation;
    sbt = SbtRetrieveSaturation();
    for ii = 1:length(seasons)
        pathJava = sbt.retrieveSaturation(channels(ii), seasons(ii));
        path = pathJava.toCharArray()';

        saturationModel(ii) = sbt_sdf_to_struct(path);
    end

    import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
    dbInstance = DatabaseServiceFactory.getInstance();
    dbInstance.clear();

    SandboxTools.close;
return

