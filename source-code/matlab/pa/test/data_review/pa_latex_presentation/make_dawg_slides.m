function make_dawg_slides(quarter)
%
% Copyright 2017 United States Government as represented by the
% Administrator of the National Aeronautics and Space Administration.
% All Rights Reserved.
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

dataLocation = ['/path/to/dawg/q0-q17-r9.3-dawg/q' num2str(quarter) '/'];
disp(dataLocation);

season = mod(quarter + 2, 4);

load /path/to/false_positives/hires_catalog/latestCleanKic.mat;
load /path/to/steve_utilities/dateStruct.mat;
mjd = mean([dateStruct(quarter+2).startMjd, dateStruct(quarter+2).endMjd]);
% raDec2PixObject = raDec2PixClass(retrieve_ra_dec_2_pix_model(), 'zero-based');
load /path/to/quarter17_spring2013/raDec2PixModel_ops_20130205.mat
raDec2PixObject = raDec2PixClass(raDec2PixModel, 'zero-based');
if 1
%% make the quarterly definitions file
fid = fopen('report-definitions.sty', 'w');

fprintf(fid, '% Quarter of data being analysed\n');
fprintf(fid, '\\newcommand{\\quarter}{Q%d}\n', quarter);
fprintf(fid, '\n');
fprintf(fid, '% Pipeline software version\n');
fprintf(fid, '\\newcommand{\\swversion}{9.3}\n');
fprintf(fid, '\n');
fprintf(fid, '% Top directory for figures\n');
fprintf(fid, '\\newcommand{\\reportgraphicspath}{/path/to/dawg/q0-q17-r9.3-dawg/q%d/}\n', quarter);

fclose(fid);

%% make the LC flux slides

load([dataLocation 'lc_flux_analysis.mat'], 'S');

negativeFluxKepIds = [S.negativeFluxKeplerId];
negativeStars = negativeFluxKepIds(negativeFluxKepIds < 1e8);

fid = fopen('lcDynamicFluxSlides.tex', 'w');

fprintf(fid, '%%START SLIDE \n');
fprintf(fid, '\\cleardoublepage\n');
fprintf(fid, '\\begin{figure*}[h!]\n');
fprintf(fid, '  \\centering\n');
fprintf(fid, '  \\subfigure{\\includegraphics[width=1in]{\\logo}}\n');
fprintf(fid, '  \\hfill\n');
fprintf(fid, '  {\\Huge {\\bf \\quarter\\ LC Stellar Targets with Negative Flux}}\n');
fprintf(fid, '  \\hfill\n');
fprintf(fid, '  \\subfigure{\\includegraphics[angle=45,width=1in]{Kepler_spacecraft.png}}\n');
fprintf(fid, '\\end{figure*}\n');
fprintf(fid, '\\hrule\n');
fprintf(fid, '\n');

fprintf(fid, '\\vspace{15pt}\n');

if ~isempty(negativeStars)
    fprintf(fid, '\\begin{table}[h!]\n');
    fprintf(fid, '\\centering\n');
    fprintf(fid, '\\begin{tabular}[h!]{|r||c|c|c|c|}\n');

    fprintf(fid, '\\hline\n');

    fprintf(fid, 'KepId & Module & Output & Row & Column \\\\ \n');   
    fprintf(fid, '\\hline\n');
    for i=1:length(negativeStars)
        kicIdx = find(kic.kepid == negativeStars(i));
        [m o r c] = ra_dec_2_pix(raDec2PixObject, 15*kic.ra(kicIdx), ...
            kic.dec(kicIdx), mjd);
        fprintf(fid, '%d & %d & %d & %0.01f & %0.01f \\\\ \n', negativeStars(i), ...
            m, o, r, c);   
        fprintf(fid, '\\hline\n');
    end
    fprintf(fid, '\\end{tabular}\n');

    fprintf(fid, '\\end{table}\n');

    fprintf(fid, '\n');
    fprintf(fid, '\n');
    fprintf(fid, '\n');
else
    fprintf(fid, 'There are no stars with negative flux\n');
end

for i=1:length(negativeFluxKepIds)
    fprintf(fid, '%%START SLIDE \n');
    fprintf(fid, '\\cleardoublepage\n');
    fprintf(fid, '\\begin{figure*}[h!]\n');
    fprintf(fid, '  \\centering\n');
    fprintf(fid, '  \\subfigure{\\includegraphics[width=1in]{\\logo}}\n');
    fprintf(fid, '  \\hfill\n');
    fprintf(fid, '  {\\Huge {\\bf \\quarter\\ LC Target with Negative Flux}}\n');
    fprintf(fid, '  \\hfill\n');
    fprintf(fid, '  \\subfigure{\\includegraphics[angle=45,width=1in]{Kepler_spacecraft.png}}\n');
    fprintf(fid, '\\end{figure*}\n');
    fprintf(fid, '\\hrule\n');
    fprintf(fid, '\n');


    fprintf(fid, '\\begin{figure*}[h!]\n');
    fprintf(fid, '  \\centering\n');
    fprintf(fid, '  \\includegraphics[width=0.7\\textwidth]{flux_figures/lc/negative_flux_%d.png}\n', negativeFluxKepIds(i));
    fprintf(fid, '\\end{figure*}\n');

    fprintf(fid, '%% END SLIDE \n');
end
fclose(fid);

%% Make the LC centroid slides

centroidDir = [dataLocation 'centroid_figures/lc/'];
dirStruct = dir([centroidDir 'large_chatter_m*.png']);

fid = fopen('lcDynamicCentroidSlides.tex', 'w');

for i=1:length(dirStruct)
    fprintf(fid, '%%START SLIDE \n');
    fprintf(fid, '\\cleardoublepage\n');
    fprintf(fid, '\\begin{figure*}[h!]\n');
    fprintf(fid, '  \\centering\n');
    fprintf(fid, '  \\subfigure{\\includegraphics[width=1in]{\\logo}}\n');
    fprintf(fid, '  \\hfill\n');
    fprintf(fid, '  {\\Huge {\\bf \\quarter\\ Chattering PRF Channel}}\n');
    fprintf(fid, '  \\hfill\n');
    fprintf(fid, '  \\subfigure{\\includegraphics[angle=45,width=1in]{Kepler_spacecraft.png}}\n');
    fprintf(fid, '\\end{figure*}\n');
    fprintf(fid, '\\hrule\n');
    fprintf(fid, '\n');


    fprintf(fid, '\\begin{figure*}[h!]\n');
    fprintf(fid, '  \\centering\n');
    fprintf(fid, '  \\includegraphics[width=0.7\\textwidth]{centroid_figures/lc/%s}\n', dirStruct(i).name);
    fprintf(fid, '\\end{figure*}\n');

    fprintf(fid, '%% END SLIDE \n');
end
end
if 0
%% Make the SC flux slides

%% make the quarterly definitions file
fid = fopen('report-definitions.sty', 'w');

fprintf(fid, '% Quarter of short cadence data being analysed\n');
fprintf(fid, '\\newcommand{\\quarter}{Q%d}\n', quarter);
fprintf(fid, '\n');
fprintf(fid, '% Pipeline software version\n');
fprintf(fid, '\\newcommand{\\swversion}{9.2}\n');
fprintf(fid, '\n');
fprintf(fid, '% Top directory for figures\n');
fprintf(fid, '\\newcommand{\\reportgraphicspath}{/path/to/pa/q0-q17-r9.2-dawg/q%d/}\n', quarter);

fclose(fid);

fid = fopen('scDynamicFluxSlides.tex', 'w');

nMonths = [1 1 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 2];

for month=1:nMonths(quarter+1) % two months in Q17
    load([dataLocation 'sc_m' num2str(month) '_flux_analysis.mat'], 'S');

    negativeFluxKepIds = unique([S.negativeFluxKeplerId]);
    negativeStars = negativeFluxKepIds(negativeFluxKepIds < 1e8);
	if length(negativeFluxKepIds) == 0
		continue;
	end

    fprintf(fid, '%%START SLIDE \n');
    fprintf(fid, '\\cleardoublepage\n');
    fprintf(fid, '\\begin{figure*}[h!]\n');
    fprintf(fid, '  \\centering\n');
    fprintf(fid, '  \\subfigure{\\includegraphics[width=1in]{\\logo}}\n');
    fprintf(fid, '  \\hfill\n');
    fprintf(fid, '  {\\Huge {\\bf \\quarter\\ SC M%d Stellar Targets with Negative Flux}}\n', month);
    fprintf(fid, '  \\hfill\n');
    fprintf(fid, '  \\subfigure{\\includegraphics[angle=45,width=1in]{Kepler_spacecraft.png}}\n');
    fprintf(fid, '\\end{figure*}\n');
    fprintf(fid, '\\hrule\n');
    fprintf(fid, '\n');

	if length(negativeStars) > 0
    	fprintf(fid, '\\vspace{15pt}\n');
    	fprintf(fid, '\\begin{table}[h!]\n');
    	fprintf(fid, '\\centering\n');
    	fprintf(fid, '\\begin{tabular}[h!]{|r||c|c|c|c|}\n');

    	fprintf(fid, '\\hline\n');

    	fprintf(fid, 'KepId & Module & Output & Row & Column \\\\ \n');   
    	fprintf(fid, '\\hline\n');
    	for i=1:length(negativeStars)
        	kicIdx = find(kic.kepid == negativeStars(i));
        	[m o r c] = ra_dec_2_pix(raDec2PixObject, 15*kic.ra(kicIdx), ...
            	kic.dec(kicIdx), mjd);
        	fprintf(fid, '%d & %d & %d & %0.01f & %0.01f \\\\ \n', negativeStars(i), ...
            	m, o, r, c);   
        	fprintf(fid, '\\hline\n');
    	end
    	fprintf(fid, '\\end{tabular}\n');

    	fprintf(fid, '\\end{table}\n');

    	fprintf(fid, '\n');
    	fprintf(fid, '\n');
    	fprintf(fid, '\n');
	end

    for i=1:length(negativeFluxKepIds)
        fprintf(fid, '%%START SLIDE \n');
        fprintf(fid, '\\cleardoublepage\n');
        fprintf(fid, '\\begin{figure*}[h!]\n');
        fprintf(fid, '  \\centering\n');
        fprintf(fid, '  \\subfigure{\\includegraphics[width=1in]{\\logo}}\n');
        fprintf(fid, '  \\hfill\n');
        fprintf(fid, '  {\\Huge {\\bf \\quarter\\ SC M%d Target with Negative Flux}}\n', month);
        fprintf(fid, '  \\hfill\n');
        fprintf(fid, '  \\subfigure{\\includegraphics[angle=45,width=1in]{Kepler_spacecraft.png}}\n');
        fprintf(fid, '\\end{figure*}\n');
        fprintf(fid, '\\hrule\n');
        fprintf(fid, '\n');


        fprintf(fid, '\\begin{figure*}[h!]\n');
        fprintf(fid, '  \\centering\n');
        fprintf(fid, '  \\includegraphics[width=0.7\\textwidth]{flux_figures/sc_m%d/negative_flux_%d.png}\n', month, negativeFluxKepIds(i));
        fprintf(fid, '\\end{figure*}\n');

        fprintf(fid, '%% END SLIDE \n');
    end
end
fclose(fid);
end
quit
