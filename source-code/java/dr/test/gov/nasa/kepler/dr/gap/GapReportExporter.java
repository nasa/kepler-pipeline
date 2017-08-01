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

package gov.nasa.kepler.dr.gap;

import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.CollateralType;
import gov.nasa.kepler.dr.gapreport.CadenceTypeXB;
import gov.nasa.kepler.dr.gapreport.ChannelXB;
import gov.nasa.kepler.dr.gapreport.CollateralPixelListXB;
import gov.nasa.kepler.dr.gapreport.GapReportDocument;
import gov.nasa.kepler.dr.gapreport.GapReportXB;
import gov.nasa.kepler.dr.gapreport.MissingTypeXB;
import gov.nasa.kepler.dr.gapreport.TargetListXB;
import gov.nasa.kepler.dr.gapreport.TargetPixelXB;
import gov.nasa.kepler.dr.gapreport.TargetXB;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dr.GapCadence;
import gov.nasa.kepler.hibernate.dr.GapChannel;
import gov.nasa.kepler.hibernate.dr.GapCollateralPixel;
import gov.nasa.kepler.hibernate.dr.GapCrud;
import gov.nasa.kepler.hibernate.dr.GapPixel;
import gov.nasa.kepler.hibernate.dr.GapTarget;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.xmlbeans.XmlError;
import org.apache.xmlbeans.XmlException;
import org.apache.xmlbeans.XmlOptions;

/**
 * Exports all gap-related data structures in the database. This exporter can be
 * run as a stand-alone application or the {@code export} method can be called
 * directly. See {@link #export()} or for details.
 * 
 * @author Bill Wohler
 */
public class GapReportExporter {

    private static final Log log = LogFactory.getLog(GapReportExporter.class);

    public void export(CadenceType cadenceType, int cadenceNumber, File file) {
        try {
            export(cadenceType, receiveGapInfo(cadenceType, cadenceNumber),
                file);
        } catch (Throwable e) {
            throw new IllegalArgumentException("Unable to export.", e);
        }
    }

    private GapInfo receiveGapInfo(CadenceType cadenceType, int cadenceNumber) {

        DatabaseService databaseService = DatabaseServiceFactory.getInstance();
        GapCrud gapCrud = new GapCrud(databaseService);

        Map<Integer, GapInfo> gaps = new HashMap<Integer, GapInfo>();

        // Populate map with GapCadence objects. Since these indicate that an
        // entire cadence is missing, we don't expect to receive more than one
        // per cadence (so throw an exception if we do).
        for (GapCadence gapCadence : gapCrud.retrieveGapCadence(cadenceType, 0,
            Integer.MAX_VALUE)) {
            GapInfo gapInfo = gaps.get(gapCadence.getCadenceNumber());
            if (gapInfo != null) {
                throw new IllegalStateException("Duplicate cadence number "
                    + gapCadence.getCadenceNumber());
            }
            gapInfo = createGapInfo(gapCadence.getCadenceNumber(), false);
            gaps.put(gapCadence.getCadenceNumber(), gapInfo);
        }

        // Populate map with GapChannel objects.
        for (GapChannel gapChannel : gapCrud.retrieveGapChannel(cadenceType, 0,
            Integer.MAX_VALUE)) {
            GapInfo gapInfo = gaps.get(gapChannel.getCadenceNumber());
            if (gapInfo == null) {
                gapInfo = createGapInfo(gapChannel.getCadenceNumber(), true);
                gaps.put(gapChannel.getCadenceNumber(), gapInfo);
            }
            gapInfo.gapChannels.add(gapChannel);
        }

        for (TargetType targetTableType : TargetType.values()) {

            // Ensure CadenceType is compatible with TargetType.
            switch (targetTableType) {
                case LONG_CADENCE:
                case BACKGROUND:
                    if (cadenceType != CadenceType.LONG) {
                        continue;
                    }
                    break;
                case SHORT_CADENCE:
                    if (cadenceType != CadenceType.SHORT) {
                        continue;
                    }
                    break;
                default:
                    continue;
            }

            // Populate map with GapTarget objects.
            for (GapTarget gapTarget : gapCrud.retrieveGapTarget(cadenceType,
                targetTableType, 0, Integer.MAX_VALUE)) {
                GapInfo gapInfo = gaps.get(gapTarget.getCadenceNumber());
                if (gapInfo == null) {
                    gapInfo = createGapInfo(gapTarget.getCadenceNumber(), true);
                    gaps.put(gapTarget.getCadenceNumber(), gapInfo);
                }
                gapInfo.gapTargets.add(gapTarget);
            }

            // Populate map with GapPixel objects.
            for (GapPixel gapPixel : gapCrud.retrieveGapPixel(cadenceType,
                targetTableType, 0, Integer.MAX_VALUE)) {
                GapInfo gapInfo = gaps.get(gapPixel.getCadenceNumber());
                if (gapInfo == null) {
                    gapInfo = createGapInfo(gapPixel.getCadenceNumber(), true);
                    gaps.put(gapPixel.getCadenceNumber(), gapInfo);
                }
                gapInfo.gapPixels.add(gapPixel);
            }
        }

        // Populate map with GapCollateralPixel objects.
        for (GapCollateralPixel gapCollateralPixel : gapCrud.retrieveGapCollateralPixel(
            cadenceType, 0, Integer.MAX_VALUE)) {
            GapInfo gapInfo = gaps.get(gapCollateralPixel.getCadenceNumber());
            if (gapInfo == null) {
                gapInfo = createGapInfo(gapCollateralPixel.getCadenceNumber(),
                    true);
                gaps.put(gapCollateralPixel.getCadenceNumber(), gapInfo);
            }
            gapInfo.gapCollateralPixels.add(gapCollateralPixel);
        }

        return gaps.get(cadenceNumber);
    }

    /**
     * Creates and populates a {@link GapInfo} object.
     * 
     * @param cadenceNumber the cadence number.
     * @param partial {@code true}, if only a portion of the cadence is missing;
     * {@code false}, if the entire cadence is missing.
     * @return the new {@link GapInfo} object.
     */
    private GapInfo createGapInfo(int cadenceNumber, boolean partial) {
        GapInfo gapInfo = new GapInfo();
        gapInfo.cadenceNumber = cadenceNumber;
        gapInfo.partial = partial;

        return gapInfo;
    }

    /**
     * Exports the given gaps in the given cadence type.
     * 
     * @param cadenceType the cadence type.
     * @param gaps the aggregated gaps.
     * @param dir the destination directory.
     * @throws IOException if there were problems exporting the data.
     * @throws XmlException if the intermediary XML document was invalid.
     */
    private void export(CadenceType cadenceType, GapInfo gapInfo, File file)
        throws IOException, XmlException {
        GapReportDocument doc = createDocument(cadenceType, gapInfo,
            file.getName().split("_")[0]);
        writeDocument(cadenceType, doc, file);
    }

    /**
     * Creates a per-cadence XML document.
     * 
     * @param cadenceType the cadence type.
     * @param gapInfo the aggregated gaps for a single cadence.
     * @param datasetName the name of the dataset for this cadence.
     * @return a non-{@code null} XML document.
     */
    private GapReportDocument createDocument(CadenceType cadenceType,
        GapInfo gapInfo, String datasetName) {

        // Create XML document.
        GapReportDocument doc = GapReportDocument.Factory.newInstance();

        // Add top-level gap-report element.
        GapReportXB gapReportXB = addTopLevelElement(cadenceType,
            gapInfo.cadenceNumber, doc, datasetName, gapInfo.partial);

        // If this wasn't a full cadence gap, add children elements.
        if (gapInfo.partial) {

            // Add channel elements.
            Map<Integer, ChannelXB> channelXbMap = new HashMap<Integer, ChannelXB>();
            for (GapChannel gapChannel : gapInfo.gapChannels) {
                addChannelElement(gapReportXB, channelXbMap,
                    gapChannel.getCcdModule(), gapChannel.getCcdOutput(), false);
            }

            // Add target elements.
            Map<Integer, TargetListXB> targetListXbMap = new HashMap<Integer, TargetListXB>();
            Map<Integer, TargetXB> targetXbMap = new HashMap<Integer, TargetXB>();
            for (GapTarget gapTarget : gapInfo.gapTargets) {
                addTargetElement(gapReportXB, channelXbMap, targetListXbMap,
                    targetXbMap, gapTarget.getCcdModule(),
                    gapTarget.getCcdOutput(), gapTarget.getTargetTableType(),
                    gapTarget.getTargetIndex(), gapTarget.getKeplerId(), false);
            }

            // Add pixel elements.
            for (GapPixel gapPixel : gapInfo.gapPixels) {
                addPixelElement(gapReportXB, channelXbMap, targetListXbMap,
                    targetXbMap, gapPixel.getCcdModule(),
                    gapPixel.getCcdOutput(), gapPixel.getTargetTableType(),
                    gapPixel.getTargetIndex(), gapPixel.getKeplerId(),
                    gapPixel.getCcdRow(), gapPixel.getCcdColumn());
            }

            // Add collateral elements.
            Map<Integer, CollateralPixelListXB> collateralPixelListXbMap = new HashMap<Integer, CollateralPixelListXB>();
            for (GapCollateralPixel gapCollateralPixel : gapInfo.gapCollateralPixels) {
                addCollateralPixelElement(gapReportXB, channelXbMap,
                    collateralPixelListXbMap,
                    gapCollateralPixel.getCcdModule(),
                    gapCollateralPixel.getCcdOutput(),
                    gapCollateralPixel.getPixelType(),
                    gapCollateralPixel.getCcdRowOrColumn());
            }
        }

        return doc;
    }

    /**
     * Adds a top-level element to the XML document.
     * 
     * @param cadenceType the cadence type.
     * @param cadenceNumber the cadence number.
     * @param doc the XML document.
     * @param datasetName the name of the dataset for this cadence.
     * @param partial {@code true}, if only a portion of the cadence is missing;
     * {@code false}, if the entire cadence is missing.
     */
    private GapReportXB addTopLevelElement(CadenceType cadenceType,
        int cadenceNumber, GapReportDocument doc, String datasetName,
        boolean partial) {

        GapReportXB gapReportXB = doc.addNewGapReport();
        gapReportXB.setCadence(getCadenceTypeXB(cadenceType));
        gapReportXB.setCadenceNumber(cadenceNumber);
        gapReportXB.setDataset(datasetName);
        gapReportXB.setMissing(getMissingTypeXB(partial));

        return gapReportXB;
    }

    /**
     * Adds a channel element to the XML document if it is not already present.
     * 
     * @param gapReportXB the gap report element.
     * @param channelXbMap the channel look-up map.
     * @param ccdModule the CCD module.
     * @param ccdOutput the CCD output.
     * @param partial {@code true}, if only a portion of the channel is missing;
     * {@code false}, if the entire channel is missing.
     * @return the channel element.
     */
    private ChannelXB addChannelElement(GapReportXB gapReportXB,
        Map<Integer, ChannelXB> channelXbMap, int ccdModule, int ccdOutput,
        boolean partial) {

        int key = generateChannelKey(ccdModule, ccdOutput);
        ChannelXB channelXB = channelXbMap.get(key);
        if (channelXB == null) {
            channelXB = gapReportXB.addNewChannel();
            channelXB.setModule(ccdModule);
            channelXB.setOutput(ccdOutput);
            channelXB.setMissing(getMissingTypeXB(partial));
            channelXbMap.put(key, channelXB);
        }

        return channelXB;
    }

    private int generateChannelKey(int ccdModule, int ccdOutput) {
        final int PRIME = 31;
        int result = 1;
        result = PRIME * result + ccdModule;
        result = PRIME * result + ccdOutput;

        return result;
    }

    /**
     * 
     * Adds a target element to the XML document if it is not already present.
     * Also adds a channel and target list elements to the document to enclose
     * it if necessary.
     * 
     * @param gapReportXB the gap report element.
     * @param channelXbMap the channel look-up map.
     * @param targetListXbMap the target list look-up map.
     * @param targetXbMap the target look-up map.
     * @param ccdModule the CCD module.
     * @param ccdOutput the CCD output.
     * @param targetTableType the target table type.
     * @param targetIndex the target's index.
     * @param keplerId the target's Kepler ID.
     * @param partial {@code true}, if only a portion of the target is missing;
     * {@code false}, if the entire target is missing.
     * @return the target element.
     */
    private TargetXB addTargetElement(GapReportXB gapReportXB,
        Map<Integer, ChannelXB> channelXbMap,
        Map<Integer, TargetListXB> targetListXbMap,
        Map<Integer, TargetXB> targetXbMap, int ccdModule, int ccdOutput,
        TargetType targetTableType, int targetIndex, int keplerId,
        boolean partial) {

        ChannelXB channelXB = addChannelElement(gapReportXB, channelXbMap,
            ccdModule, ccdOutput, true);

        int key = generateTargetListKey(ccdModule, ccdOutput, targetTableType);
        TargetListXB targetListXB = targetListXbMap.get(key);
        if (targetListXB == null) {
            switch (targetTableType) {
                case LONG_CADENCE:
                case SHORT_CADENCE:
                    targetListXB = channelXB.addNewScienceTargets();
                    break;
                case BACKGROUND:
                    targetListXB = channelXB.addNewBackgroundTargets();
                    break;
                default:
                    throw new IllegalArgumentException("Unknown type "
                        + targetTableType);
            }
            targetListXB.setMissing(MissingTypeXB.PART);
            targetListXbMap.put(key, targetListXB);
        }

        key = generateTargetKey(targetIndex);
        TargetXB targetXB = targetXbMap.get(key);
        if (targetXB == null) {
            targetXB = targetListXB.addNewTarget();
            targetXB.setKeplerId(keplerId);
            targetXB.setTargetIndex(targetIndex);
            targetXB.setMissing(getMissingTypeXB(partial));
            targetXbMap.put(key, targetXB);
        }

        return targetXB;
    }

    private int generateTargetListKey(int ccdModule, int ccdOutput,
        TargetType targetTableType) {

        final int PRIME = 31;
        int result = 1;
        result = PRIME * result + ccdModule;
        result = PRIME * result + ccdOutput;
        result = PRIME * result + targetTableType.hashCode();

        return result;
    }

    private int generateTargetKey(int targetIndex) {
        final int PRIME = 31;
        int result = 1;
        result = PRIME * result + targetIndex;

        return result;
    }

    /**
     * Adds a pixel element to the XML document if it is not already present.
     * Also adds channel, target list, and target elements to the document to
     * enclose it if necessary.
     * 
     * @param gapReportXB the gap report element.
     * @param channelXbMap the channel look-up map.
     * @param targetListXbMap the target list look-up map.
     * @param targetXbMap the target look-up map.
     * @param ccdModule the CCD module.
     * @param ccdOutput the CCD output.
     * @param targetTableType the target table type.
     * @param targetIndex the target's index.
     * @param keplerId the target's Kepler ID.
     * @param ccdRow the CCD row.
     * @param ccdColumn the CCD column.
     * @return the pixel element.
     */
    private TargetPixelXB addPixelElement(GapReportXB gapReportXB,
        Map<Integer, ChannelXB> channelXbMap,
        Map<Integer, TargetListXB> targetListXbMap,
        Map<Integer, TargetXB> targetXbMap, int ccdModule, int ccdOutput,
        TargetType targetTableType, int targetIndex, int keplerId, int ccdRow,
        int ccdColumn) {

        TargetXB targetXB = addTargetElement(gapReportXB, channelXbMap,
            targetListXbMap, targetXbMap, ccdModule, ccdOutput,
            targetTableType, targetIndex, keplerId, true);

        TargetPixelXB pixelXB = targetXB.addNewPixel();

        pixelXB.setRow(ccdRow);
        pixelXB.setColumn(ccdColumn);

        return pixelXB;
    }

    /**
     * Adds a collateral pixel element to the XML document if it is not already
     * present. Also adds a channel element to the document to enclose it if
     * necessary.
     * 
     * @param gapReportXB the gap report element.
     * @param channelXbMap the channel look-up map.
     * @param collateralPixelListXbMap the collateral pixel list look-up map.
     * @param ccdModule the CCD module.
     * @param ccdOutput the CCD output.
     * @param pixelType the collateral type.
     * @param ccdRowOrColumn the row or column (offset).
     * @return the collateral pixel element.
     */
    private CollateralPixelListXB addCollateralPixelElement(
        GapReportXB gapReportXB, Map<Integer, ChannelXB> channelXbMap,
        Map<Integer, CollateralPixelListXB> collateralPixelListXbMap,
        int ccdModule, int ccdOutput, CollateralType pixelType,
        int ccdRowOrColumn) {

        ChannelXB channelXB = addChannelElement(gapReportXB, channelXbMap,
            ccdModule, ccdOutput, true);

        CollateralPixelListXB collateralPixelListXB = collateralPixelListXbMap.get(pixelType.hashCode());
        if (collateralPixelListXB == null) {
            switch (pixelType) {
                case BLACK_LEVEL:
                    collateralPixelListXB = channelXB.addNewBlackLevelPixels();
                    break;
                case MASKED_SMEAR:
                    collateralPixelListXB = channelXB.addNewMaskedPixels();
                    break;
                case VIRTUAL_SMEAR:
                    collateralPixelListXB = channelXB.addNewVirtualSmearPixels();
                    break;
                case BLACK_MASKED:
                    collateralPixelListXB = channelXB.addNewBlackMaskedPixels();
                    break;
                case BLACK_VIRTUAL:
                    collateralPixelListXB = channelXB.addNewBlackVirtualPixels();
                    break;
                default:
                    throw new IllegalArgumentException("Unknown type "
                        + pixelType);
            }
            collateralPixelListXbMap.put(pixelType.hashCode(),
                collateralPixelListXB);
            collateralPixelListXB.setMissing(getMissingTypeXB(ccdRowOrColumn != GapCollateralPixel.ALL_PIXELS_FLAG));
        }

        if (ccdRowOrColumn != GapCollateralPixel.ALL_PIXELS_FLAG) {
            collateralPixelListXB.addNewPixel()
                .setOffset(ccdRowOrColumn);
        }

        return collateralPixelListXB;
    }

    /**
     * Writes the given XML document of the given cadence type with the given
     * dataset name to the current directory using DMC naming conventions.
     * 
     * @param cadenceType the cadence type.
     * @param doc the XML document.
     * @param dir the destination directory.
     * @param datasetName the name of the dataset for this cadence.
     * @throws IOException if there were problems exporting the data.
     * @throws XmlException if the XML document is invalid.
     */
    private void writeDocument(CadenceType cadenceType, GapReportDocument doc,
        File file) throws IOException, XmlException {

        XmlOptions xmlOptions = new XmlOptions();

        // Validate.
        List<XmlError> errors = new ArrayList<XmlError>();
        xmlOptions.setErrorListener(errors);
        if (!doc.validate(xmlOptions)) {
            throw new XmlException("XML validation error: " + errors);
        }

        // Write.
        xmlOptions.setSavePrettyPrint()
            .setSavePrettyPrintIndent(2);
        log.info("Writing " + file);
        doc.save(file, xmlOptions);
    }

    /**
     * Converts the given cadence type to a {@code CadenceTypeXB.Enum}.
     */
    private CadenceTypeXB.Enum getCadenceTypeXB(CadenceType cadenceType) {
        switch (cadenceType) {
            case LONG:
                return CadenceTypeXB.LONG;
            case SHORT:
                return CadenceTypeXB.SHORT;
            default:
                throw new IllegalArgumentException("Unknown type "
                    + cadenceType);
        }
    }

    /**
     * Converts the given boolean to a {@code MissingTypeXB.Enum}.
     */
    private MissingTypeXB.Enum getMissingTypeXB(boolean partial) {
        return partial ? MissingTypeXB.PART : MissingTypeXB.ALL;

    }

    private static class GapInfo {
        public int cadenceNumber;
        public boolean partial;
        public List<GapChannel> gapChannels = new ArrayList<GapChannel>();
        public List<GapTarget> gapTargets = new ArrayList<GapTarget>();
        public List<GapPixel> gapPixels = new ArrayList<GapPixel>();
        public List<GapCollateralPixel> gapCollateralPixels = new ArrayList<GapCollateralPixel>();
    }
}
