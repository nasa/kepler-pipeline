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

package gov.nasa.kepler.systest.validation;

import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.ModifiedJulianDate;
import gov.nasa.kepler.common.UsageException;
import gov.nasa.kepler.common.pi.CadenceRangeParameters;
import gov.nasa.kepler.common.pi.CadenceTypePipelineParameters;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineInstanceCrud;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.PipelineTask.State;
import gov.nasa.kepler.hibernate.pi.PipelineTaskCrud;
import gov.nasa.kepler.hibernate.tad.ObservedTarget;
import gov.nasa.kepler.hibernate.tad.Offset;
import gov.nasa.kepler.hibernate.tad.TargetCrud;
import gov.nasa.kepler.hibernate.tad.TargetDefinition;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.kepler.hibernate.tad.TargetTableLog;
import gov.nasa.kepler.mc.CorrectedFluxTimeSeries;
import gov.nasa.kepler.mc.OutliersTimeSeries;
import gov.nasa.kepler.mc.Pixel;
import gov.nasa.kepler.mc.dr.MjdToCadence.DataAnomalyFlags;
import gov.nasa.kepler.mc.dr.MjdToCadence.TimestampSeries;
import gov.nasa.kepler.mc.uow.ModOutCadenceUowTask;
import gov.nasa.kepler.pdc.PdcGoodnessComponent;
import gov.nasa.kepler.pdc.PdcGoodnessMetric;
import gov.nasa.spiffy.common.CompoundDoubleTimeSeries;
import gov.nasa.spiffy.common.CompoundFloatTimeSeries;
import gov.nasa.spiffy.common.SimpleDoubleTimeSeries;
import gov.nasa.spiffy.common.SimpleFloatTimeSeries;
import gov.nasa.spiffy.common.SimpleIntTimeSeries;
import gov.nasa.spiffy.common.collect.ArrayUtils;
import gov.nasa.spiffy.common.collect.Pair;

import java.io.File;
import java.io.FilenameFilter;
import java.io.IOException;
import java.net.URI;
import java.net.URISyntaxException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TreeMap;

import nom.tam.fits.BasicHDU;
import nom.tam.fits.BinaryTable;
import nom.tam.fits.Data;
import nom.tam.fits.Fits;
import nom.tam.fits.FitsException;
import nom.tam.fits.Header;
import nom.tam.fits.ImageData;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Common validation utilities.
 * 
 * @author Forrest Girouard
 * @author Bill Wohler
 */
public final class ValidationUtils {

    public static class BinFilenameFilter implements FilenameFilter {
        private String filenamePrefix;

        public BinFilenameFilter(String csci, TaskFileType type) {
            filenamePrefix = String.format("%s-%s-", csci, type.toString()
                .toLowerCase());
        }

        @Override
        public boolean accept(File dir, String name) {
            if (name.startsWith(filenamePrefix) && name.endsWith(".bin")) {
                return true;
            }
            return false;
        }
    }

    public static class StDirectoryFilter implements FilenameFilter {
        @Override
        public boolean accept(File dir, String name) {
            if (name.startsWith("st-") && new File(dir, name).isDirectory()) {
                return true;
            }
            return false;
        }
    }

    public static class GDirectoryFilter implements FilenameFilter {
        @Override
        public boolean accept(File dir, String name) {
            if (name.equals("g-0") && new File(dir, name).isDirectory()) {
                return true;
            }
            return false;
        }
    }

    /**
     * This should be the same as the constant MISSING_CAL_PIXEL_VALUE. However,
     * the original constant is not used for verification purposes.
     */
    public static final float MISSING_CAL_PIXEL_VALUE = Float.NEGATIVE_INFINITY;

    /**
     * This should be the same as the constant MISSING_PIXEL_VALUE. However, the
     * original constant is not used for verification purposes.
     */
    public static final int MISSING_PIXEL_VALUE = -1;

    /**
     * Value to use when padding an array with values that are not available in
     * the current context.
     */
    public static final float FITS_FILL_VALUE = 0.0F;

    /**
     * Used by {@code runtimeDirNames} methods to return the names of all task
     * directories, not just the one that contains a particular cadence.
     */
    public static final int ALL_CADENCES = -1;

    private static final Log log = LogFactory.getLog(ValidationUtils.class);

    // No instances.
    private ValidationUtils() {
    }

    /**
     * Checks that the given abstract path exists, is a directory, and is
     * readable.
     * 
     * @param directory the directory
     * @param errorMessageDescriptor a string used in the exception message that
     * describes the directory type
     * @return {@code false} if the given abstract path fails the tests
     * described above; otherwise, {@code true}
     */
    public static boolean directoryReadable(File directory,
        String errorMessageDescriptor) {

        if (!directory.exists()) {
            log.warn(String.format("%s %s does not exist",
                errorMessageDescriptor, directory));
            return false;
        }
        if (!directory.isDirectory()) {
            log.warn(String.format("%s %s is not a directory",
                errorMessageDescriptor, directory));
            return false;
        }
        if (!directory.canRead()) {
            log.warn(String.format("Can't read %s %s", errorMessageDescriptor,
                directory));
            return false;
        }

        return true;
    }

    /**
     * Checks that the given abstract path exists, is a file, and is readable.
     * 
     * @param file the file
     * @param errorMessageDescriptor a string used in the exception message that
     * describes the file type
     * @return {@code false} if the given abstract path fails the tests
     * described above; otherwise, {@code true}
     */
    public static boolean fileReadable(File file, String errorMessageDescriptor) {
        if (!file.exists()) {
            log.warn(String.format("%s %s does not exist",
                errorMessageDescriptor, file));
            return false;
        }
        if (!file.isFile()) {
            log.warn(String.format("%s %s is not a file",
                errorMessageDescriptor, file));
            return false;
        }
        if (!file.canRead()) {
            log.warn(String.format("Can't read %s %s", errorMessageDescriptor,
                file));
            return false;
        }

        return true;
    }

    /**
     * Checks that the given URI contains the given scheme, and contains a
     * specific scheme part.
     * 
     * @param uri the URI
     * @param scheme the expected scheme
     * @param errorMessageDescriptor a string used in the exception message that
     * describes the URI type
     * @throws URISyntaxException if the given URI could not be parsed as a URI
     * reference
     * @throws UsageException if the given URI fails the tests described above
     */
    public static void checkUri(String uri, String scheme,
        String errorMessageDescriptor) throws URISyntaxException {

        if (scheme == null) {
            throw new NullPointerException("scheme can't be null");
        }

        if (!scheme.equals(new URI(uri).getScheme())) {
            throw new UsageException(String.format("%s %s requires scheme %s",
                errorMessageDescriptor, uri, scheme));
        }
        // Creation of URI will catch lack of scheme-specific part.
    }

    public static CadenceType getCadenceType(long pipelineInstanceId) {
        PipelineInstance pipelineInstance = new PipelineInstanceCrud().retrieve(pipelineInstanceId);
        if (pipelineInstance == null) {
            throw new IllegalArgumentException(
                "Can not find pipeline instance " + pipelineInstanceId);
        }
        CadenceTypePipelineParameters cadenceTypeParameters = (CadenceTypePipelineParameters) pipelineInstance.getPipelineParameters(CadenceTypePipelineParameters.class);
        CadenceType cadenceType = CadenceType.valueOf(cadenceTypeParameters.getCadenceType());

        return cadenceType;
    }

    public static Pair<Integer, Integer> getCadenceRange(long pipelineInstanceId) {
        PipelineInstance pipelineInstance = new PipelineInstanceCrud().retrieve(pipelineInstanceId);
        if (pipelineInstance == null) {
            throw new IllegalArgumentException(
                "Can not find pipeline instance " + pipelineInstanceId);
        }

        CadenceRangeParameters cadenceRangeParameters = (CadenceRangeParameters) pipelineInstance.getPipelineParameters(CadenceRangeParameters.class);

        return Pair.of(cadenceRangeParameters.getStartCadence(),
            cadenceRangeParameters.getEndCadence());
    }

    public static Pair<String, Integer> taskDirNameAndStartCadence(
        long pipelineInstanceId, String moduleName, int cadence, int ccdModule,
        int ccdOutput) {
        if (cadence < 0) {
            throw new IllegalArgumentException("cadence must be >= 0");
        }

        return taskDirNamesAndStartCadences(pipelineInstanceId, moduleName,
            cadence, ccdModule, ccdOutput).get(0);
    }

    public static List<String> taskDirNames(long pipelineInstanceId,
        String moduleName, int ccdModule, int ccdOutput) {

        return taskDirNames(pipelineInstanceId, moduleName, ALL_CADENCES,
            ccdModule, ccdOutput);
    }

    public static List<String> taskDirNames(long pipelineInstanceId,
        String moduleName, int cadence, int ccdModule, int ccdOutput) {

        List<Pair<String, Integer>> taskDirNamesAndStartCadences = taskDirNamesAndStartCadences(
            pipelineInstanceId, moduleName, cadence, ccdModule, ccdOutput);
        List<String> taskDirNames = new ArrayList<String>(
            taskDirNamesAndStartCadences.size());

        for (Pair<String, Integer> taskDirNameAndStartCadence : taskDirNamesAndStartCadences) {
            taskDirNames.add(taskDirNameAndStartCadence.left);
        }

        return taskDirNames;
    }

    public static List<Pair<String, PipelineTask>> taskDirNamesAndPipelineTasks(
        long pipelineInstanceId, String moduleName) {

        PipelineInstance pipelineInstance = new PipelineInstanceCrud().retrieve(pipelineInstanceId);
        if (pipelineInstance == null) {
            throw new IllegalArgumentException(
                "Can not find pipeline instance " + pipelineInstanceId);
        }

        List<PipelineTask> pipelineTasks = new PipelineTaskCrud().retrieveAll(
            pipelineInstance, State.COMPLETED);
        List<Pair<String, PipelineTask>> taskDirNamesAndPipelineTasks = new ArrayList<Pair<String, PipelineTask>>();

        for (PipelineTask pipelineTask : pipelineTasks) {
            if (!pipelineTask.getPipelineInstanceNode()
                .getPipelineModuleDefinition()
                .getName()
                .toString()
                .equals(moduleName)) {
                continue;
            }

            String taskDirName = taskDirName(pipelineInstanceId, moduleName,
                pipelineTask);
            taskDirNamesAndPipelineTasks.add(Pair.of(taskDirName, pipelineTask));
        }

        if (taskDirNamesAndPipelineTasks.size() == 0) {
            log.warn(String.format(
                "Can't find any pipeline tasks for module %s "
                    + "in pipeline instance %d", moduleName, pipelineInstanceId));
        }

        return taskDirNamesAndPipelineTasks;
    }

    private static List<Pair<String, Integer>> taskDirNamesAndStartCadences(
        long pipelineInstanceId, String moduleName, int cadence, int ccdModule,
        int ccdOutput) {

        PipelineInstance pipelineInstance = new PipelineInstanceCrud().retrieve(pipelineInstanceId);
        if (pipelineInstance == null) {
            throw new IllegalArgumentException(
                "Can not find pipeline instance " + pipelineInstanceId);
        }

        List<PipelineTask> pipelineTasks = new PipelineTaskCrud().retrieveAll(
            pipelineInstance, State.COMPLETED);
        Map<Integer, String> taskDirNameByStartCadence = new TreeMap<Integer, String>();

        for (PipelineTask pipelineTask : pipelineTasks) {
            if (!pipelineTask.getPipelineInstanceNode()
                .getPipelineModuleDefinition()
                .getName()
                .toString()
                .equals(moduleName)) {
                continue;
            }
            ModOutCadenceUowTask uowTask = pipelineTask.uowTaskInstance();
            if (ccdModule != uowTask.getCcdModule()
                || ccdOutput != uowTask.getCcdOutput()) {
                continue;
            }
            String taskDirName = taskDirName(pipelineInstanceId, moduleName,
                pipelineTask);
            taskDirNameByStartCadence.put(uowTask.getStartCadence(),
                taskDirName);
            if (cadence != ALL_CADENCES) {
                if (cadence < uowTask.getStartCadence()
                    || cadence > uowTask.getEndCadence()) {
                    continue;
                }
                @SuppressWarnings("unchecked")
                List<Pair<String, Integer>> taskDirNameAndStartCadence = Arrays.asList(Pair.of(
                    taskDirName, uowTask.getStartCadence()));
                return taskDirNameAndStartCadence;
            }
        }

        if (cadence != ALL_CADENCES) {
            throw new IllegalArgumentException(
                String.format(
                    "Can't find the pipeline task for module %s, "
                        + "module/output %d/%d, cadence %d, in pipeline instance %d",
                    moduleName, ccdModule, ccdOutput, cadence,
                    pipelineInstanceId));
        }

        if (taskDirNameByStartCadence.size() == 0) {
            throw new IllegalArgumentException(String.format(
                "Can't find any pipeline tasks for module %s, "
                    + "module/output %d/%d, in pipeline instance %d",
                moduleName, ccdModule, ccdOutput, pipelineInstanceId));
        }

        List<Pair<String, Integer>> taskDirNamesAndStartCadences = new ArrayList<Pair<String, Integer>>(
            taskDirNameByStartCadence.size());
        for (Map.Entry<Integer, String> entry : taskDirNameByStartCadence.entrySet()) {
            taskDirNamesAndStartCadences.add(Pair.of(entry.getValue(),
                entry.getKey()));
        }

        return taskDirNamesAndStartCadences;
    }

    public static String taskDirName(long pipelineInstanceId,
        String moduleName, PipelineTask pipelineTask) {

        return String.format("%s-matlab-%d-%d", moduleName, pipelineInstanceId,
            pipelineTask.getId());
    }

    public static Header getFitsFileHeader(Fits fitsFile) throws FitsException,
        IOException {

        BasicHDU headerHdu = fitsFile.readHDU();
        Header header = headerHdu.getHeader();

        return header;
    }

    public static Header getFitsFileHeader(File file, Fits fitsFile)
        throws FitsException, IOException {

        Header header = getFitsFileHeader(fitsFile);

        return header;
    }

    public static Map<String, Integer> extractIntKeywords(String filename,
        Fits fitsFile, Set<String> keywords) throws FitsException, IOException {

        Map<String, Integer> valueByKeyword = new HashMap<String, Integer>();

        BasicHDU headerHdu = fitsFile.readHDU();
        if (headerHdu == null) {
            throw new IllegalStateException(String.format(
                "Did not find header in FITS file %s", filename));
        }

        Header header = headerHdu.getHeader();
        for (String keyword : keywords) {
            valueByKeyword.put(keyword, header.getIntValue(keyword));
        }

        return valueByKeyword;
    }

    public static Map<? extends String, ? extends String> extractStringKeywords(
        String filename, Fits fitsFile, Set<String> keywords)
        throws FitsException, IOException {

        Map<String, String> valueByKeyword = new HashMap<String, String>();

        BasicHDU headerHdu = fitsFile.readHDU();
        if (headerHdu == null) {
            throw new IllegalStateException(String.format(
                "Did not find header in FITS file %s", filename));
        }

        Header header = headerHdu.getHeader();
        for (String keyword : keywords) {
            valueByKeyword.put(keyword, header.getStringValue(keyword));
        }

        return valueByKeyword;
    }

    public static Map<? extends String, ? extends Float> extractFloatKeywords(
        String filename, Fits fitsFile, Set<String> keywords)
        throws FitsException, IOException {

        Map<String, Float> valueByKeyword = new HashMap<String, Float>();

        BasicHDU headerHdu = fitsFile.readHDU();
        if (headerHdu == null) {
            throw new IllegalStateException(String.format(
                "Did not find header in FITS file %s", filename));
        }

        Header header = headerHdu.getHeader();
        for (String keyword : keywords) {
            valueByKeyword.put(keyword, header.getFloatValue(keyword));
        }

        return valueByKeyword;
    }

    public static BinaryTable extractBinaryTable(String filename, Fits fitsFile)
        throws FitsException, IOException {

        BasicHDU headerHdu = fitsFile.readHDU();
        if (headerHdu == null) {
            throw new IllegalStateException(String.format(
                "Did not find header in FITS file %s", filename));
        }

        headerHdu.getHeader();

        Data data = headerHdu.getData();
        if (!(data instanceof BinaryTable)) {
            throw new IllegalStateException(String.format(
                "Expected BinaryTable data section in FITS file %s, not %s",
                filename, data.getClass()
                    .getSimpleName()));
        }

        return (BinaryTable) data;
    }

    public static SimpleFloatTimeSeries indicesToTimeSeries(int offset,
        int length, List<Integer> indices) {

        int[] intIndices = new int[indices.size()];
        int i = 0;
        for (Integer index : indices) {
            intIndices[i++] = index;
        }

        return indicesToTimeSeries(offset, length, intIndices);
    }

    public static SimpleFloatTimeSeries indicesToTimeSeries(int offset,
        int length, int[] indices) {

        float[] values = new float[length];
        boolean[] gaps = new boolean[length];
        Arrays.fill(gaps, true);
        for (int index : indices) {
            if (index < offset) {
                continue;
            }
            if (index - offset >= length) {
                break;
            }
            gaps[index - offset] = false;
        }

        return new SimpleFloatTimeSeries(values, gaps);
    }

    public static List<File> getBinFiles(File dir, String csci,
        TaskFileType type) {

        List<File> binFileList = new ArrayList<File>();
        File[] binFiles = dir.listFiles(new ValidationUtils.BinFilenameFilter(
            csci, type));
        for (File binFile : binFiles) {
            binFileList.add(binFile);
        }
        if (binFileList.isEmpty()) {
            File[] stDirectories = dir.listFiles(new ValidationUtils.StDirectoryFilter());
            for (File stDirectory : stDirectories) {
                File[] moreBinFiles = stDirectory.listFiles(new ValidationUtils.BinFilenameFilter(
                    csci, type));
                for (File binFile : moreBinFiles) {
                    binFileList.add(new File(stDirectory, binFile.getName()));
                }
            }
        }
        if (binFileList.isEmpty()) {
            File[] groupDirs = dir.listFiles(new ValidationUtils.GDirectoryFilter());
            for (File groupDir : groupDirs) {
                File[] stDirectories = groupDir.listFiles(new ValidationUtils.StDirectoryFilter());
                for (File stDirectory : stDirectories) {
                    File[] moreBinFiles = stDirectory.listFiles(new ValidationUtils.BinFilenameFilter(
                        csci, type));
                    for (File binFile : moreBinFiles) {
                        binFileList.add(new File(stDirectory, binFile.getName()));
                    }
                }
            }
        }

        return binFileList;
    }

    public static void extractAperture(String filename, Fits fitsFile,
        boolean includeCentroidApertures, FitsAperture fitsAperture)
        throws FitsException, IOException {

        try {
            getFitsFileHeader(fitsFile);
            extractBinaryTable(filename, fitsFile);

            BasicHDU headerHdu = fitsFile.readHDU();
            Header header = headerHdu.getHeader();
            int referenceColumn = header.getIntValue("CRVAL1P");
            int referenceRow = header.getIntValue("CRVAL2P");

            ImageData apertureImage = (ImageData) headerHdu.getData();
            int[][] imageData = (int[][]) apertureImage.getData();

            for (int i = imageData.length - 1; i >= 0; i--) {
                for (int j = 0; j < imageData[i].length; j++) {
                    if ((imageData[i][j] & ApertureFlag.IN_APERTURE.getBitValue()) != 0) {
                        AperturePixel pixel = new AperturePixel(referenceRow
                            + i, referenceColumn + j);
                        pixel.setInOptimalAperture((imageData[i][j] & ApertureFlag.IN_OPTIMAL_APERTURE.getBitValue()) != 0);
                        if (includeCentroidApertures) {
                            pixel.setInFluxWeightedCentroidAperture((imageData[i][j] & ApertureFlag.IN_FLUX_WEIGHTED_CENTROID_APERTURE.getBitValue()) != 0);
                            pixel.setInPrfCentroidAperture((imageData[i][j] & ApertureFlag.IN_PRF_CENTROID_APERTURE.getBitValue()) != 0);
                        }
                        fitsAperture.addPixel(Pair.of(i, j), pixel);
                    }
                }
            }
        } finally {
            fitsFile.getStream()
                .close();
        }
    }

    public static void extractOptimalApertureProjections(FitsAperture aperture,
        Set<Integer> optimalApertureRowProjection,
        Set<Integer> optimalApertureColmnProjection) {

        for (AperturePixel pixel : aperture.getPixels()) {
            if (pixel.isInOptimalAperture()) {
                optimalApertureRowProjection.add(pixel.getRow());
                optimalApertureColmnProjection.add(pixel.getColumn());
            }
        }
    }

    public static void extractProjections(Map<Integer, Pixel> pixelsByIndex,
        Set<Integer> rowProjection, Set<Integer> columnProjection) {

        for (Pixel pixel : pixelsByIndex.values()) {
            rowProjection.add(pixel.getRow());
            columnProjection.add(pixel.getColumn());
        }
    }

    public static TargetTable getTargetTable(CadenceType cadenceType,
        int startCadence, int endCadence) {

        TargetCrud targetCrud = new TargetCrud();

        List<TargetTableLog> targetTableLogs = targetCrud.retrieveTargetTableLogs(
            TargetType.valueOf(cadenceType), startCadence, endCadence);
        if (targetTableLogs.isEmpty()) {
            throw new IllegalStateException(
                String.format(
                    "%s cadence target table missing for cadence interval [%d, %d].",
                    cadenceType.getName(), startCadence, endCadence));
        }

        if (targetTableLogs.size() > 1) {
            throw new IllegalStateException(String.format(
                "Found %s target tables for cadence interval [%d, %d].",
                targetTableLogs.size(), startCadence, endCadence));
        }

        return targetTableLogs.get(0)
            .getTargetTable();
    }

    public static boolean getObservedTargetAperture(
        int keplerId,
        TargetTable targetTable,
        Map<Integer, Set<Pair<Integer, Integer>>> pixelsInPrfCentroidApertureByKeplerId,
        Map<Integer, Set<Pair<Integer, Integer>>> pixelsInFluxWeightedCentroidApertureByKeplerId,
        FitsAperture fitsAperture) {

        boolean success = true;
        TargetCrud targetCrud = new TargetCrud();

        List<ObservedTarget> observedTargets = targetCrud.retrieveObservedTargets(
            targetTable, Arrays.asList(keplerId));

        if (observedTargets == null || observedTargets.size() < 1) {
            throw new IllegalStateException(String.format(
                "Did not find observed target for keplerId ", keplerId));
        }
        ObservedTarget observedTarget = observedTargets.get(0);

        Set<Pixel> optimalAperture = new HashSet<Pixel>();
        for (Offset offset : observedTarget.getAperture()
            .getOffsets()) {
            optimalAperture.add(new Pixel(offset.getRow()
                + observedTarget.getAperture()
                    .getReferenceRow(), offset.getColumn()
                + observedTarget.getAperture()
                    .getReferenceColumn()));
        }

        for (TargetDefinition targetDefinition : observedTarget.getTargetDefinitions()) {
            int referenceRow = targetDefinition.getReferenceRow();
            int referenceColumn = targetDefinition.getReferenceColumn();

            for (Offset offset : targetDefinition.getMask()
                .getOffsets()) {
                AperturePixel pixel = new AperturePixel(referenceRow
                    + offset.getRow(), referenceColumn + offset.getColumn());
                pixel.setInOptimalAperture(optimalAperture.contains(new Pixel(
                    pixel.getRow(), pixel.getColumn())));
                if (pixelsInPrfCentroidApertureByKeplerId != null) {
                    Set<Pair<Integer, Integer>> pixelsInPrfCentroidAperture = pixelsInPrfCentroidApertureByKeplerId.get(keplerId);
                    if (pixelsInPrfCentroidAperture != null) {
                        pixel.setInPrfCentroidAperture(pixelsInPrfCentroidAperture.contains(Pair.of(
                            pixel.getRow(), pixel.getColumn())));
                    }
                }
                if (pixelsInFluxWeightedCentroidApertureByKeplerId != null) {
                    Set<Pair<Integer, Integer>> pixelsInFluxWeightedCentroidAperture = pixelsInFluxWeightedCentroidApertureByKeplerId.get(keplerId);
                    if (pixelsInFluxWeightedCentroidAperture != null) {
                        pixel.setInFluxWeightedCentroidAperture(pixelsInFluxWeightedCentroidAperture.contains(Pair.of(
                            pixel.getRow(), pixel.getColumn())));
                    }
                }
                fitsAperture.addPixel(
                    Pair.of(offset.getRow(), offset.getColumn()), pixel);
            }
        }

        return success;
    }

    public static SimpleIntTimeSeries extractSimpleIntTimeSeries(
        int gapFillValue, BinaryTable table, int valuesColumn)
        throws FitsException {

        int[] values = (int[]) table.getFlattenedColumn(valuesColumn);
        boolean[] gapIndicators = new boolean[values.length];
        setGapIndicators(gapFillValue, values, gapIndicators);

        return new SimpleIntTimeSeries(values, gapIndicators);
    }

    private static void setGapIndicators(int gapFillValue, int[] values,
        boolean[] gapIndicators) {

        for (int i = 0; i < values.length; i++) {
            if (values[i] == gapFillValue) {
                gapIndicators[i] = true;
            }
        }
    }

    public static int assembleQualityFlags(
        int startCadence,
        int cadence,
        TimestampSeries cadenceTimes,
        Map<Pixel, Float> cosmicRaysByPixel,
        Set<Integer> cadencesWithCosmicRays,
        Set<Integer> cadencesWithCollateralCosmicRays,
        List<Integer> argabrighteningIndices,
        Map<PdcExtractor.PdcFlag, SimpleFloatTimeSeries> timeSeriesByPdcFlagType,
        List<Integer> reactionWheelZeroCrossingIndices) {

        if (cadenceTimes == null) {
            throw new NullPointerException("cadenceTimes can't be null");
        }

        int qualityFlags = 0;
        DataAnomalyFlags dataAnomalyFlags = cadenceTimes.dataAnomalyFlags;
        if (dataAnomalyFlags.attitudeTweakIndicators[cadence - startCadence]) {
            qualityFlags |= QualityFlag.ATTITUDE_TWEAK.getBitValue();
        }
        if (dataAnomalyFlags.safeModeIndicators[cadence - startCadence]) {
            qualityFlags |= QualityFlag.SAFE_MODE.getBitValue();
        }
        if (dataAnomalyFlags.coarsePointIndicators[cadence - startCadence]) {
            qualityFlags |= QualityFlag.COARSE_POINT.getBitValue();
        }
        if (dataAnomalyFlags.argabrighteningIndicators[cadence - startCadence]) {
            qualityFlags |= QualityFlag.MULTICHANNEL_ARGABRIGHTENING.getBitValue();
        }
        if (dataAnomalyFlags.excludeIndicators[cadence - startCadence]) {
            qualityFlags |= QualityFlag.EXCLUDE.getBitValue();
        }
        if (dataAnomalyFlags.earthPointIndicators[cadence - startCadence]) {
            qualityFlags |= QualityFlag.EARTH_POINT.getBitValue();
        }

        if (cadenceTimes.isMmntmDmp[cadence - startCadence]) {
            qualityFlags |= QualityFlag.REACTION_WHEEL_DESAT.getBitValue();
        }
        if (cadenceTimes.isSefiAcc[cadence - startCadence]
            || cadenceTimes.isSefiCad[cadence - startCadence]
            || cadenceTimes.isLdeOos[cadence - startCadence]
            || cadenceTimes.isLdeParEr[cadence - startCadence]
            || cadenceTimes.isScrcErr[cadence - startCadence]) {
            qualityFlags |= QualityFlag.DETECTOR_ELECTRONICS_ANOMALY.getBitValue();
        }
        if (!cadenceTimes.isFinePnt[cadence - startCadence]) {
            qualityFlags |= QualityFlag.NOT_FINE_POINT.getBitValue();
        }
        if (cadenceTimes.gapIndicators[cadence - startCadence]) {
            qualityFlags |= QualityFlag.DATA_GAP.getBitValue();
        }

        if (cosmicRaysByPixel != null) {
            for (Pixel pixel : cosmicRaysByPixel.keySet()) {
                if (pixel.isInOptimalAperture()) {
                    qualityFlags |= QualityFlag.COSMIC_RAY.getBitValue();
                    break;
                }
            }
        }

        if (cadencesWithCosmicRays != null
            && cadencesWithCosmicRays.contains(cadence)) {
            qualityFlags |= QualityFlag.COSMIC_RAY.getBitValue();
        }

        if (cadencesWithCollateralCosmicRays != null
            && cadencesWithCollateralCosmicRays.contains(cadence)) {
            qualityFlags |= QualityFlag.COLLATERAL_COSMIC_RAY.getBitValue();
        }

        if (argabrighteningIndices != null) {
            if (argabrighteningIndices.contains(cadence - startCadence)) {
                qualityFlags |= QualityFlag.MODOUT_ARGABRIGHTENING.getBitValue();
            }
        }

        if (reactionWheelZeroCrossingIndices != null) {
            if (reactionWheelZeroCrossingIndices.contains(cadence
                - startCadence)) {
                qualityFlags |= QualityFlag.REACTION_WHEEL_ZERO_CROSSING.getBitValue();
            }
        }

        if (timeSeriesByPdcFlagType != null) {
            SimpleFloatTimeSeries discontinuities = timeSeriesByPdcFlagType.get(PdcExtractor.PdcFlag.DISCONTINUITIES);
            if (discontinuities != null) {
                if (!discontinuities.getGapIndicators()[cadence - startCadence]) {
                    qualityFlags |= QualityFlag.DISCONTINUITY.getBitValue();
                }
            }

            SimpleFloatTimeSeries outliers = timeSeriesByPdcFlagType.get(PdcExtractor.PdcFlag.OUTLIERS);
            if (outliers != null) {
                if (!outliers.getGapIndicators()[cadence - startCadence]) {
                    qualityFlags |= QualityFlag.OUTLIER.getBitValue();
                }
            }
        }

        return qualityFlags;
    }

    public static SimpleFloatTimeSeries extractSimpleTimeSeries(
        float gapFillValue, BinaryTable table, int valuesColumn)
        throws FitsException {

        float[] values = (float[]) table.getFlattenedColumn(valuesColumn);
        boolean[] gapIndicators = new boolean[values.length];
        setGapIndicators(gapFillValue, values, gapIndicators);

        return new SimpleFloatTimeSeries(values, gapIndicators);
    }

    public static CompoundFloatTimeSeries extractCompoundTimeSeries(
        float gapFillValue, BinaryTable table, int valuesColumn,
        int uncertaintiesColumn) throws FitsException {

        float[] values = (float[]) table.getFlattenedColumn(valuesColumn);
        float[] uncertainties = (float[]) table.getFlattenedColumn(uncertaintiesColumn);
        boolean[] gapIndicators = new boolean[values.length];
        setGapIndicators(gapFillValue, values, gapIndicators);

        return new CompoundFloatTimeSeries(values, uncertainties, gapIndicators);
    }

    private static void setGapIndicators(float gapFillValue, float[] values,
        boolean[] gapIndicators) {
        for (int i = 0; i < values.length; i++) {
            if (Float.isNaN(gapFillValue)) {
                if (Float.isNaN(values[i])) {
                    gapIndicators[i] = true;
                }
            } else if (values[i] == gapFillValue) {
                gapIndicators[i] = true;
            }
        }
    }

    public static CompoundDoubleTimeSeries extractCompoundDoubleTimeSeries(
        double gapFillValue, BinaryTable table, int valuesColumn,
        int uncertaintiesColumn) throws FitsException {

        double[] values = (double[]) table.getFlattenedColumn(valuesColumn);
        float[] uncertainties = (float[]) table.getFlattenedColumn(uncertaintiesColumn);
        boolean[] gapIndicators = new boolean[values.length];
        setGapIndicators(gapFillValue, values, gapIndicators);

        return new CompoundDoubleTimeSeries(values, uncertainties,
            gapIndicators);
    }

    public static SimpleDoubleTimeSeries extractSimpleDoubleTimeSeries(
        double gapFillValue, BinaryTable table, int valuesColumn)
        throws FitsException {

        double[] values = (double[]) table.getFlattenedColumn(valuesColumn);
        boolean[] gapIndicators = new boolean[values.length];
        setGapIndicators(gapFillValue, values, gapIndicators);

        return new SimpleDoubleTimeSeries(values, gapIndicators);
    }

    private static void setGapIndicators(double gapFillValue, double[] values,
        boolean[] gapIndicators) {

        for (int i = 0; i < values.length; i++) {
            if (Double.isNaN(gapFillValue)) {
                if (Double.isNaN(values[i])) {
                    gapIndicators[i] = true;
                }
            } else if (values[i] == gapFillValue) {
                gapIndicators[i] = true;
            }
        }
    }

    public static boolean validateTimes(
        int maxErrorsDisplayed,
        int keplerId,
        int startCadence,
        int endCadence,
        TimestampSeries cadenceTimes,
        Pair<Integer, Integer> paCadenceRange,
        Map<SimpleTimeSeriesType, SimpleFloatTimeSeries> simpleTimeSeriesByType,
        SimpleFloatTimeSeries fitsTimeCorrectionTimeSeries,
        SimpleDoubleTimeSeries fitsTimeTimeSeries) {

        if (simpleTimeSeriesByType == null) {
            log.error(String.format("Missing PA time series for %d keplerId",
                keplerId));
            return false;
        }
        SimpleFloatTimeSeries corrections = resizeSimpleTimeSeries(
            startCadence, endCadence, paCadenceRange,
            simpleTimeSeriesByType.get(SimpleTimeSeriesType.TIME_CORRECTION));
        SimpleFloatTimeSeries fitsCorrections = resizeSimpleTimeSeries(
            startCadence, endCadence, paCadenceRange,
            fitsTimeCorrectionTimeSeries);

        if (!ValidationUtils.diffSimpleTimeSeries(maxErrorsDisplayed,
            SimpleTimeSeriesType.TIME_CORRECTION.toString(), keplerId,
            corrections, fitsCorrections)) {
            return false;
        }

        SimpleDoubleTimeSeries times = calculateTimes(cadenceTimes, corrections);
        SimpleDoubleTimeSeries fitsTimes = resizeSimpleDoubleTimeSeries(
            startCadence, endCadence, paCadenceRange, fitsTimeTimeSeries);

        if (!ValidationUtils.diffSimpleDoubleTimeSeries(maxErrorsDisplayed,
            SimpleDoubleTimeSeriesType.TIME.toString(), keplerId, times,
            fitsTimes)) {
            return false;
        }

        return true;
    }

    private static SimpleDoubleTimeSeries calculateTimes(
        TimestampSeries cadenceTimes, SimpleFloatTimeSeries corrections) {

        if (cadenceTimes.midTimestamps.length != corrections.getValues().length) {
            throw new IllegalStateException(String.format(
                "barycentric corrections time series length, %d, "
                    + "does not match cadenceTimes length %d",
                corrections.getValues().length,
                cadenceTimes.midTimestamps.length));
        }

        double[] times = new double[cadenceTimes.midTimestamps.length];
        System.arraycopy(cadenceTimes.midTimestamps, 0, times, 0, times.length);
        boolean[] gaps = new boolean[cadenceTimes.gapIndicators.length];
        System.arraycopy(cadenceTimes.gapIndicators, 0, gaps, 0, gaps.length);

        for (int i = 0; i < times.length; i++) {
            if (corrections.getGapIndicators()[i]) {
                gaps[i] = true;
            }
            if (!gaps[i]) {
                times[i] = ModifiedJulianDate.mjdToKjd(cadenceTimes.midTimestamps[i])
                    + corrections.getValues()[i];
            }
        }
        return new SimpleDoubleTimeSeries(times, gaps);
    }

    public static SimpleFloatTimeSeries resizeSimpleTimeSeries(
        int startCadence, int endCadence,
        Pair<Integer, Integer> paCadenceRange,
        SimpleFloatTimeSeries simpleFloatTimeSeries) {

        if (startCadence > endCadence) {
            throw new IllegalStateException(String.format(
                "startCadence, %d, must be less than endCadence, %d",
                startCadence, endCadence));
        }
        if (startCadence < paCadenceRange.left
            || startCadence > paCadenceRange.right) {
            throw new IllegalStateException(String.format(
                "startCadence, %d, outside PA cadence range [%d, %d]",
                startCadence, paCadenceRange.left, paCadenceRange.right));
        }
        if (endCadence < paCadenceRange.left
            || endCadence > paCadenceRange.right) {
            throw new IllegalStateException(String.format(
                "endCadence, %d, outside PA cadence range [%d, %d]",
                endCadence, paCadenceRange.left, paCadenceRange.right));
        }

        int length = endCadence - startCadence + 1;
        if (simpleFloatTimeSeries.size() == length) {
            return simpleFloatTimeSeries;
        }
        int offset = startCadence - paCadenceRange.left;
        float[] fseries = new float[length];
        System.arraycopy(simpleFloatTimeSeries.getValues(), offset, fseries, 0,
            length);
        boolean[] gapIndicators = new boolean[length];
        System.arraycopy(simpleFloatTimeSeries.getGapIndicators(), offset,
            gapIndicators, 0, length);
        return new SimpleFloatTimeSeries(fseries, gapIndicators);
    }

    public static CompoundFloatTimeSeries resizeCompoundTimeSeries(
        int startCadence, int endCadence,
        Pair<Integer, Integer> paCadenceRange,
        CompoundFloatTimeSeries compoundFloatTimeSeries) {

        if (startCadence > endCadence) {
            throw new IllegalStateException(String.format(
                "startCadence, %d, must be less than endCadence, %d",
                startCadence, endCadence));
        }
        if (startCadence < paCadenceRange.left
            || startCadence > paCadenceRange.right) {
            throw new IllegalStateException(String.format(
                "startCadence, %d, outside PA cadence range [%d, %d]",
                startCadence, paCadenceRange.left, paCadenceRange.right));
        }
        if (endCadence < paCadenceRange.left
            || endCadence > paCadenceRange.right) {
            throw new IllegalStateException(String.format(
                "endCadence, %d, outside PA cadence range [%d, %d]",
                endCadence, paCadenceRange.left, paCadenceRange.right));
        }

        int length = endCadence - startCadence + 1;
        if (compoundFloatTimeSeries.size() == length) {
            return compoundFloatTimeSeries;
        }
        int offset = startCadence - paCadenceRange.left;
        float[] fseries = new float[length];
        System.arraycopy(compoundFloatTimeSeries.getValues(), offset, fseries,
            0, length);
        boolean[] gapIndicators = new boolean[length];
        System.arraycopy(compoundFloatTimeSeries.getGapIndicators(), offset,
            gapIndicators, 0, length);
        float[] uncertainties = new float[length];
        System.arraycopy(compoundFloatTimeSeries.getUncertainties(), offset,
            uncertainties, 0, length);
        return new CompoundFloatTimeSeries(fseries, uncertainties,
            gapIndicators);
    }

    public static CompoundDoubleTimeSeries resizeCompoundDoubleTimeSeries(
        int startCadence, int endCadence,
        Pair<Integer, Integer> paCadenceRange,
        CompoundDoubleTimeSeries compoundDoubleTimeSeries) {

        if (startCadence > endCadence) {
            throw new IllegalStateException(String.format(
                "startCadence, %d, must be less than endCadence, %d",
                startCadence, endCadence));
        }
        if (startCadence < paCadenceRange.left
            || startCadence > paCadenceRange.right) {
            throw new IllegalStateException(String.format(
                "startCadence, %d, outside PA cadence range [%d, %d]",
                startCadence, paCadenceRange.left, paCadenceRange.right));
        }
        if (endCadence < paCadenceRange.left
            || endCadence > paCadenceRange.right) {
            throw new IllegalStateException(String.format(
                "endCadence, %d, outside PA cadence range [%d, %d]",
                endCadence, paCadenceRange.left, paCadenceRange.right));
        }

        int length = endCadence - startCadence + 1;
        if (compoundDoubleTimeSeries.size() == length) {
            return compoundDoubleTimeSeries;
        }
        int offset = startCadence - paCadenceRange.left;
        double[] dseries = new double[length];
        System.arraycopy(compoundDoubleTimeSeries.getValues(), offset, dseries,
            0, length);
        boolean[] gapIndicators = new boolean[length];
        System.arraycopy(compoundDoubleTimeSeries.getGapIndicators(), offset,
            gapIndicators, 0, length);
        float[] uncertainties = new float[length];
        System.arraycopy(compoundDoubleTimeSeries.getUncertainties(), offset,
            uncertainties, 0, length);
        return new CompoundDoubleTimeSeries(dseries, uncertainties,
            gapIndicators);
    }

    public static SimpleIntTimeSeries resizeSimpleIntTimeSeries(
        int startCadence, int endCadence,
        Pair<Integer, Integer> paCadenceRange,
        SimpleIntTimeSeries simpleIntTimeSeries) {

        if (startCadence > endCadence) {
            throw new IllegalStateException(String.format(
                "startCadence, %d, must be less than endCadence, %d",
                startCadence, endCadence));
        }
        if (startCadence < paCadenceRange.left
            || startCadence > paCadenceRange.right) {
            throw new IllegalStateException(String.format(
                "startCadence, %d, outside PA cadence range [%d, %d]",
                startCadence, paCadenceRange.left, paCadenceRange.right));
        }
        if (endCadence < paCadenceRange.left
            || endCadence > paCadenceRange.right) {
            throw new IllegalStateException(String.format(
                "endCadence, %d, outside PA cadence range [%d, %d]",
                endCadence, paCadenceRange.left, paCadenceRange.right));
        }

        int length = endCadence - startCadence + 1;
        if (simpleIntTimeSeries.size() == length) {
            return simpleIntTimeSeries;
        }
        int offset = startCadence - paCadenceRange.left;
        int[] iseries = new int[length];
        System.arraycopy(simpleIntTimeSeries.getValues(), offset, iseries, 0,
            length);
        boolean[] gapIndicators = new boolean[length];
        System.arraycopy(simpleIntTimeSeries.getGapIndicators(), offset,
            gapIndicators, 0, length);
        return new SimpleIntTimeSeries(iseries, gapIndicators);
    }

    public static SimpleDoubleTimeSeries resizeSimpleDoubleTimeSeries(
        int startCadence, int endCadence,
        Pair<Integer, Integer> paCadenceRange,
        SimpleDoubleTimeSeries simpleDoubleTimeSeries) {

        if (startCadence > endCadence) {
            throw new IllegalStateException(String.format(
                "startCadence, %d, must be less than endCadence, %d",
                startCadence, endCadence));
        }
        if (startCadence < paCadenceRange.left
            || startCadence > paCadenceRange.right) {
            throw new IllegalStateException(String.format(
                "startCadence, %d, outside PA cadence range [%d, %d]",
                startCadence, paCadenceRange.left, paCadenceRange.right));
        }
        if (endCadence < paCadenceRange.left
            || endCadence > paCadenceRange.right) {
            throw new IllegalStateException(String.format(
                "endCadence, %d, outside PA cadence range [%d, %d]",
                endCadence, paCadenceRange.left, paCadenceRange.right));
        }

        int length = endCadence - startCadence + 1;
        if (simpleDoubleTimeSeries.size() == length) {
            return simpleDoubleTimeSeries;
        }
        int offset = startCadence - paCadenceRange.left;
        double[] dseries = new double[length];
        System.arraycopy(simpleDoubleTimeSeries.getValues(), offset, dseries,
            0, length);
        boolean[] gapIndicators = new boolean[length];
        System.arraycopy(simpleDoubleTimeSeries.getGapIndicators(), offset,
            gapIndicators, 0, length);
        return new SimpleDoubleTimeSeries(dseries, gapIndicators);
    }

    public static SimpleFloatTimeSeries mergeSimple(
        SimpleFloatTimeSeries existingTimeSeries,
        SimpleFloatTimeSeries newTimeSeries) {

        if (existingTimeSeries == null) {
            return newTimeSeries;
        }
        if (newTimeSeries == null) {
            return existingTimeSeries;
        }

        float[] values = ArrayUtils.append(existingTimeSeries.getValues(),
            newTimeSeries.getValues());
        boolean[] gapIndicators = ArrayUtils.append(
            existingTimeSeries.getGapIndicators(),
            newTimeSeries.getGapIndicators());

        return new SimpleFloatTimeSeries(values, gapIndicators);
    }

    public static CompoundFloatTimeSeries mergeCompound(
        CompoundFloatTimeSeries existingTimeSeries,
        CompoundFloatTimeSeries newTimeSeries) {

        if (existingTimeSeries == null) {
            return newTimeSeries;
        }
        if (newTimeSeries == null) {
            return existingTimeSeries;
        }

        float[] values = ArrayUtils.append(existingTimeSeries.getValues(),
            newTimeSeries.getValues());
        float[] uncertainties = ArrayUtils.append(
            existingTimeSeries.getUncertainties(),
            newTimeSeries.getUncertainties());
        boolean[] gapIndicators = ArrayUtils.append(
            existingTimeSeries.getGapIndicators(),
            newTimeSeries.getGapIndicators());

        return new CompoundFloatTimeSeries(values, uncertainties, gapIndicators);
    }

    public static CompoundDoubleTimeSeries mergeDouble(
        CompoundDoubleTimeSeries existingTimeSeries,
        CompoundDoubleTimeSeries newTimeSeries) {

        if (existingTimeSeries == null) {
            return newTimeSeries;
        }
        if (newTimeSeries == null) {
            return existingTimeSeries;
        }

        double[] values = ArrayUtils.append(existingTimeSeries.getValues(),
            newTimeSeries.getValues());
        float[] uncertainties = ArrayUtils.append(
            existingTimeSeries.getUncertainties(),
            newTimeSeries.getUncertainties());
        boolean[] gapIndicators = ArrayUtils.append(
            existingTimeSeries.getGapIndicators(),
            newTimeSeries.getGapIndicators());

        return new CompoundDoubleTimeSeries(values, uncertainties,
            gapIndicators);
    }

    public static CompoundFloatTimeSeries convertCorrectedTimeSeries(
        CorrectedFluxTimeSeries correctedFluxTimeSeries,
        OutliersTimeSeries outliers) {

        float[] values = correctedFluxTimeSeries.getValues();
        float[] uncertainties = correctedFluxTimeSeries.getUncertainties();
        boolean[] gapIndicators = correctedFluxTimeSeries.getGapIndicators();

        for (int index : correctedFluxTimeSeries.getFilledIndices()) {
            gapIndicators[index] = true;
        }

        for (int i = 0; i < outliers.getIndices().length; i++) {
            int outlierIndex = outliers.getIndices()[i];
            values[outlierIndex] = outliers.getValues()[i];
            gapIndicators[outlierIndex] = false;
            uncertainties[outlierIndex] = outliers.getUncertainties()[i];
        }

        return new CompoundFloatTimeSeries(values, uncertainties, gapIndicators);
    }

    public static boolean floatsEqual(float floatA, float floatB,
        float tolerance) {

        if (Math.abs(floatA - floatB) < tolerance) {
            return true;
        }

        return false;
    }

    public static boolean doublesEqual(double doubleA, double doubleB,
        double tolerance) {

        if (Math.abs(doubleA - doubleB) < tolerance) {
            return true;
        }

        return false;
    }

    public static boolean floatsEqual(Float floatA, Float floatB,
        Float tolerance) {

        if (floatA == null) {
            throw new NullPointerException("floatA can't be null");
        }
        if (floatB == null) {
            throw new NullPointerException("floatB can't be null");
        }
        if (tolerance == null) {
            throw new NullPointerException("tolerance can't be null");
        }

        if (Math.abs(floatA - floatB) < tolerance) {
            return true;
        }

        return false;
    }

    public static boolean doublesEqual(Double doubleA, Double doubleB,
        Double tolerance) {

        if (doubleA == null) {
            throw new NullPointerException("doubleA can't be null");
        }
        if (doubleB == null) {
            throw new NullPointerException("doubleB can't be null");
        }
        if (tolerance == null) {
            throw new NullPointerException("tolerance can't be null");
        }

        if (Math.abs(doubleA - doubleB) < tolerance) {
            return true;
        }

        return false;
    }

    public static boolean numbersEqual(Number numberA, Number numberB,
        Double tolerance) {

        if (numberA == null) {
            throw new NullPointerException("numberA can't be null");
        }
        if (numberB == null) {
            throw new NullPointerException("numberB can't be null");
        }
        if (tolerance == null) {
            throw new NullPointerException("tolerance can't be null");
        }

        if (Math.abs(numberA.doubleValue() - numberB.doubleValue()) < tolerance) {
            return true;
        }

        return false;
    }

    public static boolean diffSimpleIntTimeSeries(int maxErrorsDisplayed,
        String type, int keplerId, SimpleIntTimeSeries taskTimeSeries,
        SimpleIntTimeSeries fitsTimeSeries) {

        boolean equals = true;
        StringBuffer output = new StringBuffer();
        output.append(String.format(
            "\nTime series of type %s for Kepler ID %d differ", type, keplerId));
        output.append("\nIndex\tTask file (value, gap)\tFITS file (value, gap)\n");

        int errorCount = 0;
        int n = Math.min(taskTimeSeries.getValues().length,
            fitsTimeSeries.getValues().length);
        for (int i = 0; i < n; i++) {

            int valueA = taskTimeSeries.getValues()[i];
            int valueB = fitsTimeSeries.getValues()[i];
            boolean gapIndicatorA = taskTimeSeries.getGapIndicators()[i];
            boolean gapIndicatorB = fitsTimeSeries.getGapIndicators()[i];

            if (gapIndicatorA != gapIndicatorB || !gapIndicatorA
                && valueA != valueB) {

                equals = false;
                if (errorCount++ >= maxErrorsDisplayed) {
                    continue;
                }

                output.append(i)
                    .append("\t");
                output.append(valueA)
                    .append(" ")
                    .append(gapIndicatorA)
                    .append("\t");
                output.append(valueB)
                    .append(" ")
                    .append(gapIndicatorB)
                    .append("\n");
            }
        }

        if (!equals) {
            if (errorCount >= maxErrorsDisplayed) {
                output.append("...\n");
            }
            output.append(String.format("%d error%s in %d values (%.2f%%)\n",
                errorCount, errorCount > 1 ? "s" : "", n, (double) errorCount
                    / n * 100.0));
            log.error(output.toString());
        }

        return equals;
    }

    public static boolean diffSimpleTimeSeries(int maxErrorsDisplayed,
        String type, int keplerId, SimpleFloatTimeSeries taskTimeSeries,
        SimpleFloatTimeSeries fitsTimeSeries) {

        boolean equals = true;
        StringBuffer output = new StringBuffer();
        output.append(String.format(
            "\nTime series of type %s for Kepler ID %d differ", type, keplerId));
        output.append("\nIndex\tTask file (value, gap)\tFITS file (value, gap)\n");

        int errorCount = 0;
        int n = Math.min(taskTimeSeries.getValues().length,
            fitsTimeSeries.getValues().length);
        for (int i = 0; i < n; i++) {

            float valueA = taskTimeSeries.getValues()[i];
            float valueB = fitsTimeSeries.getValues()[i];
            boolean gapIndicatorA = taskTimeSeries.getGapIndicators()[i];
            boolean gapIndicatorB = fitsTimeSeries.getGapIndicators()[i];

            if (gapIndicatorA != gapIndicatorB || !gapIndicatorA
                && !floatsEqual(valueA, valueB, 0.00000001F)) {

                equals = false;
                if (errorCount++ >= maxErrorsDisplayed) {
                    continue;
                }

                output.append(i)
                    .append("\t");
                output.append(valueA)
                    .append(" ")
                    .append(gapIndicatorA)
                    .append("\t");
                output.append(valueB)
                    .append(" ")
                    .append(gapIndicatorB)
                    .append("\n");
            }
        }

        if (!equals) {
            if (errorCount >= maxErrorsDisplayed) {
                output.append("...\n");
            }
            output.append(String.format("%d error%s in %d values (%.2f%%)\n",
                errorCount, errorCount > 1 ? "s" : "", n, (double) errorCount
                    / n * 100.0));
            log.error(output.toString());
        }

        return equals;
    }

    public static boolean diffCompoundTimeSeries(int maxErrorsDisplayed,
        String type, int keplerId, CompoundFloatTimeSeries taskTimeSeries,
        CompoundFloatTimeSeries fitsTimeSeries) {

        boolean equals = true;
        StringBuffer output = new StringBuffer();
        output.append(String.format(
            "\nTime series of type %s for Kepler ID %d differ", type, keplerId));
        output.append("\nIndex\tTask file (value, unc, gap)\tFITS file (value, unc, gap)\n");

        int errorCount = 0;
        int n = Math.min(taskTimeSeries.getValues().length,
            fitsTimeSeries.getValues().length);
        for (int i = 0; i < n; i++) {
            float valueA = taskTimeSeries.getValues()[i];
            float valueB = fitsTimeSeries.getValues()[i];
            float uncertaintyA = taskTimeSeries.getUncertainties()[i];
            float uncertaintyB = fitsTimeSeries.getUncertainties()[i];
            boolean gapIndicatorA = taskTimeSeries.getGapIndicators()[i];
            boolean gapIndicatorB = fitsTimeSeries.getGapIndicators()[i];

            if (gapIndicatorA != gapIndicatorB || !gapIndicatorA
                && (valueA != valueB || uncertaintyA != uncertaintyB)) {

                equals = false;
                if (errorCount++ >= maxErrorsDisplayed) {
                    continue;
                }

                output.append(i)
                    .append("\t");
                output.append(valueA)
                    .append(" ")
                    .append(uncertaintyA)
                    .append(" ")
                    .append(gapIndicatorA)
                    .append("\t");
                output.append(valueB)
                    .append(" ")
                    .append(uncertaintyB)
                    .append(" ")
                    .append(gapIndicatorB)
                    .append("\n");
            }
        }

        if (!equals) {
            if (errorCount >= maxErrorsDisplayed) {
                output.append("...\n");
            }
            output.append(String.format("%d error%s in %d values (%.2f%%)\n",
                errorCount, errorCount > 1 ? "s" : "", n, (double) errorCount
                    / n * 100.0));
            log.error(output.toString());
        }

        return equals;
    }

    public static boolean diffCompoundDoubleTimeSeries(int maxErrorsDisplayed,
        String type, int keplerId, CompoundDoubleTimeSeries taskTimeSeries,
        CompoundDoubleTimeSeries fitsTimeSeries) {

        boolean equals = true;
        StringBuffer output = new StringBuffer();
        output.append(String.format(
            "\nTime series of type %s for Kepler ID %d differ", type, keplerId));
        output.append("\nIndex\tTask file (value, unc, gap)\tFITS file (value, unc, gap)\n");

        int errorCount = 0;
        int n = Math.min(taskTimeSeries.getValues().length,
            fitsTimeSeries.getValues().length);
        for (int i = 0; i < n; i++) {

            double valueA = taskTimeSeries.getValues()[i];
            double valueB = fitsTimeSeries.getValues()[i];
            float uncertaintyA = taskTimeSeries.getUncertainties()[i];
            float uncertaintyB = fitsTimeSeries.getUncertainties()[i];
            boolean gapIndicatorA = taskTimeSeries.getGapIndicators()[i];
            boolean gapIndicatorB = fitsTimeSeries.getGapIndicators()[i];

            if (gapIndicatorA != gapIndicatorB || !gapIndicatorA
                && (valueA != valueB || uncertaintyA != uncertaintyB)) {

                equals = false;
                if (errorCount++ >= maxErrorsDisplayed) {
                    continue;
                }

                output.append(i)
                    .append("\t");
                output.append(valueA)
                    .append(" ")
                    .append(uncertaintyA)
                    .append(" ")
                    .append(gapIndicatorA)
                    .append("\t");
                output.append(valueB)
                    .append(" ")
                    .append(uncertaintyB)
                    .append(" ")
                    .append(gapIndicatorB)
                    .append("\n");
            }
        }

        if (!equals) {
            if (errorCount >= maxErrorsDisplayed) {
                output.append("...\n");
            }
            output.append(String.format("%d error%s in %d values (%.2f%%)\n",
                errorCount, errorCount > 1 ? "s" : "", n, (double) errorCount
                    / n * 100.0));
            log.error(output.toString());
        }

        return equals;
    }

    public static boolean diffSimpleDoubleTimeSeries(int maxErrorsDisplayed,
        String type, int keplerId, SimpleDoubleTimeSeries taskTimeSeries,
        SimpleDoubleTimeSeries fitsTimeSeries) {

        boolean equals = true;
        StringBuffer output = new StringBuffer();
        output.append(String.format(
            "\nTime series of type %s for Kepler ID %d differ", type, keplerId));
        output.append("\nIndex\tTask file (value, gap)\tFITS file (value, gap)\n");

        int errorCount = 0;
        int n = Math.min(taskTimeSeries.getValues().length,
            fitsTimeSeries.getValues().length);
        for (int i = 0; i < n; i++) {

            double valueA = taskTimeSeries.getValues()[i];
            double valueB = fitsTimeSeries.getValues()[i];
            boolean gapIndicatorA = taskTimeSeries.getGapIndicators()[i];
            boolean gapIndicatorB = fitsTimeSeries.getGapIndicators()[i];

            if (gapIndicatorA != gapIndicatorB || !gapIndicatorA
                && !doublesEqual(valueA, valueB, 0.00000001F)) {

                equals = false;
                if (errorCount++ >= maxErrorsDisplayed) {
                    continue;
                }

                output.append(i)
                    .append("\t");
                output.append(valueA)
                    .append(" ")
                    .append(gapIndicatorA)
                    .append("\t");
                output.append(valueB)
                    .append(" ")
                    .append(gapIndicatorB)
                    .append("\n");
            }
        }

        if (!equals) {
            if (errorCount >= maxErrorsDisplayed) {
                output.append("...\n");
            }
            output.append(String.format("%d error%s in %d values (%.2f%%)\n",
                errorCount, errorCount > 1 ? "s" : "", n, (double) errorCount
                    / n * 100.0));
            log.error(output.toString());
        }

        return equals;
    }

    public static void extractIntKeywords(File file, Set<String> keywords,
        Map<String, Integer> valueByKeyword) throws FitsException, IOException {

        Fits fitsFile = new Fits(file);
        try {
            getFitsFileHeader(fitsFile);
            valueByKeyword.putAll(extractIntKeywords(file.getName(), fitsFile,
                keywords));
        } finally {
            fitsFile.getStream()
                .close();
        }
    }

    public static void extractStringKeywords(File file, Set<String> keywords,
        Map<String, String> valueByKeyword) throws FitsException, IOException {

        Fits fitsFile = new Fits(file);
        try {
            getFitsFileHeader(fitsFile);
            valueByKeyword.putAll(extractStringKeywords(file.getName(),
                fitsFile, keywords));
        } finally {
            fitsFile.getStream()
                .close();
        }
    }

    public static void extractFloatKeywords(File file, Set<String> keywords,
        Map<String, Float> valueByKeyword) throws FitsException, IOException {

        Fits fitsFile = new Fits(file);
        try {
            getFitsFileHeader(fitsFile);
            valueByKeyword.putAll(extractFloatKeywords(file.getName(),
                fitsFile, keywords));
        } finally {
            fitsFile.getStream()
                .close();
        }
    }

    public static PdcGoodnessMetric massageNaNs(
        PdcGoodnessMetric pdcGoodnessMetric, float newValue) {

        PdcGoodnessComponent correlation = pdcGoodnessMetric.getCorrelation();
        if (Float.isNaN(correlation.getPercentile())) {
            correlation.setPercentile(newValue);
        }
        if (Float.isNaN(correlation.getValue())) {
            correlation.setValue(newValue);
        }

        PdcGoodnessComponent deltaVariability = pdcGoodnessMetric.getDeltaVariability();
        if (Float.isNaN(deltaVariability.getPercentile())) {
            deltaVariability.setPercentile(newValue);
        }
        if (Float.isNaN(deltaVariability.getValue())) {
            deltaVariability.setValue(newValue);
        }

        PdcGoodnessComponent earthPointRemoval = pdcGoodnessMetric.getEarthPointRemoval();
        if (Float.isNaN(earthPointRemoval.getPercentile())) {
            earthPointRemoval.setPercentile(newValue);
        }
        if (Float.isNaN(earthPointRemoval.getValue())) {
            earthPointRemoval.setValue(newValue);
        }

        PdcGoodnessComponent introducedNoise = pdcGoodnessMetric.getIntroducedNoise();
        if (Float.isNaN(introducedNoise.getPercentile())) {
            introducedNoise.setPercentile(newValue);
        }
        if (Float.isNaN(introducedNoise.getValue())) {
            introducedNoise.setValue(newValue);
        }

        PdcGoodnessComponent total = pdcGoodnessMetric.getTotal();
        if (Float.isNaN(total.getPercentile())) {
            total.setPercentile(newValue);
        }
        if (Float.isNaN(total.getValue())) {
            total.setValue(newValue);
        }

        return new PdcGoodnessMetric(correlation, deltaVariability,
            earthPointRemoval, introducedNoise, total);
    }
}
