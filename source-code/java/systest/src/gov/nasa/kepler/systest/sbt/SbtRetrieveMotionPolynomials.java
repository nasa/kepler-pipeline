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

package gov.nasa.kepler.systest.sbt;

import gov.nasa.kepler.common.intervals.BlobSeries;
import gov.nasa.kepler.mc.blob.BlobOperations;
import gov.nasa.spiffy.common.persistable.Persistable;

import java.util.ArrayList;
import java.util.List;

public class SbtRetrieveMotionPolynomials extends AbstractSbt {
    public static final String SDF_FILE_NAME = "/tmp/sbt-retrieve-motion-polys.sdf";
    private static final boolean REQUIRES_DATABASE = true;
    private static final boolean REQUIRES_FILESTORE = true;

    public static class MotionPolyContainer implements Persistable {
        public List<List<OneMotionPoly>> motionPolys;
        
        public MotionPolyContainer() {
            motionPolys = new ArrayList<List<OneMotionPoly>>();
        }
    }
    
    public static class OneMotionPoly implements Persistable {
        public int cadence;
        public int module;
        public int output;
        public PolyBlobSeries polyBlobSeries;
        
        public OneMotionPoly(int cadence, int module, int output, PolyBlobSeries polyBlobSeries) {
            this.cadence = cadence;
            this.module = module;
            this.output = output;
            this.polyBlobSeries = polyBlobSeries;   
        }
    }
    
    public static class PolyBlobSeries implements Persistable {
        int[] blobIndices; 
        boolean[] gapIndicators;
        int startCadence; 
        int endCadence;
        String[] blobFilenames;
        
        public PolyBlobSeries (BlobSeries<String> motionBlobFileSeries) {
            this.blobIndices = motionBlobFileSeries.blobIndices();
            this.gapIndicators = motionBlobFileSeries.gapIndicators();
            this.startCadence = motionBlobFileSeries.startCadence();
            this.endCadence = motionBlobFileSeries.endCadence();
            
            this.blobFilenames = new String[motionBlobFileSeries.blobFilenames().length];
            for (int ii = 0; ii < motionBlobFileSeries.blobFilenames().length; ++ii) {
                String blobFilename = motionBlobFileSeries.blobFilenames()[ii].toString();
                this.blobFilenames[ii] = blobFilename;
            }
        }
    }

    public SbtRetrieveMotionPolynomials() {
        super(REQUIRES_DATABASE, REQUIRES_FILESTORE);
    }
    
    public String retrieveMotionPolynomials(int startCadence, int endCadence, int[] ccdModules, int[] ccdOutputs, boolean isLongCadence) throws Exception {
        if (! validateDatastores()) {
            return "";
        }
        
        if (ccdModules.length != ccdOutputs.length) {
            throw new IllegalArgumentException("ccdModules and ccdOutputs arguments must be the same length.");
        }
        
        MotionPolyContainer container = new MotionPolyContainer();
        BlobOperations blobOperations = new BlobOperations();
        
        for (int ichannel = 0; ichannel < ccdModules.length; ++ichannel) {
            int ccdModule = ccdModules[ichannel];
            int ccdOutput = ccdOutputs[ichannel];

            BlobSeries<String> motionBlobFileSeries = blobOperations.retrieveMotionBlobFileSeries(ccdModule, ccdOutput, startCadence, endCadence);
            
            int blobStartCadence = motionBlobFileSeries.startCadence();
            int blobEndCadence = motionBlobFileSeries.endCadence();
            List<OneMotionPoly> channelMotionPolys = new ArrayList<OneMotionPoly>();
            
            for (int cadence = blobStartCadence; cadence <= blobEndCadence; ++cadence) {
                PolyBlobSeries polyBlobSeries = new PolyBlobSeries(motionBlobFileSeries);
                OneMotionPoly oneMotionPoly = new OneMotionPoly(cadence, ccdModule, ccdOutput, polyBlobSeries);
                channelMotionPolys.add(oneMotionPoly);
            }
            container.motionPolys.add(channelMotionPolys);
        }
        
        return makeSdf(container, SDF_FILE_NAME);
    }
    
    public static void main(String[] args) throws Exception {
        SbtRetrieveMotionPolynomials sbt = new SbtRetrieveMotionPolynomials();
        int[] ccdModules = { 7, 7, 7, 7 };
        int[] ccdOutputs = { 1, 2, 3, 4 };
        int startCadence = 2965;
        int endCadence = 4471;
        
        String out = sbt.retrieveMotionPolynomials(startCadence, endCadence, ccdModules, ccdOutputs, true);
        System.out.println(out);
    }
}
