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

package gov.nasa.kepler.mc.pmrf;

import static gov.nasa.kepler.common.FitsConstants.*;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.fs.api.BlobResult;
import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.client.FileStoreClientFactory;
import gov.nasa.kepler.hibernate.dbservice.ConfigurationServiceFactory;
import gov.nasa.kepler.hibernate.dr.PixelLog.DataSetType;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.kepler.mc.fs.DrFsIdFactory;
import gov.nasa.kepler.mc.pmrf.CollateralPmrfTable.Duplication;
import gov.nasa.spiffy.common.collect.Pair;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.ByteArrayInputStream;

import nom.tam.fits.Fits;
import nom.tam.fits.TableHDU;

import org.apache.commons.configuration.Configuration;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * This class acts as a cache between the consumer of the PMRFs (Pixel Mapping
 * Reference File) and the file store, where they are stored as generic files.
 * 
 * The cache only stores one PMRF at a time
 * 
 * It also extracts the data from the FITS binary tables so that it only has to
 * be done once.
 * 
 * @author tklaus
 * 
 */
public class PmrfCache {

    private static final Log log = LogFactory.getLog(PmrfCache.class);

    private static final int NUM_CHANNELS = 84;

    private String currentPmrfFileName = null;

    // only one of these will typically be in use at one time
    private SciencePmrfTable[] targetPmrfTables = null;
    private SciencePmrfTable[] backgroundPmrfTables = null;
    private CollateralPmrfTable[] collateralPmrfTables = null;

    private final CadenceType cadenceType;

    private final Duplication duplication;

    public PmrfCache(CadenceType cadenceType, Duplication duplication) {
        if (duplication == null) {
            throw new NullPointerException("duplication");
        }
        if (cadenceType == null) {
            throw new NullPointerException("cadenceType");
        }
        this.duplication = duplication;
        this.cadenceType = cadenceType;
    }

    public PmrfCache(CadenceType cadenceType) {
        this(cadenceType, Duplication.ALLOWED);
    }

    public PmrfTable getPmrfTable(String pmrfFileName, DataSetType dataSetType,
        int channel) {
        if (!pmrfFileName.equals(this.currentPmrfFileName)) {
            // cache miss
            fetchPmrf(pmrfFileName, dataSetType);
            currentPmrfFileName = pmrfFileName;
        }

        if (dataSetType == DataSetType.Target) {
            return targetPmrfTables[channel - 1];
        } else if (dataSetType == DataSetType.Background) {
            return backgroundPmrfTables[channel - 1];
        } else if (dataSetType == DataSetType.Collateral) {
            return collateralPmrfTables[channel - 1];
        } else {
            throw new PipelineException("invalid visible PMRF type: "
                + dataSetType);
        }
    }

    public CollateralPmrfTable[] getCollateralPmrfTables(String pmrfFileName)
        throws PipelineException {

        // Just call the default case but then return all mod/outs.
        getPmrfTable(pmrfFileName, DataSetType.Collateral, 1);

        return collateralPmrfTables; // channel numbers run 1-84
    }

    private void fetchPmrf(String pmrfFileName, DataSetType dataSetType)
        throws PipelineException {
        log.debug("fetchPmrf(String pmrfFileName=" + pmrfFileName
            + ", DataSetType dataSetType=" + dataSetType + ") - start");

        try {
            Configuration config = ConfigurationServiceFactory.getInstance();
            FileStoreClient fsClient = FileStoreClientFactory.getInstance(config);

            FsId fsId = DrFsIdFactory.getPmrfFile(pmrfFileName);
            BlobResult blob = fsClient.readBlob(fsId);
            byte[] pmrfBytes = blob.data();

            Fits fits = new Fits(new ByteArrayInputStream(pmrfBytes));

            fits.readHDU(); // skip primary HDU

            if (dataSetType == DataSetType.Target) {
                targetPmrfTables = fetchSciencePmrf(fits,
                    TargetType.valueOf(cadenceType));
            } else if (dataSetType == DataSetType.Background) {
                backgroundPmrfTables = fetchSciencePmrf(fits,
                    TargetType.BACKGROUND);
            } else if (dataSetType == DataSetType.Collateral) {
                collateralPmrfTables = fetchCollateralPmrf(fits);
            }
        } catch (Exception e) {
            log.error("fetchPmrf(String pmrfFileName=" + pmrfFileName
                + ", DataSetType dataSetType=" + dataSetType + ")", e);

            throw new PipelineException("failed to fetch pmrf: ["
                + pmrfFileName + "]", e);
        }

        log.debug("fetchPmrf(String, DataSetType) - end");
    }

    private SciencePmrfTable[] fetchSciencePmrf(Fits fits, TargetType targetType)
        throws Exception {
        log.debug("fetchSciencePmrf(Fits fits=" + fits + ") - start");

        SciencePmrfTable[] pmrfTables = new SciencePmrfTable[NUM_CHANNELS];

        int tableIndex = 0;
        TableHDU hdu = (TableHDU) fits.readHDU();
        while (hdu != null) { // null == EOF
            Pair<Integer, Integer> modOut = FcConstants.getModuleOutput(tableIndex + 1);

            pmrfTables[tableIndex] = new SciencePmrfTable(targetType,
                modOut.left, modOut.right, (short[]) hdu.getColumn(0),
                (short[]) hdu.getColumn(1));

            hdu = (TableHDU) fits.readHDU();
            tableIndex++;
        }

        log.debug("fetchSciencePmrf(Fits) - end - return value=" + pmrfTables);
        return pmrfTables;
    }

    private CollateralPmrfTable[] fetchCollateralPmrf(Fits fits)
        throws Exception {
        log.debug("fetchCollateralPmrf(Fits fits=" + fits + ") - start");

        CollateralPmrfTable[] pmrfTables = new CollateralPmrfTable[NUM_CHANNELS];

        int tableIndex = 0;
        TableHDU hdu = (TableHDU) fits.readHDU();
        while (hdu != null) { // null == EOF

            Pair<Integer, Integer> modOut = FcConstants.getModuleOutput(tableIndex + 1);

            pmrfTables[tableIndex] = new CollateralPmrfTable(cadenceType,
                modOut.left, modOut.right, (byte[]) hdu.getColumn(0),
                (short[]) hdu.getColumn(1), duplication);

            hdu = (TableHDU) fits.readHDU();
            tableIndex++;
        }

        log.debug("fetchCollateralPmrf(Fits) - end - return value="
            + pmrfTables);
        return pmrfTables;
    }

    /**
     * Name of the FITS keyword that holds the Pixel Mapping Reference File name
     * for this pixel type
     * 
     * @return
     * @throws PipelineException
     */
    public static String getPmrfFilenameKeyword(DataSetType dataSetType,
        TargetType targetTableType) throws PipelineException {
        switch (dataSetType) {
            case Background:
                return BACKGROUND_PMRF_KW;
            case Target:
                if (targetTableType == TargetType.LONG_CADENCE) {
                    return LONG_CADENCE_PMRF_KW;
                } else {
                    return SHORT_CADENCE_PMRF_KW;
                }
            case Collateral:
                if (targetTableType == TargetType.LONG_CADENCE) {
                    return LONG_CADENCE_COLLATERAL_PMRF_KW;
                } else {
                    return SHORT_CADENCE_COLLATERAL_PMRF_KW;
                }
            default:
                throw new PipelineException("Unexpected DataSetType: "
                    + dataSetType);
        }
    }
}
