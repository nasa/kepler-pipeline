function kics = retrieve_kics_matlabstyle(varargin)
%function kics = retrieve_kics_matlabstyle(module, output, mjd) 
% or
%function kics = retrieve_kics_matlabstyle(module, output, mjd, 'get_chars') 
% or
%function kics = retrieve_kics_matlabstyle(module, output, mjd, minKeplerMag, maxKeplerMag)
% or
%function kics = retrieve_kics_matlabstyle(module, output, mjd, minKeplerMag, maxKeplerMag, 'get_chars')
% 
% Returns an array of structs that contain the KIC data for the entries
% that fall on the specified module and output on the given MJD time. If
% the final argument 'getCharacteristics' is added, characteristics will 
% be added to each KIC's output structure, otherwise the charcteristics 
% will not be added.
%
% This script converts the entire Java object (~45 fields) into MATLAB structs, 
% which can take a VERY LONG TIME for large datasets and often produces
% data which is of no interest to the user.  If you are only interested in
% a small subset of the KIC fields (ra/dec, say), consider using
% retrieve_kics instead and unpacking the desired fields manually.
%
% Characteristics retrieval is also substantially faster using
% retreive_kics than with this script.
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
%     kics  -- A struct array of KIC data.
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

    module = varargin{1};
    output = varargin{2};
    mjd    = varargin{3};
    isGetChars = 0;
    if nargin == 6 || nargin == 4
        isGetChars = 1;
    end

    switch nargin
        case {5,6}
            minKeplerMag = varargin{4};
            maxKeplerMag = varargin{5};
            kicsJava = retrieve_kics(module, output, mjd, minKeplerMag, maxKeplerMag);
        case {3,4}
            kicsJava = retrieve_kics(module, output, mjd);
        otherwise
            error('retrieve_kics_matlabstyle: incorrect number of arguments');
    end

    kics = convert_kics_java_to_matlab(kicsJava, isGetChars);
return
