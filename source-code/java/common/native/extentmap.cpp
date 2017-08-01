/**
 *  This is a Linux specifc ioctl to find where the extents are placed in a file.  This
 *  Allows for efficient reading of whole sparse files.  The fiemap ioctl must be run
 *  as the root user.
 *
 *  @author Sean McCauliff
 *  
 *  Copyright 2017 United States Government as represented by the
 *  Administrator of the National Aeronautics and Space Administration.
 *  All Rights Reserved.
 *  
 *  This file is available under the terms of the NASA Open Source Agreement
 *  (NOSA). You should have received a copy of this agreement with the
 *  Kepler source code; see the file NASA-OPEN-SOURCE-AGREEMENT.doc.
 *  
 *  No Warranty: THE SUBJECT SOFTWARE IS PROVIDED "AS IS" WITHOUT ANY
 *  WARRANTY OF ANY KIND, EITHER EXPRESSED, IMPLIED, OR STATUTORY,
 *  INCLUDING, BUT NOT LIMITED TO, ANY WARRANTY THAT THE SUBJECT SOFTWARE
 *  WILL CONFORM TO SPECIFICATIONS, ANY IMPLIED WARRANTIES OF
 *  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR FREEDOM FROM
 *  INFRINGEMENT, ANY WARRANTY THAT THE SUBJECT SOFTWARE WILL BE ERROR
 *  FREE, OR ANY WARRANTY THAT DOCUMENTATION, IF PROVIDED, WILL CONFORM
 *  TO THE SUBJECT SOFTWARE. THIS AGREEMENT DOES NOT, IN ANY MANNER,
 *  CONSTITUTE AN ENDORSEMENT BY GOVERNMENT AGENCY OR ANY PRIOR RECIPIENT
 *  OF ANY RESULTS, RESULTING DESIGNS, HARDWARE, SOFTWARE PRODUCTS OR ANY
 *  OTHER APPLICATIONS RESULTING FROM USE OF THE SUBJECT SOFTWARE.
 *  FURTHER, GOVERNMENT AGENCY DISCLAIMS ALL WARRANTIES AND LIABILITIES
 *  REGARDING THIRD-PARTY SOFTWARE, IF PRESENT IN THE ORIGINAL SOFTWARE,
 *  AND DISTRIBUTES IT "AS IS."
 *
 *  Waiver and Indemnity: RECIPIENT AGREES TO WAIVE ANY AND ALL CLAIMS
 *  AGAINST THE UNITED STATES GOVERNMENT, ITS CONTRACTORS AND
 *  SUBCONTRACTORS, AS WELL AS ANY PRIOR RECIPIENT. IF RECIPIENT'S USE OF
 *  THE SUBJECT SOFTWARE RESULTS IN ANY LIABILITIES, DEMANDS, DAMAGES,
 *  EXPENSES OR LOSSES ARISING FROM SUCH USE, INCLUDING ANY DAMAGES FROM
 *  PRODUCTS BASED ON, OR RESULTING FROM, RECIPIENT'S USE OF THE SUBJECT
 *  SOFTWARE, RECIPIENT SHALL INDEMNIFY AND HOLD HARMLESS THE UNITED
 *  STATES GOVERNMENT, ITS CONTRACTORS AND SUBCONTRACTORS, AS WELL AS ANY
 *  PRIOR RECIPIENT, TO THE EXTENT PERMITTED BY LAW. RECIPIENT'S SOLE
 *  REMEDY FOR ANY SUCH MATTER SHALL BE THE IMMEDIATE, UNILATERAL
 *  TERMINATION OF THIS AGREEMENT.
 */

//The following allows for the correct import of strerror_r
#define _XOPEN_SOURCE 600

#include <iostream>
#include <sstream>
#include <fstream>

extern "C" {
#include <stdlib.h>
#include <errno.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/ioctl.h>
#include <linux/fs.h>
#include <asm/types.h>
#include <linux/fiemap.h>
}

extern "C" {
#include <jni.h>
}

#include "common.hpp"

using namespace std;
using namespace kepler::common;
using namespace std::placeholders;

static volatile jclass simpleIntervalClass_g = 0;
static volatile jmethodID simpleIntervalConstructor_g = 0;

class FiemapDeallocator {
private:
  struct fiemap* fiemap;
  bool deallocateOk;

public:
  FiemapDeallocator(struct fiemap* fiemap_p) : fiemap(fiemap_p), deallocateOk(true) {
  }

  void noDeallocate() {
    deallocateOk = false;
  }

  ~FiemapDeallocator() {
    if (deallocateOk) {
      //Not using "new" here because fiemap needs to be allocated with malloc or realloc.
      free(fiemap);
    }
  }
};

static void initFiemap(struct fiemap* fiemap, __u32 nExtents) {
  if (fiemap == 0) {
    throw KeplerException("Bad fiemap pointer.");
  }

  memset(fiemap, 0, sizeof(struct fiemap));  

  //Start mapping the file from user space length 0.
  fiemap->fm_start = 0;
  //Start mapping to the last possible byte of user space.
  fiemap->fm_length = ~0ULL;
  //Sync any outstanding changes to the target file fiemap before getting the extent map.
  //This prevents reading bad fiemaps on ext4
  fiemap->fm_flags = FIEMAP_FLAG_SYNC;
  fiemap->fm_extent_count = nExtents;
  fiemap->fm_mapped_extents = 0;
  
  memset(fiemap->fm_extents, 0, sizeof(struct fiemap_extent) * nExtents);
}

#define INITIAL_N_EXTENTS (1024*10)
static struct fiemap *readFiemap(int fd) throw (KeplerException) {
  //Not using "new" here because later we will need to allocate fiemap with
  //realloc in order to account for the size of the extent structures.
  struct fiemap* extentMap = 
    reinterpret_cast<struct fiemap*>(malloc(sizeof(struct fiemap) + sizeof(struct fiemap_extent) * INITIAL_N_EXTENTS));
  if (extentMap == 0) {
    throw KeplerException("Failed to allocate fiemap struct.");
  }

  FiemapDeallocator fiemapDeallocator(extentMap);
  
  initFiemap(extentMap, INITIAL_N_EXTENTS);

  if (ioctl(fd, FS_IOC_FIEMAP, extentMap) < 0) {
    char errbuf[128];
    strerror_r(errno, errbuf, 127);
    throw KeplerException(errbuf);
  }

  __u32 nExtents = extentMap->fm_mapped_extents;
    fiemapDeallocator.noDeallocate();
  if (nExtents < INITIAL_N_EXTENTS) {
    return extentMap;
  }

  // Find out how many extents there are
  
  free(extentMap);
  extentMap = reinterpret_cast<struct fiemap*>(malloc(sizeof(struct fiemap)));
  if (extentMap == 0) {
    throw KeplerException("Failed to allocate fiemap struct.");
  }
  FiemapDeallocator nExtentFiemapDeallocator(extentMap);
  initFiemap(extentMap, 0);
  
  if (ioctl(fd, FS_IOC_FIEMAP, extentMap) < 0) {
    char errbuf[128];
    strerror_r(errno, errbuf, 127);
    throw KeplerException(errbuf);
  }
  nExtentFiemapDeallocator.noDeallocate();

  nExtents = extentMap->fm_mapped_extents;
  __u32 extents_size = sizeof(struct fiemap_extent) * nExtents;
    
  // Resize fiemap to allow us to read in all the extents.

  extentMap = reinterpret_cast<struct fiemap*>(realloc(extentMap,sizeof(struct fiemap) + extents_size));
  if (extentMap == 0) {
    throw KeplerException("Out of memory allocating fiemap.");
  }
  FiemapDeallocator reallocDeallocator(extentMap);
  initFiemap(extentMap, nExtents);
  
  if (ioctl(fd, FS_IOC_FIEMAP, extentMap) < 0) {
    char errbuf[128];
    strerror_r(errno, errbuf, 127);
    throw KeplerException(errbuf);   
  }
  reallocDeallocator.noDeallocate();
  return extentMap;
}


/**
 *  Creates global references to the SimpleInterval class and constructor.
 */
extern "C" 
JNIEXPORT void JNICALL Java_gov_nasa_kepler_common_file_SparseFileUtil_initExtentMapLib(JNIEnv *env) {

  __sync_synchronize();

  //So, jclasses are local references, but jmethods are persistent global
  //references which is why I don't do NewGlobRef for the constructor
  if (simpleIntervalClass_g == 0) {
    jclass simpleIntervalClass_local = 
      env->FindClass("gov/nasa/kepler/common/intervals/SimpleInterval");
    if (simpleIntervalClass_local == 0) {
      return;
    }
    simpleIntervalClass_g = 
      reinterpret_cast<jclass>(env->NewGlobalRef(simpleIntervalClass_local));
    if (simpleIntervalClass_g == 0) {
      //OK, exception already set in env.
      return;
    }
    env->DeleteLocalRef(simpleIntervalClass_local);
  }
  
  if (simpleIntervalConstructor_g == 0) {
    //constructor that is (long, long)
    simpleIntervalConstructor_g = 
      env->GetMethodID(simpleIntervalClass_g, "<init>", "(JJ)V");
    if (simpleIntervalConstructor_g == 0) {
      env->DeleteGlobalRef(simpleIntervalClass_g);
      simpleIntervalClass_g = 0;
      return;
    }
    
    __sync_synchronize(); //memory barrier in GCC 4.4+
  }

#ifdef DEBUG_EXTENTMAP
    ofstream debug("/tmp/extentmap.init.log");
    debug << "simpleIntervalClass_g = " << simpleIntervalClass_g << endl;
    debug.close();
#endif
}

extern "C"
JNIEXPORT void JNICALL Java_gov_nasa_kepler_common_file_SparseFileUtil_testJni
(JNIEnv* env, jobject javaThis, jstring s) {
  ofstream debug("/tmp/test-jni.txt");
  debug << env->GetStringUTFChars(s, 0) << endl;
  debug.close();
}

/**
 *  Returns a Java object array reference of type SimpleInterval[].  These are populated
 * with the start and end of the extents.
 */
extern "C" 
JNIEXPORT jobjectArray JNICALL Java_gov_nasa_kepler_common_file_SparseFileUtil_extentsForFile
(JNIEnv *env, jobject javaThis, jstring absolutePath_java) { 

#ifdef DEBUG_EXTENTMAP
  ofstream debugOut("/tmp/extentmap.jni.log");
  debugOut << "Started" << endl;
  debugOut << "simpleIntervalClass_g = " << simpleIntervalClass_g << endl;
  debugOut.flush();
#endif

  //const char *absolutePath = env->GetStringUTFChars(absolutePath_java, 0);
  function<void(char const*)> deleteFunction = 
    bind(deleteNativeString, env, absolutePath_java, _1);
  jni_string_ptr absolutePath(
    env->GetStringUTFChars(absolutePath_java, 0),
    deleteFunction);
    
  if (absolutePath == 0) {
    //OOM
    return 0;
  }

#ifdef DEBUG_EXTENTMAP
  debugOut << "absolutePath: " << strlen(absolutePath) << " " << absolutePath << endl;
  debugOut.flush();
#endif

  unique_ptr<FileDescriptor> fd;
  try {
    fd.reset(new FileDescriptor(absolutePath.get(), O_RDONLY));
  } catch (const exception& ex) {
#ifdef DEBUG_EXTENTMAP
    debugOut <<  ex.what() << endl;
    debugOut.flush();
#endif
    jclass ioExceptionClass = env->FindClass("java/io/IOException");
    env->ThrowNew(ioExceptionClass, ex.what());
    return 0;
   }

#ifdef DEBUG_EXTENTMAP
  debugOut << "opened file" << endl;
  debugOut.flush();
#endif

  try {
    struct fiemap* extentMap = readFiemap(**fd);
#ifdef DEBUG_EXTENTMAP
    debugOut << "Found " << extentMap->fm_mapped_extents << " extents." << endl;
    debugOut.flush();
#endif

    FiemapDeallocator fiemapDeallocator(extentMap);
    
    jobjectArray rv = 
      env->NewObjectArray(extentMap->fm_mapped_extents, simpleIntervalClass_g, 0);
    if (rv == 0) {
      return 0;
    }
    for (int extenti=0; extenti < extentMap->fm_mapped_extents; extenti++) {
      __u64 extentStart = extentMap->fm_extents[extenti].fe_logical;
      __u64 extentEnd = extentMap->fm_extents[extenti].fe_length + extentStart -1;
       
      jobject extentInterval =
	env->NewObject(simpleIntervalClass_g, simpleIntervalConstructor_g, extentStart, extentEnd);
      if (extentInterval == 0) {
	//OK, exception already set in env.
	return 0;
      }
      env->SetObjectArrayElement(rv, extenti, extentInterval);
      env->DeleteLocalRef(extentInterval);
    }
    return rv;
  } catch (const KeplerException& ex) {
    jclass ioExceptionClass = env->FindClass("java/io/IOException");
    env->ThrowNew(ioExceptionClass, ex.what());
    cerr <<  ex.what() << endl;
    cerr.flush();
  }
  
  return 0;
}

#ifdef MAIN

static string extentToString(const struct fiemap_extent& extent) {
   ostringstream sout;
   sout << extent.fe_logical << " " << extent.fe_physical << " "
	<< extent.fe_length << " ";
   if (extent.fe_flags & FIEMAP_EXTENT_LAST) {
     sout << "LAST ";
   }
   if (extent.fe_flags & FIEMAP_EXTENT_UNKNOWN) {
     sout << "UNKNOWN ";
   }
   if (extent.fe_flags & FIEMAP_EXTENT_DELALLOC) {
     sout << "DELALLOC ";
   }
   if (extent.fe_flags & FIEMAP_EXTENT_ENCODED) {
     sout << "DATA_ENCODED ";
   }
   if (extent.fe_flags & FIEMAP_EXTENT_DATA_ENCRYPTED) {
     sout << "DATA_ENCRYPTED ";
   }
   if (extent.fe_flags & FIEMAP_EXTENT_NOT_ALIGNED) {
     sout << "NOT_ALIGNED ";
   }
   if (extent.fe_flags & FIEMAP_EXTENT_DATA_INLINE) {
     sout << "DATA_INLINE ";
   }
   if (extent.fe_flags * FIEMAP_EXTENT_DATA_TAIL) {
     sout << "DATA_TAIL ";
   }
   if (extent.fe_flags & FIEMAP_EXTENT_UNWRITTEN) {
     sout << "UNWRITTEN ";
   }
   if (extent.fe_flags & FIEMAP_EXTENT_MERGED) {
     sout << "MERGED ";
   }
   
   return sout.str();
}


int main(int argc, char** argv) {
   if (argc < 2) {
     cerr << "Must have at least one file argument." << endl;
     exit(-1);
   }

   for (int i=1; i < argc; i++) {
     int fd =  open(argv[i], O_RDONLY);
     if (fd < 0) {
       char errBuf[128];
       strerror_r(errno, errBuf, 127);
       cerr << "Failed to open file: \"" << argv[i] << "\"." << errBuf << endl;
       exit(-1);
     }
     
     try {
       struct fiemap* extentMap = readFiemap(fd);
       FiemapDeallocator fiemapDeallocator(extentMap);
       cout << "File \"" << argv[i] << "\" has " 
	    << extentMap->fm_mapped_extents << endl;
       for (int extenti=0; extenti < extentMap->fm_mapped_extents; extenti++) {
	 cout << "\t" << extentToString(extentMap->fm_extents[extenti]) << endl;
       }
     } catch (const KeplerException& fex) {
       cerr << fex.errStr << endl;
       close(fd);
       exit(-2);
     }
     close(fd);
   }
}
#endif
