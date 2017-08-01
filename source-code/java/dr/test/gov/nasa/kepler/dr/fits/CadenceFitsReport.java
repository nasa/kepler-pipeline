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

package gov.nasa.kepler.dr.fits;

import gov.nasa.kepler.common.ConfigMap;
import gov.nasa.kepler.common.FitsConstants;
import gov.nasa.kepler.common.FitsUtils;
import gov.nasa.kepler.dr.dispatch.DispatcherWrapperFactory;
import gov.nasa.kepler.mc.configmap.ConfigMapOperations;
import gov.nasa.kepler.nm.DataProductMessageDocument;
import gov.nasa.kepler.nm.DataProductMessageXB;
import gov.nasa.kepler.nm.FileXB;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import nom.tam.fits.BasicHDU;
import nom.tam.fits.Fits;
import nom.tam.fits.Header;

/**
 * This class reads the cadence number keywords from a set of FITS files
 * specified by a notification message and reports on the cadence number ranges
 * and gaps.
 * 
 * @author tklaus
 * 
 */
public class CadenceFitsReport {

    private static final double DIFF_SECONDS_ALLOWED = 3.0;

    private static final int SECONDS_PER_DAY = 86400;

    private String sdnmPath;

    private List<String> datasetNames = new ArrayList<String>();

    private List<Integer> lcInters = new ArrayList<Integer>();
    private List<Integer> lcCounts = new ArrayList<Integer>();
    private List<Integer> scInters = new ArrayList<Integer>();
    private List<Integer> scCounts = new ArrayList<Integer>();
    private List<Integer> scConfigIds = new ArrayList<Integer>();
    private List<Double> startMjds = new ArrayList<Double>();

    private Map<Integer, ConfigMap> scConfigIdToConfigMap = new HashMap<Integer, ConfigMap>();

    public CadenceFitsReport(String sdnmFilename) {
        this.sdnmPath = sdnmFilename;
    }

    public void report() throws Exception {
        File nmFile = new File(sdnmPath);

        if (nmFile.exists() && nmFile.isFile()) {
            File fitsDir = nmFile.getParentFile();

            DataProductMessageDocument doc = DataProductMessageDocument.Factory.parse(nmFile);
            DataProductMessageXB message = doc.getDataProductMessage();
            FileXB[] fileList = message.getFileList()
                .getFileArray();
            List<String> filenameList = new ArrayList<String>();

            for (FileXB file : fileList) {
                if (file.getFilename()
                    .endsWith("-targ.fits")) {
                    filenameList.add(file.getFilename());
                }
            }

            Collections.sort(filenameList);

            int filenameCount = 0;
            for (String filename : filenameList) {
                if (filenameCount % 1000 == 0) {
                    System.out.println("Completed parsing " + filenameCount
                        + " of " + filenameList.size() + " files.");
                }
                filenameCount++;

                File fitsFile = new File(fitsDir, filename);

                // System.out.println("reading: " + fitsFile);

                Fits srcFits = new Fits(fitsFile.getAbsolutePath()); // Fits(File)
                // broken!
                srcFits.read(); // read all
                BasicHDU primaryHdu = srcFits.getHDU(0);
                Header primaryHduHeader = primaryHdu.getHeader();

                String datasetName = primaryHduHeader.getStringValue("DATSETNM");

                int lcInter = primaryHduHeader.getIntValue("LC_INTER");
                int lcCount = primaryHduHeader.getIntValue("LC_COUNT");
                int scInter = primaryHduHeader.getIntValue("SC_INTER");
                int scCount = primaryHduHeader.getIntValue("SC_COUNT");
                int scConfigId = FitsUtils.getHeaderIntValueChecked(
                    primaryHduHeader,
                    FitsConstants.SCCONFID_KW);
                double startMjd = FitsUtils.getHeaderDoubleValueChecked(
                    primaryHduHeader, FitsConstants.STARTIME_KW);

                datasetNames.add(datasetName);

                lcInters.add(lcInter);
                lcCounts.add(lcCount);
                scInters.add(scInter);
                scCounts.add(scCount);
                scConfigIds.add(scConfigId);
                startMjds.add(startMjd);
            }

            verifyRanges("LC_INTER", lcInters);
            verifyRanges("LC_COUNT", lcCounts);
            verifyRanges("SC_INTER", scInters);
            verifyRanges("SC_COUNT", scCounts);

            boolean hasLongCadenceFiles = false;
            boolean hasShortCadenceFiles = false;
            for (String filename : filenameList) {
                if (filename.endsWith(DispatcherWrapperFactory.LONG_CADENCE_TARGET)) {
                    hasLongCadenceFiles = true;
                } else if (filename.endsWith(DispatcherWrapperFactory.SHORT_CADENCE_TARGET)) {
                    hasShortCadenceFiles = true;
                }
            }

            if (hasLongCadenceFiles && hasShortCadenceFiles) {
                System.out.println("Unable to validate startMjds because the nm file contains both lc and sc files.");
            } else if (hasLongCadenceFiles) {
                validateLcStartMjds();
            } else if (hasShortCadenceFiles) {
                validateScStartMjds();
            } else {
                System.out.println("Unable to validate startMjds because the nm file contains neither lc nor sc files.");
            }
        } else {
            throw new Exception(
                "Specified NM does not exist or is not a regular file: "
                    + nmFile);
        }
    }

    private void validateLcStartMjds() {
        ConfigMapOperations configMapOperations = new ConfigMapOperations();

        int prevLcInter = 0;
        double prevStartMjd = 0;
        int lcStartMjdInconsistencyCount = 0;
        for (int i = 0; i < startMjds.size(); i++) {
            int lcInter = lcInters.get(i);
            int scConfigId = scConfigIds.get(i);
            double startMjd = startMjds.get(i);

            ConfigMap configMap = scConfigIdToConfigMap.get(scConfigId);
            if (configMap == null) {
                configMap = configMapOperations.retrieveConfigMap(scConfigId);
                scConfigIdToConfigMap.put(scConfigId, configMap);
            }

            if (i == 0) {
                // First value.
                prevLcInter = lcInter;
                prevStartMjd = startMjd;
            } else {
                // Compare this value to previous.
                int lcInterDiff = lcInter - prevLcInter;
                double secondsPerShortCadence = configMap.getSecondsPerShortCadence();
                int shortCadencesPerLongCadence = configMap.getShortCadencesPerLongCadence();
                double lcInterDiffSeconds = secondsPerShortCadence
                    * shortCadencesPerLongCadence * lcInterDiff;

                double startMjdDiffDays = startMjd - prevStartMjd;
                double startMjdDiffSeconds = startMjdDiffDays * SECONDS_PER_DAY;

                if (Math.abs(lcInterDiffSeconds - startMjdDiffSeconds) > DIFF_SECONDS_ALLOWED) {
                    System.out.println("Based on "
                        + FitsConstants.LC_INTER_KW
                        + ", the seconds difference was expected to be "
                        + lcInterDiffSeconds
                        + ", but the seconds difference between "
                        + FitsConstants.STARTIME_KW
                        + " was actually "
                        + startMjdDiffSeconds
                        + toString(datasetNames.get(i - 1),
                            lcInters.get(i - 1), scConfigIds.get(i - 1),
                            startMjds.get(i - 1))
                        + toString(datasetNames.get(i), lcInters.get(i),
                            scConfigIds.get(i), startMjds.get(i)));

                    lcStartMjdInconsistencyCount++;
                }

                prevLcInter = lcInter;
                prevStartMjd = startMjd;
            }
        }

        System.out.println("Found " + lcStartMjdInconsistencyCount
            + " inconsistencies between "
            + FitsConstants.LC_INTER_KW + " and "
            + FitsConstants.STARTIME_KW);
    }

    private void validateScStartMjds() {
        ConfigMapOperations configMapOperations = new ConfigMapOperations();

        int prevScInter = 0;
        double prevStartMjd = 0;
        int scStartMjdInconsistencyCount = 0;
        for (int i = 0; i < startMjds.size(); i++) {
            int scInter = scInters.get(i);
            int scConfigId = scConfigIds.get(i);
            double startMjd = startMjds.get(i);

            ConfigMap configMap = scConfigIdToConfigMap.get(scConfigId);
            if (configMap == null) {
                configMap = configMapOperations.retrieveConfigMap(scConfigId);
                scConfigIdToConfigMap.put(scConfigId, configMap);
            }

            if (i == 0) {
                // First value.
                prevScInter = scInter;
                prevStartMjd = startMjd;
            } else {
                // Compare this value to previous.
                int scInterDiff = scInter - prevScInter;
                double secondsPerShortCadence = configMap.getSecondsPerShortCadence();
                double scInterDiffSeconds = secondsPerShortCadence
                    * scInterDiff;

                double startMjdDiffDays = startMjd - prevStartMjd;
                double startMjdDiffSeconds = startMjdDiffDays * SECONDS_PER_DAY;

                if (Math.abs(scInterDiffSeconds - startMjdDiffSeconds) > DIFF_SECONDS_ALLOWED) {
                    System.out.println("Based on "
                        + FitsConstants.SC_INTER_KW
                        + ", the seconds difference was expected to be "
                        + scInterDiffSeconds
                        + ", but the seconds difference between "
                        + FitsConstants.STARTIME_KW
                        + " was actually "
                        + startMjdDiffSeconds
                        + toString(datasetNames.get(i - 1),
                            scInters.get(i - 1), scConfigIds.get(i - 1),
                            startMjds.get(i - 1))
                        + toString(datasetNames.get(i), scInters.get(i),
                            scConfigIds.get(i), startMjds.get(i)));

                    scStartMjdInconsistencyCount++;
                }

                prevScInter = scInter;
                prevStartMjd = startMjd;
            }
        }

        System.out.println("Found " + scStartMjdInconsistencyCount
            + " inconsistencies between "
            + FitsConstants.SC_INTER_KW + " and "
            + FitsConstants.STARTIME_KW);
    }

    private String toString(String datasetName, int inter, int scConfigId,
        double startMjd) {
        return "\ndatasetname: " + datasetName + "\n  inter: " + inter
            + "\n  scConfigId: " + scConfigId + "\n  startMjd: " + startMjd;
    }

    private void verifyRanges(String label, List<Integer> cadenceNums) {
        System.out.println(label + " REPORT START");

        if (cadenceNums.size() == 0) {
            System.out.println("     " + label + " list is EMPTY");
            System.out.println(label + " REPORT END");
            return;
        }

        int indexLast = cadenceNums.size() - 1;

        System.out.println("  " + label + " START [0][" + datasetNames.get(0)
            + "] = " + cadenceNums.get(0));
        System.out.println("  " + label + " END [" + indexLast + "]["
            + datasetNames.get(indexLast) + "] = " + cadenceNums.get(indexLast));

        int previous = -1;
        int cadenceIndex = 0;

        for (Integer cadenceNum : cadenceNums) {
            String datasetName = datasetNames.get(cadenceIndex);
            if (previous != -1) {
                if (previous == cadenceNum) {
                    System.out.println("     " + label + " DUPLICATE["
                        + cadenceIndex + "][" + datasetName + "]: "
                        + cadenceNum);
                } else if (previous != (cadenceNum - 1)) {
                    int gapStart = previous + 1;
                    int gapEnd = cadenceNum - 1;

                    if (gapStart == gapEnd) {
                        System.out.println("     " + label + " GAP["
                            + cadenceIndex + "][" + datasetName + "]: missing "
                            + gapStart);
                    } else {
                        System.out.println("     " + label + " GAP["
                            + cadenceIndex + "][" + datasetName + "]: missing "
                            + gapStart + " - " + gapEnd);
                    }
                }
            }

            previous = cadenceNum;
            cadenceIndex++;
        }
        System.out.println(label + " REPORT END");
    }

    /**
     * @param args
     * @throws IOException
     * @throws Exception
     */
    public static void main(String[] args) throws Exception {
        CadenceFitsReport report;

        if (args.length != 1) {
            throw new Exception("USAGE: fits-report NM_PATH");
        }

        report = new CadenceFitsReport(args[0]);
        report.report();
    }
}
