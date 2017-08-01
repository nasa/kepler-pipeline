function tcatInputDataStruct = get_region_of_interest_from_user(tcatInputDataStruct)
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

fprintf('\n');

nCcdRows = tcatInputDataStruct.fcConstantsStruct.CCD_ROWS;
nCcdColumns = tcatInputDataStruct.fcConstantsStruct.CCD_COLUMNS;



%--------------------------------------------------------------------------
% do you want to specify a region of interest?
%--------------------------------------------------------------------------

fprintf('--------------------------------------------------------------------------\n');
fprintf('Specify a region of interest.....\n');

while true
    wantToSpecifyRoi = input('TCAT: Do you want specify a region of interest (ROI)? [Y/N]: ', 's');
    wantToSpecifyRoi = lower(wantToSpecifyRoi(1));
    if(~(strcmp(wantToSpecifyRoi , 'y') || strcmp(wantToSpecifyRoi , 'n') ))
        fprintf('\n Choose either ''Y/y'' or ''N/n''');
    else
        break;
    end
end

tcatInputDataStruct.wantToSpecifyRoi = wantToSpecifyRoi;

if(strcmp(wantToSpecifyRoi , 'n'))
    return
end


%--------------------------------------------------------------------------
% is the ROI Inclusion or Exclusion region?
%--------------------------------------------------------------------------

fprintf('--------------------------------------------------------------------------\n');
fprintf('Specify an Inclusion or Exclusion region of interest?\n');

while true
    typeOfRoi = input('TCAT: Is the ROI an Inclusion or an Exclusion region? [I/E]: ', 's');
    typeOfRoi = lower(typeOfRoi(1));
    if(~(strcmp(typeOfRoi , 'i') || strcmp(typeOfRoi , 'e') ))
        fprintf('\n Choose either ''I/i'' or ''E/e''');
    else
        break;
    end
end

tcatInputDataStruct.typeOfRoi = typeOfRoi;

if(strcmp(typeOfRoi , 'i'))
    fprintf('--------------------------------------------------------------------------\n');
    fprintf('Specify the rows/columns of INCLUSION ROI below:\n');
else
    fprintf('--------------------------------------------------------------------------\n');
    fprintf('Specify the rows/columns of EXCLUSION ROI below:\n');
end



%--------------------------------------------------------------------------
% specify rows for the ROI
%--------------------------------------------------------------------------
while true
    while true
        startRow = input(['TCAT: start row? [1..' num2str(nCcdRows) ']: '], 's');
        startRow = fix(str2double(startRow));
        if(~ismember(startRow, 1:nCcdRows))
            fprintf(['start row has to be >= 1 and <= ' num2str(nCcdRows)  ' \n']);
        else
            break;
        end
    end
    while true
        endRow = input(['TCAT: end row? [1..' num2str( nCcdRows) ']: '], 's');
        endRow = fix(str2double(endRow));
        if(~ismember(endRow, 1:nCcdRows))
            fprintf(['end row has to be >= 1 and <= ' num2str(nCcdRows) ' \n']);
        else
            if(endRow < startRow)
                fprintf('end row has to be >= start row \n');
            end
            break;
        end
    end
    if(endRow >= startRow)
        break;
    end
end
fprintf('\n');
%--------------------------------------------------------------------------
% specify columns for the ROI
%--------------------------------------------------------------------------
while true
    while true
        startColumn = input(['TCAT: start column? [1..' num2str(nCcdColumns) ']: '], 's');
        startColumn = fix(str2double(startColumn));
        if(~ismember(startColumn, (1:nCcdColumns)'))
            fprintf(['start column has to be >= 1 and <= ' num2str(nCcdColumns)  ' \n' ]);
        else
            break;
        end
    end
    while true
        endColumn = input(['TCAT: end column? [1..' num2str(nCcdColumns) ']: '], 's');
        endColumn = fix(str2double(endColumn));
        if(~ismember(endColumn, 1:nCcdColumns))
            fprintf(['end column has to be >= 1 and <= ' num2str(nCcdColumns) ' \n']);
        else
            if(endColumn < startColumn)
                fprintf('end column has to be >= start column \n');
            end
            break;
        end
    end
    if(endColumn >= startColumn)
        break;
    end;
end


fprintf('--------------------------------------------------------------------------\n');

tcatInputDataStruct.roiStartRow = startRow;
tcatInputDataStruct.roiEndRow = endRow;
tcatInputDataStruct.roiStartColumn = startColumn;
tcatInputDataStruct.roiEndColumn = endColumn;

return

