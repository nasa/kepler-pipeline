function os = update_simulated_transit_parameter_struct_fieldnames(is, newNames, oldNames)
%
% function os = update_simulated_transit_parameter_struct_fieldnames(is, newNames, oldNames)
%
% This is a TIP helper function used to replace fieldnames with new ones in the same position. It was written to satisfy KSOC-3105 and is
% applied to the simulatedTransitsStruct as read from a TIP .txt file but it could be used for any struct.
%
% INPUTS:
%   is        == input struct
%   newNames  == nNames x 1 cell array of replacement field names
%   oldNames  == nNames x 1 cell array of original field names
% OUTPUTS:
%   os        == input struct with old field names replaced by old ones
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


% check length of name lists
if length(newNames) ~= length(oldNames)
    error('Length of newNames and oldNames lists must be equal.');
end
% check data type of name lists
if ~iscell(newNames) || ~iscell(oldNames)
    error('newNames and oldNames arguments must be cell arrays.')
end
% check data type of contents of name lists
for iName = 1:length(newNames)
    if ~ischar(newNames{iName}) || ~ischar(newNames{iName})
        error('newNames and oldNames must be lists of type char.');
    end
end


% read incoming fieldnames
fNames = fieldnames(is);
tf = ismember(oldNames, fNames);

% if any incoming names match any names on the oldNames list replace the matching oldNames with corresponding newNames
% otherwise just coly the incoming struct to the outgoing struct
if any(tf)
    for iName = 1:length(fNames)
        % check the field name
        [tf, idx] = ismember(fNames{iName},oldNames);
        if tf
            % copy contents under old name to corresponding new name
            os.(newNames{idx}) = is.(fNames{iName});
        else
            % copy contents under same name
            os.(fNames{iName}) = is.(fNames{iName});
        end    
    end
else
    os = is;
end
