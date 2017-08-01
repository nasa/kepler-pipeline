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

import java.util.*;

import gov.nasa.kepler.ar.exporter.ExposureCalculator;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.ConfigMap;
import gov.nasa.kepler.common.ConfigMapEntry;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.IntTimeSeries;
import gov.nasa.kepler.fs.api.TimeSeries;
import static gov.nasa.kepler.common.ConfigMap.ConfigMapMnemonic.*;

import org.junit.Test;
import static org.junit.Assert.assertEquals;

/**
 * 
 * @author Sean McCauliff
 *
 */
public class ExposureCalculatorTest {

    @Test
    public void electronsPerCadenceToElectronsPerSecond() {
        final Double FRAMES_PER_INTEGRATION = 42.0;
        final Double MS_PER_FGS_FRAME = 7.0;
        final Double MS_PER_READOUT = 2.0;
        final Double INTEGRATIONS_PER_SHORT_CADENCE = 3.0;
        final Double SHORT_CADENCES_PER_LONG_CADENCE = 5.0;
        final int nCadences = 64;
        final double startTime = 0;
        final double endTime = 
            (MS_PER_FGS_FRAME + MS_PER_READOUT) * FRAMES_PER_INTEGRATION * 
            INTEGRATIONS_PER_SHORT_CADENCE * SHORT_CADENCES_PER_LONG_CADENCE *
            nCadences * 1000.0 * 60.0 * 60.0 * 24.0;
        final int startCadence = 0;
        final int endCadence = nCadences - 1;
        
        CadenceType cadenceType = CadenceType.LONG;
        ConfigMap configMap = new ConfigMap();
        configMap.add(new ConfigMapEntry(fgsFramesPerIntegration.mnemonic(), String.format("%.0f",FRAMES_PER_INTEGRATION)));
        configMap.add(new ConfigMapEntry(millisecondsPerFgsFrame.mnemonic(), MS_PER_FGS_FRAME.toString()));
        configMap.add(new ConfigMapEntry(millisecondsPerReadout.mnemonic(), MS_PER_READOUT.toString()));
        configMap.add(new ConfigMapEntry(integrationsPerShortCadence.mnemonic(), String.format("%.0f",INTEGRATIONS_PER_SHORT_CADENCE)));
        configMap.add(new ConfigMapEntry(shortCadencesPerLongCadence.mnemonic(), String.format("%.0f",SHORT_CADENCES_PER_LONG_CADENCE)));
        configMap.add(new ConfigMapEntry(lcRequantFixedOffset.mnemonic(), "1"));
        configMap.add(new ConfigMapEntry(scRequantFixedOffset.mnemonic(), "2"));
        
        List<ConfigMap> configMaps = Collections.singletonList(configMap);
        
        IntTimeSeries its = 
            new IntTimeSeries(new FsId("/blah/blah"), new int[nCadences], 
                startCadence, endCadence, new boolean[nCadences], 99);
        List<TimeSeries> dataCollected = new ArrayList<TimeSeries>();
        dataCollected.add(its);
        ExposureCalculator exposureCalc = 
            new ExposureCalculator(configMaps, dataCollected, cadenceType,
                startTime, endTime, startCadence, endCadence);
        double expectedFluxPerSecond = 1.0/( FRAMES_PER_INTEGRATION *
        MS_PER_FGS_FRAME * INTEGRATIONS_PER_SHORT_CADENCE * SHORT_CADENCES_PER_LONG_CADENCE) * 1000.0;
        double fluxPerSecond = exposureCalc.fluxPerCadenceToFluxPerSecond(1);
        assertEquals(expectedFluxPerSecond, fluxPerSecond,0);
    }
}
