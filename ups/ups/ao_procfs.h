/* ao_procfs.h - header file for ao_procfs.c */

/*  Copyright 1995 Mark Russell, University of Kent at Canterbury.
 *
 *  You can do what you like with this source code as long as
 *  you don't try to make money out of it and you include an
 *  unaltered copy of this message (including the copyright).
 */

/* @(#)ao_procfs.h	1.1 24/5/95 (UKC) */

int procfs_setreg PROTO((iproc_t *ip, int regno, taddr_t value));
int procfs_create_child PROTO((target_t *xp, 
                               const char **argv, const char **envp, 
                               long rdlist, stopres_t *p_stopres));
int procfs_attach_to_process PROTO((target_t *xp, int pid));
void procfs_kill PROTO((target_t *xp));
void procfs_detach_from_process PROTO((target_t *xp));
stopres_t procfs_continue PROTO((target_t *xp, taddr_t restart_pc, int sig));
stopres_t procfs_single_step PROTO((target_t *xp, int sig));
int procfs_readreg PROTO((iproc_t *ip, int regno, taddr_t *p_val));
int procfs_read_fpreg PROTO((iproc_t *ip, int regno, int num_bytes, 
                             fpval_t *p_val));
sigstate_t procfs_get_sigstate PROTO((iproc_t *ip, int signo));
int procfs_read_data PROTO((iproc_t *ip, taddr_t addr, char *buf, 
                            size_t nbytes));
int procfs_write_data PROTO((iproc_t *ip, taddr_t addr, const char *buf, 
                             size_t nbytes));
int procfs_write_corefile PROTO((iproc_t *ip, const char *name));

typedef enum {
	PROCFS_REG_SP,
	PROCFS_REG_O0,
	PROCFS_REG_NREGS
} Procfs_regname;

void procfs_get_regtab PROTO((iproc_t *ip, int *regtab));
int procfs_get_reg_index PROTO((Procfs_regname regname));
bool procfs_set_all_regs PROTO((iproc_t *ip, int *regtab));

void procfs_init PROTO((iproc_t *ip));

int procfs_get_last_attach_pid PROTO((void));
bool procfs_new_dynamic_libs PROTO((target_t *xp));
bool procfs_load_mmap_info PROTO((target_t *xp, bool attached));
