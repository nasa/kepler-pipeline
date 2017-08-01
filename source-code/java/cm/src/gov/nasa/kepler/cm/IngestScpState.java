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

package gov.nasa.kepler.cm;

/**
 * The current progress state of the ingest process. This class is used by UI
 * programs to display to the user how far along the ingest process has gotten.
 * The UI program should create an object of this type and pass it into the
 * ingester, which is updated by the ingester. The UI program should
 * periodically check the content and update the user's display, typically in a
 * progress bar.
 * 
 * @author Bill Wohler
 */
public class IngestScpState {
    private String name;
    private int totalFileCount;
    private int fileCount;
    private int rowCount;
    private long totalCharCount;
    private long charCount;

    /**
     * Get the name of the file currently being ingested.
     * 
     * @return the name of the file being ingested.
     */
    public String getName() {
        return name;
    }

    /**
     * Set the name of the file currently being ingested.
     * 
     * @param name the name of the file.
     */
    public void setName(String name) {
        this.name = name;
    }

    /**
     * Get the total number of files to ingest.
     * 
     * @return the total number of files to ingest.
     */
    public int getTotalFileCount() {
        return totalFileCount;
    }

    /**
     * Sets the total number of files that will be ingested.
     * 
     * @param fileCount the total number of files to ingest.
     */
    public void setTotalFileCount(int fileCount) {
        totalFileCount = fileCount;
    }

    /**
     * Gets the index of the file currently being ingested.
     * 
     * @return the index of the file being ingested.
     */
    public int getFileCount() {
        return fileCount;
    }

    /**
     * Sets the index of the file currently being ingested.
     * 
     * @param fileNumber the index of the file being ingested.
     */
    public void setFileCount(int fileNumber) {
        fileCount = fileNumber;
    }

    /**
     * Returns the number of rows read so far.
     * 
     * @return a number of rows
     */
    public int getRowCount() {
        return rowCount;
    }

    /**
     * Adds one to the row count.
     */
    public void incrementRowCount() {
        rowCount++;
    }

    /**
     * Returns the number of characters read so far.
     * 
     * @return a number of characters
     */
    public long getCharCount() {
        return charCount;
    }

    /**
     * Adds the given number of characters to the character count.
     * 
     * @param i the increment
     */
    public void incrementCharCount(int i) {
        charCount += i;
    }

    /**
     * Returns the total number of characters to read.
     * 
     * @return a number of characters
     */
    public long getTotalCharCount() {
        return totalCharCount;
    }

    /**
     * Sets the total number of characters in all data files.
     * 
     * @param totalCharCount a number of characters
     */
    public void setTotalCharCount(long totalCharCount) {
        this.totalCharCount = totalCharCount;
    }
}
