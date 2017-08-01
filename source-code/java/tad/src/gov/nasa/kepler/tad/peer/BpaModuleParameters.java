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

package gov.nasa.kepler.tad.peer;

import gov.nasa.spiffy.common.persistable.Persistable;
import gov.nasa.spiffy.common.pi.Parameters;

/**
 * Used to pass data to and from MATLAB.
 * 
 * @author Miles Cote
 */
public class BpaModuleParameters implements Persistable, Parameters {

    private int nLinesRow = 31;
    private int nLinesCol = 36;
    private int nEdge = 6;
    private double edgeFraction = .1;
    private int lineStartRow;
    private int lineEndRow;
    private int lineStartCol;
    private int lineEndCol;
    private int histBinSize = 100;

    public BpaModuleParameters() {
    }

    public double getEdgeFraction() {
        return edgeFraction;
    }

    public void setEdgeFraction(double edgeFraction) {
        this.edgeFraction = edgeFraction;
    }

    public int getHistBinSize() {
        return histBinSize;
    }

    public void setHistBinSize(int histBinSize) {
        this.histBinSize = histBinSize;
    }

    public int getLineEndCol() {
        return lineEndCol;
    }

    public void setLineEndCol(int lineEndCol) {
        this.lineEndCol = lineEndCol;
    }

    public int getLineEndRow() {
        return lineEndRow;
    }

    public void setLineEndRow(int lineEndRow) {
        this.lineEndRow = lineEndRow;
    }

    public int getLineStartCol() {
        return lineStartCol;
    }

    public void setLineStartCol(int lineStartCol) {
        this.lineStartCol = lineStartCol;
    }

    public int getLineStartRow() {
        return lineStartRow;
    }

    public void setLineStartRow(int lineStartRow) {
        this.lineStartRow = lineStartRow;
    }

    public int getnEdge() {
        return nEdge;
    }

    public void setnEdge(int edge) {
        nEdge = edge;
    }

    public int getnLinesCol() {
        return nLinesCol;
    }

    public void setnLinesCol(int linesCol) {
        nLinesCol = linesCol;
    }

    public int getnLinesRow() {
        return nLinesRow;
    }

    public void setnLinesRow(int linesRow) {
        nLinesRow = linesRow;
    }

}
