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

package gov.nasa.kepler.tad.peer.amt;

import static org.junit.Assert.assertEquals;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.tad.Aperture;
import gov.nasa.kepler.hibernate.tad.Mask;
import gov.nasa.kepler.hibernate.tad.ObservedTarget;
import gov.nasa.kepler.mc.tad.TadParameters;
import gov.nasa.kepler.tad.peer.AmaModuleParameters;
import gov.nasa.kepler.tad.peer.AmtModuleParameters;
import gov.nasa.kepler.tad.peer.ApertureStruct;
import gov.nasa.kepler.tad.peer.ApertureStructFactory;
import gov.nasa.kepler.tad.peer.MaskDefinition;
import gov.nasa.kepler.tad.peer.MaskDefinitionFactory;
import gov.nasa.kepler.tad.peer.MaskTableParameters;
import gov.nasa.spiffy.common.jmock.JMockTest;
import gov.nasa.spiffy.common.pojo.PojoTest;

import java.util.List;

import org.junit.Test;

import com.google.common.collect.ImmutableList;

/**
 * @author Miles Cote
 * 
 */
public class AmtInputsTest extends JMockTest {

    private PipelineTask pipelineTask = mock(PipelineTask.class);
    private TadParameters tadParameters = mock(TadParameters.class);
    private MaskDefinition maskDefinition = mock(MaskDefinition.class);
    private List<MaskDefinition> maskDefinitions = ImmutableList.of(maskDefinition);
    private Mask mask = mock(Mask.class);
    private List<Mask> masks = ImmutableList.of(mask);
    private ApertureStruct apertureStruct = mock(ApertureStruct.class);
    private List<ApertureStruct> apertureStructs = ImmutableList.of(apertureStruct);
    private AmtModuleParameters amtModuleParameters = mock(AmtModuleParameters.class);
    private AmaModuleParameters amaModuleParameters = mock(AmaModuleParameters.class);
    private MaskTableParameters maskTableParameters = mock(MaskTableParameters.class);
    private ObservedTarget observedTarget = mock(ObservedTarget.class);
    private List<ObservedTarget> observedTargets = ImmutableList.of(observedTarget);
    private Aperture aperture = mock(Aperture.class);

    private MaskDefinitionFactory maskDefinitionFactory = mock(MaskDefinitionFactory.class);
    private ApertureStructFactory apertureStructFactory = mock(ApertureStructFactory.class);

    private AmtInputs amtInputs = new AmtInputs(maskDefinitionFactory,
        apertureStructFactory);

    @Test
    public void testGettersSetters() {
        PojoTest.testGettersSetters(new AmtInputs());
    }

    @Test
    public void testRetrieveFor() {
        setAllowances();

        amtInputs.retrieveFor(pipelineTask);

        assertEquals(maskDefinitions, amtInputs.getMaskDefinitions());
        assertEquals(apertureStructs, amtInputs.getApertureStructs());
        assertEquals(amtModuleParameters, amtInputs.getAmtConfigurationStruct());
        assertEquals(amaModuleParameters, amtInputs.getAmaConfigurationStruct());
        assertEquals(maskTableParameters,
            amtInputs.getMaskTableParametersStruct());
    }

    private void setAllowances() {
        allowing(pipelineTask).getParameters(TadParameters.class);
        will(returnValue(tadParameters));

        allowing(pipelineTask).getParameters(AmtModuleParameters.class);
        will(returnValue(amtModuleParameters));

        allowing(pipelineTask).getParameters(AmaModuleParameters.class);
        will(returnValue(amaModuleParameters));

        allowing(pipelineTask).getParameters(MaskTableParameters.class);
        will(returnValue(maskTableParameters));

        allowing(tadParameters).masks();
        will(returnValue(masks));

        allowing(maskDefinitionFactory).create(mask);
        will(returnValue(maskDefinition));

        allowing(amtModuleParameters).getUseOptimalApertureInputs();
        will(returnValue(AmtInputs.OPTIMAL_APERTURE_INPUTS_ENABLED));

        allowing(tadParameters).observedTargetsPlusRejected();
        will(returnValue(observedTargets));

        allowing(observedTarget).getAperture();
        will(returnValue(aperture));

        allowing(apertureStructFactory).create(observedTarget);
        will(returnValue(apertureStruct));
    }

}
