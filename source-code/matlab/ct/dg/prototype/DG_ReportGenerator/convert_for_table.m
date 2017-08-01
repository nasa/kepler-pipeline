function [starTable, leadingBlackTable trailingBlackTable...
   maskedSmearTable, virtualSmearTable] = convert_for_table(statStruct)

% function to convert statistics structure of ea/ pixel region into cells
% so that this information can be presented neatly in report generator
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


temp = struct2cell(statStruct.starRegion);
activeRegion = temp(1:end-1); % omit the pixel level, save for another table
pixelCounts = struct2cell(statStruct.starRegion.pixel);
starTable = local_new_cell(activeRegion, pixelCounts);

temp = struct2cell(statStruct.leadingBlackRegion);
activeRegion = temp(1:end-1); % omit the pixel level, save for another table
pixelCounts = struct2cell(statStruct.leadingBlackRegion.pixel);
leadingBlackTable = local_new_cell(activeRegion, pixelCounts);

temp = struct2cell(statStruct.trailingBlackRegion);
activeRegion = temp(1:end-1); % omit the pixel level, save for another table
pixelCounts = struct2cell(statStruct.trailingBlackRegion.pixel);
trailingBlackTable = local_new_cell(activeRegion, pixelCounts);

temp = struct2cell(statStruct.maskedSmearRegion);
activeRegion = temp(1:end-1); % omit the pixel level, save for another table
pixelCounts = struct2cell(statStruct.maskedSmearRegion.pixel);
maskedSmearTable = local_new_cell(activeRegion, pixelCounts);


temp = struct2cell(statStruct.virtualSmearRegion);
activeRegion = temp(1:end-1); % omit the pixel level, save for another table
pixelCounts = struct2cell(statStruct.virtualSmearRegion.pixel);
virtualSmearTable = local_new_cell(activeRegion, pixelCounts);


function newCell = local_new_cell(activeRegion, pixelCounts)
% subfunction to create tables
newCell = {'min', activeRegion{1};...
    'max', activeRegion{2};...
    'mean', activeRegion{3};...
    'median', activeRegion{4};...
    'mode', activeRegion{5};...
    'std', activeRegion{6};...
    'expected number of pixels', pixelCounts{1}; ...
    'number of missing pixels',pixelCounts{2};...
    'number of pixels in high guard', pixelCounts{3};...
    'number of pixels in low guard', pixelCounts{4};
    'percent completeness of pixel region', pixelCounts{5}'};


    