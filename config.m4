
if test "$GCC" = "yes" ; then

	# -pedantic can also be used to assist with porting to Microsoft C98 only compilers
	# Example: ./configure CFLAGS=-pedantic
	CFLAGS="$CFLAGS -Wall -Wno-pointer-sign"
	AC_MSG_NOTICE(Setting CFLAGS=$CFLAGS)
fi

PHP_ARG_WITH(sodium, for sodium support,
[  --with-sodium             Include sodium support])

PHP_ARG_ENABLE(sodium, whether to enable sodium support,
[  --enable-sodium           Enable sodium support])

if test "$PHP_SODIUM" != "no"; then

  dnl Write more examples of tests here...

  # --with-sodium -> check with-path
  SEARCH_PATH="/usr/local /usr"     # you might want to change this
  SEARCH_FOR="/include/sodium.h"  # you most likely want to change this
  if test -r $PHP_SODIUM/$SEARCH_FOR; then # path given as parameter
    SODIUM_DIR=$PHP_SODIUM
  else # search default path list
    AC_MSG_CHECKING([for sodium files in default path])
    for i in $SEARCH_PATH ; do
      if test -r $i/$SEARCH_FOR; then
        SODIUM_DIR=$i
        AC_MSG_RESULT(found in $i)
      fi
    done
  fi
  dnl
  if test -z "$SODIUM_DIR"; then
    AC_MSG_RESULT([not found])
    AC_MSG_ERROR([Please reinstall the sodium distribution])
  fi

  dnl # --with-sodium -> add include path
  PHP_ADD_INCLUDE($SODIUM_DIR/include)

  dnl # --with-sodium -> check for lib and symbol presence

 dnl   PHP_CHECK_LIBRARY($LIBNAME,$LIBSYMBOL,
 dnl   [
 dnl     PHP_ADD_LIBRARY_WITH_PATH($LIBNAME, $SODIUM_DIR/lib, SODIUM_SHARED_LIBADD)
 dnl     AC_DEFINE(HAVE_SODIUMLIB,1,[ ])
 dnl   ],[
 dnl     AC_MSG_ERROR([wrong sodium lib version or lib not found])
 dnl   ],[
 dnl     -L$SODIUM_DIR/lib -lm
 dnl   ])
    PHP_SODIUM_PREFIX=`$PKG_CONFIG libsodium --variable=prefix`
    PHP_SODIUM_LIBS=`$PKG_CONFIG libsodium --libs`
    PHP_SODIUM_INCS=`$PKG_CONFIG libsodium --cflags`
    PHP_EVAL_LIBLINE($PHP_SODIUM_LIBS, SODIUM_SHARED_LIBADD)
    PHP_EVAL_INCLINE($PHP_SODIUM_INCS)
  PHP_SUBST(SODIUM_SHARED_LIBADD)

  # --with-sodium -> check with-path
  SEARCH_PATH="/usr/local /usr"     # you might want to change this
  SEARCH_FOR="/include/sodium.h"  # you most likely want to change this
  if test -r $PHP_SODIUM/$SEARCH_FOR; then # path given as parameter
    SODIUM_DIR=$PHP_SODIUM
  else # search default path list
    AC_MSG_CHECKING([for sodium files in default path])
    for i in $SEARCH_PATH ; do
      if test -r $i/$SEARCH_FOR; then
        SODIUM_DIR=$i
        AC_MSG_RESULT(found in $i)
      fi
    done
  fi

  if test -z "$SODIUM_DIR"; then
    AC_MSG_RESULT([not found])
    AC_MSG_ERROR([Please reinstall the sodium distribution])
  fi

  # --with-sodium -> add include path
  PHP_ADD_INCLUDE($SODIUM_DIR/include)

  LIBNAME=sodium # you may want to change this
  LIBSYMBOL=sodium_version_string # you most likely want to change this 

     PHP_CHECK_LIBRARY($LIBNAME,$LIBSYMBOL,
     [
       PHP_ADD_LIBRARY_WITH_PATH($LIBNAME, $SODIUM_DIR/lib, SODIUM_SHARED_LIBADD)
       AC_DEFINE(HAVE_SODIUMLIB,1,[ ])
     ],[
       AC_MSG_ERROR([wrong sodium lib version or lib not found])
     ],[
       -L$SODIUM_DIR/lib -lm
     ])

  type git &>/dev/null

  if test $? -eq 0  ; then

	git describe --tags &>/dev/null

	if test $? -eq 0 ; then
  		AC_DEFINE_UNQUOTED([PHP_SODIUM_VERSION], `git describe --tags --abbr=0`, [git version])
	else
        AC_DEFINE([PHP_SODIUM_VERSION], [no tag], [git version])
	fi

  else
	  AC_MSG_NOTICE([git not installed. Cannot obtain php_sodium version tag. Install git.])
      AC_DEFINE([PHP_SODIUM_VERSION], [dev_no_git], [git version])

  fi
  PHP_ADD_LIBRARY_WITH_PATH($LIBNAME, $SODIUM_DIR/lib, SODIUM_SHARED_LIBADD)
  PHP_SUBST(SODIUM_SHARED_LIBADD)
  PHP_NEW_EXTENSION(sodium, sodium.c, $ext_shared)
fi
