function tadStruct = retrieve_tad(ccdModule, ccdOutput, targetListSetName, includeRejected, requireSupplemental)
% tadStruct = retrieve_tad(ccdModule, ccdOutput, targetListSetName)
% or
% tadStruct = retrieve_tad(ccdModule, ccdOutput, targetListSetName, includeRejected)
% or
% tadStruct = retrieve_tad(ccdModule, ccdOutput, targetListSetName, includeRejected, requireSupplemental)
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
            includeRejected = false;
            requireSupplemental = true;
        case 4
            requireSupplemental = true;
        case 5
             % do nothing
        otherwise
            error('retrieve_tad: Illegal call. Usage is retrieve_tad(ccdModule, ccdOutput, targetListSetName, includeRejected)');
    end
    
    import gov.nasa.kepler.systest.sbt.SandboxTools;
    SandboxTools.displayDatabaseConfig;

    import gov.nasa.kepler.systest.sbt.SbtRetrieveTad;
    sbt = SbtRetrieveTad();
    
    pathJava = sbt.retrieveTad(ccdModule, ccdOutput, targetListSetName, includeRejected, requireSupplemental);
    path = pathJava.toCharArray()';
    
    tadStruct = sbt_sdf_to_struct(path);

    % Reshape coaImage into a matlab matrix:
    %
    nrows = length(tadStruct.coaImage);
    ncols = length(tadStruct.coaImage(1).array);
    coaImage = zeros(nrows, ncols);
    for irow = 1:nrows
        coaImage(irow,:) = tadStruct.coaImage(irow).array(:)';
    end
    tadStruct.coaImage = coaImage;
    
    % Reformat data for ETEM2 compatiblity
    %
    tadStruct.maskDefinitions = tadStruct.targetMaskDefinitions;
    for imaskdef = 1:length(tadStruct.maskDefinitions)
        for ioffset = 1:length(tadStruct.maskDefinitions(imaskdef).rowOffsets)
            tadStruct.maskDefinitions(imaskdef).offsets(ioffset).row = tadStruct.maskDefinitions(imaskdef).rowOffsets(ioffset);
            tadStruct.maskDefinitions(imaskdef).offsets(ioffset).column = tadStruct.maskDefinitions(imaskdef).columnOffsets(ioffset);
        end
    end
    for imaskdef = 1:length(tadStruct.backgroundMaskDefinitions)
        for ioffset = 1:length(tadStruct.backgroundMaskDefinitions(imaskdef).rowOffsets)
            tadStruct.backgroundMaskDefinitions(imaskdef).offsets(ioffset).row = tadStruct.backgroundMaskDefinitions(imaskdef).rowOffsets(ioffset);
            tadStruct.backgroundMaskDefinitions(imaskdef).offsets(ioffset).column = tadStruct.backgroundMaskDefinitions(imaskdef).columnOffsets(ioffset);
        end
    end
    

    SandboxTools.close;
return
