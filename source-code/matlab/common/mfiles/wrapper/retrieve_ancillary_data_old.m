function [ancillaryData mnemonics] = retrieve_ancillary_data(varargin)
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%function [ancillaryData mnemonics] = retrieve_ancillary_data()
% or
%function [ancillaryData mnemonics] = retrieve_ancillary_data(mnemonics)
% or
%function [ancillaryData mnemonics] = retrieve_ancillary_data(startMjd, endMjd)
% or
%function [ancillaryData mnemonics] = retrieve_ancillary_data(mnemonics, startMjd, endMjd)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% This script retrieves the ancillary data from the datastore for a given 
% set of mnemonics.  If a time range is given, only data for that time range
% is returned.  If no time range is given, all available data is returned.
%
% INPUTS:
%   mnemonics               A cell array of one or more mnemonics to retrieve.
%                           The cell array must be structured such that
%                           mnemonics{i} is the i-th mnemonic in the list, e.g.:
%                               mnemonics = cell(1,3); 
%                               mnemonics{1} = 'ketchup'; 
%                               mnemonics{2} = 'dijon mustard';
%                               mnemonics{3} = 'relish';
%                           (A cell array is necessary to allow the mnemonics to have different lengths)
%                       
%                           This input may be ommitted.  In this case, data for
%                           every mnemonic in the database is returned.
%
% and
%
%  [no additional args]     The values for entire available time range are 
%                           returned
% or
%
%  startMjd, endMjd         The mnemonic values for the given MJD time range
%                           (inclusive) are returned.
%   
%
% OUTPUT:
%
%   mnemonics               The list of mnemonics in the ancillaryData
%                           output, in the correct order.  This is useful 
%                           if input mnemonics were not specified.
%
%   ancillaryData          A vector of N structures describing the ancillary data for the 
%                           requested times, where N is number of input mnemonics.
%                           
%                           Each structure contains the following fields:
%
%           .mnemonic                     The mnemonic for this structure.
%
%           .timestamps                   A vector of M timestamps for this mnemonic.
%
%           .values                       A vector of M data values for this mnemonic.
%
%           .stringValues                A cell array of the strings described by .values, 
%                                         if the ancillary data arrived as strings.
%                                         If not, this will be empty.
%                                         If .stringValues is nonempty, the data in .values
%                                         will not be meaningful, and the data in .stringValues
%                                         should be used.
%
%           .uncertainties                A vector of M uncertainty values for this mnemonic.
%                                         This field is only populated for ancillary data produced by a pipeline module
%
%           .isAncillaryEngineeringData   A single values that indicates whether this data comes from the
%                                         spacecraft (true) or is a product of a pipeline module (false).
%
%           .quantizationLevel            Only populated for ancillary engineering data
%
%           .intrinsicUncertainty         Only populated for ancillary engineering data
%
%           .modelOrderInDesignMatrix     This field is a module parameter.
%
%           .maxAcceptableGapInHours      This field is a module parameter.
%           
%
% 
% Copyright 2017 United States Government as represented by the
% Administrator of the National Aeronautics and Space Administration.
% All Rights Reserved.
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

import gov.nasa.kepler.systest.sbt.SandboxTools;
SandboxTools.displayDatabaseConfig;

    % Define constants for date checking:
    %
    LOW_MJD =      0;
    HIGH_MJD = 70000;
    LOW_MJD_LIMIT  = sprintf('>= %d', LOW_MJD);
    HIGH_MJD_LIMIT = sprintf('<= %d', HIGH_MJD);

    % Create ancillary CRUD and ancillary dictionary objects for use throughout:
    %
    import gov.nasa.kepler.hibernate.dr.AncillaryDictionaryCrud
    ancillaryCrud = AncillaryDictionaryCrud;
    ancillaryDicationaryMnemonicJavaList = ancillaryCrud.retrieveAncillaryDictionary();
    
    % If no mnemonic arg is given, retrieve use all of the mnemonics:
    %
    if nargin == 0 || nargin == 2
        for imnemonic = 1:ancillaryDicationaryMnemonicJavaList.size()
            mnemonics{imnemonic} = char(ancillaryDicationaryMnemonicJavaList.get(imnemonic-1).getMnemonic());
        end
    end
    
    % Validate number of arguments
    %
    if nargin < 0 || nargin > 3
        error('MATLAB:SBT:wrapper:retrieve_ancillary_data', ...
              'The retrieve_ancillary_data tool must be called with 0, 1, 2, or 3 arguments.  See help text.')
    end

    % Validate input time range, if given:
    %
    if nargin == 0 
        startMjd = LOW_MJD;
        endMjd =   HIGH_MJD;
    elseif nargin == 1
        mnemonics = varargin{1};
        startMjd = LOW_MJD;
        endMjd =   HIGH_MJD;
    elseif nargin == 2
        startMjd = varargin{1};
        endMjd   = varargin{2};
    elseif nargin == 3
        mnemonics = varargin{1};
        startMjd  = varargin{2};
        endMjd    = varargin{3};
    end
    fieldsAndBounds = {'startMjd'; LOW_MJD_LIMIT;  HIGH_MJD_LIMIT;  []};
    validate_field(startMjd, fieldsAndBounds, 'MATLAB:SBT:wrapper:retrieve_ancillary_data:invalidInput');
    fieldsAndBounds = {'endMjd';   LOW_MJD_LIMIT;  HIGH_MJD_LIMIT;  []};
    validate_field(endMjd,   fieldsAndBounds, 'MATLAB:SBT:wrapper:retrieve_ancillary_data:invalidInput');

    
    % Verify that mnemonics is a cell array:
    if ~iscell(mnemonics)
        error('MATLAB:SBT:wrapper:retrieve_ancillary_data', ...
            'The argument mnemonics must be a cell array.  See help text.')
    end

    % Define a temporary output structure for a single mnemonic with empty fields:
    %
    oneAncillaryData = struct('mnemonic',                   '', ...
                                'timestamps',                 [], ...
                                'values',                     [], ...
                                'stringValues',              cell(1), ...
                                'uncertainties',              [], ...   
                                'isAncillaryEngineeringData', 0, ...   
                                'quantizationLevel',          0.0, ...
                                'intrinsicUncertainty',       0.0, ...
                                'modelOrderInDesignMatrix',   0, ...
                                'maxAcceptableGapInHours',    0);

    % Fill the output structure with num_mnemonics (empty) single-ancillary-data structures:
    %
    ancillaryData = repmat(oneAncillaryData, 1, length(mnemonics));

    % Get the persisted ancillary data data using AncillaryOperations object:
    %
    import gov.nasa.kepler.mc.ancillary.AncillaryOperations
    ops = AncillaryOperations();

    javaAncillaryEngineeringData = ops.retrieveAncillaryEngineeringData(mnemonics, startMjd, endMjd);
    javaAncillaryPipelineData = ops.retrieveAncillaryEngineeringData(mnemonics, startMjd, endMjd);
     
    % Parse the Java-side ancillary data structures from ops method into the
    % output structure:
    %
    for java_index = 0:(javaAncillaryEngineeringData.size()-1)
        javaLoopStruct = javaAncillaryEngineeringData.get(java_index);

        ii = java_index + 1;
        ancillaryData(ii).mnemonic              = char(javaLoopStruct.getMnemonic());
        ancillaryData(ii).timestamps                 = javaLoopStruct.getTimestamps();
        ancillaryData(ii).values                     = javaLoopStruct.getValues();
%         ancillaryData(ii).uncertainties              = javaLoopStruct.getUncertainties();
%         ancillaryData(ii).isAncillaryEngineeringData = javaLoopStruct.isAncillaryEngineeringData();
%         ancillaryData(ii).quantizationLevel          = javaLoopStruct.getQuantizationLevel();
%         ancillaryData(ii).intrinsicUncertainty       = javaLoopStruct.getIntrinsicUncertainty();
%         ancillaryData(ii).modelOrderInDesignMatrix   = javaLoopStruct.getModelOrderInDesignMatrix();
%         ancillaryData(ii).maxAcceptableGapInHours    = javaLoopStruct.getMaxAcceptableGapInHours();
        ancillaryData(ii).stringValues = create_string_values_cell_array(ancillaryData(ii), ancillaryDicationaryMnemonicJavaList, java_index);
        
        if length(ancillaryData(ii).timestamps) ~= length(ancillaryData(ii).values)
            error('MATLAB:SBT:wrapper:retrieve_ancillary_data', ...
                  'Timetamps and Values are different lengths! Error');
        end
    end

    import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
    dbInstance = DatabaseServiceFactory.getInstance();
    dbInstance.clear();
SandboxTools.close;
return

function stringValuesCell = create_string_values_cell_array(ancData, ancillaryDicationaryMnemonicJavaList, javaIndexDict)
    
    stringValuesCell = cell(length(ancData.values),1);

    % Test if the input mnemonic is in the translation dictionary:
    %
    goodIndex = -1;
    for ii = 0:ancillaryDicationaryMnemonicJavaList.size()-1
        if strcmp(ancillaryDicationaryMnemonicJavaList.get(i).getMnemonic(), ancData.mnemonic)
            goodIndex = ii;
            break;
        end
    end
    
    if goodIndex < 0
        return
    end
    
    dictMnemonic = ancillaryDicationaryMnemonicJavaList.get(goodIndex);
    dictionaryValuesMap = dictMnemonic.getValuesMap();

    dictMneomicName = char(dictMnemonic.getMnemonic());
    isMnemonicMatch = strmatch(dictMneomicName, ancData.mnemonic);

    % If so, replace the double values for the mnemonic with the
    % corresponding strings:
    %
    if isMnemonicMatch
        for ivalue = 1:length(ancData.values)
            stringValuesCell{ivalue} = dictionaryValuesMap.get(java.lang.Double(ancData.values(ivalue)));
        end
    end

return 
