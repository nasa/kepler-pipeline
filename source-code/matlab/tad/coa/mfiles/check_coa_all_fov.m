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
modules = [2:4 6:20 22:24];
blobLocation = '/path/to/ETEM_PSFs/all_blobs';
for m = 1:length(modules)
	module = modules(m);
	for output = 1:4
        startTime = '30-May-2012 17:29:36';

        kicData = retrieve_kics(module, output, datestr2mjd(startTime));
        nKicEntries = length(kicData);
        for i=1:nKicEntries
            if ~isempty(kicData(i).getKeplerMag())
                ra(i) = double(kicData(i).getRa());
                dec(i) = double(kicData(i).getDec());
                kicId(i) = double(kicData(i).getKeplerId());
                keplerMagnitude(i) = double(kicData(i).getKeplerMag());
            end
        end

%         nStars = length(kicId);
%         range = 1:nStars;
        nStars = 100;
        range = fix(length(kicId)*rand(nStars,1))+1;
        %%
        kicEntryDataStruct = struct('KICID', num2cell(kicId(range)), ...
            'RA', num2cell(ra(range)), 'dec', num2cell(dec(range)),...
            'magnitude', num2cell(single(keplerMagnitude(range))), ...
            'effectiveTemp', num2cell(single(5000*ones(size(kicId(range))))));

        % pick the brightest 2000 stars as targets
        targetIndex = find(([kicEntryDataStruct.magnitude] < 15) & ...
            ([kicEntryDataStruct.magnitude] >= 9));
        targetKeplerIDList = [kicEntryDataStruct(targetIndex).KICID]';

        pixelModelStruct.wellCapacity = 1.30E+06;
        pixelModelStruct.saturationSpillUpFraction = 0.50;
        pixelModelStruct.flux12 = 2.34E+05;
        pixelModelStruct.cadenceTime = 1.7997e+03;
        pixelModelStruct.integrationTime = 5.70845;
        % pixelModelStruct.transferTime = FcConstants.ccdReadTime;
        pixelModelStruct.transferTime = 0.51895;
        pixelModelStruct.exposuresPerCadence = 289;
        pixelModelStruct.parallelCTE = 0.9996;
        pixelModelStruct.serialCTE = 0.9996;
        % pixelModelStruct.readNoiseSquared = 25 * 25 * exp_per_long_cadence; % e-^2/long cadence
        % pixelModelStruct.quantizationNoiseSquared = ... % e-^2/long cadence
        %     ( well_capac / (2^num_bits-1))^2 / 12 * exp_per_long_cadence;
        pixelModelStruct.readNoiseSquared = 180625; % e-^2/long cadence
        pixelModelStruct.quantizationNoiseSquared = 1.5164e+05; % e-^2/long cadence

        coaConfigurationStruct.dvaMeshEdgeBuffer = -1; % how close to the edge of a CCD we compute the dva
        coaConfigurationStruct.dvaMeshOrder = 3; % order of the polynomial fit to dva mesh
        coaConfigurationStruct.nDvaMeshRows = 5; % size of the mesh on which to compute DVA
        coaConfigurationStruct.nDvaMeshCols = 5; % size of the mesh on which to compute DVA
        coaConfigurationStruct.nOutputBufferPix = 2; % # of pixels to allow off visible ccd
        coaConfigurationStruct.nStarImageRows = 21; % rows in each star image
        coaConfigurationStruct.nStarImageCols = 21; % columns in each star image
        coaConfigurationStruct.starChunkLength = 5000; % # of stars to process at a time
        coaConfigurationStruct.startTime = startTime;
        coaConfigurationStruct.duration = 1;
        coaConfigurationStruct.raOffset = 0;
        coaConfigurationStruct.decOffset = 0;
        coaConfigurationStruct.phiOffset = 0;

        % load the desired prf and turn it into a blob
        % p = load('/path/to/matlab/tad/coa/PRFpolys_z1f1_4.mat');
        % prfPolyStruct = p(1,1).polys;
        % coaParameterStruct.prfBlob = struct_to_blob(prfPolyStruct);

        % fid = fopen('/path/to/matlab/tad/coa/prfBlob_z1f1_4.dat');
        blobFilename = [blobLocation filesep sprintf('prf%02d%d-2008032321.dat', module, output)];
        disp(blobFilename);
        fid = fopen(blobFilename);

        coaParameterStruct.kicEntryDataStruct = kicEntryDataStruct;
        coaParameterStruct.targetKeplerIDList = targetKeplerIDList;
        coaParameterStruct.raDec2PixModel = retrieve_ra_dec_2_pix_model();
        coaParameterStruct.prfBlob = fread(fid, 'uint8');
        coaParameterStruct.pixelModelStruct = pixelModelStruct;
        coaParameterStruct.coaConfigurationStruct = coaConfigurationStruct;
        coaParameterStruct.module = module;
        coaParameterStruct.output = output;

        clear kicEntryDataStruct targetKeplerIDList kicData ra dec kicId keplerMagnitude

        coaParameterStruct.debugFlag = 0;

        coaResultStruct = coa_matlab_controller(coaParameterStruct);
        clear coaParameterStruct coaResultStruct
    end
end
