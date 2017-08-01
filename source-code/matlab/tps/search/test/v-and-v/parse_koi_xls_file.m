function koiDataStruct = parse_koi_xls_file( xlsFileName, minSesInMesCount, unitOfWorkKjd, ...
    maxKoiNumber )
%
% parse_koi_xls_file -- parse a KOI spreadsheet and return a data struct appropriate for
% use in TPS DAWGing and V & V
%
% koiDataStruct = parse_koi_xls_file( xlsFileName, minSesInMesCount, unitOfWorkKjd,
%    maxKoiNumber ) uses xlsread to parse the named Excel spreadsheet of KOI information.
%    The returned koiDataStruct contains only KOIs which have a "DAWG Flag" value of zero
%    in the spreadsheet, which have sufficient transits in the specified unit of work, and
%    are below the max KOI number.  The spreadsheet should have only a single sheet, and
%    should be saved in the most primitive Excel format available to ensure proper parsing
%    on non-Windows platforms.
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

%=========================================================================================

% parse the Excel spreadsheet

  [dataValues, textValues, rawValues] = xlsread( xlsFileName ) ;
  
% locate the first row of actual data

  dataRows = find(~isnan(dataValues(:,1))) ;
  firstDataRow = dataRows(1) ;
  dataValues = dataValues(firstDataRow:end,:) ;
  
% convert the maxKoiNumber to the first KOI number which should be omitted

  firstKoiNumberOmitted = floor( maxKoiNumber ) + 1 ;
  
% find the DAWG flag column

  dawgFlagColumn = strncmpi('dawg',textValues(1,:),4) ;
  dawgFlag = dataValues(:,dawgFlagColumn) ;
  
% get the period and the epoch, converting epoch from Jason time to KJD

  periodDays = dataValues(:,6) ;
  epochKjd   = dataValues(:,5) + 67 ;
  
% get the KOI # and kepler ID

  koiNumber = dataValues(:,1) ;
  keplerId  = dataValues(:,2) ;
  
% determine whether any of the KOIs have timing such that inadequate #'s of transits will
% occur in the UOW

  nTransitsInUow = floor( (unitOfWorkKjd(2) - epochKjd) ./ periodDays ) + 1 ;
  
% get the KepIDs for the EB list

  eclipsingBinaryData = load_eclipsing_binary_catalog ;
  ebKepId = eclipsingBinaryData(:,1) ;
  
% so a good KOI is one which has dawgFlag == 0, nTransits >= minSesInMes, KOI # below
% the cutoff, and not on the EB list

  goodKoi = dawgFlag==0 & koiNumber < firstKoiNumberOmitted & ...
      ~ismember( keplerId, ebKepId ) & nTransitsInUow >= minSesInMesCount ;
  
% build the struct

  koiDataStruct.keplerId   = keplerId( goodKoi ) ;
  koiDataStruct.koiNumber  = koiNumber( goodKoi ) ;
  koiDataStruct.periodDays = periodDays( goodKoi ) ;
  koiDataStruct.epochKjd   = epochKjd( goodKoi ) ;
  koiDataStruct.depthPpm   = dataValues(goodKoi,20) ;
  koiDataStruct.snr        = dataValues(goodKoi,21) ;

return

