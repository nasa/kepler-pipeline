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

/*
import gov.nasa.kepler.common.ModuleFatalProcessingException;
import gov.nasa.kepler.common.PipelineException;
import gov.nasa.kepler.common.metrics.IntervalMetric;
import gov.nasa.kepler.common.metrics.IntervalMetricKey;
import gov.nasa.kepler.common.pi.Parameters;
import gov.nasa.kepler.common.pi.UnitOfWorkTask;
import gov.nasa.kepler.hibernate.pi.BeanWrapper;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineModule;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.mc.uow.CadenceUowTask;

import java.io.File;
*/
import java.text.FieldPosition;
import java.text.SimpleDateFormat;
import java.util.Date;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * VTC is represented as 5 bytes.  
 * Bytes 0-3 are the seconds.
 * Byte 4 is * fraction of seconds (where LSB is 4.096 msec).
 * Fractional part = fractional seconds / SECS_PER_VTC_FRACTIONAL_COUNT
 *
 * @author jgunter
 */
public class VtcFormat {
    private static final Log log = LogFactory.getLog(VtcFormat.class);

    public static final double SECS_PER_VTC_FRACTIONAL_COUNT = 4.096 / 1000.0;

	public static void main( String[] args ) {
		double vtc    = Double.valueOf( args[0] );
		double vtcInc = Double.valueOf( args[1] );
		long l1, l2;
		for ( int i = 0; true; i++ ) {
			String s1 = Integer.toBinaryString( getUpperBytes( vtc ) );
//			String s2 = Byte.toString( getLowerByte(  vtc ) );
			String s2 = DataSetPacker.getBits( getLowerByte(  vtc ), 128 );
			byte x = getLowerByte(  vtc );
//				System.out.println( "x= " + x );
			String a = s1 + s2;
			String b = Long.toBinaryString( toWholeAndFraction(  vtc ) );
			if ( ! a.equals( b ) ) { 
				System.out.println( "@@@@@@@@@@@@@@@@@@ i= " + i );
				System.out.println( "x= " + x );
				System.out.println( "A: " + a );
				System.out.println( "B: " + b );
			}
			if ( 0 == i % 1000 ) 
				System.out.println( "@@@@@@@@@@@@@@@@@@ i= " + i );
			vtc += vtcInc;
		}
	}
	
	public static byte[] intToBytes( int i ) {
	    byte[] b = new byte[4];
	    for ( int p = 0; p < 3; p++) {
	        b[p] = (byte) (i >>> 24);
	    	i = i << 8;
	        //System.out.println("b["+p+"]="+((byte)b[p])+", i="+i);
	    }
	    b[3] = (byte) (i >>> 24);
        //System.out.println("b["+3+"]="+((byte)b[3])+", i="+i);
	    return b;
	}
	
	public static int byteToInt( byte b ) {
	    int x = b;
        x = x << 24;
        x = x >>> 24;
        return x;
	}
	public static int bytesToInt( byte[] b ) {
	    int i = 0;
	    for ( int p = 0; p < 3; p++) {
	        i = i | byteToInt(b[p]);
	        i = i << 8;
	        //System.out.println("b["+p+"]="+b[p]+", i="+i);
	    }
        i = i | byteToInt(b[3]);
        //System.out.println("b["+3+"]="+b[3]+", i="+i);
        return i;
	}

    public static int getUpperBytes( double vtcSeconds ) {
		return (int) Math.floor( vtcSeconds );
    }

    public static byte getLowerByte( double vtcSeconds ) {
		short vtcFracPart = (short) ((vtcSeconds - getUpperBytes(vtcSeconds)) / SECS_PER_VTC_FRACTIONAL_COUNT);
		return (byte) vtcFracPart;
    }

    public static long toWholeAndFraction( double vtcSeconds ) {
		/* VTC is represented as 5 bytes.  Bytes 0-3 are the seconds and byte 4 is 
		 * fraction of seconds (where LSB is 4.096 msec).
		 * fractional part = fractional seconds / SECS_PER_VTC_FRACTIONAL_COUNT
		 */
/*
		long vtcWholePart = (long) vtcSeconds;
		short vtcFracPart = (short) ((vtcSeconds - Math.round(vtcSeconds)) / SECS_PER_VTC_FRACTIONAL_COUNT);
		long vtc = (vtcWholePart << 8) + vtcFracPart;
*/
		long vtcWholePart = (long)  getUpperBytes( vtcSeconds );
		short vtcFracPart = (short) getLowerByte(  vtcSeconds );
		byte b = getLowerByte(  vtcSeconds );
//		long vtc = (vtcWholePart << 8) + vtcFracPart;
		long vtc = b;
		vtc = vtc << 56;
		vtc = vtc >>> 56;
		long x = vtcWholePart << 8;
		vtc = vtc |  x;

		return vtc;
    }
    
    public static double bytesToDouble( byte b1, byte b2, byte b3, byte b4, byte b5 ) {
        /*
    	int seconds = b1;
    	seconds = seconds << 8;
    	seconds = seconds | b2;
    	seconds = seconds << 8;
    	seconds = seconds | b3;
    	seconds = seconds << 8;
    	seconds = seconds | b4;
    	
    	long frac = b5;
    	frac = frac << 56;
    	frac = frac >>> 56;
    	*/
        
    	int seconds = 0;
        byte[] bytes = new byte[] { b1, b2, b3, b4 };
        for ( int i = 0; i < bytes.length; i++ ) {
            int x = bytes[i];
            x = x << 24;
            x = x >>> 24;
            seconds = seconds << 8;
            seconds = seconds | x;
        }
    	long frac = b5;
    	frac = frac << 56;
    	frac = frac >>> 56;
    	
    	double whole = frac * SECS_PER_VTC_FRACTIONAL_COUNT + seconds;
    	//System.out.println("seconds="+seconds+", whole="+whole);
    	return whole;
    }

    public static Date toDate( double vtcSeconds ) {
/*
		// turn VTC into milliseconds since noon Jan 1, 2000
		long vtcSeconds   = (long) getUpperBytes( vtcSeconds );
		long vtcFracPart  = (long) getLowerByte(  vtcSeconds );
		vtcSeconds =    vtcSeconds >>> 8;
		long vtcFracPart = (long) vtc;
		vtcFracPart = vtcFracPart  << 56; 
		vtcFracPart = vtcFracPart >>> 56; 
		double vtcFracSecs = 4.096 * vtcFracPart;
		double vtcMillisecs = vtcFracSecs + ( vtcSeconds * 1000 );

		long millisecs_noon_Jan_1_2000 = 946756800000L;
							
		Date d = new Date( (long) ( vtcMillisecs + millisecs_noon_Jan_1_2000 ) );
		String ret = sdf.format( d, sb, new FieldPosition(0) ).toString();
		return ret;
*/
		long millisecs_noon_Jan_1_2000 = 946756800000L;
		long vtcMillisecs = 1000 * ( (long) vtcSeconds );
		Date d = new Date( vtcMillisecs + millisecs_noon_Jan_1_2000 );
		return d;
	}

//	private static SimpleDateFormat sdf = new SimpleDateFormat( "yyyy,DDD,HH:mm:ss" );
	private static SimpleDateFormat sdf = new SimpleDateFormat( "yyyyDDDHHmmss" );
//	private static SimpleDateFormat sdf = new SimpleDateFormat( "yyyy/MM/dd HH:mm:ss" );

    public static String toDateString( double vtcSeconds ) {
		String ret = sdf.format(	toDate( vtcSeconds ),
									new StringBuffer(),
									new FieldPosition(0) ).toString();
		return ret;
	}

}
