function RowxRow_AboveThreshold = flag_scene_dependent( dynablackObject, Inputs )
%
% function RowxRow_AboveThreshold = flag_scene_dependent( dynablackObject, Inputs )
%
% FlagSceneDependent
% Locates bright pixels in FFIs which may introduce scene dependent artifacts.
% The parameter |Inputs.threshold| specifies the brightness threshold in DN/read.
% ARGUMENTS
% 
% * Function returns: 
% * |RowxRow_AboveThreshold| - structure array containing results.
% * Function arguments:
% * |Inputs           -| structure containing input parameters. 
%
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

% hard coded local filename
dynablackStateFile = 'dynablack_state_file.mat';


% get parameters from object
CMObj       = configMapClass(dynablackObject.spacecraftConfigMap);
columnStart = median(get_masked_smear_start_column(CMObj));
columnEnd   = median(get_masked_smear_end_column(CMObj));
rowStart    = median(get_masked_smear_start_row(CMObj));
rowEnd      = median(get_virtual_smear_end_row(CMObj));
readsPerLc  = median(get_number_of_exposures_per_long_cadence_period(CMObj));

nCcdRows    = dynablackObject.fcConstants.CCD_ROWS;


% SHOULD EXTRACT ALL THE HARD CODED VALUES FROM THE DATA OBJECT (e.g. 5 and 58 below)
Constants = struct( 'ffi_count',        length(Inputs.ffi_list),...
                    'sci_pix_columns',  columnStart:columnEnd,...                                   % 13:1112
                    'column_count',     length(columnStart:columnEnd),...
                    'rows',             rowStart:rowEnd,...                                         % 7:1058
                    'row_count',        length(rowStart:rowEnd),...
                    'reads_perCadence', readsPerLc,...                                              % 270
                    'ffi_rowCount',     nCcdRows,...                                                % 1070
                    'smear_factor',     5./(58*nCcdRows + 5*length(rowStart:rowEnd)));              % 5./(58*1070 + 5*1052));

% analyze FFIs

warning('off','stats:statrobustfit:IterationLimit');    

% initialize channel unique parameters    
channel_num = Inputs.channel_list;
ccdImage_set = zeros( Constants.ffi_count, length(Constants.rows), length(Constants.sci_pix_columns) );
RowxRow_AboveThreshold = struct('channel',      channel_num,...
                                  'columns',    {num2cell(zeros(Constants.ffi_rowCount,1))},...
                                  'values',     {num2cell(zeros(Constants.ffi_rowCount,1))},...
                                  'count',      zeros(Constants.ffi_rowCount,1),...
                                  'last_column',zeros(Constants.ffi_rowCount,1),...
                                  'last_value', zeros(Constants.ffi_rowCount,1),...
                                  'threshold',  Inputs.threshold);
       
% extract ffi from object, correct for smear and save image
for ffi_ID = 1:Constants.ffi_count
    ccdImage = [dynablackObject.rawFfis(ffi_ID).image.array]';
    smear = ones(Constants.row_count,1) * sum(ccdImage(Constants.rows, Constants.sci_pix_columns),1)*Constants.smear_factor;
    ccdImage_set(ffi_ID,:,:) = ccdImage( Constants.rows, Constants.sci_pix_columns ) - smear;
end
    
% -- PIXEL x PIXEL MINIMUM OF FFIS
% This algorithm takes the minimum of smear-corrected FFIs to remove cosmic rays. 
% It then creates 2 additional images displaced �1 row from the first and takes the maximum of the three.
% This effectively blurs the image vertically to create a 1 pixel up/down buffer to allow for brightness changes.
% Finally, it subtracts the overall median and zeros negative values.

ccdImage_Min        = zeros(3,Constants.row_count,Constants.column_count);
ccdImage_Min0       = squeeze(min(ccdImage_set));
ccdImage_Min(1,:,:) = ccdImage_Min0;
ccdImage_Min(2,:,:) = [ccdImage_Min0(2:end,:);ccdImage_Min0(end,:)];
ccdImage_Min(3,:,:) = [ccdImage_Min0(1,:);ccdImage_Min0(1:end-1,:)];
ccdImage_Vblur      = squeeze(max(ccdImage_Min));
median_ffiMin       = median(ccdImage_Vblur(:));
flagable_image      = max(zeros(size(ccdImage_Vblur)),ccdImage_Vblur-median_ffiMin)/Constants.reads_perCadence;
    
% -- CALCULATE OUTPUT FLAGS ROW X ROW
% On a row-by-row basis, this algorithm finds all the columns above the value specified by |Inputs.threshold| .
% For each row, it determines and stores:
% 
% * the list of columns above threshold 
% * the list of values in those columns
% * a count of the number of columns above threshold
% * the location of the last column above threshold (for convenience in applying to A1b fitting routines)
% * the value in the last column above threshold (for convenience in applying to A1b fitting routines)
%
% the last two items determine how likely it is that trailing black pixels will be affected by scene dependent artifacts 
%
    
for row_ID = 1:Constants.row_count
    row = Constants.rows(row_ID);
    column_list = find(flagable_image(row_ID,:)>Inputs.threshold);
    count1=length(column_list);
    if count1 > 0
        RowxRow_AboveThreshold.columns{row}     = column_list+Constants.sci_pix_columns(1)-1;
        RowxRow_AboveThreshold.values{row}      = flagable_image(row_ID,column_list);
        RowxRow_AboveThreshold.count(row)       = count1;
        RowxRow_AboveThreshold.last_column(row) = max(RowxRow_AboveThreshold.columns{row});
        RowxRow_AboveThreshold.last_value(row)  = flagable_image(row_ID,max(column_list));
    end
end

% append scene dependent flags to state file
save(dynablackStateFile,'Inputs','RowxRow_AboveThreshold');


