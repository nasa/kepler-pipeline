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

package gov.nasa.kepler.mc.uow;

import static com.google.common.collect.Lists.newArrayList;
import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.common.ranges.Ranges;
import gov.nasa.kepler.hibernate.pi.UnitOfWorkTask;
import gov.nasa.kepler.hibernate.tad.ModOut;
import gov.nasa.spiffy.common.collect.Pair;

import java.util.List;

import com.google.common.primitives.Ints;

public class ModOutUowTask extends UnitOfWorkTask implements ModOutBinnable {

    @SuppressWarnings("unchecked")
    protected List<Pair<Integer, Integer>> modOuts = newArrayList(Pair.of(0, 0));

    static final String getChannelString(int[] channels) {
        StringBuilder b = new StringBuilder("[");

        Ranges ranges = Ranges.forIntegers(Ints.asList(channels));
        b.append(ranges.toString());

        b.append("]");

        return b.toString();
    }

    public ModOut modOut() {
        return ModOut.of(getCcdModule(), getCcdOutput());
    }

    public int getCcdModule() {
        return modOuts.get(0).left;
    }

    public void setCcdModule(int ccdModule) {
        Pair<Integer, Integer> previousModOut = modOuts.get(0);
        modOuts.set(0, Pair.of(ccdModule, previousModOut.right));
    }

    public int getCcdOutput() {
        return modOuts.get(0).right;
    }

    public void setCcdOutput(int ccdOutput) {
        Pair<Integer, Integer> previousModOut = modOuts.get(0);
        modOuts.set(0, Pair.of(previousModOut.left, ccdOutput));
    }

    public int[] getChannels() {
        List<Integer> channels = newArrayList();
        for (Pair<Integer, Integer> modOut : modOuts) {
            try {
                int channelNumber = FcConstants.getChannelNumber(modOut.left,
                    modOut.right);
                FcConstants.getModuleOutput(channelNumber);
                channels.add(channelNumber);
            } catch (Exception e) {
            }

        }
        return Ints.toArray(channels);
    }

    public void setChannels(int[] channels) {
        if (channels != null && channels.length != 0) {
            modOuts = newArrayList();
            for (int channel : channels) {
                try {
                    Pair<Integer, Integer> moduleOutput = FcConstants.getModuleOutput(channel);
                    modOuts.add(moduleOutput);
                } catch (Exception e) {
                }
            }
        }
    }

    public String briefState() {
        if (getChannels().length == 0) {
            return "[uninitialized]";
        }
        return getChannelString(getChannels());
    }

    @Override
    public String toString() {
        return briefState();
    }

    public ModOutUowTask makeCopy() {
        return new ModOutUowTask(modOuts);
    }

    public ModOutUowTask() {
    }

    public ModOutUowTask(int ccdModule, int ccdOutput) {
        setCcdModule(ccdModule);
        setCcdOutput(ccdOutput);
    }

    public ModOutUowTask(int[] channels) {
        setChannels(channels);
    }

    protected ModOutUowTask(List<Pair<Integer, Integer>> modOuts) {
        this.modOuts = modOuts;
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result + ((modOuts == null) ? 0 : modOuts.hashCode());
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
        ModOutUowTask other = (ModOutUowTask) obj;
        if (modOuts == null) {
            if (other.modOuts != null)
                return false;
        } else if (!modOuts.equals(other.modOuts))
            return false;
        return true;
    }

}
