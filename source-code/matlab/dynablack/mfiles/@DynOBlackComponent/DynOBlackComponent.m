%% DynOBlackComponent
% Pre-MATLAB V7.6 constructor for a DynOBlackComponent class object. 
% DynOBlackComponent:  Defines a data structure for model components for use
%                   in estimation algorithms. These objects and methods are intended to
%                   increase the efficiency of the 2D black calculation by extracting
%                   only the unique values to calculate. See DynOBlack comments for more.
%
%   Revision History:
%
%       Version 0 - 2/9/10      released for review and comment
%       Version 1 - 4/19/10     Modified classes for pre-MATLAB V7.6
%
% 
% <html>
% <style type="text/css"> pre.codeinput {background: #FFFF66; padding: 30px;} </style>
% </html>
%
%%
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
function dbc = DynOBlackComponent(List, Unique_Range, LC_count )
%% ARGUMENTS
% 
% * Function returns: dbc - an object of class DynOBlackComponent.
% * Function arguments:
% * |List            -| A List containing values for a specific attribute values for each requested pixel e.g. rows, columns, clock states
% * |Unique_Range    -| The modeled range of values for the specific property
% * |LC_count        -| number of LC requested
% *
% *    properties
% *        lc_count: number of for which black-level values are generated
% *        full_count: total # of black-level values to be generated OR zero if total # would be greater than max_full_count
% *        full_list: full list of specific attribute values OR only unique attribute values if total # would be greater than max_full_count
% *        values: initialized array for black-level estimates OR empty if total # would be greater than max_full_count
% *        errors: full list of black-level errors OR empty if total # would be greater than max_full_count
% *        unique_list: unique values in 'List' that are also in 'Unique_Range' OR full 'List' if total # is less than max_full_count 
%                       and calculating unique values only reduces the number of values calculated by >50% 
% *        unique_count: number of values in unique_list OR zero if total # is less than max_full_count 
%                        and calculating unique values only reduces the number of values calculated by >50%
% *        unique_values: initialized array for unique black-level estimates OR empty if total # is less than max_full_count 
%                         and calculating unique values only reduces the number of values calculated by >50%
% *        unique_errors: initialized array for unique black-level errors OR empty if total # is less than max_full_count 
%                         and calculating unique values only reduces the number of values calculated by >50%
%     
% 
%%
if nargin > 0

%     efficiency_threshold = 0.50; %threshold for calculating only unique values vs. all requested values
    efficiency_threshold = 1.1;     % effectively disables efficiency threshold override 2 - always set dbc.unique_list = unique_list
    
%     max_full_count = 121000000; % 1100*24 * 4583.33 (~ 1 quarters masked & virtual smear)
    max_full_count = realmax;       % effectively disables efficiency threshold override 1 - always set dbc.full_list = List

    dbc.lc_count  = LC_count;
    count         = length(List);
    unique_list   = intersect( List, Unique_Range );
    unique_count  = length(unique_list);

    if count*dbc.lc_count < max_full_count
        dbc.full_count    = count;
        dbc.full_list     = List;
        dbc.values        = zeros( dbc.full_count, dbc.lc_count );
        dbc.errors        = zeros( dbc.full_count, dbc.lc_count );
        if unique_count < (efficiency_threshold * dbc.full_count)
            dbc.unique_list   = unique_list;
            dbc.unique_count  = length(dbc.unique_list);
            dbc.unique_values = zeros(dbc.unique_count, dbc.lc_count);
            dbc.unique_errors = zeros(dbc.unique_count, dbc.lc_count);
        else
            dbc.unique_list   = dbc.full_list;
            dbc.unique_count  = 0;
            dbc.unique_values = [];
            dbc.unique_errors = [];
        end
    else
        dbc.full_count    = 0;
        dbc.full_list     = unique_list;
        dbc.values        = [];
        dbc.errors        = [];
        dbc.unique_list   = unique_list;
        dbc.unique_count  = length(dbc.unique_list);
        dbc.unique_values = zeros(dbc.unique_count, dbc.lc_count);
        dbc.unique_errors = zeros(dbc.unique_count, dbc.lc_count);
    end

end

dbc = class(dbc, 'DynOBlackComponent');  

return

end
