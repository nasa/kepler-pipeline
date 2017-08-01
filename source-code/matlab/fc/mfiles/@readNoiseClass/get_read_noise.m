function result = get_read_noise(readNoiseObject, mjds, module, output)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function result = get_read_noise(readNoiseObject, mjds)
% or 
% function result = get_read_noise(readNoiseObject, mjds, module, output)
% or
% function result = get_read_noise(readNoiseObject) 
% 
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% Get the read noise for the input vector of MJDs.  The read noise values 
% in this data are the noise introduced during readout for a single read 
% in units of digital numbers (DN). The indexing of the output is 
% readNoise(time, channel).  The size of the output is length(mjds) x M,
% where mjds is the input mjds arg, and M is 84 is if no module/outputs args
% are specified, and length(module/output) if they are.
%
% The input mjds argument need not be sorted.
%
% The call with no input args (except the object) gets the read noise that is valid for the latest MJD.
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

    if nargin == 1
        mjds = max(readNoiseObject.mjds) + 1;
    end

    % Preallocate:
    %
    result = zeros(length(mjds), 84);

    indexBefore = find(mjds <=  min(readNoiseObject.mjds));
    indexAfter  = find(mjds >=  max(readNoiseObject.mjds));
    indexIn     = find(mjds > min(readNoiseObject.mjds) & mjds < max(readNoiseObject.mjds));
    if ~isempty(indexBefore)
        result(indexBefore, :) = repmat(readNoiseObject.constants(1).array(:), 1, length(indexBefore))';
    end
    if ~isempty(indexAfter)
        result(indexAfter, :) = repmat(readNoiseObject.constants(end).array(:), 1, length(indexAfter))';
    end
    if ~isempty(indexIn)
        for i_entries = 1:length(readNoiseObject.constants)
            read_noise(i_entries,:) = readNoiseObject.constants(i_entries).array(:);
        end
        result(indexIn, :) = interp1(readNoiseObject.mjds, read_noise, mjds(indexIn));
    end

    % Limit to specified mod/outs, if given:
    %
    if 4 == nargin
        % the convert_from_module_output routine validates the module/output
        % arguments. 
        %
        channel = convert_from_module_output(module, output);
        result = result(:, channel);
    end
    
    
    % check for negativity
    if any(result(:) < 0) 
        error('MATLAB:FC:readNoiseClass:get_read_noise', 'read_noise cannot be negative in readNoiseClass::get_read_noise');
    end
    
    % Sanity check on data:
    %
    fc_nonimage_data_check(result);
return
