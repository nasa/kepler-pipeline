function [kics outChars] = debug_retrieve_kics(varargin)
% [kics outChars] = debug_retrieve_kics(module, output, mjd, minKeplerMag, maxKeplerMag, 'get_chars')
% or 
% [kics outChars] = debug_retrieve_kics(module, output, mjd, minKeplerMag, maxKeplerMag)
% or 
% [kics outChars] = debug_retrieve_kics(module, output, mjd, 'get_chars')
% or 
% [kics outChars] = debug_retrieve_kics(module, output, mjd)
%
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

import gov.nasa.kepler.systest.sbt.SbtRetrieveKics;
import gov.nasa.kepler.systest.sbt.SbtRetrieveCharacteristics;

outChars = [];

matPath = '/tmp';
matChunkSize = 1000;


% Verify that a legal signature has been used:
%
if nargin < 3 || nargin > 6
    error('retrieve_kics: incorrect number of arguments');
end

% Parse out isGetChars from the final arg in the nargin==4 or ==6 case:
%
isGetChars = 0;
if nargin == 4 || nargin == 6
    lastArg = varargin{nargin};
    if strcmp('get_chars', lastArg)
        isGetChars = 1;
    else
        error('retrieve_kics: unsupported usecase-- get_chars was set to %s, not "get_chars"', lastArg);
    end
end

% Parse mod/out/mjd arguments:
%
module = varargin{1};
output = varargin{2};
mjd    = varargin{3};

% Convert MJD to season:
%
import gov.nasa.kepler.fc.rolltime.RollTimeOperations;
rtOps = RollTimeOperations();
season = rtOps.mjdToSeason(mjd);

if nargin < 5
    results = SbtRetrieveKics.retrieveKics(module, output, season, matPath, matChunkSize);
    characteristics = SbtRetrieveCharacteristics.retrieveCharacteristicMaps(module, output, season, matPath, matChunkSize);
else
    % get mag limits from the remaining vararg:
    %
    minKeplerMag = varargin{4};
    maxKeplerMag = varargin{5};
    results = SbtRetrieveKics.retrieveKics(module, output, season, minKeplerMag, maxKeplerMag, matPath, matChunkSize);
    characteristics = SbtRetrieveCharacteristics.retrieveCharacteristicMaps(module, output, season, minKeplerMag, maxKeplerMag, matPath, matChunkSize);
end

matFileArrayResults = results.matPaths.toArray();
kics = [];
chunkEnd = 0;
for i = 1:length(matFileArrayResults)
    matFile = [matPath filesep matFileArrayResults(i)];
    disp(['Loading: ' matFile]);

    s = load(matFile, 's');
    
    chunk = s.s.kics;
    chunkStart = chunkEnd + 1;
    chunkEnd = chunkStart + length(chunk) - 1;

    if(isempty(kics))
        kics = repmat(chunk(1),1,results.numKics);
    end;
    
    kics(1,chunkStart:chunkEnd) = chunk;
    
    disp('...DONE Loading .mat file');
end

matFileArrayChars = characteristics.matPaths.toArray();

outChars = repmat(struct('keplerId', [], 'types', [], 'values', []), 1, results.numKics);
iOutChars = 1;
for ifile = 1:length(matFileArrayChars)
    matFile = [matPath filesep matFileArrayChars(ifile)];
    disp(['Loading: ' matFile]);

    s = load(matFile, 's');
    
    keplerIds = [s.s.keplerIds.keplerIds];
    for ikeplerid = 1:length(keplerIds)
        istart = s.s.startIndices(ikeplerid).startIndices;
        iend   = s.s.endIndices(ikeplerid).endIndices;
        
        keplerId = keplerIds(ikeplerid);
        types  = {s.s.characteristicTypes{istart:iend}};
        values = [s.s.characteristicValues(istart:iend).characteristicValues];
        
        outChars(iOutChars).keplerId = keplerId;
        outChars(iOutChars).types = types;
        outChars(iOutChars).values = values;
        iOutChars = iOutChars + 1;
    end
    disp('...DONE Loading .mat file');
end
