function update_diagnostic_plot_userdata(dvDataObject, dvResultsStruct, iTarget, iPlanet, oddEvenFlag)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function update_diagnostic_plot_userdata(dvDataObject, dvResultsStruct, iTarget, iPlanet, oddEvenFlag)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Add the message whether the fit completed with full/secondary convergence or failed to the captions of 
% the fit diagnostic plots
%
% Version date:  2012-October-30.
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
%    2012-October-30, JL:
%        Initial release.
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

keplerId               = dvDataObject.targetStruct(iTarget).keplerId;
dvFiguresRootDirectory = dvResultsStruct.targetResultsStruct(iTarget).dvFiguresRootDirectory;

% retrieve the file names of teh fit diagnostic plots
if oddEvenFlag == 0
    oddEvenDir = 'all-transits-fit';
    oddEvenStr = 'All transits fit';
    fitStruct  = dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).allTransitsFit;
else
    oddEvenDir = 'odd-even-transits-fit';
    oddEvenStr = 'Odd-even transits fit';
    fitStruct  = dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).oddTransitsFit;
end
planetDir  = ['planet-' num2str(iPlanet,'%02d')];
pathName   = fullfile(dvFiguresRootDirectory, planetDir, 'planet-search-and-model-fitting-results', oddEvenDir);
dirStructs = dir(pathName);

% set the message whether the fit completed with full/secondary convergence or failed
if fitStruct.modelChiSquare==-1
    convergeStr = [oddEvenStr ' failed.'];
elseif fitStruct.fullConvergence
    convergeStr = [oddEvenStr ' completed with full convergence.'];
else
    convergeStr = [oddEvenStr ' completed with secondary convergence.'];
end

% update the captions of the fit diagnostic plots
if ~isempty(dirStructs)
    
    for i=1:length(dirStructs)
        
        dirName = dirStructs(i).name;
        if ~isempty(strfind(dirName, '.fig')) && ...
               ( ~isempty(strfind(dirName, '-whitened')) || ( ~isempty(strfind(dirName, '-unwhitened')) && isempty(strfind(dirName, '-zoomed')) ) )
            fullFigureName = fullfile(pathName, dirName);
            hFig = open(fullFigureName);
            userData = get(hFig, 'UserData');
            userData = [ userData ' ' convergeStr ];
            set(hFig, 'UserData', userData);
            saveas(hFig, fullFigureName, 'fig');
            close(hFig);
        end
        
    end
    
end

return


