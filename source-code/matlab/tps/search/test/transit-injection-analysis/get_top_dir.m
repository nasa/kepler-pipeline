function [topDir, diagnosticDir] = get_top_dir(groupLabel)
% Directories for the tpsInjectionStruct and diagnosticStruct
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

% Top directory for codes
baseDir = '/path/to/matlab/tps/search/test/transit-injection-analysis/';

switch groupLabel
    
    case 'Group1-1'

        % Part 1 of Group1 (all of 1st 20 G stars)
        % 10080 target entries
        part1Suffix = 'tps-matlab-2015231/';
        topTopDir = '/path/to/transitInjectionRuns/Group_1_1st_20_G_stars_09032015/';
        topDir = strcat(topTopDir,part1Suffix);
        diagnosticDir = '/codesaver/work/transit_injection/diagnostics/Group1-1/';
        
    case 'Group1-2'
           
        % Part 2 of Group 1 (12 of 1st 20 G stars)
        % 6048 target entries
        part2Suffix = 'tps-matlab-2015239/';
        topTopDir = '/path/to/transitInjectionRuns/Group_1_1st_20_G_stars_09032015/';
        topDir = strcat(topTopDir,part2Suffix);
        diagnosticDir = '/codesaver/work/transit_injection/diagnostics/Group1-2/';
        
    case 'Group1-3'
        
        % Part 3 of Group 1 (7 of 1st 20 G stars)
        % 3528 target entries
        part3Suffix = 'tps-matlab-2015240/';
        topTopDir = '/path/to/transitInjectionRuns/Group_1_1st_20_G_stars_09032015/';
        topDir = strcat(topTopDir,part3Suffix);
        diagnosticDir = '/codesaver/work/transit_injection/diagnostics/Group1-3/';
          
    case 'Group2'
        % Group 2 (1st 20 K stars)
        topDir = '/path/to/transitInjectionRuns/Group_2_1st_20_K_stars_09012015/tps-matlab-2015233/';
        diagnosticDir = '/codesaver/work/transit_injection/diagnostics/Group2/';
        
    case 'KSOC4886'
        % 1 G star, 1 K star, and 1 M star  -- previous injection targets?
        topDir = '/path/to/1_G_star_1_K_star_1_M_star_09052015/tps-matlab-2015247/';
        diagnosticDir = '/codesaver/work/transit_injection/diagnostics/KSOC4886/';
        
    case 'Group3'
       % Group 3 (1st 20 M stars)
        topDir = '/path/to/transitInjectionRuns/Group_3_1st_20_M_stars_09082015/tps-matlab-2015244/';
        diagnosticDir = '/codesaver/work/transit_injection/diagnostics/Group3/';
        
    case 'Group4'
       % Group 4 (2nd 20 G stars)
        topDir = '/path/to/transitInjectionRuns/Group_4_2nd_20_G_stars_09102015/tps-matlab-2015248/';
        diagnosticDir = '/codesaver/work/transit_injection/diagnostics/Group4/';
        
    case 'Group5'
        % Group 5 (2nd 20 K stars)
        topDir = '/path/to/transitInjectionRuns_maxNumberOfAttemps_set_to_1/Group_5_2nd_20_K_stars_09172015/tps-matlab-2015253/';
        diagnosticDir = '/codesaver/work/transit_injection/diagnostics/Group5/';
       
    case 'Group6'
        % Group 6 (2nd 20 M stars)
        topDir = '/path/to/transitInjectionRuns_maxNumberOfAttemps_set_to_1/Group_6_2nd_20_M_stars_09242015/tps-matlab-2015260/';
        diagnosticDir = '/codesaver/work/transit_injection/diagnostics/Group6/';
        
    case 'KIC3114789'
        % Previous injection target?
        topDir = '/path/to/transitInjectionRuns_fractionToSampleByMes_set_to_0/testRun_KIC3114789_10012015/tps-matlab-2015273/';
        diagnosticDir = '/codesaver/work/transit_injection/diagnostics/KIC3114789/';
        
    case 'GroupA'
        % Group A (3 G stars and 2 K stars -- previous injection targets?)
        topDir = '/path/to/transitInjectionRuns_fractionToSampleByMes_set_to_0/Group_A_3_G_stars_and_2_K_stars_10112015/tps-matlab-2015280/';
        diagnosticDir = '/codesaver/work/transit_injection/diagnostics/GroupA/';

    case 'GroupB'
        % Group B (1 G star, 1 K star and 3 M stars -- previous injection targets?)
        topDir = '/path/to/transitInjectionRuns_fractionToSampleByMes_set_to_0/Group_B_1_G_star_1_K_star_and_3_M_stars_10112015/tps-matlab-2015282/';
        diagnosticDir = '/codesaver/work/transit_injection/diagnostics/GroupB/';
        
    case 'KSOC-4930'
        % KSOC-4930 (2 G stars: KIC-3114789 and KIC-9898170 -- both are previous injection targets)
        topDir = '/path/to/transitInjections/KSOC-4930/testRun_2_G_stars/tps-matlab-2015308/';
        diagnosticDir = '/codesaver/work/transit_injection/diagnostics/KSOC-4930/';
        
    case 'KSOC-4964'    
        % KSOC-4964 (2 G stars: KIC-3114789 and KIC-9898170 -- both are previous injection targets)
        % Same as KSOC-4930, except with new diagnostics
        topDir = '/path/to/transitInjections/KSOC-4964/testRun_1_with_2_G_stars/tps-matlab-2015344/';
        diagnosticDir = '/codesaver/work/transit_injection/diagnostics/KSOC-4964/';
       
    case 'KSOC-4964-2'
        % KSOC-4964 test2 (2 G stars: KIC-3114789 and KIC-9898170 -- both are previous injection targets)
        % Same as KSOC-4930, except with tps spsd detector off
        topDir = '/path/to/transitInjections/KSOC-4964/testRun_2_with_2_G_stars/tps-matlab-2015344/';
        diagnosticDir = '/codesaver/work/transit_injection/diagnostics/KSOC-4964-2/';
        
    case 'KSOC-4964-4'
        % KSOC-4964 test4 (20 stars -- new injection targets?)
        % Using new code with modifications by Chris Burke, see KSOC-4958
        topDir = '/path/to/transitInjections/KSOC-4964/testRun_4_with_20_stars/tps-matlab-2015356/';
        diagnosticDir = '/codesaver/work/transit_injection/diagnostics/KSOC-4964-4/';

    case 'KSOC-4976-1'
        % KSOC-4976 test1 (2 stars -- both are previous injection targets?)
        % Using updated code, based on
        % code used in KSOC-4964-4, but with modifications from Chris Burke to force
        % injected phase to be correct when forcing the injected
        % parameters, and from me to add 2 new diagnostics.
        topDir = '/path/to/transitInjections/KSOC-4976/testRun_1_with_2_stars/tps-matlab-2016011/';
        diagnosticDir = '/codesaver/work/transit_injection/diagnostics/KSOC-4976-1/';
        
     case 'KSOC-4976-2'
        % KSOC-4976 test1 (2 stars -- both are previous injection targets)
        % Using updated code, based on
        % code used in KSOC-4964-4, but with modifications from Chris Burke to force
        % injected phase to be correct when forcing the injected
        % parameters, and from me to add 2 new diagnostics.
        topDir = '/path/to/transitInjections/KSOC-4976/testRun_2_with_2_stars/tps-matlab-2016011/';
        diagnosticDir = '/codesaver/work/transit_injection/diagnostics/KSOC-4976-2/';
            
        
    case 'TPS9p3V4'
        % KSOP-2536
        topDir = '/path/to/mq-q1-q17/pipeline_results/tps-v4/';
        diagnosticDir = '';
        
    case 'KSOC-5004-1'
        % This run had an error in the 'MES targeting' code, so that
        % density of impact parameters was not uniform
        % 20 Targets with CDPP slope in desired range roughly 850K
        % injections on each
         topDir = '/path/to/transitInjections/KSOC-5004/Group_1_20_stars/tps-matlab-2016056/';
         diagnosticDir = '/codesaver/work/transit_injection/diagnostics/KSOC-5004-1/';
         
    case 'KSOC-5004-1-run2'
        % ***** This run repeated the last, but with MES targeting turned off.
        % 20 Targets with CDPP slope in desired range roughly 650K
        % injections on each
         topDir = '/path/to/transitInjections/KSOC-5004/Group_1_20_stars_fractionToSampleByMes_0/tps-matlab-2016070/';
         diagnosticDir = '/codesaver/work/transit_injection/diagnostics/KSOC-5004-1-run2/';
         
    case 'KSOC-5004-1-test2'
        % test run of a single target with MES targeting revised by Chris and turned on
        topDir = '/path/to/transitInjections/KSOC-5004/Test_2_with_1_star_fractionToSampleByMes_0p7/tps-matlab-2016076/';
        diagnosticDir = '/codesaver/work/transit_injection/diagnostics/KSOC-5004-1-test2/';  
        
    case 'KSOC-5004-2'
        % ***** This run is the 20 Group2 stars run with the code as in KSOC-5004-1-run2, with MES targeting turned off.
        % 20 Targets with CDPP slope in desired range (~positive?) roughly 650K
        % injections on each
        topDir = '/path/to/transitInjections/KSOC-5004/Group_2_20_stars_fractionToSampleByMes_0/tps-matlab-2016078/';
        diagnosticDir = '/codesaver/work/transit_injection/diagnostics/KSOC-5004-2/';  
        
    case 'KSOC-5040'
        % Single target KIC-1161137, Deep FLTI 
        % fitSinglePulseWhenSearched... is now fixed, and also TPS now searches
        % both bracketing transit durations; previously due to an error, it searched only
        % the lower one.
        topDir = '/path/to/transitInjections/KSOC-5040/Test_1_with_1_star/tps-matlab-2016123/';
        diagnosticDir = '/codesaver/work/transit_injection/diagnostics/KSOC-5040/';  
        
        
    case 'KSOC-5007-shallow-test1' % 98 stars
        topDir = '/path/to/transitInjections/KSOC-5007/Shallow_FLTI_Test_1_with_100_stars/tps-matlab-2016159/';
        diagnosticDir = '/codesaver/work/transit_injection/diagnostics/KSOC-5007-shallow-test1/'; 
        
end

