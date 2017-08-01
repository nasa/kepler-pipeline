/*
 * Copyright 2017 United States Government as represented by the
 * Administrator of the National Aeronautics and Space Administration.
 * All Rights Reserved.
 * 
 * This file is available under the terms of the NASA Open Source Agreement
 * (NOSA). You should have received a copy of this agreement with the
 * Kepler source code; see the file NASA-OPEN-SOURCE-AGREEMENT.doc.
 * 
 * No Warranty: THE SUBJECT SOFTWARE IS PROVIDED "AS IS" WITHOUT ANY
 * WARRANTY OF ANY KIND, EITHER EXPRESSED, IMPLIED, OR STATUTORY,
 * INCLUDING, BUT NOT LIMITED TO, ANY WARRANTY THAT THE SUBJECT SOFTWARE
 * WILL CONFORM TO SPECIFICATIONS, ANY IMPLIED WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR FREEDOM FROM
 * INFRINGEMENT, ANY WARRANTY THAT THE SUBJECT SOFTWARE WILL BE ERROR
 * FREE, OR ANY WARRANTY THAT DOCUMENTATION, IF PROVIDED, WILL CONFORM
 * TO THE SUBJECT SOFTWARE. THIS AGREEMENT DOES NOT, IN ANY MANNER,
 * CONSTITUTE AN ENDORSEMENT BY GOVERNMENT AGENCY OR ANY PRIOR RECIPIENT
 * OF ANY RESULTS, RESULTING DESIGNS, HARDWARE, SOFTWARE PRODUCTS OR ANY
 * OTHER APPLICATIONS RESULTING FROM USE OF THE SUBJECT SOFTWARE.
 * FURTHER, GOVERNMENT AGENCY DISCLAIMS ALL WARRANTIES AND LIABILITIES
 * REGARDING THIRD-PARTY SOFTWARE, IF PRESENT IN THE ORIGINAL SOFTWARE,
 * AND DISTRIBUTES IT "AS IS."
 * 
 * Waiver and Indemnity: RECIPIENT AGREES TO WAIVE ANY AND ALL CLAIMS
 * AGAINST THE UNITED STATES GOVERNMENT, ITS CONTRACTORS AND
 * SUBCONTRACTORS, AS WELL AS ANY PRIOR RECIPIENT. IF RECIPIENT'S USE OF
 * THE SUBJECT SOFTWARE RESULTS IN ANY LIABILITIES, DEMANDS, DAMAGES,
 * EXPENSES OR LOSSES ARISING FROM SUCH USE, INCLUDING ANY DAMAGES FROM
 * PRODUCTS BASED ON, OR RESULTING FROM, RECIPIENT'S USE OF THE SUBJECT
 * SOFTWARE, RECIPIENT SHALL INDEMNIFY AND HOLD HARMLESS THE UNITED
 * STATES GOVERNMENT, ITS CONTRACTORS AND SUBCONTRACTORS, AS WELL AS ANY
 * PRIOR RECIPIENT, TO THE EXTENT PERMITTED BY LAW. RECIPIENT'S SOLE
 * REMEDY FOR ANY SUCH MATTER SHALL BE THE IMMEDIATE, UNILATERAL
 * TERMINATION OF THIS AGREEMENT.
 */

package gov.nasa.kepler.ar.exporter.cal;

import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.fs.api.FileStoreException;
import gov.nasa.kepler.fs.api.FloatTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.IntTimeSeries;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.spiffy.common.collect.Pair;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.IOException;
import java.util.List;
import java.util.Map;

import nom.tam.fits.Fits;
import nom.tam.fits.FitsException;

interface PixelTypeInterface {

    TargetType targetTableType();

    /**
     * 
     * @return true if this is a collateral pixel data type, else false.
     */
    boolean isCollateral();

    /**
     * Integer cadence type from the CadenceType enum.
     * 
     * @return
     */
    int cadenceType();

    /**
     * Gets the pixel mapping reference file.
     * 
     * @param pixelExportFits
     * @return
     * @throws PipelineException
     * @throws FileStoreException
     * @throws FitsException
     */
    Pair<Fits, String> pmrfFits(Fits pixelExportFits, FileStoreClient fileStore)
        throws FitsException, IOException;

    /**
     * The list FsIds specified in the pmrf. This will always return the pixels
     * in the order specified in the pmrf. This list may contain duplicates.
     * 
     * @param pmrf
     * @param module
     * @param output
     * @param calibrated
     * @return
     * @throws FitsException
     * @throws IOException
     * @throws PipelineException
     */
    List<FsId> pixelIds(OutputFileInfo info, int module, int output,
        FsIdFactoryType factoryType) throws FitsException, IOException;

    /**
     * Writes out the specified module/output worth of data.
     * 
     * @param module
     * @param output
     * @param cadenceType
     * @param uncalibratedData
     * @param calibratedData Also includes uncertainties.
     * @throws IOException
     * @throws FitsException
     * @throws PipelineException
     */
    void update(OutputFileInfo info, int module, int output,
        Map<FsId, IntTimeSeries> uncalibratedData,
        Map<FsId, FloatTimeSeries> calibratedData,
        ProcessingHistoryFile historyFile) throws FitsException, IOException;

}