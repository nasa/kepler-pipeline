function memberData = get(waveletObject, memberName)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function memberData = get(waveletObject, memberName)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% get -- extract member data from the waveletObject
%
% memberData = get( waveletObject, memberName ) returns the requested
% member data of the waveletClass object.
%
% memberList = get( waveletObject, '?' ) or memberList = 
% get(waveletObject,'help') returns a list of valid members of the class.
%
% memberStruct = get( waveletObject, '*' ) returns all of the members of the
%    waveletClass object as a struct.
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

if ( (strcmp(memberName, '?')) || (strcmpi(memberName, 'help')) )
    % handle the case of a '?' or 'help' first
    memberData = fieldnames(waveletObject);  
elseif ( strcmp(memberName, '*') )
    % return everything in a struct
    memberData = struct2cell( waveletObject );
    memberData = cell2struct( memberData, fieldnames(waveletObject) );
else
    % check to make sure the member exists in the object
    if ( ~strcmp(memberName,'filterScale') && ~strcmp(memberName, 'nBands') && ...
            ~any( strcmp( fieldnames(waveletObject), memberName) ) )
        error('tps:waveletClass:get:memberNameInvalid', ...
              ['get: memberName ' char(memberName) ' is not valid!']) ;  
    end
    
    switch memberName
        
        case 'extendedFluxTimeSeries'
            memberData = waveletObject.extendedFluxTimeSeries;
            
        case 'filterScale'
            if isempty( waveletObject.G )
                error('waveletClass:get_filter_scale:filterBanksNotSet', ...
                    'get_filter_scale:  filter banks are not set.');
            else
                memberData = size( waveletObject.G, 2 ) - 1;
            end
            
        case 'nBands'
            if isempty( waveletObject.extendedFluxTimeSeries )
                error('waveletClass:compute_number_of_bands:extendedFluxNotSet', ...
                    'compute_number_of_bands:  extendedFlux member not set.') ;
            else
                nSamples     = length(waveletObject.extendedFluxTimeSeries) ;
                filterLength = length(waveletObject.h0) ;
                memberData = log2(nSamples) - floor(log2(filterLength)) + 1 ;
            end
            
        case 'gapFillParametersStruct'
            memberData = waveletObject.gapFillParametersStruct;
            
        case 'varianceWindowCadences'
            memberData = waveletObject.varianceWindowCadences;
            
        case 'outlierIndicators'
            memberData = waveletObject.outlierIndicators;
            
        case 'outlierFillValues'
            memberData = waveletObject.outlierFillValues;
            
        case 'fittedTrend'
            memberData = waveletObject.fittedTrend;
            
        case 'h0'
            memberData = waveletObject.h0;
            
        case 'whiteningCoefficients'
            memberData = waveletObject.whiteningCoefficients;
            
        case 'H'
            memberData = waveletObject.H;
            
        case 'G'
            memberData = waveletObject.G;
            
        case 'noiseEstimationByQuarterEnabled'
            memberData = waveletObject.noiseEstimationByQuarterEnabled;
            
        case 'quarterIdVector'
            memberData = waveletObject.quarterIdVector;
        
    end
        
end

return