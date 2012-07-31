/* Some flags to control experiments with chaperones: */
#define COUNT_CHAPS 1

#define SHORT_CIRCUIT_CHAP_RESULT 0

#define SHORT_CIRCUIT_CHAP_PROC_APPLY 0
#define SHORT_CIRCUIT_CHAP_PROC 0

#define SHORT_CIRCUIT_CHAP_VEC_APPLY 0
#define SHORT_CIRCUIT_CHAP_VEC 0

#define SHORT_CIRCUIT_CHAP_STRUCT_APPLY 0
#define SHORT_CIRCUIT_CHAP_STRUCT 0

#if COUNT_CHAPS
extern int proc_makes, proc_apps;
extern int vec_makes, vec_apps;
extern int struct_makes, struct_apps;
#endif
