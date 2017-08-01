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
import matlab.io.*

pulsedurs=[1.5;2.0;2.5;3.0;3.5;4.5;5.0;6.0;7.5;9.0;10.5;12.0;12.5;15.0];

fptr=fits.createFile(['!',outputWFfile]);
% Get the date
syscall='date +"%Y|%m|%d|%H|%M|%S"';
[jnk,gendate1]=system(syscall);
indx = find(gendate1==char(13) | gendate1==char(10) | gendate1==' ');
gendate1(indx) = [];
gendatestrs=strsplit(gendate1,'|');
usedate=sprintf('%4s-%2s-%2s',gendatestrs{1},gendatestrs{2},gendatestrs{3});

fits.createTbl(fptr,'binary',0,{'PERIOD','WINFUNC'},{'1E','1E'},{'Days','Fraction'});

% Start putting keywords in primary header
htype=fits.movAbsHDU(fptr,1);
fits.writeKey(fptr,'ORIGIN','NASA/Ames Kepler Project','created by');
fits.writeKey(fptr,'DATE',usedate,'file creation date');
fits.writeKey(fptr,'CREATOR','complete/Q17stats/tpsD3/maketpsqualityvectors','creation program');
fits.writeKey(fptr,'DATASRC','so-products-soc9.2/D.3-tps-sensitivity','input data source');
fits.writeKey(fptr,'FILEVER','1.0','file format version');
fits.writeKey(fptr,'TELESCOP','Kepler','telescope');
fits.writeKey(fptr,'INSTRUME','Kepler Photometer','detector type');
fits.writeKey(fptr,'OBJECT',sprintf('KIC %09d',currentKIC),'string version of KEPLERID');
fits.writeKey(fptr,'KEPLERID',int32(currentKIC),'unique Kepler target identifier'); 
fits.writeKey(fptr,'SOCVER','9.2','Kepler pipeline version');
fits.writeKey(fptr,'DATA_REL',24,'Data Release Number');
%fits.writeComment(fptr,'This file contains the D.3 Occurrence Rate Product for the window function.  The window function data specify the fraction of phase space that three transit events are observable as a function of orbital period.  There are 14 binary table extensions corresponding to the 14 transit durations searched for transits.  This file is relevant to the SOC 9.2 Kepler pipeline run, and generation of this file is tracked on the internal ticket KSO-299');

HDRCNT=2;
htype=fits.movAbsHDU(fptr,HDRCNT);
fits.writeKey(fptr,'TDUR',real(str2num(sprintf('%02.1f',pulsedurs(1)))),'transit duration in hrs');
pulsehr=fix(pulsedurs(1));
pulsefrac=fix((pulsedurs(1)-pulsehr)*10);
fits.writeKey(fptr,'EXTNAME',sprintf('DURATION%02d_%1d',pulsehr,pulsefrac),'extension name');
fits.writeCol(fptr,1,1,tpsqualityvectors{1}.periodSearchedWF);
fits.writeCol(fptr,2,1,tpsqualityvectors{1}.windowFunction);
for k=2:length(pulsedurs)
 fits.createTbl(fptr,'binary',0,{'PERIOD','WINFUNC'},{'1E','1E'},{'Days','Fraction'});
 fits.writeKey(fptr,'TDUR',real(str2num(sprintf('%02.1f',pulsedurs(k)))),'transit duration in hrs');
 pulsehr=fix(pulsedurs(k));
 pulsefrac=fix((pulsedurs(k)-pulsehr)*10);
 fits.writeKey(fptr,'EXTNAME',sprintf('DURATION%02d_%1d',pulsehr,pulsefrac),'extension name');
 fits.writeCol(fptr,1,1,tpsqualityvectors{k}.periodSearchedWF);
 fits.writeCol(fptr,2,1,tpsqualityvectors{k}.windowFunction);

end



fits.closeFile(fptr);

