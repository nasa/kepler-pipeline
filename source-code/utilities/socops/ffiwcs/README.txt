Copyright 2017 United States Government as represented by the
Administrator of the National Aeronautics and Space Administration.
All Rights Reserved.

This file is available under the terms of the NASA Open Source Agreement
(NOSA). You should have received a copy of this agreement with the
Kepler source code; see the file NASA-OPEN-SOURCE-AGREEMENT.doc.

No Warranty: THE SUBJECT SOFTWARE IS PROVIDED "AS IS" WITHOUT ANY
WARRANTY OF ANY KIND, EITHER EXPRESSED, IMPLIED, OR STATUTORY,
INCLUDING, BUT NOT LIMITED TO, ANY WARRANTY THAT THE SUBJECT SOFTWARE
WILL CONFORM TO SPECIFICATIONS, ANY IMPLIED WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR FREEDOM FROM
INFRINGEMENT, ANY WARRANTY THAT THE SUBJECT SOFTWARE WILL BE ERROR
FREE, OR ANY WARRANTY THAT DOCUMENTATION, IF PROVIDED, WILL CONFORM
TO THE SUBJECT SOFTWARE. THIS AGREEMENT DOES NOT, IN ANY MANNER,
CONSTITUTE AN ENDORSEMENT BY GOVERNMENT AGENCY OR ANY PRIOR RECIPIENT
OF ANY RESULTS, RESULTING DESIGNS, HARDWARE, SOFTWARE PRODUCTS OR ANY
OTHER APPLICATIONS RESULTING FROM USE OF THE SUBJECT SOFTWARE.
FURTHER, GOVERNMENT AGENCY DISCLAIMS ALL WARRANTIES AND LIABILITIES
REGARDING THIRD-PARTY SOFTWARE, IF PRESENT IN THE ORIGINAL SOFTWARE,
AND DISTRIBUTES IT "AS IS."

Waiver and Indemnity: RECIPIENT AGREES TO WAIVE ANY AND ALL CLAIMS
AGAINST THE UNITED STATES GOVERNMENT, ITS CONTRACTORS AND
SUBCONTRACTORS, AS WELL AS ANY PRIOR RECIPIENT. IF RECIPIENT'S USE OF
THE SUBJECT SOFTWARE RESULTS IN ANY LIABILITIES, DEMANDS, DAMAGES,
EXPENSES OR LOSSES ARISING FROM SUCH USE, INCLUDING ANY DAMAGES FROM
PRODUCTS BASED ON, OR RESULTING FROM, RECIPIENT'S USE OF THE SUBJECT
SOFTWARE, RECIPIENT SHALL INDEMNIFY AND HOLD HARMLESS THE UNITED
STATES GOVERNMENT, ITS CONTRACTORS AND SUBCONTRACTORS, AS WELL AS ANY
PRIOR RECIPIENT, TO THE EXTENT PERMITTED BY LAW. RECIPIENT'S SOLE
REMEDY FOR ANY SUCH MATTER SHALL BE THE IMMEDIATE, UNILATERAL
TERMINATION OF THIS AGREEMENT.

The delivery contains this readme file, a python script and four data files. Each data file contains the WCS information for a specific spacecraft roll orientation. The data files must be kept in the same folder as the python script and the python script must be executed from the file directory/folder containing the script. The FFI FITS file need not reside within the same folder.

README					This file
UpdateWCSinFFI.py			The python script
UpdateWCSinFFI_data_season0.txt		The WCS data for quarters 2,6,10É
UpdateWCSinFFI_data_season1.txt		The WCS data for quarters 3,7,11É
UpdateWCSinFFI_data_season2.txt		The WCS data for quarters 4,8,12É
UpdateWCSinFFI_data_season3.txt		The WCS data for quarters 0,1,5,9É

Before running the python script it must be made executable. From the shell type: chmod 755 UpdateWCSinFFI.py.

After the calibration of each FFI, perform the following shell command from the folder containing the python script and WCS data, e.g.:
UpdateWCSinFFI.py --ffifile=kplr2010174164113_ffi-cal.fits --quarter=5

--ffifile is the name and path of the FFI file
--quarter is the numeric description of the S/C quarter; an integer >= 0.

This procedure will overwrite the FFI file. It is advisable to make a copy of the FFI file before execution.

The procedure will overwrite or create new WCS keywords for each channel image within the FFI FITS file. It will also add QUARTER and SEASON keywords to the primary header extension.

If the file is named kplr2009170043915_ffi-cal.fits or kplr2009170043915_ffi-uncert.fits this file is the Q2 M1 FFI. There is a problem calibrating the WCS for this file.
The solution is to manually force an offset between the pointing values in the WCS file and that applied to the FFI header.

This readme can also be obtained by calling UpdateWCSinFFI.py --help from the shell.
