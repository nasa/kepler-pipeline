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

package gov.nasa.kepler.common.persistable;

import gov.nasa.spiffy.common.persistable.ClassWalker;
import gov.nasa.spiffy.common.persistable.PersistableOutputStream;
import gov.nasa.spiffy.common.persistable.WalkerListener;

import java.io.DataOutput;
import java.io.IOException;
import java.lang.reflect.Field;
import java.util.Date;
import java.util.Stack;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * This class implements the primitive writeX() methods of
 * PersistableOutputStream using the self-describing file format (.sdf).
 * This format is similar to the .bin format, except that it contains a
 * header with a data dictionary that describes the data structures so that
 * the file can be read without generated code.
 * 
 * See {@link SdfDataDictionary} for details on the format of the data dictionary
 * 
 * Endianness matches the platform where this code is run.
 * 
 * @author tklaus
 * 
 */
public class SdfPersistableOutputStream extends PersistableOutputStream implements WalkerListener{
    static final Log log = LogFactory.getLog(SdfPersistableOutputStream.class);

    private static int MAGIC_NUMBER = 42042;
    
    private DataOutput output = null;
    private boolean bigEndian = true;
    private Stack<SdfDataDictionaryClass> classStack = new Stack<SdfDataDictionaryClass>();
    private SdfDataDictionary dataDictionary = new SdfDataDictionary();
    
    public SdfPersistableOutputStream(DataOutput output) {
        super(false, true);  // enforcePersistable=false, ignoreStaticsDefault=true
        
        this.output = output;
        if (System.getProperty("sun.cpu.endian").equals("little")) {
            bigEndian = false;
        }
    }

    @Override
    public void save(Object rootObject) throws Exception {
        Class<? extends Object> rootClazz = rootObject.getClass();
        
        log.debug("writing .sdf file...");
        
        writeInt(null, MAGIC_NUMBER);
        
        generateDataDictionary(rootClazz);
                
        // type of top-level element
        writeInt(null, dataDictionary.typeForClass(rootClazz));

        super.save(rootObject);
        
        log.debug("...DONE writing .sdf file");
    }

    private void generateDataDictionary(Class<?> rootClazz) throws Exception{
        log.debug("Root class: " + rootClazz);
        // enforcePersistable=false, ignoreStaticsDefault=true
        ClassWalker walker = new ClassWalker(rootClazz, false, true);
        walker.addListener(this);
        walker.parse();
        
        dataDictionary.write(this);
    }
    
    @Override
    public void classStart(Class<?> clazz) throws Exception {
        log.debug("classStart(" + clazz);
        
        SdfDataDictionaryClass c = new SdfDataDictionaryClass(clazz);
        classStack.push(c);
    }

    @Override
    public void classEnd(Class<?> clazz) throws Exception {
        log.debug("classEnd(" + clazz);
        
        SdfDataDictionaryClass c = classStack.pop();
        dataDictionary.addClass(c);
    }

    @Override
    public void primitiveField(String name, String classSimpleName, Field field, boolean preservePrecision)
        throws Exception {
        log.debug("primitiveField(" + name + "," + classSimpleName);
        
        SdfDataDictionaryClass c = classStack.peek();
        int sdfType = dataDictionary.typeForClass(classSimpleName);
        SdfDataDictionaryField f = new SdfDataDictionaryField(name, sdfType);
        c.addField(f);
    }

    @Override
    public void primitiveArrayField(String name, String classSimpleName, int dimensions, Field field,
        boolean preservePrecision) throws Exception {
        log.debug("primitiveArrayField(" + name + "," + classSimpleName + "," + dimensions);
        
        SdfDataDictionaryClass c = classStack.peek();
        int sdfType = dataDictionary.typeForClass(classSimpleName);
        SdfDataDictionaryField f = new SdfDataDictionaryField(name, sdfType);
        f.setArrayDimensions(dimensions);
        c.addField(f);
    }

    @Override
    public void classField(Field field) throws Exception {
        String fieldName = field.getName();
        String className = field.getType().getSimpleName();
        log.debug("classField(" + fieldName + "," + className);
        
        SdfDataDictionaryClass c = classStack.peek();
        SdfDataDictionaryField f = new SdfDataDictionaryField(fieldName, field.getType());
        c.addField(f);
    }

    @Override
    public void classArrayField(Field field, Class<?> elementClass, int dimensions) throws Exception {
        String fieldName = field.getName();
        
        log.debug("classArrayField(" + fieldName + "," + elementClass.getSimpleName() + "," + dimensions);
        
        SdfDataDictionaryClass c = classStack.peek();
        SdfDataDictionaryField f = new SdfDataDictionaryField(fieldName, elementClass);
        f.setArrayDimensions(dimensions);
        c.addField(f);
    }

    @Override
    public void unknownType(Field field) throws Exception {        
        Class<?> fieldType = field.getType();
        throw new IllegalArgumentException("unknownType(" + field.getName() + "," + fieldType.getSimpleName() + "," + fieldType.getCanonicalName());
    }

    @Override
    protected void saveEmptyPrimitive(Class<?> clazz, String fieldName, String containingClassName) throws IOException {
        if(clazz == Boolean.class){
            writeByte(fieldName, SdfDataDictionary.EMPTY_BOOLEAN_VALUE);
        }else if(clazz == Byte.class){
            // no 'empty' representation for bytes
            writeByte(fieldName, (byte) -1);
        }else if(clazz == Short.class){
            // no 'empty' representation for shorts
            writeShort(fieldName, (short) -1);
        }else if(clazz == Integer.class){
            writeInt(fieldName, SdfDataDictionary.EMPTY_INT_VALUE);
        }else if(clazz == Long.class){
            writeLong(fieldName, SdfDataDictionary.EMPTY_LONG_VALUE);
        }else if(clazz == Float.class){
            writeFloat(fieldName, SdfDataDictionary.EMPTY_FLOAT_VALUE);
        }else if(clazz == Double.class){
            writeDouble(fieldName, SdfDataDictionary.EMPTY_DOUBLE_VALUE);
        }else if(clazz == Character.class){
            // no 'empty' representation for chars
            writeChar(fieldName, (char) -1);
        }else{
            throw new IOException("Unable to save null primitive object: " + containingClassName + "." + fieldName);
        }
    }

    protected void writeChar(String fieldName, char v) throws IOException {
        output.writeByte(v);
    }

    protected void writeByte(String fieldName, byte v) throws IOException {

        output.writeByte(v);
    }

    protected void writeShort(String fieldName, short v) throws IOException {

        if (!bigEndian) {
            v = Short.reverseBytes(v);
        }
        output.writeShort(v);
    }

    protected void writeInt(String fieldName, int v) throws IOException {

        if (!bigEndian) {
            v = Integer.reverseBytes(v);
        }
        output.writeInt(v);
    }

    protected void writeLong(String fieldName, long v) throws IOException {

        if (!bigEndian) {
            v = Long.reverseBytes(v);
        }
        output.writeLong(v);
    }

    protected void writeFloat(String fieldName, float v) throws IOException {
        int iv = Float.floatToIntBits(v);
        if (!bigEndian) {
            iv = Integer.reverseBytes(iv);
        }
        output.writeInt(iv);
    }

    protected void writeDouble(String fieldName, double v) throws IOException {

        long iv = Double.doubleToLongBits(v);
        if (!bigEndian) {
            iv = Long.reverseBytes(iv);
        }
        output.writeLong(iv);
    }

    protected void writeString(String fieldName, String v) throws IOException {

        if(v == null){
            saveEmpty(fieldName);
        }else{
            byte[] stringBytes = v.getBytes();
            writeInt(fieldName, stringBytes.length);
            output.write(stringBytes);
        }
    }

    protected void writeBoolean(String fieldName, boolean v) throws IOException {

        output.writeBoolean(v);
    }

    @Override
    protected void beginNonPrimitiveArray(String fieldName, Class<?> clazz, int length) throws IOException {
        writeInt(fieldName, length);
    }
    
    @Override
    protected void saveEmpty(String fieldName) throws IOException {
        writeInt(fieldName, 0);
    }

    @Override
    protected void endClass(String fieldName) throws IOException {
    }

    @Override
    protected void beginClass(String fieldName, Class<?> clazz) throws IOException {
        if(!dataDictionary.containsClass(clazz)){
            throw new IOException("encountered a class: " + clazz.getSimpleName() 
                + " that is not in the data dictionary. " +
                		"Note that polymorphism is not currently supported.");
        }
    }

    @Override
    protected void endNonPrimitiveArray(String fieldName) throws IOException {
    }

    @Override
    protected void writeBooleanArray(String fieldName, boolean[] data) throws IOException {
        final int length = data.length;
        writeInt(fieldName, length);
        for (int i=0; i < length; i++) {
            writeBoolean(fieldName, data[i]);
        }
    }

    @Override
    protected void writeByteArray(String fieldName, byte[] data) throws IOException {
        final int length = data.length;
        writeInt(fieldName, length);
        for (int i=0; i < length; i++) {
            writeByte(fieldName, data[i]);
        }        
    }

    @Override
    protected void writeCharArray(String fieldName, char[] data) throws IOException {
        final int length = data.length;
        writeInt(fieldName, length);
        for (int i=0; i < length; i++) {
            writeChar(fieldName, data[i]);
        }        
    }

    @Override
    protected void writeDoubleArray(String fieldName, double[] data) throws IOException {
        final int length = data.length;
        writeInt(fieldName, length);
        for (int i=0; i < length; i++) {
            writeDouble(fieldName, data[i]);
        }        
    }

    @Override
    protected void writeFloatArray(String fieldName, float[] data) throws IOException {
        final int length = data.length;
        writeInt(fieldName, length);
        for (int i=0; i < length; i++) {
            writeFloat(fieldName, data[i]);
        }
    }

    @Override
    protected void writeIntArray(String fieldName, int[] data) throws IOException {
        final int length = data.length;
        writeInt(fieldName, length);
        for (int i=0; i < length; i++) {
            writeInt(fieldName, data[i]);
        }        
    }

    @Override
    protected void writeLongArray(String fieldName, long[] data) throws IOException {
        final int length = data.length;
        writeInt(fieldName, length);
        for (int i=0; i < length; i++) {
            writeLong(fieldName, data[i]);
        }        
    }

    @Override
    protected void writeShortArray(String fieldName, short[] data) throws IOException {
        final int length = data.length;
        writeInt(fieldName, length);
        for (int i=0; i < length; i++) {
            writeShort(fieldName, data[i]);
        }        
    }
    
    @Override
    protected void writeDate(String fieldName, Date v) throws IOException {
        writeString(fieldName, v.toString());
    }

    @Override
    protected void writeEnum(String fieldName, Enum<?> v) throws IOException {
        writeString(fieldName, v.toString());
    }
    
}
