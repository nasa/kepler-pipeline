%--------------------------------------------------------------------------
% compare_requantization_tables_from_two_runs(requantizationOutputStruct1, requantizationOutputStruct2)
%--------------------------------------------------------------------------
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

function compare_requantization_tables_from_two_runs(requantizationOutputStruct1, requantizationOutputStruct2)
%------------------------------------------------------------------------------
% requantization_table_entry_vs_index
%------------------------------------------------------------------------------
tableLengthLow1 = requantizationOutputStruct1.tableLengthLow;
tableLengthMain1 = requantizationOutputStruct1.tableLengthMain;
tableLengthHigh1 = requantizationOutputStruct1.tableLengthHigh;

% first plot the requantization table for the low guard band
yTableLow1 = 1:tableLengthLow1;
h1 = plot(requantizationOutputStruct1.requantizationTable(1:tableLengthLow1), yTableLow1,  'r.-');
hold on;

% next plot the requantization table for the nominal range
iStartIndex = tableLengthLow1 + 1;
iEndIndex = iStartIndex + tableLengthMain1-1;
yTableMain1 = iStartIndex:iEndIndex;
h2 = plot(requantizationOutputStruct1.requantizationTable(iStartIndex:iEndIndex), yTableMain1,  'b.-');

% next plot the requantization table for the upper guard band
iStartIndex = iEndIndex+1;
iEndIndex = iStartIndex + tableLengthHigh1-1;
yTableHigh1 = iStartIndex:iEndIndex;
h3 = plot(requantizationOutputStruct1.requantizationTable(iStartIndex:iEndIndex), yTableHigh1,  'k.-');



tableLengthLow2 = requantizationOutputStruct2.tableLengthLow;
tableLengthMain2 = requantizationOutputStruct2.tableLengthMain;
tableLengthHigh2 = requantizationOutputStruct2.tableLengthHigh;

% first plot the requantization table for the low guard band
yTableLow2 = 1:tableLengthLow2;
h4 = plot(requantizationOutputStruct2.requantizationTable(1:tableLengthLow2), yTableLow2,  'rx-');
hold on;

% next plot the requantization table for the nominal range
iStartIndex = tableLengthLow2 + 1;
iEndIndex = iStartIndex + tableLengthMain2-1;
yTableMain2 = iStartIndex:iEndIndex;
h5 = plot(requantizationOutputStruct2.requantizationTable(iStartIndex:iEndIndex), yTableMain2,  'bx-');

% next plot the requantization table for the upper guard band
iStartIndex = iEndIndex+1;
iEndIndex = iStartIndex + tableLengthHigh2-1;
yTableHigh2 = iStartIndex:iEndIndex;
h6 = plot(requantizationOutputStruct2.requantizationTable(iStartIndex:iEndIndex), yTableHigh2,  'kx-');



grid on;
set(gca,'FontSize',10);

ylabel('Quantization Table Index (nominally up to 2^1^6)');
xlabel('Quantization Table Value (nominally up to 2^2^3) ADU');
title( 'Quantization Table (Lower Guard Band + Main + Upper Guard Band)');

legend([h1 h2 h3 h4 h5 h6], {'Lower Guard Band1'; 'Nominal Range All Data Types1'; 'Upper Guard Band1';'Lower Guard Band2'; 'Nominal Range All Data Types2'; 'Upper Guard Band2'}, 'Location', 'NorthWest');

%     if((~isempty(requantizationLowStruct)) && tableLengthHigh > 0)
%         legend([h1 h2 h3 h4 h5 h6], {'Lower Guard Band1'; 'Nominal Range All Data Types1'; 'Upper Guard Band1';'Lower Guard Band2'; 'Nominal Range All Data Types2'; 'Upper Guard Band2'}, 'Location', 'NorthWest');
%     end;
%
%     if((isempty(requantizationLowStruct)) && tableLengthHigh > 0)
%         legend([h2 h3 h5 h6], {'Nominal Range All Data Types1'; 'Upper Guard Band1';'Nominal Range All Data Types2'; 'Upper Guard Band2'}, 'Location', 'NorthWest');
%     end;
%
%     if((isempty(requantizationLowStruct)) && tableLengthHigh == 0)
%         legend( [h3 h6] , {'Nominal Range All Data Types1';'Nominal Range All Data Types2' }, 'Location', 'NorthWest');
%     end;
%
%     if((~isempty(requantizationLowStruct)) && tableLengthHigh  == 0)
%         legend([h1 h2  h4 h5], {'Lower Guard Band1'; 'Nominal Range All Data Types1';'Lower Guard Band2'; 'Nominal Range All Data Types2';}, 'Location', 'NorthWest');
%     end;

grid on;
plot_to_file('requantization_table_entry_vs_index_comparison');

%------------------------------------------------------------------------------
% requantization_table_entry_vs_step_size
%------------------------------------------------------------------------------


% second plot requant table entry versus step size
close all;

% first plot the requantization table for the low guard band
h1 = plot(requantizationOutputStruct1.requantizationTable(1:tableLengthLow1 - 1), ...
    diff(requantizationOutputStruct1.requantizationTable(1:tableLengthLow1)),  'r.-');
hold on;

% next plot the requantization table for the nominal range
iStartIndex = tableLengthLow1+ 1;
iEndIndex = iStartIndex + tableLengthMain1-1;
h2 = plot(requantizationOutputStruct1.requantizationTable(iStartIndex:iEndIndex - 1), ...
    diff(requantizationOutputStruct1.requantizationTable(iStartIndex:iEndIndex)),  'b.-');

% next plot the requantization table for the upper guard band
iStartIndex = iEndIndex+1;
iEndIndex = iStartIndex + tableLengthHigh1-1;
h3 = plot(requantizationOutputStruct1.requantizationTable(iStartIndex:iEndIndex - 1), ...
    diff(requantizationOutputStruct1.requantizationTable(iStartIndex:iEndIndex)),  'k.-');



% first plot the requantization table for the low guard band
h4 = plot(requantizationOutputStruct2.requantizationTable(1:tableLengthLow2 - 1), ...
    diff(requantizationOutputStruct2.requantizationTable(1:tableLengthLow2)),  'rx-');
hold on;

% next plot the requantization table for the nominal range
iStartIndex = tableLengthLow2+ 1;
iEndIndex = iStartIndex + tableLengthMain2-1;
h5 = plot(requantizationOutputStruct2.requantizationTable(iStartIndex:iEndIndex - 1), ...
    diff(requantizationOutputStruct2.requantizationTable(iStartIndex:iEndIndex)),  'bx-');

% next plot the requantization table for the upper guard band
iStartIndex = iEndIndex+1;
iEndIndex = iStartIndex + tableLengthHigh2-1;
h6 = plot(requantizationOutputStruct2.requantizationTable(iStartIndex:iEndIndex - 1), ...
    diff(requantizationOutputStruct2.requantizationTable(iStartIndex:iEndIndex)),  'kx-');





grid on;
set(gca,'FontSize',10);

ylabel('Quantization Table Step Size');
xlabel('Quantization Table Value (nominally up to 2^2^3) ADU');
title( 'Quantization Table (Lower Guard Band + Main + Upper Guard Band)');

legend([h1 h2 h3 h4 h5 h6], {'Lower Guard Band1'; 'Nominal Range All Data Types1'; 'Upper Guard Band1';'Lower Guard Band2'; 'Nominal Range All Data Types2'; 'Upper Guard Band2'}, 'Location', 'NorthWest');

%     if((~isempty(requantizationLowStruct)) && tableLengthHigh > 0)
%         legend([h1 h2 h3 ], {'Lower Guard Band'; 'Nominal Range All Data Types'; 'Upper Guard Band'}, 'Location', 'NorthWest');
%     end;
%
%     if((isempty(requantizationLowStruct)) && tableLengthHigh > 0)
%         legend([h2 h3 ], {'Nominal Range All Data Types'; 'Upper Guard Band'}, 'Location', 'NorthWest');
%     end;
%
%     if((isempty(requantizationLowStruct)) && tableLengthHigh == 0)
%         legend( h3 , {'Nominal Range All Data Types'; }, 'Location', 'NorthWest');
%     end;
%
%     if((~isempty(requantizationLowStruct)) && tableLengthHigh  == 0)
%         legend([h1 h2  ], {'Lower Guard Band'; 'Nominal Range All Data Types';}, 'Location', 'NorthWest');
%     end;

grid on;
plot_to_file('requantization_table_entry_vs_step_size_comparison');
close all;
return



