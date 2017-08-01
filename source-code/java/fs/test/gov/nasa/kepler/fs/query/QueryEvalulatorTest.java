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

package gov.nasa.kepler.fs.query;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

import junit.framework.AssertionFailedError;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.query.QueryEvaluator.DataType;

import org.antlr.runtime.RecognitionException;
import org.junit.Test;

/**
 * @author Sean McCauliff
 * 
 */
public class QueryEvalulatorTest {

    @Test
    public void globQuery() throws Exception {
        QueryEvaluator qEval = new QueryEvaluator("b@/a*/b");
        FsId id = new FsId("/ac/b");
        assertAll(qEval,id, true, true, true, DataType.Blob);
        
        FsId starMatchinesNothing = new FsId("/a/b");
        assertAll(qEval, starMatchinesNothing, true, true, true, DataType.Blob);
        
        
        qEval = new QueryEvaluator("b@/a/*");
        FsId matchAllNames = new FsId("/a/kljsdfjlskjdfk");
        assertAll(qEval, matchAllNames, true, true, true, DataType.Blob);
        
        FsId matchLongerPath = new FsId("/a/bde/112:343");
        assertAll(qEval, matchLongerPath, true, true,true, DataType.Blob);
        
        qEval = new QueryEvaluator("b@/a*de/\\d:\\d");
        FsId failedMatch = new FsId("/abce/123:7");
        assertAll(qEval, failedMatch, false, false, true, DataType.Blob);
        
        FsId calPixelPath = new FsId("/cal/pixels/_");
        qEval = new QueryEvaluator("t@/cal/pixels/*/[sct,lct]/\\d/\\d");
        assertAll(qEval, calPixelPath, false, false,true, DataType.TimeSeries);
        
        FsId fromCliTest = new FsId("/series-test/a/b");
        qEval = new QueryEvaluator("t@/series-test/a/*");
        assertAll(qEval, fromCliTest, true, true, true, DataType.TimeSeries);

        
    }
    
    @Test
    public void minimalIdQuery() throws Exception {
        QueryEvaluator qEval = new QueryEvaluator("blob@/a/b");
        FsId okId = new FsId("/a/b");
        assertAll(qEval,okId, true, true, true, DataType.Blob);

        FsId tooLong = new FsId("/a/b/c");
        assertFalse(qEval.match(tooLong));
        assertFalse(qEval.completeMatch());
        assertFalse(qEval.pathMatched());
        assertFalse(qEval.pathPrefixMatched());

        FsId prefixOkId = new FsId("/a/d");
        assertFalse(qEval.match(prefixOkId));
        assertFalse(qEval.completeMatch());
        assertTrue(qEval.pathMatched());
        assertTrue(qEval.pathPrefixMatched());

        FsId bad = new FsId("/b/c");
        assertFalse(qEval.match(bad));
        assertFalse(qEval.completeMatch());
        assertFalse(qEval.pathMatched());
        assertFalse(qEval.pathPrefixMatched());
    }

    @Test
    public void minimalPrefixMatch() throws Exception {
        QueryEvaluator qEval = new QueryEvaluator("timeseries@/abc/def/g");
        FsId prefixMatchId = new FsId("/abc/_");
        assertAll(qEval, prefixMatchId, false, false, true, DataType.TimeSeries);
    }

    @Test
    public void numbersWithoutConstraints() throws Exception {
        QueryEvaluator qEval = new QueryEvaluator("mjdtimeseries@/abc/123");
        FsId prefixMatchId = new FsId("/abc/123");
        assertAll(qEval, prefixMatchId, true, true, true, DataType.MjdTimeSeries);
    }

    @Test
    public void enumConstraints() throws Exception {
        QueryEvaluator qEval = new QueryEvaluator("t@/[cal,pa]/long/abc");
        FsId calId = new FsId("/cal/long/abc");
        assertAll(qEval, calId, true, true, true, DataType.TimeSeries);

        FsId paId = new FsId("/pa/long/abc");
        assertAll(qEval, paId, true, true, true, DataType.TimeSeries);

        FsId prefixId = new FsId("/pa/_");
        assertAll(qEval, prefixId, false, false, true, DataType.TimeSeries);

        qEval = new QueryEvaluator("m@/cal/[short,long]/[this,that]");
        FsId multiOk1 = new FsId("/cal/long/that");
        assertAll(qEval, multiOk1, true, true, true, DataType.MjdTimeSeries);

        FsId multiOk2 = new FsId("/cal/short/this");
        assertAll(qEval, multiOk2, true, true, true, DataType.MjdTimeSeries);

        FsId multiFail = new FsId("/cal/short/those");
        assertAll(qEval, multiFail, false, true, true, DataType.MjdTimeSeries);
        
        qEval = new QueryEvaluator("m@/[cal,calibration,cali]/blah");
        FsId chooseLongest = new FsId("/calibration/blah");
        assertAll(qEval, chooseLongest, true, true, true, DataType.MjdTimeSeries);
    }

    @Test
    public void integerConstraint() throws Exception {
        QueryEvaluator qEval = new QueryEvaluator("b@/cal/long/100:[100-1110]");
        FsId okId = new FsId("/cal/long/100:112");
        assertAll(qEval, okId, true, true, true, DataType.Blob);
    }

    @Test
    public void doubleConstraint() throws Exception {
        QueryEvaluator qEval = new QueryEvaluator(
            "t@/tps/cdpp/[3.0-4.0,7.0-16.0]");
        FsId okFsId = new FsId("/tps/cdpp/3.2");
        assertAll(qEval, okFsId, true, true, true, DataType.TimeSeries);
    }

    @Test
    public void specialClasses() throws Exception {
        QueryEvaluator qEval = new QueryEvaluator("t@/cal/\\c/[target,background]/100:[100-1100]");
        FsId okId = new FsId("/cal/ShortCadence/target/100:444");
        assertAll(qEval, okId, true, true, true, DataType.TimeSeries);
        
        qEval = new QueryEvaluator("t@/tps/cdpp/\\d:[3.0-4.0,7.0-16.0]");
        FsId anyDigitOk = new FsId("/tps/cdpp/10000000:3.5");
        assertAll(qEval, anyDigitOk, true, true, true, DataType.TimeSeries);
    }
    
    @Test
    public void evalulatorBenchmark() throws Exception {
        QueryEvaluator qEval = 
            new QueryEvaluator("t@/cal/\\c/[target,background]/*/\\d/\\d/100:[100-1100]");
        Pattern regex = Pattern.compile("/cal/(long|short|lc|sc|long_cadence|short_cadence)/(target|background])/.+/\\d+/\\d+/\\d+:\\d+");

        FsId matchId = new FsId("/cal/long/target/some-stuff/2/1/100:444");
        // apparently the server JIT compiles to native after 10k calls.
        final int NITER = 10000 * 100;
        double startTime = System.currentTimeMillis();
        for (int i = 0; i < NITER; i++) {
            assertAll(qEval, matchId, true, true, true, DataType.TimeSeries);
        }
        double endTime = System.currentTimeMillis();
        double timePerMatchInSeconds = (endTime - startTime) / NITER;
        long matchesPerSecond = (long) (1.0 / timePerMatchInSeconds * 1000.0);
        System.out.println("Matches per second " + matchesPerSecond);
        
        startTime = System.currentTimeMillis();
        for (int i=0; i <NITER; i++) {
        	Matcher m = regex.matcher(matchId.toString());
        	assertTrue(m.matches());
        }
        endTime = System.currentTimeMillis();
        timePerMatchInSeconds = (endTime - startTime) / NITER;
        matchesPerSecond = (long) (1.0 / timePerMatchInSeconds * 1000.0);
        System.out.println("Approximate regex comparision matches per second " + matchesPerSecond);

    }
    
    @Test(expected=RecognitionException.class)
    public void badQuery() throws Exception {
        new QueryEvaluator("/**$$$$%%^&*!");
        assertTrue(false);
    }
    
    private void assertAll(QueryEvaluator qEval, FsId id, boolean complete,
        boolean path, boolean prefix, DataType dataType) {
        boolean ok = false;
        try {
            if (complete != qEval.match(id)) {
                throw new AssertionFailedError("complete != match()");
            }
            if (complete !=  qEval.completeMatch()) {
                throw new AssertionFailedError("complete != completeMatch()");
            }
            if (path !=  qEval.pathMatched()) {
                throw new AssertionFailedError("path != pathMatched()");
            }
            if (prefix !=  qEval.pathPrefixMatched()) {
                throw new AssertionFailedError("prefix != pathPrefixMatched()");
            }
            assertEquals(dataType, qEval.dataType());
            ok = true;
        } finally {
            if (!ok) {
                System.out.println(qEval.toDot());
            }

        }
    }

}
