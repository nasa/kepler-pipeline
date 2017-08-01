function [ffiKeywordStruct ffiKeywordTable] = retrieve_fits_primary_keywords(ffiName, varargin)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [ffiKeywordStruct ffiKeywordTable] = retrieve_fits_primary_keywords(ffiName, varargin)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% retrieve_fits_primary_keywords retrieves variable number of keywords from a 
% the primary header of a fits file and returns it in a structure called 
% ffiKeywordStruct and a cell ffiKeywordTable.  The table contains the
% descriptions associated with the mnemonics while the structure does not
%
% matching is of the type exact, i.e., CASE SENSITIVE, if no match is
% found, output field will display 'datatype not found'
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% INPUT:  
%           ffiName: [string] in quotes, for example, 'goodData.fits'
%  varargin keyword: [string] in quotes, for example, 'INT_TIME', 'STAR_TIME'
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% 
% OUTPUT:
%  ffiKeywordStruct: [struct] with input varargin keywords as the fields
%   ffiKeywordTable: [cell] 3 column table where the first column is the
%   mnemonic, second column is the value, and third column is the
%   description
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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

numKeywords = nargin - 1;

infoFfi = fitsinfo(ffiName);

for n = 1:numKeywords

    indxDatatype=strmatch(varargin{n},infoFfi.PrimaryData.Keywords(:,1), 'exact');
    if isempty(indxDatatype)==0
        valDatatype=infoFfi.PrimaryData.Keywords{indxDatatype,2};
    else
        valDatatype= [ varargin{n} ' not found'];
    end
 ffiKeywordStruct.(varargin{n}) = valDatatype;
end



fields = fieldnames(ffiKeywordStruct);
nFields = length(fields);



% get the description of the retrieved keywords
descrip = cell(nFields, 1);
for n =1:nFields
    indx = strmatch(fields{n}, infoFfi.PrimaryData.Keywords(:,1), 'exact');
    try
        descrip(n) = infoFfi.PrimaryData.Keywords(indx, 3);
    catch
        descrip(n) = {'N/A'};
    end
end
val = struct2cell(ffiKeywordStruct);
ffiKeywordTable = [{'Mnemonic'}, {'Value'}, {'Description'}; fields, val, descrip];

return