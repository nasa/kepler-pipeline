function dgAncObj= dgAncillaryClass(inputMnemonicsCell, startMjd, endMjd, varargin)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function  dgAncObj= dgAncillaryClass(inputMnemonicsCell, startMjd, endMjd, varargin)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% Class constructor for dgAncillaryClass.  Uses retrieve_ancillary_data
% sandbox tool to obtain the ancillary data for Data Goodness.
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% INPUT:  
%           inputMnemonicsCell: [cell] specifying the mnemonics to retrieve
%                     startMjd: [double] start MJD time of data
%                       endMjd: [double] end MJD time of data
%                  varargin{1): the mat file name with ancillary data structures
%                               in string to use instead of the sandbox has
%                               to end with '.mat' extension
%                     
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% OUTPUT:
%
%    dgAncObj:  [1 x entries] of ancillary data with the following fields-
%     
%            .mnemonic   [string] the mnemonic that was queried 
%            .timestamps [vector of doubles] time range in MJD
%            .values     [vector of singles] if values are numeric
%            .stringValues [cell of strings] if values are string
%            .mean       [double] computed if values are numeric 
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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

if nargin == 4 % use mat file instead of sandbox
    matFile = varargin{1};
    if exist(matFile, 'file')==2
        eval(['load ' matFile])       
        entries = length(ancillaryData);
        for i = 1:entries
        inputMnemonicsCell{i,1} = ancillaryData(i).mnemonic;
        end
    else
        error('specified debug mat file not found')
    end
else
    ancillaryData = retrieve_ancillary_data(inputMnemonicsCell, startMjd, endMjd);
    entries = length(inputMnemonicsCell);
    % check that the length of retrieve_ancillary_data and entries match
    if length(ancillaryData) ~= entries
        error('size of retrieved ancillary does not match size of input')
    end
end



% preallocate
dgAncStruct = repmat(struct('mnemonic', [], 'timestamps', [],...
    'values', [],'stringValues',[], 'mean', [] ), 1, entries);

% build dgAncStruct
for n=1:entries
    
    % always fill mnemonic field with the queried input mnemonic
    dgAncStruct(n).mnemonic = inputMnemonicsCell{n,1}; 
    
    % check for existence of mnemonic in datastore by looking at timestamps
  
            dgAncStruct(n).timestamps = ancillaryData(n).timestamps;
            dgAncStruct(n).values = ancillaryData(n).values;
            dgAncStruct(n).stringValues = ancillaryData(n).stringValues;
            
            % calculate the mean value for given time range if it is numeric
            if ~isempty(ancillaryData(n).values)
                dgAncStruct(n).mean = mean(ancillaryData(n).values);
            end
         
end

dgAncObj = class(dgAncStruct, 'dgAncillaryClass');

return

    

