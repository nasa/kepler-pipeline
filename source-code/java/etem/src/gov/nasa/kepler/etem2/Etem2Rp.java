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

package gov.nasa.kepler.etem2;

import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.common.pi.PlannedPhotometerConfigParameters;
import gov.nasa.kepler.dr.dispatch.DispatcherWrapperFactory;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.log4j.Level;
import org.apache.log4j.Logger;

/**
 * Create reference pixel files from ETEM data
 * 
 * @author tklaus
 * @author jgunter
 * 
 */
public class Etem2Rp {

    private static final Log log = LogFactory.getLog(Etem2Rp.class);

    private String inputDir;
    private String outputDir;
    private PlannedPhotometerConfigParameters photometerConfigParams;
    private double vtcStart;
    private double secondsPerShortCadence;
    private int startCadence;
    private int endCadence;
    private int longCadencesPerBaseline;
    private double secondsPerLongCadence;

    /*
     * TODO: most of these are hard-coded. Is that correct? private int
     * headerFlags; private int longCadenceTargetTableId; private int
     * shortCadenceTargetTableId; private int backgroundTargetTableId; private
     * int backgroundApertureTableId; private int scienceApertureTableId; //
     * private int referencePixelTargetTableId; private int compressionTableId;
     */

    public Etem2Rp(String inputDir, String outputDir,
        PlannedPhotometerConfigParameters photometerConfigParams, double vtcStart,  double secondsPerShortCadence,
        int startCadence,
        int endCadence, int longCadencesPerBaseline,
        double secondsPerLongCadence) {
        this.inputDir = inputDir;
        this.outputDir = outputDir;
        this.photometerConfigParams = photometerConfigParams;
        this.secondsPerShortCadence = secondsPerShortCadence;
        // need to add the secondsPerShortCadence to match the initial vtc increment performed in DataSetPacker
        this.vtcStart = vtcStart + secondsPerShortCadence;
        this.startCadence = startCadence;
        this.endCadence = endCadence;
        this.longCadencesPerBaseline = longCadencesPerBaseline;
        this.secondsPerLongCadence = secondsPerLongCadence;
    }

    public static void main(String[] args) throws Exception {
        Logger logger = Logger.getLogger(DataSetPacker.class);
        logger.setLevel( Level.WARN );
        org.apache.log4j.BasicConfigurator.configure();

        int i = 0;
               
        Etem2Rp c = new Etem2Rp(args[i++], // inputDir
        args[i++], // outputDir
        new PlannedPhotometerConfigParameters(),
        Double.valueOf(args[i++]), // vtcStart;
        Double.valueOf(args[i++]), // secondsPerShortCadence;
        Integer.valueOf(args[i++]), // startCadence;
        Integer.valueOf(args[i++]), // endCadence;
        Integer.valueOf(args[i++]), // numLongCadencesPerBaseline;
        Double.valueOf(args[i++]) // numShortCadencesPerLongCadence;
        );
        
        c.writeFiles();
    }

    public void writeFiles() throws Exception {

//        int nRefPixels[][] = new int[100][100];
        int nRefPixels[][] = new int[FcConstants.modulesList.length][FcConstants.outputsList.length];

        int m;
        int o;
        for (m = 0; m < FcConstants.modulesList.length; m++) {
            for (o = 0; o < FcConstants.outputsList.length; o++) {
                nRefPixels[m][o] = -1;
            }
        }
        
        vtcStart += 29 * secondsPerShortCadence;

        int hit = 0;
        for (int cadence = startCadence; cadence <= endCadence; cadence++) {
//          log.info("cadence="+cadence);
            if (0 != cadence % longCadencesPerBaseline) {
                continue;
            }

            log.info("processing reference pixels for cadence #" + cadence);

            if ( cadence == 48 ) {
                vtcStart += secondsPerLongCadence;
            }
            double vtc = vtcStart + (cadence - startCadence)
                * secondsPerLongCadence;
        log.info("vtc="+vtc);

            File referencePixelFile = new File(outputDir, "kplr"
                + VtcFormat.toDateString(vtc)
                + DispatcherWrapperFactory.REFERENCE_PIXEL);

            log.info("Creating: " + referencePixelFile);

            DataOutputStream dos = new DataOutputStream(
                new BufferedOutputStream(new FileOutputStream(
                    referencePixelFile)));

            // see ReferencePixelFileReader:
            log.info("vtcToWholeAndFraction = " + VtcFormat.toWholeAndFraction( vtc ));
            writeTimestamp(dos, vtc);
            dos.writeByte(8); // headerFlags
            dos.writeByte(photometerConfigParams.getLctExternalId()); // longCadenceTargetTableId
            dos.writeByte(photometerConfigParams.getSctExternalId()); // shortCadenceTargetTableId
            dos.writeByte(photometerConfigParams.getBgpExternalId()); // backgroundTargetTableId
            dos.writeByte(photometerConfigParams.getBadExternalId()); // backgroundApertureTableId
            dos.writeByte(photometerConfigParams.getTadExternalId()); // scienceApertureTableId
            dos.writeByte(photometerConfigParams.getRptExternalId()); // referencePixelTargetTableId
            dos.writeByte(photometerConfigParams.getCompressionExternalId()); // compressionTableId

            for (m = 0; m < FcConstants.modulesList.length; m++) {
                int mod = FcConstants.modulesList[m];
                for (o = 0; o < FcConstants.outputsList.length; o++) {
                    int out = FcConstants.outputsList[o];
                    String modOutDir = "run_long_m" + mod + "o" + out + "s1";
                    String runDir = inputDir + "/" + modOutDir;

                    // Do nothing if the runNum directory does not exist.
                    File runNumDir = new File(runDir);
                    if (!runNumDir.exists()) {
                        continue;
                    }

                    log.debug("modOutDir ='" + modOutDir + "'");
                    if (-1 == nRefPixels[m][o]) {
                        PixelCounts pc = new PixelCounts(new File(runDir), 
                            "long");
                        nRefPixels[m][o] = pc.getNReferencePixels();
                        // nRefPixels[m][o] = 100;
                        log.debug("nRefPixels[" + mod + "][" + out + "]="
                            + nRefPixels[m][o]);
                    }
                    DataInputStream refPixels = new DataInputStream(
                        new BufferedInputStream(new FileInputStream(new File(
                            runDir + "/ssrOutput", "referencePixels.dat"))));
                    int skip = nRefPixels[m][o] * 4 * hit;
                    log.debug("skip ='" + skip + "'");
                    if (skip != refPixels.skipBytes(skip)) {
                        throw new Exception(
                            "CreateReferencePixelFile: unable to skip " + skip
                                + " bytes in file " + runDir + "/ssrOutput"
                                + "referencePixels.dat");
                    }
                    for (int i = 0; i < nRefPixels[m][o]; i++) {
                        dos.writeInt(refPixels.readInt());
                    }
                    refPixels.close();
                }
            }
            hit++;

            dos.close();
        }
    }

    /**
     * Write the specified 40-bit timestamp to the file Assumes big-endian
     * 
     * @param dos
     * 
     * @return
     * @throws IOException
     */
    private void writeTimestamp(DataOutputStream dos, double vtc)
        throws IOException {
        dos.writeInt(VtcFormat.getUpperBytes(vtc));
        dos.writeByte(VtcFormat.getLowerByte(vtc));
    }
}
