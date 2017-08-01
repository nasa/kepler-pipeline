
% script to mine a large set of DV results structures and extract the planet candidates
% which look most likely to be real planets
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

% set some global definitions

%  topDir = '/path/to/flight/q2/i915' ;
%  topDir = '/path/to/pipeline_results/science_q2/TEST-release6.1-tps-dv' ;
  topDir = '/path/to/TEST/7.0/pipeline_results/planet-search/dv/i3957' ;
  
%  centroidSignificanceCutoff = 0.5 ; 
  centroidSignificanceCutoff = -2.0 ; 
  transitDepthSignificanceCutoff = 0.5 ;
  transitEpochSignificanceCutoff = 0.5 ;
  orbitalPeriodSignificanceCutoff = 0.5 ;
  transitDepthCutoffSigmas = 2.0 ;

%%  
  
% define the structure

  planetCandidateStruct = [] ; 
  
% get the list of dv directories in the top dir

  dvDirList = dir([topDir, filesep, 'dv-matlab-*']) ;
  
% start the mission
  
  t00 = clock ;
  
  for iDir = 1:length(dvDirList)
      
      dirName = dvDirList(iDir).name ;
      t0 = clock ;
      disp( [ datestr(t0), '  ', dirName, '  ', num2str(iDir), '  ', ...
          num2str( length( planetCandidateStruct ) ) ] ) ;
      
      if exist( fullfile( topDir, dirName, 'dv-outputs-0.mat' ), 'file' )
          load( fullfile( topDir, dirName,  'dv-outputs-0' ) ) ;
      
          newPlanetResults = dv_data_miner_kernel( outputsStruct, dirName, ...
              centroidSignificanceCutoff, transitDepthSignificanceCutoff, ...
              transitEpochSignificanceCutoff, orbitalPeriodSignificanceCutoff, ...
              transitDepthCutoffSigmas ) ;
      
          planetCandidateStruct = [planetCandidateStruct ; newPlanetResults(:)] ;
          
          clear outputsStruct ;
          
      else
          
          dvDirListNas = dir([topDir, filesep, dirName, filesep, 'st-*']);
          
          for jDir = 1:length(dvDirListNas)
              
              dirNameNas = [dirName, filesep, dvDirListNas(jDir).name];
              
              if exist( fullfile( topDir, dirNameNas, 'dv-outputs-0.mat' ), 'file' )
                  
                  load( fullfile( topDir, dirNameNas,  'dv-outputs-0' ) ) ;
      
                  newPlanetResults = dv_data_miner_kernel( outputsStruct, dirNameNas, ...
                      centroidSignificanceCutoff, transitDepthSignificanceCutoff, ...
                      transitEpochSignificanceCutoff, orbitalPeriodSignificanceCutoff, ...
                      transitDepthCutoffSigmas ) ;

                  planetCandidateStruct = [planetCandidateStruct ; newPlanetResults(:)] ;

                  clear outputsStruct ;
                  
              end
              
          end
          
      end
      
  end % loop over directories
  
  disp(' ') ;
  t0 = clock ;
  disp([datestr(t0), '  Done!  ', num2str(length(planetCandidateStruct) )]) ;
  
%%

% sort into magnitude order

  keplerId = [planetCandidateStruct.keplerId] ;
  kicProperties = retrieve_kics_by_kepler_id_sdf( keplerId ) ;
  keplerMag = [kicProperties.keplerMag] ;
  keplerMag = [keplerMag.value];
  [sortedMag, sortKey] = sort( keplerMag ) ;
  planetCandidateStruct = planetCandidateStruct( sortKey ) ;

%%

  
% start display loop

  peruse_dv_fits_in_candidate_struct( planetCandidateStruct, topDir, 1 ) ;
  
return