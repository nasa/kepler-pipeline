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

package gov.nasa.kepler.fs.server.index.btree;

import gov.nasa.kepler.fs.server.index.*;
import gov.nasa.spiffy.common.collect.RemovableArrayList;

import java.io.DataInput;
import java.io.DataOutput;
import java.io.IOException;
import java.util.Collections;
import java.util.Comparator;

/**
 * B-tree node.  This class is not MT-safe.
 * 
 * @author Sean McCauliff
 * 
 * @param <K> key type
 * @param <V> value type
 */
public final class BtreeNode<K,V> implements TreeNode<K,V> {
	public final static int HEADER_SIZE = 4 * 2;
	final static long UNALLOCATED_ADDRESS = Long.MIN_VALUE;
    

	private final long address;
	
	final RemovableArrayList<K> keys; 
	final RemovableArrayList<V> values; 
	final RemovableArrayList<Long> childAddresses;
	private final NodeIO<K,V, BtreeNode<K,V>> io;
	
	public BtreeNode(long address, NodeIO<K,V,BtreeNode<K,V>> io) {
        keys = new RemovableArrayList<K>();
        values = new RemovableArrayList<V>();
        childAddresses = new RemovableArrayList<Long>();
		this.io = io;
		this.address = address;
	}

    /**
     * Copy constructor.
     * @param src
     */
	public BtreeNode(BtreeNode<K,V> src) {
	    keys = new RemovableArrayList<K>(src.keys);
	    values = new RemovableArrayList<V>(src.values);
	    childAddresses = new RemovableArrayList<Long>(src.childAddresses);
        this.address = src.address;
        this.io = src.io;
    }
    
	private BtreeNode(long address, 
            RemovableArrayList<K> keys, RemovableArrayList<V> v, 
            RemovableArrayList<Long> childAddresses, NodeIO<K,V,BtreeNode<K,V>> io) {
		this.keys = keys;
		this.values = v;
		this.childAddresses = childAddresses;
		this.io = io;
		this.address = address;
	}

    /**
     * Copies the contents of the other node into this node.
     * @param other
     */
    public void copyFrom(BtreeNode<K,V> other) {
        this.keys.clear();
        this.values.clear();
        this.childAddresses.clear();
        this.keys.addAll(other.keys);
        this.values.addAll(other.values);
        this.childAddresses.addAll(other.childAddresses);
    }
    
	/**
	 * Returns the number of keys.
	 * @return
	 */
	public int nKeys() {
		return keys.size();
	}
	
	@Override
	public boolean isLeaf() {
		return childAddresses.size() == 0;
	}
	
	@Override
	public int nChildren() {
	    return childAddresses.size();
	}
	
	/** The address of the disk block where this node lives.
	 */
	public long address() {
		return address;
	}
	
	public BtreeNode<K,V> child(int index) throws IOException {
		return io.readNode(childAddresses.get(index));
	}
		
	public void add(K key, V value, Comparator<K> c) {
		int index = Collections.binarySearch(keys, key, c);
		if (index < 0) {
			index = (-index) - 1;
			keys.add(index, key);
			values.add(index, value);
		} else {
			keys.set(index, key);
			values.set(index, value);
		}
		
	}
	
	
	public void addChild(int index, long childAddress) {
		childAddresses.add(index, childAddress);
	}
	public void write(DataOutput dout, KeyValueIO<K,V> kvio) throws IOException {
		dout.writeInt(keys.size());
		for (int i=0; i < keys.size();i++) {
			kvio.writeKey(dout, keys.get(i));
			kvio.writeValue(dout, values.get(i));
		}
		
		dout.writeInt(childAddresses.size());
		for (int i=0; i < childAddresses.size(); i++) {
			dout.writeLong(childAddresses.get(i));
		}
	}

    /**
     * Merges the other node into this node,
     * @param other  the other node must be greater than this node.  Other
     *   is deleted after merging.
     * @param additionalKey
     */
    public void merge(BtreeNode<K,V> other, K additionalKey, V additionalValue) throws IOException {
        if (this.childAddresses.size() > 0) {
            if (!(other.childAddresses.size() > 0)) {
                throw new IllegalArgumentException("Can't merge nodes that " +
                        "have children with nodes that do not have children."); 
            }
        } else {
            if (other.childAddresses.size() > 0) {
                throw new IllegalArgumentException("Can't merge nodes that do" +
                        " not have children with nodes that have children.");
            }
        }
        
        if (this.address == other.address) {
            throw new IllegalArgumentException("Can't merge node into it self.");
        }
        
        if (this.childAddresses.size() > 0) {
            this.childAddresses.addAll(other.childAddresses);
        }
        
        this.keys.add(additionalKey);
        this.keys.addAll(other.keys);
        
        this.values.add(additionalValue);
        this.values.addAll(other.values);
        
        io.deleteNode(other);
        io.writeNode(this);
        
    }
	
	/**
	 * This node is the ith child of parent.
	 */
	public BtreeNode<K,V> split(int t, BtreeNode<K,V> parent, int i) throws IOException {
		if ( t < 2) {
			throw new IllegalArgumentException("\"t\" must be" +
					" greater than or equal to 2.");
		}
		
		//These are the middle key value pairs to move into the parent
		V tthValue = values.get(t-1);
		K tthKey = keys.get(t-1);
		
		//Copy the right most values into the new node. 
		long newAddress = io.allocateAddress();
		BtreeNode<K,V> newNode = new BtreeNode<K,V>(newAddress, io);
		for (int j=0; j < (t-1); j++) {
			int thisNodeSource = j+t;
			newNode.keys.add(keys.get(thisNodeSource));
			newNode.values.add(values.get(thisNodeSource));
		}
			
		
		if (!isLeaf()) {	
			for (int j=0; j < t; j++) {
				newNode.childAddresses.add(childAddresses.get(j+t));
			}
		}
		
        keys.removeInterval(t-1, keys.size());
		values.removeInterval(t-1, values.size());
		if (!isLeaf()) {
		    childAddresses.removeInterval(t, childAddresses.size());
		}
		
		//Insert the middle key/value pair and a reference to the
		//newNode into the parent.  Parent should already have
		//been split.
		parent.childAddresses.add(i+1, newAddress);
		parent.keys.add(i, tthKey);
		parent.values.add(i, tthValue);
		
		io.writeNode(parent);
		io.writeNode(this);
		io.writeNode(newNode);
		return newNode;
	}
	
	

    @Override
    public int hashCode() {
        final int PRIME = 31;
        int result = 1;
        result = PRIME * result + (int) (address ^ (address >>> 32));
        result = PRIME * result + ((childAddresses == null) ? 0 : childAddresses.hashCode());
        result = PRIME * result + ((keys == null) ? 0 : keys.hashCode());
        result = PRIME * result + ((values == null) ? 0 : values.hashCode());
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
        @SuppressWarnings("unchecked")
        final BtreeNode<K,V> other = (BtreeNode<K,V>) obj;
        if (address != other.address)
            return false;
        if (childAddresses == null) {
            if (other.childAddresses != null)
                return false;
        } else if (!childAddresses.equals(other.childAddresses))
            return false;
        if (keys == null) {
            if (other.keys != null)
                return false;
        } else if (!keys.equals(other.keys))
            return false;
        if (values == null) {
            if (other.values != null)
                return false;
        } else if (!values.equals(other.values))
            return false;
        return true;
    }

    /**
     * This class is MT-safe because it is stateless.
     * @author Sean McCauliff
     *
     * @param <K> key 
     * @param <V> value
     */
    public static final class Factory<K,V> implements TreeNodeFactory<K,V, BtreeNode<K,V>> {
        
        @SuppressWarnings("rawtypes")
        private static final Factory INSTANCE = new Factory();
        
        private Factory() {
            
        }
        @Override
        public BtreeNode<K, V> read(long address, DataInput din,
            NodeIO<K, V, BtreeNode<K, V>> io) throws IOException {
            int nKeys = din.readInt();
            RemovableArrayList<K> keys = new RemovableArrayList<K>(nKeys);     
            RemovableArrayList<V> values  = new RemovableArrayList<V>(nKeys);
            
            for (int i=0; i < nKeys; i++) {
                keys.add(io.keyValueIO().readKey(din));
                values.add(io.keyValueIO().readValue(din));
            }
            
            int nChild = din.readInt();
            RemovableArrayList<Long> childAddresses = new RemovableArrayList<Long>();
            for (int i=0; i < nChild; i++) {
                childAddresses.add(din.readLong());
            }
            
            return new BtreeNode<K,V>(address, keys, values, childAddresses, io);
            
        }
        
        @SuppressWarnings("unchecked")
        public static <K,V> Factory<K,V>instance() {
            return INSTANCE;
        }
    }

}
