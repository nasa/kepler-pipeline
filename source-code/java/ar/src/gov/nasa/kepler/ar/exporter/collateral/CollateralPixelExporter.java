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

package gov.nasa.kepler.ar.exporter.collateral;

import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.*;

import org.apache.commons.lang.ArrayUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import nom.tam.fits.FitsException;
import nom.tam.fits.Header;
import nom.tam.util.ArrayDataOutput;
import nom.tam.util.BufferedDataOutputStream;

import com.google.common.collect.ImmutableList;
import com.google.common.collect.ImmutableMap;
import com.google.common.collect.Lists;
import com.google.common.collect.Maps;
import com.google.common.collect.Sets;

import gov.nasa.kepler.ar.exporter.CollateralConfigValues;
import gov.nasa.kepler.ar.exporter.ExposureCalculator;
import gov.nasa.kepler.ar.exporter.FileNameFormatter;
import gov.nasa.kepler.ar.exporter.FitsChecksumOutputStream;
import gov.nasa.kepler.ar.exporter.RollingBandFlagSecretDecoderRing;
import gov.nasa.kepler.ar.exporter.binarytable.ArrayDimensions;
import gov.nasa.kepler.ar.exporter.binarytable.BinaryTableUtils;
import gov.nasa.kepler.ar.exporter.binarytable.SingleCadenceImageWriter;
import gov.nasa.kepler.ar.exporter.primary.BasePrimaryHeaderSource;
import gov.nasa.kepler.ar.exporter.primary.PrimaryHeaderFormatter;
import gov.nasa.kepler.common.CollateralType;
import gov.nasa.kepler.common.ConfigMap;
import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.FitsConstants.ObservingMode;
import gov.nasa.kepler.common.ModifiedJulianDate;
import static gov.nasa.kepler.common.CollateralType.*;
import static gov.nasa.kepler.common.Cadence.CadenceType.*;
import static gov.nasa.kepler.common.FitsConstants.*;
import static gov.nasa.kepler.common.FitsUtils.addChecksum;
import gov.nasa.kepler.fs.api.DoubleTimeSeries;
import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.fs.api.FloatMjdTimeSeries;
import gov.nasa.kepler.fs.api.FloatTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.IntTimeSeries;
import gov.nasa.kepler.fs.api.TimeSeries;
import gov.nasa.kepler.hibernate.cal.BlackAlgorithm;
import gov.nasa.kepler.io.DataOutputStream;
import gov.nasa.kepler.mc.dr.MjdToCadence;
import gov.nasa.kepler.mc.pmrf.CollateralPmrfTable;


/**
 * Generates a collateral pixel file.  This file contains all the collateral
 * pixels for a specific (cadence type, CCD module, CCD output).
 * 
 * See KSOC-3919 for definitions of rolling band flags.
 * 
 * @author Sean McCauliff
 *
 */
public class CollateralPixelExporter {

    private static final byte ROLLING_BAND_FILL = (byte) 0;
    private static final Log log = LogFactory.getLog(CollateralPixelExporter.class);
    
    public void export(final CollateralPixelExporterSource source) throws FitsException, IOException {

        boolean isK2 = source.startStartMjd() >= FcConstants.KEPLER_END_OF_MISSION_MJD;
        
        Map<CollateralType, FsIdsForType> collateralTypeToFsIds =
            Maps.newHashMap();
        
        Set<FsId> allTimeSeriesIds = Sets.newHashSet();
        Set<FsId> cosmicRaySeriesIds = Sets.newHashSet();
        
        CollateralPmrfTable collateralPmrfTable = source.prmfTable();
        if (collateralPmrfTable.length() == 0) {
            if (source.cadenceType() == CadenceType.SHORT) {
                log.warn("Missing collateral pixels for short cadence.");
                return;
            } else {
                throw new IllegalStateException("Missing collateral pixels.");
            }
        }
        
        int[] rollingBandDurations = source.rollingBandUtils().rollingBandPulseDurations();
        
        List<CollateralType> collateralTypesInUse = 
            source.cadenceType() == SHORT ?
                Arrays.asList(CollateralType.values()) :
                ImmutableList.of(BLACK_LEVEL, MASKED_SMEAR, VIRTUAL_SMEAR);
        
        List<FsId> allRollingBandFlagIds = new ArrayList<FsId>();
        for (CollateralType collateralType : collateralTypesInUse) {
            List<FsId> raw = collateralPmrfTable.getPixelFsIds(collateralType);
            List<FsId> calibrated = collateralPmrfTable.getCalibratedPixelFsIds(collateralType);
            List<FsId> umm = collateralPmrfTable.getCalibratedUncertainityFsIds(collateralType);
            List<FsId> cosmicRay = collateralPmrfTable.getCosmicRayFsIds(collateralType);
            List<FsId> rollingBandVariation = collateralPmrfTable.getRollingBandVariation(collateralType, rollingBandDurations);
            List<FsId> rollingBandFlags = collateralPmrfTable.getRollingBandFlags(collateralType, rollingBandDurations);
            FsIdsForType fsIdsForType = new FsIdsForType(raw, calibrated, umm, cosmicRay, rollingBandVariation, rollingBandFlags, collateralType); 
            collateralTypeToFsIds.put(collateralType, fsIdsForType);
            allTimeSeriesIds.addAll(raw);
            allTimeSeriesIds.addAll(calibrated);
            allTimeSeriesIds.addAll(umm);
            if (source.cadenceType() == LONG) {
                allTimeSeriesIds.addAll(rollingBandVariation);
                allTimeSeriesIds.addAll(rollingBandFlags);
                allRollingBandFlagIds.addAll(rollingBandFlags);
            }
            cosmicRaySeriesIds.addAll(cosmicRay);
        }
        
        
        FileStoreClient fsClient = source.fileStoreClient();
        log.info("Fetching " + allTimeSeriesIds.size() + " time series.");
        Map<FsId, TimeSeries> allTimeSeries = 
            fsClient.readTimeSeries(allTimeSeriesIds, source.startCadence(), source.endCadence(), false);

        for (FsIdsForType fsIdsForType : collateralTypeToFsIds.values()) {
            fillGaps(fsIdsForType.calibrated, allTimeSeries);
            fillGaps(fsIdsForType.raw, allTimeSeries);
            fillGaps(fsIdsForType.umm, allTimeSeries);
            fillGaps(fsIdsForType.rollingBandVariation, allTimeSeries);
        }

        log.info("Fetching " + cosmicRaySeriesIds.size() + " cosmic ray series." );
        Map<FsId, FloatMjdTimeSeries> cosmicRaySeries = 
            fsClient.readMjdTimeSeries(cosmicRaySeriesIds, source.startMidMjd(), source.endMidMjd());
        
        Map<FsId, byte[]> rollingBandFlagData = rollingBandFlagsToExportFlags(allRollingBandFlagIds, allTimeSeries);
        
        ExposureCalculator exposureCalculator = 
            new ExposureCalculator(source.configMaps(), 
                allTimeSeries.values(), source.cadenceType(), 
                source.startStartMjd(), source.endEndMjd(), source.startCadence(),
                source.endCadence());
        
        log.info("Generating checksums.");
        
        final FitsChecksumOutputStream primaryHeaderChecksum = new FitsChecksumOutputStream();
        final FitsChecksumOutputStream blackChecksum = new FitsChecksumOutputStream();
        final ArrayDataOutputPassThrough blackChecksumOut = new ArrayDataOutputPassThrough(new DataOutputStream(new BufferedOutputStream(blackChecksum)));
        final FitsChecksumOutputStream virtualSmearChecksum = new FitsChecksumOutputStream();
        final ArrayDataOutputPassThrough virtualSmearChecksumOut = new ArrayDataOutputPassThrough(new DataOutputStream(new BufferedOutputStream(virtualSmearChecksum)));
        final FitsChecksumOutputStream maskedSmearChecksum = new FitsChecksumOutputStream();
        final ArrayDataOutputPassThrough maskedSmearChecksumOut = new ArrayDataOutputPassThrough(new DataOutputStream(new BufferedOutputStream(maskedSmearChecksum)));
        final FitsChecksumOutputStream blackPixelListChecksum = new FitsChecksumOutputStream();
        final ArrayDataOutputPassThrough blackPixelListOut = new ArrayDataOutputPassThrough(new DataOutputStream(new BufferedOutputStream(blackPixelListChecksum)));
        final FitsChecksumOutputStream virtualSmearPixelListChecksum =
            new FitsChecksumOutputStream();
        final ArrayDataOutputPassThrough virtualSmearPixelListOut = 
            new ArrayDataOutputPassThrough(new DataOutputStream(new BufferedOutputStream(virtualSmearPixelListChecksum)));
        final FitsChecksumOutputStream maskedSmearPixelListChecksum =
            new FitsChecksumOutputStream();
        final ArrayDataOutputPassThrough maskedSmearPixelListOut =
            new ArrayDataOutputPassThrough(new DataOutputStream(new BufferedOutputStream(maskedSmearPixelListChecksum)));
        final FitsChecksumOutputStream twoDCollateralChecksum = new FitsChecksumOutputStream();
        final ArrayDataOutputPassThrough twoDCollateralOut = new ArrayDataOutputPassThrough(new DataOutputStream(new BufferedOutputStream(twoDCollateralChecksum)));
        
        
        
        ChecksumsAndOutputs generateChecksums = new ChecksumsAndOutputs() {

                @Override
                public Date generatedAt() {
                    return source.generatedAt();
                }

                @Override
                public String primaryHeaderChecksum() {
                    return CHECKSUM_DEFAULT;
                }

                @Override
                public ArrayDataOutput primaryHeaderOutput() {
                    return new BufferedDataOutputStream(primaryHeaderChecksum);
                }

                @Override
                public String checksum(CollateralType collateralType) {
                    return CHECKSUM_DEFAULT;
                }

                @Override
                public ArrayDataOutputPassThrough output(CollateralType collateralType) {
                    switch (collateralType) {
                        case BLACK_LEVEL: return blackChecksumOut;
                        case MASKED_SMEAR: return maskedSmearChecksumOut;
                        case VIRTUAL_SMEAR: return virtualSmearChecksumOut;
                        case BLACK_MASKED: 
                        case BLACK_VIRTUAL: return twoDCollateralOut;
                        default:
                            throw new IllegalStateException(collateralType.toString());
                    }
                }

                @Override
                public String pixelListChecksum(CollateralType collateralType) {
                    return CHECKSUM_DEFAULT;
                }

                @Override
                public ArrayDataOutput pixelListOutput(CollateralType collateralType) {
                    switch (collateralType) {
                        case BLACK_LEVEL: return blackPixelListOut;
                        case MASKED_SMEAR: return maskedSmearPixelListOut;
                        case VIRTUAL_SMEAR: return virtualSmearPixelListOut;
                        default:
                            throw new IllegalStateException(collateralType.toString());
                    }
                }
        };
        
        
        writeFile(generateChecksums, isK2, exposureCalculator, source, allTimeSeries,
            cosmicRaySeries, collateralTypeToFsIds, collateralPmrfTable,
            collateralTypesInUse, rollingBandFlagData);

        File outputFile = createFileName(source, isK2);
        log.info("Exporting file \"" + outputFile + "\".");

        final ArrayDataOutputPassThrough fileOutput = new ArrayDataOutputPassThrough(new DataOutputStream(new BufferedOutputStream(new FileOutputStream(outputFile))));
        
        
        ChecksumsAndOutputs actualOutput = new ChecksumsAndOutputs() {

            @Override
            public Date generatedAt() {
                return source.generatedAt();
            }

            @Override
            public String primaryHeaderChecksum() {
                return primaryHeaderChecksum.checksumString();
            }

            @Override
            public ArrayDataOutput primaryHeaderOutput() {
                return fileOutput;
            }

            @Override
            public String checksum(CollateralType collateralType) {
                switch (collateralType) {
                    case BLACK_LEVEL: return blackChecksum.checksumString();
                    case VIRTUAL_SMEAR: return virtualSmearChecksum.checksumString();
                    case MASKED_SMEAR: return maskedSmearChecksum.checksumString();
                    case BLACK_MASKED: 
                    case BLACK_VIRTUAL: return twoDCollateralChecksum.checksumString();
                    default:
                        throw new IllegalStateException(collateralType.toString());
                }
            }

            @Override
            public ArrayDataOutputPassThrough output(CollateralType collateralType) {
                return fileOutput;
            }

            @Override
            public String pixelListChecksum(CollateralType collateralType) {
                switch (collateralType) {
                    case BLACK_LEVEL: return blackPixelListChecksum.checksumString();
                    case VIRTUAL_SMEAR: return virtualSmearPixelListChecksum.checksumString();
                    case MASKED_SMEAR: return maskedSmearPixelListChecksum.checksumString();
                    default:
                        throw new IllegalStateException(collateralType.toString());
                }
            }

            @Override
            public ArrayDataOutput pixelListOutput(CollateralType collateralType) {
                return fileOutput;
            }
            
        };
        
        writeFile(actualOutput, isK2, exposureCalculator, source, allTimeSeries,
            cosmicRaySeries, collateralTypeToFsIds, collateralPmrfTable,
            collateralTypesInUse, rollingBandFlagData);
        fileOutput.close();
        log.info("Completed exporting file \"" + outputFile + "\".");
    }

    /**
     * We don't want to export the flags in their raw format.  Here we process them into a 
     * new format.
     * 
     * @param allRollingBandFlagIds
     * @param allTimeSeries
     * @return
     */
    private Map<FsId, byte[]> rollingBandFlagsToExportFlags(
        List<FsId> allRollingBandFlagIds, Map<FsId, TimeSeries> allTimeSeries) {

        
        Map<FsId, byte[]> exportRollingBandFlags = new HashMap<FsId, byte[]>(allRollingBandFlagIds.size() * 2);
        for (FsId rollingBandId : allRollingBandFlagIds) {
            IntTimeSeries origFlags = allTimeSeries.get(rollingBandId).asIntTimeSeries();
            byte[] exportSeries = new byte[origFlags.length()];
            Arrays.fill(exportSeries, ROLLING_BAND_FILL);
            int[] origData = origFlags.iseries();
            for (int i=0; i < exportSeries.length; i++) {
                exportSeries[i] = (byte) (origData[i] &  (
                    RollingBandFlagSecretDecoderRing.ROLLING_BAND_MASK |
                    RollingBandFlagSecretDecoderRing.ROLLING_BAND_MASK_SCENE_DEPENDENT));
            }
            exportRollingBandFlags.put(rollingBandId, exportSeries);
        }
        return exportRollingBandFlags;
    }

    private static File createFileName(final CollateralPixelExporterSource source, boolean isK2) {
        FileNameFormatter fileNameFormatter = new FileNameFormatter();
        
        String fname;
        if (isK2) {
            fname = fileNameFormatter.k2CollateralName(source.k2Campaign(),
                source.ccdModule(), source.ccdOutput(), source.cadenceType());
        } else {
            fname = fileNameFormatter.collateralName(source.defaultFileTimestamp(),
                source.ccdModule(), source.ccdOutput(), source.cadenceType());
        }
        
        File outputFile = new File(source.exportDir(), fname);
        return outputFile;
    }
    
    @SuppressWarnings("unchecked")
    private void writeFile(ChecksumsAndOutputs outputs,
        boolean isK2,
        ExposureCalculator exposureCalculator,
        CollateralPixelExporterSource source,
        Map<FsId, TimeSeries> allTimeSeries,
        Map<FsId, FloatMjdTimeSeries> allCosmicRay,
        Map<CollateralType, FsIdsForType> fsIdsForType,
        CollateralPmrfTable collateralPmrfTable,
        List<CollateralType> collateralTypesInUse,
        Map<FsId, byte[]> rollingBandFlagData) throws FitsException, IOException {

        writePrimaryHeader(outputs.primaryHeaderOutput(),
            outputs.primaryHeaderChecksum(), outputs.generatedAt(), isK2, source);
        
        Map<CollateralType, CollateralPixelBinaryTableHeaderFormatter> formatters =
           ImmutableMap.of(
               BLACK_LEVEL, new BlackCollateralHeaderFormatter(),
               VIRTUAL_SMEAR, new VirtualSmearCollateralHeaderFormatter(),
               MASKED_SMEAR, new MaskedSmearCollateralHeaderFormatter());
        
        Integer[] rollingBandDimensions = rollingBandDimensions(source,
            fsIdsForType);
        
        Map<CollateralType, ArrayDimensions> arrayDimensions = arrayDimensions(
            fsIdsForType, rollingBandDimensions);

        for (CollateralType collateralType : new CollateralType[] {BLACK_LEVEL, VIRTUAL_SMEAR, MASKED_SMEAR}) {
            log.info("Working on collateral type " + collateralType);
            
            CollateralPixelBinaryTableHeaderFormatter formatter = formatters.get(collateralType);
            ArrayDimensions arrayDim = arrayDimensions.get(collateralType);
            
            FsIdsForType fsIds = fsIdsForType.get(collateralType);
            
            List<SingleCadenceImageWriter<?>> imageWriters = Lists.newArrayList();
            
            imageWriters.addAll(fsIds.imageWriters(outputs.output(collateralType), 
                source.startCadence(),
                source.mjdToCadence(), exposureCalculator, allTimeSeries, allCosmicRay,
                rollingBandFlagData));
            
            writeCollateralData(collateralType,
                outputs.output(collateralType),
                outputs.checksum(collateralType), outputs.generatedAt(),
                source, exposureCalculator, formatter,
                allTimeSeries, allCosmicRay, imageWriters,
                arrayDim);
            
            writePixelList(outputs.pixelListOutput(collateralType),
                formatter.pixelListColumnType(),
                formatter.pixelListColumnTypeComment(),
                outputs.pixelListChecksum(collateralType),
                formatter.pixelListExtensionName(),
                outputs.generatedAt(),
                fsIds.size(), 
                collateralPmrfTable.getPixelCoordinates(collateralType));
        }
        
        if (source.cadenceType() == CadenceType.SHORT) {
            FsIdsForType blackMaskedFsIds = fsIdsForType.get(BLACK_MASKED);
            FsIdsForType blackVirtualFsIds = fsIdsForType.get(BLACK_VIRTUAL);
            List<SingleCadenceImageWriter<?>> imageWriters = Lists.newArrayList();
            imageWriters.addAll(blackMaskedFsIds.imageWriters(outputs.output(BLACK_MASKED), 
                source.startCadence(),
                source.mjdToCadence(), exposureCalculator, allTimeSeries, allCosmicRay, Collections.EMPTY_MAP));
            imageWriters.addAll(blackVirtualFsIds.imageWriters(outputs.output(BLACK_VIRTUAL), 
                source.startCadence(),
                source.mjdToCadence(), exposureCalculator, allTimeSeries, allCosmicRay, Collections.EMPTY_MAP));
            
            CollateralPixelBinaryTableHeaderFormatter headerFormatter =
                new ShortCadence2DCollateralHeaderFormatter();
            writeCollateralData(BLACK_MASKED, // I don't have a collateral type that represents both the short cadence collateral
                outputs.output(BLACK_MASKED),
                outputs.checksum(BLACK_MASKED), outputs.generatedAt(),
                source, exposureCalculator, headerFormatter,
                allTimeSeries, allCosmicRay, imageWriters,
                ArrayDimensions.newEmptyInstance());
        }
    }

    private Map<CollateralType, ArrayDimensions> arrayDimensions(
        Map<CollateralType, FsIdsForType> fsIdsForType,
        Integer[] rollingBandDimensions) {
        Map<CollateralType, ArrayDimensions> arrayDimensions = ImmutableMap.of(
            BLACK_LEVEL, ArrayDimensions.newInstance(fsIdsForType.get(BLACK_LEVEL).size(), RB_LEVEL_TCOLUMN, rollingBandDimensions, RB_FLAG_TCOLUMN, rollingBandDimensions),
            VIRTUAL_SMEAR, ArrayDimensions.newInstance(fsIdsForType.get(VIRTUAL_SMEAR).size()),
            MASKED_SMEAR, ArrayDimensions.newInstance(fsIdsForType.get(MASKED_SMEAR).size()));
        return arrayDimensions;
    }

    private Integer[] rollingBandDimensions(
        CollateralPixelExporterSource source,
        Map<CollateralType, FsIdsForType> fsIdsForType) {
        Integer[] rollingBandDimensions =  null;
        if (source.rollingBandUtils().rollingBandPulseDurations().length == 0) {
            rollingBandDimensions = new Integer[] { 0, 0};
        } else {
            rollingBandDimensions = new Integer[] { source.rollingBandUtils().rollingBandPulseDurations().length, fsIdsForType.get(BLACK_LEVEL).size()};
        }
        return rollingBandDimensions;
    }

    /**
     * Writes an HDU that is a binary table which describes the mapping from
     * positions in the per cadence collateral data 
     * array to CCD rows or columns.
     * 
     * @param dout
     * @param columnType
     * @param columnTypeComment
     * @param checksum
     * @param extensionName
     * @param generatedAt
     * @param nPixels
     * @param pixelOffsets
     * @throws FitsException
     * @throws IOException
     */
    private void writePixelList(ArrayDataOutput dout, final String columnType,
        final String columnTypeComment, final String checksum,
        final String extensionName, final Date generatedAt, final int nPixels,
        List<Short> pixelOffsets) throws FitsException, IOException {
        
        Header h = new Header();
        int tableRowSize = 4;
        int nRows = nPixels;
        
        h.addValue(XTENSION_KW, XTENSION_BINTABLE_VALUE, XTENSION_COMMENT);
        h.addValue(BITPIX_KW, BITPIX_BINTABLE_VALUE, BITPIX_COMMENT);
        h.addValue(NAXIS_KW, 2, NAXIS_COMMENT);
        h.addValue(NAXIS1_KW, tableRowSize, NAXIS1_COMMENT); //number of bytes per row
        h.addValue(NAXIS2_KW, nRows, NAXIS2_COMMENT); //number of rows
        h.addValue(PCOUNT_KW, 0, PCOUNT_COMMENT);
        h.addValue(GCOUNT_KW, 1, GCOUNT_COMMENT);
        h.addValue(TFIELDS_KW, 1, TFIELDS_COMMENT);
        
        h.addValue("TTYPE1", columnType, "column title: " + columnTypeComment);
        h.addValue("TFORM1", "J", "column format: 32-bit signed integer");
        h.addValue("TUNIT1", "pixels", "column units: pixels");
        h.addValue("TDISP1", "I4", "display hint");
        h.addValue(INHERT_KW, INHERIT_VALUE, INHERIT_COMMENT);
        h.addValue(EXTNAME_KW, extensionName, EXTNAME_COMMENT);
        h.addValue(EXTVER_KW, 1, EXTVER_COMMENT);
        addChecksum(h, checksum, generatedAt);
        
        h.write(dout);
 
    
        for (short pixelOffset : pixelOffsets) {
            dout.writeInt((int)pixelOffset);
        }
        
        int bytesWritten = tableRowSize * nRows;
        BinaryTableUtils.padBinaryTableData(bytesWritten, dout);
        dout.flush();
    }
   
    /**
     * Writes an HDU containing the collateral pixel data for one type of
     * collateral.  In the case of 2d short cadence collateral collateralType
     * can be BLACK_VIRTUAL or BLACK_MASKED and it will write out both types
     * of collateral.
     * 
     * @param collateralType not null
     * @param dout not null
     * @param checksum not null
     * @param generatedAt not null
     * @param source not null
     * @param exposureCalculator not null
     * @param headerFormatter not null
     * @param allTimeSeries not null
     * @param allCosmicRay not null
     * @param imageWriters not null
     * @throws FitsException
     * @throws IOException
     */
    private void writeCollateralData(final CollateralType collateralType,
        ArrayDataOutputPassThrough dout, 
        final String checksum, final Date generatedAt,
        final CollateralPixelExporterSource source,
        final ExposureCalculator exposureCalculator,
        final CollateralPixelBinaryTableHeaderFormatter headerFormatter,
        Map<FsId, TimeSeries> allTimeSeries,
        Map<FsId, FloatMjdTimeSeries> allCosmicRay,
        List<SingleCadenceImageWriter<?>> imageWriters,
        ArrayDimensions arrayDimensions)
        
    throws FitsException, IOException {
        
      
        CollateralPixelBinaryTableHeaderSource headerSource = createFormatterHeaderSource(
            collateralType, checksum, generatedAt, source, exposureCalculator,
            headerFormatter);
       
        Header header = headerFormatter.formatHeader(headerSource, checksum, arrayDimensions);
        header.write(dout);
        
        MjdToCadence mjdToCadence = source.mjdToCadence();
        
        log.info("Number of cadences exported: " + (source.endCadence() - source.startCadence() + 1) );
        log.info("countOut: " + dout.count());
        for (int c=source.startCadence(); c <= source.endCadence(); c++) {
            int imageIndex = c - source.startCadence();
            
            try {
                dout.writeDouble(mjdToCadence.cadenceToMjd(c));
            } catch (NoSuchElementException ise) {
                dout.writeDouble(Double.NaN);
            }
            dout.writeInt(c);
            for (SingleCadenceImageWriter<?> imageWriter : imageWriters) {
                imageWriter.writeSingleCadenceImage(imageIndex);
            }
        }
        
        log.info("countOut: " + dout.count());
        long totalBytesWritten = headerFormatter.bytesPerTableRow(arrayDimensions) * 
            (source.endCadence() - source.startCadence() + 1);
        log.info("tableDataBytesWritten " + totalBytesWritten);
        BinaryTableUtils.padBinaryTableData(totalBytesWritten, dout);
        log.info("countOut:" + dout.count());
        dout.flush();
    }

    private CollateralPixelBinaryTableHeaderSource createFormatterHeaderSource(
        final CollateralType collateralType, final String checksum,
        final Date generatedAt, final CollateralPixelExporterSource source,
        final ExposureCalculator exposureCalculator,
        final CollateralPixelBinaryTableHeaderFormatter headerFormatter) {
        CollateralPixelBinaryTableHeaderSource headerSource = 
            new DefaultCollateralPixelHeaderSource(source.configMaps()) {
                
                @Override
                public Integer timeSlice() {
                    return FcConstants.getCcdModuleTimeSlice(source.ccdModule());
                }
                
                @Override
                public double timeResolutionOfDataDays() {
                    return exposureCalculator.cadenceDurationDays();
                }
                
                @Override
                public Integer shortCadenceFixedOffset() {
                    return exposureCalculator.shortCadenceFixedOffset();
                }
                
                @Override
                public double scienceFrameTimeSec() {
                    return exposureCalculator.scienceFrameSec();
                }
                
                @Override
                public int readsPerCadence() {
                    return exposureCalculator.numberOfScienceFramesPerCadence();
                }
                
                @Override
                public double readoutTimePerFrameSec() {
                    return exposureCalculator.readTimeSec();
                }
                
                @Override
                public Double readNoiseE() {
                    return source.readNoseE();
                }
                
                @Override
                public double photonAccumulationTimeSec() {
                    return exposureCalculator.integrationTimeSec();
                }
                
                @Override
                public Date observationStartUTC() {
                    return ModifiedJulianDate.mjdToDate(source.startStartMjd());
                }
                
                @Override
                public Date observationEndUTC() {
                    return ModifiedJulianDate.mjdToDate(source.endEndMjd());
                }
                
                @Override
                public int nBinaryTableRows() {
                    return source.endCadence() - source.startCadence() + 1;
                }
                
                @Override
                public Integer meanBlackCounts() {
                    return source.meanBlack();
                }
                
                @Override
                public Integer longCadenceFixedOffset() {
                    return exposureCalculator.longCadenceFixedOffset();
                }
                
                @Override
                public Integer keplerId() {
                    return null;
                }
                
                @Override
                public Date generatedAt() {
                    return generatedAt;
                }
                
                @Override
                public Double gainEPerCount() {
                    return source.gainE();
                }
                
                @Override
                public int framesPerCadence() {
                    return exposureCalculator.numberOfScienceFramesPerCadence();
                }
                
                @Override
                public String extensionName() {
                    return headerFormatter.extensionName();
                }

                @Override
                public boolean printBlackCollateralCoordinates() {
                    return collateralType == BLACK_LEVEL ||
                    collateralType == BLACK_MASKED ||
                    collateralType == BLACK_VIRTUAL;
                }

                @Override
                public boolean printVirtualSmearCoordinates() {
                    return collateralType == VIRTUAL_SMEAR ||
                    collateralType == BLACK_MASKED ||
                    collateralType == BLACK_VIRTUAL;
                }

                @Override
                public boolean printMaskedSmearCoordinates() {
                    return collateralType == MASKED_SMEAR ||
                    collateralType == BLACK_MASKED ||
                    collateralType == BLACK_VIRTUAL;
                }

                @Override
                public boolean backgroundSubtracted() {
                    return false;
                }

                @Override
                public double startMidMjd() {
                    return source.startMidMjd();
                }

                @Override
                public double endMidMjd() {
                    return source.endMidMjd();
                }

                @Override
                public double deadC() {
                    return exposureCalculator.deadC();
                }

                @Override
                public Integer dynablackColumnCutoff() {
                    if (collateralType == BLACK_LEVEL && source.cadenceType() == CadenceType.LONG) {
                        return source.rollingBandUtils().columnCutoff();
                    } else {
                        return null;
                    }
                }

                @Override
                public Double dynablackThreshold() {
                    if (collateralType == BLACK_LEVEL && source.cadenceType() == CadenceType.LONG) {
                        return source.rollingBandUtils().fluxThreshold(exposureCalculator.cadenceDurationDays());
                    } else {
                        return null;
                    }
                }

                @Override
                public int[] rollingBandDurations() {
                    if (collateralType == BLACK_LEVEL && source.cadenceType() == CadenceType.LONG) {
                        return source.rollingBandUtils().rollingBandPulseDurations();
                    } else {
                        return ArrayUtils.EMPTY_INT_ARRAY;
                    }
                }

                @Override
                public BlackAlgorithm blackAlgorithm() {
                    return source.blackAlgorithm();
                }
                
            };
        return headerSource;
    }
    
    
    private void writePrimaryHeader(ArrayDataOutput dout,
        String checksum, final Date generatedAt,
        final boolean isK2,
        final CollateralPixelExporterSource source) 
    throws FitsException, IOException {
        
        BasePrimaryHeaderSource headerSource = 
            new BasePrimaryHeaderSource() {

                @Override
                public int keplerId() {
                    return PrimaryHeaderFormatter.NO_KEPLER_ID;
                }

                @Override
                public String subversionRevision() {
                    return source.subversionRevision(); //KeplerSocVersion.getRevision();
                }

                @Override
                public String subversionUrl() {
                    return source.subversionUrl(); //KeplerSocVersion.getUrl();
                }

                @Override
                public String programName() {
                    return CollateralPixelExporter.class.getSimpleName();
                }

                @Override
                public long pipelineTaskId() {
                    return source.pipelineTaskId();
                }

                @Override
                public int ccdModule() {
                    return source.ccdModule();
                }

                @Override
                public int ccdOutput() {
                    return source.ccdOutput();
                }

                @Override
                public int ccdChannel() {
                    return FcConstants.getChannelNumber(source.ccdModule(), source.ccdOutput());
                }

                @Override
                public Integer skyGroup() {
                    return source.skyGroup();
                }

                @Override
                public int dataReleaseNumber() {
                    return source.dataRelease();
                }

                @Override
                public int quarter() {
                    return source.quarter();
                }

                @Override
                public int season() {
                    return source.season();
                }

                @Override
                public ObservingMode observingMode() {
                    return ObservingMode.valueOf(source.cadenceType());
                }

                @Override
                public double raDegrees() {
                    throw new UnsupportedOperationException();
                }

                @Override
                public Date generatedAt() {
                    return generatedAt;
                }

                @Override
                public int k2Campaign() {
                    return source.k2Campaign();
                }

                @Override
                public boolean isK2Target() {
                    return isK2;
                }

                @Override
                public int targetTableId() {
                    return source.targetTableId();
                }

                @Override
                public int extensionHduCount() {
                    switch (source.cadenceType()) {
                        case LONG: return 3 * 2;
                        case SHORT: return 3 * 2 + 1;
                        default: throw new IllegalStateException();
                    }
                }
        };
        
        CollateralPrimaryHeaderFormatter formatter = new CollateralPrimaryHeaderFormatter();
        Header h = formatter.formatHeader(headerSource, checksum);
        h.write(dout);
        dout.flush();
        
    }
    
    private void fillGaps(Collection<FsId> fsIds, Map<FsId, TimeSeries> allTimeSeries) {
        for (FsId id : fsIds) {
            TimeSeries timeSeries = allTimeSeries.get(id);
            if (timeSeries instanceof IntTimeSeries) {
                IntTimeSeries its = (IntTimeSeries) timeSeries;
                its.fillGaps(BinaryTableUtils.INT_GAP_FILL);
            } else if (timeSeries instanceof FloatTimeSeries) {
                FloatTimeSeries fts = (FloatTimeSeries) timeSeries;
                fts.fillGaps(BinaryTableUtils.GAP_FILL);
            } else if (timeSeries instanceof DoubleTimeSeries) {
                DoubleTimeSeries dts = (DoubleTimeSeries) timeSeries;
                dts.fillGaps(BinaryTableUtils.GAP_FILL);
            } else {
                throw new IllegalStateException("Unhandled time series type " + timeSeries.getClass());
            }
        }
    }
    private abstract class DefaultCollateralPixelHeaderSource extends CollateralConfigValues
    implements CollateralPixelBinaryTableHeaderSource {

        public DefaultCollateralPixelHeaderSource(
            Collection<ConfigMap> configMaps) {
            super(configMaps);
        }
        
    }
}
