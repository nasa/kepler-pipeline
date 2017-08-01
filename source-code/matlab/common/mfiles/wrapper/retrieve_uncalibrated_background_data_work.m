function bkgOutputStruct = retrieve_uncalibrated_background_data_work(targetCrud, fsclient, targetTable, ccdModule, ccdOutput, startCadence, endCadence)
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
    % Get background data:
    %
    import gov.nasa.kepler.mc.SciencePixelOperations

    % Get the background table:
    %
    backgroundTargetTables = targetCrud.retrieveBackgroundTargetTable(targetTable);
    if backgroundTargetTables.size() > 1
        warning('MATLAB:SBT:wrapper:retrieve_uncalibrated_background_data_work', ...
            'WARNING: The length of backgroundTargetTables is greater than 1.');
    end
    backgroundTargetTable = backgroundTargetTables.get(0);
    
    % Get the FS IDs of the pixels:
    %
    sciencePixelOperations = SciencePixelOperations(targetTable, backgroundTargetTable, ccdModule, ccdOutput); %#ok<NASGU>
    backgroundPixels = sciencePixelOperations.getBackgroundPixels().toArray(); % this gets uncalibrated background pixels.
    for ibkg = 1:length(backgroundPixels)
        bkgFsIds(ibkg) = backgroundPixels(ibkg).getFsId();
    end

    % Extract the data from the FS IDs' time series
    %
    bkgPixelValues = fsclient.readTimeSeriesAsInt(bkgFsIds, startCadence, endCadence, false);
    for ibkg = 1:length(bkgPixelValues)
        bkgPix = bkgPixelValues(ibkg);
        bkgOutputStruct(ibkg).row = backgroundPixels(ibkg).getRow; 
        bkgOutputStruct(ibkg).column = backgroundPixels(ibkg).getColumn; 
        bkgOutputStruct(ibkg).timeSeries =  bkgPix.iseries;
        bkgOutputStruct(ibkg).uncertainties = zeros(size(bkgPix.iseries));
        bkgOutputStruct(ibkg).gapIndicators = bkgPix.getGapIndicators;
    end
return 
