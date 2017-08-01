function fc_image_data_check(data, uncert)
% function fc_image_data_check(data, uncert)
%
% A function to check the data integrity of the image-based FC models (flat
% field and 2D black) before construction occurs.  The inputs should be the
% data and uncertainty matrices from the constructors.
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

    % Make the data a linear vector to simplify checks.
    %
    data = data(:);
    uncert = uncert(:);
    
    % Check for negatives:
    %
    if any(data < 0) || any(uncert < 0)
        error('negative data!');
    end

    % Upper-bounds check (valid for both black and flat, although extremely
    % convervative for flat):
    %
    max_data_val = 16383;
    if any(data) > max_data_val
        error(sprintf('data is higher than max allowed value: %d', max_data_val));
    end
    if any(uncert) > max_data_val
        error(sprintf('uncertainties is higher than max allowed value: %d', max_data_val));
    end
    
    % Check for appropriate ratio between data and uncertainty
    %
    ratio = uncert ./ data;
    if all(ratio >= 1)
        error('all uncertainties are greater than data-- data/uncert swap likely!');
    end

%    % Check for nan
%    %
%    if any(isnan(data)
%        error('NaNs in data!');
%    end
%    if any(isnan(uncert)) 
%        error('NaNs in uncertainty!');
%    end

    % Check for too-large:
    %
    if any(data > 16383) 
        error('data too large!');
    end
    if any(uncert > 16383)
        error('uncertainty too large!');
    end

    % Check for inf
    %
    if any(isinf(data)) 
        error('INFs in data!');
    end
    if any(isinf(uncert))
        error('INFs in uncertainty!');
    end
return


