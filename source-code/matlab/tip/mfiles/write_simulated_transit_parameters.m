function result = write_simulated_transit_parameters( tipTextFilename, inputStruct )
%
% function result = write_simulated_transit_parameters( tipTextFilename, inputStruct )
%
% This tip function write the TIP test file in csv format. The fieldnames in inputStruct become the column headings and the values in each
% field become the data in the corresponding text file column. 
%
% INPUTS:  tipTextFilename  [char string]   == filename of the TIP text file
%                    inputStruct [struct]   == structure containing data to write
% OUTPUTS:              result  [logical]   == boolean indicating if the write was successful or not
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


% hard coded defaults
defaultFormatString = '%12.4f'; 

% initialize output
result = false;

% retrieve numeric formats for text output
[ headers, nominalFormatString ] = retrieve_tip_column_headers_and_format();
nNominalColumns = length(headers);


% open the output txt file for writing
fid = fopen(tipTextFilename,'w+');

% extract fieldnames
fNames = fieldnames(inputStruct);
nNames = length(fNames);
nRows = zeros(nNames,1);

% build formatString
formatString = [];
for nCols = 1:nNames
    
    % select format for column entry
    if nNames == nNominalColumns
        stringToAdd = nominalFormatString{nCols};        
    else
        stringToAdd = defaultFormatString;
    end
    
    % add column separators
    if nCols ~= nNames
        % columns are csv
        stringToAdd = strcat(stringToAdd,',');
    else
        % add newline instead at end of row
        stringToAdd = strcat(stringToAdd,'\n');
    end
    
    formatString = strcat(formatString,stringToAdd);
end


% write header row and unpack data
for iName = 1:nNames
    
    % write comma separated header row
    fprintf(fid,'%s',fNames{iName});
    if iName < nNames
        fprintf(fid,',');
    else
        fprintf(fid,'\n');
    end
    
    % extract data into variable name same as fieldname
    eval([fNames{iName},' = inputStruct.',fNames{iName},';']);
    
    % measure data length
    eval(['nRows(iName) = length(',fNames{iName},');']);
end

% check that there is data for each row
if ~all_rows_equal(nRows)
    error('Input data is different lengths for different columns.');
end


% write each row of data to the text output file
for iRow = 1:nRows(1)
    
    % build up array of values for this row
    arrayToWrite = zeros(1,nNames);
    for iName = 1:nNames
        eval(['arrayToWrite(iName) = ',fNames{iName},'(iRow);']);
    end
    
    % write the row
    fprintf(fid,formatString, arrayToWrite);
end


% close the file
sd = fclose(fid);
if sd == 0
    result = true;
end

