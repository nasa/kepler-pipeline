function [] = convert_report_summaries_to_pdf(pdfDir, instanceDir)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [] = convert_report_summaries_to_pdf(pdfDir, instanceDir)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Function to loop through all task/sub-task directories and convert
% one-page DV report summary fig files to PDF. The pdfDir must be
% specified and the PDF's will all be written there. The instanceDir may
% optionally be specified to point to the master instance directory of DV
% tasks; if it is not specified then the current working directory is
% assumed be the master instance directory. Directories may be absolute or
% relative (I think/hope).
%
% Suboptimal and slow. It ought to be possible to do this reasonably well
% in the pipeline even in nodisplay mode. This can be revisited post-8.2.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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

timeString = local_time_to_utc(now, 'yyyymmddHHMMSS');
timeString(end) = [];

baseDir = pwd();

if ~exist(pdfDir, 'dir')
    error('PDF directory (%s) does not exist', pdfDir);
end % if
cd(pdfDir);
pdfDir = pwd();
cd(baseDir);

if exist('instanceDir', 'var')
    if exist(instanceDir, 'dir')
        cd(instanceDir);
    end % if
end % if
instanceDir = pwd();

d = dir('dv-matlab-*');

for name1 = {d.name}
    
    name = char(name1);
    disp(name);
    cd(name);
    taskDir = pwd();
    
    s = dir('st-*');
    
    for name2 = {s.name}
        
        name = char(name2);
        disp(name);
        cd(name);
        subTaskDir = pwd();
    
        t = dir('target-*');
        
        for name3 = {t.name}
            
            name = char(name3);
            disp(name);
            cd(name);
            [~, remain] = strtok(name, '-');
            remain(1) = [];
            keplerId = str2double(remain);
            targetDir = pwd();
            
            p = dir('planet-*');
        
            for name4 = {p.name}

                name = char(name4);
                disp(name);
                cd(name);
                [~, remain] = strtok(name, '-');
                remain(1) = [];
                iPlanet = str2double(remain);
                planetDir = pwd();
                
                figureName = fullfile(planetDir, 'report-summary', ...
                    sprintf('%09d-%02d-report-summary-plot.fig', ...
                    keplerId, iPlanet));
                pdfName = fullfile(pdfDir, ...
                    sprintf('kplr%09d-%02d-%s_dvs.pdf', ...
                    keplerId, iPlanet, timeString));
                if exist(figureName, 'file')
                    openfig(figureName);
                    orient landscape
                    set(gcf, 'Renderer', 'painters');
                    set(gcf, 'RendererMode', 'manual');
                    print('-dpdf', '-r75', pdfName);
                    close(gcf);
                end % if
                
                cd (targetDir);
                
            end % for name4
        
            cd(subTaskDir);
            
        end % for name3
        
        cd(taskDir);
        
    end % for name2
    
    cd(instanceDir);
    
end % for name1

cd(baseDir);

return
