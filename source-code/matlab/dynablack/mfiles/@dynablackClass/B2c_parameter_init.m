function [initInfo, inputs] = B2c_parameter_init(dynablackObject, dynablackResultsStruct)
%
% function [initInfo, inputs] = B2c_parameter_init(dynablackObject, dynablackResultsStruct)
%
% Initializes parameters used in dynablack monitoring subtask B2c.
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


% hard coded constants
serial_states = 1:7;
monitorList = {'trailingBlackResidual';...
                'frameFGSDeltaCoeff';...
                'parallelFGSDeltaCoeff';...
                'serialFGSDeltaCoeff';...
                'undershootCoeff'};
monitorLocalExpression = {'trailingArp';...
                            'frameFGSDelta';...
                            'parallelFGSDelta';...
                            'serialpix';...
                            'undershoot'};  
monitorDescription = {'trailing black residuals';...
                        'frame coefficient leading-trailing black delta';...
                        'parallel coefficient leading-trailing black delta';...
                        'serial coefficient leading-trailing black delta';...
                        'undershoot coefficient'};
monitorDomainLabel = {'';  ...
                        'FGS frame clock state';  ...
                        'FGS parallel clock state';  ...
                        'coeff # (const log exp)';  ...
                        'undershoot delay (pix)'};
monitorTypes = [1,2,2,2,2];                                  %  1-resid; 2-coeff
                    

% extract paramters from dynablackResultsStruct
channelList         = dynablackResultsStruct.A1ModelDump.Inputs.channel_list;
readsPerLongCadence = dynablackResultsStruct.A2ModelDump.Constants.readsPerLongCadence;
nChannels           = length(channelList);
nMonitors           = length(monitorList);


% initialize roi structure for output
zeroArray = zeros(nChannels,nMonitors);
cellArray = cell(nChannels,nMonitors);
roi = struct('Start',        zeroArray, ...      % columns of interest start in data input file
                'End',          zeroArray, ...    % columns of interest end in data input file
                'Count',        zeroArray, ...    % columns of interest count in data input file
                'Rows',         {cellArray}, ...  % pixel row numbers
                'Columns',      {cellArray}, ...  % pixel column numbers
                'Frame',        {cellArray},...   % pixel frame FGS states
                'Parallel',     {cellArray}, ...  % pixel parallel FGS states
                'Index',        {cellArray}, ...  % columns of interest index in data input file
                'Domain',       {cellArray}, ...  % domain value for each column of interest
                'DomainIndex',  {cellArray});     % index identifying columns of interest domain values from specific full domain value list
coeff_count = zeroArray;


% extract parameters from dynablack object
parallel_states     = dynablackObject.dynablackModuleParameters.parallelPixelSelect;
A1frame_states      = dynablackObject.dynablackModuleParameters.framePixelSelect;
A2frame_states      = dynablackObject.dynablackModuleParameters.a2FramePixelSelect;
A1column_states     = dynablackObject.dynablackModuleParameters.leadingColumnSelect;
A2column_states     = dynablackObject.dynablackModuleParameters.a2LeadingColumnSelect;
undershoot_states   = [0 -dynablackObject.dynablackModuleParameters.undershootSpan:-1:1];

monitorDomainValue  = {0; A1frame_states; parallel_states; 1:3; undershoot_states(2:21)};
monitorRelativeIndex = {0; 0; 0; 5:7; 2:21};

nCcdColumns = dynablackObject.fcConstants.CCD_COLUMNS;

% build inputs struct for output
inputs = struct('channel_list',         channelList,...
                'parallel_states',      parallel_states,...
                'A1frame_states',       A1frame_states,...
                'A2frame_states',       A2frame_states,...
                'A1column_states',      A1column_states,...
                'A2column_states',      A2column_states,...
                'undershoot_states',    undershoot_states,...
                'serial_states',        serial_states,...
                'monitor_names',        {monitorList},...
                'monitor_types',        monitorTypes,...                
                'monitor_locExpr',      {monitorLocalExpression}, ...
                'monitor_relIndex',     {monitorRelativeIndex},...
                'monitor_domainVal',    {monitorDomainValue},...
                'monitor_description',  {monitorDescription},...
                'monitor_domainlabel',  {monitorDomainLabel});

% get gfs clock states            
FGS_Clock_States1 = get_fgs_clock_states;
frame_pixel_image2 = FGS_Clock_States1.Frame;
parallel_pixel_image2 = FGS_Clock_States1.Parallel;



% extract A1 models from results
row_model            = dynablackResultsStruct.A1ModelDump.FCLC_Model.rows;
column_model         = dynablackResultsStruct.A1ModelDump.FCLC_Model.columns;
frame_pixel_model    = dynablackResultsStruct.A1ModelDump.FCLC_Model.frame_pixels;
parallel_pixel_model = dynablackResultsStruct.A1ModelDump.FCLC_Model.parallel_pixels;
frame_delta_model    = dynablackResultsStruct.A1ModelDump.FCLC_Model.frame_delta;
parallel_delta_model = dynablackResultsStruct.A1ModelDump.FCLC_Model.parallel_delta;

% extract indices from models and build into separate structure
serialpix = struct('offset', 0,...
                    'count',row_model.Subset_predictor_count,...
                    'index',row_model.Subset_predictor_index,...
                    'start',1,...
                    'end',row_model.Subset_predictor_count,...
                    'domain',inputs.serial_states);
                
leadcolumns = struct('offset',serialpix.end,...
                        'count',column_model.Subset_predictor_count,...
                        'index',column_model.Subset_predictor_index,...
                        'start',serialpix.end + 1,...
                        'end',serialpix.end + column_model.Subset_predictor_count,...
                        'domain',inputs.A1column_states);
                    
frameFGSpix = struct('offset',leadcolumns.end,...
                        'count',frame_pixel_model.Subset_predictor_count,...
                        'index',frame_pixel_model.Subset_predictor_index,...
                        'start',leadcolumns.end + 1,...
                        'end',leadcolumns.end + frame_pixel_model.Subset_predictor_count,...
                        'domain',inputs.A1frame_states);
                    
parallelFGSpix = struct('offset',frameFGSpix.end,...
                        'count',parallel_pixel_model.Subset_predictor_count,...
                        'index',frame_pixel_model.Subset_predictor_index,...
                        'start',frameFGSpix.end + 1,...
                        'end',frameFGSpix.end + parallel_pixel_model.Subset_predictor_count,...
                        'domain',inputs.parallel_states);
                    
frameFGSDelta = struct('offset',parallelFGSpix.end,...
                        'count',frame_delta_model.Subset_predictor_count,...
                        'index',frame_delta_model.Subset_predictor_index,...
                        'start',parallelFGSpix.end + 1,...
                        'end',parallelFGSpix.end + frame_delta_model.Subset_predictor_count,...
                        'domain',inputs.A1frame_states);
                    
parallelFGSDelta = struct('offset',frameFGSDelta.end,...
                            'count',parallel_delta_model.Subset_predictor_count,...
                            'index',parallel_delta_model.Subset_predictor_index,...
                            'start',frameFGSDelta.end + 1,...
                            'end',frameFGSDelta.end + parallel_delta_model.Subset_predictor_count,...
                            'domain',inputs.parallel_states);
                        
undershoot = struct('offset',parallelFGSDelta.end,...
                    'count',length(inputs.undershoot_states),...
                    'index',true(1,length(inputs.undershoot_states)),...
                    'start',parallelFGSDelta.end + 1,...
                    'end',parallelFGSDelta.end + length(inputs.undershoot_states),...
                    'domain',inputs.undershoot_states);

% set up model indices struct
modelIndices = struct('serialpix',serialpix,...
                        'frameFGSDelta',frameFGSDelta,...
                        'parallelFGSDelta',parallelFGSDelta,...
                        'undershoot',undershoot);
                            


% loop over monitors
for i = 1:nMonitors
    
    % switch on monitor type
    switch inputs.monitor_types(i)
        
        case 1        
        % -> RESIDUAL MONITOR CASE:
        % --> SELECT ROI FOR RESIDUALS OF INTEREST
        % possibilities are:
        %
        % * leadingArp
        % * trailingArp
        % * neartrailingArp
        % * trailingArpUs
        % * trailingCollat
            
            % grab the A1 fit region of interest (ROI)
            datumObject = dynablackResultsStruct.A1ModelDump.ROI.(inputs.monitor_locExpr{i});
            
            start1 = sum(row_model.Subset_datum_index(1:datumObject.First));
            idx = row_model.Subset_datum_index(datumObject.First:datumObject.Last);
            count1 = sum(idx);
            roi.Start(i) = start1;
            roi.Index{i} = idx;
            roi.End(i) = start1 + count1 - 1;
            roi.Count(i) = count1;
            roi.Rows{i} = datumObject.Rows(idx);
            roi.Columns{i} = datumObject.Columns(idx);
            roi.Frame{i} = datumObject.FGS_frame_clockstates(idx);
            roi.Parallel{i} = datumObject.FGS_parallel_clockstates(idx);
            
        case 2            
            % -> COEFFICIENT MONITOR CASE:
            % ---> SELECT COEFFICIENTS OF INTEREST
            % possibilities are:
            %
            % * serialpix
            % * leadcolumns
            % * frameFGSpix
            % * parallelFGSpix
            % * frameFGSDelta
            % * parallelFGSDelta
            % * undershoot
            
            % grab model indices
            domainObject = modelIndices.(inputs.monitor_locExpr{i});
            
            coeff_count(i) = undershoot.end;
            roi.Start(i) = domainObject.start;
            roi.End(i) = domainObject.end;
            
            if inputs.monitor_relIndex{i} == 0
                roi.Count(i) = domainObject.count;
                roi.DomainIndex{i} = domainObject.index;
                roi.Domain{i} = domainObject.domain(domainObject.index);
                roi.Index{i} = domainObject.start:domainObject.end;
            else
                index0 = intersect(find(domainObject.index),inputs.monitor_relIndex{i});
                roi.DomainIndex{i} = index0;
                roi.Domain{i} = domainObject.domain(index0);
                idx = zeros(length(domainObject.index),1);
                idx(domainObject.index) = 1:domainObject.count;
                index2 = nonzeros(idx(inputs.monitor_relIndex{i}));
                roi.Index{i} = domainObject.offset+index2;
                roi.Count(i) = length(index2);
            end
    end
end

% populate initInfo for output
initInfo.roi = roi;
initInfo.Constants = struct('Channel_count',        nChannels,...
                            'Monitor_count',        nMonitors,...
                            'FGSFrame_States',      frame_pixel_image2,...
                            'FGSParallel_States',   parallel_pixel_image2,...
                            'ffi_column_count',     nCcdColumns,...
                            'readPerCadence_count', readsPerLongCadence,...
                            'coeff_count',          coeff_count);



