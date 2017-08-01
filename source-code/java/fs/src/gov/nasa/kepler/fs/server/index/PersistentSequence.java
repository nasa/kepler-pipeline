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

package gov.nasa.kepler.fs.server.index;

import java.io.File;
import java.io.IOException;
import java.io.RandomAccessFile;

/**
 * A sequence number that is written to disk.
 * File format:
 *  1 byte version
 *  next available number 4 bytes
 *  redundant copy of next available number 4 bytes
 *  
 * @author Sean McCauliff
 *
 */
public class PersistentSequence {
    /**
     * The file format version number in use.
     */
    private static final byte FORMAT_VERSION = 0;
    private static final long FILE_SIZE = 9;
    
    private final RandomAccessFile storage;
    private int sequence = -1;
    
    protected PersistentSequence() {
        storage = null;
    }
    
    public PersistentSequence(File file) throws IOException {
        this(file, 0);
    }
    
    public PersistentSequence(File file, int initialValue) throws IOException {
        storage = new RandomAccessFile(file, "rw");
        if (storage.length() != FILE_SIZE) {
            storage.writeByte(FORMAT_VERSION);
            storage.writeInt(initialValue);
            storage.writeInt(initialValue);
            sequence = initialValue;
        } else {
            byte readVersion = storage.readByte();
            if (readVersion != FORMAT_VERSION) {
                throw new IOException("Expected version " + FORMAT_VERSION
                    + " but got version " + readVersion + " for sequence file \""+
                      file + "\".");
            }
            int firstInt = storage.readInt();
            int secondInt = storage.readInt();
            if (firstInt != secondInt) {
                throw new IOException("Sequence file \"" + file + "\" is corrupted.");
            }
            sequence = firstInt;
        }
    }
    
    public synchronized int next() throws IOException {
        int rv = sequence++;
        storage.seek(1);
        storage.writeInt(sequence);
        storage.writeInt(sequence);
        storage.getFD().sync();
        return rv;
    }
    
    public void close() throws IOException {
        storage.close();
    }
}
