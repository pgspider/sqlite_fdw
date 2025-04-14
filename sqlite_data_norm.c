/*-------------------------------------------------------------------------
 *
 * SQLite Foreign Data Wrapper for PostgreSQL
 *
 * SQLite functions for data normalization
 * This functions are used for mixed affinity inputs for PostgreSQL data column.
 *
 * Most of UUID functions are implemented here according
 * the uuid SQLite extension, Public Domain
 * https://www.sqlite.org/src/file/ext/misc/uuid.c
 *
 * IDENTIFICATION
 * 		sqlite_data_norm.c
 *
 *-------------------------------------------------------------------------
 */

#include <assert.h>
#include <ctype.h>
#include <string.h>
#include <math.h>

#include "sqlite3.h"
#include "postgres.h"
#include "sqlite_fdw.h"
#include "utils/builtins.h"
#include <sys/socket.h>
#include "utils/inet.h"
#include "utils/uuid.h"

static void error_catcher(sqlite3* db, int rc);
static bool infinity_processing (double* d, const char* t);
static sqlite_uint64 ipaddr_v4_int (const unsigned char *pBlob, int len);

/* Also used for BLOBs in sqlite_gis.c */
const char hex_dig[] = "0123456789abcdef";

#if !defined(SQLITE_ASCII) && !defined(SQLITE_EBCDIC)
#define SQLITE_ASCII 1
#endif

#define PARSE_MACADDR(format) \
if (count != MACADDR_LEN)  \
	count = sscanf(str, format, &a, &b, &c, &d, &e, &f, junk);

#define PARSE_MACADDR8(format) \
if (count != MACADDR8_LEN)  \
	count = sscanf(str, format, &a, &b, &c, &d, &e, &f, &g, &h, junk);

#define MAX_IP_TEXT_CHAR_LENGTH 52

/*
 * This UUID SQLite extension as a group of UUID C functions
 * implements functions that handling RFC-4122 UUIDs
 * Three SQL functions are implemented:
 *
 *	 sqlite_fdw_uuid_str(X)   - convert a UUID X into a well-formed UUID string
 *	 sqlite_fdw_uuid_blob(X)  - convert a UUID X into a 16-byte blob
 *
 * The output from sqlite_fdw_uuid_str(X) are always well-formed
 * RFC-4122 UUID strings in this format:
 *
 *		xxxxxxxx-xxxx-Mxxx-Nxxx-xxxxxxxxxxxx
 *
 * All of the 'x', 'M', and 'N' values are lower-case hexadecimal digits.
 * The M digit indicates the "version".  For uuid4()-generated UUIDs, the
 * version is always "4" (a random UUID).  The upper three bits of N digit
 * are the "variant".  This library only supports variant 1 (indicated
 * by values of N between '8' and 'b') as those are overwhelming the most
 * common.  Other variants are for legacy compatibility only.
 *
 * The output of sqlite_fdw_uuid_blob(X) is always a 16-byte blob. The UUID input
 * string is converted in network byte order (big-endian) in accordance
 * with RFC-4122 specifications for variant-1 UUIDs.  Note that network
 * byte order is *always* used, even if the input self-identifies as a
 * variant-2 UUID.
 *
 * The input X to the sqlite_fdw_uuid_blob() function can be either
 * a string or a BLOB. If it is a BLOB it must be exactly 16 bytes in
 * length or else a NULL is returned.  If the input is a string it must
 * consist of 32 hexadecimal digits, upper or lower case, optionally
 * surrounded by {...} and with optional "-" characters interposed in the
 * middle.  The flexibility of input is inspired by the PostgreSQL
 * implementation of UUID functions that accept in all of the following
 * formats:
 *
 *	 A0EEBC99-9C0B-4EF8-BB6D-6BB9BD380A11
 *	 {a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11}
 *	 a0eebc999c0b4ef8bb6d6bb9bd380a11
 *	 a0ee-bc99-9c0b-4ef8-bb6d-6bb9-bd38-0a11
 *	 {a0eebc99-9c0b4ef8-bb6d6bb9-bd380a11}
 *
 * Output of sqlite_fdw_uuid_str() always will be
 * in the canonical RFC-4122 format:
 *
 *	 a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11
 *
 * If the X input string has too few or too many digits or contains
 * stray characters other than {, }, or -, then NULL is returned.
 */

/*
 * Translate a single byte of Hex into an integer.
 * This routine only works if h really is a valid hexadecimal
 * character:  0..9a..fA..F
 */
static unsigned char
sqlite_fdw_data_norm_UuidHexToInt(int h)
{
	assert((h >= '0' && h <= '9') || (h >= 'a' && h <= 'f') || (h >= 'A' && h <= 'F'));
#ifdef SQLITE_ASCII
	h += 9 * (1 & (h >> 6));
#endif
#ifdef SQLITE_EBCDIC
	h += 9 * (1 & ~(h >> 4));
#endif
	return (unsigned char)(h & 0xf);
}

/*
 * Attempt to parse a zero-terminated input string zs into a binary
 * UUID.  Return 1 on success, or 0 if the input string is not
 * parsable.
 */
static int
sqlite_fdw_uuid_blob (const unsigned char* s0, unsigned char* Blob)
{
	int i;
	unsigned char* s = (unsigned char*)s0;
	if (s[0] == '{')
		s++;
	for (i = 0; i < 16; i++)
	{
		if (s[0] == '-')
			s++;
		if (isxdigit(s[0]) && isxdigit(s[1]))
		{
			Blob[i] = (sqlite_fdw_data_norm_UuidHexToInt(s[0]) << 4) + sqlite_fdw_data_norm_UuidHexToInt(s[1]);
			s += 2;
		}
		else
		{
			return 0;
		}
	}
	if (s[0] == '}')
		s++;
	return s[0] == 0;
}

/*
 * uuid_generate generates a version 4 UUID as a string
 *
 *static void uuid_generate(sqlite3_context* context, int argc, sqlite3_value** argv)
 *{
 *	unsigned char aBlob[16];
 *	unsigned char zs[37];
 *	sqlite3_randomness(16, aBlob);
 *	aBlob[6] = (aBlob[6] & 0x0f) + 0x40;
 *	aBlob[8] = (aBlob[8] & 0x3f) + 0x80;
 *	sqlite_fdw_data_norm_uuid_blob_to_str(aBlob, zs);
 *	sqlite3_result_text(context, (char*)zs, 36, SQLITE_TRANSIENT);
 *}
 */

/*
 * aBlob to RFC UUID string with 36 characters
 */
static void
sqlite3UuidBlobToStr( const unsigned char *aBlob, unsigned char *zs)
{
	unsigned char x;
	int i = 0, k=0x550;
	for(; i < UUID_LEN; i++, k = k >> 1)
	{
		if( k&1 )
		{
			zs[0] = '-';
			zs++;
		}
		x = aBlob[i];
		zs[0] = hex_dig[x>>4];
		zs[1] = hex_dig[x&0xf];
		zs += 2;
	}
	*zs = 0;
}

/*
 * Converts argument BLOB-UUID into a well-formed UUID string.
 * X can be either a string or a blob.
 */
static void
sqlite_fdw_uuid_str(sqlite3_context* context, int argc, sqlite3_value** argv)
{
	unsigned char aBlob[UUID_LEN];
	const unsigned char* pBlob;
	unsigned char zs[UUID_LEN * 2 + 1];
	sqlite3_value* arg = argv[0];
	int t = sqlite3_value_type(arg);

	if (t == SQLITE_BLOB)
	{
		pBlob = sqlite3_value_blob(arg);
	}
	else if (t == SQLITE3_TEXT)
	{
		const unsigned char* txt = sqlite3_value_text(arg);
		if (sqlite_fdw_uuid_blob(txt, aBlob))
			pBlob = aBlob;
		else
		{
			sqlite3_result_null(context);
			return;
		}
	}
	else
	{
		sqlite3_result_null(context);
		return;
	}

	sqlite3UuidBlobToStr(pBlob, zs);
	sqlite3_result_text(context, (char*)zs, 36, SQLITE_TRANSIENT);
}

/*
 * sqlite_fdw_data_norm_uuid normalize text or blob UUID argv[0] into a 16-byte blob.
 */
static void
sqlite_fdw_data_norm_uuid(sqlite3_context* context, int argc, sqlite3_value** argv)
{
	unsigned char aBlob[16];
	sqlite3_value* arg = argv[0];

	if (sqlite3_value_type(argv[0]) == SQLITE3_TEXT)
	{
		const unsigned char* txt = sqlite3_value_text(arg);
		if (sqlite_fdw_uuid_blob(txt, aBlob))
		{
			sqlite3_result_blob(context, aBlob, 16, SQLITE_TRANSIENT);
			return;
		}
	}
	sqlite3_result_value(context, arg);
}

/* ********************* End of UUID SQLite extension *********************** */

/*
 * ISO:SQL valid boolean values with text affinity such as Y, no, f, t, oN etc.
 * will be treated as boolean like in PostgreSQL console input
 */
static void
sqlite_fdw_data_norm_bool(sqlite3_context* context, int argc, sqlite3_value** argv)
{

	sqlite3_value* arg = argv[0];
	int dt = sqlite3_value_type(arg);
	const char* t;
	int l;

	if (dt == SQLITE_INTEGER)
	{
		/* The fastest call because expected very often */
		sqlite3_result_value(context, arg);
		return;
	}
	if (dt != SQLITE3_TEXT && dt != SQLITE_BLOB )
	{
		/* NULL, FLOAT */
		sqlite3_result_value(context, arg);
		return;
	}
	l = sqlite3_value_bytes(arg);
	if (l > 5)
	{
		sqlite3_result_value(context, arg);
		return;
	}

	t = (const char*)sqlite3_value_text(arg);

	if ( l == 1 )
	{
		if (strcasecmp(t, "t") == 0)
		{
			sqlite3_result_int(context, 1);
			return;
		}
		if (strcasecmp(t, "f") == 0)
		{
			sqlite3_result_int(context, 0);
			return;
		}
		if (strcasecmp(t, "y") == 0)
		{
			sqlite3_result_int(context, 1);
			return;
		}
		if (strcasecmp(t, "n") == 0)
		{
			sqlite3_result_int(context, 0);
			return;
		}
		/* rare but possible cases */
		if (strcasecmp(t, "1") == 0)
		{
			sqlite3_result_int(context, 1);
			return;
		}
		if (strcasecmp(t, "0") == 0)
		{
			sqlite3_result_int(context, 0);
			return;
		}
	}
	else if ( l == 2 )
	{
		if (strcasecmp(t, "on") == 0)
		{
			sqlite3_result_int(context, 1);
			return;
		}
		if (strcasecmp(t, "no") == 0)
		{
			sqlite3_result_int(context, 0);
			return;
		}
	}
	else if ( l == 3 )
	{
		if (strcasecmp(t, "yes") == 0)
		{
			sqlite3_result_int(context, 1);
			return;
		}
		if (strcasecmp(t, "off") == 0)
		{
			sqlite3_result_int(context, 0);
			return;
		}
	}
	else if ( l == 4 && strcasecmp(t, "true") == 0)
	{
		sqlite3_result_int(context, 1);
		return;
	}
	else if ( l == 5 && strcasecmp(t, "false") == 0)
	{
		sqlite3_result_int(context, 0);
		return;
	}
	sqlite3_result_value(context, arg);
}

/* Base ∞ constants */
const char * infs = "Inf";
const char * infl = "Infinity";

/*
 * Try to check SQLite value if there is any ∞ value with text affinity
 */
static inline bool
infinity_processing (double* d, const char* t)
{
	static const char * neg_infs = "-Inf";
	static const char * neg_infl = "-Infinity";
	static const char * pos_infs = "+Inf";
	static const char * pos_infl = "+Infinity";

	if (strcasecmp(t, infs) == 0 ||
		strcasecmp(t, pos_infs) == 0 ||
		strcasecmp(t, infl) == 0 ||
		strcasecmp(t, pos_infl) == 0)
	{
		*d = INFINITY;
		return true;
	}
	if (strcasecmp(t, neg_infs) == 0 ||
		strcasecmp(t, neg_infl) == 0)
	{
		*d = -INFINITY;
		return true;
	}
	return false;
}

/*
 * ISO:SQL valid float/double precision values with text affinity such as Infinity or Inf
 * will be treated as float like in PostgreSQL console input
 * Note: SQLite also have Infinity support with real affinity, but this values
 * isn't suitable for insert, there is any overflow number instead
 */
static void
sqlite_fdw_data_norm_float(sqlite3_context* context, int argc, sqlite3_value** argv)
{
	sqlite3_value* arg = argv[0];
	int dt = sqlite3_value_type(arg);
	int l;
	const char* t = NULL;
	double result;

	if (dt == SQLITE_FLOAT)
	{
		/* The fastest call because expected very often */
		sqlite3_result_value(context, arg);
		return;
	}
	if (dt != SQLITE3_TEXT && dt != SQLITE_BLOB )
	{
		/* INT, NULL*/
		sqlite3_result_value(context, arg);
		return;
	}

	l = sqlite3_value_bytes(arg);
	if (l > strlen(infl) + 2 || l < strlen(infs))
	{
		sqlite3_result_value(context, arg);
		return;
	}
	t = (const char*)sqlite3_value_text(arg);
	if (infinity_processing (&result, t))
	{
		sqlite3_result_double(context, result);
		return;
	}
	sqlite3_result_value(context, arg);
}

/*
 * Converts argument int64-MAC address into a well-formed MAC address string.
 */
static void
sqlite_fdw_macaddr_str(sqlite3_context* context, int argc, sqlite3_value** argv)
{
	sqlite3_value* arg = argv[0];
	sqlite3_value* len_arg = argv[1];
	int val_aff = sqlite3_value_type(arg);
	int len = 0;

	if (sqlite3_value_type(len_arg) != SQLITE_INTEGER)
	{
		ereport(ERROR,
			(errcode(ERRCODE_FDW_INVALID_DATA_TYPE),
			 errmsg("no mac address length argument in BLOB creating function %s", __func__)));
	}

	len = sqlite3_value_int(len_arg);
	if (val_aff != SQLITE_INTEGER || (len !=MACADDR_LEN && len !=MACADDR8_LEN))
	{
		ereport(ERROR,
		(errcode(ERRCODE_FDW_INVALID_DATA_TYPE),
		 errmsg("internal mac deparse error or SQLite input have not 'int' affinity")));
		return;
	}
	else
	{
		int				reslen = len * 4;
		char		   *result = (char *) palloc(reslen);
		sqlite3_int64	value = sqlite3_value_int64(arg);

		if (len == MACADDR_LEN )
		{
			snprintf(result, reslen, "%02x:%02x:%02x:%02x:%02x:%02x",
  				(unsigned char)((value >> (CHAR_BIT * 5)) & 0xFF),
  				(unsigned char)((value >> (CHAR_BIT * 4)) & 0xFF),
  				(unsigned char)((value >> (CHAR_BIT * 3)) & 0xFF),
  				(unsigned char)((value >> (CHAR_BIT * 2)) & 0xFF),
  				(unsigned char)((value >> (CHAR_BIT * 1)) & 0xFF),
  				(unsigned char)((value >> (CHAR_BIT * 0)) & 0xFF));
		}
		else if (len == MACADDR8_LEN )
		{
			snprintf(result, reslen, "%02x:%02x:%02x:%02x:%02x:%02x:%02x:%02x",
  				(unsigned char)((value >> (CHAR_BIT * 7)) & 0xFF),
  				(unsigned char)((value >> (CHAR_BIT * 6)) & 0xFF),
  				(unsigned char)((value >> (CHAR_BIT * 5)) & 0xFF),
  				(unsigned char)((value >> (CHAR_BIT * 4)) & 0xFF),
  				(unsigned char)((value >> (CHAR_BIT * 3)) & 0xFF),
  				(unsigned char)((value >> (CHAR_BIT * 2)) & 0xFF),
  				(unsigned char)((value >> (CHAR_BIT * 1)) & 0xFF),
  				(unsigned char)((value >> (CHAR_BIT * 0)) & 0xFF));
		}
		sqlite3_result_text(context, (char*)result, reslen, SQLITE_TRANSIENT);
	}
}

/*
 * Attempt to parse a zero-terminated input string zs into a int64
 * as 6 bytes MAC address. Return 1 if ok, or 0 if the input string is not
 * parsable.
 */
static int
sqlite_fdw_macaddr6_int (const unsigned char* s, sqlite_uint64*	i)
{
	 int		 a,
				 b,
				 c,
				 d,
				 e,
				 f;
	 char		 junk[2];
	 int		 count = 0;
	 const char* str = (const char*)s;

	 /* %1s matches if there is trailing non-whitespace garbage */
	 PARSE_MACADDR("%x:%x:%x:%x:%x:%x%1s");
	 PARSE_MACADDR("%x-%x-%x-%x-%x-%x%1s");
	 PARSE_MACADDR("%2x%2x%2x:%2x%2x%2x%1s");
	 PARSE_MACADDR("%2x%2x%2x-%2x%2x%2x%1s");
	 PARSE_MACADDR("%2x%2x.%2x%2x.%2x%2x%1s");
	 PARSE_MACADDR("%2x%2x-%2x%2x-%2x%2x%1s");
	 PARSE_MACADDR("%2x%2x%2x%2x%2x%2x%1s");
	 if (count != MACADDR_LEN)
		return false;

	if ((a < 0) || (a > 255) ||
		(b < 0) || (b > 255) ||
		(c < 0) || (c > 255) ||
		(d < 0) || (d > 255) ||
		(e < 0) || (e > 255) ||
		(f < 0) || (f > 255) )
		return false;

	*i = (((sqlite_int64)a) << 40) +
		(((sqlite_int64)b) << 32) +
		(c<<24) +
		(d<<16) +
		(e<<8) +
		f;
	return true;
}

/*
 * Attempt to parse a zero-terminated input string zs into a int64
 * as 8 bytes MAC address. Return 1 if ok, or 0 if the input string is not
 * parsable.
 */
static int
sqlite_fdw_macaddr8_int (const unsigned char* s, sqlite_uint64*	i)
{
	 int 		 a,
				 b,
				 c,
				 d,
				 e,
				 f,
				 g,
				 h;
	 char   	 junk[2];
	 int		 count = 0;
	 const char* str = (const char*)s;

	 /* %1s matches if there is trailing non-whitespace garbage */
 	 PARSE_MACADDR8("%x:%x:%x:%x:%x:%x:%x:%x%1s");
	 PARSE_MACADDR8("%x-%x-%x-%x-%x-%x-%x-%x%1s");
	 PARSE_MACADDR8("%2x%2x%2x%2x:%2x%2x%2x%2x%1s");
	 PARSE_MACADDR8("%2x%2x%2x%2x-%2x%2x%2x%2x%1s");
	 PARSE_MACADDR8("%2x%2x.%2x%2x.%2x%2x.%2x%2x%1s");
	 PARSE_MACADDR8("%2x%2x-%2x%2x-%2x%2x-%2x%2x%1s");
	 PARSE_MACADDR8("%2x%2x%2x%2x%2x%2x%2x%2x%1s");
	 if (count != MACADDR8_LEN)
		return false;

	 if ((a < 0) || (a > 255) ||
	 	 (b < 0) || (b > 255) ||
	 	 (c < 0) || (c > 255) ||
	 	 (d < 0) || (d > 255) ||
		 (e < 0) || (e > 255) ||
		 (f < 0) || (f > 255) ||
   		 (g < 0) || (g > 255) ||
		 (h < 0) || (h > 255) )
		return false;

	*i = (((sqlite_int64)a) << 56) +
		(((sqlite_int64)b) << 48) +
		(((sqlite_int64)c) << 40) +
		(((sqlite_int64)d) << 32) +
		(e<<24) +
		(f<<16) +
		(g<<8) +
		h;
	return true;
}

/*
 * sqlite_fdw_data_norm_macaddr
 *		normalize text or integer or blob MAC address argv[0] into sqlite_int64.
 */
static void
sqlite_fdw_data_norm_macaddr(sqlite3_context* context, int argc, sqlite3_value** argv)
{
	sqlite3_value* val_arg = argv[0];
	sqlite3_value* len_arg = argv[1];
	int val_aff = sqlite3_value_type(val_arg);
	int len = 0;

	if (val_aff == SQLITE_INTEGER)
	{
		/* the fastest call for typical case */
		sqlite3_result_value(context, val_arg);
		return;
	}

	if (sqlite3_value_type(len_arg) != SQLITE_INTEGER)
	{
		ereport(ERROR,
			(errcode(ERRCODE_FDW_INVALID_DATA_TYPE),
			 errmsg("no mac address length argument in MAC addr blob creating function %s", __func__)));
	}

	len = sqlite3_value_int(len_arg);

	if (val_aff == SQLITE3_TEXT)
	{
		const unsigned char* txt = sqlite3_value_text(val_arg);
		sqlite3_uint64 mac_int = 0;
		int res = (len == MACADDR_LEN) ? sqlite_fdw_macaddr6_int(txt, &mac_int) : sqlite_fdw_macaddr8_int(txt, &mac_int);
		if (res)
		{
			sqlite3_result_int64(context, mac_int);
			return;
		}
	}
	else if (val_aff == SQLITE_BLOB)
	{
		const unsigned char*	pBlob = sqlite3_value_blob(val_arg);
		int						l_blob = sqlite3_value_bytes(val_arg);
		sqlite3_uint64			res = 0;

		if (len == MACADDR_LEN)
		{
			if (l_blob != MACADDR_LEN)
			{
				ereport(ERROR, (errcode(ERRCODE_FDW_INVALID_DATA_TYPE),
								errmsg("PostgreSQL macaddr data type allows only %d bytes SQLite blob value", MACADDR_LEN)));
			}
			res = (((sqlite_int64)(pBlob[0])) << (CHAR_BIT *5)) +
				  (((sqlite_int64)(pBlob[1])) << (CHAR_BIT *4)) +
				  (((sqlite_int64)(pBlob[2])) << (CHAR_BIT *3)) +
				  (((sqlite_int64)(pBlob[3])) << (CHAR_BIT *2)) +
				  (((sqlite_int64)(pBlob[4])) << (CHAR_BIT *1)) +
				  (((sqlite_int64)(pBlob[5])) << (CHAR_BIT *0));
		}
		else if (len == MACADDR8_LEN)
		{
			if (l_blob != MACADDR8_LEN)
			{
				ereport(ERROR, (errcode(ERRCODE_FDW_INVALID_DATA_TYPE),
								errmsg("PostgreSQL macaddr8 data type allows only %d bytes SQLite blob value", MACADDR8_LEN)));
			}
			res = (((sqlite_int64)(pBlob[0])) << (CHAR_BIT *7)) +
				  (((sqlite_int64)(pBlob[1])) << (CHAR_BIT *6)) +
				  (((sqlite_int64)(pBlob[2])) << (CHAR_BIT *5)) +
				  (((sqlite_int64)(pBlob[3])) << (CHAR_BIT *4)) +
				  (((sqlite_int64)(pBlob[4])) << (CHAR_BIT *3)) +
				  (((sqlite_int64)(pBlob[5])) << (CHAR_BIT *2)) +
				  (((sqlite_int64)(pBlob[6])) << (CHAR_BIT *1)) +
				  (((sqlite_int64)(pBlob[7])) << (CHAR_BIT *0));
		}
		sqlite3_result_int64(context, res);
		return;
	}
	sqlite3_result_value(context, val_arg);
}

/*
 * Converts argv[0] int-MAC address (both 6 or 8 bytes) to MAC-address BLOB.
 */
static void
sqlite_fdw_macaddr_blob(sqlite3_context* context, int argc, sqlite3_value** argv)
{
	sqlite3_value* arg = argv[0];
	sqlite3_value* len_arg = argv[1];
	int val_aff = sqlite3_value_type(arg);
	int len = 0;

	if (sqlite3_value_type(len_arg) != SQLITE_INTEGER)
	{
		ereport(ERROR,
			(errcode(ERRCODE_FDW_INVALID_DATA_TYPE),
			 errmsg("no mac address length argument in MAC addr blob creating function %s", __func__)));
	}

	len = sqlite3_value_int(len_arg);
	if (val_aff != SQLITE_INTEGER || (len != MACADDR_LEN && len != MACADDR8_LEN))
	{
		ereport(ERROR,
		(errcode(ERRCODE_FDW_INVALID_DATA_TYPE),
		 errmsg("internal mac deparse error or SQLite input have not 'int' affinity")));
		return;
	}

	if (val_aff == SQLITE_INTEGER)
	{
		unsigned char aBlob[MACADDR8_LEN]; /* max possible, even for macaddr */
		sqlite_uint64 v = sqlite3_value_int64(arg);
		int			  i;

		for (i = len - 1; i >=0; i--)
		{
			int s = CHAR_BIT*i;
			aBlob[len-i-1] = (v >> s) & 0xff;
		}

		if (len == MACADDR_LEN)
			sqlite3_result_blob(context, aBlob, MACADDR_LEN, SQLITE_TRANSIENT);
		else
			sqlite3_result_blob(context, aBlob, MACADDR8_LEN, SQLITE_TRANSIENT);
		return;
	}
	else
	{
		ereport(ERROR,
			(errcode(ERRCODE_FDW_INVALID_DATA_TYPE),
			 errmsg("wrong mac address length argument %d in MAC addr blob creating function %s", len, __func__)));
	}
}

static void
ipaddr_str(const unsigned char* pBlob, int len, char* tmp)
{

	int						ipfamily = (len <= 5) ? PGSQL_AF_INET : PGSQL_AF_INET6;
	bool					is_cidr = len == 5 || len == 17;
	int						ip_len = ipfamily == PGSQL_AF_INET ? 4 : 16;
	unsigned char			bits = is_cidr ? pBlob[len - 1] : (ip_len * CHAR_BIT);
	char   				   *dst;

	memset(tmp, '\0', MAX_IP_TEXT_CHAR_LENGTH +1);
	dst = pg_inet_net_ntop(ipfamily, pBlob, bits,
						   tmp, MAX_IP_TEXT_CHAR_LENGTH);
	if (dst == NULL)
		ereport(ERROR,
				(errcode(ERRCODE_INVALID_BINARY_REPRESENTATION),
				 errmsg("could not format inet value: %m")));

	/* For CIDR, add /n if not present */
	if (is_cidr && strchr(tmp, '/') == NULL)
	{
		len = strlen(tmp);
		snprintf(tmp + len, MAX_IP_TEXT_CHAR_LENGTH - len, "/%u", bits);
	}
}

/*
 * Converts argv[0] blob IP address into a well-formed IP address string.
 */
static void
sqlite_fdw_ipaddr_str(sqlite3_context* context, int argc, sqlite3_value** argv)
{
	sqlite3_value		   *arg = argv[0];
	int						val_aff = sqlite3_value_type(arg);
	int						len = sqlite3_value_bytes(arg);
	const unsigned char	   *pBlob;
	char					tmp[MAX_IP_TEXT_CHAR_LENGTH + 1];

	if (val_aff != SQLITE_BLOB || !(len == 4 || len == 5 || len == 16 || len == 17))
		ereport(ERROR,
		(errcode(ERRCODE_FDW_INVALID_DATA_TYPE),
		 errmsg("could not create SQLite text of IP address"),
		 errhint("can be based only on BLOB input affinity value with 4,5,16 or 17 bytes length")));

	pBlob = sqlite3_value_blob(arg);
	ipaddr_str(pBlob, len, tmp);
	sqlite3_result_text(context, (char*)tmp, strlen(tmp), SQLITE_TRANSIENT);
}

/*
 * Verify a CIDR address is OK (doesn't have bits set past the masklen)
 */
static bool
addressOK(unsigned char *a, int bits, int family)
{
	int		byte;
	int		nbits;
	int		maxbits;
	int		maxbytes;
	unsigned char mask;

	if (family == PGSQL_AF_INET)
	{
		maxbits = 32;
		maxbytes = 4;
	}
	else
	{
		maxbits = 128;
		maxbytes = 16;
	}
	Assert(bits <= maxbits);

	if (bits == maxbits)
		return true;

	byte = bits / 8;

	nbits = bits % 8;
	mask = 0xff;
	if (bits != 0)
		mask >>= nbits;

	while (byte < maxbytes)
	{
		if ((a[byte] & mask) != 0)
			return false;
		mask = 0xff;
		byte++;
	}

	return true;
}

/*
 * Converts argument IP address (both v4 or v6) to IP-BLOB.
 */
static void
sqlite_fdw_ipaddr_blob(sqlite3_context* context, int argc, sqlite3_value** argv)
{
	sqlite3_value* arg = argv[0];
	int val_aff = sqlite3_value_type(arg);

	/* fastest */
	if (val_aff == SQLITE_BLOB)
		sqlite3_result_value(context, arg);

	if (val_aff == SQLITE_INTEGER)
	{
		unsigned char	aBlob[5]; /* max possible for IP v4 + bits */
		sqlite_uint64	v = sqlite3_value_int64(arg);
		bool			is_cidr = v >= 0x100000000ULL; /* more than 4 bytes integer */

		aBlob[0] = (v >> (CHAR_BIT * 3)) & 0xff;
		aBlob[1] = (v >> (CHAR_BIT * 2)) & 0xff;
		aBlob[2] = (v >> (CHAR_BIT * 1)) & 0xff;
		aBlob[3] = (v >> (CHAR_BIT * 0)) & 0xff;
		if (is_cidr)
			aBlob[4] = (v >> (CHAR_BIT * 4)) & 0xff;

		sqlite3_result_blob(context, aBlob, is_cidr ? 5 : 4, SQLITE_TRANSIENT);
		return;
	}
	if (val_aff == SQLITE_TEXT && sqlite3_value_bytes(arg) <= MAX_IP_TEXT_CHAR_LENGTH)
	{
		const char	   *txt = (const char *)sqlite3_value_text(arg);
		unsigned char	aBlob[17]; /* max possible for in v6 + cidr */
		/*
		 * First, check to see if this is an IPv6 or IPv4 address.  IPv6 addresses
		 * will have a : somewhere in them (several, in fact) so if there is one
		 * present, assume it's V6, otherwise assume it's V4.
		 */
		int				family = (strchr(txt, ':') != NULL) ? PGSQL_AF_INET6 : PGSQL_AF_INET;
		bool			is_cidr = (strchr(txt, '/') != NULL);
		unsigned char	bits = pg_inet_net_pton(family, txt, aBlob, -1);
		int				ip_len = family == PGSQL_AF_INET ? 4 : 16;
		int				maxbits = ip_len * CHAR_BIT;

		if ((bits < 0) || (bits > maxbits))
   			ereport(ERROR,
					(errcode(ERRCODE_INVALID_TEXT_REPRESENTATION),
			/* translator: first %s is inet or cidr */
					 errmsg("invalid input syntax for type %s: \"%s\"",
							is_cidr ? "cidr" : "inet", txt)));

		/*
		 * Error check: CIDR values must not have any bits set beyond the masklen.
		 */
		if (is_cidr)
		{
			if (!addressOK(aBlob, bits, family))
				ereport(ERROR,
						(errcode(ERRCODE_INVALID_TEXT_REPRESENTATION),
						 errmsg("invalid cidr value: \"%s\"", txt),
						 errdetail("Value has bits set to right of mask.")));
			aBlob[ip_len] = bits;
		}
		sqlite3_result_blob(context, aBlob, ip_len + is_cidr, SQLITE_TRANSIENT);
		return;
	}
	sqlite3_result_value(context, arg);
}

/*
 * Returns integer for BLOB IP address value
 */
static sqlite_uint64
ipaddr_v4_int (const unsigned char *pBlob, int len)
{
	sqlite_uint64 res =
		(((sqlite_int64)(pBlob[0])) << (CHAR_BIT * 3)) +
		(((sqlite_int64)(pBlob[1])) << (CHAR_BIT * 2)) +
		(((sqlite_int64)(pBlob[2])) << (CHAR_BIT * 1)) +
		(((sqlite_int64)(pBlob[3])) << (CHAR_BIT * 0));

	if (len == 5)
		res += (((sqlite_int64)(pBlob[4])) << (CHAR_BIT * 4));
	return res;
}

/*
 * Converts BLOB argument IP address (both v4 or v6) to
 * IP-BLOB for IPv6 and IP-integer for IPv4.
 */
static void
sqlite_fdw_ipaddr_native(sqlite3_context* context, int argc, sqlite3_value** argv)
{
	sqlite3_value  *arg = argv[0];
	int				len = sqlite3_value_bytes(arg);

	if (sqlite3_value_type(arg) != SQLITE_BLOB)
		ereport(ERROR,
		(errcode(ERRCODE_FDW_INVALID_DATA_TYPE),
		 errmsg("Native form of IP address exists only for BLOB input affinity value")));

	if (len == 16 || len == 17)
	{
		sqlite3_result_value(context, arg);
		return;
	}

	if (len == 4 || len == 5)
	{
		sqlite_uint64 res = ipaddr_v4_int(sqlite3_value_blob(arg), len);
		sqlite3_result_int64(context, res);
		return;
	}
	ereport(ERROR,
		(errcode(ERRCODE_FDW_INVALID_DATA_TYPE),
		 errmsg("Invalid input for IP address"),
		 errhint("Wrong length or not BLOB affinity")));
}

/*
 * Converts BLOB argument IP address (both v4 or v6) to
 *  IP-integer for IPv4.
 */
static void
sqlite_fdw_ipaddr_int(sqlite3_context* context, int argc, sqlite3_value** argv)
{
	sqlite3_value		   *arg = argv[0];
	int						val_aff = sqlite3_value_type(arg);
	int						len = sqlite3_value_bytes(arg);
	const unsigned char	   *pBlob;
	sqlite_uint64			res = 0;

	if (val_aff != SQLITE_BLOB)
		ereport(ERROR,
		(errcode(ERRCODE_FDW_INVALID_DATA_TYPE),
		 errmsg("Native form of IP address exists only for BLOB input affinity value")));

	pBlob = sqlite3_value_blob(arg);
	if (len == 4 || len == 5)
	{
		res = ipaddr_v4_int(pBlob, len);
		sqlite3_result_int64(context, res);
		return;
	}
	ereport(ERROR,
		(errcode(ERRCODE_FDW_INVALID_DATA_TYPE),
		 errmsg("You can write with integer affinity only IP v4 value"),
		 errhint("Wrong length or not BLOB input affinity")));
}

/*
 * Makes pg error from SQLite error.
 * Interrupts normal executing, no need return after place of calling
 */
static void
error_catcher(sqlite3* db, int rc)
{
	if (rc == SQLITE_OK)
		return;
	else
	{
		const char * err = sqlite3_errmsg(db);
		ereport(ERROR,
				(errcode(ERRCODE_FDW_UNABLE_TO_ESTABLISH_CONNECTION),
				 errmsg("failed to create data unifying functions for SQLite DB"),
				 errhint("%s \n SQLite code %d", err, rc)));
	}
}

/*
 * Add data normalization fuctions to SQLite internal namespace for calling
 * in deparse context.
 * This is main function of internal SQLite extension presented in this file.
 */
void
sqlite_fdw_data_norm_functs_init(sqlite3* db)
{
	static const int det_flags = SQLITE_UTF8 | SQLITE_INNOCUOUS | SQLITE_DETERMINISTIC;

	int rc = sqlite3_create_function(db, "sqlite_fdw_uuid_blob", 1, det_flags, 0, sqlite_fdw_data_norm_uuid, 0, 0);
	error_catcher(db, rc);
	rc = sqlite3_create_function(db, "sqlite_fdw_uuid_str", 1, det_flags, 0, sqlite_fdw_uuid_str, 0, 0);
	error_catcher(db, rc);
	rc = sqlite3_create_function(db, "sqlite_fdw_bool", 1, det_flags, 0, sqlite_fdw_data_norm_bool, 0, 0);
	error_catcher(db, rc);
	rc = sqlite3_create_function(db, "sqlite_fdw_float", 1, det_flags, 0, sqlite_fdw_data_norm_float, 0, 0);
	error_catcher(db, rc);
	rc = sqlite3_create_function(db, "sqlite_fdw_macaddr_int", 2, det_flags, 0, sqlite_fdw_data_norm_macaddr, 0, 0);
	error_catcher(db, rc);
	rc = sqlite3_create_function(db, "sqlite_fdw_macaddr_str", 2, det_flags, 0, sqlite_fdw_macaddr_str, 0, 0);
	error_catcher(db, rc);
	rc = sqlite3_create_function(db, "sqlite_fdw_macaddr_blob", 2, det_flags, 0, sqlite_fdw_macaddr_blob, 0, 0);
	error_catcher(db, rc);
	rc = sqlite3_create_function(db, "sqlite_fdw_ipaddr_blob", 1, det_flags, 0, sqlite_fdw_ipaddr_blob, 0, 0);
	error_catcher(db, rc);
	rc = sqlite3_create_function(db, "sqlite_fdw_ipaddr_str", 1, det_flags, 0, sqlite_fdw_ipaddr_str, 0, 0);
	error_catcher(db, rc);
	rc = sqlite3_create_function(db, "sqlite_fdw_ipaddr_int", 1, det_flags, 0, sqlite_fdw_ipaddr_int, 0, 0);
	error_catcher(db, rc);
	rc = sqlite3_create_function(db, "sqlite_fdw_ipaddr_native", 1, det_flags, 0, sqlite_fdw_ipaddr_native, 0, 0);
	error_catcher(db, rc);

	/*
	 *	static const int flags = SQLITE_UTF8 | SQLITE_INNOCUOUS;
	 *	sqlite3_create_function(db, "uuid_generate_v4", 0, flags, 0, uuid_generate, 0, 0);
	 *	sqlite3_create_function(db, "gen_random_uuid", 1, flags, 0, uuid_generate, 0, 0);
	 *
	 * no rc because in future SQLite releases it can be added UUID generation function
	 * PostgreSQL 13+, no gen_random_uuid() before
	 */
}
