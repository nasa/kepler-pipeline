function [kics characteristics] = retrieve_kics(varargin)
%function [kics characteristics] = retrieve_kics(module, output, mjd) 
% or
%function [kics characteristics] = retrieve_kics(module, output, mjd, 'get_chars') 
% or
%function [kics characteristics] = retrieve_kics(module, output, mjd, minKeplerMag, maxKeplerMag)
% or
%function [kics characteristics] = retrieve_kics(module, output, mjd, minKeplerMag, maxKeplerMag, 'get_chars')
% 
% Returns a vector of KIC objects corresponding to the KIC entries
% that fall on the specified module and output on the given MJD time.
%
% If the final argument is the string 'get_chars', the
% characteristics struct for each KIC object is returned as the separate
% output variable "characteristics". 
%
% INPUTS:
%     module        -- The module on the Kepler focal plane (a scalar value).
%     output        -- The output on the Kepler focal plane (a scalar value).
%     mjd           -- The MJD of interest (a scalar value)
%     minKeplerMag  -- The minimum Kepler magnitude to get data for (optional: the default is to retrieve all targets).
%     maxKeplerMag  -- The maximum Kepler magnitude to get data for (optional: the default is to retrieve all targets).
%     'get_chars'   -- An optional string argument.  If specified, the characteristics will be fetched.
%
% OUTPUTS:
%     kics:
%         A vector of KIC entries which match the input arguments.
%
%         When a characteristic table entry for a field is available, its latest
%         value overrides the value from the KIC.
%
%         The entry fields of kics are below.  Each entry has two fields, value and uncertainty.
%         If data for either field is not available, it is NaN.
%
%                 skyGroupId
%                 ra
%                 dec
%                 raProperMotion
%                 decProperMotion
%                 uMag
%                 gMag
%                 rMag
%                 iMag
%                 zMag
%                 gredMag
%                 d51Mag
%                 twoMassJMag
%                 twoMassHMag
%                 twoMassKMag
%                 keplerMag
%                 keplerId
%                 twoMassId
%                 internalScpId
%                 alternateId
%                 alternateSource
%                 galaxyIndicator
%                 blendIndicator
%                 variableIndicator
%                 effectiveTemp
%                 log10SurfaceGravity
%                 log10Metallicity
%                 ebMinusVRedding
%                 avExtinction
%                 radius
%                 photometryQuality
%                 astrophysicsQuality
%                 catalogId
%                 scpId
%                 parallax
%                 galacticLongitude
%                 galacticLatitude
%                 totalProperMotion
%                 grColor
%                 jkColor
%                 gkColor
%
%     characteristics:
%         A struct array with nTargets elements, with each element containing a
%         2-column cell array of the characteristics.  Each row contains the 
%         characteristic name in the first column and the characteristics value
%         in the second column.  Empty if 'get_chars' is not specified.
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

    
    % Parse args:
    %
    if nargin < 3 || nargin > 6
        error('retrieve_kics: incorrect number of arguments');
    end
    ccdModule = varargin{1};
    ccdOutput = varargin{2};
    mjd       = varargin{3};
    
    isGetChars = 0;
    isMagRangeGiven = 0;
    if nargin == 4 || nargin == 6
        lastArg = varargin{nargin};
        if strcmp('get_chars', lastArg)
            isGetChars = 1;
        else
            msg = ['retrieve_kics: unsupported usecase-- get_chars was set to "' lastArg '", not "get_chars"'];
            error(msg);
        end
    end
    if nargin == 5 || nargin == 6
        isMagRangeGiven = 1;
        minKeplerMag = varargin{4};
        maxKeplerMag = varargin{5};
    end
    
    
    import gov.nasa.kepler.systest.sbt.SbtRetrieveKics;
    import gov.nasa.kepler.systest.sbt.SbtRetrieveCharacteristics
    sbt = SbtRetrieveKics();
    sbtChars = SbtRetrieveCharacteristics();

    % Get KICs:
    %
    if isMagRangeGiven
        pathJava = sbt.retrieveKics(ccdModule, ccdOutput, mjd, minKeplerMag, maxKeplerMag);
    else
        pathJava = sbt.retrieveKics(ccdModule, ccdOutput, mjd);
    end
    
    %disp('Loading SDF file...');
    path = pathJava.toCharArray()';
    kicsStruct = sbt_sdf_to_struct(path);
    kics = kicsStruct.kics;

    % Get chars, if requested:
    %
    if isGetChars
        if isMagRangeGiven
            pathJavaChars = sbtChars.retrieveCharacteristics(ccdModule, ccdOutput, mjd, minKeplerMag, maxKeplerMag);
        else
            pathJavaChars = sbtChars.retrieveCharacteristics(ccdModule, ccdOutput, mjd);
        end
        pathChars = pathJavaChars.toCharArray()';
        charStruct = sbt_sdf_to_struct(pathChars);
        if ~isempty(charStruct)
            characteristics = charStruct.characteristics;
        else
            characteristics = [];
        end
    end
            
    SandboxTools.close;
return
