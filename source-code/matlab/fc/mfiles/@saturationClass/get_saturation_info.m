function saturationInfo = get_saturation_info(saturationObject)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function saturationInfo = get_saturation_info(saturationObject)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Return a vector of structs with the saturated pixel locations for each
% saturated star from the input object.
%
% Input:
%     saturationObject: A saturationClass instance.
%
% Output:
%     saturationInfo: a vector of structs, with one element per saturated
%                     star in the saturationObject.  The structs have
%                     fields:
%                         keplerId  -- the Kepler ID of the star
%                         season    -- the season this saturation information is for
%                         channel   -- the channel this star falls on this season
%                         column    -- the CCD column that is saturated
%                         rowStart  -- the CCD row the pixel saturation begins on.
%                         rowEnd    -- the CCD row the pixel saturation ends on.
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

    stars = get(saturationObject, 'stars');
    keplerIds = get(saturationObject, 'keplerIds');

    saturationInfo = repmat(...
                         struct('keplerId', [], 'season', [], 'channel', [], ...
                                'column', [], 'rowStart', [], 'rowEnd', []), ...
                         1, length(stars));

    for istar = 1:length(stars)
        star = stars(istar);
        saturationInfo(istar).keplerId = keplerIds(istar);
        saturationInfo(istar).channel = star.channel;
        saturationInfo(istar).season = star.season;

        for icolumn = 1:length(star.saturatedColumns)
            saturationInfo(istar).column(icolumn)   = star.saturatedColumns(icolumn).columnAddress;
            saturationInfo(istar).rowStart(icolumn) = star.saturatedColumns(icolumn).rowStart;
            saturationInfo(istar).rowEnd(icolumn)   = star.saturatedColumns(icolumn).rowEnd;
        end
    end
return
