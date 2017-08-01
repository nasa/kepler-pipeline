function kicsOut = retrieve_kics_by_kepler_id_matlabstyle(varargin)
% kics = retrieve_kics_by_kepler_id_matlabstyle(keplerId)
% or
% kics = retrieve_kics_by_kepler_id_matlabstyle(keplerId, 'get_chars')
% or
% kics = retrieve_kics_by_kepler_id_matlabstyle(vectorOfKeplerIds)
% or
% kics = retrieve_kics_by_kepler_id_matlabstyle(vectorOfKeplerIds, 'get_chars')
% or
% kics = retrieve_kics_by_kepler_id_matlabstyle(minKeplerId, maxKeplerId)
% or
% kics = retrieve_kics_by_kepler_id_matlabstyle(minKeplerId, maxKeplerId, 'get_chars')
%
% 
% Returns an array of structs that contain the KIC data for the entries 
% whose Kepler IDs match the specified inputs.  When a characteristic table
% entry for a field is available, its latest value overrides the value from the
% KIC.
% 
% If 'get_chars' is specified, every characteristic for each target is retrieved
% (not just the one that override KIC fields), and is put into the .characteristics
% field of the output struct as a 2-column cell array.  Each row contains the
% characteristic name in the first column and the characteristics value in the
% second column.
%
% This script converts the entire Java object (~45 fields) into MATLAB structs, 
% which can take a VERY LONG TIME for large datasets and often produces
% data which is of no interest to the user.  If you are only interested in
% a small subset of the KIC fields (ra/dec, say), consider using
% retrieve_kics_by_kepler_id instead and unpacking the desired fields manually.
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

isGetChar = strcmp(varargin{end}, 'get_chars');
getCharacteristics = (nargin == 2 || nargin == 3) && isGetChar;

if ~isGetChar
    if(nargin == 1)
        kics = retrieve_kics_by_kepler_id(varargin{1});
    elseif(nargin == 2)
        kics = retrieve_kics_by_kepler_id(varargin{1}, varargin{2});
    else
        error('retrieve_kics_by_kepler_id_matlabstyle: incorrect number of arguments');
    end;
else
    if(nargin == 2)
        kics = retrieve_kics_by_kepler_id(varargin{1});
    elseif(nargin == 3)
        kics = retrieve_kics_by_kepler_id(varargin{1}, varargin{2});
    else
        error('retrieve_kics_by_kepler_id_matlabstyle: incorrect number of arguments');
    end;
end

if(isempty(kics))
    if(nargin == 1)
        error('retrieve_kics_by_kepler_id_matlabstyle: No KIC entries found for Kepler ID =%d', minKeplerId);
    else
        error('retrieve_kics_by_kepler_id_matlabstyle: No KIC entries found for Kepler ID range=%d-%d', minKeplerId, maxKeplerId);
    end;
end;

kicsOut = convert_kics_java_to_matlab(kics, isGetChar);

return;




