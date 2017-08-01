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

//The following allows for the correct import of strerror_r


#include <stdio.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>

#include <jni.h>






#define BUF_SIZE 4096
#define BUF_LIMIT (BUF_SIZE - 1)

/**
 * Check if ether parameter is null for deallocation of a string.
 */
#define deallocateNotNull(cstr, jstr) {		\
  if ( (cstr) != 0) { \
      if ( (jstr) != 0) { \
	  env->ReleaseStringUTFChars( (jstr), (cstr)); \
      } \
  } \
  }

     
/**
 *  Deallocate the function parameters when this object goes out of scope.
 */
class Deallocate {
private:
  JNIEnv* env;

public:
  const char* srcAbsolutePath;
  jstring srcAbsolutePath_java;
  const char* destAbsolutePath;
  jstring destAbsolutePath_java;

  Deallocate(JNIEnv* env_p) : 
    srcAbsolutePath(0), srcAbsolutePath_java(0), destAbsolutePath(0), 
    destAbsolutePath_java(0) {
    env = env_p;
  }

  ~Deallocate() {
    deallocateNotNull(srcAbsolutePath, srcAbsolutePath_java);
    deallocateNotNull(destAbsolutePath, destAbsolutePath_java);
  }
};

/**
 * Hard link a file.
 */
extern "C" 
JNIEXPORT void JNICALL Java_gov_nasa_kepler_spiffy_io_FileUtil_nativeLink
(JNIEnv *env, jobject obj, jstring srcAbsolutePath_java, 
 jstring destAbsolutePath_java, jboolean symlinkFlag ) {

  Deallocate dealloc(env);

  //Get the native string from javaString
  const char *src = env->GetStringUTFChars(srcAbsolutePath_java, 0);
  if (src == 0) {
    //oom
    return;
  }

  dealloc.srcAbsolutePath = src;
  dealloc.srcAbsolutePath_java = srcAbsolutePath_java;

  const char* dest = env->GetStringUTFChars(destAbsolutePath_java, 0);
  if (dest == 0) {
    //oom
    return;
  }
  dealloc.destAbsolutePath = dest;
  dealloc.destAbsolutePath_java = destAbsolutePath_java;
  
  int ok = -1;
  if (symlinkFlag) {
    ok = symlink(src, dest);
  } else {
    ok = link(src, dest);
  }

  if (ok != 0) {
    int myError = errno;
    char errBuf[BUF_SIZE];
    strerror_r(myError,errBuf, BUF_LIMIT);
    int remainingBuf = BUF_LIMIT - strlen(errBuf);
    strncat(errBuf, src, remainingBuf);
    remainingBuf = BUF_LIMIT - strlen(errBuf);
    strncat(errBuf, " ", remainingBuf);
    remainingBuf = BUF_LIMIT - strlen(errBuf);
    strncat(errBuf, dest, remainingBuf);
    jclass ioExceptionClass = env->FindClass("java/io/IOException");
    if (ioExceptionClass == 0) {
      //oom
      return;
    }
    //Note the following line does not actually throw an exception.
    env->ThrowNew(ioExceptionClass, errBuf);
  }
  

}

/**
 * Commit system's buffer cache to disk.
 */
extern "C" 
JNIEXPORT void JNICALL Java_gov_nasa_spiffy_common_io_FileUtil_nativeSync
(JNIEnv *env, jobject obj) {

  sync();
}

