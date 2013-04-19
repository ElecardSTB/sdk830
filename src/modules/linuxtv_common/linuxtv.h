/*
 * Common header for supporting dvb and v4l
 *
 * Copyright (C) 2013 Anton Sergeev <Anton.Sergeev@elecard.ru>
 */

#ifndef __LINUXTV_H__
#define __LINUXTV_H__
/******************************************************************
* INCLUDE FILES                                                   *
*******************************************************************/
//V4L2_VERSION defined in <LinuxTV_builddir>/linux/kernel_version.h which includes from <LinuxTV_builddir>/v4l/compat.h
//<LinuxTV_builddir>/v4l/compat.h passed into gcc cflags (-include <LinuxTV_builddir>/v4l/compat.h) if this sorurce build with linuxtv project.
#include <linux/version.h>
#if (defined V4L2_VERSION)
#undef LINUX_VERSION_CODE
#define LINUX_VERSION_CODE V4L2_VERSION
#endif

/******************************************************************
* EXPORTED MACROS                              [for headers only] *
*******************************************************************/


#endif /* __LINUXTV_H__ */
