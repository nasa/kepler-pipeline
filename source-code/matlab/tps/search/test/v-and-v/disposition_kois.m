function [ koiWithTceStruct, koisMissingTcesStruct ] = disposition_kois( koiDataStruct, ...
    tceStruct )
%
% disposition_kois -- examine the list of KOIs and TCEs to see which KOIs produced TCEs,
% and which did not
%
% [koisWithTcesStruct, koisMissingTcesList] = disposition_kois( koiDatastruct, tceStruct )
%    takes the koiDataStruct returned by parse_koi_text_file and the tceStruct returned by
%    get_tces_from_tps_dawg_struct.  The returned koisWithTcesStruct has the same
%    structure as the koiDataStruct, except that only KOIs which produced TCEs are
%    represented.  The returned koisMissingTcesList is the Kepler IDs of all KOIs which
%    did not produce TCEs but should have (ie, known EBs or KOIs which have too few
%    transits to be detected in the UOW are not included in this list).
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

% use the Kepler IDs to do the initial generation

  koiWithTceStruct = koiDataStruct ;
  koiWithTcePointer = ismember( koiDataStruct.keplerId, ...
      tceStruct.keplerId( tceStruct.trueTceFlag ) ) ;
  
  if isfield( koiWithTceStruct, 'rejectedKeplerId' )
      koiWithTceStruct = rmfield( koiWithTceStruct, 'rejectedKeplerId' ) ;
  end
  fieldList = fieldnames(koiWithTceStruct) ;
  for iField = 1:length(fieldList)
      thisField = fieldList{iField} ;
      koiWithTceStruct.(thisField) = koiWithTceStruct.(thisField)(koiWithTcePointer) ;
  end
  
  disp(['Number of KOI stars which produced a TCE:  ', ...
      num2str(length(unique(koiWithTceStruct.keplerId)))]) ;
  
% find the rejected KOIs which produced TCEs anyway, if any

  if isfield( koiDataStruct, 'rejectedKeplerId')
      koiWithTceStruct.rejectedKeplerId = koiDataStruct.rejectedKeplerId( ...
          ismember( koiDataStruct.rejectedKeplerId, tceStruct.keplerId( tceStruct.trueTceFlag ) ) ) ;

      disp(['Number of rejected KOI stars which produced a TCE:  ', ...
          num2str(length(unique(koiWithTceStruct.rejectedKeplerId)))]) ;
  end
  
% produce the list of KOIs which did not produce a TCE (excluding the rejected ones, since
% we don't expect a TCE from them)

  koisMissingTcesList = koiDataStruct.keplerId( ...
      ~ismember( koiDataStruct.keplerId, tceStruct.keplerId( tceStruct.trueTceFlag ) ) & ...
       ismember( koiDataStruct.keplerId, tceStruct.keplerId ) ) ;
   
  disp(['Number of KOI stars which did not produce a TCE:  ', ...
      num2str(length(unique(koisMissingTcesList)))]) ;
  
  koisMissingTcesPointer = ismember( koiDataStruct.keplerId, koisMissingTcesList ) ;
  koisMissingTcesStruct = koiDataStruct ;
  fieldList = fieldnames(koisMissingTcesStruct) ;
  for iField = 1:length(fieldList)
      thisField = fieldList{iField} ;
      koisMissingTcesStruct.(thisField) = ...
          koisMissingTcesStruct.(thisField)(koisMissingTcesPointer) ;
  end
  
  
% as a last disposition, consider the number of KOIs which were not present in the TPS run
% at all

  nMissingKois = length(find(~ismember(unique(koiDataStruct.keplerId),tceStruct.keplerId))) ;
  disp(['Number of KOI stars which did not run in TPS:  ', num2str(nMissingKois)]) ;

return

