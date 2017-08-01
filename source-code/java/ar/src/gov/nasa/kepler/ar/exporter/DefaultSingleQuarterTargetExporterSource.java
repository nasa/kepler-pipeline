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

package gov.nasa.kepler.ar.exporter;

import gov.nasa.kepler.ar.archive.BarycentricCorrection;
import gov.nasa.kepler.ar.archive.DvaTargetSource;
import gov.nasa.kepler.ar.archive.TargetDva;
import gov.nasa.kepler.common.Cadence;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.fc.gain.GainOperations;
import gov.nasa.kepler.fc.readnoise.ReadNoiseOperations;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.TimeSeries;
import gov.nasa.kepler.fs.client.FileStoreClientFactory;
import gov.nasa.kepler.hibernate.cm.CelestialObject;
import gov.nasa.kepler.hibernate.dr.DataAnomaly;
import gov.nasa.kepler.hibernate.dr.LogCrud;
import gov.nasa.kepler.hibernate.gar.CompressionCrud;
import gov.nasa.kepler.hibernate.pa.TargetAperture;
import gov.nasa.kepler.hibernate.tad.ObservedTarget;
import gov.nasa.kepler.hibernate.tad.TargetCrud;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.hibernate.tad.UnifiedObservedTarget;
import gov.nasa.kepler.hibernate.tad.UnifiedObservedTargetCrud;
import gov.nasa.kepler.mc.SciencePixelOperations;
import gov.nasa.kepler.mc.cm.CelestialObjectOperations;
import gov.nasa.kepler.mc.configmap.ConfigMapOperations;
import gov.nasa.kepler.mc.dr.DataAnomalyOperations;
import gov.nasa.spiffy.common.collect.Pair;

import java.util.*;

import com.google.common.base.Function;
import com.google.common.collect.MapMaker;

/**
 * Contains default implementations of some PerTargetExporterSource methods.
 * @author Sean McCauliff
 *
 */
public abstract class DefaultSingleQuarterTargetExporterSource
    extends DefaultTargetExporterSource
    implements SingleQuarterExporterSource {

    protected final TargetTable targetTable;
    private SciencePixelOperations sciOps;
    private final UnifiedObservedTargetCrud unifiedTargetCrud;
    private Set<Integer> keplerIdsDroppedBySupplementalTad;
    
    private final CompressionCrud compressionCrud;
    private final ReadNoiseOperations readNoiseOps;
    private final GainOperations gainOps; 
    private ParametersUsedInCalibration calibration = null;
    

    private volatile List<Integer> keplerIds = null;
    private volatile Map<Integer, TargetAperture> keplerIdToTargetAperture;
    
    private List<DataAnomaly> lcAnomalies;
    
    private final int k2Campaign;
    
    private RollingBandUtils rollingBandUtils;
    
    protected DefaultSingleQuarterTargetExporterSource(DataAnomalyOperations anomalyOperations,
        ConfigMapOperations configMapOps, TargetCrud targetCrud,
        CompressionCrud compressionCrud, GainOperations gainOps,
        ReadNoiseOperations readNoiseOps, TargetTable targetTable,
        LogCrud logCrud, CelestialObjectOperations celestialObjectOps, 
        int startKeplerId, int endKeplerId,
        UnifiedObservedTargetCrud unifiedCrud,
        int k2Campaign) {

        super(targetCrud, startKeplerId, endKeplerId, logCrud, 
            anomalyOperations, configMapOps, celestialObjectOps,
            FileStoreClientFactory.getInstance());
        
        this.unifiedTargetCrud = unifiedCrud;
        this.targetTable = targetTable;
        this.compressionCrud = compressionCrud;
        this.readNoiseOps = readNoiseOps;
        this.gainOps = gainOps;
        this.k2Campaign = k2Campaign;
    }
    
    private ParametersUsedInCalibration calibration() {
        if (calibration == null) {
            calibration = new ParametersUsedInCalibration(readNoiseOps, gainOps,
                targetTable, compressionCrud,
                mjdToCadence().cadenceToMjd(startCadence()),
                mjdToCadence().cadenceToMjd(endCadence()),
                ccdModule(), ccdOutput());
        }
        return calibration;
    }
    
    @Override
    public int cadenceToLongCadence(int cadence) {
        if (mjdToCadence().cadenceType() == CadenceType.LONG) {
            return cadence;
        }
        Pair<Integer, Integer> longCadence = logCrud.shortCadenceToLongCadence(cadence, cadence);
        return longCadence.left;
    }
    
    @Override
    public List<DataAnomaly> longCadenceAnomalies() {
        if (cadenceType() == CadenceType.LONG) {
            return anomalies();
        }
        if (lcAnomalies == null) {
            int lcStart = cadenceToLongCadence(startCadence());
            int lcEnd = cadenceToLongCadence(endCadence());
            lcAnomalies = anomalyOperations.retrieveDataAnomalies(Cadence.CADENCE_LONG, lcStart, lcEnd);
        }
        return lcAnomalies;
    }

    @Override
    public double gainE() {
        return calibration().gainE();
    }


    /**
     * If a target was dropped by the supplemental target run then we may still
     * have data that needs to be exported.  Recover those targets.  If those
     * targets should turn out not to have data associated with them then they
     * will be dropped at a later point in the export.
     */
    @Override
    public List<ObservedTarget> observedTargets() {
        this.keplerIdsDroppedBySupplementalTad = new HashSet<Integer>();
        
        
        List<Integer> keplerIds = keplerIds();
        int nKeplerIds = keplerIds.size();
        Map<Integer, UnifiedObservedTarget> uTargets = 
            unifiedTargetCrud.retrieveUnifiedObservedTargets(targetTable, ccdModule(), ccdOutput(), keplerIds());
        List<ObservedTarget> rv = new ArrayList<ObservedTarget>(nKeplerIds);
        for (Integer keplerId : keplerIds) {
            if (keplerId == null) {
                rv.add(null);
                continue;
            }
            UnifiedObservedTarget uTarget = uTargets.get(keplerId);
            if (uTarget != null && uTarget.wasDroppedBySupplementalTad()) {
                keplerIdsDroppedBySupplementalTad.add(keplerId);
            }
            rv.add(uTarget);
        }
        return rv;
    }
    
    @Override
    public boolean wasTargetDroppedBySupplementalTad(int keplerId) {
        if (keplerIdsDroppedBySupplementalTad == null) {
            observedTargets();
        }
        return keplerIdsDroppedBySupplementalTad.contains(keplerId);
    }

    @Override
    public double readNoiseE() {
        return calibration().readNoiseE();
    }

    
    @Override
    public int meanBlackValue() {
        return calibration().meanBlackValue();
    }
    
    @Override
    public SciencePixelOperations sciOps() {
        if (sciOps == null) {
            List<TargetTable> bkTTable = targetCrud.retrieveBackgroundTargetTable(targetTable);
            if (bkTTable.size() != 1) {
                throw new IllegalStateException("Expected only one background" +
                        " target table, but found " + bkTTable.size());
            }
            sciOps = new SciencePixelOperations(targetTable, bkTTable.get(0), ccdModule(), ccdOutput());
        }
        return sciOps;
    }
    
    @Override
    public int season() {
        return targetTable.getObservingSeason();
    }
    
    @Override
    public int targetTableExternalId() {
        return targetTable.getExternalId();
    }
    
    @Override
    public List<CelestialObject> celestialObjects() {
        return celestialObjectOps.retrieveCelestialObjects(keplerIds());
    }
    
    /**
     * This default implementation just returns a barycentric correction of zero
     * and an RA/DEC of 0,0
     */
    @Override
    public <T extends DvaTargetSource>  Map<Integer, BarycentricCorrection> barycentricCorrection(
        Collection<T> customTargets, Map<FsId, TimeSeries> allTimeSeries) {
        
        Map<Integer, BarycentricCorrection> rv = new HashMap<Integer, BarycentricCorrection>(customTargets.size() * 2);
        for (DvaTargetSource ot : customTargets) {
            BarycentricCorrection bc = 
                new BarycentricCorrection(ot.keplerId(), new float[cadenceCount()], new boolean[cadenceCount()], 0.0, 0.0);
            rv.put(ot.keplerId(), bc);
        }
        return rv;
    }
    
    /**
     * This default implementation just returns a DVA of zero and one in the 
     * row and column axes respectively.
     */
    @Override
    public <T extends DvaTargetSource> Map<Integer, TargetDva> dvaMotion(
        Collection<T> targets, Map<FsId, TimeSeries> allTimeSeries) {
        
        float[] rowDva = new float[cadenceCount()];
        float[] columnDva = new float[cadenceCount()];
        boolean[] gaps = new boolean[cadenceCount()];
        Arrays.fill(columnDva, 1);
        Map<Integer, TargetDva> rv = new HashMap<Integer, TargetDva>();
        for (DvaTargetSource ot : targets) {
            TargetDva dva = new TargetDva(ot.keplerId(),
                columnDva, gaps, rowDva, gaps);
            rv.put(ot.keplerId(), dva);
        }
        return rv;
    }
    
    @Override
    public List<Integer> keplerIds() {
        if (this.keplerIds == null) {
            keplerIds = 
                unifiedTargetCrud.retrieveKeplerIds(targetTable, ccdModule(),
                    ccdOutput(), startKeplerId, endKeplerId);
        }
        
        return keplerIds;
    }
    
    /**
     * So this uses the deprecated MapMaker.  MapMaker now says to use CacheBuilder.
     * But the cache returned by cache.asMap does not act like the computing map
     * from MapMaker.
     * 
     * @param centroidTimeSeries We use this to look up information about which
     * PA task generated.
     */
    @SuppressWarnings("deprecation")
	@Override
    public Map<Integer, TargetAperture> targetApertures(Collection<TimeSeries> centroidTimeSeries) {
        if (keplerIdToTargetAperture != null) {
            return keplerIdToTargetAperture;
        }
        
        TargetApertureFactory targetApertureFactory = new TargetApertureFactory();
        long paPipelineTaskId = targetApertureFactory.distinctOriginator(centroidTimeSeries);
        List<TargetAperture> targetApertures = targetApertureFactory.targetApertures(
        		keplerIds(), paPipelineTaskId, cadenceType(), 
        		startCadence(), endCadence(), userSelectedTargetTable(),
        		ccdModule(), ccdOutput());
        
        final Map<Integer, TargetAperture> backingMap = 
            new HashMap<Integer, TargetAperture>();
        
        for (TargetAperture targetAperture : targetApertures) {
        	backingMap.put(targetAperture.getKeplerId(), targetAperture);
        }
        
        keplerIdToTargetAperture = 
            new MapMaker().makeComputingMap(new Function<Integer, TargetAperture>() {

                @SuppressWarnings("unchecked")
                @Override
                public TargetAperture apply(Integer keplerId) {
                    if (backingMap.containsKey(keplerId)) {
                        return backingMap.get(keplerId);
                    }
                    return new TargetAperture.Builder(null, null, keplerId)
                    .ccdModule(ccdModule())
                    .ccdOutput(ccdOutput())
                    .pixels(Collections.EMPTY_LIST)
                    .build();
                }  
            });
        
        return keplerIdToTargetAperture;
    }
    
    @Override
    public int k2Campaign() {
        return k2Campaign;
    }
    
    @Override
    public boolean isK2() {
        return this.timestampSeries().startMjd() >= FcConstants.KEPLER_END_OF_MISSION_MJD;
    }
    
    @Override
    public RollingBandUtils rollingBandUtils() {
        if (rollingBandUtils == null) {
            rollingBandUtils = new RollingBandUtils(ccdModule(), ccdOutput(), startCadence(), endCadence());
        }
        return rollingBandUtils;
    }
    
    @Override
    public TargetTable userSelectedTargetTable() {
        return targetTable;
    }
    
}
