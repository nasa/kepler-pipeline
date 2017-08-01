/*

-Disclaimer

   THIS SOFTWARE AND ANY RELATED MATERIALS WERE CREATED BY THE
   CALIFORNIA INSTITUTE OF TECHNOLOGY (CALTECH) UNDER A U.S.
   GOVERNMENT CONTRACT WITH THE NATIONAL AERONAUTICS AND SPACE
   ADMINISTRATION (NASA). THE SOFTWARE IS TECHNOLOGY AND SOFTWARE
   PUBLICLY AVAILABLE UNDER U.S. EXPORT LAWS AND IS PROVIDED "AS-IS"
   TO THE RECIPIENT WITHOUT WARRANTY OF ANY KIND, INCLUDING ANY
   WARRANTIES OF PERFORMANCE OR MERCHANTABILITY OR FITNESS FOR A
   PARTICULAR USE OR PURPOSE (AS SET FORTH IN UNITED STATES UCC
   SECTIONS 2312-2313) OR FOR ANY PURPOSE WHATSOEVER, FOR THE
   SOFTWARE AND RELATED MATERIALS, HOWEVER USED.

   IN NO EVENT SHALL CALTECH, ITS JET PROPULSION LABORATORY, OR NASA
   BE LIABLE FOR ANY DAMAGES AND/OR COSTS, INCLUDING, BUT NOT
   LIMITED TO, INCIDENTAL OR CONSEQUENTIAL DAMAGES OF ANY KIND,
   INCLUDING ECONOMIC DAMAGE OR INJURY TO PROPERTY AND LOST PROFITS,
   REGARDLESS OF WHETHER CALTECH, JPL, OR NASA BE ADVISED, HAVE
   REASON TO KNOW, OR, IN FACT, SHALL KNOW OF THE POSSIBILITY.

   RECIPIENT BEARS ALL RISK RELATING TO QUALITY AND PERFORMANCE OF
   THE SOFTWARE AND ANY RELATED MATERIALS, AND AGREES TO INDEMNIFY
   CALTECH AND NASA FOR ALL THIRD-PARTY CLAIMS RESULTING FROM THE
   ACTIONS OF RECIPIENT IN THE USE OF THE SOFTWARE.

*/

/*
   tutils_c.h  --- prototypes for CSPICE test utility code
   
       29-NOV-2004 (EDW)
   
       15-JUL-1999 (NJB)
*/

#include "SpiceUsr.h"
#include "SpiceZfc.h"


   /*
   Prototypes of test utility wrappers:
   */

   void chckad_c ( ConstSpiceChar    * name,
                   SpiceDouble       * array,
                   ConstSpiceChar    * comp,
                   SpiceDouble       * exp,
                   SpiceInt            size,
                   SpiceDouble         tol,
                   SpiceBoolean      * ok   );
                   
                    
   void chckai_c ( ConstSpiceChar    * name,
                   SpiceInt          * array,
                   ConstSpiceChar    * comp,
                   SpiceInt          * exp,
                   SpiceInt            size,
                   SpiceBoolean      * ok   );
                   
                   
   void chcksc_c ( ConstSpiceChar    * name,
                   ConstSpiceChar    * val,
                   ConstSpiceChar    * comp,
                   ConstSpiceChar    * exp,
                   SpiceBoolean      * ok    ); 

   
   void chcksd_c ( ConstSpiceChar   * name,
                   SpiceDouble        val,
                   ConstSpiceChar   * comp,
                   SpiceDouble        exp,
                   SpiceDouble        tol,
                   SpiceBoolean     * ok    );
                   
   void chcksi_c ( ConstSpiceChar    * name,
                   SpiceInt            val,
                   ConstSpiceChar    * comp,
                   SpiceInt            exp,
                   SpiceInt            tol,
                   SpiceBoolean      * ok   ); 


   void chcksl_c ( ConstSpiceChar    * name,
                   SpiceBoolean        val,
                   SpiceBoolean        exp,
                   SpiceBoolean      * ok   ); 


   void chckxc_c ( SpiceBoolean        except,
                   ConstSpiceChar    * shmsg,
                   SpiceBoolean      * ok     ); 


   SpiceDouble rand_c ( SpiceDouble     lb, 
                        SpiceDouble     ub  );
                     
                     
   SpiceInt    rani_c ( SpiceInt        lb, 
                        SpiceInt        ub  );
                     
                     
   void tcase_c  ( ConstSpiceChar    * title ); 


   void tclose_c ( void ); 


   void topen_c  ( ConstSpiceChar    * name ); 
   
   
   void tsetup_c ( ConstSpiceChar    * lognam,
                   ConstSpiceChar    * versn  ); 
   
   
   void tstatd_c ( SpiceDouble         et,
                   SpiceDouble         matrix[3][3],
                   SpiceDouble         angvel[3]    );
                   
                    
   void tstck3_c ( ConstSpiceChar    * cknm,
                   ConstSpiceChar    * sclknm,
                   SpiceBoolean        loadck,
                   SpiceBoolean        loadsc,
                   SpiceBoolean        keepsc,
                   SpiceInt          * handle  );
                   
                   
   void tstek_c ( ConstSpiceChar     * file,
                  SpiceInt             fileno,
                  SpiceInt             mxrows,
                  SpiceBoolean         load,
                  SpiceInt           * handle,
                  SpiceBoolean       * ok     );
                  

   void tstent_c ( SpiceInt           fileno,
                   ConstSpiceChar   * table,
                   SpiceInt           segno,
                   ConstSpiceChar   * column,
                   SpiceInt           rowno,
                   SpiceInt           nmax,
                   SpiceInt           vallen,
                   SpiceInt         * nelts,
                   void             * cvals,
                   SpiceDouble      * dvals,
                   SpiceInt         * ivals,
                   SpiceDouble      * tvals,
                   SpiceBoolean     * isnull  );
                   

   void tstlsk_c ( void );
   
    
   void tstmsg_c ( ConstSpiceChar    * marker,
                   ConstSpiceChar    * message );
  

   void tstmsi_c ( SpiceInt            ival );


   void tstmsd_c ( SpiceDouble         dval );


   void tstmsc_c ( ConstSpiceChar    * msg );


   void tstmsf_c ( SpiceDouble         dval );


   void tstmso_c ( SpiceInt            ival,
                   ConstSpiceChar    * marker );
                    
                    
   void tstmst_c ( SpiceInt            ival,
                   ConstSpiceChar    * marker );
                    
                    
   void tstpck_c ( ConstSpiceChar    * namepc,
                   SpiceBoolean        loadpc,
                   SpiceBoolean        keeppc ); 
                   
                   
   void tstsch_c ( ConstSpiceChar     * table,
                   SpiceInt             mxrows,
                   SpiceInt             namlen,
                   SpiceInt             declen,
                   SpiceInt           * segtyp,
                   SpiceInt           * nrows,
                   SpiceInt           * ncols,
                   void               * cnames,
                   SpiceInt           * cclass,
                   SpiceEKDataType    * dtypes,
                   SpiceInt           * stlens,
                   SpiceInt           * dims,
                   SpiceBoolean       * indexd,
                   SpiceBoolean       * nullok,
                   void               * decls   );
                   
                   
   void tstspk_c ( ConstSpiceChar    * file,
                   SpiceBoolean        load,
                   SpiceInt          * handle );
                   
                   
   void tsttxt_c ( ConstSpiceChar    * namtxt,
                   void              * txt,
                   SpiceInt            nlines,
                   SpiceInt            lenvals,
                   SpiceBoolean        load,
                   SpiceBoolean        keep     ); 

   void t_pck08_c (   ConstSpiceChar    * namepc,
                      SpiceBoolean        loadpc,
                      SpiceBoolean        keeppc ); 

   int t_success__  ( logical        * ok );
   
   void t_success_c ( SpiceBoolean   * ok );


   /*
   The following mess is the concatenation of the prototypes for each
   C routine generated by running f2c on the Fortran test utilities.
   */

extern H_f begdat_(char *ret_val, ftnlen ret_val_len);
extern H_f begtxt_(char *ret_val, ftnlen ret_val_len);
extern int chckad_(char *name__, doublereal *array, char *comp, 
                   doublereal *exp__, integer *size, doublereal *tol,
                   logical *ok, ftnlen name_len, ftnlen comp_len);
/*:ref: tststy_ 14 4 13 13 124 124 */
/*:ref: tstlgs_ 14 4 13 13 124 124 */
/*:ref: repmi_ 14 7 13 13 4 13 124 124 124 */
/*:ref: repmc_ 14 8 13 13 13 13 124 124 124 124 */
/*:ref: rtrim_ 4 2 13 124 */
/*:ref: repmd_ 14 8 13 13 7 4 13 124 124 124 */
/*:ref: tstlog_ 14 3 13 12 124 */
/*:ref: vsepg_ 7 3 7 7 4 */
/*:ref: vdistg_ 7 3 7 7 4 */
/*:ref: vnormg_ 7 2 7 4 */
/*:ref: halfpi_ 7 0 */
/*:ref: verbos_ 12 0 */
extern int chckai_(char *name__, integer *array, char *comp,
                   integer *exp__, integer *size, logical *ok,
                   ftnlen name_len, ftnlen comp_len);
/*:ref: tststy_ 14 4 13 13 124 124 */
/*:ref: tstlgs_ 14 4 13 13 124 124 */
/*:ref: repmi_ 14 7 13 13 4 13 124 124 124 */
/*:ref: repmc_ 14 8 13 13 13 13 124 124 124 124 */
/*:ref: rtrim_ 4 2 13 124 */
/*:ref: tstlog_ 14 3 13 12 124 */
/*:ref: verbos_ 12 0 */
extern int chckoc_(char *name__, char *array, char *order, integer *size, 
                   logical *ok, ftnlen name_len, ftnlen array_len, 
                   ftnlen order_len);
/*:ref: rtrim_ 4 2 13 124 */
/*:ref: tststy_ 14 4 13 13 124 124 */
/*:ref: tstlgs_ 14 4 13 13 124 124 */
/*:ref: repmc_ 14 8 13 13 13 13 124 124 124 124 */
/*:ref: repmi_ 14 7 13 13 4 13 124 124 124 */
/*:ref: tstlog_ 14 3 13 12 124 */
/*:ref: verbos_ 12 0 */
extern int chckod_(char *name__, doublereal *array, char *order, 
                   integer *size, logical *ok, ftnlen name_len, 
                   ftnlen order_len);
/*:ref: rtrim_ 4 2 13 124 */
/*:ref: tststy_ 14 4 13 13 124 124 */
/*:ref: tstlgs_ 14 4 13 13 124 124 */
/*:ref: repmc_ 14 8 13 13 13 13 124 124 124 124 */
/*:ref: repmi_ 14 7 13 13 4 13 124 124 124 */
/*:ref: repmd_ 14 8 13 13 7 4 13 124 124 124 */
/*:ref: tstlog_ 14 3 13 12 124 */
/*:ref: verbos_ 12 0 */
extern int chckoi_(char *name__, integer *array, char *order, integer *size, 
                   logical *ok, ftnlen name_len, ftnlen order_len);
/*:ref: tststy_ 14 4 13 13 124 124 */
/*:ref: tstlgs_ 14 4 13 13 124 124 */
/*:ref: rtrim_ 4 2 13 124 */
/*:ref: repmc_ 14 8 13 13 13 13 124 124 124 124 */
/*:ref: repmi_ 14 7 13 13 4 13 124 124 124 */
/*:ref: tstlog_ 14 3 13 12 124 */
/*:ref: verbos_ 12 0 */
extern int chcksc_(char *name__, char *val, char *comp, char *exp__, 
                   logical *ok, ftnlen name_len, ftnlen val_len, 
                   ftnlen comp_len, ftnlen exp_len);
/*:ref: tststy_ 14 4 13 13 124 124 */
/*:ref: tstlgs_ 14 4 13 13 124 124 */
/*:ref: ucase_ 14 4 13 13 124 124 */
/*:ref: repmc_ 14 8 13 13 13 13 124 124 124 124 */
/*:ref: rtrim_ 4 2 13 124 */
/*:ref: verbos_ 12 0 */
/*:ref: tstlog_ 14 3 13 12 124 */
extern int chcksd_(char *name__, doublereal *val, char *comp, 
                   doublereal *exp__, doublereal *tol, logical *ok, 
                   ftnlen name_len, ftnlen comp_len);
/*:ref: tststy_ 14 4 13 13 124 124 */
/*:ref: tstlgs_ 14 4 13 13 124 124 */
/*:ref: repmc_ 14 8 13 13 13 13 124 124 124 124 */
/*:ref: rtrim_ 4 2 13 124 */
/*:ref: repmd_ 14 8 13 13 7 4 13 124 124 124 */
/*:ref: verbos_ 12 0 */
/*:ref: tstlog_ 14 3 13 12 124 */
extern int chcksi_(char *name__, integer *val, char *comp, integer *exp__, 
                   integer *tol, logical *ok, ftnlen name_len, 
                   ftnlen comp_len);
/*:ref: tststy_ 14 4 13 13 124 124 */
/*:ref: tstlgs_ 14 4 13 13 124 124 */
/*:ref: repmc_ 14 8 13 13 13 13 124 124 124 124 */
/*:ref: rtrim_ 4 2 13 124 */
/*:ref: repmi_ 14 7 13 13 4 13 124 124 124 */
/*:ref: verbos_ 12 0 */
/*:ref: tstlog_ 14 3 13 12 124 */
extern int chcksl_(char *name__, logical *val, logical *exp__, 
                   logical *ok, ftnlen name_len);
/*:ref: tststy_ 14 4 13 13 124 124 */
/*:ref: tstlgs_ 14 4 13 13 124 124 */
/*:ref: repmc_ 14 8 13 13 13 13 124 124 124 124 */
/*:ref: rtrim_ 4 2 13 124 */
/*:ref: verbos_ 12 0 */
/*:ref: tstlog_ 14 3 13 12 124 */
extern int chckxc_(logical *except, char *short__, logical *ok, 
                   ftnlen short_len);
/*:ref: tststy_ 14 4 13 13 124 124 */
/*:ref: tstlgs_ 14 4 13 13 124 124 */
/*:ref: failed_ 12 0 */
/*:ref: getmsg_ 14 4 13 13 124 124 */
/*:ref: reset_ 14 0 */
/*:ref: repmc_ 14 8 13 13 13 13 124 124 124 124 */
/*:ref: rtrim_ 4 2 13 124 */
/*:ref: tstlog_ 14 3 13 12 124 */
/*:ref: verbos_ 12 0 */
extern int mprint_(doublereal *mat, integer *rows, integer *cols, char *fmt, 
                   ftnlen fmt_len);
/*:ref: nblen_ 4 2 13 124 */
/*:ref: dpfmt_ 14 5 7 13 13 124 124 */
/*:ref: rtrim_ 4 2 13 124 */
/*:ref: dpstrf_ 14 6 7 4 13 13 124 124 */
/*:ref: tostdo_ 14 2 13 124 */
extern int t_stat__(char *act, char *name__, logical *ok, integer *number,
                    ftnlen act_len, ftnlen name_len);
extern int t_begin__(char *name__, ftnlen name_len);
extern int t_name__(char *name__, ftnlen name_len);
extern int t_success__(logical *ok);
extern int t_fcount__(integer *number);
extern int t_case__(char *name__, ftnlen name_len);
extern int t_cfail__(void);
extern int t_cpass__(logical *ok);
extern int t_cnum__(integer *number);
extern int t_cname__(char *name__, ftnlen name_len);
extern int t_anybad__(logical *ok);
extern int t_trace__(char *act, char *name__, ftnlen act_len, ftnlen name_len);
/*:ref: reset_ 14 0 */
/*:ref: ljust_ 14 4 13 13 124 124 */
/*:ref: ucase_ 14 4 13 13 124 124 */
extern int tcase_(char *title, ftnlen title_len);
/*:ref: qcktrc_ 14 2 13 124 */
/*:ref: t_trace__ 14 4 13 13 124 124 */
/*:ref: chcksc_ 14 9 13 13 13 13 12 124 124 124 124 */
/*:ref: tstlip_ 14 0 */
/*:ref: t_case__ 14 2 13 124 */
/*:ref: tstrul_ 14 0 */
/*:ref: verbos_ 12 0 */
/*:ref: tststy_ 14 4 13 13 124 124 */
/*:ref: tstlgs_ 14 4 13 13 124 124 */
/*:ref: t_cname__ 14 2 13 124 */
/*:ref: tstlog_ 14 3 13 12 124 */
extern int tclose_(void);
/*:ref: tststy_ 14 4 13 13 124 124 */
/*:ref: tstlip_ 14 0 */
/*:ref: tstrul_ 14 0 */
/*:ref: tstcbl_ 14 0 */
/*:ref: t_name__ 14 2 13 124 */
/*:ref: t_fcount__ 14 1 4 */
/*:ref: t_cnum__ 14 1 4 */
/*:ref: t_success__ 14 1 12 */
/*:ref: suffix_ 14 5 13 4 13 124 124 */
/*:ref: tstlog_ 14 3 13 12 124 */
/*:ref: tstlgs_ 14 4 13 13 124 124 */
/*:ref: repmct_ 14 9 13 13 4 13 13 124 124 124 124 */
/*:ref: t_anybad__ 14 1 12 */
/*:ref: tstglf_ 14 2 13 124 */
/*:ref: tstfil_ 14 6 13 13 13 124 124 124 */
/*:ref: tstslf_ 14 2 13 124 */
/*:ref: tstget_ 14 6 13 13 13 124 124 124 */
/*:ref: tstioa_ 14 2 13 124 */
/*:ref: tstioh_ 14 2 13 124 */
/*:ref: tstwln_ 14 2 13 124 */
/*:ref: tbegf_ 14 0 */
/*:ref: tfname_ 14 2 13 124 */
/*:ref: prefix_ 14 5 13 4 13 124 124 */
/*:ref: tstioc_ 14 2 13 124 */
/*:ref: finish_ 14 0 */
extern int topen_(char *name__, ftnlen name_len);
extern int tbegf_(void);
extern int tfname_(char *name__, ftnlen name_len);
/*:ref: reset_ 14 0 */
/*:ref: qcktrc_ 14 2 13 124 */
/*:ref: t_trace__ 14 4 13 13 124 124 */
/*:ref: chcksc_ 14 9 13 13 13 13 12 124 124 124 124 */
/*:ref: tstlip_ 14 0 */
/*:ref: tstrul_ 14 0 */
/*:ref: tstcbl_ 14 0 */
/*:ref: t_name__ 14 2 13 124 */
/*:ref: t_fcount__ 14 1 4 */
/*:ref: t_cnum__ 14 1 4 */
/*:ref: t_success__ 14 1 12 */
/*:ref: tststy_ 14 4 13 13 124 124 */
/*:ref: suffix_ 14 5 13 4 13 124 124 */
/*:ref: tstlog_ 14 3 13 12 124 */
/*:ref: tstlgs_ 14 4 13 13 124 124 */
/*:ref: repmct_ 14 9 13 13 4 13 13 124 124 124 124 */
/*:ref: t_begin__ 14 2 13 124 */
/*:ref: rtrim_ 4 2 13 124 */
extern int tsetup_(char *lognam, char *versn, ftnlen lognam_len, 
                   ftnlen versn_len);
/*:ref: tstlgs_ 14 4 13 13 124 124 */
/*:ref: tstopl_ 14 4 13 13 124 124 */
/*:ref: erract_ 14 4 13 13 124 124 */
/*:ref: errdev_ 14 4 13 13 124 124 */
/*:ref: getcml_ 14 2 13 124 */
/*:ref: nextwd_ 14 6 13 13 13 124 124 124 */
/*:ref: ucase_ 14 4 13 13 124 124 */
/*:ref: verbon_ 12 0 */
/*:ref: tstlcy_ 14 0 */
extern int tstatd_(doublereal *et, doublereal *matrix, doublereal *angvel);
/*:ref: axisar_ 14 3 7 7 7 */
/*:ref: mxm_ 14 3 7 7 7 */
/*:ref: lstled_ 4 3 7 4 7 */
/*:ref: xpose_ 14 2 7 7 */
/*:ref: vhat_ 14 2 7 7 */
/*:ref: vscl_ 14 3 7 7 7 */
extern int tstck3_(char *cknm, char *sclknm, logical *loadck, logical *loadsc, 
                   logical *keepsc, integer *handle, ftnlen cknm_len, 
                   ftnlen sclknm_len);
/*:ref: kilfil_ 14 2 13 124 */
/*:ref: begdat_ 13 2 13 124 */
/*:ref: txtopn_ 14 3 13 4 124 */
/*:ref: rtrim_ 4 2 13 124 */
/*:ref: tparse_ 14 5 13 7 13 124 124 */
/*:ref: shelld_ 14 2 4 7 */
/*:ref: tstatd_ 14 3 7 7 7 */
/*:ref: m2q_ 14 2 7 7 */
/*:ref: spcopn_ 14 5 13 13 4 124 124 */
/*:ref: ckw03_ 14 15 4 7 7 4 13 12 13 4 7 7 7 4 7 124 124 */
/*:ref: dafcls_ 14 1 4 */
/*:ref: ldpool_ 14 2 13 124 */
/*:ref: cklpf_ 14 3 13 4 124 */
extern int tstfil_(char *pattrn, char *port, char *file, ftnlen pattrn_len, 
                   ftnlen port_len, ftnlen file_len);
/*:ref: chkin_ 14 2 13 124 */
/*:ref: fststr_ 14 4 13 13 124 124 */
/*:ref: exists_ 12 2 13 124 */
/*:ref: nxtstr_ 14 6 13 13 13 124 124 124 */
/*:ref: setmsg_ 14 2 13 124 */
/*:ref: errch_ 14 4 13 13 124 124 */
/*:ref: sigerr_ 14 2 13 124 */
/*:ref: chkout_ 14 2 13 124 */
/*:ref: tstopn_ 14 4 13 13 124 124 */
/*:ref: failed_ 12 0 */
/*:ref: reset_ 14 0 */
/*:ref: tstslf_ 14 2 13 124 */
extern int tstio_(char *line, char *name__, char *port, logical *ok, 
                  logical *status, ftnlen line_len, ftnlen name_len, 
                  ftnlen port_len);
extern int tstopn_(char *port, char *name__, ftnlen port_len, ftnlen name_len);
extern int tstioh_(char *port, ftnlen port_len);
extern int tstioa_(char *port, ftnlen port_len);
extern int tstgst_(char *port, logical *status, ftnlen port_len);
extern int tstpst_(char *port, logical *status, ftnlen port_len);
extern int tstioc_(char *port, ftnlen port_len);
extern int tstios_(char *port, ftnlen port_len);
extern int tstior_(char *port, logical *ok, ftnlen port_len);
extern int tstwln_(char *line, ftnlen line_len);
extern int finish_(void);
/*:ref: isrchc_ 4 5 13 4 13 124 124 */
/*:ref: rtrim_ 4 2 13 124 */
/*:ref: txtopn_ 14 3 13 4 124 */
/*:ref: failed_ 12 0 */
/*:ref: writln_ 14 3 13 4 124 */
/*:ref: repmc_ 14 8 13 13 13 13 124 124 124 124 */
/*:ref: repmi_ 14 7 13 13 4 13 124 124 124 */
/*:ref: niceio_3__ 14 5 13 4 13 124 124 */
extern int tstlgr_(char *messge, logical *errlog, char *gstyle, 
                   char *fstyle, char *marker, integer *int__, 
                   doublereal *dp, ftnlen messge_len, ftnlen gstyle_len,
                   ftnlen fstyle_len, ftnlen marker_len);
extern int tstlog_(char *messge, logical *errlog, ftnlen messge_len);
extern int tstlgs_(char *gstyle, char *fstyle, ftnlen gstyle_len, 
                   ftnlen fstyle_len);
extern int tststy_(char *gstyle, char *fstyle, ftnlen gstyle_len, 
                   ftnlen fstyle_len);
extern int vrblog_(char *messge, logical *errlog, ftnlen messge_len);
extern int tstmsg_(char *marker, char *messge, ftnlen marker_len, 
                   ftnlen messge_len);
extern int tstmsi_(integer *int__);
extern int tstmsd_(doublereal *dp);
extern int tstmsf_(doublereal *dp);
extern int tstmsc_(char *messge, ftnlen messge_len);
extern int tstmso_(integer *int__, char *marker, ftnlen marker_len);
extern int tstmst_(integer *int__, char *marker, ftnlen marker_len);
/*:ref: t_name__ 14 2 13 124 */
/*:ref: t_cname__ 14 2 13 124 */
/*:ref: t_fcount__ 14 1 4 */
/*:ref: t_cfail__ 14 0 */
/*:ref: tstfil_ 14 6 13 13 13 124 124 124 */
/*:ref: tstget_ 14 6 13 13 13 124 124 124 */
/*:ref: tstioa_ 14 2 13 124 */
/*:ref: tstioh_ 14 2 13 124 */
/*:ref: tstwln_ 14 2 13 124 */
/*:ref: nicepr_1__ 14 5 13 13 214 124 124 */
/*:ref: verbos_ 12 0 */
/*:ref: repmi_ 14 7 13 13 4 13 124 124 124 */
/*:ref: repmd_ 14 8 13 13 7 4 13 124 124 124 */
/*:ref: repmf_ 14 10 13 13 7 4 13 13 124 124 124 124 */
/*:ref: rtrim_ 4 2 13 124 */
/*:ref: repmc_ 14 8 13 13 13 13 124 124 124 124 */
/*:ref: repmot_ 14 9 13 13 4 13 13 124 124 124 124 */
/*:ref: repmct_ 14 9 13 13 4 13 13 124 124 124 124 */
extern int tstlip_(void);
extern int tstcbl_(void);
extern int tstlcy_(void);
extern int tstlcn_(void);
/*:ref: verbos_ 12 0 */
/*:ref: tststy_ 14 4 13 13 124 124 */
/*:ref: t_cpass__ 14 1 12 */
/*:ref: t_cnum__ 14 1 4 */
/*:ref: tstlog_ 14 3 13 12 124 */
/*:ref: tstlgs_ 14 4 13 13 124 124 */
/*:ref: t_cname__ 14 2 13 124 */
extern int tstlsk_(void);
/*:ref: begdat_ 13 2 13 124 */
/*:ref: newfil_1__ 14 4 13 13 124 124 */
/*:ref: tsttxt_ 14 7 13 13 4 12 12 124 124 */
extern int tstopl_(char *lognam, char *versn, ftnlen lognam_len, 
                   ftnlen versn_len);
/*:ref: tstfil_ 14 6 13 13 13 124 124 124 */
/*:ref: failed_ 12 0 */
/*:ref: curtim_ 14 2 13 124 */
/*:ref: pltfrm_ 14 4 4 4 13 124 */
/*:ref: tkvrsn_ 14 4 13 13 124 124 */
/*:ref: suffix_ 14 5 13 4 13 124 124 */
/*:ref: tstlog_ 14 3 13 12 124 */
/*:ref: tstsav_ 14 6 13 13 13 124 124 124 */
extern int tstpck_(char *namepc, logical *loadpc, logical *keeppc, 
                   ftnlen namepc_len);
/*:ref: kilfil_ 14 2 13 124 */
/*:ref: begdat_ 13 2 13 124 */
/*:ref: txtopn_ 14 3 13 4 124 */
/*:ref: rtrim_ 4 2 13 124 */
/*:ref: ldpool_ 14 2 13 124 */
extern int tstrul_(void);
/*:ref: verbos_ 12 0 */
/*:ref: tstlog_ 14 3 13 12 124 */
extern int tstsav_(char *env, char *versn, char *time, ftnlen env_len,
                   ftnlen versn_len, ftnlen time_len);
extern int tstget_(char *env, char *versn, char *time, ftnlen env_len,
                   ftnlen versn_len, ftnlen time_len);
extern int tstslf_(char *env, ftnlen env_len);
extern int tstglf_(char *env, ftnlen env_len);
extern int tstspk_(char *file, logical *load, integer *handle, ftnlen file_len);
/*:ref: kilfil_ 14 2 13 124 */
/*:ref: spcopn_ 14 5 13 13 4 124 124 */
/*:ref: tststc_ 14 2 4 4 */
/*:ref: tstst_ 14 8 4 7 13 4 7 4 7 124 */
/*:ref: frmnam_ 14 3 4 13 124 */
/*:ref: spkw05_ 14 13 4 4 4 13 7 7 13 7 4 7 7 124 124 */
/*:ref: spkw08_ 14 14 4 4 4 13 7 7 13 4 4 7 7 7 124 124 */
/*:ref: dafcls_ 14 1 4 */
/*:ref: spklef_ 14 3 13 4 124 */
/*:ref: rtrim_ 4 2 13 124 */
extern int tstst_(integer *body, doublereal *et, char *segid, integer *frame,
                  doublereal *state, integer *center, doublereal *gm,
                  ftnlen segid_len);
extern int tststc_(integer *body, integer *center);
/*:ref: prop2b_ 14 4 7 7 7 7 */
/*:ref: namfrm_ 14 3 13 4 124 */
/*:ref: pi_ 7 0 */
/*:ref: conics_ 14 3 7 7 7 */
/*:ref: dpr_ 7 0 */
/*:ref: latrec_ 14 4 7 7 7 7 */
extern int tsttxt_(char *namtxt, char *txt, integer *nlines, logical *load,
                   logical *keep, ftnlen namtxt_len, ftnlen txt_len);
/*:ref: kilfil_ 14 2 13 124 */
/*:ref: txtopn_ 14 3 13 4 124 */
/*:ref: rtrim_ 4 2 13 124 */
/*:ref: ldpool_ 14 2 13 124 */
extern int tstvrs_(char *verstr, ftnlen verstr_len);
extern logical verbos_(void);
extern logical verbon_(void);
extern logical verboff_(void);
extern int tstspk_(char *file, logical *load, integer *handle, ftnlen file_len);
/*:ref: kilfil_ 14 2 13 124 */
/*:ref: spcopn_ 14 5 13 13 4 124 124 */
/*:ref: tststc_ 14 2 4 4 */
/*:ref: tstst_ 14 8 4 7 13 4 7 4 7 124 */
/*:ref: frmnam_ 14 3 4 13 124 */
/*:ref: spkw05_ 14 13 4 4 4 13 7 7 13 7 4 7 7 124 124 */
/*:ref: spkw08_ 14 14 4 4 4 13 7 7 13 4 4 7 7 7 124 124 */
/*:ref: dafcls_ 14 1 4 */
/*:ref: spklef_ 14 3 13 4 124 */
/*:ref: rtrim_ 4 2 13 124 */
extern int tstatd_(doublereal *et, doublereal *matrix, doublereal *angvel);
/*:ref: axisar_ 14 3 7 7 7 */
/*:ref: mxm_ 14 3 7 7 7 */
/*:ref: lstled_ 4 3 7 4 7 */
/*:ref: xpose_ 14 2 7 7 */
/*:ref: vhat_ 14 2 7 7 */
/*:ref: vscl_ 14 3 7 7 7 */
extern int tstent_(integer *fileno, char *table, integer *segno, char *column,
                   integer *rowno, integer *nmax, integer *nelts, char *cvals,
                   doublereal *dvals, integer *ivals, doublereal *tvals,
                   logical *isnull, ftnlen table_len, ftnlen column_len,
                   ftnlen cvals_len);
/*:ref: return_ 12 0 */
/*:ref: chkin_ 14 2 13 124 */
/*:ref: chkout_ 14 2 13 124 */
/*:ref: repmi_ 14 7 13 13 4 13 124 124 124 */
/*:ref: setmsg_ 14 2 13 124 */
/*:ref: errch_ 14 4 13 13 124 124 */
/*:ref: sigerr_ 14 2 13 124 */
/*:ref: suffix_ 14 5 13 4 13 124 124 */
/*:ref: odd_ 12 1 4 */
/*:ref: rtrim_ 4 2 13 124 */
extern int tstsch_(char *table, integer *mxrows, integer *segtyp, 
                   integer *nrows,
                   integer *ncols, char *cnames, integer *cclass, 
                   integer *dtypes,
                   integer *stlens, integer *dims__, logical *indexd, 
                   logical *nullok,
                   char *decls, ftnlen table_len, ftnlen cnames_len, 
                   ftnlen decls_len);
/*:ref: return_ 12 0 */
/*:ref: chkin_ 14 2 13 124 */
/*:ref: setmsg_ 14 2 13 124 */
/*:ref: errint_ 14 3 13 4 124 */
/*:ref: sigerr_ 14 2 13 124 */
/*:ref: chkout_ 14 2 13 124 */
/*:ref: cleari_ 14 2 4 4 */
/*:ref: errch_ 14 4 13 13 124 124 */
/*:ref: suffix_ 14 5 13 4 13 124 124 */
/*:ref: repmi_ 14 7 13 13 4 13 124 124 124 */
/*:ref: repmc_ 14 8 13 13 13 13 124 124 124 124 */
extern int t_pck08__(char *namepc, logical *loadpc, logical *keeppc, 
                     ftnlen namepc_len);
/*:ref: kilfil_ 14 2 13 124 */
/*:ref: begdat_ 13 2 13 124 */
/*:ref: begtxt_ 13 2 13 124 */
/*:ref: txtopn_ 14 3 13 4 124 */
/*:ref: rtrim_ 4 2 13 124 */
/*:ref: writln_ 14 3 13 4 124 */
/*:ref: ldpool_ 14 2 13 124 */
/*:ref: tfiles_ 14 2 13 124 */


