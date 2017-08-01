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

import java.util.Date;

import org.jmock.Expectations;
import org.jmock.Mockery;

import gov.nasa.kepler.ar.exporter.binarytable.BaseBinaryTableHeaderSource;
import gov.nasa.kepler.ar.exporter.binarytable.BaseTargetBinaryTableHeaderSource;
import gov.nasa.kepler.hibernate.cm.CelestialObject;

public class MockUtils {

    public static CelestialObject createMinimalCelestialObject(Mockery mockery) {
        final CelestialObject kic = mockery.mock(CelestialObject.class);
        mockery.checking(new Expectations() {{
            atLeast(1).of(kic).getDec();
            will(returnValue(45.609520));
            atLeast(1).of(kic).getRaProperMotion();
            will(returnValue(0.00235f));
            atLeast(1).of(kic).getDecProperMotion();
            will(returnValue(null));
            atLeast(1).of(kic).getTotalProperMotion();
            will(returnValue(null));
            atLeast(1).of(kic).getParallax();
            will(returnValue(null));
            atLeast(1).of(kic).getGalacticLatitude();
            will(returnValue(null));
            atLeast(1).of(kic).getGalacticLongitude();
            will(returnValue(null));
            atLeast(1).of(kic).getGMag();
            will(returnValue(null));
            atLeast(1).of(kic).getRMag();
            will(returnValue(null));
            atLeast(1).of(kic).getIMag();
            will(returnValue(null));
            atLeast(1).of(kic).getZMag();
            will(returnValue(null));
            atLeast(1).of(kic).getD51Mag();
            will(returnValue(null));
            atLeast(1).of(kic).getTwoMassJMag();
            will(returnValue(null));
            atLeast(1).of(kic).getTwoMassHMag();
            will(returnValue(null));
            atLeast(1).of(kic).getTwoMassKMag();
            will(returnValue(null));
            atLeast(1).of(kic).getKeplerMag();
            will(returnValue(null));
            atLeast(1).of(kic).getGrColor();
            will(returnValue(null));
            atLeast(1).of(kic).getJkColor();
            will(returnValue(null));
            atLeast(1).of(kic).getGkColor();
            will(returnValue(null));
            atLeast(1).of(kic).getEffectiveTemp();
            will(returnValue(null));
            atLeast(1).of(kic).getLog10SurfaceGravity();
            will(returnValue(null));
            atLeast(1).of(kic).getLog10Metallicity();
            will(returnValue(null));
            atLeast(1).of(kic).getEbMinusVRedding();
            will(returnValue(null));
            atLeast(1).of(kic).getAvExtinction();
            will(returnValue(null));
            atLeast(1).of(kic).getRadius();
            will(returnValue(null));
            atLeast(1).of(kic).getTwoMassId();
            will(returnValue(null));
            atLeast(1).of(kic).getScpId();
            will(returnValue(null));
        }});
        return kic;
    }
    
	public static void baseBinaryTableExpectations(Mockery mockery, final Date generatedAt,
			final BaseBinaryTableHeaderSource source) {
		mockery.checking(new Expectations() {
            {
                atLeast(1).of(source).generatedAt();
                will(returnValue(generatedAt));
                atLeast(1).of(source).backgroundSubtracted();
                will(returnValue(true));
                atLeast(1).of(source).extensionName();
                will(returnValue("EXTNAMEVALUE"));
                atLeast(1).of(source).framesPerCadence();
                will(returnValue(17));
                atLeast(1).of(source).gainEPerCount();
                will(returnValue(18.1));
                atLeast(1).of(source).keplerId();
                will(returnValue(19));
                atLeast(1).of(source).longCadenceFixedOffset();
                will(returnValue(20));
                atLeast(1).of(source).meanBlackCounts();
                will(returnValue(21));
                atLeast(1).of(source).nBinaryTableRows();
                will(returnValue(22));
                atLeast(1).of(source).observationEndUTC();
                will(returnValue(new Date(23000000)));
                atLeast(1).of(source).observationStartUTC();
                will(returnValue(new Date(240000000)));
                atLeast(1).of(source).photonAccumulationTimeSec();
                will(returnValue(25.1));
                atLeast(1).of(source).readNoiseE();
                will(returnValue(26.1));
                atLeast(1).of(source).readoutTimePerFrameSec();
                will(returnValue(27.1));
                atLeast(1).of(source).readsPerCadence();
                will(returnValue(28));
                atLeast(1).of(source).scienceFrameTimeSec();
                will(returnValue(27.1));
                atLeast(1).of(source).shortCadenceFixedOffset();
                will(returnValue(28));
                atLeast(1).of(source).timeResolutionOfDataDays();
                will(returnValue(29.1));
                atLeast(1).of(source).timeSlice();
                will(returnValue(30));
            }
        });
	}
	
	public static void baseTargetBinaryTableExpectations(Mockery mockery,
        final BaseTargetBinaryTableHeaderSource source) {
	    
	  mockery.checking(new Expectations() {{
          atLeast(1).of(source).raDegrees();
          will(returnValue(77.7));
          atLeast(1).of(source).decDegrees();
          will(returnValue(88.8));
          atLeast(1).of(source).cdpp3Hr();
          will(returnValue(99.9f));
          atLeast(1).of(source).cdpp6Hr();
          will(returnValue(101.1f));
          atLeast(1).of(source).cdpp12Hr();
          will(returnValue(111.1f));
          atLeast(1).of(source).fluxFractionInOptimalAperture();
          will(returnValue(0.2222));
          atLeast(1).of(source).crowding();
          will(returnValue(0.3333));
          atLeast(1).of(source).isK2();
          will(returnValue(false));
          atLeast(1).of(source).daysOnSource();
          will(returnValue(1000.1));
          atLeast(1).of(source).kbjdReferenceFraction();
          will(returnValue(.11111));
          atLeast(1).of(source).kbjdReferenceInt();
          will(returnValue(22222));
          atLeast(1).of(source).elaspedTime();
          will(returnValue(3333.3));
          atLeast(1).of(source).liveTimeDays();
          will(returnValue(3334.4));
          atLeast(1).of(source).startKbjd();
          will(returnValue(444.4));
          atLeast(1).of(source).endKbjd();
          will(returnValue(555.5));
          atLeast(1).of(source).startMidMjd();
          will(returnValue(666.6));
          atLeast(1).of(source).endMidMjd();
          will(returnValue(777.7));
          atLeast(1).of(source).deadC();
          will(returnValue(888.8));
          
          
      }});
	}
}
