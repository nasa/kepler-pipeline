function blobSeriesStruct = make_test_blobSeries_structure()
%
% make_test_blobSeries_structure -- generate a valid data structure of the blobSeries
% format for use in testing blobSeriesClass methods
%
% blobSeriesStruct = make_test_blobSeries_structure() returns a mock-up of a blobSeries
%    data structure which can be used to instantiate a blobSeriesClass object or to do
%    other tests of blobSeriesClass features.
%
% Version date:  2008-September-19.
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
%     2008-September-19, PT:
%         add startCadence and endCadence fields
%     2008-September-05, PT:
%         updated to current plan for blobSeries class:  blobs are always passed as
%         filenames, in a blobFilenames cell array field.
%
%=========================================================================================

% a total of ten cadences, one of which is gapped

  blobSeriesStruct.blobIndices = int32([0 0 0 0 2 2 2 1 1 1]) ; % zero-based
  blobSeriesStruct.gapIndicators = [false false false true false false false ...
                                    false false false] ;
  blobSeriesStruct.startCadence = 0 ;
  blobSeriesStruct.endCadence = 2 ;
        
% how many blob structures?

  nBlobs = max(blobSeriesStruct.blobIndices) + 1 ;
  for iBlob = 1:nBlobs
      
%     generate each structure, blobbify it, and stick it on the blobSeries structure

      s.firstField = rand(10) ;
      s.secondField = randn(10) ;
      s.thirdField = 'Duran Duran' ;
      s.fourthField(1).firstSubField = ceil(rand(5,1)*5) ;
      s.fourthField(1).secondSubField = 'positronium' ;
      s.fourthField(2).firstSubField = 'quark-gluon plasma' ;
      s.fourthField(2).secondSubField = false ;
      
      filename = ['blobTest',num2str(iBlob),'.mat'] ;
      
      struct_to_blob(s,filename) ;
      blobSeriesStruct.blobFilenames{iBlob} = filename ;
      
  end % loop over blobs
  
% and that's it!

%
%
%
