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

package gov.nasa.kepler.ar.exporter.tpixel;

import gov.nasa.kepler.ar.archive.BackgroundPixelValue;
import gov.nasa.kepler.ar.exporter.DefaultSingleQuarterTargetExporterSource;
import gov.nasa.kepler.ar.exporter.BlackAlgorithmUtils;
import gov.nasa.kepler.fc.gain.GainOperations;
import gov.nasa.kepler.fc.readnoise.ReadNoiseOperations;
import gov.nasa.kepler.hibernate.cal.BlackAlgorithm;
import gov.nasa.kepler.hibernate.cal.CalCrud;
import gov.nasa.kepler.hibernate.dr.LogCrud;
import gov.nasa.kepler.hibernate.gar.CompressionCrud;
import gov.nasa.kepler.hibernate.tad.TargetCrud;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.hibernate.tad.UnifiedObservedTargetCrud;
import gov.nasa.kepler.mc.Pixel;
import gov.nasa.kepler.mc.cm.CelestialObjectOperations;
import gov.nasa.kepler.mc.configmap.ConfigMapOperations;
import gov.nasa.kepler.mc.dr.DataAnomalyOperations;
import gov.nasa.kepler.mc.dr.MjdToCadence.TimestampSeries;


import java.util.*;


/**
 * A target pixel exporter source with the methods that might actually have
 * some logic implemented.
 * 
 * @author Sean McCauliff
 *
 */
public abstract class DefaultTargetPixelExporterSource 
    extends DefaultSingleQuarterTargetExporterSource implements TargetPixelExporterSource {

    private BlackAlgorithm blackAlgorithm;
    
    private final CalCrud calCrud;
    
    public DefaultTargetPixelExporterSource(DataAnomalyOperations anomalyOperations,
        ConfigMapOperations configMapOps, TargetCrud targetCrud,
        CompressionCrud compressionCrud, GainOperations gainOps,
        ReadNoiseOperations readNoiseOps, TargetTable targetTable,
        LogCrud logCrud, CelestialObjectOperations celestialObjectOps, 
        int startKeplerId, int endKeplerId, 
        UnifiedObservedTargetCrud uTargetCrud,
        int k2Campaign, CalCrud calCrud) {

       super(anomalyOperations, configMapOps, targetCrud, compressionCrud,
           gainOps, readNoiseOps, targetTable, logCrud, celestialObjectOps,
           startKeplerId, endKeplerId,
           uTargetCrud, k2Campaign);
       
       this.calCrud = calCrud;

    }

    
    /**
     * This default implementation just returns a uniform background of zero.
     * @param pixels
     * @return
     */
    @Override
    public Map<Pixel, BackgroundPixelValue> background(Set<Pixel> pixels) {
        Map<Pixel, BackgroundPixelValue> rv = new HashMap<Pixel, BackgroundPixelValue>();
        double[] floatArray = new double[cadenceCount()];
        boolean[] gaps = new boolean[floatArray.length];
        //Arrays.fill(gaps, true);
        for (Pixel pixel : pixels) {
            
            BackgroundPixelValue value = 
                new BackgroundPixelValue(pixel.getRow(), pixel.getColumn(), 
                    floatArray , gaps, floatArray, gaps);
            rv.put(pixel, value);
        }
        return rv;
    }
    
    /**
     * cadenceTimes() is a synonym for timestampSeries()
     */
    @Override
    public TimestampSeries cadenceTimes() {
        return timestampSeries();
    }
    
    /**
     * longCadenceTimes() is a synonym for longCadenceTimestampSeries()
     */
    @Override
    public TimestampSeries longCadenceTimes() {
        return longCadenceTimestampSeries();
    }
    
    @Override
    public BlackAlgorithm blackAlgorithm() {
        if (blackAlgorithm == null) {
            blackAlgorithm = BlackAlgorithmUtils.blackAlgorithm(calCrud, 
                ccdModule(), ccdOutput(), 
                startCadence(), endCadence(), cadenceType());
        }
        return blackAlgorithm;
    }
 
}
