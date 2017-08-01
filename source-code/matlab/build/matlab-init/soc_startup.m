
% 
% Startup script for the Kepler SOC MATLAB environment
%
% Dynamically sets up the path to SOC production code based on the contents
% of the environment variable SOC_CODE_ROOT.  This environment variable
% should point to the code directory in your local Subversion working directory.
%
% This approach is used to allow the build machine to dynamically set the
% location of the source tree using the environment variable and to allow
% multiple builds to execute in parallel, for example soc and soc-test,
% using different values of the variable.
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

% note that, since the path to initialize_soc_variables isn't set yet, 
% we still need to manually get socCodeRoot
 socCodeRoot=getenv('SOC_CODE_ROOT');

 if(isempty(socCodeRoot))
   disp('SOC_CODE_ROOT not set, not updating MATLAB path');
else
  if(~isdeployed || ismcc)

%   find the backtrace state of Matlab and save it to a local variable
    backtraceState = warning('query','backtrace') ;
    
    %   turn off backtrace
    warning backtrace off ;
    
    disp(['Setting SOC MATLAB path relative to SOC_CODE_ROOT=' socCodeRoot]);
    path(fullfile(socCodeRoot, '/matlab/mlunit/src/'),path);
    path(fullfile(socCodeRoot, '/matlab/bin_to_mat/mfiles/'),path);
    path(fullfile(socCodeRoot, '/matlab/ar/build/generated/mfiles/'),path);
    path(fullfile(socCodeRoot, '/matlab/ar/mfiles/'),path);
    path(fullfile(socCodeRoot, '/matlab/ar/test/'),path);
    path(fullfile(socCodeRoot, '/matlab/gar/huffman/build/generated/mfiles/'),path);
    path(fullfile(socCodeRoot, '/matlab/gar/huffman/mfiles/'),path);
    path(fullfile(socCodeRoot, '/matlab/gar/huffman/build/mex/'),path);
    path(fullfile(socCodeRoot, '/matlab/gar/requantization/build/generated/mfiles/'),path);
    path(fullfile(socCodeRoot, '/matlab/gar/requantization/mfiles/'),path);
    path(fullfile(socCodeRoot, '/matlab/gar/hgn/mfiles/'),path);
    path(fullfile(socCodeRoot, '/matlab/gar/hgn/build/generated/mfiles/'),path);
    path(fullfile(socCodeRoot, '/matlab/gar/hac/mfiles/'),path);
    path(fullfile(socCodeRoot, '/matlab/gar/hac/build/generated/mfiles/'),path);
    path(fullfile(socCodeRoot, '/matlab/fc/RaDec2Pix/'),path); % DO NOT REMOVE THIS LINE.  It is necessary for 6.1 and 6.2 (but not later releases) to run radec2pix.
    path(fullfile(socCodeRoot, '/matlab/fc/mfiles/'),path);
    path(fullfile(socCodeRoot, '/matlab/fc/build/mex/'),path);
    path(fullfile(socCodeRoot, '/matlab/cal/build/generated/mfiles/'),path);
    path(fullfile(socCodeRoot, '/matlab/cal/test/'),path);    
    path(fullfile(socCodeRoot, '/matlab/cal/test/etem2_functions_for_cal_inputs/'),path);
    path(fullfile(socCodeRoot, '/matlab/cal/mfiles/'),path);
    path(fullfile(socCodeRoot, '/matlab/cal/mfiles/transform'),path);
    path(fullfile(socCodeRoot, '/matlab/cal/mfiles/compress'),path);
    path(fullfile(socCodeRoot, '/matlab/cal/mfiles/cosmic_ray'),path);
    path(fullfile(socCodeRoot, '/matlab/pdq/build/generated/mfiles/'),path);
    path(fullfile(socCodeRoot, '/matlab/pdq/mfiles/'),path);
    path(fullfile(socCodeRoot, '/matlab/prf/build/generated/mfiles/'),path);
    path(fullfile(socCodeRoot, '/matlab/prf/mfiles/'),path);
    path(fullfile(socCodeRoot, '/matlab/sbt/mfiles/'),path);
    path(fullfile(socCodeRoot, '/matlab/build/matlab-init/'),path);
    path(fullfile(socCodeRoot, '/matlab/build/mfiles'),path);
    path(fullfile(socCodeRoot, '/matlab/tad/coa/build/generated/mfiles/'),path);
    path(fullfile(socCodeRoot, '/matlab/tad/coa/mfiles/'),path);
    path(fullfile(socCodeRoot, '/matlab/tad/ama/build/generated/mfiles/'),path);
    path(fullfile(socCodeRoot, '/matlab/tad/ama/mfiles/'),path);
    path(fullfile(socCodeRoot, '/matlab/tad/amt/build/generated/mfiles/'),path);
    path(fullfile(socCodeRoot, '/matlab/tad/amt/mfiles/'),path);
    path(fullfile(socCodeRoot, '/matlab/tad/bpa/build/generated/mfiles/'),path);
    path(fullfile(socCodeRoot, '/matlab/tad/bpa/mfiles/'),path);
    path(fullfile(socCodeRoot, '/matlab/tad/common/mfiles/'),path);
    path(fullfile(socCodeRoot, '/matlab/tad/rpts/mfiles/'),path);
    path(fullfile(socCodeRoot, '/matlab/tad/rpts/build/generated/mfiles/'),path);
    path(fullfile(socCodeRoot, '/matlab/common/mfiles/'),path);
    path(fullfile(socCodeRoot, '/matlab/common/mfiles/vector_operations/'),path);
    path(fullfile(socCodeRoot, '/matlab/common/mfiles/matrix_operations/'),path);
    path(fullfile(socCodeRoot, '/matlab/common/mfiles/unit_conversion/'),path);
    path(fullfile(socCodeRoot, '/matlab/common/mfiles/unit_conversion/time_string_utilities/'),path);
    path(fullfile(socCodeRoot, '/matlab/common/mfiles/stat_dsp/'),path);
    path(fullfile(socCodeRoot, '/matlab/common/mfiles/programming/'),path);
    path(fullfile(socCodeRoot, '/matlab/common/mfiles/math/'),path);
    path(fullfile(socCodeRoot, '/matlab/common/mfiles/centroids/'),path);
    path(fullfile(socCodeRoot, '/matlab/common/mfiles/DVA/'),path);
    path(fullfile(socCodeRoot, '/matlab/common/mfiles/prf/'),path);
    path(fullfile(socCodeRoot, '/matlab/common/mfiles/wavelet/'),path);
    path(fullfile(socCodeRoot, '/matlab/common/mfiles/wrapper/'),path);
    path(fullfile(socCodeRoot, '/matlab/common/mfiles/quaternion/'),path);
    path(fullfile(socCodeRoot, '/matlab/common/mfiles/astronomy_astrodynamics/'),path);
    path(fullfile(socCodeRoot, '/matlab/common/mfiles/reports/'),path);
    path(fullfile(socCodeRoot, '/matlab/common/mfiles/dsp/'), path);
    path(fullfile(socCodeRoot, '/matlab/common/mfiles/datafun/'), path);
    path(fullfile(socCodeRoot, '/matlab/common/mfiles/mosaic_fp_plot'), path);  
    path(fullfile(socCodeRoot, '/matlab/common/mfiles/motion_polynomial/'), path);
    path(fullfile(socCodeRoot, '/matlab/common/mfiles/timeseries/'), path);
    path(fullfile(socCodeRoot, '/matlab/common/build/generated/mfiles/'),path);
    path(fullfile(socCodeRoot, '/matlab/common/test/wrapper/'),path);
    path(fullfile(socCodeRoot, '/matlab/common/mfiles/coolMatlabGuiStuff/'),path);
    path(fullfile(socCodeRoot, '/matlab/common/mfiles/plotting/'),path);
    path(fullfile(socCodeRoot, '/matlab/common/mfiles/misc/'),path);
    % Add path to directory for process_K2_thruster_firing_data
    path(fullfile(socCodeRoot, '/matlab/common/mfiles/K2_thruster_firing/'),path);
    
    % add TIP
    path(fullfile(socCodeRoot, '/matlab/tip/mfiles/'),path);
    path(fullfile(socCodeRoot, '/matlab/tip/build/generated/mfiles/'),path);
    % begin PDC paths
    %   note: do not add /matlab/pdc/mfiles/legacy/ to path
    path(fullfile(socCodeRoot, '/matlab/pdc/mfiles/'),path);
    path(fullfile(socCodeRoot, '/matlab/pdc/mfiles/map/'),path);
    path(fullfile(socCodeRoot, '/matlab/pdc/mfiles/spsd/'),path);
    path(fullfile(socCodeRoot, '/matlab/pdc/mfiles/bandsplitting/'),path);
    path(fullfile(socCodeRoot, '/matlab/pdc/mfiles/input/'),path);
    path(fullfile(socCodeRoot, '/matlab/pdc/test/'),path);
    path(fullfile(socCodeRoot, '/matlab/pdc/tools/'),path);
    path(fullfile(socCodeRoot, '/matlab/pdc/mfiles/shortgapfill'),path);
    path(fullfile(socCodeRoot, '/matlab/pdc/mfiles/longgapfill'),path);
    path(fullfile(socCodeRoot, '/matlab/pdc/build/generated/mfiles/'),path);
    % end PDC paths
    path(fullfile(socCodeRoot, '/matlab/pa/common/mfiles/'),path);
    path(fullfile(socCodeRoot, '/matlab/pa/mfiles/'),path);
    path(fullfile(socCodeRoot, '/matlab/pa/mfiles/encircled_energy/'),path);
    path(fullfile(socCodeRoot, '/matlab/pa/mfiles/cosmic_ray/'),path);
    path(fullfile(socCodeRoot, '/matlab/pa/mfiles/image_modeling/'),path);
    path(fullfile(socCodeRoot, '/matlab/pa/build/generated/mfiles/'),path);
    path(fullfile(socCodeRoot, '/matlab/ppa/pad/mfiles/'),path);
    path(fullfile(socCodeRoot, '/matlab/ppa/pad/build/generated/mfiles/'),path);
    path(fullfile(socCodeRoot, '/matlab/ppa/pag/mfiles/'),path);
    path(fullfile(socCodeRoot, '/matlab/ppa/pag/build/generated/mfiles/'),path);
    path(fullfile(socCodeRoot, '/matlab/ppa/pmd/mfiles/'),path);
    path(fullfile(socCodeRoot, '/matlab/ppa/pmd/build/generated/mfiles/'),path);
    path(fullfile(socCodeRoot, '/matlab/debug/mfiles/'),path);
    path(fullfile(socCodeRoot, '/matlab/debug/build/generated/mfiles/'),path);
    path(fullfile(socCodeRoot, '/matlab/sggen/mfiles/'),path);
    path(fullfile(socCodeRoot, '/matlab/sggen/build/generated/mfiles/'),path);
    % Do not add /matlab/etem2/mfiles/ since you have to run etem from that
    % directory anyway. Not including this directory on the path also avoids
    % overriding pipeline functions with test code by accident.
    path(fullfile(socCodeRoot, '/matlab/etem2/mfiles/build/generated/mfiles/'),path);
    path(fullfile(socCodeRoot, '/matlab/ct/fpg/mfiles/'),path);
    path(fullfile(socCodeRoot, '/matlab/ct/fpg/mfiles/quasar/'),path);
    path(fullfile(socCodeRoot, '/matlab/ct/fpg/build/generated/mfiles/'),path);
    path(fullfile(socCodeRoot, '/matlab/ct/cbdt/mfiles/'),path);
    path(fullfile(socCodeRoot, '/matlab/ct/dg/mfiles/'),path);
    path(fullfile(socCodeRoot, '/matlab/ct/bart/mfiles/'),path);
    path(fullfile(socCodeRoot, '/matlab/tps/search/build/generated/mfiles/'),path);
    path(fullfile(socCodeRoot, '/matlab/tps/search/mfiles/'),path);
    path(fullfile(socCodeRoot, '/matlab/tps/search/build/mex/'),path);
    path(fullfile(socCodeRoot, '/matlab/tps/dawg/mfiles/'),path);
    path(fullfile(socCodeRoot, '/matlab/poof/mfiles'),path);
    path(fullfile(socCodeRoot, '/matlab/ct/tcat/mfiles/'),path);
    path(fullfile(socCodeRoot, '/matlab/ct/cdq/mfiles/'),path);
    path(fullfile(socCodeRoot, '/matlab/ct/lisa/mfiles/'),path);
    path(fullfile(socCodeRoot, '/matlab/dv/validate/mfiles/'),path);
    path(fullfile(socCodeRoot, '/matlab/dv/validate/mfiles/cotrending'),path);
    path(fullfile(socCodeRoot, '/matlab/dv/validate/mfiles/report'),path);
    path(fullfile(socCodeRoot, '/matlab/dv/validate/build/generated/mfiles/'),path);
    path(fullfile(socCodeRoot, '/matlab/dv/validate/build/mex'),path);
    path(fullfile(socCodeRoot, '/matlab/dv/dom/mfiles/'),path);
    path(fullfile(socCodeRoot, '/matlab/dynablack/mfiles/'),path);
    path(fullfile(socCodeRoot, '/matlab/dynablack/build/generated/mfiles/'),path);
% Needed for release 5 backwards compatibility.  Remove after release 5 is dead.
    path(fullfile(socCodeRoot, '/matlab/fc/mex/'),path);
    path(fullfile(socCodeRoot, '/matlab/tps/search/mex/'),path);

    % initialize log4j
    log4jConfigFile = ['file:' socCodeRoot '/dist/etc/log4j-matlab-interactive.xml'];
    disp(['Setting log4j configuration file to ' log4jConfigFile]);
    java.lang.System.setProperty('log4j.configuration', log4jConfigFile);
    clear log4jConfigFile;
    
    % Trailing slash required.
    java.lang.System.setProperty('log4j.logfile.prefix', fullfile(socCodeRoot, 'dist/logs/'));
    
%   get all standard SOC variables which are stored in environment variables 
    initialize_soc_variables ;
    
    disp(['Setting SOC Java path relative to ' socDistRoot]);
    initialize_soc_javapath( socDistRoot ) ;
    
    initialize_soc_variables( 'clear' ) ;

%   set backtrace back to its original state
    warning(backtraceState) ;
    clear backtraceState

  end; % if(~isdeployed || ismcc)
end; % if(isempty(socCodeRoot))

% don't leave it in the workspace
clear socCodeRoot ;



