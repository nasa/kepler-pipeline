function result = make_valid_tip_input_parameter_file( inputStruct, paramSetName, inputParameterFileName )
% function result = make_valid_tip_input_parameter_file( inputStruct, paramSetName, inputParameterFileName  )
%
% This TIP tool creates a valid tip input parameter file from user input. 
% 
% INPUT:            inputStruct == [struct] containing the following fields (7 minimum):
%                          keplerId: [nx1 double]
%                  impactParameters: [nx1 double]
%                        inputPhase: [nx1 double]
%                      offsetArcSec: [nx1 double]
%                       offsetPhase: [nx1 double]
%                       
%                       If paramSetName = 'sesDurationParamSet' must contain:
%                          inputSES: [nx1 double]
%                    inputDurations: [nx1 double]
%
%                       If paramSetName = 'periodRPlanetParamSet' must contain:
%                      planetRadius: [nx1 double]
%                 orbitalPeriodDays: [nx1 double]
%
%                                       Note all arrays must be column vectors of the same dimension.
%
%                 paramSetName  == [string]  TIP input parameter set name. {'sesDurationParamSet','periodRPlanetParamSet'}
%       inputParameterFileName  == [string]  TIP inputs parameter csv delimited text file to write (e.g. 'tip-inputs-sg-20-ident.txt')
% 
% OUTPUT:               result  == [logical] true on successful write to file. false otherwise. The column headings in the file
%                                            inputParameterFileName will match the field names of the inputStruct as defined above. 
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


% initialize output
result = false;

% string used for formatted output
formatString = '%10i,%10.6f,%10.6f,%10.6f,%10.6f,%10.6f,%10.3f\n';

% common field names required by tip
headings = {'keplerId', 'impactParameters', 'inputPhase', 'offsetArcSec', 'offsetPhase'};

% parameter set dependent field names
sesDurationHeading = {'inputSES', 'inputDurations'};
periodRadiusHeadings = {'planetRadius', 'orbitalPeriodDays'}; 

% select params based on paramSetName
switch paramSetName
    case 'sesDurationParamSet'
        headings = {headings{:}, sesDurationHeading{:}};                                                            %#ok<*CCAT>
    case 'periodRPlanetParamSet'
        headings = {headings{:}, periodRadiusHeadings{:}};
    otherwise
        error(['Generating parameter set ',generatingParamSetName,' is not recognized by TIP.']);
end



% remove any non-matching fileds in inputStruct and check validity of truncated input struct
fNames = fieldnames(inputStruct);
tf = ismember(fNames, headings);
if ~isvalid_tip_input_parameter_set( rmfield(inputStruct, fNames(~tf)), paramSetName )
    display('Invalid inputStruct. Parameter file not written.');
    display('USAGE:');
    help('make_valid_tip_input_parameter_file');
    disp(' ');
    display(inputStruct);
    return;
end


% open the output txt file for writing
fid = fopen(inputParameterFileName,'w+');
nHeadings = length(headings);

% write header row and unpack data
for iHeading = 1:nHeadings
    
    % write comma separated header row
    fprintf(fid,'%s',headings{iHeading});
    if iHeading < nHeadings
        fprintf(fid,',');
    else
        fprintf(fid,'\n');
    end

    % extract data into variable name same as fieldname
    eval([headings{iHeading},' = inputStruct.',(headings{iHeading}),';']);
end

% measure length of data
nRows = length(inputStruct.(headings{1}));

% write each row of data to the text output file
for iRow = 1:nRows
    
    % build up array of values for this row
    arrayToWrite = zeros(1,nHeadings);
    for iHeading = 1:nHeadings
        eval(['arrayToWrite(iHeading) = ',headings{iHeading},'(iRow);']);
    end
    
    % write the row
    fprintf(fid,formatString, arrayToWrite);
end

% close the file setting result true on success
sd = fclose(fid);
if sd == 0
    result = true;
end