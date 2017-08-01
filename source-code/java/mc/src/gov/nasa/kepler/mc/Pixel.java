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

package gov.nasa.kepler.mc;

import gov.nasa.kepler.fs.api.FsId;

import java.util.Collections;
import java.util.HashSet;
import java.util.Set;

/**
 * A helper class for saving items from the inputs that are needed by the
 * outputs.
 * 
 * @author Forrest Girouard
 * @author Bill Wohler
 */
public class Pixel implements Comparable<Pixel> {

    private final FsId fsId;
    private final boolean inOptimalAperture;
    private final int row;
    private final int column;

    /**
     * Returns the corresponding set of {@link FsId}s for the given set of
     * {@link Pixel}s.
     * 
     * @param pixels the {@link Set} of {@link Pixel}s
     * @return a {@link Set} of {@link FsId}s.
     */
    public static Set<FsId> getAllFsIds(Set<Pixel> pixels) {

        Set<FsId> fsIds = Collections.emptySet();
        if (pixels != null && pixels.size() > 0) {
            fsIds = new HashSet<FsId>(pixels.size() * 2);
            for (Pixel pixel : pixels) {
                fsIds.addAll(pixel.getFsIds());
            }
        }
        return fsIds;
    }

    public static Set<FsId> getAllMjdFsIds(Set<Pixel> pixels) {

        Set<FsId> fsIds = Collections.emptySet();
        if (pixels != null && pixels.size() > 0) {
            fsIds = new HashSet<FsId>(pixels.size());
            for (Pixel pixel : pixels) {
                fsIds.addAll(pixel.getMjdFsIds());
            }
        }
        return fsIds;
    }

    public Pixel(int row, int column) {
        this.row = row;
        this.column = column;
        fsId = null;
        inOptimalAperture = false;
    }

    public Pixel(int row, int column, FsId fsId) {
        this.row = row;
        this.column = column;
        this.fsId = fsId;
        inOptimalAperture = false;
    }

    public Pixel(int row, int column, boolean inOptimalAperture) {
        this.row = row;
        this.column = column;
        fsId = null;
        this.inOptimalAperture = inOptimalAperture;
    }

    public Pixel(int row, int column, FsId fsId, boolean inOptimalAperture) {
        this.row = row;
        this.column = column;
        this.fsId = fsId;
        this.inOptimalAperture = inOptimalAperture;
    }

    public int getRow() {
        return row;
    }

    public int getColumn() {
        return column;
    }

    public FsId getFsId() {
        return fsId;
    }

    /**
     * The fsid associated with this pixel in a set, if the fsId is null then
     * the set will contain a null.
     * @return A non-null mutable set of size 1.
     */
    public Set<FsId> getFsIds() {
        Set<FsId> fsIds = new HashSet<FsId>();
        fsIds.add(fsId);
        return fsIds;
    }

    public Set<FsId> getMjdFsIds() {
        return Collections.emptySet();
    }

    public boolean isInOptimalAperture() {
        return inOptimalAperture;
    }

    /**
     * Returns a hash code value for the object. Only the {@code row} and
     * {@code column} fields are considered.
     */
    @Override
    public int hashCode() {
        return row ^ Integer.rotateLeft(column, 16);
    }

    /**
     * Indicates whether some other object is "equal to" this one. Only the
     * {@code row} and {@code column} fields are considered.
     */
    @Override
    public boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (obj == null) {
            return false;
        }
        if (!(obj instanceof Pixel)) {
            return false;
        }
        Pixel other = (Pixel) obj;
        if (other.row != row) {
            return false;
        }
        return other.column == column;
    }

    public int compareTo(Pixel obj) {
        int diff = row - obj.row;
        if (diff != 0) {
            return diff;
        }
        return column - obj.column;
    }

    @Override
    public String toString() {
        StringBuilder bldr = new StringBuilder(11);
        bldr.append('(')
            .append(row)
            .append(',')
            .append(column)
            .append(')');
        return bldr.toString();
    }
}
