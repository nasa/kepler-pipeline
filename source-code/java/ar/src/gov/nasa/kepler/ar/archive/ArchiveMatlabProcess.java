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

package gov.nasa.kepler.ar.archive;


import gov.nasa.kepler.ar.archive.BarycentricInputs.BarycentricTarget;
import gov.nasa.kepler.ar.exporter.background.BackgroundPolynomial;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.SipWcsCoordinates;
import gov.nasa.kepler.common.intervals.BlobFileSeries;
import gov.nasa.kepler.common.intervals.BlobSeries;
import gov.nasa.kepler.fc.RaDec2PixModel;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.TimeSeries;
import gov.nasa.kepler.hibernate.dr.LogCrud;
import gov.nasa.kepler.mc.Pixel;
import gov.nasa.kepler.mc.blob.BlobOperations;
import gov.nasa.kepler.mc.dr.MjdToCadence.TimestampSeries;
import gov.nasa.kepler.mc.fc.RaDec2PixOperations;
import gov.nasa.spiffy.common.collect.Pair;

import java.io.IOException;
import java.util.*;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Calls the matlab process responsible for generating background pixel values and
 * WCS coordinates.
 * 
 * @author Sean McCauliff
 *
 */
public class ArchiveMatlabProcess {

    private static final Log log = LogFactory.getLog(ArchiveMatlabProcess.class);

    private static final String FFI_CADENCE_TYPE = "FFI";
    
    private final boolean ignoreZeroCrossingsForReferenceCadence;
    
    public ArchiveMatlabProcess(boolean ignoreZeroCrossingsForReferenceCadence) {
        this.ignoreZeroCrossingsForReferenceCadence = ignoreZeroCrossingsForReferenceCadence;
    }
    
    public ArchiveOutputs calculateBackground(ArchiveMatlabProcessSource source,
        PipelineProcessExecutor<ArchiveInputs, ArchiveOutputs> pipelineModule,
        Collection<Pixel> pixels) {


        if (source.cadenceType() == null) {
            throw new IllegalArgumentException("Can not calculate background for FFI.");
        }
        
        Pair<Integer, Integer> longCadences = longCadences(source);
        BlobSeries<String> backgroundBlobs = 
            source.blobOps().retrieveBackgroundBlobFileSeries(source.ccdModule(), 
                source.ccdOutput(), longCadences.left, longCadences.right);
        for (long originator : backgroundBlobs.blobOriginatorsSet()) {
            source.addOriginator(originator);
        }
        double startMjd = source.cadenceTimes().midTimestamps[0];
        double endMjd = source.cadenceTimes().midTimestamps[source.cadenceTimes().midTimestamps.length - 1];
        List<gov.nasa.kepler.common.ConfigMap> configMaps = 
            source.configMapOps().retrieveConfigMaps(startMjd, endMjd);
        
        BlobSeries<String> motionPolyBlobs = motionPolyBlobs(source, longCadences.left, longCadences.right);
        RaDec2PixModel raDec2PixModel = raDec2PixModel(source, startMjd, endMjd);
        
        BackgroundInputs backgroundInputs = new BackgroundInputs(backgroundBlobs, pixels);
        ArchiveInputs inputs = new ArchiveInputs(
            "calculate background",
            source.cadenceType().getName(),
            source.ccdModule(), source.ccdOutput(), 
             configMaps, source.cadenceTimes(),
             source.longCadenceTimes(),
             motionPolyBlobs,
             raDec2PixModel,
             backgroundInputs);
            
        
        ArchiveOutputs outputs = new ArchiveOutputs();
        pipelineModule.exec(outputs, inputs);
        return outputs;
    }
    
    public <T extends DvaTargetSource> ArchiveOutputs calculateWcs(ArchiveMatlabProcessSource source,
        PipelineProcessExecutor<ArchiveInputs, ArchiveOutputs> pipelineModule,
        Collection<T> targets, Map<FsId, TimeSeries> allTimeSeries) {

        if (source.cadenceType() == null) {
            throw new IllegalArgumentException("Can not calculate WCS for FFI.");
        }
        
        Pair<Integer, Integer> longCadences = longCadences(source);
        double startMjd = source.cadenceTimes().midTimestamps[0];
        double endMjd = source.cadenceTimes().midTimestamps[source.cadenceTimes().midTimestamps.length - 1];
        List<gov.nasa.kepler.common.ConfigMap> configMaps = source.configMapOps()
            .retrieveConfigMaps(startMjd, endMjd);

        List<WcsTarget> wcsTargets = new ArrayList<WcsTarget>(targets.size());
        for (DvaTargetSource target : targets) {
            int referenceCadence = target.longReferenceCadence(allTimeSeries, ignoreZeroCrossingsForReferenceCadence);
            Pair<Double, Double> centroid = target.rowColumnCentroid(allTimeSeries, ignoreZeroCrossingsForReferenceCadence);
            WcsTarget wcsTarget = new WcsTarget(target.keplerId(),
                target.ra(), target.dec(),
                referenceCadence, centroid.left, centroid.right, target.aperturePixels(),
                target.isCustomTarget());
            
            wcsTargets.add(wcsTarget);
        }
        WcsInputs wcsInputs = new WcsInputs(wcsTargets);

        BlobSeries<String> motionPolyBlobs = motionPolyBlobs(source,
            longCadences.left, longCadences.right);
        RaDec2PixModel raDec2PixModel = raDec2PixModel(source, startMjd, endMjd);
        ArchiveInputs inputs = new ArchiveInputs(
            "calculate WCS coordinates", source.cadenceType()
                .getName(), source.ccdModule(), source.ccdOutput(), configMaps,
            source.cadenceTimes(), source.longCadenceTimes(), motionPolyBlobs,
            raDec2PixModel, wcsInputs);

        ArchiveOutputs outputs = new ArchiveOutputs();
        pipelineModule.exec(outputs, inputs);
        return outputs;
    }
    
    
    /**
     * Generates the SIP WCS coordinates for a mod/out.
     * @param source
     * @return the sip wcs coordinates
     */
    public SipWcsCoordinates sipWcsCoordinates(ArchiveMatlabProcessSource source, 
        PipelineProcessExecutor<ArchiveInputs, ArchiveOutputs> pipelineModule,
        boolean isFfi, int referenceLongCadence, double colStep, double rowStep) {
        
        if (source.cadenceType() == CadenceType.SHORT) {
            throw new IllegalArgumentException("Can't generate for short cdence.");
        }
        
        TimestampSeries cadenceTimes = source.cadenceTimes();
        double startMjd = cadenceTimes.midTimestamps[0];
        double endMjd = cadenceTimes.midTimestamps[source.cadenceTimes().midTimestamps.length - 1];
        
        BlobSeries<String> motionPolyBlobs = 
            motionPolyBlobs(source, source.startCadence(), source.endCadence());
        
        SipWcsInputs sipWcsInputs = new SipWcsInputs(referenceLongCadence, colStep, rowStep);
        String cadenceTypeStr = (isFfi) ? ArchiveInputs.FFI_CADENCE_TYPE : source.cadenceType().toString();
        ArchiveInputs inputs = 
            new ArchiveInputs("sip wcs correction",
                              cadenceTypeStr,
                              source.ccdModule(),
                              source.ccdOutput(), 
                              source.configMapOps().retrieveConfigMaps(startMjd, endMjd),
                              source.cadenceTimes(), source.longCadenceTimes(),
                              motionPolyBlobs, sipWcsInputs);
                  
        ArchiveOutputs outputs = new ArchiveOutputs();
        pipelineModule.exec(outputs, inputs);
        SipWcsCoordinates sipWcsCoordinates = outputs.sipWcsCoordinates();
        return sipWcsCoordinates;
    }
    
    public <T extends DvaTargetSource> ArchiveOutputs calculateDva(ArchiveMatlabProcessSource source,
        PipelineProcessExecutor<ArchiveInputs, ArchiveOutputs> pipelineModule,
        Collection<T> targets, Map<FsId, TimeSeries> allTimeSeries) {

        if (source.cadenceType() == null) {
            throw new IllegalArgumentException("Can not calculate DVA for FFI.");
        }
        
        Pair<Integer, Integer> longCadences = longCadences(source);
        double startMjd = source.cadenceTimes().midTimestamps[0];
        double endMjd = source.cadenceTimes().midTimestamps[source.cadenceTimes().midTimestamps.length - 1];
        List<gov.nasa.kepler.common.ConfigMap> configMaps = source.configMapOps()
            .retrieveConfigMaps(startMjd, endMjd);

        List<DvaTarget> dvaTargets = new ArrayList<DvaTarget>(targets.size());
        for (DvaTargetSource target : targets) {
            int referenceCadence = target.longReferenceCadence(allTimeSeries, ignoreZeroCrossingsForReferenceCadence);
            Pair<Double, Double> centroid = target.rowColumnCentroid(allTimeSeries, ignoreZeroCrossingsForReferenceCadence);
            DvaTarget dvt = new DvaTarget(target.keplerId(),
                referenceCadence, target.ra(), target.dec(),
                centroid.left, centroid.right);
            dvaTargets.add(dvt);
        }
        DvaInputs dvaInputs = new DvaInputs(dvaTargets);

        BlobSeries<String> motionPolyBlobs = motionPolyBlobs(source,
            longCadences.left, longCadences.right);
        RaDec2PixModel raDec2PixModel = raDec2PixModel(source, startMjd, endMjd);
        ArchiveInputs inputs = new ArchiveInputs(
            "calculate dva corrections and ra/dec", source.cadenceType()
                .getName(), source.ccdModule(), source.ccdOutput(), configMaps,
            source.cadenceTimes(), source.longCadenceTimes(), motionPolyBlobs,
            raDec2PixModel, dvaInputs);

        ArchiveOutputs outputs = new ArchiveOutputs();
        pipelineModule.exec(outputs, inputs);
        return outputs;
    }
    
       
    public <T extends BarycentricCorrectionTarget> 
    ArchiveOutputs calculateBarycentricCorrections(ArchiveMatlabProcessSource source,
           PipelineProcessExecutor<ArchiveInputs, ArchiveOutputs> pipelineModule,
           Collection<T> targets, Map<FsId, TimeSeries> allTimeSeries) {
       
      
       Pair<Integer, Integer> longCadences = longCadences(source);
       double startMjd = source.cadenceTimes().midTimestamps[0];
       double endMjd = source.cadenceTimes().midTimestamps[source.cadenceTimes().midTimestamps.length - 1];
       List<gov.nasa.kepler.common.ConfigMap> configMaps = 
           source.configMapOps().retrieveConfigMaps(startMjd, endMjd);
       
       RuntimeException encounteredException = null;
       List<BarycentricTarget> barycentricTargets = 
           new ArrayList<BarycentricTarget>(targets.size());
       for (BarycentricCorrectionTarget target : targets) {
           int referenceCadence = 0;
           Pair<Double, Double> targetCentroid = Pair.of(0.0, 0.0);
           try {
               referenceCadence = target.longReferenceCadence(allTimeSeries,
                   ignoreZeroCrossingsForReferenceCadence);
               targetCentroid = target.rowColumnCentroid(allTimeSeries,
                   ignoreZeroCrossingsForReferenceCadence);
           } catch (RuntimeException e) {
               log.error("Can not calculate barycentric correction for "
                   + target.keplerId() + ": " + e.getMessage());
               encounteredException = e;
           }
           BarycentricTarget bt = 
               new BarycentricTarget(target.keplerId(), referenceCadence,
                   targetCentroid.left, targetCentroid.right, 
                   target.ra(), target.dec());
           barycentricTargets.add(bt);
       }
       if (encounteredException != null) {
           throw encounteredException;
       }

       BarycentricInputs barycentricInputs = new BarycentricInputs(barycentricTargets);
       
       BlobSeries<String> motionPolyBlobs = motionPolyBlobs(source, longCadences.left, longCadences.right);
       RaDec2PixModel raDec2PixModel = raDec2PixModel(source, startMjd, endMjd);
       ArchiveInputs inputs = new ArchiveInputs(
           "calculate barycentric corrections and ra/dec",
           source.cadenceType() != null ? source.cadenceType().getName() : FFI_CADENCE_TYPE,
           source.ccdModule(), source.ccdOutput(), 
            configMaps, source.cadenceTimes(),
            source.longCadenceTimes(),
            motionPolyBlobs,
            raDec2PixModel,
             barycentricInputs);
           
       
       ArchiveOutputs outputs = new ArchiveOutputs();
       pipelineModule.exec(outputs, inputs);
       return outputs;
    }
    

    
    /**
     * Reads the background polynomial blob and returns it.
     * @return
     * @throws IOException 
     */
    public BackgroundPolynomial convertBackgroundPolynomial(ArchiveMatlabProcessSource source, 
        PipelineProcessExecutor<ArchiveInputs, ArchiveOutputs> pipelineModule) {
        
        BlobSeries<String> bkgSeries = 
            source.blobOps().retrieveBackgroundBlobFileSeries(source.ccdModule(),
            source.ccdOutput(), source.startCadence(), source.endCadence());
        if (bkgSeries.size() != 1) {
            throw new IllegalStateException("Expected only one background blob.");
        }

      
        @SuppressWarnings("unchecked")
        BackgroundInputs bkgInputs = new BackgroundInputs(bkgSeries, Collections.EMPTY_LIST);
        
        ArchiveInputs archiveInputs = new ArchiveInputs(bkgInputs, source.ccdModule(), source.ccdOutput());
        ArchiveOutputs archiveOutputs = new ArchiveOutputs();
        pipelineModule.exec(archiveOutputs, archiveInputs);
        return archiveOutputs.backgroundPolynomial();
    }
    
    /**
     * Unpacks the co-trending basis vectors blobs into a Java readable format.
     * @param source
     * @param pipelineModule
     * @return Co-trending basis vector, if not present this returns null.
     */
    public CotrendingBasisVectors convertCotrendingBasisVectorBlob(ArchiveMatlabProcessSource source,
        PipelineProcessExecutor<ArchiveInputs, ArchiveOutputs> pipelineModule) {
        
        BlobSeries<String> cbvSeries = 
            source.blobOps().retrieveCbvBlobFileSeries(source.ccdModule(), source.ccdOutput(),
                source.cadenceType(), source.startCadence(), source.endCadence());
        if (cbvSeries.size() == 0) {
            return null;
        }
        
        if (cbvSeries.blobOriginatorsSet().size() != 1) {
            throw new IllegalStateException("Found originators from more than one pipeline task for CBV blob.");
        }
        
        BlobFileSeries cbvFileSeries = new BlobFileSeries(cbvSeries);
        
        if (cbvSeries.size() != 1) {
            throw new IllegalStateException("Expected one CBV blob, but found " + cbvSeries.size() + ".");
        }
        
        ArchiveInputs archiveInputs = new ArchiveInputs(cbvFileSeries, source.cadenceTimes());
        ArchiveOutputs archiveOutputs = new ArchiveOutputs();
        pipelineModule.exec(archiveOutputs, archiveInputs);
        CotrendingBasisVectors cbvs = archiveOutputs.cotrendingBasisVectors();
        cbvs.setOriginator(cbvSeries.blobOriginators()[0]);
        return cbvs;
    }
    
   
    private static Pair<Integer, Integer> longCadences(ArchiveMatlabProcessSource source) {
        int longCadenceStart;
        int longCadenceEnd;
        
        if (source.cadenceType() == CadenceType.SHORT) {
            LogCrud logCrud = source.logCrud();
            Pair<Integer,Integer> longCadences = 
                logCrud.shortCadenceToLongCadence(source.startCadence(), source.endCadence());
            longCadenceStart = longCadences.left;
            longCadenceEnd = longCadences.right;
        } else {
            longCadenceStart = source.startCadence();
            longCadenceEnd = source.endCadence();
        }
        return Pair.of(longCadenceStart, longCadenceEnd);
    }
    
    private static BlobSeries<String> motionPolyBlobs(ArchiveMatlabProcessSource source, int longCadenceStart, int longCadenceEnd) {
        BlobOperations blobOps = source.blobOps();
        BlobSeries<String> motionPolynomials = 
            blobOps.retrieveMotionBlobFileSeries(source.ccdModule(),
                source.ccdOutput(), longCadenceStart, longCadenceEnd);
        return motionPolynomials; 
    }
    
    private static RaDec2PixModel raDec2PixModel(ArchiveMatlabProcessSource source, double startMjd, double endMjd) {
        RaDec2PixOperations raDec2PixOps = source.raDec2PixOps();
        return raDec2PixOps.retrieveRaDec2PixModel(startMjd, endMjd);
    }
}
