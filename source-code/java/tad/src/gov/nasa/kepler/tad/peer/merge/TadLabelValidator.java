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

import static com.google.common.collect.Maps.newHashMap;
import gov.nasa.kepler.common.TargetManagementConstants;
import gov.nasa.kepler.hibernate.cm.PlannedTarget;
import gov.nasa.kepler.hibernate.cm.PlannedTarget.TargetLabel;
import gov.nasa.kepler.tad.peer.AmaModuleParameters;

import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * Validates tad labels.
 * 
 * @author Miles Cote
 * 
 */
class TadLabelValidator {

    private TargetLabel defaultStellarHaloLabel;
    private TargetLabel defaultStellarUndershootLabel;
    private TargetLabel defaultCustomHaloLabel;
    private TargetLabel defaultCustomUndershootLabel;

    private Map<Integer, ValidatorTarget> keplerIdToValidatorTarget = newHashMap();

    TadLabelValidator(AmaModuleParameters amaModuleParameters) {
        String[] defaultStellarLabels = amaModuleParameters.getDefaultStellarLabels();
        for (String defaultStellarLabel : defaultStellarLabels) {
            if (TargetLabel.isTadLabel(defaultStellarLabel)) {
                if (TargetLabel.isHaloLabel(defaultStellarLabel)) {
                    defaultStellarHaloLabel = TargetLabel.getHaloLabel(defaultStellarLabel);
                } else if (TargetLabel.isUndershootLabel(defaultStellarLabel)) {
                    defaultStellarUndershootLabel = TargetLabel.valueOf(defaultStellarLabel);
                }
            }
        }

        String[] defaultCustomLabels = amaModuleParameters.getDefaultCustomLabels();
        for (String defaultCustomLabel : defaultCustomLabels) {
            if (TargetLabel.isTadLabel(defaultCustomLabel)) {
                if (TargetLabel.isHaloLabel(defaultCustomLabel)) {
                    defaultCustomHaloLabel = TargetLabel.getHaloLabel(defaultCustomLabel);
                } else if (TargetLabel.isUndershootLabel(defaultCustomLabel)) {
                    defaultCustomUndershootLabel = TargetLabel.valueOf(defaultCustomLabel);
                }
            }
        }

        if (defaultStellarHaloLabel == null) {
            throw new IllegalArgumentException(
                AmaModuleParameters.class
                    + " must contain a default stellar halo label.\n  defaultStellarLabels: "
                    + Arrays.toString(defaultStellarLabels));
        }
        if (defaultStellarUndershootLabel == null) {
            throw new IllegalArgumentException(
                AmaModuleParameters.class
                    + " must contain a default stellar undershoot label.\n  defaultStellarLabels: "
                    + Arrays.toString(defaultStellarLabels));
        }
        if (defaultCustomHaloLabel == null) {
            throw new IllegalArgumentException(
                AmaModuleParameters.class
                    + " must contain a default custom halo label.\n  defaultCustomLabels: "
                    + Arrays.toString(defaultCustomLabels));
        }
        if (defaultCustomUndershootLabel == null) {
            throw new IllegalArgumentException(
                AmaModuleParameters.class
                    + " must contain a default custom undershoot label.\n  defaultCustomLabels: "
                    + Arrays.toString(defaultCustomLabels));
        }
    }

    void validate(List<PlannedTarget> plannedTargets) {
        for (PlannedTarget plannedTarget : plannedTargets) {
            int keplerId = plannedTarget.getKeplerId();

            ValidatorTarget validatorTarget = new ValidatorTarget(plannedTarget);

            ValidatorTarget existingValidatorTarget = keplerIdToValidatorTarget.get(keplerId);
            if (existingValidatorTarget == null) {
                keplerIdToValidatorTarget.put(keplerId, validatorTarget);
            } else {
                if (!existingValidatorTarget.equals(validatorTarget)) {
                    throw new IllegalArgumentException(
                        "PlannedTargets with the same keplerId must have consistent labels.\n  "
                            + existingValidatorTarget + "\n  "
                            + validatorTarget);
                }
            }
        }
    }

    private final class ValidatorTarget {

        private int keplerId;
        private String targetListName;
        private TargetLabel haloLabel;
        private boolean haloFromDefault;
        private TargetLabel undershootLabel;
        private boolean undershootFromDefault;

        public ValidatorTarget(PlannedTarget plannedTarget) {
            keplerId = plannedTarget.getKeplerId();
            targetListName = plannedTarget.getTargetList()
                .getName();

            Set<String> labels = plannedTarget.getLabels();
            for (String label : labels) {
                if (TargetLabel.isTadLabel(label)) {
                    if (TargetLabel.isHaloLabel(label)) {
                        haloLabel = TargetLabel.getHaloLabel(label);
                        haloFromDefault = false;
                    } else if (TargetLabel.isUndershootLabel(label)) {
                        undershootLabel = TargetLabel.valueOf(label);
                        undershootFromDefault = false;
                    }
                }
            }

            if (haloLabel == null) {
                haloLabel = TargetManagementConstants.isCustomTarget(keplerId) ? defaultCustomHaloLabel
                    : defaultStellarHaloLabel;
                haloFromDefault = true;
            }

            if (undershootLabel == null) {
                undershootLabel = TargetManagementConstants.isCustomTarget(keplerId) ? defaultCustomUndershootLabel
                    : defaultStellarUndershootLabel;
                undershootFromDefault = true;
            }
        }

        @Override
        public int hashCode() {
            final int prime = 31;
            int result = 1;
            result = prime * result + getOuterType().hashCode();
            result = prime * result
                + (haloLabel == null ? 0 : haloLabel.hashCode());
            result = prime * result + keplerId;
            result = prime * result
                + (undershootLabel == null ? 0 : undershootLabel.hashCode());
            return result;
        }

        @Override
        public boolean equals(Object obj) {
            if (this == obj) {
                return true;
            }
            if (obj == null) {
                return false;
            }
            if (getClass() != obj.getClass()) {
                return false;
            }
            ValidatorTarget other = (ValidatorTarget) obj;
            if (!getOuterType().equals(other.getOuterType())) {
                return false;
            }
            if (haloLabel == null) {
                if (other.haloLabel != null) {
                    return false;
                }
            } else if (!haloLabel.equals(other.haloLabel)) {
                return false;
            }
            if (keplerId != other.keplerId) {
                return false;
            }
            if (undershootLabel == null) {
                if (other.undershootLabel != null) {
                    return false;
                }
            } else if (!undershootLabel.equals(other.undershootLabel)) {
                return false;
            }
            return true;
        }

        @Override
        public String toString() {
            String haloFromDefaultModifier = haloFromDefault ? "(copied from default labels)"
                : "";
            String undershootFromDefaultModifier = undershootFromDefault ? "(copied from default labels)"
                : "";

            return "keplerId " + keplerId + " from target list "
                + targetListName + " has a halo label of " + haloLabel + " "
                + haloFromDefaultModifier + ", and an undershoot label of "
                + undershootLabel + " " + undershootFromDefaultModifier + ".";
        }

        private TadLabelValidator getOuterType() {
            return TadLabelValidator.this;
        }
    }

}
