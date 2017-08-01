function [ skygroup ] = return_skygroup_for_season( module, output, season, varargin )
%
% [ skygroup ] = return_skygroup_for_season( module, output, season, varargin  )
%
% This tip helper function returns the skygroupId corresponding to the module/output for a given season. The inputs module and output may be
% lists, season must be a single value. The optional fourth argument is fcConstants. If this is not supplied it will be read using the
% database call convert_fc_constants_java_2_struct. If calling return_skygroup_for_season from compliled code the fcConstants argument
% should be specified.
%
% INPUTS:       module      == list of ccd modules, 1 x nChannels; { 2:4, 6:20, 22:24 }
%               output      == list of ccd outputs; 1 x nChannels; { 1:4 }
%               season      == observing season; scalar; { 0:3 }
%               varargin    == fcConstants
% OUTPUTS:      skygroup    == list of skygroupIds; { 1:84 }
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


% hard code valid observing season
SEASON_LIST = 0:3;

% initialize default output
skygroup = [];

% get variable arguments
if nargin > 3
    % copy fc constants from inputs
    fc = varargin{1};
else
    % load fc constants from database call
    fc = convert_fc_constants_java_2_struct;
end

% check the rest of the inputs
inputError = false;
% check dimension
if ~isvector(module) || ~isvector(output) || ~isscalar(season)
    disp('Input argument "module" and "output" must be scalar or vector. Input argument "season" must be scalar.');
    inputError = true;
end
% check size
if length(module) ~= length(output)
    disp('Input argument "module" and "output" must be equal length.');
    inputError = true;
end
% check values
if ~all(ismember(module, fc.modulesList))
     disp(['Invalid "module" value(s). Must be element of {',num2str(fc.modulesList'),'}.']);
    inputError = true;
end
if ~all(ismember(output, fc.outputsList))
     disp(['Invalid "output" value(s). Must be element of {',num2str(fc.outputsList'),'}.']);
    inputError = true;
end
if ~(ismember(season, SEASON_LIST))
     disp(['Invalid "season" value. Must be element of {',num2str(SEASON_LIST),'}.']);
    inputError = true;
end
% throw usage message on input error and exit
if inputError
    disp('Usage:');
    help('return_skygroup_for_season');
    return;
end
    

% ---- inputs are valid, proceed

% convert to row vectors
module = rowvec(module);
output = rowvec(output);

% convert module/output to channel
channel = convert_from_module_output(module, output);

% channel number equals skygroup in season 2
EQUAL_SEASON = 2;

% set up skygroup 10x10 grid - grid elements off the Kepler focal plane will contain channel = skygroup = 0
skygroupGrid = zeros(10,10);
for i = 1:100
    r = floor((i-1)/10) + 1;
    c = mod(i-1,10) + 1;
    if ~any(fc.MOD_OUT_IN_GRID_ORDER(i).array < 0 )
        skygroupGrid(r,c) = convert_from_module_output(fc.MOD_OUT_IN_GRID_ORDER(i).array(1),fc.MOD_OUT_IN_GRID_ORDER(i).array(2));
    end
end

% rotate skygroupGrid cw 90-degrees per season from season 2 to give channel location for input season
channelGrid = rot90(skygroupGrid, -(season - EQUAL_SEASON));

% convert to linear indexing
skygroupGrid = skygroupGrid(:);
channelGrid = channelGrid(:);

% find index into channel grid for input channels - these indices map back to the skygroup grid to give skygroup for season
[tf, idx] = ismember( channel, channelGrid );

% extract skygroup for input channels from skygroupGrid
skygroup = skygroupGrid(idx(tf));