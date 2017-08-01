function catalog = convert_catalog_to_pa_format(catalog)
%**************************************************************************
% function catalog = convert_catalog_to_pa_format(catalog)
%**************************************************************************
% Determine the type of catalog provided, if any, and convert it to the
% format expected by PA.
%
% INPUTS
%     catalog : 
%
% OUTPUTS
%     catalog : 
%
%**************************************************************************
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
    valueStruct = struct('value', NaN, 'uncertainty', NaN);
    kicsStruct = struct( ...
       'keplerId',  int16(0), ... 
       'keplerMag', valueStruct, ...
       'ra',        valueStruct, ...
       'dec',       valueStruct);

    expectedStructFields = {'keplerMag', 'ra', 'dec'};
    expectedArrayFields  = {'keplerId'};
        
    isExpectedFormat = true;
    
    if all(isfield(catalog, expectedStructFields)) ...
       && all(isfield(catalog, expectedArrayFields))

       for iField = 1:numel(expectedStructFields)
            f = expectedStructFields{iField};
            s = catalog(1).(f);
            if ~isstruct(s) || isfield(s, 'value') ...
               || isfield(s, 'uncertainty')
                isExpectedFormat = false;
            end
        end
    end
    
    if ~isExpectedFormat
        nEntries = numel(catalog);
        newCatalog = repmat(kicsStruct, [1, nEntries]);
        
        for iEntry = 1:nEntries
            newCatalog(iEntry).keplerId         = catalog(iEntry).keplerId;
            newCatalog(iEntry).keplerMag.value  = catalog(iEntry).keplerMag;
            newCatalog(iEntry).ra.value         = catalog(iEntry).ra;
            newCatalog(iEntry).dec.value        = catalog(iEntry).dec;
        end
        catalog = newCatalog;
    else
        fieldsToRemove = setdiff( fieldnames(catalog), ...
            {'keplerId', 'keplerMag', 'ra', 'dec'} );
        catalog = rmfield( catalog, fieldsToRemove );
    end

end

%********************************* EOF ************************************