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

package gov.nasa.kepler.common;

import gov.nasa.spiffy.common.lang.StringUtils;

import java.util.Date;
import java.util.Stack;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Simple timer based on the tic and toc MATLAB functions.
 * 
 * @author tklaus
 *
 */
public class TicToc {
    static final Log log = LogFactory.getLog(TicToc.class);

    private static final class Block{
        public String label;
        public int debugLevel = 0;
        public Date startTime;
        
        public Block(String label, int debugLevel) {
            this.label = label;
            this.debugLevel = debugLevel;
            this.startTime = new Date();
        }
    }

    private static final class ThreadData{
        public Stack<Block> blocks = new Stack<Block>();
        public int level = 0;
        public int indentLevel = 0;
        public boolean incompleteLine = false;
    }
    
    private static final ThreadLocal<ThreadData> threadData = new ThreadLocal<ThreadData>(){
        @Override protected ThreadData initialValue() {
            return new ThreadData();
    }};

    
    private TicToc() {
    }

    public static void tic(String label){
        tic(label, 0);
    }
    
    public static void tic(String label, int debugLevel){
        ThreadData thisThreadData = threadData.get();
        
        if(shouldLog(debugLevel)){
            if(thisThreadData.incompleteLine){
              System.out.println();
            }
            System.out.print(indentString(thisThreadData.indentLevel) + label + "...");
            thisThreadData.incompleteLine = true;
        }

        thisThreadData.blocks.push(new Block(label, debugLevel));
        thisThreadData.indentLevel++;
    }
    
    public static void toc(){
        ThreadData thisThreadData = threadData.get();        
        Block b = thisThreadData.blocks.pop();
        Date endTime = new Date();
        String timeString = StringUtils.elapsedTime(b.startTime, endTime);
        boolean decrementIndent = (thisThreadData.indentLevel > 0);
        
        if(shouldLog(b.debugLevel)){
            if(thisThreadData.incompleteLine){
                System.out.println(timeString);
            }else{
                thisThreadData.indentLevel--;
                decrementIndent = false;
                System.out.println(indentString(thisThreadData.indentLevel) + "DONE " + b.label + ", total time: " + timeString);
            }
            thisThreadData.incompleteLine = false;
        }
        
        if(decrementIndent){
            thisThreadData.indentLevel--;
        }
    }

    private static boolean shouldLog(int debugLevel){
        ThreadData thisThreadData = threadData.get();        
        return(debugLevel <= thisThreadData.level);
    }
    
    private static String indentString(int indentLevel){
        StringBuilder s = new StringBuilder();
        for(int i = 0; i < indentLevel; i++){
            s.append(" ");
        }
        return s.toString();
    }

    public static int getLevel() {
        ThreadData thisThreadData = threadData.get();        
        return thisThreadData.level;
    }

    public static void setLevel(int debugLevel) {
        ThreadData thisThreadData = threadData.get();        
        thisThreadData.level = debugLevel;
    }
}
