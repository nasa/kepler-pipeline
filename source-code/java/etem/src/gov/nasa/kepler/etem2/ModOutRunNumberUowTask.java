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

package gov.nasa.kepler.etem2;

import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.hibernate.pi.UnitOfWorkTask;
import gov.nasa.kepler.mc.uow.ModOutBinnable;

import java.util.Arrays;

/**
 * {@link UnitOfWorkTask} for pipelines that divide up the work using cadence
 * range bins and module/output bins.
 * 
 * @author Todd Klaus tklaus@arc.nasa.gov
 * 
 */
public class ModOutRunNumberUowTask extends UnitOfWorkTask implements ModOutBinnable,
    EtemRunNumberRangeBinnable {

    private int[] channels;

    private int startRunNumber;
    private int endRunNumber;

    public ModOutRunNumberUowTask() {
        this(new int[0], 0, 0);
    }

    public ModOutRunNumberUowTask(int ccdModule, int ccdOutput,
        int startRunNumber, int endRunNumber) {
        this(new int[] { FcConstants.getChannelNumber(ccdModule, ccdOutput) },
            startRunNumber, endRunNumber);
    }

    public ModOutRunNumberUowTask(int[] channels, int startRunNumber,
        int endRunNumber) {
        this.channels = channels;
        this.startRunNumber = startRunNumber;
        this.endRunNumber = endRunNumber;
    }

    public ModOutRunNumberUowTask makeCopy() {
        return new ModOutRunNumberUowTask(channels, startRunNumber,
            endRunNumber);
    }

    public int getCcdModule() {
        if (channels.length > 1) {
            throw new IllegalStateException(
                "If channels.length is greater than 1, then getCcdModule cannot be called. Consider calling getChannels instead."
                    + "\n  channels.length: " + channels.length);
        }

        return channels.length == 0 ? 0 : FcConstants.getModuleOutput(channels[0]).left;
    }

    public int getCcdOutput() {
        if (channels.length > 1) {
            throw new IllegalStateException(
                "If channels.length is greater than 1, then getCcdOutput cannot be called. Consider calling getChannels instead."
                    + "\n  channels.length: " + channels.length);
        }

        return channels.length == 0 ? 0 : FcConstants.getModuleOutput(channels[0]).right;
    }

    public int[] getChannels() {
        return channels;
    }

    public void setChannels(int[] channels) {
        this.channels = channels;
    }

    public int getEndRunNumber() {
        return endRunNumber;
    }

    public void setEndRunNumber(int endRunNumber) {
        this.endRunNumber = endRunNumber;
    }

    public int getStartRunNumber() {
        return startRunNumber;
    }

    public void setStartRunNumber(int startRunNumber) {
        this.startRunNumber = startRunNumber;
    }

    public String briefState() {
        return "[" + startRunNumber + "," + endRunNumber + "]"
            + Arrays.toString(channels);
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result + Arrays.hashCode(channels);
        result = prime * result + endRunNumber;
        result = prime * result + startRunNumber;
        return result;
    }

    @Override
    public boolean equals(Object obj) {
        if (this == obj)
            return true;
        if (obj == null)
            return false;
        if (getClass() != obj.getClass())
            return false;
        ModOutRunNumberUowTask other = (ModOutRunNumberUowTask) obj;
        if (!Arrays.equals(channels, other.channels))
            return false;
        if (endRunNumber != other.endRunNumber)
            return false;
        if (startRunNumber != other.startRunNumber)
            return false;
        return true;
    }

    @Override
    public String toString() {
        return briefState();
    }

}
