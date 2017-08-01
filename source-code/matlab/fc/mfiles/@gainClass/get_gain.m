function outputGains = get_gain(gainObject, mjds, module, output)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% outputGains = get_gain(gainObject, mjds, module, output)
% or
% outputGains = get_gain(gainObject, mjds)
% or
% outputGains = get_gain(gainObject)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Get the gain for an (optional) vector of (module, output) at a given 
% vector of mjd for this gainObject
%
% The gain values are in units of electrons/DN.
%
% The outputGains is a matrix of gains with size MxN,where M is the length of the input MJDs, and N
% is either 84 or the length of the module/output outputs, if given.
%
% The input mjds argument need not be sorted.
%
% The call with no input args (except the object) gets the gain that
% is valid for the latest MJD.
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

    isModOutSpecified = 4 == nargin;

    
    if 1 ~= nargin && 2 ~= nargin && 4 ~= nargin
        error('MATLAB:FC:gainClass:get_gain','MATLAB:FC:gainClass:get_gain: get_gain takes 1, 2, or 4 args');
    end
    
    if isModOutSpecified && length(module) ~= length(output)
        error('MATLAB:FC:gainClass:get_gain', 'MATLAB:FC:gainClass:get_gain needs equal-length module and output arguments');
    end
    
    if nargin == 1
        mjds = max(gainObject.mjds) + 1;
    end

    % Prepopulate output with NaNs:
    %
    numMjds = length(mjds);
    outputGains = nan(numMjds, 84);
    
    % Convert mod/out to channel; the convert_from_module_output routine validates
    % the mod/out values:
    %
    if ~isModOutSpecified
        channel = 1:84;
    else
        channel = convert_from_module_output(module, output);
    end
    
    indexBefore = find(mjds <  min(gainObject.mjds));
    indexAfter  = find(mjds >  max(gainObject.mjds));
    indexIn     = find(mjds >= min(gainObject.mjds) & mjds <= max(gainObject.mjds));
    if ~isempty(indexBefore)
        outputGains(indexBefore,:) = repmat(gainObject.constants(  1, :), length(indexBefore), 1);
    end
    if ~isempty(indexAfter)
        outputGains(indexAfter, :) = repmat(gainObject.constants(end, :), length(indexAfter), 1);
    end
    if ~isempty(indexIn)
        if length(gainObject.mjds) == 1
            outputGains(indexIn, :) = gainObject.constants;
        else
            outputGains(indexIn, :) = interp1(gainObject.mjds, gainObject.constants, mjds(indexIn));
        end
    end
    
    outputGains = outputGains(:,channel);
    
    % check for NaNs and error.
    if any(isnan(outputGains(:)))
        error('MATLAB:FC:gainClass:get_gain', 'outputGains not fully populated in gainClass::get_gain');
    end
    
    % check for negativity
    if any(outputGains(:) < 0) 
        error('MATLAB:FC:gainClass:get_gain', 'outputGains cannot be negative in gainClass::get_gain');
    end
    
    % Sanity check on data:
    %
    fc_nonimage_data_check(outputGains);
return
