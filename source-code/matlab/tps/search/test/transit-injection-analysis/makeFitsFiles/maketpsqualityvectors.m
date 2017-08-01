% maketpsqualityvectors.m 
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

% go through directories and make window functions and one sigma depth functions from tps inject outputs
% headdir='/path/to/so-products-soc9.2/D.3-tps-sensitivity/tps-matlab-2015075';
% outputdir='/path/to/so-products-soc9.2/D.3-tps-sensitivity';

% Note: in order to run this to completion I had to do two things:
% (1) run under later version MATLAB 2013b, which knows how to 'import
% matlab.io.*'
% (2) comment out the lines involving 'randStreamStruct' in
% /path/to/matlab/validate_tps_input_structure.m

% Initialize
close all

% Directory containing this code
baseDir = '/path/to/matlab/tps/search/test/transit-injection-analysis/makeFitsFiles/';
addpath '/path/to/matlab/tps/search/test/transit-injection-analysis/';
addpath '/path/to/matlab/tps/search/mfiles/';
addpath '/path/to/matlab/common/mfiles/programming/';

% Get groupLabel, assign headdir name
groupLabel = input('Group label, eg. KSOC-5004-1-run2, or KSOC-5004-2 -- ','s');
[headdir, ~] = get_top_dir(groupLabel);

% Make MATLAB and FITS directories
outputdir='/codesaver/work/transit_injection/diagnostics/';
matlabDir = strcat(outputdir,groupLabel,'/MATLAB');
fitsDir = strcat(outputdir,groupLabel,'/FITS');
mkdir(matlabDir);
mkdir(fitsDir);

% Set prefixes
outputprefix='tpsqualitydata';
outputWFprefix='kplr';
outputOSDprefix='kplr';

% Parse headdir string
parsed=textscan(headdir,'%s','delimiter','/');
workdirprefix=parsed{1};
workdirprefix=workdirprefix{end};

% Get list of subdirs
headdirlist=dir(fullfile(headdir,sprintf('%s-*',workdirprefix)));

% Pulse durations
pulsedurs=[1.5;2.0;2.5;3.0;3.5;4.5;5.0;6.0;7.5;9.0;10.5;12.0;12.5;15.0];

% Loop over head task directories and find the st-# directories
for i=1:length(headdirlist)
    fprintf('Starting on task directory %s\n',headdirlist(i).name)
    stdirlist=dir(fullfile(headdir,headdirlist(i).name,'st-*'));
    
    % Loop over st- subtask directories
    for j=1:length(stdirlist)
        diagfile=fullfile(headdir,headdirlist(i).name,stdirlist(j).name,'tps-diagnostic-struct.mat');
        tpsinputfile=fullfile(headdir,headdirlist(i).name,stdirlist(j).name,'tps-inputs-0.mat');
        
        % Find -st directories that contain tps-diagnostic-struct.mat files
        if (exist(diagfile,'file') && exist(tpsinputfile,'file'))
            
            % Begin making tps quality vectors for this target
            load(diagfile);
            load(tpsinputfile);
            clear 'tpsqualityvectors';
            currentKIC=inputsStruct.tpsTargets.keplerId;
            sprintf('Starting on target %s %09d',stdirlist(j).name,currentKIC)
            inputsStruct = tps_convert_91_data_to_92( inputsStruct ) ;
            inputsStruct = tps_convert_92_data_to_93( inputsStruct ) ;
            inputsStruct = validate_tps_input_structure( inputsStruct );
            
            % Loop over pulse durations, make and accumulate Window Function and One-Sigma
            % Depth Functions
            for usepulseidx=1:14
                
                % Do window function
                possiblePeriodsInCadences=tpsDiagnosticStruct(usepulseidx).periodsWindowFunction;
                %%%% TPS gives results in high resolution x3 cadences***
                possiblePeriodsInCadences=possiblePeriodsInCadences./3.0;
                possiblePeriodsInDays=possiblePeriodsInCadences./inputsStruct.tpsModuleParameters.cadencesPerDay;
                tpsqualityvectors{usepulseidx}.periodSearchedWF=possiblePeriodsInDays;
                tpsqualityvectors{usepulseidx}.windowFunction=tpsDiagnosticStruct(usepulseidx).windowFunction;
                % if there is a single block of contiguous low values clip it out
                idxzero=find(tpsDiagnosticStruct(usepulseidx).windowFunction <= 1.0e-4);
                diffidx=diff(idxzero);
                brklocs=find(diffidx > 4);
                didclip=0;
                if (isempty(brklocs) && length(idxzero) ~= length(tpsDiagnosticStruct(usepulseidx).windowFunction))
                    didclip=1;
                    tpsqualityvectors{usepulseidx}.periodSearchedWF(idxzero)=[];
                    tpsqualityvectors{usepulseidx}.windowFunction(idxzero)=[];
                end
                if (isempty(brklocs) && length(idxzero) == length(tpsDiagnosticStruct(usepulseidx).windowFunction)) % trying to remove entire vector
                    didclip=1;
                    idxzero=idxzero(2:end-1);
                    tpsqualityvectors{usepulseidx}.periodSearchedWF(idxzero)=[];
                    tpsqualityvectors{usepulseidx}.windowFunction(idxzero)=[];
                    
                end
                MAXGDPER=max(tpsqualityvectors{usepulseidx}.periodSearchedWF);
                
                % Do planet-less one sigma depth function
                if (isempty(tpsDiagnosticStruct(usepulseidx).decimationFactorMeanMesFull))
                    tpsqualityvectors{usepulseidx}.periodSearchedOSD=possiblePeriodsInDays;
                    tpsqualityvectors{usepulseidx}.oneSigmaDepthFunction=1.0e6./tpsDiagnosticStruct(usepulseidx).meanMes;
                    
                    tpsqualityvectors{usepulseidx}.periodSearchedResidualOSD=[];
                    tpsqualityvectors{usepulseidx}.residualOSDFunction=[];
                    if (didclip ==1)
                        tpsqualityvectors{usepulseidx}.periodSearchedOSD(idxzero)=[];
                        tpsqualityvectors{usepulseidx}.oneSigmaDepthFunction(idxzero)=[];
                    end
                    
                else
                    
                    possiblePeriodsInCadences=tpsDiagnosticStruct(usepulseidx).periodsMeanMesFull;
                    possiblePeriodsInCadences=possiblePeriodsInCadences./3.0;
                    possiblePeriodsInDays=possiblePeriodsInCadences./inputsStruct.tpsModuleParameters.cadencesPerDay;
                    tpsqualityvectors{usepulseidx}.periodSearchedOSD=possiblePeriodsInDays;
                    tpsqualityvectors{usepulseidx}.oneSigmaDepthFunction=1.0e6./tpsDiagnosticStruct(usepulseidx).meanMesFull;
                    idxzero=find(tpsqualityvectors{usepulseidx}.periodSearchedOSD > MAXGDPER);
                    tpsqualityvectors{usepulseidx}.periodSearchedOSD(idxzero)=[];
                    tpsqualityvectors{usepulseidx}.oneSigmaDepthFunction(idxzero)=[];
                    
                    possiblePeriodsInCadences=tpsDiagnosticStruct(usepulseidx).periodsMeanMes;
                    possiblePeriodsInCadences=possiblePeriodsInCadences./3.0;
                    possiblePeriodsInDays=possiblePeriodsInCadences./inputsStruct.tpsModuleParameters.cadencesPerDay;
                    tpsqualityvectors{usepulseidx}.periodSearchedResidualOSD=possiblePeriodsInDays;
                    tpsqualityvectors{usepulseidx}.residualOSDFunction=1.0e6./tpsDiagnosticStruct(usepulseidx).meanMes;
                    
                end
                
            end % loop over pulse durations
            
            % Save the MATLAB and FITS files
            
            % Save matlab version
            outputfile=fullfile(matlabDir,sprintf('%s_%09d',outputprefix,currentKIC));
            save(outputfile,'tpsqualityvectors','currentKIC');
            
            % Save window function fits file
            outputWFfile=fullfile(fitsDir,sprintf('%s%09d_dr24_window.fits',outputWFprefix,currentKIC));
            genWFfits
            
            % Save one sigma depth fits file
            outputOSDfile=fullfile(fitsDir,sprintf('%s%09d_dr24_onesigdepth.fits',outputOSDprefix,currentKIC));
            genOSDfits
            
        end % -st directories that contain diagnostic structs
        
    end % Loop over subtask directories
    
end % Loop over directories under top directory

