function [ blackDN blackDN_error ]  = DynOBlack( row, column, relativeLongCadence, rowColumnType, initInfo )
% 
% function [ blackDN blackDN_error ]  = DynOBlack( row, column, relativeLongCadence, rowColumnType, initInfo )
% Uses Dynamic 2D Black Model to Estimate Black Level.
% Requires prior initialization by DynOBlack_init.m
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

% ARGUMENTS
% 
% * Function returns:
% * --> |blackDN  -| black level estimate(s) in DN for the given set of arguments.
% * --> |blackDN_error -| black level uncertainty(ies) in DN.
%
% * Function arguments:
% * --> |row       -| pixel row or list or rows (first row = 1). 
% * --> |column    -| pixel column list of columns(first column = 1).
% * --> |relativeLongCadence        -| relativeLongCadence or list of LCs referenced to initialized relativeLongCadence list.
% * --> |rowColumnType    -| output context for given (row,column):
% *                         0- single point; 
% *                         1- vector value for each (row,column) pair.
% *                         2- rectangular region covering (row,column) ranges.
% * --> |initInfo-| initialized model structures, see DynOBlack_init.



% CASE 0 == single point not supported


% declare anonymous functions
flatten = @(this) this(:);

% extract parameters and model
constants      = initInfo.constants;
dynablackModel = initInfo.dynablackModel;
staticTwoDBlackImage = dynablackModel.staticTwoDBlackImage;
meanBlack = dynablackModel.Black_offset;

% extract flags
removeStatic2DBlack = constants.removeStatic2DBlack;

nLongCadences = length(relativeLongCadence);

ffiRows = 1:constants.ffi_row_count;
ffiColumns = 1:constants.ffi_column_count;
fgsFramePixelList = constants.frameFGS_modeledList;
fgsParallelPixelList = constants.parallelFGS_modeledList;


switch rowColumnType 

%     % CASE 0: ESTIMATES FOR SINGLE POINT
%     case 0   % point
%         frameFGS_clockOffsetID    = constants.FGSFrame_States(row, column);
%         parallelFGS_clockOffsetID = constants.FGSParallel_States(row, column);
% 
%         % BLACK LEVEL ESTIMATE
%          blackDN = dynablackModel.Black_offset + ...
%                    (dynablackModel.Vertical_component(row, relativeLongCadence) + ...
%                     dynablackModel.Horizontal_component(column, relativeLongCadence) + ...
%                     dynablackModel.FGSFrame_component(frameFGS_clockOffsetID, row, column, relativeLongCadence) + ...
%                     dynablackModel.FGSParallel_component(parallelFGS_clockOffsetID, row, column, relativeLongCadence) ) ./ constants.readPerCadence_count;
% 
%         % BLACK LEVEL UNCERTAINTY
%          blackDN_error =  sqrt( dynablackModel.Vertical_error(row, relativeLongCadence).^2  + ...
%                                 dynablackModel.Horizontal_error(column, relativeLongCadence).^2  + ...
%                                 dynablackModel.FGSFrame_error(frameFGS_clockOffsetID, row, column, relativeLongCadence).^2 + ...
%                                 dynablackModel.FGSParallel_error(parallelFGS_clockOffsetID, row, column, relativeLongCadence).^2 ) ./ constants.readPerCadence_count;

    % CASE 1: ESTIMATES FOR A LIST (VECTOR) OF ROW & COLUMN VALUES

    case 1   % list of points
                
%         subscript                 = (column-1) * constants.ffi_row_count + row;
        subscript                 = sub2ind([constants.ffi_row_count, constants.ffi_column_count], row, column); 
        frameFGS_clockOffsetID    = constants.FGSFrame_States(subscript);
        parallelFGS_clockOffsetID = constants.FGSParallel_States(subscript);
        
        vertical_DN    = DynOBlackComponent( row,                       ffiRows,          nLongCadences );
        horizontal_DN  = DynOBlackComponent( column,                    ffiColumns,       nLongCadences );
        frameFGS_DN    = DynOBlackComponent( frameFGS_clockOffsetID,    fgsFramePixelList,     nLongCadences );
        parallelFGS_DN = DynOBlackComponent( parallelFGS_clockOffsetID, fgsParallelPixelList,  nLongCadences );
                
        if vertical_DN.full_count ~= 0
            
            % BLACK LEVEL ESTIMATES AND UNCERTAINTY ESTIMATES
            vertical_DN = vertical_DN.assemble(dynablackModel.Vertical_components(vertical_DN.unique_list,relativeLongCadence),...
                                            dynablackModel.Vertical_errors(vertical_DN.unique_list,relativeLongCadence));
            horizontal_DN = horizontal_DN.assemble(dynablackModel.Horizontal_components(horizontal_DN.unique_list,relativeLongCadence),...
                                                dynablackModel.Horizontal_errors(horizontal_DN.unique_list,relativeLongCadence));
            frameFGS_DN = frameFGS_DN.assemble(dynablackModel.FGSFrame_components(frameFGS_DN.unique_list,relativeLongCadence ),...
                                            dynablackModel.FGSFrame_errors(frameFGS_DN.unique_list,relativeLongCadence));
            parallelFGS_DN = parallelFGS_DN.assemble(dynablackModel.FGSParallel_components(parallelFGS_DN.unique_list,relativeLongCadence),...
                                                  dynablackModel.FGSParallel_errors(parallelFGS_DN.unique_list,relativeLongCadence));
            
            % determine black offset component 
            if removeStatic2DBlack
                % extract static 2D black for these rows/columns and cadences
                blackOffset = repmat(flatten( staticTwoDBlackImage( sub2ind( size(staticTwoDBlackImage), row, column) ) ), 1, nLongCadences);
            else
                % use mean black over mod out
                blackOffset = meanBlack * ones( vertical_DN.full_count, nLongCadences );
            end
                                              
            blackDN = blackOffset + ...
                      ( vertical_DN.values  + ...
                        horizontal_DN.values  + ...
                        frameFGS_DN.values  + ...
                        parallelFGS_DN.values) ./ constants.readPerCadence_count;

            blackDN_error = sqrt( vertical_DN.errors.^2  + ...
                                  horizontal_DN.errors.^2  + ...
                                  frameFGS_DN.errors.^2  + ...
                                  parallelFGS_DN.errors.^2) ./ constants.readPerCadence_count;
        end


    % CASE 2: ESTIMATES FOR A RECTANGULAR REGION
    
    case 2     % rectangular region

        frameFGS_clockOffsetID    = flatten(constants.FGSFrame_States( row, column ));
        parallelFGS_clockOffsetID = flatten(constants.FGSParallel_States( row, column ));
                       
        
        vertical_DN    = DynOBlackComponent( row,                       ffiRows,         nLongCadences );
        horizontal_DN  = DynOBlackComponent( column,                    ffiColumns,      nLongCadences );
        frameFGS_DN    = DynOBlackComponent( frameFGS_clockOffsetID,    fgsFramePixelList,    nLongCadences );
        parallelFGS_DN = DynOBlackComponent( parallelFGS_clockOffsetID, fgsParallelPixelList, nLongCadences );

        % BLACK LEVEL AND UNCERTAINTY ESTIMATES
        vertical_DN    = vertical_DN.assemble(dynablackModel.Vertical_components(vertical_DN.unique_list,relativeLongCadence), ...
                                                dynablackModel.Vertical_errors(vertical_DN.unique_list,relativeLongCadence));
        horizontal_DN  = horizontal_DN.assemble(dynablackModel.Horizontal_components(horizontal_DN.unique_list,relativeLongCadence), ...
                                                dynablackModel.Horizontal_errors(horizontal_DN.unique_list,relativeLongCadence));
        frameFGS_DN    = frameFGS_DN.assemble(dynablackModel.FGSFrame_components(frameFGS_DN.unique_list,relativeLongCadence), ...
                                                dynablackModel.FGSFrame_errors(frameFGS_DN.unique_list,relativeLongCadence));
        parallelFGS_DN = parallelFGS_DN.assemble(dynablackModel.FGSParallel_components(parallelFGS_DN.unique_list,relativeLongCadence), ...
                                                    dynablackModel.FGSParallel_errors(parallelFGS_DN.unique_list,relativeLongCadence));

        % determine black offset component
        if removeStatic2DBlack
            % extract static 2D black for these rows/columns and cadences
            blackOffset = repmat(flatten( staticTwoDBlackImage( row, column ) ), 1,  nLongCadences); 
        else
            % use mean black over mod out
            blackOffset = meanBlack * ones( vertical_DN.full_count * horizontal_DN.full_count, nLongCadences );
        end                                        
                                                
                                                
        if frameFGS_DN.full_count == 0 || parallelFGS_DN.full_count == 0 

            blackDN0 = zeros( length(parallelFGS_clockOffsetID), nLongCadences );
            blackDN_error0 = zeros( length(parallelFGS_clockOffsetID), nLongCadences );

            for k=1:frameFGS_DN.unique_count
                kth_index = (frameFGS_clockOffsetID == frameFGS_DN.unique_list(k));
                blackDN0( kth_index, : ) = frameFGS_DN.unique_values(k,:);
                blackDN_error0( kth_index, : ) = frameFGS_DN.unique_errors(k,:).^2;
            end

            for k=1:parallelFGS_DN.unique_count
                kth_index = parallelFGS_clockOffsetID == parallelFGS_DN.unique_list(k);FGSFrame_components
                blackDN0( kth_index, : ) = parallelFGS_DN.unique_values(k,:);
                blackDN_error0( kth_index, : ) = frameFGS_DN.unique_errors(k,:).^2;
            end
                       
            blackDN = blackOffset +...
                        (cell2mat(cellfun(@(x1,x2)flatten(x1'*ones(1,length(x2)) + ones(length(x1),1)*x2)', ...
                            num2cell(vertical_DN.values',2), ...
                            num2cell(horizontal_DN.values',2), ...
                            'UniformOutput', false))' + blackDN0 ) ./ constants.readPerCadence_count;            
                        
            blackDN_error  = sqrt(cell2mat(cellfun(@(x1,x2)flatten(x1'.^2*ones(1,length(x2))+ones(length(x1),1)*x2.^2)', ...
                            num2cell(vertical_DN.errors',2), ...
                            num2cell(horizontal_DN.errors',2), ...
                            'UniformOutput', false))' + blackDN_error0 ) ./ constants.readPerCadence_count;
        else
                        
            blackDN = blackOffset + ...
                        (cell2mat(cellfun(@(x1,x2)flatten(x1'*ones(1,length(x2)) + ones(length(x1),1)*x2)', ...
                            num2cell(vertical_DN.values',2), ...
                            num2cell(horizontal_DN.values',2), ...
                            'UniformOutput', false))' + frameFGS_DN.values + parallelFGS_DN.values) ./ constants.readPerCadence_count;            

            blackDN_error = sqrt(cell2mat(cellfun(@(x1,x2)flatten(x1'.^2 * ones(1,length(x2)) + ones(length(x1),1) * x2.^2)', ...
                            num2cell(vertical_DN.errors',2), ...
                            num2cell(horizontal_DN.errors',2), ...
                            'UniformOutput', false))' + frameFGS_DN.errors.^2 + parallelFGS_DN.errors.^2) ./ constants.readPerCadence_count;
        end
end

