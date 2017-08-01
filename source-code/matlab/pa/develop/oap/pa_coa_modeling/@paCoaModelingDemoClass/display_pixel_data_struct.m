function display_pixel_data_struct(pixelDataStruct, varargin)
%************************************************************************** 
% display_pixel_data_struct(pixelDataStruct, varargin)
%************************************************************************** 
% Generate images of the specified data fields on the specified cadence
%
% INPUTS
%     pixelDataStruct
% 
%     Other inputs are specified as optional attribute/value pairs. Valid 
%     attribute and values are
%    
%     Attribute      Value
%     ---------      -----
%     'cadence'      An integer in the range [1, nCadences]. (default: 1)
%     'fields'       A cell array of field names (strings) specifying data
%                    fields in pixelDataStruct from which to generate
%                    images (e.g., {'values', 'uncertainties'}). (default:
%                    'values') 
%     'plotType'     Either 'linear' or 'log'. (default: 'linear')
%
% OUTPUTS
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

    nCadences = length(pixelDataStruct(1).values);
    validPlotTypes = {'linear', 'log'};
    
    %----------------------------------------------------------------------
    % Parse and validate arguments.
    %----------------------------------------------------------------------
    parser = inputParser;
    parser.addParamValue('cadence',         1, @(x) x == fix(x) && x>=1 && x<=nCadences   );
    parser.addParamValue('fields', {'values'}, @(x) all(isfield(pixelDataStruct, x))      );
    parser.addParamValue('plotType', 'linear', @(x) any(strcmpi(x, validPlotTypes)));
    parser.parse(varargin{:});
    
    cadence     = parser.Results.cadence;
    fields      = parser.Results.fields;
    plotType    = parser.Results.plotType;

    %----------------------------------------------------------------------
    % Generate the plot.
    %----------------------------------------------------------------------
    nFields = numel(fields);

    figure
    for iField = 1:nFields

        mat = paCoaModelingDemoClass.extract_data_cube( pixelDataStruct, fields{iField}, cadence );
        
        if strcmpi(plotType, 'log')
            mat(mat<=0) = 0;
            mat = log(mat);
        end

        ax = subplot(1, nFields, iField);           
        if iField == 1
            imagesc(mat);
            clim = get(ax,'CLim');
        else
            imagesc(mat, clim);
        end
        colorbar('location', 'SouthOutside');
        if strcmpi(plotType, 'log')
            dataStr = sprintf('log(%s)', fields{iField});
        else
            dataStr = sprintf('%s', fields{iField});
        end
        title( sprintf('Data = %s, Cadence = %d', dataStr, cadence), ...
            'FontSize', 12, 'FontWeight', 'bold');
        xlabel('Column');
        ylabel('Row');
    end
        
end

%********************************** EOF ***********************************

