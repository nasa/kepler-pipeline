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

package gov.nasa.kepler.tad.peer.merge;

import gov.nasa.kepler.hibernate.cm.PlannedTarget;
import gov.nasa.kepler.hibernate.cm.PlannedTarget.TargetLabel;
import gov.nasa.kepler.hibernate.cm.TargetList;
import gov.nasa.kepler.tad.peer.AmaModuleParameters;

import org.junit.Before;
import org.junit.Test;

import com.google.common.collect.ImmutableList;

public class TadLabelValidatorTest {

    private static final int STELLAR_KEPLER_ID = 5000000;
    private static final int CUSTOM_KEPLER_ID = 100000000;

    private static final int SKY_GROUP_ID = 1;

    private static final TargetLabel DEFAULT_STELLAR_HALO_LABEL = TargetLabel.TAD_ONE_HALO;
    private static final TargetLabel DEFAULT_STELLAR_UNDERSHOOT_LABEL = TargetLabel.TAD_ADD_UNDERSHOOT_COLUMN;
    private static final TargetLabel DEFAULT_CUSTOM_HALO_LABEL = TargetLabel.TAD_NO_HALO;
    private static final TargetLabel DEFAULT_CUSTOM_UNDERSHOOT_LABEL = TargetLabel.TAD_NO_UNDERSHOOT_COLUMN;

    private static final TargetLabel NON_DEFAULT_STELLAR_HALO_LABEL = TargetLabel.TAD_NO_HALO;
    private static final TargetLabel NON_DEFAULT_STELLAR_UNDERSHOOT_LABEL = TargetLabel.TAD_NO_UNDERSHOOT_COLUMN;
    private static final TargetLabel NON_DEFAULT_CUSTOM_HALO_LABEL = TargetLabel.TAD_ONE_HALO;
    private static final TargetLabel NON_DEFAULT_CUSTOM_UNDERSHOOT_LABEL = TargetLabel.TAD_ADD_UNDERSHOOT_COLUMN;

    private AmaModuleParameters amaModuleParameters;
    private TargetList targetList;

    @Before
    public void setUp() {
        amaModuleParameters = new AmaModuleParameters();
        amaModuleParameters.setDefaultStellarLabels(new String[] {
            DEFAULT_STELLAR_HALO_LABEL.toString(),
            DEFAULT_STELLAR_UNDERSHOOT_LABEL.toString() });
        amaModuleParameters.setDefaultCustomLabels(new String[] {
            DEFAULT_CUSTOM_HALO_LABEL.toString(),
            DEFAULT_CUSTOM_UNDERSHOOT_LABEL.toString() });

        targetList = new TargetList("planetary.txt");
    }

    @Test
    public void testValidateStellarHaloConsistent() {
        final PlannedTarget plannedTargetNoLabels = new PlannedTarget(
            STELLAR_KEPLER_ID, SKY_GROUP_ID, targetList);

        final PlannedTarget plannedTargetWithLabels = new PlannedTarget(
            STELLAR_KEPLER_ID, SKY_GROUP_ID, targetList);
        plannedTargetWithLabels.addLabel(DEFAULT_STELLAR_HALO_LABEL);

        TadLabelValidator tadLabelValidator = new TadLabelValidator(
            amaModuleParameters);
        tadLabelValidator.validate(ImmutableList.of(plannedTargetNoLabels));
        tadLabelValidator.validate(ImmutableList.of(plannedTargetWithLabels));
    }

    @Test(expected = IllegalArgumentException.class)
    public void testValidateStellarHaloInconsistent() {
        final PlannedTarget plannedTargetNoLabels = new PlannedTarget(
            STELLAR_KEPLER_ID, SKY_GROUP_ID, targetList);

        final PlannedTarget plannedTargetWithLabels = new PlannedTarget(
            STELLAR_KEPLER_ID, SKY_GROUP_ID, targetList);
        plannedTargetWithLabels.addLabel(NON_DEFAULT_STELLAR_HALO_LABEL);

        TadLabelValidator tadLabelValidator = new TadLabelValidator(
            amaModuleParameters);
        tadLabelValidator.validate(ImmutableList.of(plannedTargetNoLabels));
        tadLabelValidator.validate(ImmutableList.of(plannedTargetWithLabels));
    }

    @Test
    public void testValidateStellarUndershootConsistent() {
        final PlannedTarget plannedTargetNoLabels = new PlannedTarget(
            STELLAR_KEPLER_ID, SKY_GROUP_ID, targetList);

        final PlannedTarget plannedTargetWithLabels = new PlannedTarget(
            STELLAR_KEPLER_ID, SKY_GROUP_ID, targetList);
        plannedTargetWithLabels.addLabel(DEFAULT_STELLAR_UNDERSHOOT_LABEL);

        TadLabelValidator tadLabelValidator = new TadLabelValidator(
            amaModuleParameters);
        tadLabelValidator.validate(ImmutableList.of(plannedTargetNoLabels));
        tadLabelValidator.validate(ImmutableList.of(plannedTargetWithLabels));
    }

    @Test(expected = IllegalArgumentException.class)
    public void testValidateStellarUndershootInconsistent() {
        final PlannedTarget plannedTargetNoLabels = new PlannedTarget(
            STELLAR_KEPLER_ID, SKY_GROUP_ID, targetList);

        final PlannedTarget plannedTargetWithLabels = new PlannedTarget(
            STELLAR_KEPLER_ID, SKY_GROUP_ID, targetList);
        plannedTargetWithLabels.addLabel(NON_DEFAULT_STELLAR_UNDERSHOOT_LABEL);

        TadLabelValidator tadLabelValidator = new TadLabelValidator(
            amaModuleParameters);
        tadLabelValidator.validate(ImmutableList.of(plannedTargetNoLabels));
        tadLabelValidator.validate(ImmutableList.of(plannedTargetWithLabels));
    }

    @Test
    public void testValidateCustomHaloConsistent() {
        final PlannedTarget plannedTargetNoLabels = new PlannedTarget(
            CUSTOM_KEPLER_ID, SKY_GROUP_ID, targetList);

        final PlannedTarget plannedTargetWithLabels = new PlannedTarget(
            CUSTOM_KEPLER_ID, SKY_GROUP_ID, targetList);
        plannedTargetWithLabels.addLabel(DEFAULT_CUSTOM_HALO_LABEL);

        TadLabelValidator tadLabelValidator = new TadLabelValidator(
            amaModuleParameters);
        tadLabelValidator.validate(ImmutableList.of(plannedTargetNoLabels));
        tadLabelValidator.validate(ImmutableList.of(plannedTargetWithLabels));
    }

    @Test(expected = IllegalArgumentException.class)
    public void testValidateCUSTOMHaloInconsistent() {
        final PlannedTarget plannedTargetNoLabels = new PlannedTarget(
            CUSTOM_KEPLER_ID, SKY_GROUP_ID, targetList);

        final PlannedTarget plannedTargetWithLabels = new PlannedTarget(
            CUSTOM_KEPLER_ID, SKY_GROUP_ID, targetList);
        plannedTargetWithLabels.addLabel(NON_DEFAULT_CUSTOM_HALO_LABEL);

        TadLabelValidator tadLabelValidator = new TadLabelValidator(
            amaModuleParameters);
        tadLabelValidator.validate(ImmutableList.of(plannedTargetNoLabels));
        tadLabelValidator.validate(ImmutableList.of(plannedTargetWithLabels));
    }

    @Test
    public void testValidateCUSTOMUndershootConsistent() {
        final PlannedTarget plannedTargetNoLabels = new PlannedTarget(
            CUSTOM_KEPLER_ID, SKY_GROUP_ID, targetList);

        final PlannedTarget plannedTargetWithLabels = new PlannedTarget(
            CUSTOM_KEPLER_ID, SKY_GROUP_ID, targetList);
        plannedTargetWithLabels.addLabel(DEFAULT_CUSTOM_UNDERSHOOT_LABEL);

        TadLabelValidator tadLabelValidator = new TadLabelValidator(
            amaModuleParameters);
        tadLabelValidator.validate(ImmutableList.of(plannedTargetNoLabels));
        tadLabelValidator.validate(ImmutableList.of(plannedTargetWithLabels));
    }

    @Test(expected = IllegalArgumentException.class)
    public void testValidateCUSTOMUndershootInconsistent() {
        final PlannedTarget plannedTargetNoLabels = new PlannedTarget(
            CUSTOM_KEPLER_ID, SKY_GROUP_ID, targetList);

        final PlannedTarget plannedTargetWithLabels = new PlannedTarget(
            CUSTOM_KEPLER_ID, SKY_GROUP_ID, targetList);
        plannedTargetWithLabels.addLabel(NON_DEFAULT_CUSTOM_UNDERSHOOT_LABEL);

        TadLabelValidator tadLabelValidator = new TadLabelValidator(
            amaModuleParameters);
        tadLabelValidator.validate(ImmutableList.of(plannedTargetNoLabels));
        tadLabelValidator.validate(ImmutableList.of(plannedTargetWithLabels));
    }

}
