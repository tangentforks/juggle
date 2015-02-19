/* hash.h - header file for hash.c */

/* @(#)hash.h	1.2 24/5/95 (UKC) */

/* Copyright 1992  Mark Russell, University of Kent at Canterbury */

typedef struct hashtab_s hashtab_t;

typedef const char *hash_key_t;
typedef const char *hash_value_t;

typedef struct hashvalues_s {
	int hv_nvalues;
	hash_value_t *hv_values;
	int hv__max_nvalues;
	hash_value_t hv__static_values[10];
} hashvalues_t;

typedef const char *(*hash_apply_func_t)PROTO((hashtab_t *hashtab,
					       const char *arg, hash_key_t key,
					       size_t keylen, hashvalues_t *hv));

hashtab_t *hash_create_tab PROTO((alloc_id_t alloc_id, int probable_size));

void hash_enter_key PROTO((hashtab_t *hashtab,
			   hash_key_t key, size_t keylen));
void hash_enter PROTO((hashtab_t *hashtab, hash_key_t key,
					size_t keylen, hash_value_t value));

bool hash_lookup_key PROTO((hashtab_t *hashtab, hash_key_t key,
					size_t keylen, hashvalues_t *hv));
hash_value_t hash_lookup PROTO((hashtab_t *hashtab, hash_key_t key,
					size_t keylen));

void hash_delete_key PROTO((hashtab_t *hashtab, hash_key_t key,
					size_t keylen));
void hash_delete PROTO((hashtab_t *hashtab, hash_key_t key,
					size_t keylen, hash_value_t value));

hashvalues_t *hash_make_hashvalues PROTO((void));
void hash_free_hashvalues PROTO((hashvalues_t *hv));

const char *hash_apply PROTO((hashtab_t *hashtab, hash_apply_func_t func,
					const char *arg, hashvalues_t *hv));
char *hash_stats PROTO((hashtab_t *hashtab));
