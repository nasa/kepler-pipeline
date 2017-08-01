function crInfoStruct = process_cosmic_ray_event_data( realCREvents, detectedCREvents )
%
% process_cosmic_ray_event_data -- process cosmic ray events data structures
%
% crInfoStruct = process_cosmic_ray_event_data( realCREvents, detectedCREvents ) takes a
% real ("ground truth") cosmic ray events data structure, and an equivalent structure of
% the detected events.  It analyzes the two datasets and produces an output structure with
% the following fields:
%
% nEventsActual:       actual number of cosmic ray events
% nEventsDetected:     number of actual events detected
% nFalsePositive:      number of false positive events (events detected on pixels which 
%                      had no cosmic ray contamination on them)
% nFalseNegative:      number of false negative events (events with undetected cosmics)
% deltaActual:         actual intensity of detected cosmic ray events
% deltaDetected:       detected intensity of detected cosmic ray events
% deltaFalsePositive:  detected intensity of false positive events
% deltaFalseNegative:  actual intensity of undetected cosmic ray events
%
% Version date:  2008-December-11.
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

% Modification History:
%
%=========================================================================================

% convert the row, col, mjd, delta from each structure into vectors.  Note that the pixel
% information is currently zero-based and must be converted to one-based

  realRow = [realCREvents.ccdRow] + 1 ;
  realCol = [realCREvents.ccdColumn] + 1 ;
  realMjd = [realCREvents.mjd] ;
  realDelta = [realCREvents.delta] ;
  nEventsActual = length(realDelta) ;
  
  detRow = [detectedCREvents.ccdRow] ;
  detCol = [detectedCREvents.ccdColumn] ;
  detMjd = [detectedCREvents.mjd] ;
  detDelta = [detectedCREvents.delta] ;
  
% find the complete, unique set of MJDs for all data in both datasets

  mjdAll = unique([realMjd(:) ; detMjd(:)]) ;
  nMjd = length(mjdAll) ;
  
% construct vectors which convert the MJDs of the events into indices into mjdAll; this
% will give each event a unique set of integer coords for row, col, and cadence

  [tf,realMjdIndex] = ismember(realMjd,mjdAll) ;
  [tf,detMjdIndex] = ismember(detMjd,mjdAll) ;
  
% find the max row and max column present in either dataset

  maxRow = max([realRow(:) ; detRow(:)]) ;
  maxCol = max([realCol(:) ; detCol(:)]) ;
  
% Convert the (row,col,mjdIndex) to a single index which uniquely identifies the time and
% location of each hit

  realIndex = sub2ind([maxRow,maxCol,nMjd], realRow, realCol, realMjdIndex) ;
  detIndex  = sub2ind([maxRow,maxCol,nMjd], detRow,  detCol,  detMjdIndex ) ;
  
% find the detected events -- these are the elements in detIndex which are members of
% realIndex

  [tf,detectedEventRealIndex] = ismember(detIndex,realIndex) ;
  detectedRealEvents = find(tf == true) ;
  realIndexPointer = find(detectedEventRealIndex > 0) ;
  detectedEventRealIndex = detectedEventRealIndex(realIndexPointer) ;
  nEventsDetected = length(detectedRealEvents) ;
  deltaActual = realDelta(detectedEventRealIndex) ;
  deltaDetected = detDelta(detectedRealEvents) ;
  
% find the false positives -- these are events in detIndex which are absent in realIndex

  falsePositiveEvents = find(tf == false) ;
  nFalsePositive = length(falsePositiveEvents) ;
  deltaFalsePositive = detDelta(falsePositiveEvents) ;
  
% find the false negatives -- these are events in realIndex which are absent in detIndex

  [tf,loc] = ismember(realIndex,detIndex) ;
  falseNegativeEvents = find(tf==false) ;
  nFalseNegative = length(falseNegativeEvents) ;
  deltaFalseNegative = realDelta(falseNegativeEvents) ;
  
% construct the return structure and exit

  crInfoStruct.nEventsActual = nEventsActual ;
  crInfoStruct.nEventsDetected = nEventsDetected ;
  crInfoStruct.nFalsePositive = nFalsePositive ;
  crInfoStruct.nFalseNegative = nFalseNegative ;
  crInfoStruct.deltaActual = deltaActual ;
  crInfoStruct.deltaDetected = deltaDetected ;
  crInfoStruct.deltaFalsePositive = deltaFalsePositive ;
  crInfoStruct.deltaFalseNegative = deltaFalseNegative ;
  
return

% and that's it!

%
%
%

  