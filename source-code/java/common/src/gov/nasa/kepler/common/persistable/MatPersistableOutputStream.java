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

import static gov.nasa.spiffy.common.persistable.PersistableUtils.isArray;
import static gov.nasa.spiffy.common.persistable.PersistableUtils.isPrimitiveArray;

import gov.nasa.spiffy.common.persistable.PersistableOutputStream;
import gov.nasa.spiffy.common.persistable.PersistableUtils;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Date;
import java.util.Stack;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import com.jmatio.io.MatFileWriter;
import com.jmatio.types.MLArray;
import com.jmatio.types.MLCell;
import com.jmatio.types.MLChar;
import com.jmatio.types.MLDouble;
import com.jmatio.types.MLStructure;
import com.jmatio.types.MLUInt8;

/**
 * Implementation of {@link PersistableOutputStream} that writes to a MATLAB .mat
 * file using the JMatIO library
 * 
 * @author tklaus
 *
 */
public class MatPersistableOutputStream extends PersistableOutputStream {
    static final Log log = LogFactory.getLog(MatPersistableOutputStream.class);
    private File file;
    private Stack<Container> stack = new Stack<Container>();
    
    private class Container{
        public MLStructure var;
        public String name; // for debugging only
        public boolean isArray = false;
        public int currentIndex = 0;
        public boolean isMultiDimensionalArray = false;
        public boolean isStringArray = false;
        public MLCell cell; // used only for String arrays
        public int cellLength = 0;
        
        public Container(String name, MLStructure var, boolean isArray) {
            this.name = name;
            this.var = var;
            this.isArray = isArray;
        }
        public String toString(){
            return "name="+name+",isArray="+isArray+",currentIndex="+currentIndex+",isMulti="+isMultiDimensionalArray
            +",isStringArray="+isStringArray+",cell="+cell+",cellLength="+cellLength;
        }
    }
    
    public MatPersistableOutputStream(File file) {
        super(false, false);
        this.file = file;
    }
    
    private void stackPush(Container c){
        if(log.isDebugEnabled()){
            log.debug("stackPush(" + c + ")");
        }
        stack.push(c);
    }

    private Container stackPop(){
        Container c = stack.pop();
        if(log.isDebugEnabled()){
            log.debug("stackPop(" + c + ")");
        }
        return c;
    }

    @Override
    public void save(Object rootObject) throws Exception {

        // root struct.  all vars in the .mat file will be in this struct
        MLStructure var = new MLStructure("s", new int[]{1,1});
        Container c = new Container("s", var, false);
        stackPush(c);

        log.info("Processing object tree...");
        
        super.save(rootObject);

        if(stack.size() != 1){
            throw new IllegalStateException("Expected stack size to be 1, but it's actually: " + stack.size());
        }
        
        log.info("Writing .mat file...");
        ArrayList<MLArray> root = new ArrayList<MLArray>();
        root.add(stackPop().var);
        new MatFileWriter(file, root);
    }

    @Override
    protected void beginClass(String fieldName, Class<?> clazz) throws IOException {
        if(log.isDebugEnabled()){
            log.debug("beginPersistable(" + fieldName + ")");
        }
        
        if(fieldName != null){ // ignore root object
            Container parent = stack.peek();
            
            // the MLStructure for arrays is created in beginNonPrimitiveArray,
            // so we only create one here for non-arrays
            if(parent != null && (!parent.isArray || (!parent.name.equals(fieldName)))){ 

                MLStructure var = new MLStructure(null, new int[]{1,1});
                Container c = new Container(fieldName, var, false);
                stackPush(c);
                
                if(parent.isArray){
                    log.debug("setting " + parent.name + "." + fieldName + "["+parent.currentIndex+"] (struct)");
                    parent.var.setField(fieldName, var, parent.currentIndex++);
                }else{
                    log.debug("setting " + parent.name + "." + fieldName + " (struct)");
                    parent.var.setField(fieldName, var);
                }
            }
        }
    }

    @Override
    protected void endClass(String fieldName) throws IOException {
        if(log.isDebugEnabled()){
            log.debug("endPersistable(" + fieldName + ")");
        }

        if(fieldName != null){ // ignore root object

            Container c = stack.peek();
            
            if(!c.name.equals(fieldName)){
                throw new IllegalStateException("field name mismatch, expected: " + fieldName + ", but was: " + c.name);
            }
            
            if(!c.isArray){
                stackPop();
            }
        }
    }

    @Override
    protected void beginNonPrimitiveArray(String fieldName, Class<?> componentClass, int length) throws IOException {
        if(log.isDebugEnabled()){
            log.debug("beginNonPrimitiveArray(" + fieldName + ", " + componentClass + ", " + length + ")");
            log.debug("clazz.isArray(): " + componentClass.isArray());
        }
        
        Container parent = stack.peek();
        Container c = new Container(fieldName, null, true);
        Class<?> cc = innermostComponentClass(componentClass);
        
        if(cc == String.class){
            c.isStringArray = true;
            c.cell = new MLCell(null, new int[]{1,length});
            c.cellLength = length;

            if(parent.cell != null){
                // parent is also a cell array
                parent.cell.set(c.cell, parent.currentIndex++);
            }else{
                // parent is a struct
                parent.var.setField(fieldName, c.cell);
                log.debug("setting " + parent.name + "." + fieldName + " (cell)");
            }
        }else{
            MLStructure var = new MLStructure(null, new int[]{1, length});
            c.var = var;
            parent.var.setField(fieldName, var);
            log.debug("setting " + parent.name + "." + fieldName + " (struct array["+length+"])");
        }
        
        if(length > 0 && PersistableUtils.isArray(componentClass)){
            c.isMultiDimensionalArray = true;
        }

        stackPush(c);
    }

    @Override
    protected void endNonPrimitiveArray(String fieldName) throws IOException {
        if(log.isDebugEnabled()){
            log.debug("endNonPrimitiveArray(" + fieldName + ")");
        }

        Container c = stackPop();
        
        if(!c.name.equals(fieldName)){
            throw new IllegalStateException("field name mismatch, expected: " + fieldName + ", but was: " + c.name);
        }        
    }

    private Class<?> innermostComponentClass(Class<?> arrayClass){
        Class<?> currentClass = arrayClass.getComponentType();
        
        if(currentClass == null){
            return arrayClass;
        }
        
        if(log.isDebugEnabled()){
            log.debug("currentClass: " + currentClass);
        }
        
        while(PersistableUtils.isArray(currentClass)){
            currentClass = arrayClass.getComponentType();
        }
        
        return currentClass;
    }
    
    @Override
    protected void writeString(String fieldName, String v) throws IOException {
        if(log.isDebugEnabled()){
            log.debug("writeString(" + fieldName + ", " + v + ")");
        }

        Container c = stack.peek();
        
        if(c.isStringArray){
            c.cell.set(new MLChar(null, v), c.currentIndex++);
        }else{
            if(c.isArray){
                c.var.setField(fieldName, new MLChar(null, v), c.currentIndex++);
            }else{
                c.var.setField(fieldName, new MLChar(null, v));
            }
        }
    }

    @Override
    protected void saveEmpty(String fieldName) throws IOException {
        if(log.isDebugEnabled()){
            log.debug("saveEmpty(" + fieldName + ")");
        }

        Container c = stack.peek();
        
        if(c.cell != null){
            c.cell.set(new MLDouble(null, new int[] {0,0}), c.currentIndex++);
        }else{
            if(c.isArray){
                c.var.setField(fieldName, new MLDouble(null, new int[] {0,0}), c.currentIndex++);
            }else{
                c.var.setField(fieldName, new MLDouble(null, new int[] {0,0}));
            }
        }
    }

    @Override
    protected void saveEmptyPrimitive(Class<?> clazz, String fieldName, String containingClassName) throws IOException {
        saveEmpty(fieldName);
    }

    @Override
    protected void writeBoolean(String fieldName, boolean v) throws IOException {
        if(log.isDebugEnabled()){
            log.debug("writeBoolean(" + fieldName + ", " + v + ")");
        }

        Container c = stack.peek();
        if(c.isArray){
            c.var.setField(fieldName, new MLDouble(null, new double[]{v?1:0}, 1), c.currentIndex++);
        }else{
            c.var.setField(fieldName, new MLDouble(null, new double[]{v?1:0}, 1));
        }
    }

    @Override
    protected void writeByte(String fieldName, byte v) throws IOException {
        if(log.isDebugEnabled()){
            log.debug("writeByte(" + fieldName + ", " + v + ")");
        }

        Container c = stack.peek();
        if(c.isArray){
            c.var.setField(fieldName, new MLDouble(null, new double[]{v}, 1), c.currentIndex++);
        }else{
            c.var.setField(fieldName, new MLDouble(null, new double[]{v}, 1));
        }
    }

    @Override
    protected void writeChar(String fieldName, char v) throws IOException {
        if(log.isDebugEnabled()){
            log.debug("writeChar(" + fieldName + ", " + v + ")");
        }

        Container c = stack.peek();
        if(c.isArray){
            c.var.setField(fieldName, new MLChar(null, new String(new char[]{v})), c.currentIndex++);
        }else{
            c.var.setField(fieldName, new MLChar(null, new String(new char[]{v})));
        }
    }

    @Override
    protected void writeDouble(String fieldName, double v) throws IOException {
        if(log.isDebugEnabled()){
            log.debug("writeDouble(" + fieldName + ", " + v + ")");
        }

        Container c = stack.peek();
        if(c.isArray){
            c.var.setField(fieldName, new MLDouble(null, new double[]{v}, 1), c.currentIndex++);
        }else{
            c.var.setField(fieldName, new MLDouble(null, new double[]{v}, 1));
        }
    }

    @Override
    protected void writeFloat(String fieldName, float v) throws IOException {
        if(log.isDebugEnabled()){
            log.debug("writeFloat(" + fieldName + ", " + v + ")");
        }
        
        Container c = stack.peek();
        if(c.isArray){
            c.var.setField(fieldName, new MLDouble(null, new double[]{v}, 1), c.currentIndex++);
        }else{
            c.var.setField(fieldName, new MLDouble(null, new double[]{v}, 1));
        }
    }

    @Override
    protected void writeInt(String fieldName, int v) throws IOException {
        if(log.isDebugEnabled()){
            log.debug("writeInt(" + fieldName + ", " + v + ")");
        }

        Container c = stack.peek();
        if(c.isArray){
            c.var.setField(fieldName, new MLDouble(null, new double[]{v}, 1), c.currentIndex++);
        }else{
            c.var.setField(fieldName, new MLDouble(null, new double[]{v}, 1));
        }
    }

    @Override
    protected void writeLong(String fieldName, long v) throws IOException {
        if(log.isDebugEnabled()){
            log.debug("writeLong(" + fieldName + ", " + v + ")");
        }

        Container c = stack.peek();
        if(c.isArray){
            c.var.setField(fieldName, new MLDouble(null, new double[]{v}, 1), c.currentIndex++);
        }else{
            c.var.setField(fieldName, new MLDouble(null, new double[]{v}, 1));
        }
    }

    @Override
    protected void writeShort(String fieldName, short v) throws IOException {
        if(log.isDebugEnabled()){
            log.debug("writeShort(" + fieldName + ", " + v + ")");
        }

        Container c = stack.peek();
        if(c.isArray){
            c.var.setField(fieldName, new MLDouble(null, new double[]{v}, 1), c.currentIndex++);
        }else{
            c.var.setField(fieldName, new MLDouble(null, new double[]{v}, 1));
        }
    }

    @Override
    protected void writeCharArray(String fieldName, char[] v) throws IOException {
        if(log.isDebugEnabled()){
            log.debug("writeCharArray(" + fieldName + "[" + v.length + "]");
        }

        Container c = stack.peek();
        
        if(v.length > 0){
            String name = c.isMultiDimensionalArray?"array":fieldName;
            if(c.isArray){
                c.var.setField(name, new MLChar(null, new String(v)), c.currentIndex++);
            }else{
                c.var.setField(name, new MLChar(null, new String(v)));
            }
        }else{
            c.var.setField(fieldName, new MLDouble(null, new int[] {0,0}));
        }        
    }

    @Override
    protected void writeBooleanArray(String fieldName, boolean[] v) throws IOException {
        if(log.isDebugEnabled()){
            log.debug("writeBooleanArray(" + fieldName + "[" + v.length + "]");
        }

        Container c = stack.peek();
        
        if(v.length > 0){
            double[] d = new double[v.length];
            for (int i = 0; i < v.length; i++) {
                d[i] = v[i]?1:0;
            }
            int numRows = (v.length > 0?v.length:1);
            String name = c.isMultiDimensionalArray?"array":fieldName;
            if(c.isArray){
                c.var.setField(name, new MLDouble(null, d, numRows), c.currentIndex++);
            }else{
                c.var.setField(name, new MLDouble(null, d, numRows));
            }
        }else{
            c.var.setField(fieldName, new MLDouble(null, new int[] {0,0}));
        }        
    }

    @Override
    protected void writeDoubleArray(String fieldName, double[] v) throws IOException {
        if(log.isDebugEnabled()){
            log.debug("writeDoubleArray(" + fieldName + "[" + v.length + "]");
        }

        Container c = stack.peek();
        
        if(v.length > 0){
            int numRows = (v.length > 0?v.length:1);
            String name = c.isMultiDimensionalArray?"array":fieldName;
            if(c.isArray){
                c.var.setField(name, new MLDouble(null, v, numRows), c.currentIndex++);
            }else{
                c.var.setField(name, new MLDouble(null, v, numRows));
            }
        }else{
            c.var.setField(fieldName, new MLDouble(null, new int[] {0,0}));
        }        
    }

    @Override
    protected void writeFloatArray(String fieldName, float[] v) throws IOException {
        if(log.isDebugEnabled()){
            log.debug("writeFloatArray(" + fieldName + "[" + v.length + "]");
        }

        Container c = stack.peek();
        
        if(v.length > 0){
            double[] d = new double[v.length];
            for (int i = 0; i < v.length; i++) {
                d[i] = (double) v[i];
            }
            int numRows = (v.length > 0?v.length:1);
            String name = c.isMultiDimensionalArray?"array":fieldName;
            if(c.isArray){
                c.var.setField(name, new MLDouble(null, d, numRows), c.currentIndex++);
            }else{
                c.var.setField(name, new MLDouble(null, d, numRows));
            }
        }else{
            c.var.setField(fieldName, new MLDouble(null, new int[] {0,0}));
        }
    }

    @Override
    protected void writeByteArray(String fieldName, byte[] v) throws IOException {
        if(log.isDebugEnabled()){
            log.debug("writeByteArray(" + fieldName + "[" + v.length + "]");
        }

        Container c = stack.peek();
        
        if(v.length > 0){
            int numRows = (v.length > 0?v.length:1);
            String name = c.isMultiDimensionalArray?"array":fieldName;
            if(c.isArray){
                c.var.setField(name, new MLUInt8(null, v, numRows), c.currentIndex++);
            }else{
                c.var.setField(name, new MLUInt8(null, v, numRows));
            }
        }else{
            c.var.setField(fieldName, new MLUInt8(null, new int[] {0,0}));
        }        
    }

    @Override
    protected void writeShortArray(String fieldName, short[] v) throws IOException {
        if(log.isDebugEnabled()){
            log.debug("writeShortArray(" + fieldName + "[" + v.length + "]");
        }

        Container c = stack.peek();
        
        if(v.length > 0){
            double[] d = new double[v.length];
            for (int i = 0; i < v.length; i++) {
                // treat shorts as unsigned
                d[i] = (double) (v[i] & 0xFFFF);
            }
            int numRows = (v.length > 0?v.length:1);
            String name = c.isMultiDimensionalArray?"array":fieldName;
            if(c.isArray){
                c.var.setField(name, new MLDouble(null, d, numRows), c.currentIndex++);
            }else{
                c.var.setField(name, new MLDouble(null, d, numRows));
            }
        }else{
            c.var.setField(fieldName, new MLDouble(null, new int[] {0,0}));
        }        
    }
    
    @Override
    protected void writeIntArray(String fieldName, int[] v) throws IOException {
        if(log.isDebugEnabled()){
            log.debug("writeIntArray(" + fieldName + "[" + v.length + "]");
        }

        Container c = stack.peek();
        
        if(v.length > 0){
            double[] d = new double[v.length];
            for (int i = 0; i < v.length; i++) {
                d[i] = (double) v[i];
            }
            int numRows = (v.length > 0?v.length:1);
            String name = c.isMultiDimensionalArray?"array":fieldName;
            if(c.isArray){
                c.var.setField(name, new MLDouble(null, d, numRows), c.currentIndex++);
            }else{
                c.var.setField(name, new MLDouble(null, d, numRows));
            }
        }else{
            c.var.setField(fieldName, new MLDouble(null, new int[] {0,0}));
        }
    }

    @Override
    protected void writeLongArray(String fieldName, long[] v) throws IOException {
        if(log.isDebugEnabled()){
            log.debug("writeLongArray(" + fieldName + "[" + v.length + "]");
        }

        Container c = stack.peek();
        
        if(v.length > 0){
            double[] d = new double[v.length];
            for (int i = 0; i < v.length; i++) {
                d[i] = (double) v[i];
            }
            int numRows = (v.length > 0?v.length:1);
            String name = c.isMultiDimensionalArray?"array":fieldName;
            if(c.isArray){
                c.var.setField(name, new MLDouble(null, d, numRows), c.currentIndex++);
            }else{
                c.var.setField(name, new MLDouble(null, d, numRows));
            }
        }else{
            c.var.setField(fieldName, new MLDouble(null, new int[] {0,0}));
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
