
function raDec2PixObject = raDec2PixClass(raDec2PixData, base_description)
% raDec2PixObject = raDec2PixClass(raDec2PixData, base_description)
%
% This class is just a container; data check is done inside the
% pointing, geometry, and rolltime constructors
%
% If the base_description argument is 'zero-based', the center of the science
% pixel closest to the readout node is (20.0, 12.0), and the center of the
% first pixel in accumulation memory is (0.0, 0.0).
%
% If the base_description argument is 'one-based', the center of the science
% pixel closest to the readout node is (21.0, 13.0), and the center of the
% first pixel in accumulation memory is (1.0, 1.0).
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


    
    ZERO_BASED_STRING = 'zero-based';
    ONE_BASED_STRING = 'one-based';
    
    if nargin < 2
        error('Matlab:FC:raDec2PixClass', 'raDec2PixClass constructor requires two arguments. See helptext.')
    end
    
    if strcmp(ZERO_BASED_STRING, base_description)
        raDec2PixData.base = 0;
    elseif strcmp(ONE_BASED_STRING, base_description)
        raDec2PixData.base = 1;
    else
        error('Matlab:FC:raDec2PixClass', 'String argument "base_descripton" must be "zero-based" or "one-based"')
    end    

    % Sort model data to prevent the warning "Field names and parent
    % classes for class raDec2PixClass cannot be changed without clear classes."
    %
    raDec2PixData = orderfields(raDec2PixData);


    % Run data checks on contained object data:
    %
    po = pointingClass(raDec2PixData.pointingModel);
    ro = rollTimeClass(raDec2PixData.rollTimeModel);
    go = geometryClass(raDec2PixData.geometryModel);

    raDec2PixObject = class(raDec2PixData, 'raDec2PixClass');
return

