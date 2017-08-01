function fieldsAndBounds = get_fields_and_bounds(paramStruct) 
%
% Copyright 2017 United States Government as represented by the
% Administrator of the National Aeronautics and Space Administration.
% All Rights Reserved.
% 
% NASA acknowledges the SETI Institute's primary role in authoring and
% producing the Kepler Data Processing Pipeline under Cooperative
% Agreement Nos. NNA04CC63A, NNX07AD96A, NNX07AD98A, NNX11AI13A,
% NNX11AI14A, NNX13AD01A & NNX13AD16A.
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
    HIGH_WINDOW_WIDTH_LIMIT = 1001;  % minimum valid window width.
    LOW_WINDOW_WIDTH_LIMIT = 11;     % minimum valid window width.
    HIGH_POLY_ORDER_LIMIT = 10;      % Maximum valid polynomial order for both long and short models
    LOW_LONG_POLY_ORDER = 2;         % Minimum valid polynomial order for long model
    LOW_SHORT_POLY_ORDER_LIMIT = 1;  % Minimum valid polynomial order for short model

    if nargin < 1
        windowWidth = HIGH_WINDOW_WIDTH_LIMIT;
    else
        windowWidth = paramStruct.windowWidth;
    end

    fieldsAndBounds = cell(8,4);
    fieldsAndBounds(1,:)  = { 'mode';                 []; []; '[1]'};
    fieldsAndBounds(2,:)  = { 'windowWidth';          []; []; ['[' num2str(LOW_WINDOW_WIDTH_LIMIT) ':2:' num2str(HIGH_WINDOW_WIDTH_LIMIT) ']']}; 
    fieldsAndBounds(3,:)  = { 'minWindowWidth';       []; []; ['[' '9' ':2:' num2str(min(windowWidth, HIGH_WINDOW_WIDTH_LIMIT)) ']']};
    fieldsAndBounds(4,:)  = { 'sgPolyOrder';          []; []; ['[' '3:' num2str(HIGH_POLY_ORDER_LIMIT) ']']};
    fieldsAndBounds(5,:)  = { 'sgStepPolyOrder';      []; []; ['[' num2str(LOW_LONG_POLY_ORDER) ':' num2str(HIGH_POLY_ORDER_LIMIT) ']']}; 
    fieldsAndBounds(6,:)  = { 'shortWindowWidth';     []; []; ['[' num2str(LOW_WINDOW_WIDTH_LIMIT) ':2:' num2str(min(windowWidth, HIGH_WINDOW_WIDTH_LIMIT)) ']']};
    fieldsAndBounds(7,:)  = { 'shortSgPolyOrder';     []; []; ['[' num2str(LOW_SHORT_POLY_ORDER_LIMIT) ':' num2str(HIGH_POLY_ORDER_LIMIT) ']']}; 
    fieldsAndBounds(8,:)  = { 'shortSgStepPolyOrder'; []; []; ['[' num2str(LOW_SHORT_POLY_ORDER_LIMIT) ':' num2str(HIGH_POLY_ORDER_LIMIT) ']']};
end

