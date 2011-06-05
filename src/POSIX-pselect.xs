#define NEED_newSVpvn_flags
#include "xshelper.h"

/* stolen from pp_sselect() at pp_sys.c */
void
do_pselect(pTHX)
{
    dVAR; dSP; dTARGET;
    register I32 i;
    register I32 j;
    register char *s;
    register SV *sv;
    NV value;
    I32 maxlen = 0;
    I32 nfound;
    struct timeval timebuf;
    struct timeval *tbuf = &timebuf;
    I32 growsize;
    char *fd_sets[4];
#if BYTEORDER != 0x1234 && BYTEORDER != 0x12345678
        I32 masksize;
        I32 offset;
        I32 k;

#   if BYTEORDER & 0xf0000
#        define ORDERBYTE (0x88888888 - BYTEORDER)
#   else
#        define ORDERBYTE (0x4444 - BYTEORDER)
#   endif

#endif

    SP -= 4;
    for (i = 1; i <= 3; i++) {
        SV * const sv = SP[i];
        if (!SvOK(sv))
            continue;
        if (SvREADONLY(sv)) {
            if (SvIsCOW(sv))
                sv_force_normal_flags(sv, 0);
            if (SvREADONLY(sv) && !(SvPOK(sv) && SvCUR(sv) == 0))
                Perl_croak_no_modify(aTHX);
        }
        if (!SvPOK(sv)) {
            Perl_ck_warner(aTHX_ packWARN(WARN_MISC), "Non-string passed as bitmask");
            SvPV_force_nolen(sv);        /* force string conversion */
        }
        j = SvCUR(sv);
        if (maxlen < j)
            maxlen = j;
    }

/* little endians can use vecs directly */
#if BYTEORDER != 0x1234 && BYTEORDER != 0x12345678
#  ifdef NFDBITS

#    ifndef NBBY
#     define NBBY 8
#    endif

    masksize = NFDBITS / NBBY;
#  else
    masksize = sizeof(long);        /* documented int, everyone seems to use long */
#  endif
    Zero(&fd_sets[0], 4, char*);
#endif

#  if SELECT_MIN_BITS == 1
    growsize = sizeof(fd_set);
#  else
#   if defined(__GLIBC__) && defined(__FD_SETSIZE)
#      undef SELECT_MIN_BITS
#      define SELECT_MIN_BITS __FD_SETSIZE
#   endif
    /* If SELECT_MIN_BITS is greater than one we most probably will want
     * to align the sizes with SELECT_MIN_BITS/8 because for example
     * in many little-endian (Intel, Alpha) systems (Linux, OS/2, Digital
     * UNIX, Solaris, NeXT, Darwin) the smallest quantum select() operates
     * on (sets/tests/clears bits) is 32 bits.  */
    growsize = maxlen + (SELECT_MIN_BITS/8 - (maxlen % (SELECT_MIN_BITS/8)));
#  endif

    sv = SP[4];
    if (SvOK(sv)) {
        value = SvNV(sv);
        if (value < 0.0)
            value = 0.0;
        timebuf.tv_sec = (long)value;
        value -= (NV)timebuf.tv_sec;
        timebuf.tv_usec = (long)(value * 1000000.0);
    }
    else
        tbuf = NULL;

    for (i = 1; i <= 3; i++) {
        sv = SP[i];
        if (!SvOK(sv) || SvCUR(sv) == 0) {
            fd_sets[i] = 0;
            continue;
        }
        assert(SvPOK(sv));
        j = SvLEN(sv);
        if (j < growsize) {
            Sv_Grow(sv, growsize);
        }
        j = SvCUR(sv);
        s = SvPVX(sv) + j;
        while (++j <= growsize) {
            *s++ = '\0';
        }

#if BYTEORDER != 0x1234 && BYTEORDER != 0x12345678
        s = SvPVX(sv);
        Newx(fd_sets[i], growsize, char);
        for (offset = 0; offset < growsize; offset += masksize) {
            for (j = 0, k=ORDERBYTE; j < masksize; j++, (k >>= 4))
                fd_sets[i][j+offset] = s[(k % masksize) + offset];
        }
#else
        fd_sets[i] = SvPVX(sv);
#endif
    }

#ifdef PERL_IRIX5_SELECT_TIMEVAL_VOID_CAST
    /* Can't make just the (void*) conditional because that would be
     * cpp #if within cpp macro, and not all compilers like that. */
    nfound = PerlSock_select(
        maxlen * 8,
        (Select_fd_set_t) fd_sets[1],
        (Select_fd_set_t) fd_sets[2],
        (Select_fd_set_t) fd_sets[3],
        (void*) tbuf); /* Workaround for compiler bug. */
#else
    nfound = PerlSock_select(
        maxlen * 8,
        (Select_fd_set_t) fd_sets[1],
        (Select_fd_set_t) fd_sets[2],
        (Select_fd_set_t) fd_sets[3],
        tbuf);
#endif
    for (i = 1; i <= 3; i++) {
        if (fd_sets[i]) {
            sv = SP[i];
#if BYTEORDER != 0x1234 && BYTEORDER != 0x12345678
            s = SvPVX(sv);
            for (offset = 0; offset < growsize; offset += masksize) {
                for (j = 0, k=ORDERBYTE; j < masksize; j++, (k >>= 4))
                    s[(k % masksize) + offset] = fd_sets[i][j+offset];
            }
            Safefree(fd_sets[i]);
#endif
            SvSETMAGIC(sv);
        }
    }

    PUSHi(nfound);
    if (GIMME == G_ARRAY && tbuf) {
        value = (NV)(timebuf.tv_sec) +
                (NV)(timebuf.tv_usec) / 1000000.0;
        mPUSHn(value);
    }
    RETURN;
}


MODULE = POSIX::pselect    PACKAGE = POSIX::pselect

PROTOTYPES: DISABLE

void
pselect(rfdset, wfdset, efdset, timeout, sigset)
CODE:
{
    do_pselect(aTHX);
}
