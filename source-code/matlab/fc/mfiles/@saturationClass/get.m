function output = get(saturationObject, field)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function output = get(saturationObject, field)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Get various fields of the saturationObject.  Consider using
% get_saturation_info for a more convenient representation of the data
% containted in a saturationClass object.
%
% Inputs:
%     saturationObject: A saturationClass instance.
%     field: A string specifying which field to get. Can be "season",
%            "channel", "keplerIds", or "stars".
%
% Output:
%    The value of that saturationObject's field.  If the saturationObject
%    contains data for multiple channel/season pairs, the multiple values
%    are returned in a vector.
%
%    For the "stars" field, the data is slightly reshaped for convenience:
%    it is returned as a 1D vector of structs with the keplerId, season, and
%    channel added.  The resultant struct has fields:
%        keplerId
%        season
%        channel
%        saturatedColumn: a 1D vector of structs, one per saturated column, with fields:
%              columnAddress
%              rowStart
%              rowEnd
%
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

    switch field
        case 'season'
            output = [saturationObject.season];
        case 'channel'
            output = [saturationObject.channel];
        case 'keplerIds'
            stars = [saturationObject.stars];
			if isempty(stars)
				output = [];
			else
            	output = [stars.keplerId];
			end
        case 'stars'
            seasons = [saturationObject.season];
            channels = [saturationObject.channel];
            keplerIds = get(saturationObject, 'keplerIds');
            if length(seasons) ~= length(channels)
                error('FC:SaturationClass', 'Internal error: seasons and channels are not the same length');
            end

            output = [];
            ientry = 1;
            for ii = 1:length(channels)
                stars = saturationObject(ii).stars;
                for istar = 1:length(stars)
                    output(ientry).keplerId = keplerIds(ientry);
                    output(ientry).season  = seasons(ii);
                    output(ientry).channel = channels(ii);
                    output(ientry).saturatedColumns = stars(istar).saturatedColumns;
                    ientry = ientry + 1;
                end
            end

            if length(output) ~= length(keplerIds)
                error('Matlab:FC:saturationClass:get', 'KeplerIds and Stars output are not the same length! Internal error!');
            end
        otherwise
            error('Matlab:FC:saturationClass:get', '%s is not a valid field of saturationObject', field)
    end

return
