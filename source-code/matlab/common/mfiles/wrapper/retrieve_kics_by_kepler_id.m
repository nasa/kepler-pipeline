function [kics characteristics] = retrieve_kics_by_kepler_id(varargin)
% [kics characteristics] = retrieve_kics_by_kepler_id(keplerId)
% or
% [kics characteristics] = retrieve_kics_by_kepler_id(targetListSetName, 'get_chars')
% or
% [kics characteristics] = retrieve_kics_by_kepler_id(targetListSetName, module, output, 'get_chars')
% or
% [kics characteristics] = retrieve_kics_by_kepler_id(keplerId, 'get_chars')
% or
% [kics characteristics] = retrieve_kics_by_kepler_id(vectorOfKeplerIds)
% or
% [kics characteristics] = retrieve_kics_by_kepler_id(vectorOfKeplerIds, 'get_chars')
% or
% [kics characteristics] = retrieve_kics_by_kepler_id(minKeplerId, maxKeplerId)
% or
% [kics characteristics] = retrieve_kics_by_kepler_id(minKeplerId, maxKeplerId, 'get_chars')
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
   
    import gov.nasa.kepler.systest.sbt.SbtRetrieveKics;
    sbt = SbtRetrieveKics();

    import gov.nasa.kepler.systest.sbt.SbtRetrieveCharacteristics;
    sbtChars = SbtRetrieveCharacteristics();
    
    if nargin < 1
        error('retrieve_kics_by_kepler_id requires at least one argument, see helptext');
    end
    lastArg = varargin{nargin};
    if ischar(lastArg) && ~strcmp(lastArg, 'get_chars')
        error('retrieve_kics_by_kepler_id: unsupported usecase-- get_chars was set to %s, not "get_chars"', lastArg);
    end
    
    isGetChars = ischar(lastArg) && strcmp(lastArg, 'get_chars');

    
    switch nargin
        case 1
            % Usecases:
            %     kics = retrieve_kics_by_kepler_id(keplerId)
            %     kics = retrieve_kics_by_kepler_id(vectorOfKeplerIds)
            %
            % If the first arg have more than one element, it is a vector of kepler
            % IDs.  Otherwise, it's a single kepler ID.
            %
            keplerIds = lastArg(:)'; % the "(:)'" syntax forces a row vector, which is required for the below.
            keplerIdsArrayList = vector_to_array_list(keplerIds);
            pathJava = sbt.retrieveKics(keplerIdsArrayList);
        case 2
            if isGetChars
                if ischar(varargin{1})
                    % Usecases:
                    %     [kics outChars] = retrieve_kics_by_kepler_id(targetListSetName, 'get_chars')                
                    targetListSetName = varargin{1};
                    pathJava = sbt.retrieveKics(targetListSetName);
                    pathJavaChars = sbtChars.retrieveCharacteristics(targetListSetName);
                else
                    % Usecases:
                    %     kics = retrieve_kics_by_kepler_id(keplerId, 'get_chars')
                    %     kics = retrieve_kics_by_kepler_id(vectorOfKeplerIds, 'get_chars')
                    keplerIds = varargin{1};
                    keplerIdsArrayList = vector_to_array_list(keplerIds);
                    pathJava = sbt.retrieveKics(keplerIdsArrayList);
                    pathJavaChars = sbtChars.retrieveCharacteristics(keplerIdsArrayList);
                end
            else 
                % Usecases:
                %     kics = retrieve_kics_by_kepler_id(minKeplerId, maxKeplerId)
                minKeplerId = varargin{1};
                maxKeplerId = varargin{2};
                pathJava = sbt.retrieveKics(minKeplerId, maxKeplerId);
                
            end
        case 3
            if isGetChars
                % Usecase:
                %     kics = retrieve_kics_by_kepler_id(minKeplerId, maxKeplerId, 'get_chars')
                minKeplerId = varargin{1};
                maxKeplerId = varargin{2};
                keplerIdVector = minKeplerId:maxKeplerId;
                keplerIdsArrayList = vector_to_array_list(keplerIdVector);
                pathJava = sbt.retrieveKics(keplerIdsArrayList);
                pathJavaChars = sbtChars.retrieveCharacteristics(keplerIdsArrayList);
            else
                % Usecase:
                %     kics = retrieve_kics_by_kepler_id(targetListSetName, module, output)
                targetListSetName = varargin{1};
                ccdModule = varargin{2};
                ccdOutput = varargin{3};
                pathJava = sbt.retrieveKics(targetListSetName, ccdModule, ccdOutput);
            end
        case 4
            % Usecase:
            %    [kics outChars] = retrieve_kics_by_kepler_id(targetListSetName, module, output, 'get_chars')
            targetListSetName = varargin{1};
            ccdModule = varargin{2};
            ccdOutput = varargin{3};
            pathJava = sbt.retrieveKics(targetListSetName, ccdModule, ccdOutput);
            pathJavaChars = sbtChars.retrieveCharacteristics(targetListSetName, ccdModule, ccdOutput);
        otherwise
            error('Error in nargin switch block for retrieve_kics_by_kepler_id');
    end
    

    characteristics = [];
    if isGetChars
        pathChars = pathJavaChars.toCharArray()';
        charsStruct = sbt_sdf_to_struct(pathChars);
        if isfield(charsStruct, 'characteristics')
            characteristics = charsStruct.characteristics;
        end
    end
    
    path = pathJava.toCharArray()';
    kicsStruct = sbt_sdf_to_struct(path);
    kics = kicsStruct.kics;
    
    SandboxTools.close;
return

function arrayList = vector_to_array_list(matlabVector)
    import java.util.ArrayList;
    import java.lang.Integer;
    arrayList = ArrayList();
    for ii=1:length(matlabVector)
        arrayList.add(Integer(matlabVector(ii)));
    end
return
