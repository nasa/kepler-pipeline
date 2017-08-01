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

package gov.nasa.kepler.tad.xml;

import static org.junit.Assert.assertTrue;
import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.common.pi.ModuleOutputListsParameters;
import gov.nasa.kepler.hibernate.cm.TargetListSet;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.tad.Aperture;
import gov.nasa.kepler.hibernate.tad.ObservedTarget;
import gov.nasa.kepler.hibernate.tad.Offset;
import gov.nasa.kepler.hibernate.tad.TargetCrud;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.spiffy.common.jmock.JMockTest;

import java.io.File;
import java.io.IOException;
import java.util.List;

import org.junit.Test;

import com.google.common.collect.ImmutableList;

/**
 * @author Miles Cote
 * 
 */
public class ObservedTargetsExporterImporterTest extends JMockTest {

    private static final boolean ALLOW_NULL_APERTURES = true;

    @Test
    public void testExportImport() throws Exception {
        testExportImport(1, 1);
    }

    @Test(expected = IllegalArgumentException.class)
    public void testImportMissingTargetWithValidationEnabled() throws Exception {
        testExportImport(91, 92);
    }

    @Test
    public void testImportMissingTargetWithValidationDisabled()
        throws Exception {
        System.setProperty(
            ObservedTargetsImporter.VALIDATION_ENABLED_PROP_NAME, "false");

        testExportImport(91, 92);
    }

    private void testExportImport(int keplerIdSrc, int keplerIdDest)
        throws IOException {
        int aperturePixelCount = 2;
        int badPixelCount = 3;
        double signalToNoiseRatio = 4.4;
        float magnitude = 5.5F;
        double ra = 5.6F;
        double dec = 5.7F;
        float effectiveTemp = 5.8F;
        double crowdingMetric = 6.6;
        double skyCrowdingMetric = 7.7;
        double fluxFractionInAperture = 8.8;
        int saturatedRowCount = 8;
        int distanceFromEdge = 9;
        boolean userDefined = true;
        int referenceRow = 10;
        int referenceColumn = 20;
        short rowOffset = 40;
        short columnOffset = 80;

        List<Offset> offsets = ImmutableList.of(new Offset(rowOffset,
            columnOffset));

        Aperture aperture = new Aperture(userDefined, referenceRow,
            referenceColumn, offsets);

        ObservedTarget targetSrc = mock(ObservedTarget.class, "targetSrc");
        List<ObservedTarget> targetsSrc = ImmutableList.of(targetSrc);

        ObservedTarget targetDest = mock(ObservedTarget.class, "targetDest");
        List<ObservedTarget> targetsDest = ImmutableList.of(targetDest);

        TargetListSet targetListSetSrc = mock(TargetListSet.class,
            "targetListSetSrc");
        TargetListSet targetListSetDest = mock(TargetListSet.class,
            "targetListSetDest");

        TargetTable targetTableSrc = mock(TargetTable.class, "targetTableSrc");
        TargetTable targetTableDest = mock(TargetTable.class, "targetTableDest");

        int channel = 1;

        int ccdModule = FcConstants.getModuleOutput(channel).left;
        int ccdOutput = FcConstants.getModuleOutput(channel).right;

        ModuleOutputListsParameters moduleOutputListsParameters = new ModuleOutputListsParameters(
            new int[] { channel }, new int[] {});

        TargetCrud targetCrud = mock(TargetCrud.class);
        DatabaseService databaseService = mock(DatabaseService.class);

        allowing(targetListSetSrc).getTargetTable();
        will(returnValue(targetTableSrc));

        allowing(targetListSetDest).getTargetTable();
        will(returnValue(targetTableDest));

        allowing(targetCrud).retrieveObservedTargets(targetTableSrc, ccdModule,
            ccdOutput);
        will(returnValue(targetsSrc));

        allowing(targetCrud).retrieveObservedTargets(targetTableDest,
            ccdModule, ccdOutput, ALLOW_NULL_APERTURES);
        will(returnValue(targetsDest));

        allowing(targetSrc).getKeplerId();
        will(returnValue(keplerIdSrc));

        allowing(targetSrc).getCcdModule();
        will(returnValue(ccdModule));

        allowing(targetSrc).getCcdOutput();
        will(returnValue(ccdOutput));

        allowing(targetDest).getKeplerId();
        will(returnValue(keplerIdDest));

        allowing(targetDest).getCcdModule();
        will(returnValue(ccdModule));

        allowing(targetDest).getCcdOutput();
        will(returnValue(ccdOutput));

        allowing(targetListSetSrc).getName();
        will(returnValue(targetTableSrc.getClass()
            .getName()));

        allowing(targetSrc).getAperture();
        will(returnValue(aperture));

        allowing(targetSrc).getAperturePixelCount();
        will(returnValue(aperturePixelCount));

        allowing(targetSrc).getBadPixelCount();
        will(returnValue(badPixelCount));

        allowing(targetSrc).getSignalToNoiseRatio();
        will(returnValue(signalToNoiseRatio));

        allowing(targetSrc).getMagnitude();
        will(returnValue(magnitude));

        allowing(targetSrc).getRa();
        will(returnValue(ra));

        allowing(targetSrc).getDec();
        will(returnValue(dec));

        allowing(targetSrc).getEffectiveTemp();
        will(returnValue(effectiveTemp));

        allowing(targetSrc).getCrowdingMetric();
        will(returnValue(crowdingMetric));

        allowing(targetSrc).getSkyCrowdingMetric();
        will(returnValue(skyCrowdingMetric));

        allowing(targetSrc).getFluxFractionInAperture();
        will(returnValue(fluxFractionInAperture));

        allowing(targetSrc).getDistanceFromEdge();
        will(returnValue(distanceFromEdge));

        allowing(targetSrc).getSaturatedRowCount();
        will(returnValue(saturatedRowCount));

        oneOf(databaseService).flush();
        oneOf(databaseService).evictAll(targetsSrc);
        oneOf(databaseService).flush();
        oneOf(databaseService).evictAll(targetsDest);

        if (keplerIdSrc == keplerIdDest) {
            oneOf(targetDest).setAperture(aperture);
            oneOf(targetDest).setAperturePixelCount(aperturePixelCount);
            oneOf(targetDest).setBadPixelCount(badPixelCount);
            oneOf(targetDest).setSignalToNoiseRatio(signalToNoiseRatio);
            oneOf(targetDest).setMagnitude(magnitude);
            oneOf(targetDest).setRa(ra);
            oneOf(targetDest).setDec(dec);
            oneOf(targetDest).setEffectiveTemp(effectiveTemp);
            oneOf(targetDest).setCrowdingMetric(crowdingMetric);
            oneOf(targetDest).setSkyCrowdingMetric(skyCrowdingMetric);
            oneOf(targetDest).setFluxFractionInAperture(fluxFractionInAperture);
            oneOf(targetDest).setDistanceFromEdge(distanceFromEdge);
            oneOf(targetDest).setSaturatedRowCount(saturatedRowCount);
        }

        ObservedTargetsExporter exporter = new ObservedTargetsExporter(
            targetCrud, moduleOutputListsParameters, databaseService);
        File file = exporter.exportObservedTargets(targetListSetSrc);

        ObservedTargetsImporter importer = new ObservedTargetsImporter(
            targetCrud, databaseService, file, targetListSetDest,
            moduleOutputListsParameters);
        importer.run();

        boolean deleted = file.delete();
        if (!deleted) {
            throw new IllegalStateException("File was not deleted.");
        }
        assertTrue(!file.exists());
    }

}
