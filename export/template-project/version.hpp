/*! version.hpp */

#ifndef _<PKG>_VERSION_HPP_
#define _<PKG>_VERSION_HPP_

#if defined(_WIN32) && !defined(__GCC__)
#  ifdef BUILDING_<PKG>
#    define DT_API __declspec(dllexport)
#  else
#    define DT_API __declspec(dllimport)
#  endif
#  ifndef _CRT_SECURE_NO_WARNINGS
#    define _CRT_SECURE_NO_WARNINGS
#  endif
#else
#  ifdef BUILDING_<PKG>
#    define <PKG>_API __attribute__ ((visibility ("default")))
#  else
#    define <PKG>_API 
#  endif
#endif

#endif//_<PKG>_VERSION_HPP_
