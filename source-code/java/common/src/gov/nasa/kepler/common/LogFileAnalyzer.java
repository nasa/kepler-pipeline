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

import gov.nasa.spiffy.common.lang.DefaultSystemProvider;
import gov.nasa.spiffy.common.lang.SystemProvider;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.SortedSet;
import java.util.TreeSet;

/**
 * Find the log file statements which took the most time.
 * 
 * @author Sean McCauliff
 *
 */
public class LogFileAnalyzer {

    //2008-12-29 17:59:17,245
    private static final String LOG_FILE_DATE_FORMAT = 
        "yyyy-MM-dd HH:mm:ss,SS";
    private static final String SEP;
    
    static {
        StringBuilder bldr = new StringBuilder();
        for (int i=0; i < 80; i++) {
            bldr.append('-');
        }
        SEP = bldr.toString();
    }
    
    private final SystemProvider system;
    
    private File logFile;
    
    private void printUsage() {
        system.out().println("java -cp ... " + getClass() + " <logfile>");
    }
    
    private void parse(String[] argv) {
        if (argv.length != 1) {
            printUsage();
            system.exit(-1);
            throw new IllegalArgumentException("Too few arguments.");
        }
        
        logFile = new File(argv[0]);
        if (!logFile.canRead()) {
            String msg = "Can't read file \"" + logFile + "\".";
            system.err().println(msg);
            system.exit(-2);
            throw new IllegalStateException(msg);
        }
        
    }
    
    private void exec() throws IOException, ParseException {
        SimpleDateFormat logFileDateFormat = 
            new SimpleDateFormat(LOG_FILE_DATE_FORMAT);
        
        SortedSet<Duration> resultSet = new TreeSet<Duration>();
        BufferedReader breader = new BufferedReader(new FileReader(logFile), 1024*128);
        Date prevDate = null;
        String prevLine = null;
        for (String line = breader.readLine();
            line != null;
            line = breader.readLine()) {
            
            Date nextDate = null;
            try {
                nextDate = logFileDateFormat.parse(line);
            } catch (ParseException ingored) {
                continue;
            }
            
            if (prevDate == null) {
                prevDate = nextDate;
                prevLine = line;
                continue;
            }
                

            
            long durationInMilliSeconds = nextDate.getTime() - prevDate.getTime();
            Duration duration = new Duration(prevLine, line, durationInMilliSeconds);
            resultSet.add(duration);
            if (resultSet.size() > 10) {
                resultSet.remove(resultSet.last());
            }
            
            prevDate = nextDate;
            prevLine = line;
        }
        breader.close();
        
        system.out().println("Top 10 items.");
        printSep();
        for (Duration d : resultSet) {
            double doubleDuration = (double) d.durationInMilliSeconds / 1000.0;
            system.out().println(doubleDuration + "s");
            system.out().println(d.prevLine);
            system.out().println(d.nextLine);
            printSep();
        }
    }
    
    private void printSep() {
        system.out().println(SEP);
    }
    
    public LogFileAnalyzer(SystemProvider system) {
        this.system = system;
    }
    
    /**
     * @param argv
     */
    public static void main(String[] argv) throws Exception {
        LogFileAnalyzer logFileAnalyzer = new LogFileAnalyzer(new DefaultSystemProvider());
        
        logFileAnalyzer.parse(argv);
        logFileAnalyzer.exec();
    }
    
    private static final class Duration implements Comparable<Duration> {
        public final String prevLine;
        public final String nextLine;
        public final long durationInMilliSeconds;
        /**
         * @param prevLine
         * @param nextLine
         * @param durationInSeconds
         */
        public Duration(String prevLine, String nextLine, long durationInMilliSeconds) {
            super();
            this.prevLine = prevLine;
            this.nextLine = nextLine;
            this.durationInMilliSeconds = durationInMilliSeconds;
        }
        @Override
        public int compareTo(Duration o) {
            long diff = o.durationInMilliSeconds - this.durationInMilliSeconds;
            if (diff < 0) {
                return -1;
            } else if (diff > 0) {
                return 1;
            } else {
                return 0;
            }
        }
        @Override
        public int hashCode() {
            final int prime = 31;
            int result = 1;
            result = prime
                * result
                + (int) (durationInMilliSeconds ^ (durationInMilliSeconds >>> 32));
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
            final Duration other = (Duration) obj;
            if (durationInMilliSeconds != other.durationInMilliSeconds)
                return false;
            return true;
        }
        
        
    }

}
