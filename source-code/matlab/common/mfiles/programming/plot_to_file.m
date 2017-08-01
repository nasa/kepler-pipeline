function plot_to_file(fileNameStr, paperOrientationFlag, includeTimeFlag, printJpgFlag)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function plot_to_file(fileNameStr, paperOrientationFlag)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% http://www.mathworks.com/support/bugreports/details.html?rp=365144
% Summary  	   	Segmentation violation when exporting a figure on a Unix/Linux Machine
% Report ID 	  	365144
% Date Last Modified 	  	21 Sep 2007
% Current Product Name 	  	MATLAB
% Previous Product Name(s) 	  	MATLAB�
% Exists In Version 	  	7.6, 7.5, 7.4, 7.3, 7.2, 7.1
% Exists In Release 	  	R2008a, R2007b, R2007a, R2006b, R2006a, R14SP3
% Fixed In Version 	  	OPEN
% Fixed In Release 	  	OPEN
%
% Summary
%
% Segmentation violation when exporting a figure on a Unix/Linux Machine
% Description
%
% A segmentation violation occurs when printing a figure with a large number of lines to a vector format, for  example, when exporting this plot:
%
%     SIZE=100000;
%     x(SIZE)=0;
%     y(SIZE)=0;
%     h=figure;
%     hold on;
%     for a=1:25
%         for b=1:SIZE
%             x(1,b)=b;
%             y(1,b)=a+b;
%         end
%         plot(x,y,'r*');
%     end
%     hold off;
%    print -dps test.ps;
%
% Workaround
%
% Use another renderer when printing, for example z-buffer.
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


% Printing and Exporting without a Display
%
%
% On a UNIX platform (including Macintosh), where you can start MATLAB in
% nodisplay mode (matlab -nodisplay), you can print using most of the
% drivers you can use with a display and export to most of the same file
% formats. The PostScript and Ghostscript devices all function in nodisplay
% mode on UNIX. The graphic devices -djpeg, -dpng, -dtiff (compressed TIFF
% bitmaps) and -tiff (EPS with TIFF preview) work as well, but under
% nodisplay they use Ghostscript to generate output instead of using the
% drivers built into MATLAB. However, Ghostscript ignores the -r option
% when generating -djpeg, -dpng, -dtiff and -tiff image files. This means
% that you cannot vary the resolution of image files when running in
% nodisplay mode.
% To ensure that the printed output matches what you see on the screen,
% print using the -zbuffer option. To obtain higher resolution (for
% example, to make text look better), use the -r option to increase the
% resolution. There is, however, a tradeoff between the resolution and the
% size of the created PostScript file, which can be quite large at higher
% resolutions. The default resolution of 150 dpi generally produces good
% results.
% You can reduce the size of the output file by making the figure smaller
% before printing it and setting the figure PaperPositionMode to auto, or
% by just setting the PaperPosition property to a smaller size.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

if(~exist('paperOrientationFlag', 'var'))
    paperOrientationFlag = false;
end

if(~exist('includeTimeFlag', 'var'))
    includeTimeFlag = false;
end

if(~exist('printJpgFlag', 'var'))
    printJpgFlag = false;
end



fileNameStr = strrep(fileNameStr, '-', '_');
fileNameStr = strrep(fileNameStr, ':', '_');
fileNameStr = strrep(fileNameStr, ' + ', '_');
fileNameStr = strrep(fileNameStr, ' = ', '_');
fileNameStr = strrep(fileNameStr, '  ', ' ');
fileNameStr = strrep(fileNameStr, ' ', '_');

if(includeTimeFlag)

    dateString = datestr(now);
    dateString = strrep(dateString, '-', '_');
    dateString = strrep(dateString, ' ', '_');
    dateString = strrep(dateString, ':', '_');

    fileName = [fileNameStr '_' dateString '.jpg'];
    figFileName = [fileNameStr '_' dateString '.fig'];

else

    fileName = [fileNameStr '.jpg'];
    figFileName = [fileNameStr '.fig'];

end


if(printJpgFlag)

    set(gcf, 'PaperPositionMode', 'manual');
    set(gcf, 'PaperUnits', 'inches');

    set(gcf, 'PaperPosition',[0 0 8.5 11]);

    if(paperOrientationFlag)
        set(gcf, 'PaperPosition',[0 0 11 8.5]);
    end

    %     fprintf('\n\nSaving the plot to a file named %s \n', fileName);
    %     fprintf('Please wait....\n\n');

    print('-djpeg', '-zbuffer', fileName);

end


saveas(gcf, figFileName);

return

