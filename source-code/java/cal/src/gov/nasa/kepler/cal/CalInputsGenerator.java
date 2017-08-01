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

package gov.nasa.kepler.cal;

import gov.nasa.kepler.cal.io.CommonParameters;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.hibernate.tad.TargetCrud;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.hibernate.tad.TargetTableLog;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.kepler.io.DataOutputStream;
import gov.nasa.kepler.mc.Pixel;
import gov.nasa.kepler.mc.SciencePixelOperations;
import gov.nasa.spiffy.common.concurrent.DaemonThreadFactory;
import gov.nasa.spiffy.common.persistable.BinaryPersistableOutputStream;
import gov.nasa.spiffy.common.persistable.Persistable;

import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileOutputStream;

import java.util.*;
import java.util.concurrent.Callable;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;
import java.util.concurrent.ThreadFactory;

import com.google.common.collect.Lists;
import com.google.common.collect.Maps;

/**
 * Use this class to generate inputs into cal outside of the pipeline module.
 * Or even inside a pipeline module if you wanted it.
 * 
 * @author Sean McCauliff
 *
 */
public class CalInputsGenerator {

    private final File outputDir;
    
    public CalInputsGenerator(File outputDir) {
        this.outputDir = outputDir;
    }
    
    
    public void create(int startCadence, int endCadence, int maxChunkSize,
        int ccdModule, int ccdOutput, CadenceType cadenceType, File blobOutputDir) throws Exception {
        
        CommonParametersFactory commonParametersGenerator = new CommonParametersFactory();
        CommonParameters commonParameters = 
            commonParametersGenerator.create(cadenceType, startCadence, endCadence, ccdModule, ccdOutput, blobOutputDir);
        CalWorkParticleFactory particleGenerator = 
            new CalWorkParticleFactory(commonParameters);
        
        TargetCrud targetCrud = new TargetCrud();
        TargetType  targetType = cadenceType == CadenceType.LONG ? TargetType.LONG_CADENCE : TargetType.SHORT_CADENCE;
        List<TargetTableLog> ttableLogs = targetCrud.retrieveTargetTableLogs(targetType, startCadence, endCadence);
        
        if (ttableLogs.size() != 1) {
            throw new IllegalArgumentException("Expected to find 1 target table log, but found " + ttableLogs.size());
        }
        
        TargetTable ttable = ttableLogs.get(0).getTargetTable();
        TargetTable bkgTargetTable = null;
        if (cadenceType == CadenceType.LONG) {
            bkgTargetTable = targetCrud.retrieveBackgroundTargetTable(ttable).get(0);
        }
        
        SciencePixelOperations sciOps = 
            new SciencePixelOperations(ttable, bkgTargetTable, ccdModule, ccdOutput);
        
        Set<Pixel> tnbPixels = sciOps.getPixels();
        Map<FsId, Pixel> pixelsByFsId = Maps.newHashMapWithExpectedSize(tnbPixels.size());
        for (Pixel px : tnbPixels) {
            pixelsByFsId.put(px.getFsId(), px);
        }
        
        List<List<CalWorkParticle>> workMolecule = 
            particleGenerator.create(tnbPixels, pixelsByFsId, maxChunkSize);
        
        ThreadFactory threadFactory = new DaemonThreadFactory("CalInputsFactory");
        ExecutorService xService =  Executors.newFixedThreadPool(Runtime.getRuntime().availableProcessors(), threadFactory);
        //Since we are not going to actually execute cal here I'm just going
        //to generate all the outputs.
        List<CalWorkParticle> allParticles = Lists.newArrayList();
        for (Collection<CalWorkParticle> particles : workMolecule) {
            allParticles.addAll(particles);
        }
        List<Future<CalWorkParticle>> futures = xService.invokeAll(allParticles);
        List<Future<Object>> writeFutures = Lists.newArrayListWithCapacity(futures.size());
        for (Future<CalWorkParticle> future : futures) {
            CalWorkParticle completedParticle = future.get();
            writeFutures.add(xService.submit(new WorkParticleWriter(completedParticle)));
        }
        
        //Don't care about the return values, just want to check
        //the errors and wait until this is complete.
        for (Future<Object> writeFuture : writeFutures) {
            writeFuture.get();
        }
    }
    
    private void write(int iteration, Persistable outputData) throws Exception {
        //TODO: Generate this file name from some shared code.
        File outputFile = new File(outputDir, "cal-inputs-" + iteration + ".bin");
        DataOutputStream dout = 
            new DataOutputStream(new BufferedOutputStream(new FileOutputStream(outputFile)));
        BinaryPersistableOutputStream binOut = new BinaryPersistableOutputStream(dout);
        binOut.save(outputData);
        dout.close();
    }
    
    
    public static void main(String[] argv) throws Exception {
        
    }
    
    
    private final class WorkParticleWriter implements Callable<Object> {
        private final CalWorkParticle completedParticle;
        
        WorkParticleWriter(CalWorkParticle completedParticle) {
            this.completedParticle = completedParticle;
        }
        
        @Override
        public Object call() throws Exception {
            write(completedParticle.particleNumber(), completedParticle.calInputs());
            return null;
        }
        
    }
    

}
