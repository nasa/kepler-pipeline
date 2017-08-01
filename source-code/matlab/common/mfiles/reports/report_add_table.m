%% report_add_table
%
% function report_add_table(reportDir, filename, data, startRow)
%
% Adds table data for use by a LaTeX report. If an extension
% is missing, .tex is appended. If data is missing, the output file is not
% created. That way, an empty table can be tested in the LaTeX code with
% \IfFileExists.
%
%% INPUTS
%  reportDir [string]: the directory that contains the report
%   filename [string]: the name of the file that will contain the table
%                      data
%     data [nx2 cell]: an n by 2 cell matrix
%      startRow [int]: the starting row (optional)
%
%% OUTPUTS
%  None
%%
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
function report_add_table(reportDir, filename, data, startRow)

if (~exist('startRow', 'var'))
    startRow = 1;
end

if (size(data, 1) == 0)
    return
end

fid = report_open_latex_file(reportDir, filename);

for i = startRow : size(data, 1)
    row = data(i,:);
    line = '';
    for j = 1 : length(row);
        value = row(j);

        % Ensure that value is a string, even if it's a cell or a
        % number.
        if (iscell(value))
            value = value{1};
        end
        if (isnumeric(value))
            value = num2str(value);
        end
        value = report_latex_quote(value, false);
        if (~isempty(line))
            line = [line ' & ']; %#ok<AGROW>
        end
        line = [line char(value)]; %#ok<AGROW>
    end
    fprintf(fid, '%s\\\\\n', line);
end

xclose(fid, filename);
end
