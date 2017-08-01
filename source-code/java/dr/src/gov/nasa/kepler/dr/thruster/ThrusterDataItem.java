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

package gov.nasa.kepler.dr.thruster;

import org.apache.commons.lang.builder.ReflectionToStringBuilder;

/**
 * Contains the content of a single line of thruster firing data.
 * 
 * @author Bill Wohler
 */
public class ThrusterDataItem {

    /**
     * An enumeration of the thruster mnemonics. There are eight thrusters, and
     * the thruster number is 1-based.
     * 
     * @author Bill Wohler
     */
    public enum ThrusterMnemonic {
        ADTHR1CNTNIC(1),
        ADTHR2CNTNIC(2),
        ADTHR3CNTNIC(3),
        ADTHR4CNTNIC(4),
        ADTHR5CNTNIC(5),
        ADTHR6CNTNIC(6),
        ADTHR7CNTNIC(7),
        ADTHR8CNTNIC(8);

        private int thrusterNumber;

        private ThrusterMnemonic(int thrusterNumber) {
            this.thrusterNumber = thrusterNumber;
        }

        public int getThrusterNumber() {
            return thrusterNumber;
        }

        /**
         * Returns the mnemonic as a string for the given thruster number. This
         * string is appropriate in an FSID.
         * 
         * @throws IllegalArgumentException if the number is not a valid
         * thruster number (1-{@link ThrusterDataItem#THRUSTER_COUNT}).
         */
        public static String mnemonic(int thrusterNumber) {
            for (ThrusterMnemonic mnemonic : values()) {
                if (mnemonic.getThrusterNumber() == thrusterNumber) {
                    return mnemonic.toString();
                }
            }
            throw new IllegalArgumentException("Unknown thruster number "
                + thrusterNumber);
        }
    };

    public static final int THRUSTER_COUNT = ThrusterMnemonic.values().length;

    private double spacecraftTime;
    private float[] thrusterData = new float[THRUSTER_COUNT];

    /**
     * Creates a {@link ThrusterDataItem}. The spacecraft time is in MJD and the
     * thruster firing values are in seconds.
     */
    public ThrusterDataItem(double spacecraftTime, float thruster1,
        float thruster2, float thruster3, float thruster4, float thruster5,
        float thruster6, float thruster7, float thruster8) {
        this.spacecraftTime = spacecraftTime;

        // Thruster numbers are 1-based.
        thrusterData[0] = thruster1;
        thrusterData[1] = thruster2;
        thrusterData[2] = thruster3;
        thrusterData[3] = thruster4;
        thrusterData[4] = thruster5;
        thrusterData[5] = thruster6;
        thrusterData[6] = thruster7;
        thrusterData[7] = thruster8;
    }

    public double getSpacecraftTime() {
        return spacecraftTime;
    }

    /**
     * Returns the thruster data for the given thruster (1 based, or 1-
     * {@link THRUSTER_COUNT}).
     */
    public float getThrusterData(int i) {
        // Ensure thruster number is valid.
        ThrusterMnemonic.mnemonic(i);

        return thrusterData[i - 1];
    }

    @Override
    public String toString() {
        return new ReflectionToStringBuilder(this).toString();
    }
}
