function [module,output,channel,skygroup]=get_mod_out_channel_skygroup(keplerId, kepIdmapFileStruct)

% function [module,output,channel,skygroup]=get_mod_out_channel_skygroup(keplerId, kepIdmapFileStruct)
% author - Anima Sabale
%
% This function takes as input a keplerid and file name of a mapping file
% and returns the asociated module, output, channel and skygroup.
% 
% Input Arguments:
%   keplerId            (integer) The Kepler ID of a target (For K2, the term Kepler ID 
%                       is equavilant to EPIC ID)
%   kepIdmapFileStruct        (string) The full path to a *.mat file containing
%                       the mapping of Kepler ID to module, output,
%                       channel, skygroup. This *.mat file will be generate
%                       by SOC-OPS at the end of Target Management for each
%                       Campaign. 
%                       Ex:
%                       /path/to/c0/tad/c0_march2014/trimmed_v2/extract_tad_data/c0_march2014_trimmed_v2_modOutChnlSG_map.mat
% Output Arguments:
%   module              (integer) The module number for the Kepler ID supplied
%   output              (integer) The output number for the Kepler ID supplied
%   channel             (integer) The channel number for the Kepler ID supplied
%   skygroup            (integer) The skygroup number for the Kepler ID supplied
%   
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

module=0;
output=0;
channel=0;
skygroup=0;

mapFileStruct=load(kepIdmapFileStruct);

for iCounter=1:length(mapFileStruct.kepidModOutStruct)
    if keplerId == mapFileStruct.kepidModOutStruct(iCounter).kepid;
        module = mapFileStruct.kepidModOutStruct(iCounter).mod;
        output = mapFileStruct.kepidModOutStruct(iCounter).out;
        channel = mapFileStruct.kepidModOutStruct(iCounter).channel;
        skygroup = mapFileStruct.kepidModOutStruct(iCounter).skygroup;
        fprintf('KepID: %10i\n Module:%2i \n Output: %2i\n Channel: %2i \n SkyGroup: %2i \n', keplerId, module, output, channel, skygroup);
        continue
    end
end
   
return
