function badTimingStruct = find_and_sort_bad_timings( koiAndTceStruct, ...
    epochTolerance, periodTolerance )
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

  if length(epochTolerance) == 1
      epochTolerance(2) = 0 ;
  end
  
  badEpoch1 = abs(koiAndTceStruct.epochFigureOfMerit) >= epochTolerance(1) ;
  badEpoch2 = abs(koiAndTceStruct.koiEpochKjd - ...
      koiAndTceStruct.tceEpochKjd) >= epochTolerance(2) * 0.0204 ;
  badEpoch = badEpoch1 & badEpoch2 ;
  
% start with the ones which have bad period timing

  badPeriodPointer = abs(koiAndTceStruct.periodFigureOfMerit) >= periodTolerance & ...
      ~badEpoch ;
  
  badTimingStruct.badPeriodStruct = find_and_sort_kois( koiAndTceStruct, ...
      badPeriodPointer ) ;
  
% now the ones with bad epoch

  badEpochPointer = abs(koiAndTceStruct.periodFigureOfMerit) <= periodTolerance & ...
      badEpoch ;

  badTimingStruct.badEpochStruct = find_and_sort_kois( koiAndTceStruct, ...
      badEpochPointer ) ;
  
% and of course the ones which are bad on both metric

  badBothPointer = abs(koiAndTceStruct.periodFigureOfMerit) >= periodTolerance & ...
      badEpoch ;

  badTimingStruct.badBothStruct = find_and_sort_kois( koiAndTceStruct, ...
      badBothPointer ) ;
  
return

%==========================================================================

function badStruct = find_and_sort_kois( koiAndTceStruct, badPointer )

% first, find the locations of the bad KOIs

  badKoiLocation = find(badPointer) ;
  
% next, sort the snrs for these from strongest to weakest

  [~,sortKey] = sort(koiAndTceStruct.koiSnr(badKoiLocation),'descend') ;
  
  badKoiLocation = badKoiLocation(sortKey) ;
  
% now build the struct

  fieldNames = fieldnames( koiAndTceStruct ) ;
  for iField = 1:length(fieldNames)
      thisField = fieldNames{iField} ;
      badStruct.(thisField) = koiAndTceStruct.(thisField)(badKoiLocation) ;
  end
  
return
