function copy_frequencies( obj, obj2 )
%
% copy_frequencies -- copy frequencies from one harmonicCorrectionClass object to another
%
% obj.copy_frequencies( obj2 ) copies the frequencies from one harmonicCorrectionClass to
%    another.  Any frequencies which are stored in the destination object will be cleared.
%    The copy process will also map the frequencies in obj2 to the nearest equivalent
%    frequencies in obj, given that the two objects may not have the same frequency
%    spacing.
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

% make sure that obj2 is of the correct class

  if ~isa(obj2,'harmonicCorrectionClass')
      error('common:harmonicCorrectionClass:wrongArgumentClass', ...
          'copy_frequencies:  argument is not harmonicCorrectionClass') ;
  end

% if the destination object contains any frequencies, clear them and issue a warning

  if ~isempty( obj.fourierComponentStruct )
      warning('common:harmonicCorrectionClass:clearingExistingFrequencies', ...
          'copy_frequencies will clear existing harmonics in destination object') ;
      obj.fourierComponentStruct = [] ;
  end
  
% get the PSD frequencies for the destination

  psdFrequenciesHz = obj.get_psd_frequencies ;
  
% get the frequency struct from the source object

  sourceFourierComponentStruct = obj2.fourierComponentStruct ;
  
% build a destination struct with the correct # of entries

  destinationStruct = harmonicCorrectionClass.get_fourier_component_struct_array( 0, 0, ...
      length(sourceFourierComponentStruct) ) ;
  
% loop over frequencies

  for iFreq = 1:length(destinationStruct)
      sourceStruct = sourceFourierComponentStruct(iFreq) ;
      [~,nearestIndex] = min(abs(psdFrequenciesHz - sourceStruct.frequencyHz)) ;
      [~,centerIndex] = min(abs(psdFrequenciesHz - sourceStruct.centerFrequencyHz)) ;
      destinationStruct(iFreq).frequencyHz = psdFrequenciesHz(nearestIndex) ;
      destinationStruct(iFreq).frequencyIndex = nearestIndex ;
      destinationStruct(iFreq).centerFrequencyHz = psdFrequenciesHz(centerIndex) ;
      destinationStruct(iFreq).centerIndex       = centerIndex ;      
      destinationStruct(iFreq).periodDays = ...
          1/destinationStruct(iFreq).frequencyHz * ...
          get_unit_conversion('sec2day') ; 

      
  end
  
% eliminate duplicates and save

  [~,uniquePointer] = unique([destinationStruct.frequencyIndex]) ;
  obj.fourierComponentStruct = destinationStruct(uniquePointer) ;
  
return

