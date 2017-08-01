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

package gov.nasa.kepler.dr.pixels;

import static gov.nasa.kepler.common.FitsConstants.LC_INTER_KW;
import static gov.nasa.kepler.common.FitsConstants.SC_INTER_KW;
import gov.nasa.kepler.dr.dispatch.DispatchException;
import gov.nasa.kepler.dr.lazyfits.Hdu;
import gov.nasa.kepler.dr.lazyfits.LazyFits;
import gov.nasa.kepler.dr.pixels.FitsMetadataCache.CadenceMetadata;
import gov.nasa.kepler.hibernate.dr.PixelLog.DataSetType;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.kepler.mc.pmrf.PmrfCache;
import gov.nasa.kepler.mc.pmrf.PmrfTable;

import java.io.File;
import java.io.IOException;

/**
 * This class models a set of cadence science data FITS files in the format sent
 * by the DMC to the SOC It is the super-class for the various types of data
 * sets (target, bkgrnd, collateral)
 * 
 * @author Todd Klaus tklaus@arc.nasa.gov
 * 
 */
class CadenceFitsPair {

    private String fitsDir;
    private String fitsFileName;
    private DataSetType dataSetType;
    private TargetType targetTableType;
    private PmrfCache pmrfCache;

    private int ccdChannel = 0; // Used as an HDU index. 0 is the primary
    // HDU, 1-84 are the extensions (one per
    // channel)

    private File dataFile = null;
    private LazyFits dataFits = null;
    private Hdu dataChannelHdu = null;
    private String pmrfFilename = null;

    private int cadenceNumber;

    private FitsMetadataCache fitsCache = null;

    /**
     * channel = channelNums[module] + output
     */
    private static final int[] channelNums = { 0, 0, 0, 4, 8, 0, 12, 16, 20,
        24, 28, 32, 36, 40, 44, 48, 52, 56, 60, 64, 68, 0, 72, 76, 80 };

    private int[] rawValueColumn;
    private PmrfTable pmrfTable;

    CadenceFitsPair(String fitsDir, String fitsFileName,
        DataSetType dataSetType, TargetType targetTableType,
        PmrfCache pmrfCache, FitsMetadataCache fitsCache) {
        this.fitsDir = fitsDir;
        this.fitsFileName = fitsFileName;
        this.dataSetType = dataSetType;
        this.targetTableType = targetTableType;
        this.pmrfCache = pmrfCache;
        this.fitsCache = fitsCache;

        initialize();
    }

    void close() throws IOException {
        if (dataFits != null) {
            dataFits.close();
        }
    }

    private void initialize() {
        dataFile = new File(fitsDir, fitsFileName);

        if (!dataFile.exists()) {
            throw new DispatchException("data file " + dataFile + " not found!");
        }

        try {
            CadenceMetadata metadata = fitsCache.getMetadata(fitsFileName);

            if (metadata == null) {
                dataFits = new LazyFits(dataFile);
                Hdu primaryHdu = dataFits.readNextHdu();
                String pmrfFilenameKeyword = PmrfCache.getPmrfFilenameKeyword(
                    dataSetType, targetTableType);
                pmrfFilename = primaryHdu.getHeader()
                    .getStringValue(pmrfFilenameKeyword);

                int cadenceNumber;

                if (targetTableType == TargetType.SHORT_CADENCE) {
                    cadenceNumber = primaryHdu.getHeader()
                        .getIntValue(SC_INTER_KW);
                } else { // long cadence
                    cadenceNumber = primaryHdu.getHeader()
                        .getIntValue(LC_INTER_KW);
                }

                if (pmrfFilename == null || pmrfFilename.length() == 0) {
                    throw new DispatchException(
                        "missing value for pmrfFilenamekeyword: "
                            + pmrfFilenameKeyword);
                }

                metadata = new CadenceMetadata(cadenceNumber, pmrfFilename);
                fitsCache.putMetadata(fitsFileName, metadata);
            } else {
                pmrfFilename = metadata.pmrfFilename;
                cadenceNumber = metadata.cadenceNumber;
            }

            LazyFits referenceFits = fitsCache.getReferenceFits(pmrfFilename);

            if (referenceFits == null) {
                // this instance will become the reference
                if (dataFits == null) {
                    dataFits = new LazyFits(dataFile);
                }
                dataFits.readAllHdus();
                fitsCache.setReferenceFits(pmrfFilename, dataFits);
            } else {
                if (dataFits != null) {
                    dataFits.close();
                }
                // re-open dataFits using the reference
                dataFits = new LazyFits(dataFile, referenceFits);
            }
        } catch (Throwable e) {
            throw new DispatchException("failed to open FITS files", e);
        }
    }

    TimeSeriesEntry readRow(int rowIndex) {
        return new TimeSeriesEntry(pmrfTable.getFsId(rowIndex),
            getCadenceNumber(), rawValueColumn[rowIndex]);
    }

    void setCurrentModuleOutput(int desiredCcdModule, int desiredCcdOutput) {
        int desiredCcdChannel = channelNums[desiredCcdModule]
            + desiredCcdOutput;

        if (desiredCcdChannel < ccdChannel) {
            throw new DispatchException(
                "Attempted to get an HDU that was already passed in the stream (can't move backwards)");
        } else if (desiredCcdChannel == ccdChannel) {
            return;
        }

        // get the table HDU for this channel
        try {
            if (desiredCcdChannel != ccdChannel) {
                dataChannelHdu = dataFits.getHdu(desiredCcdChannel);

                ccdChannel = desiredCcdChannel;
                pmrfTable = pmrfCache.getPmrfTable(pmrfFilename, dataSetType,
                    ccdChannel);

                prefetchTable();
            }
        } catch (Exception e) {
            throw new DispatchException("failed to fetch HDU for binary table",
                e);
        }
    }

    private void prefetchTable() throws Exception {
        rawValueColumn = (int[]) dataChannelHdu.getData()
            .getColumn(0);

        validateLength();
    }

    private void validateLength() {
        int pmrfLength = pmrfTable.length();
        int pixelFitsLength = rawValueColumn.length;

        if (pmrfLength != pixelFitsLength) {
            throw new IllegalArgumentException(
                "The pmrf cannot have a different length than the pixel fits file."
                    + "\n  pmrfLength: " + pmrfLength + "\n  pixelFitsLength: "
                    + pixelFitsLength);
        }
    }

    int getRowCountForCurrentModuleOutput() {
        return dataChannelHdu.getData()
            .getRowCount();
    }

    int getCadenceNumber() {
        return cadenceNumber;
    }

    String getFitsFileName() {
        return fitsFileName;
    }

}