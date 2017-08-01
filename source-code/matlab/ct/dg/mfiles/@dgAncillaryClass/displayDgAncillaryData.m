function [outputType display] = displayDgAncillaryData(dgAncObjs)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function  [outputType display] = displayDgAncillaryData(dgAncObjs)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% Method for displaying dgAncObjs of sigle entry structure.
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% INPUT:  
%    dgAncObj:  an object of the class dgAncillaryClass with the following fields-
%     
%            .mnemonic   [string] the mnemonic that was queried 
%            .timestamps [vector of doubles] time range in MJD
%            .values     [vector of singles] if values are numeric
%            .stringValues [cell of strings] if values are string
%            .mean       [double] computed if values are numeric 
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% OUTPUT:
%
%       outputType: [string] indicating whether display is a figure, table,
%                   or that mnemonic was not found
%          display: [empty string] if outputType is figure 
%                   (mnemonic values are numeric)
%                   [cell] if outputType is table
%                   (mnemonic values are strings)
%                   [string] if ouputType indicates mnemonic not found
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
mnemonic = get(dgAncObjs, 'mnemonic');
timestamps = get(dgAncObjs, 'timestamps');
values = get(dgAncObjs, 'values');
stringValues = get(dgAncObjs, 'stringValues');
meanValue = get(dgAncObjs, 'mean');

if ~isempty(timestamps) % if mnemonic for the time range is in datastore
    
    if ~isempty(values) % if mnemonic values are numeric
        outputType = 'figure';
        display = '';
        figure
        set(gcf, 'position', [138   408   893   227])
        set(gcf, 'color', [1 1 1]);
        plot(timestamps, values, '.')
        xlabel('\bf Timestamps (mjd)')
        ylabel('\bf Value')
        string = strcat(mnemonic, ', mean =', num2str(meanValue));
        legend(string);
        
        
        %plot and display mean

    else % values are string and a table must be built
        outputType = 'table';
        lgth = length(timestamps);
        preDisplay =[{'timestamps'}, {'values'}; num2cell(timestamps), stringValues];
        if lgth <= 20 % limit of table rows
            display = preDisplay;
        else % must resample so that table is of viewable length
            rowFactor = fix(lgth/20);
            display(1,:) = preDisplay(1, :); % same header
            display(2,:) = preDisplay(2,:); % keep the first pair of values
            for r = 3:21
            display(r,:) = preDisplay((r-2)*rowFactor+2,:);
            end        
        end
    end
    
else % mnemonic for the time range not in datastore
    
    outputType = 'string';
    display = 'no mnemonic found for the time range';
    
    
end



