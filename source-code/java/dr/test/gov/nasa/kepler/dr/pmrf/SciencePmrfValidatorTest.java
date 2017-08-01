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

package gov.nasa.kepler.dr.pmrf;

import gov.nasa.kepler.dr.fits.FitsFileBuilder;
import gov.nasa.kepler.hibernate.tad.ModOut;
import gov.nasa.kepler.hibernate.tad.ModOutsFactory;
import gov.nasa.kepler.hibernate.tad.TargetCrud;
import gov.nasa.kepler.hibernate.tad.TargetDefinition;
import gov.nasa.spiffy.common.jmock.JMockTest;

import java.util.ArrayList;
import java.util.List;

import org.junit.Test;

import com.google.common.collect.ImmutableList;

/**
 * @author Miles Cote
 * 
 */
public class SciencePmrfValidatorTest extends JMockTest {

    private static final int ILLEGAL_ARG = -1;

    private SciencePmrf sciencePmrf = new SciencePmrfBuilder().build();

    private SciencePmrfModOut sciencePmrfModOut = sciencePmrf.getSciencePmrfModOuts()
        .get(0);
    private ModOut modOut = sciencePmrfModOut.getModOut();
    private List<ModOut> modOuts = ImmutableList.of(modOut);
    private TadTargetTable tadTargetTable = sciencePmrf.toTadTargetTable();

    private TargetCrud targetCrud = mock(TargetCrud.class);
    private ModOutsFactory modOutsFactory = mock(ModOutsFactory.class);

    private SciencePmrfValidator sciencePmrfValidator = new SciencePmrfValidator(
        targetCrud, modOutsFactory);

    @Test
    public void passesWithValidPmrf() {
        setAllowances();

        sciencePmrfValidator.validate(sciencePmrf.toPmrf());
    }

    @Test(expected = IllegalArgumentException.class)
    public void failsWithInvalidPmrf() {
        setAllowances();

        sciencePmrfValidator.validate(new PmrfBuilder().withFitsFile(
            new FitsFileBuilder().withFitsTables(
                ImmutableList.of(new SciencePmrfModOutBuilder().withModOut(
                    ModOut.of(ILLEGAL_ARG, ILLEGAL_ARG))
                    .build()
                    .toFitsTable()))
                .build())
            .build());
    }

    /**
     * KSOC-2272: This is legacy behavior of pmrfDispatcher. This behavior needs
     * to be preserved because of the existing data in the database.
     */
    @Test
    public void passesWhenPmrfHasEntriesAndTadEntriesIsEmpty() {
        allowing(targetCrud).retrieveTargetDefinitions(
            tadTargetTable.getTargetTable(), modOut.getCcdModule(),
            modOut.getCcdOutput());
        will(returnValue(new ArrayList<TargetDefinition>()));

        setAllowances();

        sciencePmrfValidator.validate(sciencePmrf.toPmrf());
    }

    private void setAllowances() {
        allowing(targetCrud).retrieveUplinkedTargetTable(
            tadTargetTable.getTargetTable()
                .getExternalId(), tadTargetTable.getTargetTable()
                .getType());
        will(returnValue(tadTargetTable.getTargetTable()));

        allowing(modOutsFactory).create();
        will(returnValue(modOuts));

        allowing(targetCrud).retrieveTargetDefinitions(
            tadTargetTable.getTargetTable(), modOut.getCcdModule(),
            modOut.getCcdOutput());
        will(returnValue(tadTargetTable.getTadTargetTableModOuts()
            .get(0)
            .getTargetDefinitions()));
    }

}
